#!/bin/bash
# Inline web initialization for Claude Code (copy content to $WEBINIT variable)
# This version embeds all commands to bypass network timing issues at boot

# Compact one-liner version (for $WEBINIT environment variable):
# [ "$CLAUDE_CODE_REMOTE" = "true" ] && { echo "🌐 Initializing..."; command -v bd >/dev/null || { go install github.com/steveyegge/beads/cmd/bd@latest && cat > /usr/local/bin/bd <<'BDWRAP'
# #!/bin/bash
# exec /root/go/bin/bd "$@"
# BDWRAP
# chmod +x /usr/local/bin/bd && echo "✓ bd installed"; }; [ -d "$CLAUDE_PROJECT_DIR/.beads" ] && { [ -f "$CLAUDE_PROJECT_DIR/.beads/issues.jsonl" ] && [ ! -f "$CLAUDE_PROJECT_DIR/.beads/beads.db" ] && { PREFIX=$(head -1 "$CLAUDE_PROJECT_DIR/.beads/issues.jsonl" | grep -o '"id":"[^-]*' | cut -d'"' -f4); [ -n "$PREFIX" ] && { cd "$CLAUDE_PROJECT_DIR" && bd init "$PREFIX" --quiet 2>/dev/null; }; }; bd ready --limit 5 2>/dev/null || echo "📋 Beads repo detected"; }; echo "✅ Ready!"; }

# Expanded readable version (for understanding/testing):
if [ "$CLAUDE_CODE_REMOTE" = "true" ]; then
    echo "🌐 Initializing Claude Code web environment..."

    # Install bd if not present
    if ! command -v bd &> /dev/null; then
        if go install github.com/steveyegge/beads/cmd/bd@latest; then
            # Create wrapper for PATH persistence
            cat > /usr/local/bin/bd <<'EOF'
#!/bin/bash
exec /root/go/bin/bd "$@"
EOF
            chmod +x /usr/local/bin/bd
            echo "✓ bd installed"
        fi
    fi

    # Handle beads repository
    if [ -d "$CLAUDE_PROJECT_DIR/.beads" ]; then
        # Initialize database if JSONL exists but DB doesn't
        if [ -f "$CLAUDE_PROJECT_DIR/.beads/issues.jsonl" ] && [ ! -f "$CLAUDE_PROJECT_DIR/.beads/beads.db" ]; then
            # Extract prefix from first issue
            PREFIX=$(head -1 "$CLAUDE_PROJECT_DIR/.beads/issues.jsonl" | grep -o '"id":"[^-]*' | cut -d'"' -f4)
            if [ -n "$PREFIX" ]; then
                cd "$CLAUDE_PROJECT_DIR"
                bd init "$PREFIX" --quiet 2>/dev/null || true
            fi
        fi

        # Show ready work
        bd ready --limit 5 2>/dev/null || echo "📋 Beads repository detected"
    fi

    echo "✅ Ready!"
fi
