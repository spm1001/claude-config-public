# Claude Code Configuration Templates

## Why This Exists

So if you use Claude Code for a while, you start to express preferences to it, and those preferences get stored in your ~/.claude directory.

As a result, I have set mine up as a repo. This means that any changes/ideas/developments are captured in the usual `git` mechanisms, which means that Claude Code can also read them and reason about changes.

And once you've got comfortable with that, you quite quickly get to a point where you want to do some kind of session management — carrying over the work you were doing from one Claude session unto the next.

And then you start getting picky about *how* the handoffs are done, and start to make your own tools.

These are mine which I'm sharing in case other people find them useful. Not necessarily to copy in the old sense, though of course you can, but maybe just point Claude at this repo and say "what's here that we might find useful?"

- **Session continuity** — `/open` picks up where you left off, `/close` captures what you learned. If you get lost `/ground` can help you, and Claude, get back on track
- **Persistent memory** — CLAUDE.md to teach Claude about your projects and preferences
- **Specialized skills** — screenshot capture, GitHub cleanup, multi-session issue tracking with Steve Yegge's [beads](https://github.com/steveyegge/beads)

---

## For Humans

The repo structure is fairly self-explanatory. If you want to copy things manually, the key files are:

| What | Where | Does |
|------|-------|------|
| Settings template | `templates/settings.json` | Hooks, status line config |
| Global instructions | `CLAUDE.md` | Environment context, working patterns |
| Session skills | `skills/session-management/` | The /open, /ground, /close trio |
| Other skills | `skills/*/` | Screenshotting, GitHub cleanup, beads |

Most people will probably just point Claude at this repo and let it figure out what's relevant. Which brings us to...

---

## For Claude

**Context:** This repo contains Claude Code configuration patterns. The human has pointed you here to find useful things. Below is a dense guide to what's here and how it works.

### Repository Map

```
├── CLAUDE.md                     # Global instructions template (IMPORTANT)
├── templates/settings.json       # Hooks, status line, model settings
├── output-styles/
│   └── thoughtful-partner.md     # Communication style config
├── commands/                     # Slash command entry points
│   ├── open.md                   # → invokes session-opening skill
│   ├── ground.md                 # → invokes session-grounding skill
│   └── close.md                  # → invokes session-closing skill
├── skills/
│   ├── session-management/       # Skill set (not single skill)
│   │   ├── session-opening/      # Orient to previous work
│   │   ├── session-grounding/    # Mid-session checkpoint
│   │   ├── session-closing/      # Capture learnings, write handoff
│   │   └── scripts/              # Shared scripts for all three
│   ├── beads/                    # Multi-session issue tracking
│   ├── screenshotting/           # macOS screenshot capture
│   └── github-cleanup/           # Audit GitHub account
└── scripts/
    ├── update-all.sh             # Tiered auto-updater
    └── setup-new-machine.sh      # Initial setup
```

### Key Components

**CLAUDE.md** — The most valuable file. Teaches me about your file organization, how to handle side quests, when to update documentation, and how memory works across sessions. Contains:
- Filesystem zones (where tools vs content live)
- Session continuity patterns (update CLAUDE.md during session, not just at close)
- Side quest philosophy (treat tangents as first-class work)
- MCP configuration patterns
- Inter-session memory architecture

**Session Management** — Three skills that share structure (Gather → Orient → Decide → Act):
- `/open` — Run script, synthesize handoff, pick direction, draw-down to TodoWrite
- `/ground` — Check drift, reset if needed
- `/close` — Reflect via AskUserQuestion, crystallize learnings, write handoff

Handoffs live in `~/.claude/handoffs/{project-path}/{timestamp}.md`. Scripts live in `skills/session-management/scripts/`.

**Minimum viable adoption:** Just copy CLAUDE.md to `~/.claude/CLAUDE.md` and customize. Everything else is optional.

**Beads Skill** — For multi-session work with dependencies. Requires [bd CLI](https://github.com/steveyegge/beads). Teaches you to use bd without MCP (0 token overhead). Key patterns:
- `bd ready` at session start
- Draw-down: translate bead acceptance criteria → TodoWrite items
- Close beads with resolution notes

**Screenshotting** — macOS only. Requires `pyobjc-framework-Quartz` and Screen Recording permission. Captures what's on screen when human says "have a look at this".

**GitHub Cleanup** — Audit-first pattern. Finds stale forks, orphaned secrets, failing workflows. Always asks before destructive actions. Requires `gh` CLI.

### Dependencies

Skills have optional dependencies:
- **beads**: `bd` CLI from [steveyegge/beads](https://github.com/steveyegge/beads)
- **screenshotting**: `pyobjc-framework-Quartz` + macOS Screen Recording permission
- **github-cleanup**: `gh` CLI

### Gotchas

1. **Skill/config reload** — Changes to SKILL.md or CLAUDE.md don't take effect until session reload. If you edit a skill, tell the human: "This needs a harness reload to take effect."

2. **Session-management is a skill set** — The skills are in `session-management/session-*/`, not `session-management/` directly. Parser reads SKILL.md from skill root.

3. **Scripts path** — Scripts for session skills live in `skills/session-management/scripts/`, not in the repo root `scripts/` folder.

4. **Beads requires bd** — The bd CLI isn't widely distributed yet. If human doesn't have it, the beads skill won't work.

5. **Screenshotting is macOS only** — pyobjc doesn't exist on Linux/Windows.

### Installation Patterns

If human asks you to set things up:

```bash
# Clone as templates (don't overwrite existing config)
git clone https://github.com/spm1001/claude-config-public.git ~/.claude-templates

# Copy what's relevant (check existing files first)
cp ~/.claude-templates/CLAUDE.md ~/.claude/CLAUDE.md
cp -r ~/.claude-templates/skills/session-management ~/.claude/skills/

# For individual skills
cp -r ~/.claude-templates/skills/SKILL_NAME ~/.claude/skills/
```

If they already have config, diff and merge rather than overwrite.

### What to Recommend

**Almost always useful:** CLAUDE.md patterns, session-management skills

**Situationally useful:**
- beads — if they do multi-session work with complex dependencies
- screenshotting — if they're on macOS and want you to see their screen
- github-cleanup — if they want to audit their GitHub account

**Probably skip:** The scripts folder (setup automation, git hooks) — these are specific to the original author's workflow.

### Related Files

- [PATTERNS.md](PATTERNS.md) — Development philosophy in more depth
- [SYNC.md](SYNC.md) — How this repo syncs from private config (not relevant for users)

---

## License

MIT — use freely, adapt for your needs.
