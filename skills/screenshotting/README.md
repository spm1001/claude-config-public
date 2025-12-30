# Screenshotting Skill

Take screenshots to see what's on screen. Enables Claude to verify visual state, capture documentation, and see what the user sees.

## Platform

**macOS only** — Uses macOS Quartz APIs and `screencapture` command.

## Dependencies

```bash
# Required: pyobjc-framework-Quartz
pip install pyobjc-framework-Quartz

# Or add to your Claude skill venv
~/.claude/.venv/bin/pip install pyobjc-framework-Quartz
```

## Permissions

Requires **Screen Recording** permission in System Preferences > Privacy & Security.

Grant permission to your terminal app (Ghostty, Terminal, iTerm, etc.).

## Installation

```bash
# Copy to skills directory
cp -r screenshotting ~/.claude/skills/

# Or symlink
ln -s /path/to/claude-config-public/skills/screenshotting ~/.claude/skills/
```

## Usage

```bash
# Capture specific app window
~/.claude/skills/screenshotting/scripts/look.py --app Chrome

# Capture window by title match
~/.claude/skills/screenshotting/scripts/look.py --app Chrome --title "GitHub"

# Capture full screen
~/.claude/skills/screenshotting/scripts/look.py --screen

# List available windows
~/.claude/skills/screenshotting/scripts/look.py --list

# List windows grouped by category
~/.claude/skills/screenshotting/scripts/look.py --categories
```

## Why This Skill Matters

Claude can ask you "what do you see?" but that requires you to describe what's on screen. This skill lets Claude see for itself:

- **Proactive verification** — After uncertain CLI operations, capture to verify state
- **Documentation** — Capture steps in a workflow with persistent screenshots
- **Debugging** — See exactly what the user sees when something "looks wrong"
- **Reduced back-and-forth** — Instead of asking users to describe, just look
