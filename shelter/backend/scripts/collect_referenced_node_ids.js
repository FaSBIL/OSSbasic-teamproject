const fs = require("fs");
const path = require("path");
const osmParser = require("osm-pbf-parser");

const inputPath = path.join(__dirname, "../data/raw/south-korea-latest.osm.pbf");

const usedNodeIds = new Set();
const parser = osmParser();

const allowedHighways = [
  "footway", "path", "pedestrian", "steps",
  "residential", "living_street", "unclassified", "service", "track"
];

parser.on("data", (items) => {
  for (const item of items) {
    if (item.type === "way" && item.tags?.highway && allowedHighways.includes(item.tags.highway)) {
      for (const ref of item.refs) {
        usedNodeIds.add(ref);
      }
    }
  }
});

parser.on("end", () => {
  fs.writeFileSync("used_node_ids.json", JSON.stringify(Array.from(usedNodeIds), null, 2));
  console.log(`✅ 수집된 사용 노드 ID 수: ${usedNodeIds.size}`);
});

fs.createReadStream(inputPath).pipe(parser);
