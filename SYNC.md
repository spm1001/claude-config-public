# Sync Documentation

This document describes how this public repo is kept in sync with the private upstream (`~/.claude`).

## Relationship

```
~/.claude (private)                    claude-config-public (this repo)
├── CLAUDE.md ───────────────────────► CLAUDE.md (generalized)
├── settings.json ───────────────────► templates/settings.json (templated)
├── output-styles/ ──────────────────► output-styles/
├── scripts/ ────────────────────────► scripts/ (templated)
└── skills/
    ├── session-opening ─────────────► skills/session-management/session-opening/
    ├── session-grounding ───────────► skills/session-management/session-grounding/
    ├── session-closing ─────────────► skills/session-management/session-closing/
    ├── beads ───────────────────────► skills/beads/
    ├── screenshotting ──────────────► skills/screenshotting/
    ├── github-cleanup ──────────────► skills/github-cleanup/
    │
    ├── collaborating ───────────────✗ (personal workflow)
    ├── filing ──────────────────────✗ (personal workflow)
    ├── todoist-gtd ─────────────────✗ (personal workflow)
    ├── itv-styling ─────────────────✗ (company-specific)
    ├── google-workspace ────────────✗ (MCP-coupled)
    └── grounding ───────────────────✗ (repo-coupled)
```

## Skills Structure

Skills in this repo are **full copies**, not symlinks. The upstream uses symlinks to separate skill repos (e.g., `~/.claude/skills/beads` → `~/Repos/skill-beads`), but for the public version we bundle everything.

### Skills Included

| Skill | Type | Dependencies |
|-------|------|--------------|
| **session-management** | Skill set (3 skills) | Scripts included, bd optional |
| **beads** | Complex with references | bd CLI required |
| **screenshotting** | Utility | macOS, pyobjc-framework-Quartz |
| **github-cleanup** | Audit pattern | gh CLI required |

### Skills NOT Included

| Skill | Reason |
|-------|--------|
| `collaborating` | Personal workflow patterns |
| `filing` | Personal file organization |
| `todoist-gtd` | Personal task management |
| `itv-styling` | Company-specific branding |
| `google-workspace` | Coupled to MCP server |
| `grounding` | Coupled to claude-memory repo |
| `diagramming` | Not yet polished |
| `server-maintenance` | Too niche |

## What Stays Private

### CLAUDE.md Sections (Never Sync)
- Personal email addresses and paths
- Specific MCP server configurations with internal URLs
- "Cognitive Profile" and personal working patterns
- Company-specific workflow references

### Output Style Elements (Never Sync)
- Personal calibration references
- Company-specific communication patterns

## Sync Checklist

When syncing from upstream:

### 1. Check CLAUDE.md for new generic sections
```bash
diff ~/.claude/CLAUDE.md ~/Repos/claude-config-public/CLAUDE.md | head -100
```

Look for:
- New sections under "Development Philosophy"
- Updated guidance that applies broadly
- New patterns worth sharing

### 2. Check skills for updates
```bash
# List skills in upstream
ls ~/.claude/skills/

# Check if any included skills have updates
diff -r ~/.claude/skills/beads ~/Repos/claude-config-public/skills/beads
```

For significant skill updates, recopy and generalize.

### 3. Check scripts for updates
```bash
diff ~/.claude/scripts/ ~/Repos/claude-config-public/scripts/
```

Sync new features as templated/optional sections.

### 4. Update README if new components added

Add new skills to the skills table, update structure diagram.

## Generalization Patterns

When syncing content, apply these transformations:

| Private | Public |
|---------|--------|
| Specific email addresses | Remove or note as placeholder |
| Personal MCP servers | "CUSTOMIZE: Add your servers" |
| Specific repo paths | `~/Repos/your-project` |
| Personal Todoist IDs | Comment out with placeholder |
| ITV/company references | Remove entirely |

## After Syncing

1. **Review all changes** - Ensure no private content leaked
2. **Test skills** - Ensure they work without upstream dependencies
3. **Update this file** - If sync process changed
4. **Commit with descriptive message** - "Sync: add X skill, update Y section"
