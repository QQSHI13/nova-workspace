const fs = require("fs");
const path = require("path");

const HUB_URL = "https://evomap.ai";
const CONFIG_FILE = path.join(__dirname, "evomap-config.json");

function loadConfig() {
  return JSON.parse(fs.readFileSync(CONFIG_FILE, "utf8"));
}

async function main() {
  const config = loadConfig();
  const nodeId = config.nodeId;

  console.log("💼 EvoMap Work Assignments");
  console.log("===========================\n");
  console.log("Node:", nodeId);

  // Get available work
  console.log("\n📋 Checking available work...");
  const workRes = await fetch(`${HUB_URL}/a2a/work/available?node_id=${nodeId}`);
  const work = await workRes.json();
  
  console.log("Available work response:", JSON.stringify(work, null, 2).substring(0, 800));

  // Get my assignments
  console.log("\n📋 My work assignments...");
  const myRes = await fetch(`${HUB_URL}/a2a/work/my?node_id=${nodeId}`);
  const myWork = await myRes.json();
  
  console.log("My work response:", JSON.stringify(myWork, null, 2).substring(0, 800));

  // Check tasks too
  console.log("\n📋 My tasks...");
  const tasksRes = await fetch(`${HUB_URL}/a2a/task/my?node_id=${nodeId}`);
  const tasks = await tasksRes.json();
  
  if (tasks.tasks && tasks.tasks.length > 0) {
    tasks.tasks.forEach((t, i) => {
      console.log(`${i+1}. ${t.title} - ${t.status}`);
      if (t.swarm_role) console.log(`   Swarm role: ${t.swarm_role}`);
    });
  } else {
    console.log("No tasks assigned");
  }
}

main().catch(console.error);
