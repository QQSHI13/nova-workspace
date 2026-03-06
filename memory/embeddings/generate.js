#!/usr/bin/env node
/**
 * Memory Embedding Generator
 * 
 * Generates Nomic embeddings for all memory files using Ollama.
 * Run via: node memory/embeddings/generate.js
 * 
 * Requirements:
 * - Ollama running locally with nomic-embed-text model
 * - npm install chalk glob
 */

const fs = require('fs');
const path = require('path');
const { glob } = require('glob');
const https = require('https');

const MEMORY_DIR = path.join(__dirname, '..');
const EMBEDDINGS_DIR = path.join(__dirname, 'vectors');
const OLLAMA_HOST = process.env.OLLAMA_HOST || 'http://localhost:11434';

// Ensure embeddings directory exists
if (!fs.existsSync(EMBEDDINGS_DIR)) {
  fs.mkdirSync(EMBEDDINGS_DIR, { recursive: true });
}

/**
 * Generate embedding for text via Ollama API
 */
async function generateEmbedding(text) {
  return new Promise((resolve, reject) => {
    const data = JSON.stringify({
      model: 'nomic-embed-text',
      prompt: text
    });

    const url = new URL(`${OLLAMA_HOST}/api/embeddings`);
    const options = {
      hostname: url.hostname,
      port: url.port || 11434,
      path: url.pathname,
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': data.length
      }
    };

    const req = https.request(options, (res) => {
      let responseData = '';
      res.on('data', chunk => responseData += chunk);
      res.on('end', () => {
        try {
          const result = JSON.parse(responseData);
          resolve(result.embedding);
        } catch (err) {
          reject(new Error(`Failed to parse response: ${err.message}`));
        }
      });
    });

    req.on('error', reject);
    req.write(data);
    req.end();
  });
}

/**
 * Chunk text into overlapping segments for better retrieval
 */
function chunkText(text, chunkSize = 500, overlap = 100) {
  const chunks = [];
  let start = 0;
  
  while (start < text.length) {
    const end = Math.min(start + chunkSize, text.length);
    // Find natural break point (newline or period)
    let breakPoint = end;
    if (end < text.length) {
      const searchText = text.slice(start, end + 50);
      const lastNewline = searchText.lastIndexOf('\n');
      const lastPeriod = searchText.lastIndexOf('. ');
      breakPoint = start + Math.max(lastNewline, lastPeriod + 1);
      if (breakPoint <= start) breakPoint = end;
    }
    
    chunks.push({
      text: text.slice(start, breakPoint).trim(),
      start,
      end: breakPoint
    });
    
    start = breakPoint - overlap;
    if (start < 0) start = 0;
    if (start >= text.length - 1) break;
  }
  
  return chunks;
}

/**
 * Process a single memory file
 */
async function processFile(filePath) {
  console.log(`Processing: ${path.relative(MEMORY_DIR, filePath)}`);
  
  const content = fs.readFileSync(filePath, 'utf-8');
  const relativePath = path.relative(MEMORY_DIR, filePath);
  const chunks = chunkText(content);
  
  const embeddings = [];
  
  for (let i = 0; i < chunks.length; i++) {
    const chunk = chunks[i];
    try {
      const vector = await generateEmbedding(chunk.text);
      embeddings.push({
        chunk: i,
        text: chunk.text.slice(0, 200) + (chunk.text.length > 200 ? '...' : ''),
        vector,
        start: chunk.start,
        end: chunk.end
      });
      process.stdout.write('.');
    } catch (err) {
      console.error(`\nError embedding chunk ${i}: ${err.message}`);
    }
  }
  
  console.log(` ✓ ${embeddings.length} chunks`);
  
  // Save embeddings
  const outputFile = path.join(EMBEDDINGS_DIR, `${relativePath.replace(/[\/]/g, '_')}.json`);
  fs.mkdirSync(path.dirname(outputFile), { recursive: true });
  fs.writeFileSync(outputFile, JSON.stringify({
    file: relativePath,
    chunks: embeddings.length,
    generated: new Date().toISOString(),
    embeddings
  }, null, 2));
  
  return embeddings.length;
}

/**
 * Generate index file for all embeddings
 */
function generateIndex(processedFiles) {
  const index = {
    version: 2,
    generated: new Date().toISOString(),
    model: 'nomic-embed-text',
    files: processedFiles.map(f => ({
      file: f.file,
      chunks: f.chunks,
      path: `vectors/${f.file.replace(/[\/]/g, '_')}.json`
    }))
  };
  
  fs.writeFileSync(
    path.join(EMBEDDINGS_DIR, 'index.json'),
    JSON.stringify(index, null, 2)
  );
  
  console.log(`\nIndex written: embeddings/vectors/index.json`);
}

/**
 * Search embeddings for similar content
 */
async function search(query, topK = 5) {
  const indexPath = path.join(EMBEDDINGS_DIR, 'index.json');
  if (!fs.existsSync(indexPath)) {
    console.error('No index found. Run generation first.');
    return;
  }
  
  const queryVector = await generateEmbedding(query);
  const index = JSON.parse(fs.readFileSync(indexPath, 'utf-8'));
  
  const results = [];
  
  for (const file of index.files) {
    const embeddingPath = path.join(EMBEDDINGS_DIR, file.path);
    if (!fs.existsSync(embeddingPath)) continue;
    
    const data = JSON.parse(fs.readFileSync(embeddingPath, 'utf-8'));
    for (const chunk of data.embeddings) {
      const similarity = cosineSimilarity(queryVector, chunk.vector);
      results.push({
        file: file.file,
        text: chunk.text,
        similarity: Math.round(similarity * 1000) / 1000,
        start: chunk.start,
        end: chunk.end
      });
    }
  }
  
  return results
    .sort((a, b) => b.similarity - a.similarity)
    .slice(0, topK);
}

/**
 * Calculate cosine similarity between two vectors
 */
function cosineSimilarity(a, b) {
  let dot = 0, normA = 0, normB = 0;
  for (let i = 0; i < a.length; i++) {
    dot += a[i] * b[i];
    normA += a[i] * a[i];
    normB += b[i] * b[i];
  }
  return dot / (Math.sqrt(normA) * Math.sqrt(normB));
}

/**
 * Main entry point
 */
async function main() {
  const command = process.argv[2];
  
  if (command === 'search') {
    const query = process.argv.slice(3).join(' ');
    if (!query) {
      console.log('Usage: node generate.js search "your query here"');
      process.exit(1);
    }
    console.log(`Searching for: "${query}"\n`);
    const results = await search(query);
    results.forEach((r, i) => {
      console.log(`${i + 1}. [${r.similarity}] ${r.file}:${r.start}-${r.end}`);
      console.log(`   ${r.text.slice(0, 100)}...\n`);
    });
    return;
  }
  
  // Default: generate all embeddings
  console.log('Memory Embedding Generator');
  console.log('==========================\n');
  
  const files = await glob('**/*.md', {
    cwd: MEMORY_DIR,
    ignore: ['**/embeddings/**', '**/subagent-results/**', '**/node_modules/**']
  });
  
  console.log(`Found ${files.length} markdown files\n`);
  
  const processed = [];
  for (const file of files) {
    const filePath = path.join(MEMORY_DIR, file);
    try {
      const chunks = await processFile(filePath);
      processed.push({ file, chunks });
    } catch (err) {
      console.error(`Failed to process ${file}: ${err.message}`);
    }
  }
  
  generateIndex(processed);
  console.log(`\nDone! Processed ${processed.length} files.`);
}

main().catch(err => {
  console.error(err);
  process.exit(1);
});
