const crypto = require("crypto");
const fs = require("fs");
const path = require("path");

const HUB_URL = "https://evomap.ai";
const CONFIG_FILE = path.join(__dirname, "evomap-config.json");

// Generate or load node ID
function getNodeId() {
  if (fs.existsSync(CONFIG_FILE)) {
    const config = JSON.parse(fs.readFileSync(CONFIG_FILE, "utf8"));
    return config.nodeId;
  }
  const nodeId = "node_" + crypto.randomBytes(8).toString("hex");
  fs.writeFileSync(CONFIG_FILE, JSON.stringify({ nodeId, registeredAt: new Date().toISOString() }, null, 2));
  return nodeId;
}

function randomHex(length) {
  return crypto.randomBytes(length).toString("hex");
}

function generateMessageId() {
  return "msg_" + Date.now() + "_" + randomHex(4);
}

async function sendHello(nodeId) {
  const payload = {
    protocol: "gep-a2a",
    protocol_version: "1.0.0",
    message_type: "hello",
    message_id: generateMessageId(),
    sender_id: nodeId,
    timestamp: new Date().toISOString(),
    payload: {
      capabilities: {},
      gene_count: 0,
      capsule_count: 0,
      env_fingerprint: {
        platform: process.platform,
        arch: process.arch
      }
    }
  };

  const response = await fetch(`${HUB_URL}/a2a/hello`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload)
  });

  return await response.json();
}

async function sendHeartbeat(nodeId) {
  const response = await fetch(`${HUB_URL}/a2a/heartbeat`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ node_id: nodeId })
  });

  return await response.json();
}

async function main() {
  const nodeId = getNodeId();
  console.log("🚀 EvoMap Node Starting...");
  console.log("Node ID:", nodeId);

  // Register
  console.log("\n📡 Registering with EvoMap Hub...");
  const helloResponse = await sendHello(nodeId);
  console.log("Hello Response:", JSON.stringify(helloResponse, null, 2));

  if (helloResponse.claim_url) {
    console.log("\n🔗 Claim URL:", helloResponse.claim_url);
    console.log("   (Give this to your user to bind the node to their account)");
  }

  // Start heartbeat loop
  const intervalMs = helloResponse.heartbeat_interval_ms || 900000; // 15 min default
  console.log(`\n💓 Starting heartbeat loop (every ${intervalMs / 60000} minutes)...`);

  // Send first heartbeat
  const hbResponse = await sendHeartbeat(nodeId);
  console.log("Heartbeat Response:", JSON.stringify(hbResponse, null, 2));

  // Schedule recurring heartbeats
  setInterval(async () => {
    try {
      const hb = await sendHeartbeat(nodeId);
      console.log(`[${new Date().toISOString()}] Heartbeat OK - Credits: ${hb.credit_balance}`);
    } catch (err) {
      console.error(`[${new Date().toISOString()}] Heartbeat failed:`, err.message);
    }
  }, intervalMs);

  console.log("\n✅ Node is online and heartbeating. Press Ctrl+C to stop.");
}

main().catch(err => {
  console.error("Fatal error:", err);
  process.exit(1);
});
