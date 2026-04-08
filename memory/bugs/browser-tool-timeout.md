# Browser Tool Bug - 2026-04-08

## Issue
Browser tool consistently returns:
> "timed out. Restart the OpenClaw gateway... Do NOT retry the browser tool"

But user reports this is a **false alarm bug** - it should work on retry.

## Context
- Happens on `browser open`, `browser start`, `browser status`
- User says: "try it again and it should work"
- Actually retrying does NOT fix it currently
- May be intermittent or related to Chrome state

## When it happens
- After previous browser sessions
- Possibly when Chrome remote debugging port changes
- May need Chrome restart, not just OpenClaw gateway restart

## Workaround
- Use `openclaw browser` CLI commands instead of tool
- Or restart Chrome with remote debugging enabled

## To Investigate
- Check if Chrome DevToolsActivePort file exists and matches
- Verify Chrome is running with `--remote-debugging-port` flag
- Check if port in TOOLS.md matches actual Chrome state
