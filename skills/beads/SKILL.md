---
name: beads
description: Tracks complex, multi-session work with dependency graphs using bd (beads) issue tracker. Triggers on 'multi-session', 'complex dependencies', 'resume after weeks', 'project memory', 'persistent context', 'side quest tracking', 'portfolio', 'all my beads', 'cross-project beads', or when TodoWrite is insufficient for scope. For simple single-session linear tasks, TodoWrite remains appropriate. (user)
---

## Reference Files Quick Index

beads has extensive reference material. To avoid reading all files:

**When you need...**
- CLI commands → `references/CLI_BOOTSTRAP_ADMIN.md`
- When to use bd vs TodoWrite → `references/BOUNDARIES.md`
- Session handoff → `references/WORKFLOWS.md` (Session Handoff section)
- Dependency semantics (A blocks B vs B blocks A) → `references/DEPENDENCIES.md`
- Troubleshooting → `references/TROUBLESHOOTING.md`
- Design context capture → `references/WORKFLOWS.md` (Design Context section)
- Resumability after compaction → `references/RESUMABILITY.md`
- **Molecules, wisps, protos** → `references/MOLECULES.md` (v0.34.0+)
- **Formulas, gates, activity** → `references/MOLECULES.md` (v0.36.0+)
- **Cross-project dependencies** → `references/MOLECULES.md` (v0.34.0+)
- **Portfolio view (all projects)** → `references/PORTFOLIO.md` + `scripts/bd-portfolio.sh`

Read SKILL.md first, then load specific references as needed.

**BEFORE running bd commands:** Check `references/CLI_BOOTSTRAP_ADMIN.md` for correct flags.

# Beads Issue Tracking

## Overview

bd is a graph-based issue tracker for persistent memory across sessions, designed for AI-supervised coding workflows. Use for multi-session work with complex dependencies; use TodoWrite for simple single-session tasks.

**Interface:** CLI via Bash tool (bd commands). All operations return JSON with `--json` flag for structured parsing.

## When to Use bd vs TodoWrite

### Use bd when:
- **Multi-session work** - Tasks spanning multiple compaction cycles or days
- **Complex dependencies** - Work with blockers, prerequisites, or hierarchical structure
- **Knowledge work** - Strategic documents, research, or tasks with fuzzy boundaries
- **Side quests** - Exploratory work that might pause the main task
- **Project memory** - Need to resume work after weeks away with full context

### Use TodoWrite when:
- **Single-session tasks** - Work that completes within current session
- **Linear execution** - Straightforward step-by-step tasks with no branching
- **Immediate context** - All information already in conversation
- **Simple tracking** - Just need a checklist to show progress

**Key insight**: If resuming work after 2 weeks would be difficult without bd, use bd. If the work can be picked up from a markdown skim, TodoWrite is sufficient.

**For detailed decision criteria and examples:** [references/BOUNDARIES.md](references/BOUNDARIES.md)

## Session Start Protocol

**bd is available when:**
- Project has a `.beads/` directory (project-local database), OR
- `~/.beads/` exists (global fallback database for any directory)

**At session start, always check for bd availability and run ready check:**

```bash
# Check recent version changes (if bd recently upgraded)
bd info --whats-new

# Find unblocked work
bd ready --json

# Check active work
bd list --status in_progress --json

# If in_progress exists, read notes for context
bd show <issue-id> --json
```

**Report format:** "I can see X items ready to work on: [summary]. Issue Y is in_progress - last session: [from notes]. Should I continue with that?"

This establishes immediate shared context about available and active work.

**For detailed session handoff workflow:** [references/WORKFLOWS.md](references/WORKFLOWS.md#session-handoff)

## Database Hygiene (Yegge Best Practices)

**Keep your database small.** Performance degrades with large issue counts (agents search issues.jsonl directly).

```bash
# Delete closed issues older than N days (default: 7)
bd cleanup --days 2     # Aggressive if moving fast
bd cleanup              # Standard 7-day cleanup

# Run periodically
bd doctor               # Check for issues
bd doctor --fix         # Auto-fix problems

# Sync after cleanup
bd sync
```

**Target sizes:**
- ⚠️ >200 issues: Consider cleanup
- 🛑 >500 issues: Performance problems likely
- Deleted issues remain in git history - always recoverable

**Upgrade regularly:** `bd upgrade` (at least weekly). Bug fixes are frequent.

## When to File Issues

**File issues liberally.** Any work taking >2 minutes deserves an issue.

- During code reviews, file issues as you find them
- Capture context immediately rather than losing it when conversation ends
- Models often file spontaneously - nudging helps

**Plan outside Beads, then import.** For larger plans:
1. Use external planning tool first (refine with model)
2. Ask agent to file detailed epics/issues with dependencies
3. Ask agent to review, proofread, refine the filed beads
4. Can iterate up to 5 times on both plan and beads

**Restart agents frequently.** One task at a time → kill process → start fresh. Beads is the working memory between sessions. Saves money, better model performance.

## Core CLI Operations

All commands support `--json` for structured output. **Note:** JSON output is always an array, even for single-item queries like `bd show`. Use these jq patterns:

```bash
# Single issue (bd show returns array with one element)
bd show issue-123 --json | jq '.[0].title'
bd show issue-123 --json | jq -r '.[] | "\(.id): \(.title)"'

# Multiple issues (bd list, bd ready)
bd list --json | jq -r '.[] | "\(.id) [\(.priority)] \(.title)"'
bd ready --json | jq 'length'  # Count ready issues
```

### Essential Commands

```bash
# Find unblocked work
bd ready --json
bd ready --priority 0  # Filter by priority (0=critical, 3=low)

# Create new issue
bd create "Issue title" \
  --description "Problem statement" \
  --priority 0 \
  --type bug \
  --design "Initial approach"

# Update issue
bd update <issue-id> --status in_progress
bd update <issue-id> --notes "COMPLETED: X. IN PROGRESS: Y. NEXT: Z"
bd update <issue-id> --priority 1

# Show issue details
bd show <issue-id> --json

# List issues with filters
bd list --status open --json
bd list --status in_progress --priority 0 --json

# Close completed work
bd close <issue-id> --reason "What was accomplished"

# Manage dependencies
bd dep add <dependent-issue> <prerequisite-issue>
bd dep add <dependent> <prerequisite> --type parent-child
bd dep remove <from> <to>

# Check project health
bd stats --json
bd blocked --json  # Find blocked issues
```

**For complete CLI reference:** [references/CLI_BOOTSTRAP_ADMIN.md](references/CLI_BOOTSTRAP_ADMIN.md)

## Understanding Dependencies (CRITICAL)

**The mental model trap:** `bd dep add A B` means "A depends on B", NOT "A blocks B"!

**Correct semantics:** `bd dep add A B` creates a dependency where **B must complete before A can start**.

### Creating Dependencies Correctly

```bash
# Want: "Setup must complete before Implementation can start"
bd dep add implementation setup  # ✓ CORRECT
# Result: implementation waits for setup to close

# Common mistake (backwards):
bd dep add setup implementation  # ✗ WRONG
# Result: setup waits for implementation (opposite of intent!)
```

**Mnemonic:** "DEPENDENT depends-on PREREQUISITE"
- First parameter = what waits (the dependent)
- Second parameter = what must be done first (the prerequisite)

**Verify after creating:**
```bash
bd show implementation
# Should show: "Dependencies (blocks this issue): setup"
# Meaning: implementation waits for setup
```

### Dependency Types

1. **blocks** - Hard blocker (A blocks B from starting) - default type
2. **related** - Soft link (issues are related but not blocking)
3. **parent-child** - Hierarchical (epic/subtask relationship)
4. **discovered-from** - Provenance (issue B discovered while working on A)

```bash
# Blocking dependency (default)
bd dep add phase2 phase1

# Epic structure
bd dep add subtask epic --type parent-child

# Related issues (no blocking)
bd dep add issue-a issue-b --type related

# Track discovery provenance
bd dep add new-bug current-task --type discovered-from
```

**For detailed dependency patterns:** [references/DEPENDENCIES.md](references/DEPENDENCIES.md)

## Surviving Compaction Events

**Critical:** Compaction events delete conversation history but preserve beads. After compaction, bd state is your only persistent memory.

**Writing notes for post-compaction recovery:**

```bash
# Update notes with session handoff information
bd update <issue-id> --notes "$(cat <<'EOF'
COMPLETED: JWT auth with RS256 (1hr access, 7d refresh tokens)
KEY DECISION: RS256 over HS256 per security review - enables key rotation
IN PROGRESS: Password reset flow - email service working, need rate limiting
BLOCKERS: Waiting on user decision: reset token expiry (15min vs 1hr)
NEXT: Implement rate limiting (5 attempts/15min) once expiry decided
EOF
)"
```

**Pattern:** Write notes as if explaining to a future agent with zero conversation context.

**After compaction:** `bd show <issue-id>` reconstructs full context from notes field.

**For complete compaction survival workflow:** [references/WORKFLOWS.md](references/WORKFLOWS.md#compaction-survival)

## Capturing Design Context (CRITICAL)

**Design discussions are lost at compaction unless captured in beads.** The notes field is your only persistent memory for cross-session continuity.

### What to Capture

1. **Design Decisions** - "Decided X because Y. Considered Z but rejected because..."
2. **Technical Discoveries** - "Found that API behaves unexpectedly when..."
3. **Architecture Discussions** - "Discussed event architecture: events go to notification bar OR train rows depending on type"
4. **Constraints Found** - "Push Port schedule messages are sparse - only sent on changes"
5. **Open Questions** - "Still need to decide: how long should notification events display?"

### Format for Design Notes

```bash
bd update <id> --notes "$(cat <<'EOF'
DESIGN DISCUSSIONS:
- Event display architecture: Some events → notification bar (replacing weather temporarily),
  others → train rows (ARRIVING state, CANCELLED). Need to design priority/duration.
- Considered hybrid SOAP+PushPort: SOAP for destinations (always available),
  PushPort for real-time updates (faster but sparse schedules)

KEY DISCOVERIES:
- Push Port schedule messages only sent when schedules CHANGE - not continuous
- This means fresh starts show "Unknown" destinations until schedules trickle in
- Cache helps across restarts but not for truly new trains

OPEN QUESTIONS:
- How to merge SOAP destinations with PushPort real-time updates?
- Event priority for notification bar?
EOF
)"
```

### When to Update Design Notes

- After any substantive design discussion with user
- When discovering technical constraints or surprises
- Before ending a session (closedown ritual)
- When architectural decisions are made

**Test yourself:** "If a new Claude instance reads this, will they understand the design decisions and WHY they were made?"

## Progress Checkpointing

Update bd notes at these critical triggers:

- ⚠️ **Context running low** - User says "running out of context" or >70% token usage
- 🎯 **Major milestone reached** - Completed significant piece of work
- 🚧 **Hit a blocker** - Can't proceed, need to capture what was tried
- 🔄 **Task transition** - Switching issues or about to close
- ❓ **Before user input** - About to ask decision that might change direction

**Test yourself:** "If compaction happened right now, could future-me resume from these notes?"

## Molecules, Formulas, and Gates (v0.34.0+)

bd v0.34+ introduces workflow automation: **molecules** (reusable templates), **formulas** (declarative workflows), and **gates** (async coordination).

### Quick Concepts

| Term | What it is | Storage | Use case |
|------|-----------|---------|----------|
| **Proto** | Template epic (has `template` label) | `.beads/` | Reusable workflow pattern |
| **Mol** | Persistent instance from proto | `.beads/` | Tracked work with audit trail |
| **Wisp** | Ephemeral instance from proto | `.beads-wisp/` | Operational loops, no clutter |
| **Formula** | TOML workflow definition | `.beads/formulas/` | Declarative multi-step workflows |
| **Gate** | Async coordination point | `.beads/` | Timer, mail, or GitHub-based waits |

### When to Use

**Use mols (persistent):**
- Release workflows, onboarding checklists, reviews
- Work that needs audit trail
- Multi-session projects

**Use wisps (ephemeral):**
- Patrol cycles, health checks
- Diagnostic runs
- High-frequency operational work

**Use formulas:**
- Repeatable multi-step workflows
- Release processes with gates
- Workflows with variable substitution

**Use gates:**
- Wait for time-based triggers
- Wait for GitHub PR merge or workflow completion
- Human approval checkpoints

### Quick Commands

```bash
# List available templates/formulas
bd mol catalog
bd cook --list                    # List available formulas

# Create work from template (v0.36.0+: spawn removed, use pour/wisp)
bd pour mol-release --var version=2.0      # Persistent mol
bd wisp create mol-patrol                   # Ephemeral wisp

# Execute formula
bd cook beads-release --var version=2.0    # Run declarative workflow

# Durable execution (pour + assign + pin for crash recovery)
bd mol run mol-release --var version=2.0

# Gates (async coordination)
bd gate create "Wait for PR merge" --await gh:pr:merged
bd gate eval .claude-xyz           # Evaluate gate conditions
bd gate approve .claude-xyz        # Human approval

# End ephemeral work
bd mol squash wisp-abc --summary "Completed patrol"  # Compress to digest
bd mol burn wisp-abc                                 # Delete without trace

# Extract template from ad-hoc work
bd mol distill bd-epic --as "Release Process" --var version=X.Y.Z
```

### Cross-Project Dependencies

```bash
# Project A ships capability
bd ship auth-api

# Project B depends on it
bd dep add bd-123 external:project-a:auth-api
```

**For detailed patterns:** [references/MOLECULES.md](references/MOLECULES.md)

---

## Issue Lifecycle Workflow

### 1. Discovery Phase (Proactive Issue Creation)

```bash
# File discovered work immediately
bd create "Found: auth doesn't handle profile permissions" \
  --type bug \
  --description "Discovered while implementing login flow"

# Link with provenance
bd dep add new-issue current-task --type discovered-from
```

**Key benefit:** Capture context immediately instead of losing it when conversation ends.

### 2. Execution Phase (Status Maintenance)

```bash
# Start work
bd update <issue-id> --status in_progress

# Update design as implementation progresses
bd update <issue-id> --design "Using JWT with RS256 for key rotation"

# Close when complete
bd close <issue-id> --reason "Implemented JWT validation with tests passing"
```

**Important:** Closed issues remain in database - they're not deleted, just marked complete for project history.

### 3. Planning Phase (Dependency Graphs)

```bash
# Create epic
bd create "Implement user authentication" --type epic

# Create subtasks
bd create "Setup auth library" --type task
bd create "Implement login flow" --type task

# Link structure
bd dep add auth-setup auth-epic --type parent-child
bd dep add auth-flow auth-epic --type parent-child

# Create ordering (auth-flow depends on auth-setup)
bd dep add auth-flow auth-setup
```

**For complete workflow patterns:** [references/WORKFLOWS.md](references/WORKFLOWS.md)

## Field Usage Reference

| Field | Purpose | When to Set | Update Frequency |
|-------|---------|-------------|------------------|
| **description** | Immutable problem statement | At creation | Never (fixed forever) |
| **design** | Initial approach, architecture, decisions | During planning | Rarely (only if approach changes) |
| **acceptance-criteria** | Concrete deliverables checklist (`- [ ]` syntax) | When design is clear | Mark `- [x]` as items complete |
| **notes** | Session handoff (COMPLETED/IN_PROGRESS/NEXT) | During work | At session end, major milestones |
| **status** | Workflow state (open→in_progress→closed) | As work progresses | When changing phases |
| **priority** | Urgency level (0=highest, 3=lowest) | At creation | Adjust if priorities shift |

**Key pattern:** Notes field is your "read me first" at session start.

## Integration with TodoWrite

**TodoWrite and bd complement each other at different timescales:**

- **TodoWrite:** Short-term working memory (this hour) - tactical execution, ephemeral
- **bd:** Long-term episodic memory (this week/month) - strategic context, persistent

**The handoff pattern:** Session start → read bd notes → create TodoWrite → work → update bd at milestones → TodoWrite disappears, bd survives.

**Key principle:** TodoWrite tracks execution ("Implement endpoint"), bd captures meaning ("COMPLETED: Endpoint with JWT auth. KEY DECISION: RS256 for key rotation").

**For temporal layering patterns:** [references/INTEGRATION_PATTERNS.md](references/INTEGRATION_PATTERNS.md#todowrite-integration)

### Draw-Down Pattern

**Trigger:** User says "let's work on bead X" or you run `bd update <id> --status in_progress`.

**STOP. Before doing anything else:**

1. `bd show <bead-id> --json` — read design and acceptance-criteria
2. Create TodoWrite items — actual steps, not "work on the bead"
3. Show user: "Breaking this down into: [list]. Sound right?"
4. **VERIFY:** TodoWrite is not empty before proceeding
5. THEN start working

**If TodoWrite is empty after user says "let's work on bead X", you have failed.** This is not optional.

At each TodoWrite completion, pause: "Still the right direction?"

**Why this matters:** Beads alone don't create pauses. TodoWrite items create natural breakpoints. These breakpoints are where you catch drift before it compounds.

**The failure mode:** Without draw-down, you work from the bead directly, context accumulates, and by the time /close runs you've drifted. The breakpoints are where course-correction happens.

**Example — Good draw-down:**

```
Bead: "Add user authentication to API"
Design: "JWT with RS256, refresh tokens, password reset flow"
Acceptance: "Login/logout works, tokens expire correctly, reset email sends"

→ TodoWrite:
1. Set up JWT library and key generation
2. Implement login endpoint with token issuance
3. Implement token refresh endpoint
4. Implement logout (token invalidation)
5. Implement password reset flow
6. Add integration tests
```

Each TodoWrite item is a checkpoint. When you complete item 2 and start item 3, that's a moment to ask "still on track?" Not just motor through.

**Example — Bad (no draw-down):**

```
Bead: "Add user authentication to API"
→ Start coding immediately
→ 45 minutes later, deep in password reset edge cases
→ Forgot about token refresh entirely
→ Context exhausted, /close runs, handoff is confused
```

### Session Boundary Pattern

**Trigger:** You just closed a bead (or batch of beads) and there's more ready work.

**STOP. Before summarizing and asking "what's next?":**

1. Check `bd ready` — what's now unblocked?
2. If user wants to continue → **do the draw-down for the next bead**
3. If user wants to stop → proceed to /close

**The gap this fills:** Draw-down happens at session start because `/open` commands it. But mid-session transitions (finishing one bead, starting another) don't have the same trigger. This pattern creates the checkpoint.

**Example — Good session boundary:**

```
[Complete bead .claude-ftz]
bd close .claude-ftz --reason "Fixed container detection"

"Bug fix complete. Ready work now includes:
- .claude-dqg (handoff accumulation) — was blocked, now ready
- .claude-c9j (bidirectional reflection)

Want to continue with .claude-dqg? If so, let me draw down from its acceptance criteria..."
```

**Example — Bad (no boundary check):**

```
[Complete bead .claude-ftz]
bd close .claude-ftz --reason "Fixed container detection"

"Done! What's next?"
→ User says "continue"
→ Start working without draw-down
→ Drift begins
```

**The pattern:** Close bead → check ready → offer next with draw-down commitment.

## Issue Creation Guidelines

**Quick guidelines:**
- Ask user first for knowledge work with fuzzy boundaries
- Create directly for clear bugs, technical debt, or discovered work
- Use clear titles, sufficient context in descriptions
- Design field: HOW to build (can change during implementation)
- Acceptance criteria: WHAT success looks like (should remain stable)

**Self-check for acceptance criteria:**

❓ "If I changed the implementation approach, would these criteria still apply?"
- → **Yes** = Good criteria (outcome-focused)
- → **No** = Move to design field (implementation-focused)

**Standard design field structure:**

```bash
bd create "Title" --design "$(cat <<'EOF'
## Approach
[How you'll build this]

## Workflow
1. DRAW-DOWN: Create TodoWrite items from acceptance criteria
2. Work through items, check direction at each completion
3. Update notes at milestones
EOF
)"
```

Every new bead should include the Workflow section. When you `bd show` later, the reminder is right there in the output. Self-documenting enforcement.

**For detailed creation guidance:** [references/ISSUE_CREATION.md](references/ISSUE_CREATION.md)

## Error Recovery

**Wrong Dependency Created:**
```bash
# Remove wrong dependency
bd dep remove A B

# Create correct dependency (B depends on A)
bd dep add B A

# Verify
bd show B  # Should show "Dependencies: A"
```

**Closed Issue Prematurely:**
```bash
# Reopen the issue
bd reopen <issue-id> --reason "Need to add error handling"

# Issue returns to 'open' status
```

**Duplicate Issues:**
```bash
# Preview deletion
bd delete <issue-dup>

# Force delete if safe
bd delete <issue-dup> --force

# If duplicate has dependencies, reassign first
bd dep remove dependent issue-dup
bd dep add dependent issue-kept
bd delete issue-dup --force
```

## Statistics and Monitoring

```bash
# Project health overview
bd stats --json

# Find blocked work
bd blocked --json

# Check daemon status
bd daemon --status
```

Use stats to report progress, identify bottlenecks, and understand project velocity.

## Troubleshooting

**For comprehensive troubleshooting guide:** [references/TROUBLESHOOTING.md](references/TROUBLESHOOTING.md)

**Common issues:**
- Dependencies not persisting → Check bd version (need v0.15.0+)
- Status updates delayed → Daemon sync timing (3-5s delay expected)
- Daemon won't start → Git repository required
- Cloud storage errors → SQLite incompatible with Google Drive/Dropbox

## Database Selection

bd automatically selects the appropriate database:
- **Project-local** (`.beads/` in project): Used for project-specific work
- **Global fallback** (`~/.beads/`): Used when no project-local database exists

**Use --db flag explicitly when:**
- Accessing a specific database outside current directory
- Working with multiple databases (e.g., project database + reference database)

## Bootstrap and Initialization

**Use short prefixes** (2-3 chars): `bd-`, `vc-`, `wy-`. Makes everything more readable.

```bash
# Initialize new project (auto-detects prefix from folder name)
bd init

# Initialize with explicit short prefix
bd init --prefix wy

# Install git hooks for auto-sync
bd hooks install

# Start daemon (auto-starts on first command)
bd daemon

# Compact old closed issues
bd compact --all
```

**For complete bootstrap guide:** [references/CLI_BOOTSTRAP_ADMIN.md](references/CLI_BOOTSTRAP_ADMIN.md)

## Common Patterns

**Quick patterns for typical scenarios:**

- **Knowledge work:** Read bd notes → create TodoWrite → work → update notes at milestones
- **Side quests:** Create issue immediately, link with discovered-from, assess blocker vs defer
- **Multi-session resume:** `bd ready` → `bd show` → read notes → begin work
- **Compaction recovery:** Read notes field to reconstruct full context
- **Status transitions:** open → in_progress → blocked/closed as appropriate

**For detailed pattern examples:** [references/PATTERNS.md](references/PATTERNS.md)

## Reference Files

Detailed information organized by topic:

| Reference | Read When |
|-----------|-----------|
| [TROUBLESHOOTING.md](references/TROUBLESHOOTING.md) | **Encountering errors** - dependencies not saving, sync delays, daemon issues |
| [WORKFLOWS.md](references/WORKFLOWS.md) | Need step-by-step workflows with checklists for common scenarios |
| [DEPENDENCIES.md](references/DEPENDENCIES.md) | Need deep understanding of dependency types or relationship patterns |
| [BOUNDARIES.md](references/BOUNDARIES.md) | Need detailed decision criteria for bd vs TodoWrite |
| [PATTERNS.md](references/PATTERNS.md) | Need detailed examples of common patterns and status transitions |
| [INTEGRATION_PATTERNS.md](references/INTEGRATION_PATTERNS.md) | Need integration with TodoWrite or writing-plans |
| [ISSUE_CREATION.md](references/ISSUE_CREATION.md) | Need guidance on when to ask vs create issues, issue quality |
| [CLI_BOOTSTRAP_ADMIN.md](references/CLI_BOOTSTRAP_ADMIN.md) | Need CLI commands for bootstrap or admin operations |
| [RESUMABILITY.md](references/RESUMABILITY.md) | Need patterns for writing resumable notes |
| [STATIC_DATA.md](references/STATIC_DATA.md) | Want to use bd for reference databases instead of work tracking |
| [MOLECULES.md](references/MOLECULES.md) | **Reusable templates** - protos, mols, wisps, cross-project deps (v0.34.0+) |
| [PORTFOLIO.md](references/PORTFOLIO.md) | **Cross-project view** - see all beads across repos, triage, audit skeleton beads |
