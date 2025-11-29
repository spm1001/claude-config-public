---
name: session-closedown
description: End-of-session ritual for tidying artifacts, committing work, and extracting learnings for CLAUDE.md. Invoke when wrapping up a session, especially after significant work or discoveries.
---

# Session Closedown

End-of-session ritual that ensures work is saved, pushed, and learnings are captured.

## When to Use This Skill

**Use when:**
- User says "let's wrap up" or "end of session"
- Significant work completed that should be committed
- Discoveries or patterns learned that should persist
- Before context gets too full and compaction happens

**NOT for:**
- Quick questions or small tasks
- Mid-session checkpoints (just commit normally)

## The Closedown Ritual

### Phase 1: Git Tidy

Check working directories for uncommitted changes:

```bash
# Check common development directories
for dir in ~/.claude ~/Projects/*; do
  [ -d "$dir/.git" ] && git -C "$dir" status --porcelain | grep -q . && echo "📁 $dir"
done
```

For each repo with changes:
1. Review what changed (`git diff --stat`)
2. Stage appropriate files
3. Write clear commit message
4. Commit

### Phase 2: Push

Push repos ahead of remote:

```bash
for dir in ~/.claude ~/Projects/*; do
  [ -d "$dir/.git" ] && [ "$(git -C "$dir" rev-list --count @{u}..HEAD 2>/dev/null)" -gt 0 ] && echo "📤 $dir"
done
```

### Phase 3: Session Reflection

Ask these questions:

**Patterns Discovered:**
- Better way to do something?
- Tool behaved unexpectedly?
- Learned something about codebase/domain?

**Process Improvements:**
- Something took longer than it should?
- Friction that could be reduced?
- Workflow that worked well?

**Configuration Insights:**
- Permissions to add/change?
- Paths or tools to document?

### Phase 4: CLAUDE.md Updates

If reflection yields learnings:

1. **Which file:**
   - Global (~/.claude/CLAUDE.md) - Cross-project
   - Project CLAUDE.md - Project-specific

2. **Draft addition** (2-5 lines, appropriate section)

3. **Present to user** for approval

4. **If approved:**
   ```bash
   git -C ~/.claude add CLAUDE.md
   git -C ~/.claude commit -m "Add learning: [description]"
   git -C ~/.claude push
   ```

## Output Format

```
## Session Closedown Summary

**Commits:** repo1: "message", repo2: "message"
**Pushed:** repo1, repo2
**Learnings:** [description] or "None this session"
**Complete** ✓
```

## Integration with Issue Tracker (bd)

If `.beads/` exists in working directory, include issue tidy-up:

### Check Current State
```bash
bd list --status in_progress --json | jq -r '.[] | "\(.id): \(.title)"'
bd list --status open --json | jq -r '.[] | "\(.id): \(.title)"'
```

### Close Completed Issues
For each issue completed this session:
```bash
bd update <id> --status closed --notes "Completed: [what was done]"
```

### Update In-Progress Issues
For work that will continue next session, capture RICH context:

```bash
bd update <id> --notes "$(cat <<'EOF'
SESSION: [date]

COMPLETED: [what got done]

KEY DISCOVERIES:
- [technical insight or constraint found]
- [behavior that surprised us]

DESIGN DISCUSSIONS:
- Discussed [topic]: decided [choice] because [reasoning]
- Considered [alternatives], rejected because [why]

CURRENT STATE: [where things stand]

NEXT SESSION: [what to pick up]
EOF
)"
```

**Critical:** Write notes as if explaining to a future instance with ZERO conversation context.
The notes field is your only persistent memory across sessions.

### Check Dependencies
Review if completed work unblocks other issues:
```bash
bd ready --json  # See what's now unblocked
```

### Create New Issues
If session revealed new work items:
```bash
bd create "New task discovered" --type task --design "Context from this session"
```

### Add Session Learnings to Issues
If insights apply to specific issues:
```bash
bd update <id> --notes "Learning: [insight that affects this work]"
```
