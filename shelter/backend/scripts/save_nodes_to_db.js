const fs = require("fs");
const readline = require("readline");
const Database = require("better-sqlite3");

const db = new Database("all_nodes.db");
db.exec("CREATE TABLE IF NOT EXISTS nodes (id INTEGER PRIMARY KEY, lat REAL, lon REAL)");
const insert = db.prepare("INSERT OR IGNORE INTO nodes (id, lat, lon) VALUES (?, ?, ?)");

// 트랜잭션으로 묶을 배치 함수
const batchInsert = db.transaction((batch) => {
  for (const node of batch) {
    insert.run(node.id, node.lat, node.lon);
  }
});

const fileStream = fs.createReadStream("nodes_all.json");
const rl = readline.createInterface({ input: fileStream, crlfDelay: Infinity });

let buffer = [];
let count = 0;

console.log("🚀 노드 삽입 시작...");

rl.on("line", (line) => {
  line = line.trim();
  if (line === "[" || line === "]") return;
  if (line.endsWith(",")) line = line.slice(0, -1);

  try {
    const node = JSON.parse(line);
    buffer.push(node);
    count++;

    if (buffer.length >= 10000) {
      batchInsert(buffer);
      buffer = [];
      if (count % 100000 === 0) {
        console.log(`💾 저장된 노드 수: ${count}`);
      }
    }
  } catch (e) {
    console.error("❌ 파싱 오류:", e);
  }
});

rl.on("close", () => {
  if (buffer.length > 0) {
    batchInsert(buffer);
  }
  console.log(`✅ 완료! 총 ${count}개의 노드를 저장했어`);
});
