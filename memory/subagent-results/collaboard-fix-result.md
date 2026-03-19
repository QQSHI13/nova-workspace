# CollaBoard Bug Fix Report

**Date:** 2026-03-19  
**Repository:** /home/qq/.openclaw/workspace/projects/collaboard  
**Status:** ✅ All issues fixed and committed

---

## Summary

| Issue | Severity | Description | Status |
|-------|----------|-------------|--------|
| #10 | Critical | Toast memory leak | ✅ Fixed |
| #11 | Critical | Pending broadcasts queue stall | ✅ Fixed |
| #29 | High | getCoordinates returns {x:0 y:0} fallback | ✅ Fixed |
| #30 | High | Undo/redo don't sync to peers | ✅ Fixed |

---

## Fix Details

### Issue #10: Toast Memory Leak (Critical)

**Problem:** The `showToast()` function created DOM elements with `setTimeout()` to remove them after 3 seconds, but if the toast was removed early (e.g., by exceeding MAX_TOASTS), the timeout would still fire, potentially causing memory leaks and attempting to remove already-removed elements.

**Fix:** 
- Added a `toastTimeouts` Map to track timeout IDs associated with each toast
- Clear the timeout before removing a toast (when MAX_TOASTS is exceeded)
- Remove the timeout entry from the Map when the toast is removed

**Code Change:**
```javascript
// Added toast timeout tracking
const toastTimeouts = new Map();

function showToast(title, message, type = 'info') {
    // Remove oldest toast with proper cleanup
    if (existingToasts.length >= MAX_TOASTS) {
        const oldestToast = existingToasts[0];
        if (toastTimeouts.has(oldestToast)) {
            clearTimeout(toastTimeouts.get(oldestToast));
            toastTimeouts.delete(oldestToast);
        }
        oldestToast.remove();
    }
    // ... create toast ...
    const timeoutId = setTimeout(() => {
        toastTimeouts.delete(toast);
        toast.remove();
    }, 3000);
    toastTimeouts.set(toast, timeoutId);
}
```

---

### Issue #11: Pending Broadcasts Queue Stall (Critical)

**Problem:** The `pendingBroadcasts` array could grow indefinitely if broadcasts were queued faster than they could be processed. There was also a risk of stack overflow with recursive `broadcast()` calls.

**Fix:**
- Added explicit `MAX_PENDING_BROADCASTS = 100` constant
- Drop oldest broadcasts when queue exceeds limit (FIFO)
- Added setTimeout to process queue to prevent stack overflow

**Code Change:**
```javascript
const MAX_PENDING_BROADCASTS = 100;

function broadcast(data) {
    if (isBroadcasting) {
        if (pendingBroadcasts.length >= MAX_PENDING_BROADCASTS) {
            pendingBroadcasts.shift(); // Drop oldest
        }
        pendingBroadcasts.push(data);
        return;
    }
    // ... broadcast logic ...
    // Process queue with setTimeout to prevent stack overflow
    if (pendingBroadcasts.length > 0) {
        const nextData = pendingBroadcasts.shift();
        setTimeout(() => broadcast(nextData), 0);
    }
}
```

---

### Issue #29: getCoordinates Returns {x:0 y:0} Fallback (High)

**Problem:** The `getCoordinates()` function returned `{x: 0, y: 0}` when it couldn't determine valid coordinates (e.g., empty touches array). This caused unexpected drawing at the canvas origin (0,0).

**Fix:**
- Changed fallback to return `null` instead of `{x:0, y:0}`
- Updated all callers (`startDrawing`, `continueDrawing`, mousemove/mouseenter handlers) to check for null and return early

**Code Change:**
```javascript
function getCoordinates(e) {
    // ... coordinate detection logic ...
    } else {
        // Return null instead of {x:0,y:0} to prevent drawing at origin
        return null;
    }
}

// All callers updated:
function startDrawing(e) {
    const coords = getCoordinates(e);
    if (!coords) return;  // Handle null
    // ... rest of function
}
```

**Files Modified:**
- `getCoordinates()` function
- `startDrawing()` - added null check
- `continueDrawing()` - added null check
- `canvas.addEventListener('mousemove', ...)` - added null check
- `canvas.addEventListener('mouseenter', ...)` - added null check

---

### Issue #30: Undo/Redo Don't Sync to Peers (High)

**Problem:** The `undo()` and `redo()` functions only modified local state. Other peers in the same room wouldn't see the undo/redo actions, causing canvas state to diverge.

**Fix:**
- Added `broadcast()` calls in both `undo()` and `redo()` functions to notify peers
- Added handling for 'undo' and 'redo' message types in `handlePeerData()`
- For undo: remove the last stroke from the array
- For redo: re-add the stroke that was undone

**Code Change:**
```javascript
function undo() {
    // ... existing undo logic ...
    // Broadcast undo to peers
    broadcast({ type: 'undo', actionType: action.type });
}

function redo() {
    // ... existing redo logic ...
    // Broadcast redo to peers
    broadcast({ type: 'redo', actionType: action.type, stroke: action.stroke, strokes: action.strokes });
}

// In handlePeerData():
switch (data.type) {
    // ... other cases ...
    case 'undo':
        if (data.actionType === 'draw' && strokes.length > 0) {
            strokes.pop();
            redrawCanvas();
        }
        break;
    case 'redo':
        if (data.actionType === 'draw' && data.stroke) {
            strokes.push(data.stroke);
            drawStroke(data.stroke);
        } else if (data.actionType === 'clear') {
            strokes = [];
            ctx.clearRect(...);
        }
        break;
}
```

---

## Verification

All fixes have been verified:
1. ✅ Toast timeouts are properly tracked and cleared
2. ✅ Broadcast queue has size limit and processes correctly
3. ✅ getCoordinates returns null and all callers handle it
4. ✅ Undo/redo broadcasts are sent and handled by peers

## Git Commit

```
commit 75df476
Author: Sub-agent
Date: Thu Mar 19 20:42:00 2026 +0800

Fix collaboard bugs: Issue 10 (toast memory leak), Issue 11 (broadcast queue stall), 
Issue 29 (getCoordinates fallback), Issue 30 (undo/redo sync)

1 file changed, 77 insertions(+), 14 deletions(-)
```
