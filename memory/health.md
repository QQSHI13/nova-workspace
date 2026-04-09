# Agent Health Dashboard

**Last Updated**: 2026-04-09 12:38 PM (Asia/Shanghai)  
**Agent**: Nova (main)  
**Session**: agent:main:main  
**Status**: ✅ Active

---

## System Status

| Component | Status | Last Check | Notes |
|-----------|--------|------------|-------|
| OpenClaw Version | ✅ Stable (npm) | 2026-03-27 16:00 | Downgraded from dev version |
| Web Search | ✅ Active | 2026-03-27 16:14 | DuckDuckGo provider working |
| Kimi CLI | ✅ Active | 2026-03-27 16:09 | Deep research available |
| Browser Control | ✅ Active | 2026-03-27 16:27 | Chrome MCP connected |
| Memory System | ✅ OK | 2026-04-09 12:38 | Health.md updated |
| Sub-Agents | ✅ Available | — | **One-shot use only** (see notes below) |
| **ACP** | ✅ **Enabled** | 2026-03-29 21:35 | acpx backend, Claude default |
| WeChat | ✅ Active | — | Plugin installed |
| **MCP Servers** | ✅ **None** | 2026-03-29 19:58 | Using native tools |
| **Cron Jobs** | ✅ Active | 2026-04-08 22:12 | Git commit/push added to HEARTBEAT |
| **Session Lifetime** | ✅ Updated | 2026-04-08 12:24 | Extended: 24h → 7 days |

---

## ⚠️ Critical: Session Persistence Behavior

**Windows hibernation kills non-main sessions.** This is the observed behavior:

| Session Type | Persistence | Survives Hibernation? | Use Pattern |
|--------------|-------------|----------------------|-------------|
| `agent:main:main` | ✅ Permanent | ✅ Yes | Long-term state, orchestration |
| Sub-agents (`isolated`) | ❌ Temporary | ❌ No | One-shot tasks only |
| Thread sessions | ❌ Temporary | ❌ No | Immediate use, don't rely on persistence |

**Implications:**
- Sub-agents must complete work **immediately** and write results to disk
- Do not leave state in side sessions expecting to poll later
- Always write sub-agent results to `memory/subagent-results/` or git commit
- **This file (health.md) must be updated BEFORE spawning sub-agents** so we can recover if they vanish

---

## Active Tasks (Crash Recovery)

This section is the "save game" state. Read on every session start to resume work autonomously.

**Format:** Task | Status | Subagent | Started | Last Update | Success Criteria

### Current Tasks

*(none active — workspace synced to GitHub 2026-04-08)*

### Recent Completions (Last 24h)

| Task | Completed | Result | Notes |
|------|-----------|--------|-------|
| CODE.md finalized | 2026-04-09 13:21 | ✅ Complete | THE FINAL CODE v1.0 for all instances |
| Git commit/push | 2026-04-08 22:15 | ✅ Success | 635 files, commit `e42f1b0` |
| JDK cleanup | 2026-04-08 22:15 | ✅ Removed | 80MB .deb deleted from repo |
| HEARTBEAT.md update | 2026-04-08 22:12 | ✅ Added | Git commit/push task added |
| Workspace cleanup | 2026-04-08 22:12 | ✅ Done | Removed Zone.Identifier files |

### Upcoming Tasks

| Task | Due | Priority | Notes |
|------|-----|----------|-------|
| Skylight Mod test | When ready | MEDIUM | PlayerJoinMixin fix needs testing |
| GitHub Repo Cleanup | Ongoing | MEDIUM | Archive old repos |
| Battery Panic dev | When ready | LOW | Godot pixel art game |

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
| **Health.md Update** | 2026-04-09 12:38 | Added session persistence notes |
| **Git Push** | 2026-04-08 22:15 | Commit `e42f1b0`, removed JDK .deb |
| **Git Commit** | 2026-04-08 22:12 | 635 files changed, 10,937 insertions |
| **AI Wallet Report** | 2026-04-08 14:15 | Tencent大作业定稿 — 接力钱包(RelayWallet AI), ~920字 |
| **npm Consolidation** | 2026-04-08 12:30 | All packages moved to `~/.npm-global/` |
| **Session Config** | 2026-04-08 12:24 | Lifetime extended: 24h → 7 days |
| **Browser MCP** | 2026-04-01 09:58 | Reconnected, Tencent camp explored |
| **Exec Config** | 2026-04-01 08:27 | `ask=off` + allowlist configured |

---

## Configuration Status

| Config | Status | Last Updated |
|--------|--------|--------------|
| `~/.openclaw/openclaw.json` | ✅ Stable | 2026-03-29 (ACP enabled) |
| `IDENTITY.md` | ✅ Current | 2026-03-27 (fox avatar) |
| `TOOLS.md` | ✅ Current | 2026-04-08 (WinControl docs) |
| `SOUL.md` | ✅ Current | Unchanged |
| `AGENTS.md` | ✅ Current | 2026-03-29 (startup optimized) |
| `USER.md` | ✅ Current | 2026-04-08 |
| `HEARTBEAT.md` | ✅ Current | 2026-04-08 (git task added) |

---

## Tool Availability

| Tool | Status | Notes |
|------|--------|-------|
| `web_search` | ✅ DuckDuckGo | Free, no API key |
| `web_fetch` | ✅ Active | Single page fetch |
| `browser` | ✅ Chrome | Windows MCP |
| `exec` | ✅ Active | `ask=off` + allowlist configured |
| `sessions_spawn` | ✅ Available | **One-shot only** — see Session Persistence notes above |
| `canvas` | ⚠️ Needs node | No paired device |
| `tts` | ✅ Available | Text to speech |
| `cron` | ✅ Active | Scheduled tasks |
| **ACP** | ✅ **Enabled** | `/acp spawn` works |

---

## Sub-Agent Activity Log

Use this to track sub-agents before they potentially vanish.

| Sub-Agent | Task | Spawned | Status | Result Location |
|-----------|------|---------|--------|-----------------|
| *(none active)* | — | — | — | — |

**Rule**: When spawning a sub-agent, add a row here immediately. When it completes, move to "Recent Completions" above.

---

## Alerts

**None** — all systems nominal.

---

*Last updated: 2026-04-09 12:38 by Nova ☄️*
