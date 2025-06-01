const fs = require('fs');
const sqlite3 = require('sqlite3').verbose();

// 1. SQLite 연결
const db = new sqlite3.Database('./shelters.db');

// 2. JSON 파일 읽기
const rawData = fs.readFileSync('./busan_shelters.json', 'utf8');
const shelters = JSON.parse(rawData);

// 3. 테이블 생성
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

// 4. 데이터 삽입
const stmt = db.prepare(`
  INSERT INTO shelters (name, address, latitude, longitude, region)
  VALUES (?, ?, ?, ?, ?)
`);

shelters.forEach((shelter) => {
  stmt.run(shelter.name, shelter.address, shelter.lat, shelter.lng, shelter.region);
});

stmt.finalize();

// 5. 종료
db.close(() => {
  console.log('📦 대피소 데이터가 성공적으로 삽입되었습니다!');
});
