# Agent Health Dashboard

**Last Updated**: 2026-03-27 08:56 PM (Asia/Shanghai)  
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
| Memory System | ✅ OK | 2026-03-27 20:56 | Files updated |
| Sub-Agents | ✅ Available | — | Can spawn Claude Code CLI |
| WeChat | ✅ Active | — | Plugin installed |
| **MCP Servers** | ✅ **Active** | 2026-03-27 20:56 | See details below |

---

## MCP Servers

| Server | Status | Transport | URL/Command | Tools |
|--------|--------|-----------|-------------|-------|
| ✅ **everything** | **Online** | HTTP/SSE | `http://172.22.128.1:3000/sse` | Test/reference server |
| ✅ **filesystem** | **Online** | STDIO | `npx -y @modelcontextprotocol/server-filesystem` | 14 file tools |

**Setup Details:**
- everything server running on Windows (172.22.128.1:3000)
- Connected via HTTP/SSE transport
- filesystem server runs locally via STDIO
- Both configured in `~/.openclaw/openclaw.json`

---

## Active Tasks

| Task | Status | Started | Notes |
|------|--------|---------|-------|
| OpenClaw Stabilization | ✅ Complete | 2026-03-27 13:55 | Dev version rolled back to npm stable |
| Web Search Setup | ✅ Complete | 2026-03-27 15:41 | DuckDuckGo activated, Kimi CLI documented |
| Avatar Update | ✅ Complete | 2026-03-27 10:09 | Iron Golem → Fox |
| Memory Organization | ✅ Complete | 2026-03-27 16:30 | 2026-03-27.md created, files updated |
| **MCP Server Setup** | ✅ Complete | 2026-03-27 20:50 | everything + filesystem servers configured |

---

## Recent Activity

| Event | Time | Details |
|-------|------|---------|
| Dev Version Crash | 13:55 | Multiple "Gateway draining" errors |
| Rollback to Stable | 14:00 | Switched to npm install version |
| Avatar Rename | 15:10 | Iron_Golem_face.png → fox-avatar.png |
| IDENTITY.md Update | 15:12 | Avatar path updated |
| Kimi Search Test | 15:41 | 401/429 errors (separate API needed) |
| Kimi CLI Test | 16:09 | Successfully retrieved March 2025 AI news |
| DuckDuckGo Test | 16:14 | 5 results in 1.8 seconds, no API key |
| TOOLS.md Update | 16:17 | Documented both search methods |
| Browser Screenshot | 16:27 | Visual mode working (Chrome on Windows) |
| Memory Update | 16:30 | Created 2026-03-27.md, organized files |
| **MCP everything Server** | 20:50 | Configured HTTP server on Windows |
| **MCP Config Update** | 20:56 | Updated OpenClaw config with SSE URL |

---

## Configuration Status

| Config | Status | Last Updated |
|--------|--------|--------------|
| `~/.openclaw/openclaw.json` | ✅ Stable | 2026-03-27 (MCP servers added) |
| `IDENTITY.md` | ✅ Current | 2026-03-27 (fox avatar) |
| `TOOLS.md` | ✅ Current | 2026-03-27 (web search docs) |
| `SOUL.md` | ✅ Current | Unchanged |
| `AGENTS.md` | ✅ Current | Unchanged |
| `USER.md` | ✅ Current | Unchanged |

---

## Tool Availability

| Tool | Status | Notes |
|------|--------|-------|
| `web_search` | ✅ DuckDuckGo | Free, no API key |
| `web_fetch` | ✅ Active | Single page fetch |
| `browser` | ✅ Chrome | Windows MCP |
| `exec` | ✅ Active | Bash commands |
| `sessions_spawn` | ✅ Available | Can spawn Claude Code |
| `canvas` | ⚠️ Needs node | No paired device |
| `tts` | ✅ Available | Text to speech |
| `cron` | ✅ Available | Scheduled tasks |
| **MCP** | ✅ Active | everything + filesystem servers |

---

## Quick Stats

| Metric | Value |
|--------|-------|
| Schema Version | 2 |
| Daily Memory Files | 40 (+1 today) |
| Active Projects | 11 |
| Deployed Tools | 9 |
| GitHub Repos | 10 active |
| Web Search Provider | DuckDuckGo |
| Main Model | kimi-for-coding |
| Coding Sub-Agent | Claude Code CLI |
| **MCP Servers** | 2 active |

---

## Alerts

**None** — all systems nominal.

---

*Last updated: 2026-03-27 20:56 by Nova ☄️*