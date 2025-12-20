#!/usr/bin/env python3
"""
Capture windows or screen to PNG files.

Usage:
    look.py [options] [output_path]
    look.py --list [--app NAME]

Options:
    --app NAME      Filter by application name (case-insensitive substring match)
    --title MATCH   Filter by window title (case-insensitive substring match)
    --list          List available windows instead of capturing
    --screen        Capture entire screen instead of a window
    --max-size PX   Resize so largest dimension is at most PX (default: 1568)
    --native        Skip resizing, keep native resolution

If no output path given, generates timestamped filename in current directory.

Examples:
    look.py                              # Capture frontmost window
    look.py --app Ghostty                # Capture Ghostty window
    look.py --title "LinkedIn"           # Capture window with LinkedIn in title
    look.py --screen                     # Capture entire screen
    look.py --list                       # List all windows
    look.py --list --app Chrome          # List Chrome windows
"""

import argparse
import os
import subprocess
import sys
from datetime import datetime

try:
    from Quartz import (
        CGWindowListCopyWindowInfo,
        kCGWindowListOptionAll,
        kCGWindowListOptionOnScreenOnly,
        kCGNullWindowID,
    )
except ImportError:
    print("Error: pyobjc-framework-Quartz required", file=sys.stderr)
    print("Install: pip install pyobjc-framework-Quartz", file=sys.stderr)
    sys.exit(1)


def get_windows(app_filter=None, title_filter=None, on_screen_only=False):
    """Get list of capturable windows using CGWindowList (no AppleScript)."""
    windows = []
    options = kCGWindowListOptionOnScreenOnly if on_screen_only else kCGWindowListOptionAll
    window_list = CGWindowListCopyWindowInfo(options, kCGNullWindowID)

    for window in window_list:
        owner = window.get('kCGWindowOwnerName', '')
        name = window.get('kCGWindowName', '')
        wid = window.get('kCGWindowNumber', 0)
        layer = window.get('kCGWindowLayer', 0)
        bounds = window.get('kCGWindowBounds', {})

        # Only main windows (layer 0) with reasonable size
        # Filter out small panels, popovers, web inspectors (min 600x400)
        width = bounds.get('Width', 0)
        height = bounds.get('Height', 0)
        if layer == 0 and width >= 600 and height >= 400:
            # Apply filters
            if app_filter and app_filter.lower() not in owner.lower():
                continue
            if title_filter and title_filter.lower() not in name.lower():
                continue

            windows.append({
                'id': wid,
                'app': owner,
                'title': name or '(untitled)',
                'width': int(width),
                'height': int(height),
                'x': int(bounds.get('X', 0)),
                'y': int(bounds.get('Y', 0)),
            })

    return windows


def capture_screen(output_path, main_only=True):
    """Capture entire screen using screencapture."""
    cmd = ['screencapture', '-x']
    if main_only:
        cmd.append('-m')
    cmd.append(output_path)

    result = subprocess.run(cmd, capture_output=True, text=True)
    return result.returncode == 0


def capture_window(window_id, output_path):
    """Capture a specific window by ID using screencapture."""
    cmd = ['screencapture', '-x', '-o', f'-l{window_id}', output_path]
    result = subprocess.run(cmd, capture_output=True, text=True)
    return result.returncode == 0


def resize_image(path, max_size):
    """Resize image so largest dimension is at most max_size using sips."""
    cmd = ['sips', '--resampleHeightWidthMax', str(max_size), path, '--out', path]
    result = subprocess.run(cmd, capture_output=True, text=True)
    return result.returncode == 0


def generate_filename(prefix="screenshot"):
    """Generate timestamped filename."""
    timestamp = datetime.now().strftime("%Y-%m-%d-%H%M%S")
    return f"{timestamp}-{prefix}.png"


def main():
    parser = argparse.ArgumentParser(
        description='Capture windows or screen to PNG files',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__
    )
    parser.add_argument('output', nargs='?', help='Output PNG path (auto-generated if omitted)')
    parser.add_argument('--app', help='Filter by application name')
    parser.add_argument('--title', help='Filter by window title')
    parser.add_argument('--list', action='store_true', help='List available windows')
    parser.add_argument('--screen', action='store_true', help='Capture entire screen')
    parser.add_argument('--max-size', type=int, default=1568, help='Max dimension in pixels (default: 1568)')
    parser.add_argument('--native', action='store_true', help='Keep native resolution (skip resize)')

    args = parser.parse_args()

    # List mode
    if args.list:
        windows = get_windows(app_filter=args.app, title_filter=args.title)
        if not windows:
            filter_desc = []
            if args.app:
                filter_desc.append(f"app='{args.app}'")
            if args.title:
                filter_desc.append(f"title='{args.title}'")
            print(f"No windows found" + (f" matching {', '.join(filter_desc)}" if filter_desc else ""))
            return 1

        print(f"Available windows ({len(windows)}):")
        for w in windows:
            print(f"  [{w['id']}] {w['app']}: {w['title']} ({w['width']}x{w['height']})")
        return 0

    # Generate output path if not provided
    output_path = args.output
    if not output_path:
        prefix = "screen" if args.screen else (args.app or args.title or "window")
        # Sanitize prefix for filename
        prefix = "".join(c if c.isalnum() or c in '-_' else '-' for c in prefix.lower())
        output_path = generate_filename(prefix)

    # Ensure output directory exists
    output_dir = os.path.dirname(os.path.abspath(output_path))
    if output_dir:
        os.makedirs(output_dir, exist_ok=True)

    # Capture
    if args.screen:
        print(f"Capturing screen...")
        success = capture_screen(output_path)
        if not success:
            print("Failed to capture screen", file=sys.stderr)
            return 1
    else:
        # Find target window
        windows = get_windows(app_filter=args.app, title_filter=args.title)
        if not windows:
            filter_desc = []
            if args.app:
                filter_desc.append(f"app='{args.app}'")
            if args.title:
                filter_desc.append(f"title='{args.title}'")
            print(f"No windows found" + (f" matching {', '.join(filter_desc)}" if filter_desc else ""))
            return 1

        # Take first match (could add interactive selection later)
        window = windows[0]
        print(f"Capturing: {window['app']} - {window['title']} ({window['width']}x{window['height']})")

        success = capture_window(window['id'], output_path)
        if not success:
            print("Failed to capture window - check Screen Recording permissions", file=sys.stderr)
            return 1

    # Resize if needed
    if not args.native and args.max_size:
        resize_image(output_path, args.max_size)

    # Report result
    size = os.path.getsize(output_path)
    print(f"Saved: {output_path} ({size:,} bytes)")
    return 0


if __name__ == '__main__':
    sys.exit(main())
