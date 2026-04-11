# MEMORY.md - Nova's Long-Term Memory

## Quick Reference

| Key | Value |
|-----|-------|
| **Name** | QQ (public) / Cyrus (in-person only) |
| **Timezone** | Asia/Shanghai |
| **System** | Windows + native Ubuntu dual-boot |
| **Browser** | Thorium + Quark (no Chrome/Firefox) |
| **License** | GPL-3.0 for all projects |
| **Avatar** | 🦊 Fox visual, ☄️ Nova emoji |

---

## System Configuration

| Component | Status |
|-----------|--------|
| **Web Search** | DuckDuckGo (default), Kimi CLI (fallback) |
| **Models** | Kimi for Coding (main), Claude Code (sub-agents) |
| **Browser** | Chrome on Windows via MCP |
| **MCP Servers** | None — using native OpenClaw tools |
| **ACP** | ✅ Enabled — acpx backend, Claude default |
| **Exec Security** | `ask=off` + allowlist configured |
| **Session Lifetime** | 7 days (was 24 hours) |

---

## Active Projects (2)

| Project | Status | Location |
|---------|--------|----------|
| **Battery Panic (1%)** | 🔄 Design Phase | `projects/battery-panic/` |
| **Skylight Mod** | 🧪 Testing | `projects/skylight-mod/` - Fixed crash, awaiting test |

## Published Skills (ClawHub)

| Skill | Version | Description |
|-------|---------|-------------|
| **WinControl** | 1.0.0 | AI remote control for Windows - capture screenshots, control mouse/keyboard via HTTP API |

---

## Recently Completed (Last 30 Days)

| Date | Project | Notes |
|------|---------|-------|
| 2026-04-10 | **PayMate AI Wallet Report** ✅ | Tencent大作业 finalized — renamed from RelayWallet, fund float business model, ~970字 |
| 2026-04-09 | **CODE.md v1.0** ✅ | THE FINAL CODE — universal value system with emergency protocols |
| 2026-04-09 | **WinControl Skill** ✅ | Published to ClawHub (v1.0.0) — on-demand screenshot capture |
| 2026-04-08 | **AI钱包报告初稿** ✅ | RelayWallet AI concept, ~920字 |
| 2026-04-08 | **npm Global Consolidation** | All packages moved to `~/.npm-global/` |
| 2026-04-08 | **Session Config** | Lifetime extended: 24h → 7 days |
| 2026-04-09 | **WinControl Skill** ✅ | Published to ClawHub - Windows desktop automation via HTTP API |
| 2026-04-06 | **Desktop Remote Control** ✅ | Browser-based Win remote desktop at ~7 FPS |
| 2026-04-06 | **Tencent Camp Practice** | Exam scores: 73/100 → 82/100 (improvement!) |
| 2026-04-05 | **Skylight Mod Fix** | Fixed PlayerJoinMixin crash for 1.21.1 |
| 2026-04-03 | **Tencent Camp Transcripts** | Extracted 19/27 lessons, exam prep started |
| 2026-04-03 | **Workspace Cleanup** | Removed venv, node_modules, archive folders |
| 2026-04-01 | **Weixia Archived** | Pivoted from Weixia to Tencent Camp |
| 2026-04-01 | Exec Security Tuned | `ask=off` + allowlist configured |
| 2026-03-29 | **ACP Configuration** | Enabled acpx backend, Claude default agent |
| 2026-03-16 | **M5Timer** ⏱️ | Hardware Pomodoro complete! |
| 2026-03-13 | **QuickNotes Extension** | v0.0.2.0 published to Microsoft Store |

---

## Shipped Projects (Live)

### Web Tools
| Tool | URL | Tech |
|------|-----|------|
| **Flow** | https://qqshi13.github.io/flow/ | Pomodoro timer, PWA |
| **Tools Suite** | https://qqshi13.github.io/tools-suite/ | Developer utilities collection |
| **DropTransfer** | https://qqshi13.github.io/droptransfer/ | P2P file sharing (WebRTC) |
| **CollaBoard** | https://qqshi13.github.io/collaboard/ | Collaborative whiteboard |
| **LifeLab** | https://qqshi13.github.io/lifelab/ | Conway's Game of Life simulator |
| **Nova Site** | https://qqshi13.github.io/nova/ | Personal portfolio |

### Apps & Hardware
| Project | Status | Tech |
|---------|--------|------|
| **QuickNotes** | ✅ Microsoft Store v0.0.2.0 | VS Code Extension (C#/.NET) |
| **M5Timer** | ✅ Complete | ESP32 hardware Pomodoro |
| **atoms3-rainbow** | ✅ Complete | LED demo for AtomS3 Lite |
| **Desktop Remote** | ✅ Complete | Python + WebSocket remote control |

### In Development
| Project | Status | Notes |
|---------|--------|-------|
| **Skylight Mod** | 🧪 Testing | MC 1.21 Fabric mod, photography tools |
| **Battery Panic** | 📝 Design | Godot pixel art game |

---

## Important Rules

- **Credits**: Add "Nova ☄️" to every website
- **Name Usage**: "QQ" only in public/digital contexts
- **Communication**: Action over questions, deploy immediately
- **Quiet Hours**: 21:30-07:30 (no non-urgent messages)
- **Browser Etiquette**: Don't switch/focus tabs when using browser tools; check existing tabs first

---

## Archives

- **Full History**: See `memory/YYYY-MM-DD.md` files
- **Project Details**: See individual project READMEs
- **Health Status**: See `memory/health.md`

---

## Lessons & Insights

### Browser Automation
- **Don't switch tabs** when user already has relevant page open — it interrupts their flow
- Use `fn` with `kind: "evaluate"` for clicking elements that don't have stable accessibility refs
- Visual screenshot mode works for debugging UI issues

### Project Management
- **RelayWallet AI concept**: AI消费协商伙伴 — 让AI拥有小金库，跑完支付最后一棒
- **三层执行策略**: <¥80自动, ¥80-1000反问, >¥1000辩论

### VPN Strategy
- WARP doesn't guarantee US IP — routes through nearest Cloudflare datacenter
- Psiphon recommended as backup for GitHub/Google when main VPN fails
- Proton VPN free tier has unlimited data but limited locations

### Technical Notes
- npm global packages consolidated to `~/.npm-global/` for consistency
- Session lifetime extended to 7 days to reduce interruptions
- Windows node tested: camera ✅, canvas ✅, commands ✅

---

## Random Notes

- **Tech Purchase Planned**: 正点原子 T80 智能电烙铁 (upgraded from T65)
- **Game Idea**: "1%" — Energy anthology game (6 levels)
- **OpenFang**: Re-evaluated April 1, 2026 — Decision: Wait for v1.0
- **Tencent Camp**: 18 core lessons complete, AI Wallet report submitted

---

## Today's Activity (2026-04-08)

- **AI专属钱包报告定稿**: 完成腾讯大作业 — 接力钱包(RelayWallet AI)概念设计
  - 双层架构: 安全执行层 + 决策交互层
  - 三层执行策略动态调整
  - 约920字，符合≤1000字要求
- **npm全局整合**: 所有包迁移至 `~/.npm-global/`
- **会话配置更新**: 生命周期从24小时延长至7天
- **Windows节点测试**: Camera ✅, Canvas ✅, 命令执行 ✅

*Last updated: 2026-04-11 09:53 by Nova ☄️*
