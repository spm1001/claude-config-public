# Recent Developments (November 2025)

This reference documents bd features added in November 2025 that significantly impact AI agent workflows.

**Last updated:** November 12, 2025 (bd v0.23.1)

---

## Quick Check: bd info --whats-new

**Instead of reading this file**, run `bd info --whats-new` for the most current information:

```bash
bd info --whats-new          # Human-readable
bd info --whats-new --json   # Machine-readable
```

This command shows the last 3 versions with workflow-impacting changes, avoiding the need to re-read documentation.

---

## November 2025 Highlights

### 1. Auto-Detection of Issue Prefix from Git History

**Commit:** `8f37904` (Nov 10, 2025)
**Impact:** High - Changes initialization behavior

**What changed:**
- `bd init` now reads existing JSONL first to extract prefix from first issue
- Falls back to directory folder name if no issues exist
- More robust than previous git-remote-only detection

**Why it matters:**
- Prevents prefix mismatches when re-initializing
- Aligns with "trust folder name defaults" philosophy
- Reduces need for manual `--prefix` specification

**Usage:**
```bash
bd init                    # Now smarter - checks JSONL first, then folder name
bd init --prefix custom    # Only use when auto-detection wrong
```

**Code reference:** `/cmd/bd/init.go` (readFirstIssueFromJSONL function)

---

### 2. bd info --whats-new (Agent-Specific Feature)

**Added:** v0.23.0+
**Impact:** Medium - Improves agent upgrade workflow

**What it is:**
Quick upgrade summaries designed specifically for AI agents, showing last 3 versions with workflow-impacting changes.

**Why it matters:**
- Avoids re-reading full CHANGELOG
- Designed for agent consumption (concise, workflow-focused)
- Weekly bd releases make this essential for staying current

**Usage:**
```bash
bd info --whats-new          # At session start after upgrade
bd info --whats-new --json   # For programmatic parsing
```

**Example output:**
```
v0.23.0 (2025-11-08):
  - Auto-invoke 3-way merge for JSONL conflicts
  - Add 'new' as alias for 'create' command
  - Add bd cleanup command for bulk deletion
```

**Workflow integration:**
Add to session start checklist as first step (skip if no upgrades).

---

### 3. bd hooks install (Embedded Git Hooks)

**Added:** v0.22.0+
**Impact:** Medium - Simplifies hook installation

**What changed:**
- Git hooks now embedded in bd CLI
- `bd hooks install` replaces old external install script
- `bd init --quiet` auto-installs without prompting

**Why it matters:**
- Easier setup for non-interactive environments (agents, CI/CD)
- Hooks stay updated with bd version
- No external dependencies

**Usage:**
```bash
bd hooks install             # Install/update hooks
bd init --quiet              # Auto-installs hooks without prompting
```

**What it installs:**
- post-merge: Auto-sync after git pull
- pre-push: Export JSONL before push
- merge driver: Intelligent 3-way JSONL merging

---

### 4. bd list One-Line Format

**Changed:** v0.22.0+
**Impact:** Low - Output format change

**What changed:**
- `bd list` now shows one line per issue (was multi-line)
- Use `--long` flag for old multi-line format

**Example:**
```bash
bd list                      # One line per issue (new default)
bd list --long               # Multi-line format (old default)
```

**Why it changed:**
- More compact output
- Easier to parse for agents
- Aligns with standard Unix tool conventions

---

### 5. Context Optimization for AI Agents

**Commit:** `f7e80dd` (Nov 2025)
**Impact:** Low - Performance improvement

**What changed:**
- MCP server optimizations for context window usage
- Better caching and request batching

**Why it matters:**
- Reduces token usage for MCP operations
- Improves responsiveness

**Note:** Transparent improvement - no workflow changes needed.

---

### 6. bd compact Command Fix

**Fixed:** `d9904a8` (Nov 2025)
**Impact:** Low - Bug fix

**What was broken:**
- `bd compact` failed with "SQLite DB needed" error when daemon running

**What was fixed:**
- Now uses direct mode for analyze/apply phases
- Daemon no longer blocks compact operations

---

### 7. Multi-Repo Support & Agent Mail

**Added:** v0.22.0+ (November 2025)
**Impact:** Medium - Advanced use cases

**What's new:**
- Single MCP server routes to per-project daemons
- Agent Mail integration for multi-workspace coordination
- Multi-repo patterns documented in AGENTS.md

**Why it matters:**
- Cleaner separation between projects
- Better for teams and OSS contributors
- Follows LSP (Language Server Protocol) architecture

**Resources:**
- See beads repo `/AGENTS.md` for multi-repo patterns
- See beads repo `/docs/MULTI_REPO_AGENTS.md` for configuration

---

### 8. Template Support for Issue Creation

**Added:** v0.21.8+ (November 2025)
**Impact:** Low - Quality of life

**What's new:**
- `bd create` supports templates
- Standardize issue structure across team

**Usage:**
```bash
bd create --template bug "Found crash in auth module"
```

---

### 9. Base36 Encoding for Issue IDs

**Changed:** GH #213 (November 2025)
**Impact:** Low - ID format change

**What changed:**
- Issue IDs now use Base36 encoding (was hex)
- Shorter, more compact IDs

**Example:**
- Old: `myproject-a1b2c3d4`
- New: `myproject-xk7m`

---

## Migration Notes

### From Pre-November Versions

**If upgrading from v0.21.x or earlier:**

1. **Restart daemon** after upgrade:
   ```bash
   bd daemon --stop
   bd daemon --start
   ```

2. **Update git hooks:**
   ```bash
   bd hooks install
   ```

3. **Check what's new:**
   ```bash
   bd info --whats-new
   ```

4. **Test prefix auto-detection:**
   ```bash
   # In a test directory
   bd init  # Should detect from folder name
   ```

---

## Skill Updates Needed

**This skill was updated on Nov 12, 2025 to reflect:**

- ✅ Auto-detection from git history (SKILL.md, CLI_BOOTSTRAP_ADMIN.md)
- ✅ `bd info --whats-new` command (SKILL.md, CLI_BOOTSTRAP_ADMIN.md)
- ✅ `bd hooks install` command (CLI_BOOTSTRAP_ADMIN.md)
- ✅ Session start checklist updated (SKILL.md)
- ✅ "Trust folder name defaults" philosophy (SKILL.md)

**Still TODO:**
- Document `bd list` one-line format change in examples
- Add multi-repo patterns (defer to AGENTS.md)
- Document template support

---

## Version Timeline

| Version | Date | Key Features |
|---------|------|--------------|
| v0.23.1 | Nov 9, 2025 | Parallel test fixes, auto-prefix detection |
| v0.23.0 | Nov 8, 2025 | Auto-merge JSONL conflicts, `bd cleanup` |
| v0.22.0 | Nov 5, 2025 | `bd merge`, multi-repo support, embedded hooks |
| v0.21.9 | Nov 5, 2025 | Pattern matching in `bd list`, date ranges |
| v0.21.8 | Nov 4, 2025 | Template support, Base36 IDs |

---

## Resources

**Official Documentation:**
- beads repo `/AGENTS.md` - AI agent guide (maintained by Steve Yegge)
- beads repo `/docs/MULTI_REPO_AGENTS.md` - Multi-repo patterns
- beads repo `/CHANGELOG.md` - Full version history

**Quick Commands:**
```bash
bd info --whats-new          # This replaces reading this file!
bd info --version            # Current installed version
bd hooks install             # Update hooks after upgrade
```

---

## When to Re-Read This File

**Don't re-read this file unless:**
- `bd info --whats-new` command doesn't exist (pre-v0.23.0)
- You need context on *why* a feature changed (design rationale)
- You're troubleshooting version-specific bugs

**Instead:**
- Run `bd info --whats-new` for current changes
- Check beads repo `/AGENTS.md` for official agent guide
- Use `bd --help` for command syntax
