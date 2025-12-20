---
name: looking
description: >
  Take screenshots to see what's on screen. Use when user says 'have a look',
  'can you see', 'what does it look like', 'check this', or 'it looks like'.
  Also use proactively to verify state after uncertain CLI operations (backgrounded
  processes, tool prompts, visual changes). Captures windows or full screen to files.
---

# Looking

Take screenshots to see what's on screen. Captures persist as files (unlike browsermcp snapshots which only exist in context).

## Quick Reference

```bash
# Capture specific app window
~/.claude/.venv/bin/python ~/.claude/skills/looking/scripts/look.py --app Ghostty

# Capture window by title match
~/.claude/.venv/bin/python ~/.claude/skills/looking/scripts/look.py --app Chrome --title "LinkedIn"

# Capture full screen
~/.claude/.venv/bin/python ~/.claude/skills/looking/scripts/look.py --screen

# List available windows
~/.claude/.venv/bin/python ~/.claude/skills/looking/scripts/look.py --list

# Native resolution (skip resize)
~/.claude/.venv/bin/python ~/.claude/skills/looking/scripts/look.py --app Safari --native
```

## When to Use

**Reactive (user asks):**
- "Have a look at this"
- "Can you see what's on screen?"
- "What does it look like?"
- "Check the browser"

**Proactive (verify state):**
- After uncertain CLI operations (did it background?)
- When tool prompt state is unclear
- After browsermcp actions when snapshot isn't enough
- To verify visual changes actually happened

**Documentation:**
- Capture steps in a workflow
- Before/after comparisons
- Bug evidence with screenshots

**When NOT to use:**
- For browser-only tasks where browsermcp snapshot suffices
- When you just need to describe what's visible (use your existing context)
- High-frequency captures that would clutter the directory

## Resolution Strategy

Default: 1568px max dimension (~1,600 tokens, optimal for API)

| Option | Tokens | Use case |
|--------|--------|----------|
| Default (1568px) | ~1,600 | Full detail, no resize penalty |
| `--max-size 735` | ~500 | Quick look, text readable |
| `--native` | varies | When original resolution needed |

**Why 1568px:** Images larger than this get resized server-side anyway. Pre-resizing avoids upload latency while getting the same visual fidelity.

## Output

If no output path given, generates timestamped filename in current directory:
```
2025-12-15-143022-chrome.png
```

With explicit path:
```bash
look.py --app Chrome /path/to/output.png
```

## How It Works

1. **Window enumeration:** Uses macOS CGWindowList API (pure Quartz, no AppleScript)
2. **Capture:** Uses `screencapture -l<windowid>` for windows, `screencapture -x` for screen
3. **Resize:** Uses `sips --resampleHeightWidthMax` for efficient scaling

**Key capability:** Can capture windows even when covered or minimized.

## Limitations

**Scrollback:** Only captures visible viewport. If content scrolled off screen, it won't be in the screenshot. Workaround: increase window size or pipe output to file.

**Multiple monitors:** Untested. `--screen` with `-m` flag captures main monitor only.

**Window selection:** Takes first match when multiple windows match filters. No "frontmost" heuristic yet.

## Integration with browsermcp

browsermcp's `browser_screenshot` injects images directly into context but doesn't persist them as files. Use this skill when you need:
- Screenshots that persist beyond the conversation
- Captures of non-browser apps
- Captures of windows behind the browser
- Files to upload to Drive or include in docs

## Permissions

Requires **Screen Recording** permission in System Preferences > Privacy & Security.

If capture fails with "check Screen Recording permissions", the user needs to grant permission to the terminal app (Ghostty, Terminal, iTerm, etc.).
