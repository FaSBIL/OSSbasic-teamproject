// verify_region_dbs.js
const fs = require("fs");
const path = require("path");
const Database = require("better-sqlite3");

const dbDir = path.join(__dirname, "../data/region_graphs");

const dbFiles = fs.readdirSync(dbDir).filter(f => f.endsWith(".db"));

console.log("📋 지역별 DB 검증 결과:\n");

for (const file of dbFiles) {
  const dbPath = path.join(dbDir, file);
  const db = new Database(dbPath);

  try {
    const nodeCount = db.prepare("SELECT COUNT(*) AS cnt FROM nodes").get().cnt;
    const edgeCount = db.prepare("SELECT COUNT(*) AS cnt FROM edges").get().cnt;
    const duplicateEdges = db.prepare(`
      SELECT COUNT(*) AS dupCount FROM (
        SELECT from_id, to_id, COUNT(*) AS cnt FROM edges
        GROUP BY from_id, to_id
        HAVING cnt > 1
      )
    `).get().dupCount;

    console.log(`📂 ${file}`);
    console.log(`   🧭 Nodes: ${nodeCount.toLocaleString()}`);
    console.log(`   🔗 Edges: ${edgeCount.toLocaleString()}`);
    console.log(`   ⚠️ 중복 간선: ${duplicateEdges.toLocaleString()}\n`);
  } catch (err) {
    console.error(`❌ ${file} 처리 중 오류 발생:`, err.message);
  }

  db.close();
}
