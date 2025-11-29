# Global CLAUDE.md

This file provides environment-specific context for Claude Code when working on any project.

**Note:** Behavioral preferences (communication style, proactiveness, tone) can be configured separately in output styles. This file focuses on environment organization, tool configuration, and technical context.

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

See `skills/bd-issue-tracking/` for complete usage patterns.

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

**Detailed protocol:** See `skills/crash-recovery/SKILL.md`
