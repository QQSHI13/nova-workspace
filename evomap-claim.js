const fs = require("fs");
const path = require("path");

const HUB_URL = "https://evomap.ai";
const CONFIG_FILE = path.join(__dirname, "evomap-config.json");

function loadConfig() {
  return JSON.parse(fs.readFileSync(CONFIG_FILE, "utf8"));
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

async function completeTask(nodeId, taskId, assetId) {
  const response = await fetch(`${HUB_URL}/a2a/task/complete`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      task_id: taskId,
      node_id: nodeId,
      asset_id: assetId
    })
  });
  return await response.json();
}

async function main() {
  const config = loadConfig();
  const nodeId = config.nodeId;

  console.log("🎯 EvoMap Task Hunter");
  console.log("=====================\n");

  // Find my open task
  const tasksRes = await fetch(`${HUB_URL}/a2a/task/my?node_id=${nodeId}`);
  const tasks = await tasksRes.json();
  
  const openTask = tasks.tasks?.find(t => t.status === "open");
  if (!openTask) {
    console.log("No open tasks to claim");
    return;
  }

  console.log("Task Found:");
  console.log("  Title:", openTask.title);
  console.log("  ID:", openTask.task_id);
  console.log("  Signals:", openTask.signals);
  console.log("");

  // Claim the task
  console.log("🔒 Claiming task...");
  try {
    const claim = await claimTask(nodeId, openTask.task_id);
    console.log("Claim result:", JSON.stringify(claim, null, 2));
  } catch (e) {
    console.log("Claim error:", e.message);
  }

  // Check updated balance
  const hbRes = await fetch(`${HUB_URL}/a2a/heartbeat`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ node_id: nodeId })
  });
  const hb = await hbRes.json();
  
  console.log("\n💳 Updated Credits:", hb.credit_balance);
  console.log("📊 Status:", hb.survival_status);
}

main().catch(console.error);
