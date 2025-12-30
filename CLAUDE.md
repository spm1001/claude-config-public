# Global CLAUDE.md

This file provides environment-specific context for Claude Code when working on any project.

**Note:** Behavioral preferences (communication style, proactiveness, tone) can be configured separately in output styles. This file focuses on environment organization, tool configuration, and technical context.

## Commands and Skills Architecture

- **Commands** (`~/.claude/commands/*.md`) are slash-command entry points
- **Skills** (`~/.claude/skills/*/SKILL.md`) contain the actual implementation
- Commands should explicitly invoke skills: "**Invoke the `skill-name` skill**"
- This makes the link discoverable when reviewing either file

### Skill/Config Reload Pattern

**Changes to SKILL.md, CLAUDE.md, or other config files don't take effect until the session reloads.**

Skills are loaded into context at session start. If you edit a skill during a session:
- The file on disk has changed
- But the current session still has the OLD version loaded
- Testing the new code requires a harness reload

**When to suggest reload:**
- After editing any SKILL.md file
- After modifying ~/.claude/CLAUDE.md or project CLAUDE.md
- Before testing changes to commands or hooks

**How to reload:**
- `/exit` then `claude` (fresh session)
- `/exit` then `claude -c` (continue conversation with fresh harness)
- `/exit` then `claude -r "session name"` (resume named session with fresh harness)

**Action:** When you've edited a skill or config, proactively tell the user: "This needs a harness reload to take effect."

### Official Examples Reference

When building hooks, plugins, commands, or agents, check the official Claude Code repo for examples:
- **Repository:** https://github.com/anthropics/claude-code
- **Plugins:** `plugins/` — 15+ official plugins with full source (hooks, commands, agents, skills)
- **Hook examples:** `examples/hooks/` — Reference implementations

Use WebFetch or browse directly when you need implementation patterns.

## Two Claude Configurations

macOS has two separate Claude config directories:

| | **Claude Code** | **Claude Desktop** |
|---|---|---|
| **Location** | `~/.claude/` | `~/Library/Application Support/Claude/` |
| **Manages** | Skills, settings.json, CLAUDE.md, output styles | MCP servers for Desktop app |
| **Modified by** | This repo, `claude` CLI | Desktop app UI, direct file edit |

When modifying config from a Claude Code session, ensure you're editing the right location. Use `~/.claude/` paths for Code config.

## What This Config Adds

The Claude Code system prompt handles: tool usage, git workflows, task management, plan mode, basic security, skills loading, and output styles.

**This config focuses on what the system prompt doesn't know:**
- Your specific filesystem zones and MCP setup
- Working style philosophy (side quests, foundations over speed)
- Domain-specific workflows (issue tracking, file organization)
- Integration points (skills, crash recovery)
- Security policies beyond the basics

## Development Philosophy

### Side Quests and Exploration

Side quests and exploratory tangents are valuable work, not distractions.

**Trust user judgment about what needs to happen first:**
- If they're insisting on fixing/understanding something before moving forward, there's usually a good reason
- Example: Fixing a broken MCP server that provides API documentation before starting to code
  - You might see: "This is blocking us, let's skip it and work around it"
  - They see: "This will make the actual work much better and faster"
- **Prioritize elegance and proper foundations over speed**

**When pivoting to a side quest:**
- Treat it as the new primary focus, not a distraction to minimize
- Don't rush to "get back to the main task"
- The original task can wait; mark todos as pending if needed
- Side quests often provide necessary context, tools, or understanding for better work later
- Examples: "How does X work?", "Let's fix this tool first", "Help me understand this concept"

**Don't:**
- Keep reminding about incomplete todos from before the side quest
- Try to "efficiently resolve" the side quest to return to the original task
- Frame side quests as blockers or distractions to work around
- Feel pressure to maintain in_progress status on paused tasks
- Push to skip foundation work in favor of "getting started"

**Side quests are first-class work.**

### Reading Documentation Properly

**WebFetch returns AI summaries, not raw content.** When exploring documentation or wikis:
- WebFetch sends the page to a small model and returns a summary - you're reading a book report, not the book
- For actual documentation, use `curl` via Bash to get raw content and read it yourself
- Summaries miss nuance, edge cases, and the "gotchas" that matter most

**When to use which:**
- **WebFetch**: Quick check if a page exists, get a rough overview
- **curl + read**: Actually understanding documentation, finding specific details, learning from wikis

### Git Commits

**Commits should be in logical units**, not one giant commit at the end.

- Group related changes together (e.g., "add feature X" not "add feature X + fix typo in unrelated file + update deps")
- Each commit should be coherent and reviewable on its own
- Write descriptive commit messages that explain the "why" not just the "what"
- When doing multi-step work, commit after each logical milestone

**Don't batch everything into one commit** just because it's convenient. The git history is documentation.

### Testing Documentation for LLM Robustness

When documenting intentional decisions (ADRs, design docs), test effectiveness by spawning subagents with adversarial prompts:

- Use "fix mode" prompts: "clean this up", "dedupe that", "fix this warning"
- Check if agents find and respect the documentation
- If they don't, add inline references at the code site
- Iterate: test → find gaps → harden → test again

### Background Agents: Stay Talkative

**CRITICAL: When spawning multiple agents, use `run_in_background: true` to stay responsive.**

Silent pauses while agents run are confusing and frustrating. The correct pattern is:

```python
# ✅ CORRECT: Background agents
Task(
    subagent_type="general-purpose",
    prompt="...",
    description="...",
    run_in_background=True  # Stay responsive!
)

# ❌ WRONG: Synchronous agents
Task(
    subagent_type="general-purpose",
    prompt="...",
    description="..."
)  # Goes silent until complete
```

**The pattern:**
1. Spawn agents with `run_in_background=True`
2. Immediately respond: "Launched N agents (IDs: ...), running in background"
3. Stay responsive and conversational while they work
4. Use `TaskOutput` to check progress or wait for completion
5. Report results as they come in

**When to use background agents:**
- Multiple test scenarios running in parallel
- Long-running research tasks
- Any parallel work where blocking isn't necessary
- When user explicitly expects continued interaction

**When synchronous is okay:**
- Single, quick agent that completes in seconds
- User explicitly wants to wait for result
- Next step absolutely requires agent output

**Key insight:** Background agents aren't just about performance - they're about maintaining conversational flow and user trust.

### Open Files in Apps Proactively

Use `open -a "App Name" /path/to/file` to open files in the appropriate application. This bypasses significant friction for the human:

1. Open Finder (or Go > Go To Folder for hidden dirs like `~/.claude`)
2. Navigate to folder
3. Find file
4. Open in preferred app (not always the default)

**When to do this proactively:**
- User needs to **review** something: Large markdown doc that flew past in CLI, generated config
- User needs to **edit** something: `.env` file for API keys, YAML config, credentials
- User needs to **reference** something: Documentation while working, checklist to follow along
- You just created/updated a significant file and user will want to see it

**Examples:**
```bash
open -a "Sublime Text" ~/.claude/skills/my-skill/SKILL.md  # Edit a skill
open -a "Visual Studio Code" /path/to/.env                 # Add API keys
open /path/to/file                                         # Default app if unsure
```

Don't wait to be asked. If the user would benefit from having a file open, just do it.

### Approaching Closure

**Concrete triggers — when you notice ANY of these, prompt the reflection:**
- User says "let's wrap up", "almost done", "one more thing"
- You've completed the main task and are about to summarize
- TodoWrite is nearly empty (1-2 items left)
- User mentions time/context ("running low", "before we close")

**The prompt:** "Before we close — what haven't we done? What might we have missed?"

**Why this matters:** By the time /close runs, context is exhausted. This question works better with juice left to act on the answers.

**Don't be vague.** "Any final thoughts?" is weak. "What did we miss?" is specific.

### Accessibility for the Agent Era

**Core framework for content system design.** When building any system that stores or serves content, design for the whole principal matrix, not just one cell:

|  | **Self** | **Other** |
|---|---|---|
| **Human** | Me reading/editing | Colleagues reading |
| **Machine** | My Claude, my scripts | Their Gemini, shared artifacts |

**Key insight:** Agents inherit identity context. When a colleague's Gemini queries content, it runs as them - seeing what they see, blocked from what they can't access. This is different from infrastructure (crawlers, indexes) which see everything.

**Design implications:**
1. **Separate store from view** - Content lives in canonical store, multiple views serve different principals
2. **Auth-aware placement** - Content's location determines which agents can reach it (Workspace Gemini can see Drive, not SSO-protected wikis)
3. **Don't bifurcate, multiply views** - One source, multiple access paths (Markdown in Git → static site for humans → connector for agents)
4. **Design for all four cells** - The "other's machine" cell is the one we forget, and it's increasingly important

**The elegance criterion:** Solutions that serve multiple principals without separate paths are better than per-principal infrastructure.

## Filesystem Zones

Organize your development environment into distinct zones, each serving a different purpose:

### `~/Projects/` or `~/Repos/` - Development (Local)
- Git repositories for code and tools
- MCP servers, custom scripts, utilities
- **Never cloud-synced** - local, fast, version-controlled
- **Permissions configured** - Claude Code has read access via `settings.local.json`

### `~/.claude/` - Claude Code Configuration (Local, Version-Controlled)
- Global preferences: `CLAUDE.md`
- Settings: `settings.json`
- Custom Skills: `skills/`
- **Tracked in git** for portability across machines
- **Session data excluded** - history, todos, projects ignored via .gitignore

### `~/Documents/Work/` or Cloud Storage - Content (Cloud-Synced)
- Knowledge work (documents, notes, spreadsheets)
- Inputs and outputs of actual work
- **Cloud-synced** via Google Drive, Dropbox, or iCloud
- **May have project CLAUDE.md** with environment context

### Key Principle: Separation of Concerns
- **Tools** (~/Projects) build and access **content** (Documents/Cloud)
- **Config** (~/.claude) teaches Claude how to use the tools
- They reference each other but remain separate
- Use absolute paths when spanning zones

## MCP Server Configuration

MCP servers are registered globally via `claude mcp add --scope user` and load for all projects.

**Storage:** Global MCPs are stored in `~/.claude.json`, not `~/.claude/settings.json`.

### Per-Project Configuration

**NOTE:** Claude Code does not currently support per-project MCP filtering. All globally-registered MCPs load for every project.

**Available workarounds:**
1. **Global toggle:** Use `claude mcp remove <server>` / `claude mcp add <server>` (affects all projects)
2. **Define per-project:** Don't use global registration, define each MCP in project's `.mcp.json`
3. **Accept token cost:** Live with all MCPs loading

### MCP Authentication Principle

When an MCP needs authentication (e.g., shows "Needs authentication"):
- **Prompt user to authenticate** - say "X MCP needs authentication. Please authenticate so I can continue."
- **Don't workaround** - don't guess at data, ask user to check manually, or skip the integration
- **Canonical data matters** - partial workarounds create drift between what's in the system and what Claude knows

### Skill Permission Quirk

The `Skill(*)` wildcard in `settings.json` permissions covers tool execution but **not** the content trust prompt ("Use slash command X?"). To auto-approve specific skills without prompting, add explicit entries:

```json
"allow": [
  "Skill(*)",
  "Skill(close)",
  "Skill(session-closing)"
]
```

The wildcard handles unknown skills; explicit entries bypass trust prompts for known ones.

### Issue Tracking with bd (beads)

If using bd for issue tracking, it works via CLI commands through the Bash tool:
- **CLI interface:** `bd` commands with `--json` flags for structured output
- **0 token overhead** - no MCP server loaded
- **Full functionality** - all operations available via CLI

**Common operations:**
- `bd ready --json` - Find unblocked work
- `bd show <id> --json` - View issue details
- `bd create "title" --type task` - Create issues
- `bd update <id> --status in_progress` - Update status
- `bd dep add <dependent> <prerequisite>` - Manage dependencies

See `skills/beads/` for complete usage patterns.

## Security: Accidental Commit Remediation

The system prompt covers basic security (never commit secrets, .gitignore, etc.). This section adds the specific remediation protocol when things go wrong.

**If secrets are accidentally committed - STOP all work and execute:**

1. **Revoke immediately** - Compromised credentials at source (cloud provider, service)
2. **Clean history** - Use `git filter-branch` or `git filter-repo` to remove
3. **Force push** - Push cleaned history to remote
4. **Regenerate** - New credentials with appropriate restrictions
5. **Test** - Verify new credentials in secure environment
6. **Document** - Incident and lessons learned for future prevention

## Repository Naming Convention

**Keep local folder names in sync with GitHub repository names.**

- Folder name = GitHub repo name (e.g., `~/Projects/my-tool` ↔ `github.com/user/my-tool`)
- When renaming locally, rename on GitHub too: `gh repo rename NEW-NAME --repo OWNER/OLD-NAME`
- Update local remote URL after rename: `git remote set-url origin https://github.com/USER/NEW-NAME.git`

**Why:** Reduces confusion when sharing paths, consistent across machines.

## Issue Tracking Philosophy

When to use persistent issue tracking (like bd) vs simple todo lists:

**Use persistent tracking when:**
- Multi-session projects with dependencies
- Knowledge work with fuzzy boundaries
- Strategic work that needs structure
- You'd struggle to resume after 2 weeks away

**Use TodoWrite when:**
- Single-session execution
- Linear task lists
- Straightforward implementation
- Could pick it back up from a markdown skim

### At Session Start
When working on projects with issue tracking:
- **Always check for ready work** automatically when starting
- Tell user: "I can see X items ready to work on" and summarize them
- This gives shared context immediately

### Creating New Issues
- **Ask first** for knowledge work - task boundaries are fuzzy and need discussion
- Creating issues helps clarify scope and think through problem structure
- For clear-cut tasks discovered during work, can create directly
- When in doubt, discuss the issue structure first

### Updating Status
- **Keep tracker updated** as you work (mark in_progress, close when done)
- Closed issues stay in the database - they're not deleted, just marked complete
- This maintains project history and shows what was learned

## Documentation as Session Memory

Project CLAUDE.md files are crash-resistant memory. Conversation history is ephemeral.

**Update CLAUDE.md during the session, not just at closedown:**
- When you discover something important (architectural insight, gotcha, key decision), capture it immediately
- Don't wait for closedown - sessions can crash, context can exhaust
- The test: If this session dies right now, would a future Claude know what we learned?

**What belongs in project CLAUDE.md:**
- Current deployment state (what's running, what's not)
- Key technical decisions and why
- Gotchas discovered during implementation
- "Next phase" context for future sessions

**What doesn't belong:**
- Session-specific todos (use TodoWrite)
- Detailed implementation plans (use issue tracker)
- Historical narrative (close issues with resolution notes instead)

## Python Environment Management

**Use `uv` for all Python virtual environments and package management.**

- Fast (10-100x faster than pip)
- Modern tooling from Astral (makers of Ruff)
- Handles virtual environments automatically
- Compatible with standard pyproject.toml

**Global Claude Code venv:** `~/.claude/.venv/`
- Contains dependencies for Claude Skills (pypdf, pillow, markitdown, etc.)
- Use when running skill scripts: `~/.claude/.venv/bin/python script.py`

**Common commands:**
```bash
uv sync                          # Install dependencies
uv add package-name              # Add new dependency
uv run python script.py          # Run with project dependencies
uv venv                          # Create venv (if needed manually)

# For skill dependencies (global venv)
~/.claude/.venv/bin/pip install package-name
~/.claude/.venv/bin/python script.py
```

Unless a project specifically requires a different approach, always use `uv`.

## Crash Recovery Protocol

When Claude Code session crashes and history is lost:
1. Check `git status`, `git diff`, `git log -1 --stat`
2. Check issue tracker ready list and in-progress items (if using one)
3. Ask user: "What were we working on when it crashed?"
4. Summarize reconstruction for confirmation before continuing

**Session management:** See `skills/session-management/` for open/ground/close workflows that help prevent context loss.

## Inter-Session Memory Architecture

Claude's memory across sessions comes from multiple sources, each with a distinct purpose:

| Layer | Purpose | When to use |
|-------|---------|-------------|
| **Git commits** | Code changes + narrative | Always - history is documentation |
| **CLAUDE.md** | Persistent knowledge, decisions, gotchas | Things future Claude MUST know |
| **Issue tracker** | Work state, dependencies, session context | Multi-session work with structure |
| **Handoff files** | Session-to-session continuity | Claude-to-Claude message |

### The Continuity Stack

| Level | Layer | Scope | Persistence |
|-------|-------|-------|-------------|
| 1 | **Handoff** | Session→session, per-project | Overwritten each session close |
| 2 | **Local CLAUDE.md** | This project | Curated, durable |
| 3 | **Global CLAUDE.md** | All projects | Curated, durable |

**Key principle:** Update CLAUDE.md during the session, not just at close. Sessions can crash, context can exhaust. If this session dies right now, would a future Claude know what we learned?

---

## Your Working Style (Template)

_This section is a placeholder. Add notes about your personal working patterns, cognitive preferences, or communication style here._

Example sections you might add:
- **Decision-making approach** — How you prefer to make decisions (intuitive, analytical, or both)
- **Communication preferences** — How you like to receive information
- **Work patterns** — Iteration style, when you do your best thinking
