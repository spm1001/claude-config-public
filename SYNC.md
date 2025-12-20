# Sync Documentation

This document describes how this public repo is kept in sync with the private upstream (`~/.claude`).

## Relationship

```
~/.claude (private)                    claude-config-public (this repo)
├── CLAUDE.md ───────────────────────► CLAUDE.md (generalized)
├── settings.json ───────────────────► templates/settings.json (templated)
├── output-styles/ ──────────────────► output-styles/ (minor edits)
├── scripts/ ────────────────────────► scripts/ (templated)
└── skills/
    ├── crash-recovery/ ─────────────► skills/crash-recovery/
    ├── session-closedown/ ──────────► skills/session-closedown/
    ├── svg-dataviz/ ────────────────► skills/svg-dataviz/
    ├── looking/ ────────────────────► skills/looking/
    ├── bd-issue-tracking/ ──────────► skills/bd-issue-tracking/
    ├── skill-quality-gate/ ─────────► skills/skill-quality-gate/
    │
    ├── working-with-sameer/ ────────✗ (personal exoskeleton)
    ├── core-fluency/ ───────────────✗ (domain-specific)
    ├── itv-brand/ ──────────────────✗ (company-specific)
    ├── todoist-strategy/ ───────────✗ (personal workflow)
    ├── desired-outcomes/ ───────────✗ (team-specific)
    └── workspace-fluency/ ──────────✗ (needs workspace MCP)
```

## What Stays Private

### Skills (Never Sync)
- `working-with-sameer/` - Personal exoskeleton with cognitive patterns
- `core-fluency/` - ITV/MIT domain terminology resolution
- `itv-brand/` - Company-specific branding
- `todoist-strategy/` - Personal GTD layer
- `desired-outcomes/` - Team outcome coaching

### CLAUDE.md Sections (Never Sync)
- "MIT Strategic Planning System" - Team-specific workflow
- "CORE Domain Context System" - Domain-specific shards
- Personal MCP server configurations with specific paths
- Personal symlink paths and email addresses

### Output Style Elements (Never Sync)
- "Distillation Signals" section (personal signal phrases)
- Personal calibration references

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

### 2. Check skills/ for new shareable skills
```bash
# List skills in upstream not in public
comm -23 \
  <(ls ~/.claude/skills/ | grep -v '^[.]' | sort) \
  <(ls ~/Repos/claude-config-public/skills/ | sort)
```

For each candidate skill, ask:
- Does it require personal/company context?
- Does it depend on specific MCP servers?
- Would it work for someone with a different setup?

### 3. Check scripts/ for updates
```bash
diff ~/.claude/scripts/update-all.sh ~/Repos/claude-config-public/scripts/update-all.sh
```

Sync new features as templated/optional sections.

### 4. Check settings.json for new permissions
```bash
diff ~/.claude/settings.json ~/Repos/claude-config-public/templates/settings.json
```

Note: The public version intentionally has more granular permissions (130+ specific commands) vs upstream's blanket "Bash" permission.

### 5. Update README if new components added

Add new skills to the skills table, update structure diagram.

## Generalization Patterns

When syncing content, apply these transformations:

| Private | Public |
|---------|--------|
| `~/Google Drive/Work/` | `~/Documents/Work/` or cloud storage |
| Specific email addresses | Generic placeholders |
| `itv-brand` references | "if a brand skill exists" |
| Personal MCP servers | "CUSTOMIZE: Add your servers" |
| Specific repo paths | `$HOME/Repos/your-project` |

## After Syncing

1. **Review all changes** - Ensure no private content leaked
2. **Test skills** - Ensure they work without upstream dependencies
3. **Update this file** - If sync process changed
4. **Commit with descriptive message** - "Sync: add X skill, update Y section"

## Future Automation Ideas

- Script to detect new upstream skills
- Diff tool that highlights private content
- Template engine for CLAUDE.md sections
- Automated skill dependency checker
