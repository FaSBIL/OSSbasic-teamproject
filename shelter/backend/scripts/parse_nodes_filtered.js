const fs = require("fs");
const path = require("path");
const osmParser = require("osm-pbf-parser");

const inputPath = path.join(__dirname, "../data/raw/south-korea-latest.osm.pbf");
const usedIds = new Set(JSON.parse(fs.readFileSync("used_node_ids.json"))); // 1단계에서 미리 수집된 node ID들

const parser = osmParser();

let filteredCount = 0;
let first = true;
const stream = fs.createWriteStream("nodes_all.json");
stream.write("[\n");

parser.on("data", (items) => {
  for (const item of items) {
    if (item.type === "node" && usedIds.has(item.id)) {
      const nodeStr = JSON.stringify({ id: item.id, lat: item.lat, lon: item.lon });

      if (!first) {
        stream.write(",\n");
      }
      stream.write(nodeStr);

      first = false;
      filteredCount++;
      if (filteredCount % 100000 === 0) {
        console.log(`📍 필터링된 노드 수: ${filteredCount}`);
      }
    }
  }
});

parser.on("end", () => {
  stream.write("\n]");
  stream.end();
  console.log(`✅ 저장 완료! 총 노드 수: ${filteredCount}`);
});

fs.createReadStream(inputPath)
  .on("error", (err) => {
    console.error("❌ 파일 열기 실패:", err);
  })
  .pipe(parser);
