const fs = require('fs');
const path = require('path');
const sqlite3 = require('sqlite3').verbose();

// 1. 경로 설정
const civilJSONPath = path.join(__dirname, '../data/civil/civilForDB');
const dbPath = path.join(__dirname, '../data/civil/civilShelters.db');

// 2. DB 생성 및 연결
const db = new sqlite3.Database(dbPath);

// 3. 테이블 생성
db.serialize(() => {
  db.run(`DROP TABLE IF EXISTS civil_shelters`);
  db.run(`
    CREATE TABLE IF NOT EXISTS civil_shelters (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      address TEXT NOT NULL,
      latitude REAL NOT NULL,
      longitude REAL NOT NULL,
      region TEXT NOT NULL
    )
  `);

  // 4. JSON 파일 읽기
  const files = fs.readdirSync(civilJSONPath).filter(f => f.endsWith('.json'));

  const stmt = db.prepare(`
    INSERT INTO civil_shelters (name, address, latitude, longitude, region)
    VALUES (?, ?, ?, ?, ?)
  `);

  files.forEach(file => {
    const filePath = path.join(civilJSONPath, file);
    const data = JSON.parse(fs.readFileSync(filePath, 'utf8'));

    data.forEach(entry => {
        const hasValidCoords =
    typeof entry.lat === 'number' &&
    typeof entry.lng === 'number' &&
    !isNaN(entry.lat) &&
    !isNaN(entry.lng);

  if (
    entry.name &&
    entry.address &&
    hasValidCoords &&
    entry.region
  ) {
    stmt.run(
      entry.name,
      entry.address,
      entry.lat,
      entry.lng,
      entry.region
    );
  } else {
    console.warn(`⚠️ 누락되었거나 잘못된 데이터 건너뜀: ${JSON.stringify(entry)}`);
  }
      });
    
  });

  stmt.finalize(() => {
    db.close();
    console.log('✅ 민방위 대피소 JSON → SQLite 변환 완료!');
  });
});
