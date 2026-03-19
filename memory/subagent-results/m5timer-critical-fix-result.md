# M5Timer Critical Bug Fix Report

**Date:** 2026-03-19  
**Status:** ✅ COMPLETE  
**Commits:** 3 new commits

---

## Summary

Fixed 3 issues (2 critical + 1 medium) in the M5Timer project. All changes verified with successful compilation.

---

## Issues Fixed

### Issue #14 ✅ FIXED (Critical - RTC Time Calculation)
**Location:** `src/main.cpp` (lines 158-175)

**Problem:** RTC time calculation only handled second rollovers within the same minute. Did not account for:
- Minute changes (when minutes increment, seconds reset)
- Hour changes
- Day changes

**Fix:** Rewrote elapsed time calculation to:
1. Convert both times to total seconds using `(hours * 3600 + minutes * 60 + seconds)`
2. Calculate difference with proper handling for midnight wraparound
3. Check for changes in minutes and hours, not just seconds

**Code Changes:**
```cpp
// Before: Only handled seconds within same minute
if (rtcTime.seconds > lastSecond) {
    elapsedSeconds = rtcTime.seconds - lastSecond;
} else {
    elapsedSeconds = (60 - lastSecond) + rtcTime.seconds;
}

// After: Handles min/hour/day rollovers
long lastTotalSec = ((long)lastRTC.hours * 3600L + (long)lastRTC.minutes * 60L + lastRTC.seconds);
long currTotalSec = ((long)rtcTime.hours * 3600L + (long)rtcTime.minutes * 60L + rtcTime.seconds);
long diff = currTotalSec - lastTotalSec;
if (diff < 0) {
    diff += 86400L;  // Handle midnight wraparound
}
elapsedSeconds = (int)diff;
```

**Commit:** `64b7684`

---

### Issue #15 ✅ FIXED (Critical - Preferences Namespace Collision)
**Location:** `src/storage.cpp` (line 4)

**Problem:** Preferences namespace was generic `"pomodoro"`, which could conflict with other timer apps on the same device.

**Fix:** Changed namespace from `"pomodoro"` to `"M5Timer"`.

**Code Change:**
```cpp
// Before:
static const char* PREFS_NAMESPACE = "pomodoro";

// After:
static const char* PREFS_NAMESPACE = "M5Timer";
```

**Commit:** `582169b`

---

### Issue #63 ✅ FIXED (Medium - Buzzer Volume Inconsistency)
**Location:** `src/buzzer.cpp` (lines 19-24)

**Problem:** Volume changes via `setBuzzerVolume()` only took effect when playing the next tone in queue. If volume was changed while a tone was playing, the change wouldn't apply until the next tone started.

**Fix:** Apply volume change immediately if the buzzer is currently active.

**Code Change:**
```cpp
void setBuzzerVolume(uint8_t volume) {
    currentVolume = volume;
    // Apply volume change immediately if buzzer is currently active
    if (buzzerState.active) {
        ledcWrite(0, currentVolume);
    }
}
```

**Commit:** `f139047`

---

## Verification

### Compilation Status
```
$ pio run
Building in release mode...
Linking .pio/build/m5capsule/firmware.elf
Checking size .pio/build/m5capsule/firmware.elf
RAM:   [=         ]   7.2% (used 23552 bytes from 327680 bytes)
Flash: [=         ]  14.7% (used 492897 bytes from 3342336 bytes)
========================= [SUCCESS] Took 61.12 seconds =========================
```

✅ **Build successful** - No compilation errors

### Git Commits
```
f139047 fix(audio): Fix Issue #63 - Apply buzzer volume changes immediately
582169b fix(storage): Fix Issue #15 - Change Preferences namespace to M5Timer
64b7684 fix(rtc): Fix Issue #14 - RTC time calculation for min/hour/day rollovers
```

All commits are local (not yet pushed to origin).

---

## Files Modified

| File | Issue | Lines Changed |
|------|-------|---------------|
| src/main.cpp | #14 | +14, -6 |
| src/storage.cpp | #15 | +1, -1 |
| src/buzzer.cpp | #63 | +4, -0 |

---

## Notes

- The fixes were already present as uncommitted changes in the working directory
- Each fix was committed separately as requested
- All code compiles successfully with `pio run`
- Changes are local only - not pushed to remote
