# Claude Code Configuration Templates

**Production-tested patterns for Claude Code setup** - permissions, hooks, skills, output styles, and workflow practices that reduce friction and increase reliability.

## Why This Exists

Claude Code requires configuration to work smoothly. Without it, you'll face:
- **Permission prompts** on every bash command (frustrating)
- **No session continuity** across crashes (lost work)
- **Manual tool updates** that fall behind (error-prone)
- **Repeated setup** on new machines (tedious)

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

3. **Copy output style (optional):**
```bash
mkdir -p ~/.claude/output-styles
cp output-styles/thoughtful-partner.md ~/.claude/output-styles/
```

4. **Copy skills you want:**
```bash
cp -r skills/crash-recovery ~/.claude/skills/
cp -r skills/session-closedown ~/.claude/skills/
cp -r skills/skill-quality-gate ~/.claude/skills/
cp -r skills/bd-issue-tracking ~/.claude/skills/
```

5. **Setup auto-updates (optional):**
```bash
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

### Core Configuration

**`CLAUDE.md`** - Example global instructions
- Two Claude configurations (Code vs Desktop)
- Development philosophy (side quests, foundations over speed)
- Filesystem zones organization
- MCP server configuration patterns
- Issue tracking philosophy
- Security practices
- Python environment with uv
- Crash recovery protocol

**`PATTERNS.md`** - Development philosophy and practices
- Side quests as first-class work
- Security-first mindset
- Code quality standards
- Session management patterns

### Templates (`templates/`)

**`settings.json`** - Comprehensive permission and hooks template
- 130+ common CLI commands pre-approved
- Session hooks (start, end, WebFetch reminder)
- Status line configuration
- Output style setting
- Thinking mode enabled

**`settings.local.json.example`** - Machine-specific settings template
- WebFetch domain allowlists
- Read permissions for your directories
- Additional directory access

### Output Styles (`output-styles/`)

**`thoughtful-partner.md`** - Collaborative communication style
- When to explain vs just do
- Tone guidance (direct, no apologies)
- Proactiveness policies
- Work quality standards

### Skills (`skills/`)

**`bd-issue-tracking/`** - Issue tracking with beads
- When to use bd vs TodoWrite
- CLI and MCP patterns
- Session handoff workflows
- Dependency management
- Comprehensive reference docs

**`crash-recovery/`** - Session recovery after crashes
- Git state assessment
- Issue tracker integration
- Context reconstruction
- Quality checklist

**`session-closedown/`** - End-of-session ritual
- Git tidy and push
- Session reflection
- CLAUDE.md updates
- Issue tracker updates

**`skill-quality-gate/`** - Skill creation validation
- Naming conventions
- Description requirements
- Quality checklist
- Anti-patterns to avoid

### Scripts (`scripts/`)

**`update-all.sh`** - Tiered auto-updater
- Quick tier (every trigger): Submodules, plugins, cleanup
- Heavy tier (daily): Homebrew, npm, Claude CLI

**`setup-new-machine.sh`** - Initial setup automation

**`web-init.sh`** - Web session initialization

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

---

## Philosophy

**Trust the operator.** If you're running Claude Code, you've already authorized it. Constant permission prompts add friction without meaningful security benefit. The templates pre-approve safe operations while maintaining oversight for destructive ones.

**Side quests are work.** Exploratory tangents and foundation-fixing are valuable, not distractions. The configuration reflects this philosophy.

**Automate the boring stuff.** Tool updates, config backups, session handoffs - these should happen automatically or with minimal friction.

**Portable patterns over rigid configs.** Templates work across machines because they're parameterized. Personal paths stay in `.local` files that aren't tracked.

For deeper philosophy, see [PATTERNS.md](PATTERNS.md) and [CLAUDE.md](CLAUDE.md).

---

## Repository Structure

```
├── README.md                     # You are here
├── CLAUDE.md                     # Example global instructions
├── PATTERNS.md                   # Development philosophy
├── templates/
│   ├── settings.json             # Permissions + hooks template
│   └── settings.local.json.example
├── output-styles/
│   └── thoughtful-partner.md     # Communication style
├── scripts/
│   ├── README.md
│   ├── update-all.sh             # Tiered auto-updater
│   ├── setup-new-machine.sh
│   ├── web-init.sh
│   └── ...
└── skills/
    ├── bd-issue-tracking/        # Issue tracking skill
    ├── crash-recovery/           # Session recovery skill
    ├── session-closedown/        # End-of-session skill
    └── skill-quality-gate/       # Skill creation validation
```

---

## Related

- [Claude Code Documentation](https://docs.anthropic.com/claude-code)
- [beads](https://github.com/steveyegge/beads) - Issue tracker for AI collaboration
- [Model Context Protocol](https://modelcontextprotocol.io/) - MCP specification

## License

MIT - Use freely, customize for your needs.
