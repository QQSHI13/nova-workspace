# DropTransfer Bug Fix Report

**Date:** 2026-03-19  
**Status:** ✅ Complete  
**Commit:** ad916c1

## Summary

Fixed 6 bugs in the droptransfer project as specified in the task:
- 3 Critical Issues (Issues 3, 4, 5)
- 3 High Priority Issues (Issues 21, 22, 23)

## Bugs Fixed

### Issue 3: Directory Traversal Batch Handling (CRITICAL)

**Location:** `traverseEntry()` function (line ~534)

**Problem:** The directory traversal code was processing entries as they were read in batches, but errors in subdirectory processing were being silently caught and logged, potentially causing inconsistent state. Additionally, if an error occurred during entry processing, the promise could resolve prematurely.

**Fix:** 
- Accumulate all entries across batches before processing
- Process all entries only after complete batch reading
- Proper error propagation to reject the promise on processing errors

**Code Change:**
```javascript
// Before: Processed entries as they came, errors were silently caught
const readEntries = () => {
    dirReader.readEntries(async (entries) => {
        if (entries.length === 0) { resolve(); return; }
        for (const subEntry of entries) {
            try {
                await traverseEntry(subEntry, path + entry.name + '/');
            } catch (err) {
                console.error('Error traversing subdirectory:', err);
            }
        }
        readEntries();
    }, ...);
};

// After: Accumulate all entries first, then process
const allEntries = []; // Accumulate all entries across batches
const readEntries = () => {
    dirReader.readEntries(async (entries) => {
        if (entries.length === 0) {
            // All batches read, now process all entries
            try {
                for (const subEntry of allEntries) {
                    await traverseEntry(subEntry, path + entry.name + '/');
                }
                resolve();
            } catch (err) {
                console.error('Error processing directory entries:', err);
                reject(err);
            }
            return;
        }
        // Accumulate entries from this batch
        allEntries.push(...entries);
        // Continue reading next batch
        readEntries();
    }, ...);
};
```

---

### Issue 4: WebTorrent Memory Leak (CRITICAL)

**Location:** `initTorrentSender()` function (line ~1453)

**Problem:** When `initTorrentSender()` was called multiple times without `resetSender()` being called first (e.g., when selecting new files while already seeding), new torrents would be created but old ones weren't cleaned up, causing memory leaks and ghost connections.

**Fix:** 
- Clean up existing torrents at the start of `initTorrentSender()`
- Destroy all active torrents and clear the tracking array before creating new ones

**Code Change:**
```javascript
async function initTorrentSender() {
    // Clean up existing torrents before creating new ones (prevent memory leak)
    activeTorrents.forEach(torrent => {
        if (torrent._cleanup) torrent._cleanup();
        torrent.destroy();
    });
    activeTorrents = [];
    
    if (!client) {
        // ... rest of function
```

---

### Issue 5: Data Queue Not Cleared on Reset (CRITICAL)

**Location:** `resetReceiver()` function (line ~1415)

**Problem:** The `resetReceiver()` function didn't clear the `dataQueue` or reset the `isProcessingData` flag. This could cause:
- Stale data from previous transfers to persist
- Queue processing to be stuck if `isProcessingData` was true
- `chunkCache` and `expectedChunkIndex` not being reset

**Fix:** 
- Clear `dataQueue` array
- Reset `isProcessingData` to false
- Clear `chunkCache` Map
- Reset `expectedChunkIndex` to 0

**Code Change:**
```javascript
function resetReceiver() {
    // ... existing cleanup code ...
    
    // Clear data queue and processing flag to prevent stale data
    dataQueue.length = 0;
    isProcessingData = false;
    chunkCache.clear();
    expectedChunkIndex = 0;
    
    // ... rest of function
```

---

### Issue 21: No Validation of Received File Size (HIGH)

**Location:** `handleDataInternal()` function (line ~1247)

**Problem:** When receiving chunks, there was no validation that:
1. The chunk data was valid
2. The received data size didn't exceed the expected file size

This could allow a malicious sender to send corrupted data or exceed the agreed-upon file size.

**Fix:** 
- Added validation for chunk data type and existence
- Added size validation to ensure projected total doesn't exceed expected file size
- Return early with error status if validation fails

**Code Change:**
```javascript
} else if (data.type === 'chunk') {
    // Validate chunk data exists
    if (!data.data || !(data.data instanceof ArrayBuffer || data.data.byteLength === undefined)) {
        console.error('Invalid chunk data received');
        showStatus('receiveStatus', 'Error: Invalid chunk data received', 'error');
        return;
    }
    
    let chunkData = data.data;
    
    // Validate that adding this chunk won't exceed expected total size
    const expectedFileSize = fileInfo.files[data.fileIndex]?.size || 0;
    const maxAllowedSize = expectedFileSize + CHUNK_SIZE; // Allow one chunk tolerance for padding
    const projectedSize = receivedSize + chunkData.byteLength + 
        Array.from(chunkCache.values()).reduce((sum, chunk) => sum + chunk.byteLength, 0);
    
    if (projectedSize > maxAllowedSize) {
        console.error(`Size validation failed: projected ${projectedSize} exceeds max allowed ${maxAllowedSize}`);
        showStatus('receiveStatus', 'Error: Received data exceeds expected file size', 'error');
        return;
    }
    
    // ... rest of processing
```

---

### Issue 22: Potential Infinite Loop in Chunk Resending (HIGH)

**Location:** `sendFiles()` function retry loop (line ~975)

**Problem:** In the chunk retry loop, there was no connection state check before resending chunks. If the connection closed during retries, the code would continue trying to send on a closed connection, potentially causing errors or unexpected behavior.

**Fix:** 
- Added connection state check before each chunk resend
- Return early with proper cleanup if connection is closed

**Code Change:**
```javascript
// Resend unacknowledged chunks
for (const [chunkKey, chunkInfo] of pendingAcks) {
    // Check connection is still open before each send
    if (!conn || !conn.open) {
        console.error('Connection closed during retry');
        isSending = false;
        document.getElementById('resetBtn').disabled = false;
        return;
    }
    
    const { index: chunkIdx, fileIndex: targetFileIdx } = chunkInfo;
    // ... rest of resend logic
```

---

### Issue 23: Missing Error Handling in Zip Creation (HIGH)

**Location:** `createZipFromFiles()` function (line ~614)

**Problem:** The for loop that adds files to the zip had no error handling. If one file failed to be read (e.g., file was deleted or permission denied), the entire zip creation would fail silently or leave the zip in a partially constructed state.

**Fix:** 
- Added try-catch block around file reading and zip addition
- Return null early if any file fails, allowing caller to handle the error

**Code Change:**
```javascript
// Add all files to zip with their relative paths
for (const f of currentFiles) {
    try {
        const fileData = await f.file.arrayBuffer();
        zip.file(f.path, fileData);
    } catch (err) {
        console.error('Error adding file to zip:', f.path, err);
        showStatus('sendStatus', 'Error adding file to zip: ' + f.path, 'error');
        return null;
    }
}
```

---

## Verification Checklist

- [x] Directory traversal properly accumulates batches before processing
- [x] WebTorrent memory leak fixed (existing torrents cleaned up)
- [x] Data queue cleared on receiver reset
- [x] Processing flag reset on receiver reset
- [x] Chunk cache cleared on receiver reset
- [x] Received file size validation added
- [x] Connection state checked during chunk retry
- [x] Zip creation error handling added
- [x] All changes committed locally

## Stats

- **Files Modified:** 1 (`index.html`)
- **Lines Added:** 62
- **Lines Removed:** 6
- **Net Change:** +56 lines
