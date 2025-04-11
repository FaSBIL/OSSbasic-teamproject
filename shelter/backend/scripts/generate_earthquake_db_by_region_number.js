const fs = require('fs');
const path = require('path');
const sqlite3 = require('sqlite3').verbose();

// 지진 대피소 JSON 파일이 있는 경로
const earthquakeJSONPath = path.join(__dirname, '../data/earthquake/earthquakeForDB');

// DB 파일 경로
const dbPath = path.join(__dirname, '../data/earthquake/earthquakeSheltersByRegion.db');

// SQLite DB 연결
const db = new sqlite3.Database(dbPath);

// 위도/경도 유효성 검사 함수
function isValidCoord(lat, lng) {
  const numLat = Number(lat);
  const numLng = Number(lng);
  return (
    typeof numLat === 'number' &&
    typeof numLng === 'number' &&
    !isNaN(numLat) &&
    !isNaN(numLng)
  );
}

db.serialize(() => {
  const files = fs.readdirSync(earthquakeJSONPath).filter(f => f.endsWith('.json'));

  files.forEach(file => {
    const filePath = path.join(earthquakeJSONPath, file);
    const data = JSON.parse(fs.readFileSync(filePath, 'utf8'));

    // 예: gyeonggi_earthquake.json → earthquake_gyeonggi
    const rawRegion = file.replace('_earthquake.json', '');
    const tableName = `earthquake_${rawRegion.toLowerCase()}`;

    // 테이블 생성 (없으면)
    db.run(`
      CREATE TABLE IF NOT EXISTS ${tableName} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        address TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL
      )
    `);

    // 데이터 삽입
    data.forEach(entry => {
      const lat = Number(entry.lat);
      const lng = Number(entry.lng);

      if (
        entry.name &&
        entry.address &&
        isValidCoord(entry.lat, entry.lng)
      ) {
        db.run(
          `INSERT INTO ${tableName} (name, address, latitude, longitude) VALUES (?, ?, ?, ?)`,
          [entry.name, entry.address, lat, lng],
          function (err) {
            if (err) {
              console.error(`❌ [${tableName}] 삽입 실패: ${JSON.stringify(entry)}\n에러: ${err.message}`);
            }
          }
        );
      } else {
        console.warn(`⚠️ 누락되었거나 잘못된 데이터 건너뜀: ${JSON.stringify(entry)}`);
      }
    });
  });

  db.close(() => {
    console.log('✅ 지진 대피소 지역별 테이블 생성 및 데이터 저장 완료!');
  });
});
