# Web Init Script Usage

Two approaches for initializing bd in Claude Code web environments, depending on network timing issues.

## Option A: Fetch Script (Preferred when network is stable)

**Pros:** Clean separation, script updates automatically, easy to maintain
**Cons:** Fails if raw.githubusercontent.com blocked at boot time

```bash
# Set in web environment configuration
WEBINIT='curl -fsSL https://raw.githubusercontent.com/spm1001/claude-config-public/main/scripts/web-init.sh | bash'
```

**When this works:**
- Network allows raw.githubusercontent.com at container boot
- Can add retry logic to handle transient delays

**When this fails:**
- Web environment blocks external URLs during startup
- Network only becomes available after ~30 seconds

## Option B: Inline Commands (Workaround for network timing issues)

**Pros:** No network dependency, runs immediately, reliable
**Cons:** Must update environment variable when script changes, harder to maintain

```bash
# Set in web environment configuration (copy entire line)
WEBINIT='[ "$CLAUDE_CODE_REMOTE" = "true" ] && { echo "🌐 Initializing..."; command -v bd >/dev/null || { go install github.com/steveyegge/beads/cmd/bd@latest && cat > /usr/local/bin/bd <<'\''BDWRAP'\''
#!/bin/bash
exec /root/go/bin/bd "$@"
BDWRAP
chmod +x /usr/local/bin/bd && echo "✓ bd installed"; }; [ -d "$CLAUDE_PROJECT_DIR/.beads" ] && { [ -f "$CLAUDE_PROJECT_DIR/.beads/issues.jsonl" ] && [ ! -f "$CLAUDE_PROJECT_DIR/.beads/beads.db" ] && { PREFIX=$(head -1 "$CLAUDE_PROJECT_DIR/.beads/issues.jsonl" | grep -o "\"id\":\"[^-]*" | cut -d"\"" -f4); [ -n "$PREFIX" ] && { cd "$CLAUDE_PROJECT_DIR" && bd init "$PREFIX" --quiet 2>/dev/null; }; }; bd ready --limit 5 2>/dev/null || echo "📋 Beads repo detected"; }; echo "✅ Ready!"; }'
```

## What Each Approach Does

Both initialize the web environment identically:

1. **Check environment** - Only run if `$CLAUDE_CODE_REMOTE = true`
2. **Install bd** - Via `go install` if not present
3. **Create wrapper** - At `/usr/local/bin/bd` for PATH persistence
4. **Detect prefix** - Extract from existing `issues.jsonl` if present
5. **Initialize database** - Run `bd init <prefix>` to import JSONL
6. **Show ready work** - Display `bd ready --limit 5`

## Updating the Inline Version

If you modify `web-init.sh`, regenerate the inline version:

```bash
# Test the expanded version first
bash scripts/web-init-inline.sh

# Copy the one-liner from web-init-inline.sh (starts with "[ "$CLAUDE_CODE_REMOTE"...")
# Paste into web environment configuration as $WEBINIT value
```

## Testing in Web Environment

```bash
# Test network access timing
curl -I https://raw.githubusercontent.com/spm1001/claude-config-public/main/scripts/web-init.sh

# Test go install directly
go install github.com/steveyegge/beads/cmd/bd@latest

# Verify bd available
bd version
bd ready
```

## Troubleshooting

**"bd: command not found" after init:**
- Wrapper script failed - check `/usr/local/bin/bd` exists
- Verify `/root/go/bin/bd` installed (28MB)
- Try: `export PATH="$PATH:/root/go/bin"` then `bd version`

**Network errors during boot:**
- Switch to inline approach (Option B)
- Or add retry logic to Option A

**Prefix mismatch errors:**
- Check `head -1 .beads/issues.jsonl | grep -o '"id":"[^-]*'`
- Should match prefix used in repo
- Delete `.beads/beads.db` to force re-init

## Files

- **web-init.sh** - Full script with logging and error handling
- **web-init-inline.sh** - Contains both one-liner and expanded versions
- **WEB_INIT_USAGE.md** - This file
