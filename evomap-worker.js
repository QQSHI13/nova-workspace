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

async function registerWorker(nodeId) {
  const response = await fetch(`${HUB_URL}/a2a/worker/register`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      sender_id: nodeId,
      enabled: true,
      domains: ["javascript", "nodejs", "web", "automation"],
      max_load: 3
    })
  });
  return await response.json();
}

async function fetchTrendingAssets() {
  const response = await fetch(`${HUB_URL}/a2a/trending?limit=5`);
  return await response.json();
}

async function fetchTopAssets() {
  const response = await fetch(`${HUB_URL}/a2a/assets/ranked?limit=5`);
  return await response.json();
}

async function main() {
  const config = loadConfig();
  const nodeId = config.nodeId;

  console.log("🔧 EvoMap Worker Registration");
  console.log("==============================\n");
  console.log("Node ID:", nodeId);

  // Register as worker
  console.log("\n👷 Registering as worker...");
  try {
    const worker = await registerWorker(nodeId);
    console.log("Worker Status:", worker.worker_enabled ? "✅ Enabled" : "❌ Disabled");
    console.log("Domains:", worker.worker_domains?.join(", ") || "none");
    console.log("Max Load:", worker.worker_max_load);
  } catch (e) {
    console.log("Worker registration:", e.message);
  }

  // Fetch trending assets
  console.log("\n🔥 Trending Assets:");
  try {
    const trending = await fetchTrendingAssets();
    if (trending.assets) {
      trending.assets.slice(0, 3).forEach((asset, i) => {
        console.log(`  ${i+1}. ${asset.summary?.substring(0, 60) || "No summary"}...`);
        console.log(`     GDI: ${asset.gdi_score} | Calls: ${asset.calls || 0}`);
      });
    }
  } catch (e) {
    console.log("  Could not fetch trending:", e.message);
  }

  // Fetch top ranked assets
  console.log("\n⭐ Top Ranked Assets:");
  try {
    const ranked = await fetchTopAssets();
    if (ranked.assets) {
      ranked.assets.slice(0, 3).forEach((asset, i) => {
        console.log(`  ${i+1}. ${asset.summary?.substring(0, 60) || "No summary"}...`);
        console.log(`     GDI: ${asset.gdi_score} | Reputation: ${asset.reputation || 0}`);
      });
    }
  } catch (e) {
    console.log("  Could not fetch ranked:", e.message);
  }

  console.log("\n✅ Setup complete!");
  console.log("\nYour node will now:");
  console.log("  - Receive passive task assignments (via heartbeat)");
  console.log("  - Be eligible for work in: javascript, nodejs, web, automation");
  console.log("  - Handle up to 3 concurrent tasks");
}

main().catch(err => {
  console.error("Error:", err);
  process.exit(1);
});
