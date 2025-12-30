# Changelog

Notable changes to this config repo.

---

## 2025-12-30

**README rewrite for Claude-first consumption**
- Stripped marketing-speak and bold assertions
- Added "For Claude" section with dense technical guide
- Added gotchas, handoff paths, minimum viable adoption guidance
- Softer tone in PATTERNS.md opening

## 2025-12-30 (earlier)

**Major refresh**
- Replaced 6 old skills with 4 new ones:
  - `session-management/` (session-opening, session-grounding, session-closing)
  - `beads/` (multi-session issue tracking)
  - `screenshotting/` (macOS screenshot capture)
  - `github-cleanup/` (audit GitHub account)
- Added `commands/` directory with `/open`, `/ground`, `/close`
- Updated CLAUDE.md with ~130 lines of generalizable content
- Added `output-styles/thoughtful-partner.md`

## 2025-12-20

**Settings cleanup**
- Blanket permissions approach in settings.json
- Removed accumulated per-path permissions
- Added hooks: startup notification, end-of-session reminder, WebFetch warning
- Added status line config

## 2025-11-15

**Tiered auto-update system**
- `update-all.sh` with quick (<10s) and heavy (daily) tiers
- Git hook integration for automatic updates
- Local setup patterns in `setup-new-machine.sh`

## Earlier

- Web session initialization scripts (`web-init.sh`)
- Initial CLAUDE.md and settings templates
- Basic skills structure
