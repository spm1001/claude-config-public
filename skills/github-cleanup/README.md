# GitHub Cleanup Skill

Progressive audit and cleanup of GitHub accounts. Audit-first with user approval before any destructive actions.

## Dependencies

- **gh CLI** — `brew install gh` or see https://cli.github.com/
- Must be authenticated: `gh auth status`

## What It Audits

- **Stale forks** — Forks with no custom changes (0 commits ahead)
- **Failing workflows** — Misconfigured GitHub Actions and CodeQL
- **Orphaned secrets** — Secrets not referenced in any workflow
- **Security configuration** — Dependabot, vulnerability alerts, code scanning

## Installation

```bash
# Copy to skills directory
cp -r github-cleanup ~/.claude/skills/

# Or symlink
ln -s /path/to/claude-config-public/skills/github-cleanup ~/.claude/skills/
```

## Usage

```
clean up my GitHub        # Full audit
quick check my GitHub     # Focus on obvious issues
check for stale forks     # Targeted audit
```

## Workflow

1. **Audit** — Scan all repos for issues
2. **Present** — Show findings with recommendations
3. **Approve** — User selects which actions to take
4. **Execute** — Perform approved cleanups
5. **Verify** — Confirm changes took effect

## Why Audit-First Matters

This skill **never deletes without approval**. The pattern is:
1. Gather all findings
2. Present consolidated summary
3. Use AskUserQuestion for explicit selection
4. Only then execute approved actions

This prevents accidents and gives users full visibility into what's happening to their account.

## Required Scopes

| Operation | Scope |
|-----------|-------|
| List repos, secrets | (default) |
| Delete repos | `delete_repo` — run `gh auth refresh -h github.com -s delete_repo` |
| Modify security | `security_events` |
