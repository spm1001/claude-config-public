#!/bin/bash
# Setup Claude Code for new machine
#
# Usage: ./setup-new-machine.sh
#
# Prerequisites:
# - Claude Code CLI installed
# - uv installed (for Python MCPs)
#
# What this does:
# 1. Creates settings.local.json with machine-specific permissions
# 2. Optionally registers MCP servers
# 3. Sets up git hooks for auto-updates
#
# CUSTOMIZE: Modify the paths and MCP registrations for your environment

set -e

echo "=== Claude Code New Machine Setup ==="
echo ""

# --- Local Settings Generation ---
echo "1. Creating settings.local.json..."

CONFIG_FILE="$HOME/.claude/settings.local.json"

# Check if file already exists
if [ -f "$CONFIG_FILE" ]; then
    echo "   ⚠ settings.local.json already exists"
    read -p "   Overwrite? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "   Skipped settings.local.json"
        GENERATE_LOCAL=false
    else
        GENERATE_LOCAL=true
    fi
else
    GENERATE_LOCAL=true
fi

if [ "$GENERATE_LOCAL" = true ]; then
    # Build the config with common defaults
    cat > "$CONFIG_FILE" << EOF
{
  "permissions": {
    "allow": [
      "WebFetch(domain:github.com)",
      "WebFetch(domain:docs.anthropic.com)",
      "WebFetch(domain:code.claude.com)",
      "Read(//private/tmp/**)",
      "Read(//Users/$USER/Repos/**)",
      "Read(//Users/$USER/.claude/**)",
      "Read(//Applications/**)"
    ],
    "deny": [],
    "ask": [],
    "additionalDirectories": [
      "/Users/$USER/Repos",
      "/Users/$USER/.claude"
    ]
  }
}
EOF

    echo "   ✓ Created settings.local.json"
    echo "   Note: Edit $CONFIG_FILE to add more paths/domains"
fi

echo ""

# --- MCP Server Registration (Optional) ---
echo "2. MCP Server Registration (optional)"
echo ""
echo "   Example registrations (uncomment in script to enable):"
echo ""

# CUSTOMIZE: Add your MCP server registrations here
# Example Python MCP server:
# if [ -d ~/Repos/my-mcp-server ]; then
#     claude mcp add my-server -- uv --directory ~/Repos/my-mcp-server run python -m my_server
#     echo "   ✓ my-server MCP registered"
# fi

# Example HTTP-based MCP server:
# claude mcp add docs-server --transport http -- https://example.com/mcp
# echo "   ✓ docs-server MCP registered"

echo "   (No MCPs configured - edit setup-new-machine.sh to add yours)"

echo ""

# --- Git Hooks for Auto-Updates (Optional) ---
echo "3. Git Hooks Setup (optional)"
echo ""

read -p "   Setup auto-update git hooks? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    mkdir -p "$HOME/.claude/.git/hooks"
    mkdir -p "$HOME/.claude/scripts"

    # Post-merge hook (runs after git pull)
    cat > "$HOME/.claude/.git/hooks/post-merge" << 'EOF'
#!/bin/bash
# Auto-update everything after git pull
nohup "$HOME/.claude/scripts/update-all.sh" > /dev/null 2>&1 &
echo "🔄 Auto-update started in background"
EOF
    chmod +x "$HOME/.claude/.git/hooks/post-merge"

    # Pre-push hook (runs before git push)
    cat > "$HOME/.claude/.git/hooks/pre-push" << 'EOF'
#!/bin/bash
# Auto-update everything before git push
nohup "$HOME/.claude/scripts/update-all.sh" > /dev/null 2>&1 &
echo "🔄 Auto-update started in background"
EOF
    chmod +x "$HOME/.claude/.git/hooks/pre-push"

    echo "   ✓ Git hooks created"
    echo "   Note: Copy update-all.sh to ~/.claude/scripts/ and customize"
else
    echo "   Skipped git hooks"
fi

echo ""
echo "=== Setup Complete ==="
echo ""
echo "Next steps:"
echo "  1. Edit ~/.claude/settings.local.json to add your paths/domains"
echo "  2. Copy and customize update-all.sh to ~/.claude/scripts/"
echo "  3. Register your MCP servers (see examples in this script)"
echo "  4. Restart Claude Code to load new settings"
