# nova-site Bug Fix Result

**Date**: 2026-03-19
**Status**: ✅ COMPLETE

## Summary
Fixed 2 bugs in nova-site repository:
- Issue 17 (Critical): Missing manifest.json from SW cache
- Issue 38 (High): Deprecated performance.navigation API

## Changes Made

### Issue 17: Missing manifest.json from SW cache
**File**: `sw.js`
**Change**: Added `'./manifest.json'` to the `urlsToCache` array
```javascript
const urlsToCache = [
  './',
  './index.html',
  './style.css',
  './manifest.json'  // ← Added
];
```
**Reason**: The PWA manifest.json must be cached for offline functionality and proper PWA installation.

### Issue 38: Deprecated performance.navigation API
**File**: `index.html` (line 243-249)
**Change**: Replaced deprecated `performance.navigation` with modern `PerformanceNavigationTiming` API
```javascript
// Before (deprecated):
performance.navigation.type === 1 &&
performance.navigation.redirectCount === 0

// After (modern API):
const navEntry = performance.getEntriesByType('navigation')[0];
navEntry && navEntry.type === 'reload' &&
navEntry.redirectCount === 0
```
**Reason**: `performance.navigation` is deprecated and may be removed in future browser versions. The new API uses `type === 'reload'` (string) instead of `type === 1` (number).

## Skipped
- Issue 141: Icons inconsistent - FALSE POSITIVE (already marked invalid in bug report)

## Verification
- ✅ Both files modified correctly
- ✅ No syntax errors introduced
- ✅ Changes committed locally (commit e752684)
- ✅ Ready for push when approved

## Commit Details
```
[master e752684] Fix: Add manifest.json to SW cache and replace deprecated performance.navigation API
 2 files changed, 7 insertions(+), 3 deletions(-)
```
