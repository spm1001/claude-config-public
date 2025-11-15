# Claude Code Configuration Templates

**Production-tested patterns for Claude Code setup** - permissions, auto-updates, skills, and workflow practices that reduce friction and increase reliability.

## Why This Exists

Claude Code requires configuration to work smoothly. Without it, you'll face:
- **Permission prompts** on every bash command (frustrating)
- **Manual tool updates** that fall behind (error-prone)
- **Repeated setup** on new machines (tedious)
- **Lost context** across sessions (inefficient)

This repo provides battle-tested templates that solve these problems.

---

## Quick Start

### Local Setup (New Machine)

1. **Clone and customize:**
```bash
git clone https://github.com/spm1001/claude-config-public.git ~/.claude-templates
cd ~/.claude-templates
```

2. **Copy settings template:**
```bash
# Review and customize for your environment
cp templates/settings.json ~/.claude/settings.json
```

3. **Setup auto-updates (optional):**
```bash
# Copy and customize update script
cp scripts/update-all.sh ~/.claude/scripts/
# See scripts/README.md for git hook setup
```

### Web Sessions

For Claude Code web environments (ephemeral VMs):

```
$WEBINIT

Then [your actual task]
```

**Environment variable setup:** See [scripts/WEB_INIT_USAGE.md](scripts/WEB_INIT_USAGE.md)

---

## What's Included

### Templates (`templates/`)

**`settings.json`** - Comprehensive permission template
- 100+ common CLI commands pre-approved (git, npm, brew, curl, etc.)
- Eliminates "approve this command?" prompts
- Safe defaults - no destructive operations without review
- Copy and customize for your machine

**`settings.local.json.example`** - Machine-specific settings template
- WebFetch domain allowlists
- Read permissions for your directories
- Additional directory access
- NOT tracked in git (contains paths)

### Scripts (`scripts/`)

**`update-all.sh`** - Tiered auto-updater
- **Quick tier** (every trigger, <10s): Submodules, plugins, cleanup
- **Heavy tier** (once per day): Homebrew, npm, Claude CLI
- Prevents redundant expensive operations
- Runs via git hooks (post-merge, pre-push)

**`setup-new-machine.sh`** - Initial setup automation
- Registers MCP servers
- Generates settings.local.json
- Auto-detects environment (e.g., Google Drive path)

**`web-init.sh`** - Web session initialization
- Installs tools in ephemeral VM
- Sets up environment variables
- Shows ready work from issue tracker

### Skills (`skills/`)

**`bd-issue-tracking/`** - Issue tracking with beads
- When to use bd vs TodoWrite
- CLI bootstrap patterns
- Session handoff workflows
- Dependency management

### Documentation

**`PATTERNS.md`** - Development philosophy and practices
- Side quests as first-class work
- Security-first mindset
- Code quality standards
- Session management patterns

---

## Customization Guide

These are **templates, not drop-in configs**. You'll need to customize:

1. **Paths** - Replace example paths with your actual directories
2. **MCP servers** - Add your server registrations
3. **Domains** - Add WebFetch domains you trust
4. **Tools** - Add commands specific to your stack

### Example Customizations

**Python developer:**
```json
{
  "allow": [
    "Bash(python:*)",
    "Bash(pip:*)",
    "Bash(poetry:*)",
    "Bash(pytest:*)"
  ]
}
```

**Rust developer:**
```json
{
  "allow": [
    "Bash(cargo:*)",
    "Bash(rustc:*)",
    "Bash(rustup:*)"
  ]
}
```

**Team with shared repos:**
```bash
# In update-all.sh, add your repos
if [ -d "$HOME/work/shared-tooling" ]; then
    cd "$HOME/work/shared-tooling"
    git pull origin main
fi
```

---

## Philosophy

**Trust the operator.** If you're running Claude Code, you've already authorized it. Constant permission prompts add friction without meaningful security benefit. The templates pre-approve safe operations while maintaining oversight for destructive ones.

**Automate the boring stuff.** Tool updates, dependency syncing, config backups - these should happen automatically. The tiered update system ensures freshness without wasting time.

**Portable patterns over rigid configs.** These templates work across machines and teams because they're parameterized. Personal paths stay in `.local` files that aren't tracked.

For deeper philosophy (side quests, security practices, quality standards), see [PATTERNS.md](PATTERNS.md).

---

## Repository Structure

```
├── README.md                 # You are here
├── PATTERNS.md              # Development philosophy
├── templates/
│   ├── settings.json        # Base permissions template
│   └── settings.local.json.example  # Machine-specific template
├── scripts/
│   ├── README.md            # Script documentation
│   ├── update-all.sh        # Tiered auto-updater
│   ├── setup-new-machine.sh # Initial setup
│   ├── web-init.sh          # Web session init
│   └── ...                  # Supporting files
└── skills/
    └── bd-issue-tracking/   # Issue tracking skill
```

---

## Related

- [Claude Code Documentation](https://docs.anthropic.com/claude-code)
- [beads](https://github.com/steveyegge/beads) - Issue tracker for AI collaboration
- [Model Context Protocol](https://modelcontextprotocol.io/) - MCP specification

## License

MIT - Use freely, customize for your needs.
