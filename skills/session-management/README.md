# Session Management Skills

A cohesive trio of skills for managing Claude Code session lifecycle: opening, grounding (mid-session), and closing.

## The Three Skills

| Skill | Trigger | Purpose |
|-------|---------|---------|
| **session-opening** | `/open`, "where did we leave off" | Orient to previous work, pick direction |
| **session-grounding** | `/ground`, "where are we" | Mid-session checkpoint, catch drift |
| **session-closing** | `/close`, "wrap up" | Reflect, capture learnings, commit |

## Shared Structure

All three follow the same pattern:

```
Gather  → Collect current state
Orient  → Synthesize what matters
Decide  → User picks direction
Act     → Execute on decision
```

## Installation

### Option 1: Copy to ~/.claude/skills/

```bash
# Copy the whole skill set
cp -r session-management ~/.claude/skills/

# Or create symlinks (if cloning this repo)
ln -s /path/to/claude-config-public/skills/session-management/session-opening ~/.claude/skills/
ln -s /path/to/claude-config-public/skills/session-management/session-grounding ~/.claude/skills/
ln -s /path/to/claude-config-public/skills/session-management/session-closing ~/.claude/skills/
```

### Option 2: Install scripts globally

Copy scripts to a central location for all skills to use:

```bash
cp scripts/*.sh ~/.claude/scripts/
chmod +x ~/.claude/scripts/*.sh
```

## Dependencies

### Required
- Git (for status checks)
- Bash

### Optional (graceful degradation)
- **bd (beads)** — Issue tracking. Skills work without it but lose bead-related features.
- **Handoff archive** — `~/.claude/handoffs/` structure. Skills work without but lose session continuity.

## Customization

### Handoff Location

The default handoff archive location is `~/.claude/handoffs/{encoded-path}/`. Modify `open-context.sh` if you prefer a different structure.

### Task Management Integration

The context detection section in `open-context.sh` is a placeholder. Customize for your task management (Todoist, Linear, etc.):

```bash
# Example: Add Todoist integration
if [ "$CONTEXT" = "work" ]; then
    echo "TODOIST_PROJECT_ID=your-project-id"
fi
```

## How They Work Together

```
/open          →  Start of session
                  Read handoff, orient, pick direction

[work happens]

/ground        →  Mid-session (optional)
                  Check drift, reset todos

[more work]

/close         →  End of session
                  Reflect, write handoff, commit
```

The handoff written by `/close` is read by the next `/open`, creating session-to-session continuity.

## Mirrors Table

Each skill has a "Mirrors" table showing how phases map across all three:

| Phase | /open | /ground | /close |
|-------|-------|---------|--------|
| Gather | Handoff, beads, script | Todos, beads, drift | Todos, beads, git, drift |
| Orient | "Where we left off" | "What's drifted" | Reflect (AskUserQuestion) |
| Decide | User picks direction | Continue or adjust | Crystallize actions (STOP) |
| Act | Draw-down → TodoWrite | Update beads, reset | Execute, handoff, commit |
