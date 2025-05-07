// split_to_regions.js
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

// 2. 지역별 노드/간선 임시 구조
const regionNodes = {}, regionNodeIds = {}, dbHandles = {};
for (const region of Object.keys(regions)) {
  regionNodes[region] = [];
  regionNodeIds[region] = new Set();
}

// 3. 출력 폴더 설정
const outputDir = path.join(__dirname, "../data/region_graphs");
if (!fs.existsSync(outputDir)) {
  fs.mkdirSync(outputDir, { recursive: true });
}

// 4. 노드 분배
const nodeStream = fs.createReadStream("nodes_all.json");
const rlNodes = readline.createInterface({ input: nodeStream });

rlNodes.on("line", (line) => {
  line = line.trim();
  if (line === "[" || line === "]") return;
  if (line.endsWith(",")) line = line.slice(0, -1);

  try {
    const node = JSON.parse(line);
    for (const [region, box] of Object.entries(regions)) {
      if (
        node.lat <= box.top &&
        node.lat >= box.bottom &&
        node.lon >= box.left &&
        node.lon <= box.right
      ) {
        regionNodes[region].push(node);
        regionNodeIds[region].add(node.id);
      }
    }
  } catch (e) {
    console.error("❌ 노드 파싱 에러:", e);
  }
});

rlNodes.on("close", () => {
  console.log("✅ 노드 분배 완료. 지역별 DB 생성...");

  for (const region of Object.keys(regions)) {
    const dbPath = path.join(outputDir, `region_${region}.db`);
    const db = new Database(dbPath);
    db.exec(`
      CREATE TABLE IF NOT EXISTS nodes (id INTEGER PRIMARY KEY, lat REAL, lon REAL);
      CREATE TABLE IF NOT EXISTS edges (from_id INTEGER, to_id INTEGER, distance REAL);
    `);
    const insertNode = db.prepare("INSERT OR IGNORE INTO nodes (id, lat, lon) VALUES (?, ?, ?)");
    const insertEdge = db.prepare("INSERT INTO edges (from_id, to_id, distance) VALUES (?, ?, ?)");

    // 🚀 트랜잭션으로 최적화된 노드 삽입
    const insertManyNodes = db.transaction((nodes) => {
      for (const n of nodes) {
        insertNode.run(n.id, n.lat, n.lon);
      }
    });
    insertManyNodes(regionNodes[region]);

    dbHandles[region] = { db, insertEdge };
  }

  console.log("✅ DB 초기화 완료. 간선 처리 시작...");

  const edgeStream = fs.createReadStream("edges_all.json");
  const rlEdges = readline.createInterface({ input: edgeStream });

  rlEdges.on("line", (line) => {
    line = line.trim();
    if (line === "[" || line === "]") return;
    if (line.endsWith(",")) line = line.slice(0, -1);

    try {
      const edge = JSON.parse(line);
      for (const region of Object.keys(regions)) {
        if (
          regionNodeIds[region].has(edge.from) &&
          regionNodeIds[region].has(edge.to)
        ) {
          dbHandles[region].insertEdge.run(edge.from, edge.to, edge.distance);
        }
      }
    } catch (e) {
      console.error("❌ 간선 파싱 에러:", e);
    }
  });

  rlEdges.on("close", () => {
    for (const region of Object.keys(regions)) {
      dbHandles[region].db.close();
      console.log(`✅ ${region} 저장 완료`);
    }
    console.log("🎉 모든 지역 DB 분할 완료!");
  });
});
