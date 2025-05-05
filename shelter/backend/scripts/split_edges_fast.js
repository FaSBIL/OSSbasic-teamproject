// split_edges_fast.js
const fs = require("fs");
const path = require("path");
const readline = require("readline");
const Database = require("better-sqlite3");

// 1. 지역 정보 설정
const regions = {
  seoul: { top: 37.715, bottom: 37.413, left: 126.734, right: 127.269 },
  busan: { top: 35.3, bottom: 35.0, left: 128.8, right: 129.3 },
  daegu: { top: 35.95, bottom: 35.7, left: 128.4, right: 128.7 },
  incheon: { top: 37.7, bottom: 37.3, left: 126.4, right: 126.9 },
  gwangju: { top: 35.25, bottom: 34.9, left: 126.7, right: 127.1 },
  daejeon: { top: 36.45, bottom: 36.2, left: 127.2, right: 127.6 },
  ulsan: { top: 35.7, bottom: 35.4, left: 129.1, right: 129.5 },
  sejong: { top: 36.7, bottom: 36.4, left: 127.1, right: 127.4 },
  gyeonggi: { top: 38.3, bottom: 36.9, left: 126.6, right: 127.9 },
  gangwon: { top: 38.6, bottom: 37.0, left: 127.3, right: 129.5 },
  chungbuk: { top: 37.2, bottom: 36.0, left: 127.2, right: 128.5 },
  chungnam: { top: 36.9, bottom: 36.0, left: 126.4, right: 127.7 },
  jeonbuk: { top: 36.1, bottom: 35.4, left: 126.5, right: 127.3 },
  jeonnam: { top: 35.3, bottom: 34.0, left: 126.2, right: 127.5 },
  gyeongbuk: { top: 37.3, bottom: 35.6, left: 128.0, right: 129.5 },
  gyeongnam: { top: 35.7, bottom: 34.5, left: 127.5, right: 129.4 },
  jeju: { top: 33.6, bottom: 33.1, left: 126.0, right: 126.9 },
};

const outputDir = path.join(__dirname, "../data/region_graphs");
const regionNodeIds = {};
const dbHandles = {};

// 2. 각 지역 DB 열고 node id 불러오기 + edges 초기화
for (const region of Object.keys(regions)) {
  const dbPath = path.join(outputDir, `region_${region}.db`);
  const db = new Database(dbPath);
  const nodeIds = new Set(
    db.prepare("SELECT id FROM nodes").all().map((row) => row.id)
  );
  db.exec("DELETE FROM edges;"); // 기존 간선 제거

  const insertEdge = db.prepare("INSERT INTO edges (from_id, to_id, distance) VALUES (?, ?, ?)");
  const insertMany = db.transaction((edges) => {
    for (const e of edges) insertEdge.run(e.from, e.to, e.distance);
  });

  regionNodeIds[region] = nodeIds;
  dbHandles[region] = { db, buffer: [], insertMany };
}

console.log("📦 간선 처리 시작...");
const rl = readline.createInterface({
  input: fs.createReadStream("edges_all.json"),
  crlfDelay: Infinity,
});

rl.on("line", (line) => {
  line = line.trim();
  if (line === "[" || line === "]") return;
  if (line.endsWith(",")) line = line.slice(0, -1);

  try {
    const edge = JSON.parse(line);
    for (const region of Object.keys(regions)) {
      const nodeSet = regionNodeIds[region];
      if (nodeSet.has(edge.from) && nodeSet.has(edge.to)) {
        dbHandles[region].buffer.push(edge);
        if (dbHandles[region].buffer.length >= 10000) {
          dbHandles[region].insertMany(dbHandles[region].buffer);
          dbHandles[region].buffer = [];
        }
      }
    }
  } catch (err) {
    console.error("❌ 간선 파싱 오류:", err);
  }
});

rl.on("close", () => {
  for (const region of Object.keys(dbHandles)) {
    const handle = dbHandles[region];
    if (handle.buffer.length > 0) handle.insertMany(handle.buffer);
    handle.db.close();
    console.log(`✅ ${region} 완료`);
  }
  console.log("🎉 간선 삽입 완료");
});
