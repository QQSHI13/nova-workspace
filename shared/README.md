# Shared Cross-Session State

This directory enables session synchronization between webchat and Feishu.

## Files

| File | Purpose |
|------|---------|
| `messages.md` | Shared message log (both directions) |
| `todos.md` | Unified todo list |
| `brain-state.json` | Current context, active tasks, decisions |
| `feishu-context.md` | Feishu-specific context (chat IDs, recent messages) |

## Usage

### From Webchat (this session)
Read/write these files directly. Feishu session checks them on wake.

### From Feishu
On heartbeat, read `brain-state.json` and `todos.md` to stay in sync.

## Protocol

**Last writer wins** — both sessions read before acting, write after acting.
Timestamp your entries to resolve conflicts.
