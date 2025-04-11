const fs = require('fs');
const path = require('path');
const sqlite3 = require('sqlite3').verbose();

// 경로 설정
const jsonPath = path.join(__dirname, '../data/tsunami/tsunamiForDB/shelters_tsunami_deduped.json');
const dbPath = path.join(__dirname, '../data/tsunami/tsunamiShelters.db');

// DB 연결
const db = new sqlite3.Database(dbPath);

// 유효성 검사 함수
function isValidCoord(lat, lng) {
  return (
    typeof lat === 'number' &&
    typeof lng === 'number' &&
    !isNaN(lat) &&
    !isNaN(lng)
  );
}

// 실행
db.serialize(() => {
  const data = JSON.parse(fs.readFileSync(jsonPath, 'utf8'));

  db.run(`DROP TABLE IF EXISTS tsunami_shelters`);
  db.run(`
    CREATE TABLE IF NOT EXISTS tsunami_shelters (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      address TEXT NOT NULL,
      latitude REAL NOT NULL,
      longitude REAL NOT NULL,
      region TEXT NOT NULL
    )
  `);

  const stmt = db.prepare(`
    INSERT INTO tsunami_shelters (name, address, latitude, longitude, region)
    VALUES (?, ?, ?, ?, ?)
  `);

  data.forEach(entry => {
    if (
      entry.name &&
      entry.address &&
      isValidCoord(entry.lat, entry.lng) &&
      entry.region
    ) {
      stmt.run(entry.name, entry.address, entry.lat, entry.lng, entry.region);
    } else {
      console.warn(`⚠️ 누락 또는 오류로 건너뜀: ${JSON.stringify(entry)}`);
    }
  });

  stmt.finalize(() => {
    db.close();
    console.log('✅ 지진해일 대피소 DB 생성 완료!');
  });
});
