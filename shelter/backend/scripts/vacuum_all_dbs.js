// vacuum_all_dbs.js
const fs = require("fs");
const path = require("path");
const Database = require("better-sqlite3");

const dbDir = path.join(__dirname, "../data/region_graphs");
const dbFiles = fs.readdirSync(dbDir).filter(f => f.endsWith(".db"));

console.log("🧹 VACUUM 최적화 시작...");

for (const file of dbFiles) {
  const fullPath = path.join(dbDir, file);
  try {
    const beforeSize = fs.statSync(fullPath).size;

    const db = new Database(fullPath);
    db.exec("VACUUM;");
    db.close();

    const afterSize = fs.statSync(fullPath).size;
    const percent = ((1 - afterSize / beforeSize) * 100).toFixed(2);

    console.log(`✅ ${file} 최적화 완료: ${(beforeSize / 1_048_576).toFixed(1)}MB → ${(afterSize / 1_048_576).toFixed(1)}MB (${percent}% 감소)`);
  } catch (err) {
    console.error(`❌ ${file} 처리 중 오류:`, err.message);
  }
}

console.log("🎉 모든 지역 DB에 VACUUM 완료!");