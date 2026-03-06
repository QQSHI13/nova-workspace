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

async function fetchTasksWithBounties(nodeId) {
  const payload = {
    protocol: "gep-a2a",
    protocol_version: "1.0.0",
    message_type: "fetch",
    message_id: generateMessageId(),
    sender_id: nodeId,
    timestamp: new Date().toISOString(),
    payload: {
      asset_type: null,
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

async function claimTask(nodeId, taskId) {
  const response = await fetch(`${HUB_URL}/a2a/task/claim`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      task_id: taskId,
      node_id: nodeId
    })
  });
  return await response.json();
}

async function listBounties() {
  const response = await fetch(`${HUB_URL}/bounty/list?status=open&limit=10`);
  return await response.json();
}

async function checkAvailableWork(nodeId) {
  const response = await fetch(`${HUB_URL}/a2a/work/available?node_id=${nodeId}`);
  return await response.json();
}

async function main() {
  const config = loadConfig();
  const nodeId = config.nodeId;

  console.log("💰 EvoMap Credit Hunter");
  console.log("=======================\n");
  console.log("Node ID:", nodeId);

  // Check available work first
  console.log("\n📋 Checking Available Work...");
  try {
    const work = await checkAvailableWork(nodeId);
    if (work.assignments && work.assignments.length > 0) {
      console.log(`  Found ${work.assignments.length} work assignments!`);
      work.assignments.forEach((a, i) => {
        console.log(`  ${i+1}. ${a.title} - ${a.status}`);
      });
    } else {
      console.log("  No work assignments yet");
    }
  } catch (e) {
    console.log("  Could not check work:", e.message);
  }

  // Fetch tasks from A2A protocol
  console.log("\n🎯 Fetching Tasks via A2A...");
  try {
    const result = await fetchTasksWithBounties(nodeId);
    if (result.payload && result.payload.tasks && result.payload.tasks.length > 0) {
      const openTasks = result.payload.tasks.filter(t => t.status === "open");
      console.log(`  Found ${openTasks.length} open tasks\n`);
      
      openTasks.slice(0, 5).forEach((task, i) => {
        console.log(`  ${i+1}. ${task.title}`);
        console.log(`     Signals: ${task.signals || "none"}`);
        console.log(`     Min Reputation: ${task.min_reputation || 0}`);
        console.log(`     Expires: ${task.expires_at ? new Date(task.expires_at).toLocaleDateString() : "N/A"}`);
        console.log("");
      });

      // Try to claim first eligible task
      const eligibleTask = openTasks.find(t => (t.min_reputation || 0) === 0);
      if (eligibleTask) {
        console.log(`\n🔒 Attempting to claim: ${eligibleTask.title}`);
        try {
          const claim = await claimTask(nodeId, eligibleTask.task_id);
          console.log("Claim Result:", JSON.stringify(claim, null, 2));
        } catch (e) {
          console.log("  Claim failed:", e.message);
        }
      }
    } else {
      console.log("  No tasks available via A2A fetch");
    }
  } catch (e) {
    console.log("  Error:", e.message);
  }

  // Check bounties
  console.log("\n💎 Checking Bounties...");
  try {
    const bounties = await listBounties();
    if (bounties.bounties && bounties.bounties.length > 0) {
      console.log(`  Found ${bounties.bounties.length} open bounties\n`);
      bounties.bounties.slice(0, 5).forEach((b, i) => {
        console.log(`  ${i+1}. ${b.title}`);
        console.log(`     Amount: ${b.amount} credits`);
        console.log(`     Signals: ${b.signals || "none"}`);
        console.log("");
      });
    } else {
      console.log("  No open bounties");
    }
  } catch (e) {
    console.log("  Error:", e.message);
  }

  // Check credits
  console.log("\n💳 Checking Credit Balance...");
  try {
    const response = await fetch(`${HUB_URL}/a2a/nodes/${nodeId}`);
    const node = await response.json();
    console.log(`  Current Balance: ${node.credit_balance || 0} credits`);
    console.log(`  Reputation: ${node.reputation || 0}`);
    console.log(`  Assets Published: ${node.capsule_count || 0}`);
  } catch (e) {
    console.log("  Could not fetch balance");
  }

  console.log("\n✅ Exploration complete!");
  console.log("\nWays to earn:");
  console.log("  1. Wait for worker task assignments (heartbeat will notify)");
  console.log("  2. Claim bounty tasks and solve them");
  console.log("  3. Publish your solutions for others to reuse");
  console.log("  4. Validate other agents' assets (+10-30 credits)");
}

main().catch(err => {
  console.error("Error:", err);
  process.exit(1);
});
