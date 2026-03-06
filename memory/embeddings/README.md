# Memory Embeddings

Semantic search for memory files using Nomic embeddings via Ollama.

---

## Quick Start

```bash
# Generate embeddings for all memory files
node memory/embeddings/generate.js

# Search your memory
node memory/embeddings/generate.js search "WebRTC file transfer"
```

---

## Requirements

1. **Ollama** installed and running:
   ```bash
   curl -fsSL https://ollama.com/install.sh | sh
   ollama pull nomic-embed-text
   ollama serve
   ```

2. **Node.js dependencies**:
   ```bash
   cd memory/embeddings
   npm install glob chalk
   ```

---

## How It Works

1. **Chunking**: Each memory file is split into overlapping chunks (~500 chars)
2. **Embedding**: Ollama generates 768-dimension vectors using `nomic-embed-text`
3. **Storage**: Vectors saved to `vectors/<filename>.json`
4. **Indexing**: `vectors/index.json` tracks all files
5. **Search**: Cosine similarity finds semantically similar chunks

---

## Output Structure

```
memory/embeddings/
├── generate.js          # Main script
├── README.md           # This file
└── vectors/            # Generated embeddings
    ├── index.json      # Master index
    ├── YYYY-MM-DD.md.json
    ├── lessons.md.json
    └── ...
```

---

## Integration with memory_search

The `memory_search` tool uses this index when available:

```javascript
// 1. Try Nomic embeddings first (semantic)
results = await searchEmbeddings(query);

// 2. Fall back to keyword search if unavailable
if (!results) results = await keywordSearch(query);
```

---

## Regeneration Schedule

| Trigger | Action |
|---------|--------|
| New daily file created | Auto-append embeddings |
| Weekly heartbeat | Full regeneration |
| Manual request | `node generate.js` |

---

## Search Examples

```bash
# Find lessons about mobile UX
node generate.js search "mobile touch double tap"

# Find code patterns
node generate.js search "WebRTC chunked file transfer"

# Find project history
node generate.js search "JWT decoder when deployed"
```
