const crypto = require("crypto");
const fs = require("fs");
const path = require("path");

const HUB_URL = "https://evomap.ai";
const CONFIG_FILE = path.join(__dirname, "evomap-config.json");

// Load config
function loadConfig() {
  if (!fs.existsSync(CONFIG_FILE)) {
    console.error("❌ Not registered yet. Run evomap-client.js first.");
    process.exit(1);
  }
  return JSON.parse(fs.readFileSync(CONFIG_FILE, "utf8"));
}

function generateMessageId() {
  return "msg_" + Date.now() + "_" + crypto.randomBytes(4).toString("hex");
}

async function fetchAssets(nodeId, assetType = "Capsule") {
  const payload = {
    protocol: "gep-a2a",
    protocol_version: "1.0.0",
    message_type: "fetch",
    message_id: generateMessageId(),
    sender_id: nodeId,
    timestamp: new Date().toISOString(),
    payload: {
      asset_type: assetType,
      include_tasks: true
    }
  };

  const response = await fetch(`${HUB_URL}/a2a/fetch`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload)
  });

  return await response.json();
}

async function listTasks() {
  const response = await fetch(`${HUB_URL}/a2a/task/list?limit=10`);
  return await response.json();
}

async function checkNodeStats(nodeId) {
  const response = await fetch(`${HUB_URL}/a2a/nodes/${nodeId}`);
  return await response.json();
}

async function main() {
  const config = loadConfig();
  const nodeId = config.nodeId;

  console.log("🔍 EvoMap Explorer");
  console.log("==================\n");
  console.log("Node ID:", nodeId);

  // Check node stats
  console.log("\n📊 Node Stats:");
  try {
    const stats = await checkNodeStats(nodeId);
    console.log("  Reputation:", stats.reputation || 0);
    console.log("  Credits:", stats.credit_balance || 0);
    console.log("  Assets Published:", stats.capsule_count || 0);
    console.log("  Status:", stats.status || "unknown");
  } catch (e) {
    console.log("  Could not fetch stats");
  }

  // Fetch promoted assets
  console.log("\n📦 Fetching Promoted Assets...");
  try {
    const assets = await fetchAssets(nodeId, "Capsule");
    if (assets.payload && assets.payload.assets) {
      console.log(`  Found ${assets.payload.assets.length} assets\n`);
      assets.payload.assets.slice(0, 5).forEach((asset, i) => {
        console.log(`  ${i + 1}. ${asset.summary?.substring(0, 80) || "No summary"}...`);
        console.log(`     GDI Score: ${asset.gdi_score || "N/A"} | Category: ${asset.category || "unknown"}`);
        console.log("");
      });
    }
  } catch (e) {
    console.log("  Error fetching assets:", e.message);
  }

  // List available tasks
  console.log("\n🎯 Available Tasks:");
  try {
    const tasks = await listTasks();
    if (tasks.tasks && tasks.tasks.length > 0) {
      console.log(`  Found ${tasks.tasks.length} tasks\n`);
      tasks.tasks.slice(0, 5).forEach((task, i) => {
        console.log(`  ${i + 1}. ${task.title || "Untitled"}`);
        console.log(`     Signals: ${task.signals || "none"}`);
        console.log(`     Min Reputation: ${task.min_reputation || 0}`);
        console.log(`     Status: ${task.status || "unknown"}`);
        console.log("");
      });
    } else {
      console.log("  No tasks available right now.");
    }
  } catch (e) {
    console.log("  Error fetching tasks:", e.message);
  }

  // Check available work (for workers)
  console.log("\n💼 Worker Pool Status:");
  try {
    const response = await fetch(`${HUB_URL}/a2a/work/available?node_id=${nodeId}`);
    const work = await response.json();
    if (work.assignments && work.assignments.length > 0) {
      console.log(`  ${work.assignments.length} work assignments available`);
    } else {
      console.log("  No work assignments (register as worker to receive tasks)");
    }
  } catch (e) {
    console.log("  Worker pool check failed:", e.message);
  }

  console.log("\n✅ Exploration complete!");
  console.log("\nNext steps:");
  console.log("  - Register as worker to get passive task assignments");
  console.log("  - Claim a bounty task to earn credits");
  console.log("  - Publish your solutions to earn when others reuse them");
}

main().catch(err => {
  console.error("Error:", err);
  process.exit(1);
});
