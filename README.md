# Claude Code Configuration Templates

Production-tested patterns for Claude Code: permissions, hooks, skills, and workflows. Pick what you need.

## Why This Exists

Out of the box, Claude Code asks permission for *everything*. Every file read, every shell command, every web search — click, click, click. It forgets what you were working on between sessions. It doesn't know your preferences.

This repo fixes that. After setup:
- **No more permission prompts** for routine operations
- **Session continuity** — `/open` picks up where you left off, `/close` captures what you learned
- **Persistent memory** — CLAUDE.md files teach Claude about your projects and preferences
- **Specialized skills** — screenshot capture, GitHub cleanup, multi-session issue tracking

It's the difference between a helpful stranger and a capable collaborator who knows your codebase.

## Quick Start

**Minimal (5 minutes):** Just the settings template
```bash
git clone https://github.com/spm1001/claude-config-public.git ~/.claude-templates
cp ~/.claude-templates/templates/settings.json ~/.claude/settings.json
# Edit settings.json to add your paths and tools
```

**Recommended:** Settings + CLAUDE.md + session skills
```bash
# After minimal setup:
cp ~/.claude-templates/CLAUDE.md ~/.claude/CLAUDE.md
cp -r ~/.claude-templates/skills/session-management ~/.claude/skills/
```

**Full setup:** Everything including all skills and automation
```bash
# After recommended setup:
cp -r ~/.claude-templates/skills/* ~/.claude/skills/
cp -r ~/.claude-templates/output-styles ~/.claude/
cp -r ~/.claude-templates/scripts ~/.claude/
# Configure git hooks per scripts/README.md
```

---

## Components

### Core Settings (`templates/settings.json`)

Blanket permissions for standard operations. The philosophy: if you're running Claude Code, you've authorized it.

**Includes:**
- `Bash` - All shell commands (blanket permission)
- `Write(*)`, `Edit(*)`, `Read(*)` - All file operations
- `WebSearch`, `WebFetch` - Web access
- Hooks: startup notification, end-of-session reminder, WebFetch warning
- Status line showing model, output style, and working directory

**Customize:** Add your `additionalDirectories` and MCP tool permissions.

### Global Instructions (`CLAUDE.md`)

Example global instructions covering:
- **Development philosophy** - Side quests as first-class work, foundations over speed
- **Skill and command architecture** - How to structure skills with reload patterns
- **Filesystem organization** - Separating tools, config, and content
- **MCP configuration** - Patterns for server management, authentication
- **Session memory** - Using CLAUDE.md and handoffs as crash-resistant context
- **Background agents** - Staying responsive while agents run
- **Inter-session continuity** - The layered memory architecture

This is a template. Adapt to your environment and preferences.

### Skills

Each skill works independently. Pick what fits your workflow.

| Skill | Purpose | Dependencies |
|-------|---------|--------------|
| **session-management** | Open/ground/close rituals for session continuity | Scripts included, bd optional |
| **beads** | Multi-session work with dependency graphs | [bd CLI](https://github.com/steveyegge/beads) |
| **screenshotting** | Screenshot capture for "have a look" requests | macOS only (pyobjc) |
| **github-cleanup** | Audit and clean GitHub account | `gh` CLI |

#### Session Management (3 skills)

The `/open`, `/ground`, `/close` trio creates session-to-session continuity:

- **session-opening** — Orient to previous work, pick direction
- **session-grounding** — Mid-session checkpoint when things feel off
- **session-closing** — Reflect, capture learnings, write handoff

They share a common structure (Gather → Orient → Decide → Act) and work together through handoff files.

#### Beads Issue Tracking

For multi-session work with complex dependencies. Requires the `bd` CLI from [beads](https://github.com/steveyegge/beads).

- Tracks work across sessions that outlast context
- Dependency graphs for understanding blockers
- Portfolio view across all your projects

#### Screenshotting

macOS screenshot capture that lets Claude see what's on screen.

```bash
# Requires
pip install pyobjc-framework-Quartz
# Also requires Screen Recording permission
```

#### GitHub Cleanup

Audit-first pattern for GitHub housekeeping:
- Find stale forks with no custom changes
- Detect orphaned secrets
- Identify failing workflows
- Always asks before destructive actions

**To install a skill:**
```bash
cp -r ~/.claude-templates/skills/SKILL_NAME ~/.claude/skills/
```

### Output Style (`output-styles/thoughtful-partner.md`)

Communication style configuration:
- When to explain vs just do
- Tone guidance (direct, no apologies, confident)
- Proactiveness policies
- Work quality standards

**To use:**
```bash
mkdir -p ~/.claude/output-styles
cp ~/.claude-templates/output-styles/thoughtful-partner.md ~/.claude/output-styles/
# Then set in settings.json: "outputStyle": "thoughtful-partner"
```

### Scripts (`scripts/`)

| Script | Purpose |
|--------|---------|
| `update-all.sh` | Tiered auto-updater: quick (<10s) + heavy (daily) |
| `setup-new-machine.sh` | Initial Claude Code setup |
| `web-init.sh` | Web session initialization |

See `scripts/README.md` for git hook integration.

---

## Adoption Guide

### Merging with Existing Config

If you already have `~/.claude/settings.json`:

1. **Compare permissions:**
   ```bash
   diff ~/.claude/settings.json ~/.claude-templates/templates/settings.json
   ```

2. **Merge what you need** - The template's `allow` array can be merged with yours

3. **Don't overwrite** - Keep your existing paths, MCP servers, and customizations

### Adding Skills to Existing Setup

Skills are additive. Just copy the folder:
```bash
cp -r ~/.claude-templates/skills/session-management ~/.claude/skills/
```

### Updating from Upstream

This repo is occasionally updated. To get new versions:
```bash
cd ~/.claude-templates
git pull origin main
# Then manually diff and merge what you want
```

---

## Philosophy

**Trust the operator.** If you're running Claude Code, you've authorized it. Constant permission prompts add friction without security benefit.

**Side quests are work.** Exploratory tangents and foundation-fixing are valuable. The configuration reflects this.

**Pick what you need.** This is a buffet, not a set menu. Take the patterns that help, ignore the rest.

For deeper philosophy, see [PATTERNS.md](PATTERNS.md) and [CLAUDE.md](CLAUDE.md).

---

## Repository Structure

```
├── README.md                     # This file
├── CLAUDE.md                     # Example global instructions
├── PATTERNS.md                   # Development philosophy
├── SYNC.md                       # Upstream sync documentation
├── templates/
│   ├── settings.json             # Permissions + hooks
│   └── settings.local.json.example
├── output-styles/
│   └── thoughtful-partner.md
├── commands/                     # Slash commands (/open, /ground, /close)
│   ├── open.md
│   ├── ground.md
│   └── close.md
├── scripts/
│   ├── README.md
│   ├── update-all.sh
│   ├── setup-new-machine.sh
│   └── web-init.sh
└── skills/
    ├── session-management/       # Open/ground/close trio
    │   ├── session-opening/
    │   ├── session-grounding/
    │   ├── session-closing/
    │   └── scripts/
    ├── beads/                    # Issue tracking with dependencies
    ├── screenshotting/           # macOS screenshot capture
    └── github-cleanup/           # GitHub account maintenance
```

---

## Related

- [Claude Code Documentation](https://docs.anthropic.com/claude-code)
- [beads](https://github.com/steveyegge/beads) - Issue tracker for AI collaboration
- [Model Context Protocol](https://modelcontextprotocol.io/) - MCP specification

## License

MIT - Use freely, adapt for your needs.
