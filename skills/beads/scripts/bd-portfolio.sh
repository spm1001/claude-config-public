#!/bin/bash
# bd-portfolio.sh — Cross-project beads portfolio view
# Discovers all .beads/ directories and aggregates status
#
# Usage:
#   bd-portfolio.sh [OPTIONS] [COMMAND]
#
# Commands:
#   (default)              Show portfolio summary
#   skeletons [PROJECT]    List skeleton beads (optionally for specific project)
#
# Options:
#   --dir PATH             Directory to scan (default: ~/Repos)
#   --format FORMAT        Output format: summary, full, json, markdown (default: summary)
#   --filter PATTERN       Filter projects by glob pattern (e.g., "infra-*", "skill-*")
#   --help                 Show this help

set -euo pipefail

# Defaults
REPOS_DIR="$HOME/Repos"
OUTPUT_FORMAT="summary"
FILTER_PATTERN=""
COMMAND="portfolio"

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Show help
show_help() {
    cat << 'EOF'
bd-portfolio.sh — Cross-project beads portfolio view

Usage:
  bd-portfolio.sh [OPTIONS] [COMMAND]

Commands:
  (default)              Show portfolio summary
  skeletons [PROJECT]    List skeleton beads (optionally for specific project)

Options:
  --dir PATH             Directory to scan (default: ~/Repos)
  --format FORMAT        Output format: summary, full, json, markdown
  --filter PATTERN       Filter projects by glob pattern (e.g., "infra-*")
  --help                 Show this help

Examples:
  bd-portfolio.sh                           # Summary of all projects
  bd-portfolio.sh --format full             # Detailed breakdown
  bd-portfolio.sh --filter "infra-*"        # Only infra projects
  bd-portfolio.sh --format markdown > report.md  # Export report
  bd-portfolio.sh skeletons                 # List all skeleton beads
  bd-portfolio.sh skeletons infra-openwrt   # Skeletons in specific project
EOF
}

# Check dependencies
check_dependencies() {
    local missing=()

    if ! command -v jq &> /dev/null; then
        missing+=("jq")
    fi

    if ! command -v bd &> /dev/null; then
        missing+=("bd")
    fi

    if [ ${#missing[@]} -gt 0 ]; then
        echo "Error: Missing required dependencies: ${missing[*]}" >&2
        echo "Install with:" >&2
        for dep in "${missing[@]}"; do
            case "$dep" in
                jq) echo "  brew install jq" >&2 ;;
                bd) echo "  See beads installation docs" >&2 ;;
            esac
        done
        exit 1
    fi
}

# Parse arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --dir)
                REPOS_DIR="$2"
                shift 2
                ;;
            --format)
                OUTPUT_FORMAT="$2"
                shift 2
                ;;
            --filter)
                FILTER_PATTERN="$2"
                shift 2
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            skeletons)
                COMMAND="skeletons"
                shift
                if [[ $# -gt 0 && ! "$1" =~ ^-- ]]; then
                    SKELETON_PROJECT="$1"
                    shift
                fi
                ;;
            *)
                # Legacy positional args for backwards compatibility
                if [[ -d "$1" ]]; then
                    REPOS_DIR="$1"
                elif [[ "$1" =~ ^(summary|full|json|markdown)$ ]]; then
                    OUTPUT_FORMAT="$1"
                fi
                shift
                ;;
        esac
    done
}

# Find all .beads directories (exclude .git subdirs and worktrees)
find_beads_dirs() {
    local dirs
    dirs=$(find "$REPOS_DIR" -name ".beads" -type d 2>/dev/null | \
        grep -v "\.git/" | \
        grep -v "beads-worktrees" | \
        sort)

    # Apply filter if specified
    if [ -n "$FILTER_PATTERN" ]; then
        local filtered=""
        while IFS= read -r dir; do
            local project_name=$(basename "$(dirname "$dir")")
            # Use bash pattern matching
            if [[ "$project_name" == $FILTER_PATTERN ]]; then
                filtered+="$dir"$'\n'
            fi
        done <<< "$dirs"
        echo "${filtered%$'\n'}"  # Remove trailing newline
    else
        echo "$dirs"
    fi
}

# Get beads summary for a single project
get_project_summary() {
    local beads_dir="$1"
    local project_dir=$(dirname "$beads_dir")
    local project_name=$(basename "$project_dir")

    # Run bd commands from project directory
    cd "$project_dir" 2>/dev/null || return 1

    # Use temp files for JSON to avoid bash variable escaping issues
    local tmp_all="/tmp/bd-portfolio-all-$$.json"
    local tmp_ready="/tmp/bd-portfolio-ready-$$.json"
    trap "rm -f $tmp_all $tmp_ready 2>/dev/null" RETURN

    # Get all issues as JSON (suppress daemon warnings)
    bd list --json 2>/dev/null > "$tmp_all" || echo "[]" > "$tmp_all"

    # Count by status
    local total=$(jq 'length' "$tmp_all")
    local open=$(jq '[.[] | select(.status == "open")] | length' "$tmp_all")
    local in_progress=$(jq '[.[] | select(.status == "in_progress")] | length' "$tmp_all")
    local closed=$(jq '[.[] | select(.status == "closed")] | length' "$tmp_all")

    # Count open by priority
    local p1=$(jq '[.[] | select(.status == "open" and .priority <= 1)] | length' "$tmp_all")
    local p2=$(jq '[.[] | select(.status == "open" and .priority == 2)] | length' "$tmp_all")
    local p3=$(jq '[.[] | select(.status == "open" and .priority >= 3)] | length' "$tmp_all")

    # Get ready count (suppress daemon warnings)
    bd ready --json 2>/dev/null > "$tmp_ready" || echo "[]" > "$tmp_ready"
    local ready=$(jq 'length' "$tmp_ready")

    # Detect skeleton beads (open with no description AND no design content beyond template)
    # Use type check to safely handle non-string design values
    local skeletons=$(jq '[.[] | select(
        .status == "open" and
        ((.description // "") == "" or (.description // "") == null) and
        (
            (.design == null) or
            (.design == "") or
            ((.design | type) == "string" and ((.design // "") | test("^\\s*$|DRAW-DOWN|^\\s*##\\s*Workflow")))
        )
    )] | length' "$tmp_all" 2>/dev/null || echo "0")

    # Determine category
    local category="dormant"
    if [ "$in_progress" -gt 0 ]; then
        category="active"
    elif [ "$p1" -gt 0 ] || [ "$p2" -gt 0 ]; then
        category="ready"
    elif [ "$open" -gt 0 ]; then
        category="stalled"
    fi

    # Output JSON for this project
    jq -n \
        --arg name "$project_name" \
        --arg path "$project_dir" \
        --arg category "$category" \
        --argjson total "$total" \
        --argjson open "$open" \
        --argjson in_progress "$in_progress" \
        --argjson closed "$closed" \
        --argjson ready "$ready" \
        --argjson p1 "$p1" \
        --argjson p2 "$p2" \
        --argjson p3 "$p3" \
        --argjson skeletons "$skeletons" \
        '{
            name: $name,
            path: $path,
            category: $category,
            counts: {
                total: $total,
                open: $open,
                in_progress: $in_progress,
                closed: $closed,
                ready: $ready
            },
            priorities: {
                p1: $p1,
                p2: $p2,
                p3: $p3
            },
            quality: {
                skeletons: $skeletons
            }
        }'
}

# List skeleton beads for a project
list_skeletons() {
    local project_dir="$1"
    local project_name=$(basename "$project_dir")

    cd "$project_dir" 2>/dev/null || return 1

    # Get skeleton beads with details
    bd list --json 2>/dev/null | jq -r '.[] | select(
        .status == "open" and
        ((.description // "") == "" or (.description // "") == null) and
        (
            (.design == null) or
            (.design == "") or
            ((.design | type) == "string" and ((.design // "") | test("^\\s*$|DRAW-DOWN|^\\s*##\\s*Workflow")))
        )
    ) | "  [\(.priority // 2)] \(.id): \(.title)"' 2>/dev/null
}

# Skeletons command
cmd_skeletons() {
    local target_project="${SKELETON_PROJECT:-}"

    if [ -n "$target_project" ]; then
        # Specific project
        local project_dir="$REPOS_DIR/$target_project"
        if [ ! -d "$project_dir/.beads" ]; then
            echo "Error: No .beads directory found in $project_dir" >&2
            exit 1
        fi
        echo -e "${BOLD}Skeleton beads in $target_project:${NC}"
        list_skeletons "$project_dir"
    else
        # All projects
        echo -e "${BOLD}Skeleton beads across all projects:${NC}\n"
        local beads_dirs=$(find_beads_dirs)

        while IFS= read -r beads_dir; do
            [ -z "$beads_dir" ] && continue
            local project_dir=$(dirname "$beads_dir")
            local project_name=$(basename "$project_dir")
            local skeletons=$(list_skeletons "$project_dir")

            if [ -n "$skeletons" ]; then
                echo -e "${YELLOW}$project_name:${NC}"
                echo "$skeletons"
                echo ""
            fi
        done <<< "$beads_dirs"
    fi
}

# Portfolio command
cmd_portfolio() {
    local beads_dirs=$(find_beads_dirs)

    if [ -z "$beads_dirs" ]; then
        echo "No .beads directories found in $REPOS_DIR"
        [ -n "$FILTER_PATTERN" ] && echo "(filter: $FILTER_PATTERN)"
        exit 0
    fi

    # Collect all project summaries
    local projects="[]"
    while IFS= read -r beads_dir; do
        [ -z "$beads_dir" ] && continue
        local summary=$(get_project_summary "$beads_dir" 2>/dev/null || echo "")
        if [ -n "$summary" ]; then
            projects=$(echo "$projects" | jq --argjson p "$summary" '. + [$p]')
        fi
    done <<< "$beads_dirs"

    # Calculate totals
    local total_open=$(echo "$projects" | jq '[.[].counts.open] | add // 0')
    local total_closed=$(echo "$projects" | jq '[.[].counts.closed] | add // 0')
    local total_in_progress=$(echo "$projects" | jq '[.[].counts.in_progress] | add // 0')
    local total_skeletons=$(echo "$projects" | jq '[.[].quality.skeletons] | add // 0')
    local project_count=$(echo "$projects" | jq 'length')

    # Group by category
    local active=$(echo "$projects" | jq '[.[] | select(.category == "active")]')
    local ready=$(echo "$projects" | jq '[.[] | select(.category == "ready")]')
    local stalled=$(echo "$projects" | jq '[.[] | select(.category == "stalled")]')
    local dormant=$(echo "$projects" | jq '[.[] | select(.category == "dormant")]')

    case "$OUTPUT_FORMAT" in
        json)
            jq -n \
                --argjson projects "$projects" \
                --argjson active "$active" \
                --argjson ready "$ready" \
                --argjson stalled "$stalled" \
                --argjson dormant "$dormant" \
                --argjson total_open "$total_open" \
                --argjson total_closed "$total_closed" \
                --argjson total_in_progress "$total_in_progress" \
                --argjson total_skeletons "$total_skeletons" \
                '{
                    totals: {
                        open: $total_open,
                        closed: $total_closed,
                        in_progress: $total_in_progress,
                        skeletons: $total_skeletons,
                        projects: ($projects | length)
                    },
                    by_category: {
                        active: $active,
                        ready: $ready,
                        stalled: $stalled,
                        dormant: $dormant
                    },
                    all_projects: $projects
                }'
            ;;

        markdown)
            # Markdown export for reports
            local date=$(date +%Y-%m-%d)
            echo "# Beads Portfolio Report"
            echo ""
            echo "_Generated: ${date}_"
            echo ""
            echo "## Summary"
            echo ""
            echo "| Metric | Count |"
            echo "|--------|-------|"
            echo "| Projects | $project_count |"
            echo "| Open beads | $total_open |"
            echo "| In progress | $total_in_progress |"
            echo "| Closed | $total_closed |"
            [ "$total_skeletons" -gt 0 ] && echo "| **Skeleton beads** | **$total_skeletons** |"
            echo ""

            # Active
            local active_count=$(echo "$active" | jq 'length')
            if [ "$active_count" -gt 0 ]; then
                echo "## Active (work in progress)"
                echo ""
                echo "| Project | In Progress | Ready |"
                echo "|---------|-------------|-------|"
                echo "$active" | jq -r '.[] | "| \(.name) | \(.counts.in_progress) | \(.counts.ready) |"'
                echo ""
            fi

            # Ready
            local ready_count=$(echo "$ready" | jq 'length')
            if [ "$ready_count" -gt 0 ]; then
                echo "## Ready (P1-P2 work available)"
                echo ""
                echo "| Project | P1 | P2 | Ready |"
                echo "|---------|----|----|-------|"
                echo "$ready" | jq -r '.[] | "| \(.name) | \(.priorities.p1) | \(.priorities.p2) | \(.counts.ready) |"'
                echo ""
            fi

            # Stalled
            local stalled_count=$(echo "$stalled" | jq 'length')
            if [ "$stalled_count" -gt 0 ]; then
                echo "## Stalled (P3 only)"
                echo ""
                echo "| Project | Open |"
                echo "|---------|------|"
                echo "$stalled" | jq -r '.[] | "| \(.name) | \(.counts.open) |"'
                echo ""
            fi

            # Quality issues
            local projects_with_skeletons=$(echo "$projects" | jq '[.[] | select(.quality.skeletons > 0)]')
            local skeleton_project_count=$(echo "$projects_with_skeletons" | jq 'length')
            if [ "$skeleton_project_count" -gt 0 ]; then
                echo "## Quality Issues"
                echo ""
                echo "Skeleton beads (empty shells needing attention):"
                echo ""
                echo "| Project | Skeletons |"
                echo "|---------|-----------|"
                echo "$projects_with_skeletons" | jq -r '.[] | "| \(.name) | \(.quality.skeletons) |"'
            fi
            ;;

        full)
            # Full output with ready items listed
            echo -e "${BOLD}=== Beads Portfolio ===${NC}\n"
            echo -e "Scanning: $REPOS_DIR"
            [ -n "$FILTER_PATTERN" ] && echo -e "Filter: $FILTER_PATTERN"
            echo ""

            echo -e "${BOLD}Totals:${NC} $total_open open, $total_closed closed, $total_in_progress in progress"
            if [ "$total_skeletons" -gt 0 ]; then
                echo -e "${YELLOW}Warning:${NC} $total_skeletons skeleton beads (empty shells)"
            fi
            echo ""

            # Active projects (have in_progress)
            local active_count=$(echo "$active" | jq 'length')
            if [ "$active_count" -gt 0 ]; then
                echo -e "${GREEN}${BOLD}ACTIVE${NC} (work in progress):"
                echo "$active" | jq -r '.[] | "  \(.name): \(.counts.in_progress) in_progress, \(.counts.ready) ready"'
                echo ""
            fi

            # Ready projects (P1-P2 work available)
            local ready_count=$(echo "$ready" | jq 'length')
            if [ "$ready_count" -gt 0 ]; then
                echo -e "${BLUE}${BOLD}READY${NC} (P1-P2 work available):"
                echo "$ready" | jq -r '.[] | "  \(.name): P1=\(.priorities.p1) P2=\(.priorities.p2) (\(.counts.ready) ready)"'
                echo ""
            fi

            # Stalled projects (only P3 work)
            local stalled_count=$(echo "$stalled" | jq 'length')
            if [ "$stalled_count" -gt 0 ]; then
                echo -e "${YELLOW}${BOLD}STALLED${NC} (P3 only):"
                echo "$stalled" | jq -r '.[] | "  \(.name): \(.counts.open) open (all P3)"'
                echo ""
            fi

            # Dormant projects (all closed)
            local dormant_count=$(echo "$dormant" | jq 'length')
            if [ "$dormant_count" -gt 0 ]; then
                echo -e "${CYAN}${BOLD}DORMANT${NC} (all closed):"
                echo "$dormant" | jq -r '.[] | "  \(.name): \(.counts.closed) closed"'
                echo ""
            fi

            # Quality warnings
            local projects_with_skeletons=$(echo "$projects" | jq '[.[] | select(.quality.skeletons > 0)]')
            local skeleton_project_count=$(echo "$projects_with_skeletons" | jq 'length')
            if [ "$skeleton_project_count" -gt 0 ]; then
                echo -e "${RED}${BOLD}QUALITY ISSUES${NC} (skeleton beads):"
                echo "$projects_with_skeletons" | jq -r '.[] | "  \(.name): \(.quality.skeletons) empty shells"'
            fi
            ;;

        summary|*)
            # Compact summary (default)
            echo -e "${BOLD}Beads Portfolio${NC} — $total_open open across $project_count projects"
            [ -n "$FILTER_PATTERN" ] && echo -e "(filter: $FILTER_PATTERN)"
            echo ""

            # One-line per category
            local active_names=$(echo "$active" | jq -r '[.[].name] | join(", ")')
            local ready_names=$(echo "$ready" | jq -r '[.[].name] | join(", ")')
            local stalled_names=$(echo "$stalled" | jq -r '[.[].name] | join(", ")')

            [ -n "$active_names" ] && echo -e "${GREEN}Active:${NC} $active_names"
            [ -n "$ready_names" ] && echo -e "${BLUE}Ready:${NC} $ready_names"
            [ -n "$stalled_names" ] && echo -e "${YELLOW}Stalled:${NC} $stalled_names"

            if [ "$total_skeletons" -gt 0 ]; then
                echo -e "\n${RED}$total_skeletons skeleton beads need attention${NC}"
            fi
            ;;
    esac
}

# Main execution
main() {
    check_dependencies
    parse_args "$@"

    case "$COMMAND" in
        skeletons)
            cmd_skeletons
            ;;
        portfolio|*)
            cmd_portfolio
            ;;
    esac
}

main "$@"
