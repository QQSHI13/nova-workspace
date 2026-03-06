# Lessons Learned

This file captures insights, mistakes, and patterns discovered during work. Review weekly and update MEMORY.md with the most valuable learnings.

---

## Technical Lessons

### WSL/Windows Integration
- **Lesson**: Cannot directly write to Windows Desktop from WSL due to permission boundaries
- **Impact**: PowerShell scripts from WSL paths fail due to execution policy
- **Solution**: Provide manual copy-paste instructions rather than automated scripts when crossing WSL/Windows boundary
- **Source**: 2026-02-28 WSL wipe update workflow
- **Cross-reference**: FRESH-START-TODO.md sync issues

### Mobile Web Development
- **Lesson**: `dblclick` events don't work on touch devices
- **Fix**: Use `touchend` with double-tap detection (300ms threshold)
- **Also**: Disable keyboard shortcuts on mobile - they confuse users and don't apply
- **Detection**: Use `'ontouchstart' in window` or User-Agent for mobile-specific features
- **Source**: 2026-03-02 Flow timer mobile fixes

### GitHub Pages Deployment
- **Lesson**: Network issues can block git pushes at critical moments
- **Workaround**: Have manual editing instructions ready for urgent fixes
- **Pattern**: When fixing urgent bugs, prepare both automated and manual solutions
- **Source**: 2026-03-03 QuickShare maxlength fix

### Input Validation Gotchas
- **Lesson**: HTML `maxlength` attributes can break real-world usage
- **Example**: PeerJS IDs can exceed 15 characters, breaking the receive flow
- **Rule**: Don't restrict input length without understanding the data format
- **Source**: 2026-03-03 QuickShare fix

---

## Project Management Lessons

### Project Lifecycle
- **Pattern**: Demos → Official Projects → Maintenance
- **Trigger**: When a tool gets regular use and has a clean URL, promote from `demos/` to `projects/`
- **Checklist**: Update MEMORY.md, GitHub profile README, and main homepage
- **Source**: 2026-03-03 JWT Decoder and CSV to JSON promotion

### Crash Recovery Pattern
- **System**: Use `active-tasks.md` as a "save game" file
- **Format**: Task, Status, Subagent session key, Timestamps, Success criteria
- **Benefit**: Can resume work autonomously after restart
- **Source**: AGENTS.md workflow documentation

### Subagent Orchestration
- **Pattern**: Spawn subagents for parallel research tasks
- **Tracking**: Always record session keys for audit trail
- **Result**: Pi dashboard research completed in ~4 min (vs ~8 min sequential)
- **Source**: 2026-03-04 Pi research tasks

---

## EvoMap/Distributed Systems

### Task System Realities
- **Lesson**: Solutions can be rejected as "duplicate assets"
- **Implication**: Need to create genuinely novel solutions, not just working ones
- **Quarantine**: All submissions go through safety review (standard procedure)
- **Source**: 2026-03-03 EvoMap rollback task submission

### Worker Registration
- **Benefit**: Registering as worker enables passive task assignments
- **Config**: Set domains (javascript, nodejs, web, automation) and max load
- **Heartbeat**: Tasks arrive via heartbeat polling
- **Source**: 2026-03-03 EvoMap worker registration

---

## Browser Architecture Insights

### Universal Protocol Browser Design
- **Approach**: Use Thorium (optimized Chromium) as base
- **Methods**: Extension-based (easiest), Fork (full control), Hybrid proxy (recommended)
- **Key insight**: Thorium gives 8-38% performance boost + Pi optimization
- **Source**: 2026-03-04 browser architecture discussion

### Protocol Handler Pattern
- **URL schemes**: `ipfs://`, `gemini://`, `hyper://`, `tor://`
- **Transformation**: Convert to HTML via template system, render in Blink
- **Security**: Each protocol isolated, declarative permissions
- **Source**: Universal browser architecture design session

---

## User Experience Patterns

### Tool Design Philosophy
- **Pattern**: Simple, focused tools > complex suites
- **Examples**: Flow (just timer), JWT Decoder (just decode), CSV→JSON (just convert)
- **Result**: Easier to maintain, clearer user value proposition
- **Source**: Multiple tool deployments (2026-03-01 to 2026-03-04)

### Homepage Design Evolution
- **v1**: Emoji grid - too cluttered
- **v2**: Big logo + cards - logo was distracting
- **v3**: Text header + dot accent + clean cards - winner
- **Lesson**: Iteration based on user feedback beats initial design
- **Source**: 2026-03-03 homepage redesign session

---

## Meta-Lessons (About This System)

### What Makes Memory Useful
1. **Actionable**: Lessons should change future behavior
2. **Searchable**: Use clear categories and cross-references
3. **Fresh**: Review weekly, archive outdated lessons
4. **Linked**: Connect to source files and related concepts

### When to Document
- **Always**: Workarounds for technical limitations
- **Always**: User feedback that changes design
- **Often**: Patterns that repeat across projects
- **Sometimes**: Interesting but one-off technical discoveries

### When NOT to Document
- One-time commands with no broader applicability
- Transient issues (network hiccups, temporary outages)
- Information easily found in official docs

---

## Review Log

| Date | Reviewer | Actions Taken |
|------|----------|---------------|
| 2026-03-05 | System | Initial creation from last 7 days of memory files |

---

*Next review: 2026-03-12*
