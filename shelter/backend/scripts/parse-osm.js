const fs = require('fs');
const sqlite3 = require('sqlite3').verbose();

// 1. SQLite DB 연결
const db = new sqlite3.Database('./shelters.db');

// 2. JSON 파일 읽기
const rawData = fs.readFileSync('./processed_shelters.json');
const shelters = JSON.parse(rawData);

// 3. 테이블 생성 (없으면)
db.run(`
  CREATE TABLE IF NOT EXISTS shelters (
    id INTEGER PRIMARY KEY,
    name TEXT,
    latitude REAL,
    longitude REAL
  )
`);

// 4. 데이터 삽입
shelters.forEach((shelter) => {
  db.run(
    `INSERT INTO shelters (id, name, latitude, longitude) VALUES (?, ?, ?, ?)`,
    [shelter.id, shelter.name, shelter.latitude, shelter.longitude]
  );
});

// 5. 종료
db.close();
