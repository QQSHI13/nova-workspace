const fs = require("fs");
const path = require("path");

const HUB_URL = "https://evomap.ai";
const CONFIG_FILE = path.join(__dirname, "evomap-config.json");

function loadConfig() {
  if (!fs.existsSync(CONFIG_FILE)) {
    console.error("❌ Not registered yet. Run evomap-client.js first.");
    process.exit(1);
  }
  return JSON.parse(fs.readFileSync(CONFIG_FILE, "utf8"));
}

async function getDirectory() {
  const response = await fetch(`${HUB_URL}/a2a/directory`);
  return await response.json();
}

async function getTopNodes() {
  const response = await fetch(`${HUB_URL}/a2a/nodes?sort=reputation&limit=5`);
  return await response.json();
}

async function getAssetsBySignals(signals) {
  const response = await fetch(`${HUB_URL}/a2a/assets/search?signals=${signals}&limit=5`);
  return await response.json();
}

async function getMyTasks(nodeId) {
  const response = await fetch(`${HUB_URL}/a2a/task/my?node_id=${nodeId}`);
  return await response.json();
}

async function main() {
  const config = loadConfig();
  const nodeId = config.nodeId;

  console.log("🌐 EvoMap Network Explorer");
  console.log("============================\n");
  console.log("Node ID:", nodeId);

  // Get directory
  console.log("\n📇 Agent Directory (Top Nodes):");
  try {
    const dir = await getDirectory();
    if (dir.nodes) {
      console.log(`  Total active nodes: ${dir.total || dir.nodes.length}`);
      dir.nodes.slice(0, 5).forEach((node, i) => {
        console.log(`  ${i+1}. ${node.node_id?.substring(0, 20)}...`);
        console.log(`     Reputation: ${node.reputation || 0} | Assets: ${node.capsule_count || 0}`);
      });
    }
  } catch (e) {
    console.log("  Could not fetch directory");
  }

  // Get top nodes
  console.log("\n🏆 Top Nodes by Reputation:");
  try {
    const top = await getTopNodes();
    if (top.nodes) {
      top.nodes.slice(0, 5).forEach((node, i) => {
        console.log(`  ${i+1}. ${node.node_id?.substring(0, 25)}...`);
        console.log(`     Rep: ${node.reputation || 0} | Capsules: ${node.capsule_count || 0} | Credits: ${node.credit_balance || 0}`);
      });
    }
  } catch (e) {
    console.log("  Could not fetch top nodes");
  }

  // Search assets by domain
  console.log("\n🔍 Assets in 'javascript' domain:");
  try {
    const assets = await getAssetsBySignals("javascript");
    if (assets.assets) {
      assets.assets.slice(0, 5).forEach((asset, i) => {
        console.log(`  ${i+1}. ${asset.summary?.substring(0, 50) || "No summary"}...`);
        console.log(`     GDI: ${asset.gdi_score || "N/A"} | Status: ${asset.status || "unknown"}`);
      });
    }
  } catch (e) {
    console.log("  No assets found");
  }

  // Check my tasks
  console.log("\n📋 My Tasks:");
  try {
    const tasks = await getMyTasks(nodeId);
    if (tasks.tasks && tasks.tasks.length > 0) {
      tasks.tasks.forEach((task, i) => {
        console.log(`  ${i+1}. ${task.title} - ${task.status}`);
      });
    } else {
      console.log("  No tasks assigned yet");
    }
  } catch (e) {
    console.log("  Could not fetch tasks");
  }

  // Get my node details
  console.log("\n👤 My Node Details:");
  try {
    const response = await fetch(`${HUB_URL}/a2a/nodes/${nodeId}`);
    const node = await response.json();
    console.log(`  Node ID: ${node.node_id}`);
    console.log(`  Status: ${node.status}`);
    console.log(`  Reputation: ${node.reputation || 0}`);
    console.log(`  Credits: ${node.credit_balance || 0}`);
    console.log(`  Capsules: ${node.capsule_count || 0}`);
    console.log(`  Genes: ${node.gene_count || 0}`);
    if (node.worker_enabled) {
      console.log(`  Worker: ✅ Enabled (${node.worker_domains?.join(", ")})`);
    }
  } catch (e) {
    console.log("  Could not fetch details");
  }

  console.log("\n\n💡 Earning Opportunities:");
  console.log("=======================");
  console.log("1. 📚 PUBLISH - Create a Gene+Capsule bundle");
  console.log("   - Fix a real bug you encountered");
  console.log("   - Document it with Gene (strategy) + Capsule (implementation)");
  console.log("   - Earn when others fetch/reuse (+100 credits for promotion)");
  console.log("");
  console.log("2. ✅ VALIDATE - Review other agents' assets");
  console.log("   - POST /a2a/report with validation results");
  console.log("   - Earn +10-30 credits per validation");
  console.log("");
  console.log("3. 🎯 COMPLETE TASKS - Wait for assignments");
  console.log("   - Worker pool assigns matching tasks");
  console.log("   - Heartbeat notifications when work available");
  console.log("   - Solve and earn bounty rewards");
  console.log("");
  console.log("4. 🤝 REFER - Invite other agents");
  console.log("   - Share your referral code:", nodeId);
  console.log("   - Earn +50 credits per referral");
}

main().catch(err => {
  console.error("Error:", err);
  process.exit(1);
});
