# Agent Health Dashboard

**Last Updated**: 2026-04-01 09:58 AM (Asia/Shanghai)  
**Agent**: Nova (main)  
**Session**: agent:main:main

---

## System Status

| Component | Status | Last Check | Notes |
|-----------|--------|------------|-------|
| OpenClaw Version | ✅ Stable (npm) | 2026-03-27 16:00 | Downgraded from dev version |
| Web Search | ✅ Active | 2026-03-27 16:14 | DuckDuckGo provider working |
| Kimi CLI | ✅ Active | 2026-03-27 16:09 | Deep research available |
| Browser Control | ✅ Active | 2026-03-27 16:27 | Chrome MCP connected |
| Memory System | ✅ OK | 2026-03-29 21:35 | Files updated |
| Sub-Agents | ✅ Available | — | Can spawn Claude Code CLI |
| **ACP** | ✅ **Enabled** | 2026-03-29 21:35 | acpx backend, Claude default |
| WeChat | ✅ Active | — | Plugin installed |
| **MCP Servers** | ✅ **None** | 2026-03-29 19:58 | Using native tools |
| **Cron Jobs** | ✅ Active | 2026-04-01 10:06 | OpenFang check scheduled May 1 |

---

## Active Tasks (Crash Recovery)

This section is the "save game" state. Read on every session start to resume work autonomously.

**Format:** Task | Status | Subagent | Started | Last Update | Success Criteria

### Current Tasks

*(none active)*

### Upcoming Tasks

| Task | Due | Priority | Notes |
|------|-----|----------|-------|
| Workspace Cleanup | When ready | LOW | ~700-800 MB recoverable |
| GitHub Repo Cleanup | Ongoing | MEDIUM | Archive old repos |

---

## MCP Servers

**Status**: No MCP servers configured — using native OpenClaw tools instead

**History**:
- 2026-03-27: Configured `everything` + `filesystem` servers
- 2026-03-29: Removed all servers (redundant with native tools)

---

## Recent Activity

| Event | Time | Details |
|-------|------|---------|
| **ACP Configuration** | 2026-03-29 21:35 | Enabled acpx backend, Claude default |
| **Session Cleanup** | 2026-03-29 21:20 | Archived 8+ sessions, fixed sessions.json |
| MCP Server Cleanup | 2026-03-29 | Removed github + filesystem servers |
| Blog Writing | 2026-03-29 | Weekly wrap-up blog post completed |
| Memory Update | 2026-03-29 | Distilled raw logs from March 20-28 |
| Workspace Cleanup | 2026-03-28 | Archived 9 files, reduced workspace by 76% |
| SSH Password Testing | 2026-03-28 | Documented in TOOLS.md |
| OpenClaw Install Job | 2026-03-27 | Earned ¥200 on client PC |

---

## Configuration Status

| Config | Status | Last Updated |
|--------|--------|--------------|
| `~/.openclaw/openclaw.json` | ✅ Stable | 2026-03-29 (ACP enabled) |
| `IDENTITY.md` | ✅ Current | 2026-03-27 (fox avatar) |
| `TOOLS.md` | ✅ Current | 2026-03-28 (SSH docs) |
| `SOUL.md` | ✅ Current | Unchanged |
| `AGENTS.md` | ✅ Current | 2026-03-29 (startup optimized) |
| `USER.md` | ✅ Current | Unchanged |

---

## Tool Availability

| Tool | Status | Notes |
|------|--------|-------|
| `web_search` | ✅ DuckDuckGo | Free, no API key |
| `web_fetch` | ✅ Active | Single page fetch |
| `browser` | ✅ Chrome | Windows MCP |
| `exec` | ✅ Active | `ask=off` + allowlist configured |
| `sessions_spawn` | ✅ Available | Can spawn Claude Code |
| `canvas` | ⚠️ Needs node | No paired device |
| `tts` | ✅ Available | Text to speech |
| `cron` | ✅ Available | Scheduled tasks |
| **ACP** | ✅ **Enabled** | `/acp spawn` works |

---

## Recent Activity

| Event | Time | Details |
|-------|------|---------|
| **Browser MCP** | 2026-04-01 09:58 | Reconnected, Tencent camp explored |
| **Exec Config** | 2026-04-01 08:27 | `ask=off` + allowlist configured |
| ACP Configuration | 2026-03-29 21:35 | Enabled acpx backend, Claude default |
| Session Cleanup | 2026-03-29 21:20 | Archived 8+ sessions, fixed sessions.json |

## Alerts

**None** — all systems nominal.

---

*Last updated: 2026-03-29 21:35 by Nova ☄️*