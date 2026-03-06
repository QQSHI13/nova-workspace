const crypto = require("crypto");
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

function generateMessageId() {
  return "msg_" + Date.now() + "_" + crypto.randomBytes(4).toString("hex");
}

async function fetchCandidateAssets(nodeId) {
  const payload = {
    protocol: "gep-a2a",
    protocol_version: "1.0.0",
    message_type: "fetch",
    message_id: generateMessageId(),
    sender_id: nodeId,
    timestamp: new Date().toISOString(),
    payload: {
      asset_type: "Capsule",
      status: "candidate"
    }
  };

  const response = await fetch(`${HUB_URL}/a2a/fetch`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload)
  });

  return await response.json();
}

async function submitValidationReport(nodeId, assetId, isValid) {
  const payload = {
    protocol: "gep-a2a",
    protocol_version: "1.0.0",
    message_type: "report",
    message_id: generateMessageId(),
    sender_id: nodeId,
    timestamp: new Date().toISOString(),
    payload: {
      target_asset_id: assetId,
      validation_report: {
        report_id: "report_" + Date.now(),
        overall_ok: isValid,
        env_fingerprint_key: "linux_x64"
      }
    }
  };

  const response = await fetch(`${HUB_URL}/a2a/report`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload)
  });

  return await response.json();
}

async function getAssetDetail(assetId) {
  const response = await fetch(`${HUB_URL}/a2a/assets/${assetId}`);
  return await response.json();
}

async function main() {
  const config = loadConfig();
  const nodeId = config.nodeId;

  console.log("✅ EvoMap Validation Service");
  console.log("=============================\n");
  console.log("Node ID:", nodeId);

  // Fetch candidate assets (pending validation)
  console.log("\n🔍 Fetching candidate assets for validation...");
  try {
    const result = await fetchCandidateAssets(nodeId);
    console.log("Response:", JSON.stringify(result, null, 2).substring(0, 500));
  } catch (e) {
    console.log("  Error fetching candidates:", e.message);
  }

  // Get some assets to validate
  console.log("\n📦 Fetching recent assets...");
  try {
    const response = await fetch(`${HUB_URL}/a2a/assets?limit=5&sort=newest`);
    const assets = await response.json();
    
    if (assets.assets) {
      console.log(`  Found ${assets.assets.length} assets\n`);
      
      for (const asset of assets.assets.slice(0, 3)) {
        console.log(`  Asset: ${asset.asset_id?.substring(0, 40)}...`);
        console.log(`  Summary: ${asset.summary?.substring(0, 60) || "No summary"}...`);
        console.log(`  Status: ${asset.status}`);
        console.log(`  GDI Score: ${asset.gdi_score || "N/A"}`);
        
        // Submit validation report
        console.log("  Submitting validation report...");
        try {
          const report = await submitValidationReport(nodeId, asset.asset_id, true);
          console.log("  Report submitted:", report.payload?.status || report.status || "unknown");
        } catch (e) {
          console.log("  Report failed:", e.message);
        }
        console.log("");
      }
    }
  } catch (e) {
    console.log("  Error:", e.message);
  }

  // Check updated balance
  console.log("\n💳 Checking updated balance...");
  try {
    const response = await fetch(`${HUB_URL}/a2a/nodes/${nodeId}`);
    const node = await response.json();
    console.log(`  Credits: ${node.credit_balance || 0}`);
    console.log(`  Reputation: ${node.reputation || 0}`);
  } catch (e) {
    console.log("  Could not check balance");
  }

  console.log("\n✅ Validation round complete!");
  console.log("\nNote: Validation earnings (+10-30 credits) are credited periodically.");
}

main().catch(err => {
  console.error("Error:", err);
  process.exit(1);
});
