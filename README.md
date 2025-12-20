# Claude Code Configuration Templates

Production-tested patterns for Claude Code: permissions, hooks, skills, and workflows. Pick what you need.

## Quick Start

**Minimal (5 minutes):** Just the settings template
```bash
git clone https://github.com/spm1001/claude-config-public.git ~/.claude-templates
cp ~/.claude-templates/templates/settings.json ~/.claude/settings.json
# Edit settings.json to add your paths and tools
```

**Recommended:** Settings + CLAUDE.md + core skills
```bash
# After minimal setup:
cp ~/.claude-templates/CLAUDE.md ~/.claude/CLAUDE.md
cp -r ~/.claude-templates/skills/crash-recovery ~/.claude/skills/
cp -r ~/.claude-templates/skills/session-closedown ~/.claude/skills/
```

**Full setup:** Everything including automation
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
- **Filesystem organization** - Separating tools, config, and content
- **MCP configuration** - Patterns for server management
- **Session memory** - Using CLAUDE.md as crash-resistant context
- **Background agents** - Staying responsive while agents run
- **Agent-era thinking** - Designing for human/machine × self/other matrix

This is a template. Adapt to your environment and preferences.

### Skills (Standalone Value)

Each skill works independently. Pick what fits your workflow.

| Skill | Purpose | Dependencies |
|-------|---------|--------------|
| **crash-recovery** | Reconstruct session context after crashes | None |
| **session-closedown** | End-of-session ritual: git tidy, push, learnings | Git |
| **svg-dataviz** | Create SVG charts/diagrams with render-and-iterate workflow | `rsvg-convert` or `sips` |
| **looking** | Screenshot capture for "have a look" requests | macOS only (pyobjc) |
| **bd-issue-tracking** | Multi-session work with dependency graphs | [beads](https://github.com/steveyegge/beads) |
| **skill-quality-gate** | Validation checklist before creating new skills | None |

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
cp -r ~/.claude-templates/skills/crash-recovery ~/.claude/skills/
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
├── scripts/
│   ├── README.md
│   ├── update-all.sh
│   ├── setup-new-machine.sh
│   └── web-init.sh
└── skills/
    ├── crash-recovery/
    ├── session-closedown/
    ├── svg-dataviz/
    ├── looking/
    ├── bd-issue-tracking/
    └── skill-quality-gate/
```

---

## Related

- [Claude Code Documentation](https://docs.anthropic.com/claude-code)
- [beads](https://github.com/steveyegge/beads) - Issue tracker for AI collaboration
- [Model Context Protocol](https://modelcontextprotocol.io/) - MCP specification

## License

MIT - Use freely, adapt for your needs.
