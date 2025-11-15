# Claude Code Scripts

Scripts for setting up and maintaining Claude Code configuration.

---

## New Machine Setup

**`setup-new-machine.sh`** - Run once when setting up Claude Code on a new machine.

```bash
./setup-new-machine.sh
```

**What it does:**
1. Creates `settings.local.json` with machine-specific permissions
2. Optionally registers MCP servers (you customize which ones)
3. Sets up git hooks for auto-updates

**Customization required:**
- Edit MCP server registrations for your environment
- Adjust default paths if needed
- Add project-specific configurations

---

## Tiered Auto-Update Script

**`update-all.sh`** - Automatically keeps dev tools current with intelligent throttling.

### Architecture

```
┌─────────────────────────────────────────────────┐
│ QUICK TIER (every trigger, <10s)               │
├─────────────────────────────────────────────────┤
│ • Git submodule update                          │
│ • Claude plugin marketplace refresh             │
│ • Claude Desktop config backup (if changed)    │
│ • Stale artifact cleanup                        │
└─────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────┐
│ HEAVY TIER (once per 24h max)                  │
├─────────────────────────────────────────────────┤
│ • Homebrew update + upgrade + cleanup           │
│ • npm global packages update                    │
│ • Claude Code CLI update                        │
│ • MCP server dependencies (uv sync)            │
│ • Shared team repo pulls                        │
└─────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────┐
│ HEALTH SUMMARY                                  │
├─────────────────────────────────────────────────┤
│ • Log tool versions                             │
│ • Report failures                               │
│ • Trim log file                                 │
└─────────────────────────────────────────────────┘
```

### Why Tiered?

Without throttling, every git push/pull runs full `brew upgrade` + `npm update -g` (20+ seconds of redundant work). The tiered approach:

- **Quick updates** run every time (<10 seconds)
- **Heavy updates** run once per day max
- Timestamp file tracks when heavy operations last ran

### Setup

1. **Copy to your .claude:**
```bash
cp update-all.sh ~/.claude/scripts/
chmod +x ~/.claude/scripts/update-all.sh
```

2. **Customize** the CUSTOMIZE sections:
   - Add your plugin marketplaces
   - Add your MCP server paths
   - Add shared team repos to pull
   - Add version checks for your tools

3. **Create git hooks** (optional):
```bash
# Post-merge (after git pull)
cat > ~/.claude/.git/hooks/post-merge << 'EOF'
#!/bin/bash
nohup "$HOME/.claude/scripts/update-all.sh" > /dev/null 2>&1 &
echo "🔄 Auto-update started in background"
EOF
chmod +x ~/.claude/.git/hooks/post-merge

# Pre-push (before git push)
cat > ~/.claude/.git/hooks/pre-push << 'EOF'
#!/bin/bash
nohup "$HOME/.claude/scripts/update-all.sh" > /dev/null 2>&1 &
echo "🔄 Auto-update started in background"
EOF
chmod +x ~/.claude/.git/hooks/pre-push
```

### Files Created

- `~/.claude/scripts/update.log` - Log of all update operations
- `~/.claude/scripts/update.lock` - Prevents concurrent runs
- `~/.claude/scripts/.last-heavy-update` - Timestamp for throttling

### Viewing Logs

```bash
# Recent updates
tail -50 ~/.claude/scripts/update.log

# Live monitoring
tail -f ~/.claude/scripts/update.log
```

### Manual Trigger

```bash
~/.claude/scripts/update-all.sh
```

---

## Web Session Initialization

**`web-init.sh`** - Initialize Claude Code web environments (ephemeral VMs).

See [WEB_INIT_USAGE.md](WEB_INIT_USAGE.md) for detailed setup instructions.

**Quick start:**

1. Set environment variable:
```
WEBINIT=curl -fsSL https://raw.githubusercontent.com/YOUR_USER/YOUR_REPO/main/scripts/web-init.sh | bash
```

2. Start sessions with:
```
$WEBINIT

Then [your task]
```

**What it does:**
- Installs tools in ephemeral VM
- Sets up environment variables
- Shows ready work from issue tracker
- Takes ~5-10 seconds

### Related Files

- `web-init-inline.sh` - One-liner version for network-restricted environments
- `WEBINIT_ONE_LINER.txt` - Copy-paste ready version

---

## Customization Guide

These scripts are **templates**. You'll need to customize:

### update-all.sh

**Add your plugin marketplaces:**
```bash
if claude plugin marketplace update your-marketplace >> "$LOG_FILE" 2>&1; then
    log "✓ your-marketplace updated"
fi
```

**Add your MCP servers:**
```bash
if [ -d "$HOME/Repos/your-mcp-server" ]; then
    if uv sync --directory "$HOME/Repos/your-mcp-server" >> "$LOG_FILE" 2>&1; then
        log "✓ your-mcp-server dependencies synced"
    fi
fi
```

**Add your shared repos:**
```bash
if [ -d "$HOME/work/team-tooling" ]; then
    cd "$HOME/work/team-tooling"
    git pull origin main >> "$LOG_FILE" 2>&1
    log "✓ team-tooling updated"
fi
```

### setup-new-machine.sh

**Add your MCP registrations:**
```bash
if [ -d ~/Repos/your-mcp-server ]; then
    claude mcp add your-server -- uv --directory ~/Repos/your-mcp-server run python -m your_server
    echo "   ✓ your-server MCP registered"
fi
```

### web-init.sh

**Add your tools:**
```bash
# Install project-specific tools
npm install -g your-cli-tool
```

---

## Philosophy

**Trust the operator.** These scripts assume you know what you're doing. They don't ask for confirmation before updating tools - that's the whole point.

**Automate the boring stuff.** Tool updates, dependency syncing, config backups - these should happen without thought.

**Fail gracefully.** Missing tools or paths are logged, not fatal. Partial success is better than complete failure.

**Observable.** Everything logs with timestamps. You can always see what happened and when.
