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

# Install beads CLI via npm
echo "📦 Installing beads (bd)..."
if ! command -v bd &> /dev/null; then
    npm install -g @beads/bd
    echo "✓ bd $(bd version) installed"
else
    echo "✓ bd already available"
fi

# Set up environment
echo "🔧 Configuring environment..."
echo 'export PATH="$PATH:$HOME/.local/bin"' >> "$CLAUDE_ENV_FILE"

# If .beads exists, show ready work
if [ -d "$CLAUDE_PROJECT_DIR/.beads" ]; then
    echo ""
    echo "📋 Ready work in this repo:"
    bd ready --limit 5 2>/dev/null || echo "(bd database needs initialization)"
fi

echo ""
echo "✅ Web environment ready!"
if command -v bd &> /dev/null; then
    echo "   - beads: $(bd version) at $(which bd)"
fi
echo "   - Type 'bd --help' for commands"
