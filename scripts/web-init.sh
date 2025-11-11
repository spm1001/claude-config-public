#!/bin/bash
# Web environment initialization for Claude Code
# Usage: curl -fsSL https://raw.githubusercontent.com/spm1001/claude-config-public/main/scripts/web-init.sh | bash

set -e

# Only run in web environment
if [ "$CLAUDE_CODE_REMOTE" != "true" ]; then
    echo "Skipping web-init.sh (not in web environment)"
    exit 0
fi

echo "🌐 Initializing Claude Code web environment..."
echo "   Claude Code: v${CLAUDE_CODE_VERSION:-unknown}"
echo "   Session: ${CLAUDE_CODE_SESSION_ID:-unknown}"
echo "   Environment: ${CLAUDE_CODE_REMOTE_ENVIRONMENT_TYPE:-default}"
echo ""

# Install beads CLI via go install
echo "📦 Installing beads (bd)..."
if command -v bd &> /dev/null; then
    echo "✓ bd already available at $(which bd)"
else
    # Use go install directly (npm fails on /releases/download/ in web environment)
    if go install github.com/steveyegge/beads/cmd/bd@latest 2>&1 | tail -1 | grep -qE "go/bin/bd|installed"; then
        # Create wrapper in /usr/local/bin for PATH persistence
        # (Web environment: each bash call is isolated, .bashrc not sourced)
        cat > /usr/local/bin/bd <<'EOF'
#!/bin/bash
exec /root/go/bin/bd "$@"
EOF
        chmod +x /usr/local/bin/bd
        echo "✓ bd installed to /usr/local/bin ($(bd version))"
    else
        echo "⚠ Could not install bd automatically"
        echo "   Agent can still work with beads JSONL files directly"
    fi
fi

# Handle beads repository if it exists
if [ -d "$CLAUDE_PROJECT_DIR/.beads" ]; then
    echo ""
    echo "📋 Beads repository detected"

    # Check if database exists
    if [ -f "$CLAUDE_PROJECT_DIR/.beads/beads.db" ]; then
        # Database exists, just show ready work
        if command -v bd &> /dev/null; then
            bd ready --limit 5 2>/dev/null || echo "   Run 'bd ready' to see available work"
        else
            echo "   (bd not available - agent can read JSONL directly)"
        fi
    elif [ -f "$CLAUDE_PROJECT_DIR/.beads/issues.jsonl" ]; then
        # JSONL exists but no database - detect prefix to avoid mismatch
        echo "   Detecting existing prefix from issues.jsonl..."

        # Extract prefix from first issue ID in JSONL
        EXISTING_PREFIX=$(head -1 "$CLAUDE_PROJECT_DIR/.beads/issues.jsonl" | grep -o '"id":"[^-]*' | cut -d'"' -f4)

        if [ -n "$EXISTING_PREFIX" ] && command -v bd &> /dev/null; then
            echo "   Found prefix: $EXISTING_PREFIX"
            echo "   Initializing database with existing prefix..."
            cd "$CLAUDE_PROJECT_DIR"
            bd init "$EXISTING_PREFIX" --quiet 2>/dev/null || true
            echo "   ✓ Database initialized"
            bd ready --limit 5 2>/dev/null || echo "   Run 'bd ready' to see available work"
        else
            echo "   (Database will be created on first bd command)"
        fi
    else
        # No JSONL - fresh repo, don't initialize yet
        echo "   (Empty repository - run 'bd init' to start tracking work)"
    fi
fi

echo ""
echo "✅ Web environment ready!"
if command -v bd &> /dev/null; then
    echo "   - beads: $(bd version) at $(which bd)"
else
    echo "   - beads: Not installed (agent can read JSONL files)"
fi
