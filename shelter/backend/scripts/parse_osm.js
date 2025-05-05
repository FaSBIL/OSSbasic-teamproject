const fs = require("fs");
const path = require("path");
const osmParser = require("osm-pbf-parser");
const haversine = require("haversine-distance");

const inputPath = path.join(__dirname, "../data/raw/south-korea-latest.osm.pbf");

const nodes = new Map();
const ways = [];

console.log("📦 Parsing started...");

const parser = osmParser();

// Step 1: 수집
parser.on("data", (items) => {
  for (const item of items) {
    if (item.type === "node") {
      nodes.set(item.id, { id: item.id, lat: item.lat, lon: item.lon });
    }

    if (item.type === "way" && item.tags && item.tags.highway) {
      ways.push(item);
    }
  }
});

// Step 2: 간선 생성
parser.on("end", () => {
  const edges = [];

  for (const way of ways) {
    const refs = way.refs;

    for (let i = 0; i < refs.length - 1; i++) {
      const from = nodes.get(refs[i]);
      const to = nodes.get(refs[i + 1]);

      if (from && to) {
        const distance = haversine(
          { lat: from.lat, lon: from.lon },
          { lat: to.lat, lon: to.lon }
        );

        edges.push({ from: from.id, to: to.id, distance });
        edges.push({ from: to.id, to: from.id, distance }); // 양방향 도로
      }
    }
  }

  console.log(`✅ 총 노드 수: ${nodes.size}, 간선 수: ${edges.length}`);

  fs.writeFileSync("nodes.json", JSON.stringify(Array.from(nodes.values()), null, 2));
  fs.writeFileSync("edges.json", JSON.stringify(edges, null, 2));

  console.log("📁 nodes.json & edges.json 저장 완료!");
});

fs.createReadStream(inputPath).pipe(parser);
