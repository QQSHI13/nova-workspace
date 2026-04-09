# Changelog

## [1.1.0] - 2026-04-09

### Changed
- **Simplified API**: Removed `/screen` and `/frames` endpoints
- **Enhanced `/capture`**: Now returns screen dimensions directly in the response
  - Added `screen: {width, height}` field to capture response
- **On-demand capture only**: No background thread, captures only when POSTed

### API Changes
**Before:**
```bash
GET /screen    # Get dimensions
curl -X POST /capture  # Returns {path, frame}
```

**After:**
```bash
curl -X POST /capture  # Returns {path, frame, screen}
```

### Removed
- `GET /screen` endpoint (functionality merged into `/capture`)
- `GET /frames` endpoint (no longer needed with on-demand capture)

## [1.0.0] - 2026-04-09

### Initial Release
- AI remote control for Windows desktop
- On-demand screenshot capture via `POST /capture`
- Mouse control: click, drag, scroll
- Keyboard control: type, key press, combinations
- WSL integration: saves frames to `/tmp/wincontrol/`
- HTTP API on port 8767
