---
name: crash-recovery
description: Reconstructs session context after crashes or context limit exhaustion by combining git state, issue tracker (bd), and user memory. Triggers on phrases like "session crashed", "lost history", "hit context limit", "context at zero", "what were we working on", or starting fresh after unexpected termination.
---

# Session Recovery Protocol

When session continuity is broken (crash or context limit), follow this protocol to reconstruct context and resume work smoothly.

## When to Use This Skill

**Use when:**
- Session crashed unexpectedly (lost history)
- Hit context limit (0% remaining)
- Starting fresh after termination
- User says "what were we working on"

**NOT for:**
- Normal session continuation (context still available)
- Intentional session end (user chose to stop)
- Switching topics within same session

## Two Recovery Scenarios

### Crash Recovery (History Lost)
- Session terminated unexpectedly
- Conversation history completely unavailable
- Need to reconstruct everything from artifacts

### Context Limit Recovery (Hit Zero)
- Reached 0% context remaining
- Previous session may still be visible in UI but can't continue
- Need to start fresh session and catch up

## Quick Start

**Goal:** Reconstruct what we were working on by combining git state, issue tracker, and user memory.

**Key insight:** Issue tracker fields (design/resolution/notes) act as a "lab notebook" - permanent record of investigation that survives crashes.

## Recovery Process

**Same steps for both scenarios** - the artifacts (git, issue tracker, user memory) are what matter, not the conversation history.

### 1. Assess Repository State

Check what work is in progress:

```bash
git status              # What's uncommitted? Work in progress?
git log -1 --stat       # What was last committed?
git diff                # What changed since last commit?
```

**Look for:**
- Uncommitted changes (staged or unstaged)
- Recently modified files
- Pattern of recent commits

### 2. Check Issue Tracker (if using bd)

If project has `.beads/` directory:

```bash
bd ready                # What issues are ready to work on?
bd list --status in_progress  # What was being worked on?
bd show <issue-id>      # Review design and context
```

**Why this helps:**
- Issues preserve investigation thinking
- Design field shows initial approach
- Notes field may have session handoff context
- Comments track decision history

### 3. Ask User for Context

Ask targeted questions based on scenario:

**After crash:**
- "Did you see any errors or take screenshots before the crash?"
- "What were we working on when it crashed?"
- "Were there any specific files or features in progress?"

**After hitting context limit:**
- "What were we working on in the previous session?"
- "Were we close to finishing something, or mid-stream?"
- "Any specific blockers or decisions you remember from last session?"

**Frame it as collaboration, not interrogation** - you're piecing together context together.

### 4. Reconstruct Context

Synthesize information from multiple sources:

- **Git diff** - Shows current work in progress
- **Git log** - Shows recent commit pattern and messages
- **Issue tracker** - Preserves investigation and design thinking
- **User memory** - Fills gaps and provides direction
- **CLAUDE.md** - Project context and architecture decisions
- **Open files** (if user mentions them) - Active working set

### 5. Resume Work

Before continuing:
1. **Summarize what you've reconstructed** - explain to user for confirmation
2. **Identify gaps** - clarify any ambiguities before proceeding
3. **Update issues** - if crash interrupted issue work, note recovery in comments

**Example summary:**
> "From what I can reconstruct:
> - Last commit: Added authentication middleware (30 mins ago)
> - Uncommitted: Half-finished session management code
> - Issue #15 in_progress: 'Implement user sessions'
> - You mentioned it crashed while running tests
>
> Should we continue with the session management implementation?"

## Best Practices

### Don't Assume
- Don't guess what was being worked on
- Don't assume user remembers everything
- Don't skip asking questions to "save time"

### Do Collaborate
- Show your reconstruction process
- Ask for confirmation before proceeding
- Update issues/todos to reflect current state

### Leverage Issue Tracker's Lab Notebook Pattern
- Read design field for initial hypothesis
- Check resolution field for discoveries
- Review comments for decision rationale
- This preserves thinking even when session history is lost

## Common Scenarios

### Crash During Feature Implementation
1. Check git diff for partial work
2. Check issue for original plan
3. Ask: "Were you happy with the direction, or were you reconsidering?"

### Crash During Investigation
1. Check issue design for hypothesis
2. Check git log for clues discovered
3. Ask: "What had we ruled out already?"

### Crash During Refactoring
1. Git diff shows mechanical changes
2. Ask: "What was the goal of this refactor?"
3. Confirm scope before continuing

## Recovery Quality Checklist

Before resuming work, verify:
- [ ] I understand what was being worked on
- [ ] I know why (the goal/motivation)
- [ ] I've identified any blockers or open questions
- [ ] User has confirmed my reconstruction
- [ ] Todos/issues reflect current state (not stale)
