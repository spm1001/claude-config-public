---
name: bd-issue-tracking
description: Track complex, multi-session work with dependency graphs using bd (beads) issue tracker. Use when work spans multiple sessions, has complex dependencies, or requires persistent context across compaction cycles. For simple single-session linear tasks, TodoWrite remains appropriate.
---

# bd Issue Tracking

## Overview

bd is a graph-based issue tracker for persistent memory across sessions. Use for multi-session work with complex dependencies; use TodoWrite for simple single-session tasks.

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

### Test Yourself: bd or TodoWrite?

Ask these questions to decide:

**Choose bd if:**
- ❓ "Will I need this context in 2 weeks?" → Yes = bd
- ❓ "Could conversation history get compacted?" → Yes = bd
- ❓ "Does this have blockers/dependencies?" → Yes = bd
- ❓ "Is this fuzzy/exploratory work?" → Yes = bd

**Choose TodoWrite if:**
- ❓ "Will this be done in this session?" → Yes = TodoWrite
- ❓ "Is this just a task list for me right now?" → Yes = TodoWrite
- ❓ "Is this linear with no branching?" → Yes = TodoWrite

**When in doubt**: Use bd. Better to have persistent memory you don't need than to lose context you needed.

**For detailed decision criteria and examples, read:** [references/BOUNDARIES.md](references/BOUNDARIES.md)

## Interface: MCP Tools (CLI for Bootstrap)

bd provides **MCP tools** for all core operations. Use MCP tools when available (local Claude Code environment). CLI is needed only for bootstrap/admin operations or when MCP is unavailable (web environment).

### Primary Interface: MCP Tools

**Use MCP tools for all core operations:**
- `mcp__plugin_beads_beads__ready` - Find unblocked work
- `mcp__plugin_beads_beads__list` - List issues with filters
- `mcp__plugin_beads_beads__show` - Show issue details
- `mcp__plugin_beads_beads__create` - Create new issues
- `mcp__plugin_beads_beads__update` - Update issue fields
- `mcp__plugin_beads_beads__close` - Close completed work
- `mcp__plugin_beads_beads__dep` - Manage dependencies
- `mcp__plugin_beads_beads__stats` - Project statistics
- `mcp__plugin_beads_beads__blocked` - Find blocked work

**Why MCP:** Structured JSON I/O, type validation, error handling, parameter documentation.

### Bootstrap/Admin: CLI Only

**CLI commands for operations without MCP equivalent:**
- `bd init [prefix]` - Initialize bd in new project (creates `.beads/` directory)
- `bd daemon [--global] [--stop] [--status]` - Start/stop/check daemon
- `bd compact` - Compact old closed issues
- `bd export/import` - JSONL export/import

**Why these are CLI-only:** Bootstrap operations that must happen before daemon can route requests, or admin operations outside normal workflow.

### Web Environment: CLI Fallback

**When MCP unavailable (web Claude Code without MCP setup):**

Use CLI equivalents for core operations:

| MCP Tool | CLI Equivalent |
|----------|---------------|
| `mcp__plugin_beads_beads__ready` | `bd ready --json` |
| `mcp__plugin_beads_beads__list` | `bd list --status <status> --json` |
| `mcp__plugin_beads_beads__show` | `bd show <issue-id> --json` |
| `mcp__plugin_beads_beads__create` | `bd create "title" -p <priority> -t <type>` |
| `mcp__plugin_beads_beads__update` | `bd update <issue-id> --status <status>` |
| `mcp__plugin_beads_beads__close` | `bd close <issue-id> --reason "..."` |
| `mcp__plugin_beads_beads__dep` | `bd dep add <dependent> <prerequisite>` |

**Pattern for this Skill:** Examples show MCP tools (primary interface). CLI equivalents noted in parentheses where helpful for web environment.

## Surviving Compaction Events

**Critical**: Compaction events delete conversation history but preserve beads. After compaction, bd state is your only persistent memory.

**What survives compaction:**
- All bead data (issues, notes, dependencies, status)
- Complete work history and context

**What doesn't survive:**
- Conversation history
- TodoWrite lists
- Recent discussion context

**Writing notes for post-compaction recovery:**

Write notes as if explaining to a future agent with zero conversation context:

**Pattern:**
```markdown
notes field format:
- COMPLETED: Specific deliverables ("implemented JWT refresh endpoint + rate limiting")
- IN PROGRESS: Current state + next immediate step ("testing password reset flow, need user input on email template")
- BLOCKERS: What's preventing progress
- KEY DECISIONS: Important context or user guidance
```

**After compaction:** `bd show <issue-id>` reconstructs full context from notes field.

### Notes Quality Self-Check

Before checkpointing (especially pre-compaction), verify your notes pass these tests:

❓ **Future-me test**: "Could I resume this work in 2 weeks with zero conversation history?"
- [ ] What was completed? (Specific deliverables, not "made progress")
- [ ] What's in progress? (Current state + immediate next step)
- [ ] What's blocked? (Specific blockers with context)
- [ ] What decisions were made? (Why, not just what)

❓ **Stranger test**: "Could another developer understand this without asking me?"
- [ ] Technical choices explained (not just stated)
- [ ] Trade-offs documented (why this approach vs alternatives)
- [ ] User input captured (decisions that came from discussion)

**Good note example:**
```
COMPLETED: JWT auth with RS256 (1hr access, 7d refresh tokens)
KEY DECISION: RS256 over HS256 per security review - enables key rotation
IN PROGRESS: Password reset flow - email service working, need rate limiting
BLOCKERS: Waiting on user decision: reset token expiry (15min vs 1hr trade-off)
NEXT: Implement rate limiting (5 attempts/15min) once expiry decided
```

**Bad note example:**
```
Working on auth. Made some progress. More to do.
```

**For complete compaction recovery workflow, read:** [references/WORKFLOWS.md](references/WORKFLOWS.md#compaction-survival)

## Session Start Protocol

**bd is available when:**
- Project has a `.beads/` directory (project-local database), OR
- `~/.beads/` exists (global fallback database for any directory)

**At session start, always check for bd availability and run ready check.**

### Session Start Checklist

Copy this checklist when starting any session where bd is available:

```
Session Start (with MCP):
- [ ] Use mcp__plugin_beads_beads__ready to see available work
- [ ] Use mcp__plugin_beads_beads__list with status:"in_progress" for active work
- [ ] If in_progress exists: use mcp__plugin_beads_beads__show to read notes
- [ ] Report context to user: "X items ready: [summary]"
- [ ] If using global ~/.beads, mention this in report
- [ ] If nothing ready: use mcp__plugin_beads_beads__blocked to check blockers

Session Start (CLI fallback - web environment):
- [ ] Run bd ready --json to see available work
- [ ] Run bd list --status in_progress --json for active work
- [ ] If in_progress exists: bd show <issue-id> to read notes
- [ ] Report context to user: "X items ready: [summary]"
```

**Pattern**: Always check both ready work AND in_progress issues. Read notes field first to understand where previous session left off.

**Report format**:
- "I can see X items ready to work on: [summary]"
- "Issue Y is in_progress. Last session: [summary from notes]. Next: [from notes]. Should I continue with that?"

This establishes immediate shared context about available and active work without requiring user prompting.

**For detailed collaborative handoff process, read:** [references/WORKFLOWS.md](references/WORKFLOWS.md#session-handoff)

**Note**: bd auto-discovers the database:
- Uses `.beads/*.db` in current project if exists
- Falls back to `~/.beads/default.db` otherwise
- No configuration needed

### When No Work is Ready

Use `mcp__plugin_beads_beads__blocked` tool to find blocked issues.

(CLI: `bd blocked --json`)

Report blockers and suggest next steps.

---

## Progress Checkpointing

Update bd notes at these checkpoints (don't wait for session end):

**Critical triggers:**
- ⚠️ **Context running low** - User says "running out of context" / "approaching compaction" / "close to token limit"
- 📊 **Token budget > 70%** - Proactively checkpoint when approaching limits
- 🎯 **Major milestone reached** - Completed significant piece of work
- 🚧 **Hit a blocker** - Can't proceed, need to capture what was tried
- 🔄 **Task transition** - Switching issues or about to close this one
- ❓ **Before user input** - About to ask decision that might change direction

**Proactive monitoring during session:**
- At 70% token usage: "We're at 70% token usage - good time to checkpoint bd notes?"
- At 85% token usage: "Approaching token limit (85%) - checkpointing current state to bd"
- At 90% token usage: Automatically checkpoint without asking

**Current token usage**: Check `<system-warning>Token usage:` messages to monitor proactively.

**Checkpoint checklist:**

```
Progress Checkpoint:
- [ ] Update notes with COMPLETED/IN_PROGRESS/NEXT format
- [ ] Document KEY DECISIONS or BLOCKERS since last update
- [ ] Mark current status (in_progress/blocked/closed)
- [ ] If discovered new work: create issues with discovered-from
- [ ] Verify notes are self-explanatory for post-compaction resume
```

**Most important**: When user says "running out of context" OR when you see >70% token usage - checkpoint immediately, even if mid-task.

**Test yourself**: "If compaction happened right now, could future-me resume from these notes?"

---

### Database Selection

bd automatically selects the appropriate database:
- **Project-local** (`.beads/` in project): Used for project-specific work
- **Global fallback** (`~/.beads/`): Used when no project-local database exists

**Use case for global database**: Cross-project tracking, personal task management, knowledge work that doesn't belong to a specific project.

**When to use --db flag explicitly:**
- Accessing a specific database outside current directory
- Working with multiple databases (e.g., project database + reference database)
- Example: `bd --db /path/to/reference/terms.db list`

**Database discovery rules:**
- bd looks for `.beads/*.db` in current working directory
- If not found, uses `~/.beads/default.db`
- Shell cwd can reset between commands - use absolute paths with --db when operating on non-local databases

**For complete session start workflows, read:** [references/WORKFLOWS.md](references/WORKFLOWS.md#session-start)

## Core Operations

Use MCP tools for all core operations. All tools return structured JSON data.

### Essential Operations

**Check ready work:**

Use `mcp__plugin_beads_beads__ready` tool with optional filters:
- `priority`: Filter by priority level (0-3)
- `assignee`: Filter by assignee name

Returns list of unblocked issues ready to work on.

(CLI: `bd ready --json --priority 0 --assignee alice`)

**Create new issue:**

Use `mcp__plugin_beads_beads__create` tool with parameters:
- `title`: Issue title (required)
- `description`: Problem statement
- `priority`: 0=critical, 1=high, 2=normal (default), 3=low
- `type`: bug/feature/task/epic/chore
- `design`: HOW to build (approach, architecture)
- `acceptance`: WHAT success looks like (deliverables)
- `assignee`: Who's responsible

Example parameters:
```json
{
  "title": "Fix login bug",
  "description": "Users cannot log in with SSO",
  "priority": 0,
  "type": "bug"
}
```

(CLI: `bd create "Fix login bug" -d "Users cannot log in with SSO" -p 0 -t bug`)

**Update issue:**

Use `mcp__plugin_beads_beads__update` tool with:
- `issue_id`: Issue to update (required)
- `status`: open/in_progress/blocked/closed
- `priority`: 0-3
- `design`: Update approach
- `notes`: Add session handoff information
- `assignee`: Change ownership

(CLI: `bd update issue-123 --status in_progress --priority 0`)

**Close completed work:**

Use `mcp__plugin_beads_beads__close` tool with:
- `issue_id`: Issue to close (required)
- `reason`: Why closing (completion summary)

Can close multiple issues by calling tool multiple times.

(CLI: `bd close issue-123 --reason "Implemented in PR #42"`)

**Show issue details:**

Use `mcp__plugin_beads_beads__show` tool with:
- `issue_id`: Issue to show (required)

Returns full issue details including notes, dependencies, history.

(CLI: `bd show issue-123 --json`)

**List issues:**

Use `mcp__plugin_beads_beads__list` tool with filters:
- `status`: open/in_progress/blocked/closed
- `priority`: 0-3
- `type`: bug/feature/task/epic/chore
- `assignee`: Filter by assignee

(CLI: `bd list --status open --priority 0 --type bug`)

**For CLI bootstrap/admin commands, read:** [references/CLI_BOOTSTRAP_ADMIN.md](references/CLI_BOOTSTRAP_ADMIN.md)

## Field Usage Reference

Quick guide for when and how to use each bd field:

| Field | Purpose | When to Set | Update Frequency |
|-------|---------|-------------|------------------|
| **description** | Immutable problem statement | At creation | Never (fixed forever) |
| **design** | Initial approach, architecture, decisions | During planning | Rarely (only if approach changes) |
| **acceptance-criteria** | Concrete deliverables checklist (`- [ ]` syntax) | When design is clear | Mark `- [x]` as items complete |
| **notes** | Session handoff (COMPLETED/IN_PROGRESS/NEXT) | During work | At session end, major milestones |
| **status** | Workflow state (open→in_progress→closed) | As work progresses | When changing phases |
| **priority** | Urgency level (0=highest, 3=lowest) | At creation | Adjust if priorities shift |

**Key pattern**: Notes field is your "read me first" at session start. See [WORKFLOWS.md](references/WORKFLOWS.md#session-handoff) for session handoff details.

---

## Integration with writing-plans Skill (Optional)

**For very complex features**, bd's design field can link to detailed implementation plans (RED-GREEN-REFACTOR breakdown).

**Pattern**: Create bd issue → use writing-plans skill for detailed plan → link in design field → use TodoWrite to track current task within plan → update bd notes at milestones.

**When to use**: Complex features with multiple components, multi-session systematic work, TDD-appropriate core logic.

**When to skip**: Simple features, exploratory work, infrastructure setup, would take longer to plan than implement.

**For complete integration patterns, examples, and decision framework, read:** [references/INTEGRATION_PATTERNS.md](references/INTEGRATION_PATTERNS.md#writing-plans-integration)

---

## Issue Lifecycle Workflow

### 1. Discovery Phase (Proactive Issue Creation)

**During exploration or implementation, proactively file issues for:**
- Bugs or problems discovered
- Potential improvements noticed
- Follow-up work identified
- Technical debt encountered
- Questions requiring research

**Pattern:**

Use `mcp__plugin_beads_beads__create` to capture new work, then `mcp__plugin_beads_beads__dep` to link:

```json
// Create discovered issue
{
  "title": "Found: auth doesn't handle profile permissions",
  "type": "bug",
  "description": "Discovered while implementing login flow"
}

// Link with discovered-from dependency
{
  "from_issue": "current-task-id",
  "to_issue": "new-issue-id",
  "type": "discovered-from"
}
```

(CLI: `bd create "Found: auth doesn't handle profile permissions"` then `bd dep add current-task-id new-issue-id --type discovered-from`)

**Key benefit**: Capture context immediately instead of losing it when conversation ends.

### 2. Execution Phase (Status Maintenance)

**Mark issues in_progress when starting work:**

Use `mcp__plugin_beads_beads__update`:
```json
{
  "issue_id": "issue-123",
  "status": "in_progress"
}
```

(CLI: `bd update issue-123 --status in_progress`)

**Update throughout work:**

Add design notes as implementation progresses:
```json
{
  "issue_id": "issue-123",
  "design": "Using JWT with RS256 algorithm for key rotation support"
}
```

(CLI: `bd update issue-123 --design "Using JWT with RS256 algorithm"`)

**Close when complete:**

Use `mcp__plugin_beads_beads__close`:
```json
{
  "issue_id": "issue-123",
  "reason": "Implemented JWT validation with tests passing"
}
```

(CLI: `bd close issue-123 --reason "Implemented JWT validation with tests passing"`)

**Important**: Closed issues remain in database - they're not deleted, just marked complete for project history.

### 3. Planning Phase (Dependency Graphs)

For complex multi-step work, structure issues with dependencies before starting:

**Create parent epic:**

Use `mcp__plugin_beads_beads__create`:
```json
{
  "title": "Implement user authentication",
  "type": "epic",
  "description": "OAuth integration with JWT tokens"
}
```

**Create subtasks:**

Create multiple issues for each part of the work.

**Link with dependencies:**

Use `mcp__plugin_beads_beads__dep` tool:

```json
// parent-child for epic structure
{
  "from_issue": "auth-epic",
  "to_issue": "auth-setup",
  "type": "parent-child"
}

// blocks for ordering - DEPENDENT first, PREREQUISITE second
{
  "from_issue": "auth-flow",
  "to_issue": "auth-setup",
  "type": "blocks"
}
// This means: auth-flow depends on auth-setup
// Effect: auth-flow cannot start until auth-setup completes
```

(CLI: `bd dep add auth-epic auth-setup --type parent-child` then `bd dep add auth-flow auth-setup`)

### Understanding blocks Direction (Critical!)

**Mental model trap**: The command is `bd dep add A B` but this means "A depends on B", NOT "A blocks B"!

**The actual semantics**: `bd dep add A B` creates a dependency where **B must complete before A can start**.

**When you want "A must complete before B can start":**

```bash
bd dep add B A --type blocks
# ✓ CORRECT: B depends on A (so A must finish first)
# ✓ Meaning: A is prerequisite, B is dependent
# ✓ Effect: B excluded from `bd ready` until A closes
```

**Common mistake (what intuition suggests):**
```bash
bd dep add A B --type blocks
# ✗ WRONG: A depends on B (backwards!)
# ✗ Effect: A is excluded from ready until B closes
# ✗ This is the OPPOSITE of what you want
```

**Correct mnemonic**: "DEPENDENT depends-on PREREQUISITE"
- First parameter = what waits (the dependent)
- Second parameter = what must be done first (the prerequisite)

**Visual check after creating dependency:**
```bash
bd show B
# Should show: "Dependencies (blocks this issue): A"
# This means B waits for A (A must complete first)
```

**Correct examples:**

```bash
# Phase 1 must complete before Phase 2
bd dep add phase2 phase1  # ✓ phase2 depends on phase1

# Database schema must exist before API endpoint
bd dep add endpoint schema  # ✓ endpoint depends on schema

# Setup must finish before implementation
bd dep add impl setup  # ✓ impl depends on setup
```

**Memory aid**: Think "the thing that waits goes first in the command"

**For detailed dependency patterns and types, read:** [references/DEPENDENCIES.md](references/DEPENDENCIES.md)

## Dependency Types Reference

bd supports four dependency types:

1. **blocks** - Hard blocker (issue A blocks issue B from starting)
2. **related** - Soft link (issues are related but not blocking)
3. **parent-child** - Hierarchical (epic/subtask relationship)
4. **discovered-from** - Provenance (issue B discovered while working on A)

**For complete guide on when to use each type with examples and patterns, read:** [references/DEPENDENCIES.md](references/DEPENDENCIES.md)

## Integration with TodoWrite

**TodoWrite and bd complement each other at different timescales:**

- **TodoWrite**: Short-term working memory (this hour) - tactical execution, ephemeral
- **bd**: Long-term episodic memory (this week/month) - strategic context, persistent

**The handoff pattern**: Session start → read bd notes → create TodoWrite → work → update bd at milestones → TodoWrite disappears, bd survives.

**Key principle**: TodoWrite tracks execution ("Implement endpoint"), bd captures meaning ("COMPLETED: Endpoint with JWT auth. KEY DECISION: RS256 for key rotation").

**For temporal layering pattern, examples, and when to update each tool, read:** [references/INTEGRATION_PATTERNS.md](references/INTEGRATION_PATTERNS.md#todowrite-integration)

**For complete decision criteria (bd vs TodoWrite), read:** [references/BOUNDARIES.md](references/BOUNDARIES.md)

## Common Patterns

**Quick patterns for typical scenarios:**

- **Knowledge work**: Read bd notes (via `mcp__plugin_beads_beads__show`) → create TodoWrite → work → update notes at milestones
- **Side quests**: Create issue immediately (via `mcp__plugin_beads_beads__create`), link with discovered-from dependency, assess blocker vs defer
- **Multi-session resume**: Use `mcp__plugin_beads_beads__ready` → `mcp__plugin_beads_beads__show` → read notes → begin work
- **Compaction recovery**: Read notes field to reconstruct full context
- **Status transitions**: open → in_progress → blocked/closed as appropriate (via `mcp__plugin_beads_beads__update`)
- **Issue closure**: Update notes with outcomes, document key decisions (via `mcp__plugin_beads_beads__close`)

**For detailed examples, status transitions, and compaction recovery patterns, read:** [references/PATTERNS.md](references/PATTERNS.md)

**For step-by-step workflows with checklists, read:** [references/WORKFLOWS.md](references/WORKFLOWS.md)

## Issue Creation

**Quick guidelines:**
- Ask user first for knowledge work with fuzzy boundaries
- Create directly for clear bugs, technical debt, or discovered work
- Use clear titles, sufficient context in descriptions
- Design field: HOW to build (can change during implementation)
- Acceptance criteria: WHAT success looks like (should remain stable)

### Issue Creation Checklist

Copy when creating new issues:

```
Creating Issue:
- [ ] Title: Clear, specific, action-oriented
- [ ] Description: Problem statement (WHY this matters) - immutable
- [ ] Design: HOW to build (can change during work)
- [ ] Acceptance: WHAT success looks like (stays stable)
- [ ] Priority: 0=critical, 1=high, 2=normal, 3=low
- [ ] Type: bug/feature/task/epic/chore
```

**Self-check for acceptance criteria:**

❓ "If I changed the implementation approach, would these criteria still apply?"
- → **Yes** = Good criteria (outcome-focused)
- → **No** = Move to design field (implementation-focused)

**Example:**
- ✅ Acceptance: "User tokens persist across sessions and refresh automatically"
- ❌ Wrong: "Use JWT tokens with 1-hour expiry" (that's design, not acceptance)

**For detailed guidance on when to ask vs create, issue quality, resumability patterns, and design vs acceptance criteria, read:** [references/ISSUE_CREATION.md](references/ISSUE_CREATION.md)

## Alternative Use Cases

bd is primarily for work tracking, but can also serve as queryable database for static reference data (glossaries, terminology) with adaptations.

**For guidance on using bd for reference databases and static data, read:** [references/STATIC_DATA.md](references/STATIC_DATA.md)

## Statistics and Monitoring

**Check project health:**

Use `mcp__plugin_beads_beads__stats` tool.

Returns: total issues, open, in_progress, closed, blocked, ready, avg lead time

(CLI: `bd stats --json`)

**Find blocked work:**

Use `mcp__plugin_beads_beads__blocked` tool.

Returns list of issues that have unresolved dependencies.

(CLI: `bd blocked --json`)

Use stats to:
- Report progress to user
- Identify bottlenecks
- Understand project velocity

## Error Recovery

Mistakes happen. Here's how to fix common errors:

### Wrong Dependency Created

**Symptom:** Created dependency backwards - wanted A to block B, but did `bd dep add A B` (made A depend on B instead).

**Fix:**
```bash
# Remove wrong dependency
bd dep remove A B

# Create correct dependency (B depends on A, so A blocks B)
bd dep add B A

# Verify with bd show
bd show B  # Should show "Dependencies: A"
```

### Closed Issue Prematurely

**Symptom:** Marked issue as done, but work isn't actually complete.

**Fix:**
```bash
# Reopen the issue
bd reopen issue-123 --reason "Need to add error handling"

# Issue returns to 'open' status and appears in bd ready
bd ready  # Should now include issue-123
```

**Bulk reopen:**
```bash
bd reopen issue-1 issue-2 issue-3 --reason "Sprint not complete"
```

### Duplicate Issues Created

**Symptom:** Accidentally created two issues for the same work.

**Strategy:** Keep the better one, delete the duplicate.

**Safe deletion (preview first):**
```bash
# Check what would be deleted
bd delete issue-duplicate

# If safe, delete with --force
bd delete issue-duplicate --force
```

**If duplicate has dependencies:**
```bash
# Preview shows dependents
bd delete issue-dup

# Choose strategy:
# Option 1: Move dependencies to kept issue first, then delete
bd dep remove dependent-issue issue-dup
bd dep add dependent-issue issue-kept
bd delete issue-dup --force

# Option 2: Force delete and orphan dependents (they become unblocked)
bd delete issue-dup --force
```

**Cascade delete (deletes issue AND all dependents):**
```bash
bd delete issue-dup --cascade --force
```
⚠️ Use cascade carefully - it recursively deletes everything depending on the issue.

### Wrong Dependency Type

**Symptom:** Used `--type blocks` but should have used `--type parent-child`.

**Fix:**
```bash
# Remove wrong dependency
bd dep remove child parent

# Add with correct type
bd dep add child parent --type parent-child
```

## Troubleshooting

**Common issues?** See [references/TROUBLESHOOTING.md](references/TROUBLESHOOTING.md) for complete guide including:
- Dependencies not persisting (bd v0.15.0+ required)
- Status updates not visible (daemon sync delays)
- Daemon won't start (git repository required)
- Cloud storage errors (SQLite incompatible with Google Drive/Dropbox)
- MCP parameter confusion
- Version requirements and debug checklists

**Quick fixes:**
- Dependencies wrong direction: See [Error Recovery](#error-recovery)
- Database issues: [references/DEPENDENCIES.md](references/DEPENDENCIES.md#common-mistakes)
- Bootstrap/admin commands: [references/CLI_BOOTSTRAP_ADMIN.md](references/CLI_BOOTSTRAP_ADMIN.md)

## Reference Files

Detailed information organized by topic:

| Reference | Read When |
|-----------|-----------|
| [references/TROUBLESHOOTING.md](references/TROUBLESHOOTING.md) | **Encountering errors or unexpected behavior** - dependencies not saving, sync delays, daemon issues, cloud storage errors, version problems |
| [references/PATTERNS.md](references/PATTERNS.md) | Need detailed examples of common patterns: knowledge work, side quests, compaction recovery, status transitions, closure |
| [references/INTEGRATION_PATTERNS.md](references/INTEGRATION_PATTERNS.md) | Need detailed integration with TodoWrite or writing-plans, cross-skill workflows, decision framework |
| [references/BOUNDARIES.md](references/BOUNDARIES.md) | Need detailed decision criteria for bd vs TodoWrite, or integration patterns |
| [references/CLI_BOOTSTRAP_ADMIN.md](references/CLI_BOOTSTRAP_ADMIN.md) | Need CLI commands for bootstrap (init, daemon) or admin operations (compact, export/import), or web environment CLI equivalents |
| [references/WORKFLOWS.md](references/WORKFLOWS.md) | Need step-by-step workflows with checklists for common scenarios |
| [references/DEPENDENCIES.md](references/DEPENDENCIES.md) | Need deep understanding of dependency types or relationship patterns |
| [references/ISSUE_CREATION.md](references/ISSUE_CREATION.md) | Need guidance on when to ask vs create issues, issue quality, or design vs acceptance criteria |
| [references/STATIC_DATA.md](references/STATIC_DATA.md) | Want to use bd for reference databases, glossaries, or static data instead of work tracking |
