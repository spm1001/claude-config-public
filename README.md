# Claude Code Public Configuration

Public subset of Claude Code configuration optimized for web sessions.

## What's Here

**Scripts:**
- `scripts/web-init.sh` - Initialization script for Claude Code web sessions
  - Installs beads CLI
  - Sets up environment
  - Shows ready work if repo has `.beads/`

**Skills:**
- `skills/bd-issue-tracking/` - Issue tracking with bd (beads)
  - MCP-first approach for complex workflows
  - CLI guidance for bootstrap and web environments
  - Decision framework for bd vs TodoWrite

## Using in Claude Code for Web

### Recommended: Environment Variable Pattern

Create a named environment in the web UI:

```
Name: Development
Network access: Trusted network access
Environment variables:
  WEBINIT=curl -fsSL https://raw.githubusercontent.com/spm1001/claude-config-public/main/scripts/web-init.sh | bash
```

**Then your opening prompt becomes:**
```
$WEBINIT

Then [your actual task]
```

### Alternative: Direct Curl

```
curl -fsSL https://raw.githubusercontent.com/spm1001/claude-config-public/main/scripts/web-init.sh | bash

Then [your actual task]
```

### What the Script Does

- Installs beads CLI via npm (if needed)
- Sets up environment variables
- Shows ready work if repo has `.beads/` directory
- Takes ~5-10 seconds per session
- Displays Claude Code version and session info

## About

This is a curated public subset of a larger private Claude Code configuration. It focuses on tools and patterns useful for web sessions where you need:
- Quick environment setup
- Issue tracking with beads
- Development workflow patterns

## Philosophy

- **Zero per-repo config** - Works with any repo immediately
- **Eliminates wheelspin** - Agent starts with context and tools
- **MCP-first** - Structured workflows where available
- **CLI fallback** - Works in web environments

## Related

- [beads](https://github.com/steveyegge/beads) - Issue tracker optimized for AI collaboration
- [Claude Code](https://claude.com/claude-code) - AI-powered development environment

## License

MIT
