const fs = require("fs");
const path = require("path");
const osmParser = require("osm-pbf-parser");

const inputPath = path.join(__dirname, "../data/raw/south-korea-latest.osm.pbf");

// 체크: 파일 존재하는지 확인
if (!fs.existsSync(inputPath)) {
  console.error("❌ .osm.pbf 파일을 찾을 수 없습니다:", inputPath);
  process.exit(1);
}

console.log("📂 OSM 파일 찾음:", inputPath);

const nodes = new Map();
const parser = osmParser();

let batchCount = 0;
let nodeCount = 0;

// 1. 데이터 파싱 시작
parser.on("data", (items) => {
  batchCount++;
  if (batchCount % 100 === 0) {
    console.log(`🔄 ${batchCount}번째 batch 처리 중...`);
  }

  for (const item of items) {
    if (item.type === "node") {
      nodes.set(item.id, { id: item.id, lat: item.lat, lon: item.lon });
      nodeCount++;
      if (nodeCount % 100000 === 0) {
        console.log(`📍 노드 누적 수: ${nodeCount}`);
      }
    }
  }
});

// 2. 파싱 완료
parser.on("end", () => {
  console.log("✅ 파싱 완료!");
  console.log("📦 총 노드 수:", nodes.size);

  const outputPath = path.join(__dirname, "nodes_all.json");
  fs.writeFileSync(outputPath, JSON.stringify(Array.from(nodes.values()), null, 2));
  console.log("💾 저장 완료:", outputPath);
});

// 3. 오류 처리
parser.on("error", (err) => {
  console.error("❌ 파싱 중 에러 발생:", err);
});

// 4. 실행
console.log("🚀 파싱 시작...");
fs.createReadStream(inputPath)
  .on("error", (err) => {
    console.error("❌ 파일 스트림 열기 실패:", err);
  })
  .pipe(parser);
