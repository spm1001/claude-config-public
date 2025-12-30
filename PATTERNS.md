# Development Patterns and Philosophy

Patterns I've found useful when working with Claude Code. Take what helps, ignore the rest.

---

## Side Quests as First-Class Work

**Core principle:** Side quests and exploratory tangents are valuable work, not distractions.

### Why This Matters

When you pivot from your main task to investigate something, fix a tool, or understand a concept, that's not wasted time. It's often the foundation work that makes the main task succeed.

**Example:** You're implementing a feature but notice your MCP server is broken.
- **Bad approach:** "Let's work around it and get back to the feature"
- **Good approach:** "Let's fix this first - it'll make the actual work better and faster"

### Patterns

**When you pivot to a side quest:**
- Treat it as the new primary focus
- Don't rush to "get back to the main task"
- The original task can wait - mark todos as pending
- Side quests often provide necessary context or tools

**Don't:**
- Keep reminding about incomplete todos from before
- Try to "efficiently resolve" the side quest to return
- Frame side quests as blockers to work around
- Feel pressure to maintain in_progress status on paused tasks

**Trust your judgment about what needs to happen first.** If you're insisting on fixing or understanding something before moving forward, there's usually a good reason.

---

## Security-First Mindset

**Core principle:** Treat every project as if it will become public.

### Never Commit Secrets

- No exceptions, no "just this once"
- Prevention over remediation - build security in from day one
- Create private repositories initially, make public only after security review

### Mandatory Project Setup

Before any development:

**1. Environment Variables:**
```bash
# Create .env.template documenting required vars
API_KEY=your-key-here
DATABASE_URL=postgresql://...

# Never commit actual .env files
echo ".env" >> .gitignore
```

**2. Comprehensive .gitignore:**
```gitignore
# Secrets
*.env*
credentials.json
token.json
*secret*
*key*

# Build artifacts
node_modules/
dist/
__pycache__/
.venv/

# IDE files
.idea/
.vscode/
*.swp
```

**3. Placeholder Values:**
- All documentation uses placeholders: `YOUR_API_KEY_HERE`
- Never include real credentials in any committed file
- Review every staged file before committing

### API Security Patterns

- Restrict API keys to minimum required permissions
- Use separate keys for dev/staging/prod
- Validate required environment variables at startup:

```python
def load_config():
    required = ['API_KEY', 'DATABASE_URL']
    missing = [k for k in required if k not in os.environ]
    if missing:
        raise ValueError(f"Missing required env vars: {missing}")
```

### If Secrets Are Accidentally Committed

**STOP all work immediately:**

1. Revoke compromised credentials at source
2. Clean git history (git filter-branch or filter-repo)
3. Force push cleaned history
4. Generate new credentials
5. Document incident and lessons learned

---

## Code Quality Standards

### Elegance Over Speed

**Prioritize proper foundations over quick fixes.** Rushed code creates technical debt that costs more time later.

**Signs you're rushing:**
- Copying code without understanding it
- Skipping tests "just this once"
- Hardcoding values that should be configurable
- Ignoring edge cases "for now"

**Better approach:**
- Understand the problem fully before coding
- Write tests alongside implementation
- Make code self-documenting
- Handle edge cases upfront

### Commit Granularity

**One logical change per commit.** Commits should tell a clear story.

**When to split commits:**
- Product vs byproduct: Feature work separate from config changes
- Different concerns: Refactoring separate from new features
- Different scope: Changes to different systems

**The "and also" smell:** If your commit message needs "and also," split it:
- ✗ "Add user auth **and also** update permissions"
- ✓ "Add user auth" + "Update permissions for user auth"

**Good commit message structure:**
```
First line: Clear, concise summary (50 chars)

Body: Why the change was made (the what is in the diff)
- Group related changes with bullets
- Reference issues when relevant
- Focus on intent, not mechanics
```

### Repository Naming

**Keep folder names in sync with GitHub repo names:**
- Reduces confusion when sharing paths
- Easier to find repos
- Consistent across machines and documentation

```bash
# Good: folder name matches repo name
~/Repos/my-project  ↔  github.com/user/my-project

# After renaming on GitHub:
gh repo rename NEW-NAME --repo OWNER/OLD-NAME
git remote set-url origin https://github.com/USER/NEW-NAME.git
```

---

## Session Management

### Crash Recovery Protocol

When session history is lost:

1. **Check git state:**
```bash
git status
git diff
git log -1 --stat
```

2. **Check issue tracker** (if using bd/beads):
```bash
bd ready
bd list --status in_progress
```

3. **Ask user:** "What were we working on when it crashed?"

4. **Summarize reconstruction** for confirmation before continuing

### Context Preservation

**For long-running work:**
- Update issue tracker with progress
- Document discoveries in resolution fields
- Keep notes field current with session context
- Commit frequently with descriptive messages

**At session end:**
- Close completed issues
- Update in-progress issues with current state
- Document blockers or next steps
- Leave clear breadcrumbs for future sessions

---

## Tool Usage Patterns

### When to Use What

**TodoWrite:**
- Single-session execution
- Linear task lists
- Straightforward implementation

**Issue tracker (bd/beads):**
- Multi-session projects
- Complex dependencies
- Knowledge work with fuzzy boundaries
- Strategic work needing structure

**The test:** If you'd struggle to resume after 2 weeks away → issue tracker. If you could pick it back up from markdown skim → markdown is fine.

### Exploration vs Implementation

**Exploration mode:**
- Use Task agents for open-ended searches
- Read multiple files speculatively
- Build mental model before acting

**Implementation mode:**
- Break work into clear phases
- Validate each step before proceeding
- Test as you go

### Filesystem Organization

**Keep clear separation:**
```
~/Repos/          # Git repositories (fast, local)
~/.claude/        # Claude Code config (version-controlled)
~/Documents/      # Working content (may be cloud-synced)
```

**Use absolute paths** when spanning zones to avoid confusion.

---

## Communication Patterns

### When to Explain

**Always explain:**
- User asks "why" or "how"
- Making architectural decisions
- User will need to maintain the solution
- Running non-trivial system commands

**Skip explanations for:**
- Routine operations
- Simple implementations
- When explicitly asked to "just do it"

### Structured Questions

**Use structured questions for 2+ options:**
- Present options with clear trade-offs
- Make implications explicit
- Let user make informed decisions

**Skip structure for single questions** - just ask directly.

### Tone

- Be direct and confident
- No excessive apologies
- Treat interaction as collaboration
- Skip excessive politeness
- Challenge approach when something seems off

---

## Automation Philosophy

### Trust the Operator

If you're running Claude Code, you've authorized it. Constant permission prompts add friction without security benefit. Pre-approve safe operations, maintain oversight for destructive ones.

### Automate the Boring Stuff

- Tool updates should happen automatically
- Config backups should be triggered by natural workflows (git push/pull)
- Cleanup should be self-maintaining

### Tiered Operations

**Quick (every trigger):**
- Lightweight checks (submodule updates, plugin refresh)
- Config backups if changed
- Artifact cleanup

**Heavy (throttled):**
- Package manager updates (brew, npm)
- Dependency synchronization
- Major version upgrades

This prevents wasting time on redundant expensive operations while keeping quick checks frequent.

---

These patterns evolve with experience. Adapt them to your workflow, discard what doesn't fit, and add what you discover.
