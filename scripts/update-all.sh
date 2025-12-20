#!/bin/bash
# Tiered auto-updater for dev tools
#
# Two tiers:
# - QUICK: Runs every trigger (<10s) - submodules, plugins, cleanup
# - HEAVY: Runs once per day max - brew, npm, mcp deps
#
# Triggered by git hooks (post-merge, pre-push)
# Logs to ~/.claude/scripts/update.log
#
# CUSTOMIZE: Add your MCP servers, repos, and tools in the marked sections below

set -euo pipefail

LOG_FILE="$HOME/.claude/scripts/update.log"
LOCK_FILE="$HOME/.claude/scripts/update.lock"
HEAVY_TIMESTAMP="$HOME/.claude/scripts/.last-heavy-update"
HEAVY_INTERVAL=$((24 * 60 * 60))  # 24 hours in seconds

# Prevent multiple simultaneous runs
if [ -f "$LOCK_FILE" ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') SKIP: Update already running" >> "$LOG_FILE"
    exit 0
fi

touch "$LOCK_FILE"
trap "rm -f $LOCK_FILE" EXIT

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $1" >> "$LOG_FILE"
}

log_section() {
    echo "" >> "$LOG_FILE"
    log "=== $1 ==="
}

# Check if heavy updates should run (>24h since last run)
should_run_heavy() {
    if [ ! -f "$HEAVY_TIMESTAMP" ]; then
        return 0  # Never run, should run
    fi

    last_run=$(cat "$HEAVY_TIMESTAMP")
    now=$(date +%s)
    elapsed=$((now - last_run))

    if [ $elapsed -gt $HEAVY_INTERVAL ]; then
        return 0  # Should run
    else
        hours_ago=$((elapsed / 3600))
        log "THROTTLE: Heavy updates ran ${hours_ago}h ago (next in $((24 - hours_ago))h)"
        return 1  # Skip
    fi
}

mark_heavy_complete() {
    date +%s > "$HEAVY_TIMESTAMP"
}

#######################################
# QUICK TIER - Every trigger (<10s)
#######################################

log_section "QUICK UPDATES"

# 1. Git submodules (e.g., skills/anthropic)
log "Updating git submodules..."
cd "$HOME/.claude" || exit
if git submodule update --remote --merge >> "$LOG_FILE" 2>&1; then
    log "✓ Submodules updated"
else
    log "⚠ Submodule update failed"
fi

# 2. Check for new skills in submodules
# This notifies you when new skills appear in anthropic or other submodules
log "Checking for new skills in submodules..."
NEW_SKILLS=""
SKILLS_DIR="$HOME/.claude/skills"
KNOWN_FILE="$SKILLS_DIR/.known-unlinked"
NOTIFY_FILE="$HOME/.claude/.new-skills-notification"

# Helper: check if skill is in known-unlinked list
is_known_unlinked() {
    local skill_id="$1"
    if [ -f "$KNOWN_FILE" ]; then
        grep -q "^$skill_id$" "$KNOWN_FILE" 2>/dev/null
        return $?
    fi
    return 1
}

# Check anthropic submodule (official Anthropic skills)
if [ -d "$SKILLS_DIR/anthropic/skills" ]; then
    for skill in "$SKILLS_DIR/anthropic/skills"/*/; do
        skill_name=$(basename "$skill")
        skill_id="anthropic:$skill_name"
        if [ ! -L "$SKILLS_DIR/$skill_name" ] && [ -f "$skill/SKILL.md" ]; then
            if ! is_known_unlinked "$skill_id"; then
                NEW_SKILLS="$NEW_SKILLS $skill_id"
            fi
        fi
    done
fi

# CUSTOMIZE: Add other skill submodules here
# Example: superpowers submodule
# if [ -d "$HOME/.claude/submodules/superpowers/skills" ]; then
#     for skill in "$HOME/.claude/submodules/superpowers/skills"/*/; do
#         skill_name=$(basename "$skill")
#         skill_id="superpowers:$skill_name"
#         if [ ! -L "$SKILLS_DIR/$skill_name" ] && [ -f "$skill/SKILL.md" ]; then
#             if ! is_known_unlinked "$skill_id"; then
#                 NEW_SKILLS="$NEW_SKILLS $skill_id"
#             fi
#         fi
#     done
# fi

if [ -n "$NEW_SKILLS" ]; then
    log "⚠ NEW SKILLS AVAILABLE:$NEW_SKILLS"
    log "  To enable: cd ~/.claude/skills && ln -s <source> <name>"
    log "  To ignore: add skill_id to ~/.claude/skills/.known-unlinked"
    # Write notification file for Claude to pick up at session start
    echo "$NEW_SKILLS" > "$NOTIFY_FILE"
else
    log "✓ All submodule skills accounted for"
    # Clear notification if no new skills
    rm -f "$NOTIFY_FILE"
fi

# 3. Issue tracker hygiene (if using bd/beads)
if command -v bd &> /dev/null; then
    log "Running bd doctor..."
    if bd doctor >> "$LOG_FILE" 2>&1; then
        log "✓ bd doctor passed"
    else
        log "⚠ bd doctor found issues (run 'bd doctor --fix' manually)"
    fi
fi

# 4. Backup Claude Desktop config (if changed)
BACKUP_DIR="$HOME/.claude/backup/claude-desktop"
CLAUDE_CONFIG="$HOME/Library/Application Support/Claude/claude_desktop_config.json"
CLAUDE_PLIST="$HOME/Library/Preferences/com.anthropic.claudefordesktop.plist"

mkdir -p "$BACKUP_DIR"

if [ -f "$CLAUDE_CONFIG" ]; then
    if ! cmp -s "$CLAUDE_CONFIG" "$BACKUP_DIR/claude_desktop_config.json" 2>/dev/null; then
        cp "$CLAUDE_CONFIG" "$BACKUP_DIR/claude_desktop_config.json"
        log "✓ Backed up claude_desktop_config.json"
    fi
fi

if [ -f "$CLAUDE_PLIST" ]; then
    if ! cmp -s "$CLAUDE_PLIST" "$BACKUP_DIR/com.anthropic.claudefordesktop.plist" 2>/dev/null; then
        cp "$CLAUDE_PLIST" "$BACKUP_DIR/com.anthropic.claudefordesktop.plist"
        log "✓ Backed up com.anthropic.claudefordesktop.plist"
    fi
fi

# 5. Cleanup stale artifacts
if [ -d "$HOME/.claude/local" ]; then
    rm -rf "$HOME/.claude/local"
    log "✓ Cleaned up stale ~/.claude/local directory"
fi

#######################################
# HEAVY TIER - Once per day max
#######################################

if should_run_heavy; then
    log_section "HEAVY UPDATES (daily)"

    HEAVY_FAILED=false

    # 1. Homebrew (macOS)
    log "Updating Homebrew packages..."
    if command -v brew &> /dev/null; then
        if brew update >> "$LOG_FILE" 2>&1 && \
           brew upgrade >> "$LOG_FILE" 2>&1 && \
           brew cleanup >> "$LOG_FILE" 2>&1; then
            log "✓ Homebrew updated"
        else
            log "⚠ Homebrew update had issues (check log)"
            HEAVY_FAILED=true
        fi
    else
        log "⚠ Homebrew not found"
    fi

    # 2. npm globals
    log "Updating npm global packages..."
    if command -v npm &> /dev/null; then
        if npm update -g >> "$LOG_FILE" 2>&1; then
            log "✓ npm globals updated"
        else
            log "⚠ npm global update failed"
            HEAVY_FAILED=true
        fi
    else
        log "⚠ npm not found"
    fi

    # 3. Claude Code CLI
    log "Updating Claude Code CLI..."
    if command -v claude &> /dev/null; then
        if claude update >> "$LOG_FILE" 2>&1; then
            log "✓ Claude Code CLI updated"
        else
            log "⚠ Claude Code CLI update failed"
            HEAVY_FAILED=true
        fi
    else
        log "⚠ Claude CLI not found"
    fi

    # 4. MCP server dependencies
    # CUSTOMIZE: Add your MCP servers here
    log "Updating MCP server dependencies..."
    if command -v uv &> /dev/null; then
        # Example: Python MCP server
        # if [ -d "$HOME/Repos/my-mcp-server" ]; then
        #     if uv sync --directory "$HOME/Repos/my-mcp-server" >> "$LOG_FILE" 2>&1; then
        #         log "✓ my-mcp-server dependencies synced"
        #     else
        #         log "⚠ my-mcp-server uv sync failed"
        #         HEAVY_FAILED=true
        #     fi
        # fi
        log "✓ MCP dependencies checked"
    else
        log "⚠ uv not found (skipping Python MCP dependency sync)"
    fi

    # 5. Shared team repos
    # CUSTOMIZE: Add repos that should stay current
    # Example:
    # if [ -d "$HOME/work/shared-tooling" ]; then
    #     cd "$HOME/work/shared-tooling"
    #     git pull origin main >> "$LOG_FILE" 2>&1
    #     log "✓ shared-tooling updated"
    # fi

    # Mark heavy updates complete (even if some failed, to avoid spam)
    mark_heavy_complete

    if [ "$HEAVY_FAILED" = true ]; then
        log "⚠ Some heavy updates failed - check log for details"
    else
        log "✓ All heavy updates completed successfully"
    fi
else
    log "SKIP: Heavy updates throttled"
fi

#######################################
# HEALTH SUMMARY
#######################################

log_section "SESSION INFO"

# Claude Desktop version (macOS)
if [ -f "/Applications/Claude.app/Contents/Info.plist" ]; then
    CLAUDE_VERSION=$(defaults read /Applications/Claude.app/Contents/Info.plist CFBundleShortVersionString 2>/dev/null || echo "unknown")
    log "Claude Desktop: v$CLAUDE_VERSION"
fi

# Claude Code CLI version
if command -v claude &> /dev/null; then
    CLI_VERSION=$(claude --version 2>/dev/null | head -1 || echo "unknown")
    log "Claude Code CLI: $CLI_VERSION"
fi

# bd version (if using beads issue tracker)
if command -v bd &> /dev/null && command -v brew &> /dev/null && brew list bd &> /dev/null; then
    BD_VERSION=$(brew info bd --json 2>/dev/null | jq -r '.[0].installed[0].version' 2>/dev/null || echo "unknown")
    log "bd CLI: v$BD_VERSION"
fi

# CUSTOMIZE: Add version checks for your tools

log "Update cycle complete"

# Trim log file to last 500 lines (prevent growth)
tail -n 500 "$LOG_FILE" > "$LOG_FILE.tmp" && mv "$LOG_FILE.tmp" "$LOG_FILE"
