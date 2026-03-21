# M5Timer ESP32 Project — Bug Analysis Report

**Date:** 2026-03-20
**Project:** M5Timer (`/home/qq/.openclaw/workspace/projects/M5Timer`)
**Files Analyzed:** src/main.cpp, src/buzzer.cpp, src/storage.cpp, src/sync.cpp, src/led.cpp, src/timer_logic.cpp, include/types.h, include/config.h, platformio.ini
**Total Bugs Found:** 14

---

## Summary Table

| ID | File | Lines | Description | Severity |
|---|---|---|---|---|
| BUG-01 | main.cpp | 208 | Negative `remainingSeconds` cast to `uint32_t` causes near-infinite sleep | High |
| BUG-02 | main.cpp | 92, 115 | Unsigned underflow in `remaining = INITIAL_MODE_SECONDS - elapsed` skips final countdown beep | High |
| BUG-03 | storage.cpp | 48–65 | `indexOf("break=")` matches inside `"longBreak="`, causing parser to read wrong field | High |
| BUG-04 | buzzer.cpp, types.h | 82, 48 | Local `tones[5]` oversized vs. `queue[4]` — mismatched sizes trap future developers | Medium |
| BUG-05 | main.cpp | 275–278 | Interrupted WORK sessions incorrectly increment `completedWorkSessions` | High |
| BUG-06 | main.cpp | 116 | `lastBeepSecond` static never reset on INITIAL mode re-entry | Medium |
| BUG-07 | main.cpp | 138–139 | `lastRTC`/`lastSecond` statics not reset on TIMER mode re-entry — causes time skip | Medium |
| BUG-08 | main.cpp, platformio.ini | 97, 217, L10 | `Serial.end()` conflicts with `ARDUINO_USB_CDC_ON_BOOT=1` build flag | Medium |
| BUG-09 | sync.cpp | 6, 25–28, 81 | Static `buffer` retains stale data across SYNC mode sessions; heap fragmentation from `+=` | Medium |
| BUG-10 | storage.cpp | 103–104 | No bounds check on `TimerMode` cast from flash — corrupt NVS yields invalid enum | Medium |
| BUG-11 | storage.cpp | 62–65 | Dependent on BUG-03: wrong substring extracted when `breakIdx` lands in `longBreak=` | High |
| BUG-12 | main.cpp | 222–226, 269 | `switchEntryTime` init to `0` risks false "already entered" detection on first SWITCH | Low |
| BUG-13 | main.cpp | 201–203 | `saveTimerState` called every second — excessive NVS flash write wear | Medium |
| BUG-14 | platformio.ini | 8 | `CORE_DEBUG_LEVEL=3` left enabled — adds overhead and verbose logging in production | Low |

---

## Detailed Bug Descriptions

---

### BUG-01: Integer Overflow — Negative `remainingSeconds` Cast to `uint32_t` Causes Near-Infinite Sleep

**File:** `src/main.cpp`, line 208
**Severity: High**

```cpp
uint32_t sleepMs = (uint32_t)g_timerState.remainingSeconds * 1000;
```

`g_timerState.remainingSeconds` is declared as `int`. If flash is corrupted or NVS is loaded with a negative value (compounded by BUG-10), casting a negative `int` to `uint32_t` produces a value near `2^32`. The resulting `sleepMs` will be enormous (~4 billion ms = ~49 days), causing the device to enter an effectively infinite light sleep with no recovery path except a hard power cycle.

The multiplication `(uint32_t)remainingSeconds * 1000` promotes `1000` to `uint32_t` via the cast, so even a value like `-1` becomes `4,294,966,296 * 1000` which wraps again (undefined behavior on overflow aside, it effectively means a very long or immediate wrong sleep).

**Suggested Fix:**
```cpp
if (g_timerState.remainingSeconds <= 0) return;
uint32_t sleepMs = (uint32_t)g_timerState.remainingSeconds * 1000UL;
const uint32_t MAX_SLEEP_MS = 3600000UL; // 1 hour max
if (sleepMs > MAX_SLEEP_MS) sleepMs = MAX_SLEEP_MS;
```

---

### BUG-02: Unsigned Underflow in Initial Mode Countdown Skips Final Beep

**File:** `src/main.cpp`, lines 92, 115
**Severity: High**

```cpp
unsigned long elapsed = (now - g_state.modeStartTime) / 1000;
unsigned long remaining = INITIAL_MODE_SECONDS - elapsed;  // line 115
```

Both `elapsed` and `remaining` are `unsigned long`. `INITIAL_MODE_SECONDS` is `4`. When `elapsed >= INITIAL_MODE_SECONDS` (e.g., `elapsed == 4`), `remaining = 4 - 4 = 0` is safe, but `elapsed == 5` gives `remaining = 4 - 5` which wraps to `0xFFFFFFFF...` (about 4 billion).

Line 118: `if ((int)remaining != lastBeepSecond && remaining <= 5)` — the wrapped value is enormous, so `remaining <= 5` is false, and the final countdown beep at `remaining == 0` is silently skipped on the loop iteration when elapsed first exceeds INITIAL_MODE_SECONDS.

**Suggested Fix:**
```cpp
if (elapsed < INITIAL_MODE_SECONDS) {
    unsigned long remaining = INITIAL_MODE_SECONDS - elapsed;
    // ... use remaining safely here
}
```

---

### BUG-03: `indexOf("break=")` Matches Inside `"longBreak="` — Wrong Field Parsed

**File:** `src/storage.cpp`, lines 48–65
**Severity: High**

```cpp
int breakIdx  = str.indexOf("break=");
int longIdx   = str.indexOf("longBreak=");
```

The substring `"longBreak="` contains `"break="` at offset 4. `str.indexOf("break=")` will always find the first occurrence of `"break="` in the string. In the canonical serialized form `"work=25,break=5,longBreak=15,..."`, `break=5` appears before `longBreak=`, so `breakIdx` happens to be correct. However:

1. If field order ever changes (e.g., after a refactor or protocol update), `breakIdx` will point inside `"longBreak="`, extracting garbage for `breakMinutes`.
2. Any future code path that produces `longBreak=` before `break=` will silently mis-parse settings.

This is a latent bug that is fragile to serialization order changes.

**Suggested Fix:** Anchor the search with the field separator:
```cpp
int breakIdx = str.indexOf(",break=");
if (breakIdx >= 0) breakIdx++; // skip the comma
// OR: split on ',' first, then split each token on '='
```

---

### BUG-04: Array Size Mismatch Between `tones[5]` and `queue[4]`

**File:** `src/buzzer.cpp` line 82, `include/types.h` line 48
**Severity: Medium**

```cpp
// buzzer.cpp
Tone tones[5];          // local array, 5 slots

// types.h
Tone queue[4];          // BuzzerState queue, 4 slots

// buzzer.cpp guard
if (count == 0 || count > 4) return;  // silently drops count==5
```

No sound currently uses 5 tones (max is 4), so this is not currently exploitable. However, the mismatch is a trap: if a developer adds a 5-tone sound, passes `count=5`, and copies all 5 tones into the local array, `playToneSequence` will silently drop it (`count > 4` returns early). If the guard were removed or missed, writing `queue[4]` is an out-of-bounds write.

**Suggested Fix:** Align sizes: change `Tone tones[5]` to `Tone tones[4]`, or increase `queue[4]` to `queue[5]`.

---

### BUG-05: Interrupted WORK Sessions Incorrectly Increment `completedWorkSessions`

**File:** `src/main.cpp`, lines 275–278
**Severity: High**

```cpp
if (g_state.completedFromMode == TimerMode::WORK && g_timerState.mode != TimerMode::WORK) {
    g_timerState.completedWorkSessions++;
}
```

This runs in `handleSwitchMode()` when the user *manually* selects a new mode. `completedFromMode` is set to the current running mode when the user enters SWITCH mode. If the user interrupted an in-progress WORK timer, `completedFromMode == WORK` is true, but the session was NOT completed — it was abandoned.

This incorrectly advances the Pomodoro session counter, eventually triggering a long break that was not earned, breaking the core Pomodoro logic.

**Suggested Fix:** Only increment on natural completion. Add a flag `bool sessionCompleted` to `GlobalState`, set it `true` only in `switchToNextModeFromCompleted()`, and check it here:
```cpp
if (g_state.completedFromMode == TimerMode::WORK
    && g_timerState.mode != TimerMode::WORK
    && g_state.sessionCompleted) {
    g_timerState.completedWorkSessions++;
    g_state.sessionCompleted = false;
}
```

---

### BUG-06: `lastBeepSecond` Static Never Reset on INITIAL Mode Re-Entry

**File:** `src/main.cpp`, lines 95–98, 116
**Severity: Medium**

```cpp
static bool serialEnded = false;
static int lastBeepSecond = -1;
```

`serialEnded` is explicitly reset to `false` at lines 133 and 292. However, `lastBeepSecond` is **never reset** when INITIAL mode is re-entered. On a subsequent entry to INITIAL mode, `lastBeepSecond` retains its final value from the previous run (typically `0` after the countdown completes). The countdown beep condition `lastBeepSecond != remaining` will fail to fire for any second where `remaining` happens to equal the stale `lastBeepSecond`.

**Suggested Fix:** Reset `lastBeepSecond = -1` in the INITIAL mode entry/reset path alongside `serialEnded = false`.

---

### BUG-07: Static RTC State Variables in `handleTimerMode()` Not Reset on Mode Re-Entry

**File:** `src/main.cpp`, lines 138–139
**Severity: Medium**

```cpp
static I2C_BM8563_TimeTypeDef lastRTC;
static uint8_t lastSecond = 255;
```

`lastSecond = 255` is the sentinel for "first call — initialize from current RTC." On the very first entry to TIMER mode, this correctly initializes `lastRTC` from the current hardware RTC. However, these `static` variables persist across ALL visits to TIMER mode.

When returning to TIMER mode from SWITCH or SYNC mode, `lastSecond` is not `255` — it holds the RTC second from when the device last left TIMER mode. On the next loop iteration, the elapsed time `diff` is computed between the current RTC time and the time at the end of the *previous* TIMER session. If time passed in the other modes (even a second or two), this `diff` causes the timer to "skip ahead" by that amount.

**Suggested Fix:** Add a `bool timerModeFirstEntry` field to `GlobalState`, set to `true` on TIMER mode entry. In `handleTimerMode()`, check this flag and reset `lastSecond = 255` when `true`, then clear the flag:
```cpp
if (g_state.timerModeFirstEntry) {
    lastSecond = 255;
    g_state.timerModeFirstEntry = false;
}
```

---

### BUG-08: `Serial.end()` Conflicts With `ARDUINO_USB_CDC_ON_BOOT=1` Build Flag

**File:** `src/main.cpp` lines 97, 217; `platformio.ini` line 10
**Severity: Medium**

```ini
build_flags = -DARDUINO_USB_CDC_ON_BOOT=1
```
```cpp
Serial.end();
```

`ARDUINO_USB_CDC_ON_BOOT=1` causes the ESP32 to automatically enumerate the USB CDC interface at boot. Calling `Serial.end()` on a USB CDC connection may cause the device to de-enumerate from the USB host, resetting the USB connection. This conflicts with the SYNC mode which depends on a stable USB CDC connection.

The intent ("serial only used in SYNC mode") contradicts the build flag ("auto-start USB CDC at boot"). This can result in missed SYNC opportunities or unreliable USB connectivity depending on host OS behavior.

**Suggested Fix:** Either:
- Remove `-DARDUINO_USB_CDC_ON_BOOT=1` if serial should be manually managed, OR
- Do not call `Serial.end()`; instead stop reading/writing but leave the USB interface up

---

### BUG-09: Static Serial Buffer Retains Stale Data Across SYNC Sessions; Heap Fragmentation

**File:** `src/sync.cpp`, lines 6, 25–28, 81
**Severity: Medium**

```cpp
static String buffer = "";
...
buffer += c;   // repeated heap allocation
```

Two issues:

1. **Stale data:** `buffer` is a `static` local. If SYNC mode exits while a partial line was being received (no `\n` yet), `buffer` retains those characters. On the next SYNC session entry, new incoming characters are appended to the stale partial line, producing a garbled command.

2. **Heap fragmentation:** Each `buffer += c` call on ESP32's `String` class triggers a `realloc`. In a tight serial read loop, many small concatenations cause heap fragmentation. On an ESP32 with ~300KB free heap, sustained SYNC sessions can degrade heap health.

**Suggested Fix:**
- Reset `buffer = ""` at the start of each SYNC mode session entry.
- Consider a fixed-size `char buf[256]` with a length counter to eliminate heap allocations entirely.

---

### BUG-10: No Bounds Check on `TimerMode` Cast From Flash

**File:** `src/storage.cpp`, lines 103–104
**Severity: Medium**

```cpp
uint8_t modeVal = prefs.getUChar("tmode", 0);
mode = static_cast<TimerMode>(modeVal);
```

`TimerMode` has valid values `0` (WORK), `1` (BREAK), `2` (LONG_BREAK). If NVS is corrupted or the enum changes between firmware versions, `modeVal` could be `3`–`255`. The `static_cast` produces an invalid enum value with undefined behavior in subsequent `switch` statements. Most `switch` arms have `default` cases that silently use fallback values, masking the invalid state rather than reporting it.

**Suggested Fix:**
```cpp
uint8_t modeVal = prefs.getUChar("tmode", 0);
if (modeVal > 2) modeVal = 0; // clamp to valid range
mode = static_cast<TimerMode>(modeVal);
```

---

### BUG-11: Wrong Substring Extracted for `breakMinutes` When BUG-03 Fires

**File:** `src/storage.cpp`, lines 62–65
**Severity: High** *(Dependent on BUG-03)*

```cpp
int breakIdx = str.indexOf("break=");
...
int val = str.substring(breakIdx + 6, endIdx).toInt();
```

When `breakIdx` incorrectly points to the `"break="` substring *inside* `"longBreak="` (per BUG-03), `breakIdx + 6` skips 6 characters from that position — landing mid-value of the `longBreak=` field. `toInt()` then parses whatever digits follow, silently assigning the wrong value to `breakMinutes`.

**Shares the same fix as BUG-03.**

---

### BUG-12: `switchEntryTime` Initialized to `0` — False "Already Entered" Detection on First SWITCH

**File:** `src/main.cpp`, lines 222–226, 269
**Severity: Low**

```cpp
if (g_state.switchEntryTime != g_state.modeStartTime) {
    g_state.switchEntryTime = g_state.modeStartTime;
    g_state.switchActionTime = millis();
    ...
}
...
if (millis() - g_state.switchActionTime >= 4000) { // auto-exit timeout
```

Both `switchEntryTime` and `modeStartTime` default to `0`. If `millis()` returns `0` at the exact moment of the very first SWITCH mode entry (possible immediately post-reset), the condition `switchEntryTime != modeStartTime` is `false`, `switchActionTime` is never initialized, and remains `0`. The 4-second timeout then fires almost immediately (`millis() - 0 >= 4000` becomes true within 4 seconds), causing an unintended auto-exit from SWITCH mode on first entry.

**Suggested Fix:** Initialize `switchEntryTime` to `ULONG_MAX` in `GlobalState` constructor/initializer so the first entry comparison always fires correctly.

---

### BUG-13: Excessive NVS Flash Write Wear — `saveTimerState` Called Every Second

**File:** `src/main.cpp`, lines 193, 201–203
**Severity: Medium**

```cpp
if (elapsedSeconds > 0 || g_timerState.remainingSeconds == 0) {
    saveTimerState(g_timerState);
}
```

`saveTimerState` opens the NVS `"M5Timer"` namespace, writes up to 4 NVS keys, and closes it — every second during active timing. This means approximately **86,400 NVS writes per day** of active use. ESP32 NVS sectors have a write endurance of roughly 10,000–100,000 cycles. NVS wear-leveling distributes writes across the partition, but heavy use will exhaust the partition within months to years of daily use.

**Suggested Fix:** Save at meaningful checkpoints only:
```cpp
// Only write every 60 seconds during active countdown
static int lastSavedSecond = -1;
int currentMinuteMark = g_timerState.remainingSeconds / 60;
if (currentMinuteMark != lastSavedSecond) {
    lastSavedSecond = currentMinuteMark;
    saveTimerState(g_timerState);
}
```
Also save on mode transitions, sleep entry, and button presses (already done at other call sites).

---

### BUG-14: `CORE_DEBUG_LEVEL=3` Left Enabled in Production Build

**File:** `platformio.ini`, line 8
**Severity: Low**

```ini
build_flags =
    -DCORE_DEBUG_LEVEL=3
```

Level 3 = ESP-IDF `DEBUG` logging. This:
- Adds runtime overhead for string formatting and serial output
- Produces verbose USB CDC output even when `Serial` is "disabled"
- Increases firmware binary size
- May expose internal state information unintentionally

**Suggested Fix:** Set `-DCORE_DEBUG_LEVEL=0` for production. Use separate PlatformIO environments:
```ini
[env:release]
build_flags = -DCORE_DEBUG_LEVEL=0 -DARDUINO_USB_CDC_ON_BOOT=0

[env:debug]
build_flags = -DCORE_DEBUG_LEVEL=3 -DARDUINO_USB_CDC_ON_BOOT=1
```

---

## Priority Fix Order

### Immediate (High Severity)
1. **BUG-03 + BUG-11** — Fix `indexOf("break=")` parser collision with `"longBreak="`. Silent data corruption of settings.
2. **BUG-05** — Fix premature `completedWorkSessions` increment on manual session interruption. Breaks core Pomodoro logic.
3. **BUG-01** — Guard against negative `remainingSeconds` before casting to `uint32_t`. Can cause device to enter infinite sleep.
4. **BUG-02** — Fix unsigned underflow in countdown calculation. Skips final countdown beep.

### Near-Term (Medium Severity)
5. **BUG-07** — Reset `lastRTC`/`lastSecond` statics on TIMER mode re-entry. Prevents timer skipping forward.
6. **BUG-10** — Add `TimerMode` bounds check on NVS load. Prevents invalid enum from corrupting state.
7. **BUG-09** — Reset serial buffer on SYNC mode entry; consider fixed-size buffer.
8. **BUG-13** — Reduce NVS write frequency to extend flash lifetime.
9. **BUG-08** — Resolve conflict between `Serial.end()` and `ARDUINO_USB_CDC_ON_BOOT=1`.
10. **BUG-06** — Reset `lastBeepSecond` static on INITIAL mode re-entry.

### Cleanup (Low Severity)
11. **BUG-04** — Align `tones[5]` vs `queue[4]` array sizes.
12. **BUG-12** — Initialize `switchEntryTime` to `ULONG_MAX`.
13. **BUG-14** — Disable `CORE_DEBUG_LEVEL=3` for production builds.
