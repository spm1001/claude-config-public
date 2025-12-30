#!/bin/bash
# Consolidated context gathering for /open
# Outputs structured sections for Claude to parse

set -e

# Time-aware language: converts timestamp to human-readable with absolute anchor
# Usage: time_ago <seconds_ago> <epoch_timestamp>
time_ago() {
    local seconds=$1
    local timestamp=$2
    local absolute=$(date -r "$timestamp" '+%Y-%m-%d %H:%M' 2>/dev/null || date -d "@$timestamp" '+%Y-%m-%d %H:%M' 2>/dev/null)

    local relative
    if [ "$seconds" -lt 60 ]; then
        relative="just now"
    elif [ "$seconds" -lt 3600 ]; then
        local mins=$((seconds / 60))
        [ "$mins" -eq 1 ] && relative="1 minute ago" || relative="$mins minutes ago"
    elif [ "$seconds" -lt 86400 ]; then
        local hours=$((seconds / 3600))
        [ "$hours" -eq 1 ] && relative="1 hour ago" || relative="$hours hours ago"
    elif [ "$seconds" -lt 172800 ]; then
        relative="yesterday"
    else
        local days=$((seconds / 86400))
        relative="$days days ago"
    fi

    echo "$relative ($absolute)"
}

# === HANDOFF ===
echo "=== HANDOFF ==="

# Central location (matches Claude Code session folder pattern)
ARCHIVE_DIR="$HOME/.claude/handoffs"
CWD=$(pwd)
NOW=$(date +%s)

# Encode path: /Users/foo/bar → -Users-foo-bar
ENCODED_PATH=$(echo "$CWD" | tr '/' '-')
PROJECT_FOLDER="$ARCHIVE_DIR/$ENCODED_PATH"

if [ -d "$PROJECT_FOLDER" ]; then
    # Get most recent handoff from this project's folder
    MATCH_FILE=$(ls -t "$PROJECT_FOLDER"/*.md 2>/dev/null | head -1)

    if [ -n "$MATCH_FILE" ] && [ -f "$MATCH_FILE" ]; then
        FILE_TIME=$(stat -f '%m' "$MATCH_FILE" 2>/dev/null || stat -c '%Y' "$MATCH_FILE" 2>/dev/null)
        SECONDS_AGO=$((NOW - FILE_TIME))
        TIME_STR=$(time_ago $SECONDS_AGO $FILE_TIME)
        echo "# Handoff ($TIME_STR)"
        echo ""
        cat "$MATCH_FILE"
        echo ""
        echo "HANDOFF_EXISTS=true"
        echo "HANDOFF_AGE_SECONDS=$SECONDS_AGO"
    else
        echo "HANDOFF_EXISTS=false"
    fi
else
    echo "HANDOFF_EXISTS=false"
fi

# === GIT STATUS ===
echo ""
echo "=== GIT ==="
if [ -d ".git" ]; then
    DIRTY=$(git status --porcelain 2>/dev/null)
    UNPUSHED=$(git rev-list --count @{u}..HEAD 2>/dev/null || echo "0")
    if [ -n "$DIRTY" ] || [ "$UNPUSHED" -gt 0 ]; then
        echo "WARNING: Uncommitted/unpushed work detected"
        if [ -n "$DIRTY" ]; then
            echo "  Uncommitted:"
            echo "$DIRTY" | head -5 | sed 's/^/    /'
            TOTAL=$(echo "$DIRTY" | wc -l | tr -d ' ')
            [ "$TOTAL" -gt 5 ] && echo "    ... and $((TOTAL - 5)) more"
        fi
        [ "$UNPUSHED" -gt 0 ] && echo "  Unpushed: $UNPUSHED commits"
        echo "GIT_DIRTY=true"
    else
        # Silent when clean - nothing to act on
        echo "GIT_DIRTY=false"
    fi
else
    # Silent when not a repo - nothing to act on
    echo "GIT_DIRTY=false"
fi

# === BEADS ===
echo ""
echo "=== BEADS ==="
if [ -d ".beads" ] && command -v bd &> /dev/null; then
    bd ready 2>/dev/null | head -15

    # Show recently closed (context for what just finished)
    RECENTLY_CLOSED=$(bd list --status closed 2>/dev/null | head -5)
    if [ -n "$RECENTLY_CLOSED" ]; then
        echo ""
        echo "Recently closed:"
        echo "$RECENTLY_CLOSED"
    fi

    echo "BEADS_EXISTS=true"

    # Gate: require Skill(beads) before proceeding
    echo ""
    echo "GATE_REQUIRED=true"
    echo "NEXT_ACTION=Skill(beads)"
    echo "→ Next: Skill(beads) to load workflow patterns"
else
    # Silent when no beads - not all projects use them
    echo "BEADS_EXISTS=false"
fi

# === UPDATE NEWS ===
echo ""
echo "=== UPDATE_NEWS ==="
if [ -f "$HOME/.claude/.update-news" ]; then
    cat "$HOME/.claude/.update-news"
    echo "UPDATE_NEWS_EXISTS=true"
else
    # Silent when no news
    echo "UPDATE_NEWS_EXISTS=false"
fi

# === CONTEXT DETECTION ===
# Customize this section for your own task management integration
echo ""
echo "=== CONTEXT ==="
CWD=$(pwd)

# Example context detection - customize for your setup
case "$CWD" in
    "$HOME/Repos"*|"$HOME/.claude"*)
        echo "CONTEXT=development"
        ;;
    *"Documents"*|*"Work"*)
        echo "CONTEXT=work"
        ;;
    *)
        echo "CONTEXT=general"
        ;;
esac
