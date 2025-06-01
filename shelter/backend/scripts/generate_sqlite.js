const fs = require('fs');
const path = require('path');
const sqlite3 = require('sqlite3').verbose();

// DB 파일 경로
const dbPath = path.join(__dirname, '../data/shelters.db');
const refinedPath = path.join(__dirname, '../data/processed/refinedJSON');

// 1. DB 연결
const db = new sqlite3.Database(dbPath);

// 2. shelters 테이블 생성
db.serialize(() => {
  db.run(`DROP TABLE IF EXISTS shelters`);
  db.run(`
    CREATE TABLE IF NOT EXISTS shelters (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      address TEXT NOT NULL,
      latitude REAL NOT NULL,
      longitude REAL NOT NULL,
      region TEXT NOT NULL
    )
  `);

  // 3. refinedJSON 폴더 내 모든 .json 파일 읽기
  const files = fs.readdirSync(refinedPath).filter(file => file.endsWith('.json'));

  const insertStmt = db.prepare(`
    INSERT INTO shelters (name, address, latitude, longitude, region)
    VALUES (?, ?, ?, ?, ?)
  `);

  files.forEach(file => {
    const region = file.replace('.json', '');
    const fullPath = path.join(refinedPath, file);
    const data = JSON.parse(fs.readFileSync(fullPath, 'utf8'));

    data.forEach(entry => {
      insertStmt.run(entry.name, entry.address, entry.lat, entry.lng, entry.region || region);
    });
  });

  insertStmt.finalize(() => {
    console.log(`✅ 모든 JSON 파일을 SQLite로 변환 완료!`);
    db.close();
  });
});
