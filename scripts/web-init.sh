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

# Install beads CLI
echo "📦 Installing beads (bd)..."
BD_INSTALLED=false

if command -v bd &> /dev/null; then
    echo "✓ bd already available"
    BD_INSTALLED=true
else
    # Try npm install (may fail due to network restrictions)
    if npm install -g @beads/bd 2>/dev/null; then
        echo "✓ bd installed via npm"
        BD_INSTALLED=true
    else
        echo "⚠ npm install failed, trying alternative..."
        # Fallback: use install script (will try go install)
        if curl -fsSL https://raw.githubusercontent.com/steveyegge/beads/main/scripts/install.sh | bash 2>&1 | grep -q "installed successfully"; then
            echo "✓ bd installed via go"
            BD_INSTALLED=true
        else
            echo "⚠ Could not install bd automatically"
            echo "   Agent can still work with beads JSONL files directly"
        fi
    fi
fi

# Set up environment - persist PATH for subsequent commands
echo "🔧 Configuring environment..."
{
    echo 'export PATH="$PATH:$HOME/.local/bin"'
    echo 'export PATH="$PATH:$HOME/go/bin"'  # For go-installed bd
    echo 'export PATH="$PATH:/root/go/bin"'  # Alternative go path
} >> "$CLAUDE_ENV_FILE"

# Handle beads repository if it exists
if [ -d "$CLAUDE_PROJECT_DIR/.beads" ]; then
    echo ""
    echo "📋 Beads repository detected"

    # Check if database exists
    if [ -f "$CLAUDE_PROJECT_DIR/.beads/beads.db" ]; then
        # Database exists, just show ready work
        if $BD_INSTALLED; then
            bd ready --limit 5 2>/dev/null || echo "   Run 'bd ready' to see available work"
        else
            echo "   (bd not available - agent can read JSONL directly)"
        fi
    elif [ -f "$CLAUDE_PROJECT_DIR/.beads/issues.jsonl" ]; then
        # JSONL exists but no database - detect prefix to avoid mismatch
        echo "   Detecting existing prefix from issues.jsonl..."

        # Extract prefix from first issue ID in JSONL
        EXISTING_PREFIX=$(head -1 "$CLAUDE_PROJECT_DIR/.beads/issues.jsonl" | grep -o '"id":"[^-]*' | cut -d'"' -f4)

        if [ -n "$EXISTING_PREFIX" ] && $BD_INSTALLED; then
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
if $BD_INSTALLED && command -v bd &> /dev/null; then
    echo "   - beads: $(bd version) at $(which bd)"
else
    echo "   - beads: Not installed (agent can read JSONL files)"
fi
echo "   - Type 'bd --help' for commands (if bd is installed)"
