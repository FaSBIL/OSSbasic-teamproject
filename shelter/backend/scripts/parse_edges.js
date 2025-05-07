const fs = require("fs");
const path = require("path");
const Database = require("better-sqlite3");
const osmParser = require("osm-pbf-parser");
const haversine = require("haversine-distance");

const inputPath = path.join(__dirname, "../data/raw/south-korea-latest.osm.pbf");

// 1. SQLite에서 노드 불러오기
const db = new Database("all_nodes.db");
const nodeMap = new Map();
for (const row of db.prepare("SELECT id, lat, lon FROM nodes").iterate()) {
  nodeMap.set(row.id, row);
}
console.log("📦 불러온 노드 수:", nodeMap.size);

// 2. 허용된 도로 타입 정의
const allowedHighways = [
  "footway", "path", "pedestrian", "steps",
  "residential", "living_street", "unclassified", "service", "track"
];

// 3. 출력 스트림 설정
const out = fs.createWriteStream("edges_all.json");
out.write("[\n");

let first = true;
let count = 0;

// 4. OSM 파서
const parser = osmParser();
parser.on("data", (items) => {
  for (const item of items) {
    if (item.type === "way" && item.tags?.highway && allowedHighways.includes(item.tags.highway)) {
      const refs = item.refs;
      for (let i = 0; i < refs.length - 1; i++) {
        const from = nodeMap.get(refs[i]);
        const to = nodeMap.get(refs[i + 1]);

        if (from && to) {
          const dist = haversine({ lat: from.lat, lon: from.lon }, { lat: to.lat, lon: to.lon });

          // 양방향 간선 2개 작성
          const edge1 = JSON.stringify({ from: from.id, to: to.id, distance: dist });
          const edge2 = JSON.stringify({ from: to.id, to: from.id, distance: dist });

          if (!first) out.write(",\n");
          out.write(edge1 + ",\n" + edge2);
          first = false;

          count += 2;
          if (count % 100000 === 0) {
            console.log(`🔁 누적 간선 수: ${count}`);
          }
        }
      }
    }
  }
});

parser.on("end", () => {
  out.write("\n]");
  out.end();
  console.log(`✅ edges_all.json 저장 완료! 총 간선 수: ${count}`);
});

fs.createReadStream(inputPath).pipe(parser);
