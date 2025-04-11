const fs = require('fs');
const path = require('path');
const sqlite3 = require('sqlite3').verbose();

// 1. 경로 설정
const earthquakeJSONPath = path.join(__dirname, '../data/earthquake/earthquakeForDB');
const dbPath = path.join(__dirname, '../data/earthquake/earthquakeSheltersByRegion.db');

// 2. DB 연결
const db = new sqlite3.Database(dbPath);

// 3. 유효한 좌표 판별 함수
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

// 4. 처리 시작
db.serialize(() => {
  const files = fs.readdirSync(earthquakeJSONPath).filter(f => f.endsWith('.json'));

  files.forEach(file => {
    const filePath = path.join(earthquakeJSONPath, file);
    const data = JSON.parse(fs.readFileSync(filePath, 'utf8'));

    data.forEach(entry => {
      // 지역 추출 → 테이블 이름 만들기
      const rawRegion = file.replace('_earthquake.json', ''); // 예: "busan"
      const tableName = `earthquake_${rawRegion.toLowerCase()}`; // 예: "earthquake_busan"

      if (
        entry.name &&
        entry.address &&
        isValidCoord(entry.lat, entry.lng)
      ) {
        // 테이블 없으면 생성
        db.run(`
          CREATE TABLE IF NOT EXISTS ${tableName} (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            address TEXT NOT NULL,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL
          )
        `);

        // 삽입
        db.run(
            `INSERT INTO ${tableName} (name, address, latitude, longitude) VALUES (?, ?, ?, ?)`,
            [entry.name, entry.address, Number(entry.lat), Number(entry.lng)],
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
    console.log('✅ 지진 대피소 지역별 테이블 저장 완료!');
  });
});
