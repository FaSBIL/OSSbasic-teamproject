const fs = require('fs');
const path = require('path');
const sqlite3 = require('sqlite3').verbose();

// 1. 경로 설정
const civilJSONPath = path.join(__dirname, '../data/civil/civilForDB');
const dbPath = path.join(__dirname, '../data/civil/civilSheltersByRegion.db');

// 2. DB 연결
const db = new sqlite3.Database(dbPath);

// 3. 유효한 좌표 판별 함수
function isValidCoord(lat, lng) {
  return (
    typeof lat === 'number' &&
    typeof lng === 'number' &&
    !isNaN(lat) &&
    !isNaN(lng)
  );
}

// 4. 파일별로 처리
db.serialize(() => {
  const files = fs.readdirSync(civilJSONPath).filter(f => f.endsWith('.json'));

  files.forEach(file => {
    const filePath = path.join(civilJSONPath, file);
    const data = JSON.parse(fs.readFileSync(filePath, 'utf8'));

    data.forEach(entry => {
      const region = (entry.region || 'unknown')
        .replace(/[\s특별광역자치도시군]/g, '') // 예: 서울특별시 → 서울
        .toLowerCase();                          // 테이블 이름용으로 소문자 처리
      const tableName = `civil_${region}`;

      // 유효성 검증
      if (
        entry.name &&
        entry.address &&
        isValidCoord(entry.lat, entry.lng) &&
        region
      ) {
        // 테이블이 없으면 생성
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
        db.run(
          `INSERT INTO ${tableName} (name, address, latitude, longitude) VALUES (?, ?, ?, ?)`,
          [entry.name, entry.address, entry.lat, entry.lng],
          function (err) {
            if (err) {
              console.error(`❌ [${tableName}] 삽입 실패: ${JSON.stringify(entry)}\n에러: ${err.message}`);
            }
          }
        );
      } else {
        console.warn(`⚠️ 누락 또는 오류로 건너뜀: ${JSON.stringify(entry)}`);
      }
    });
  });

  db.close(() => {
    console.log('✅ 민방위 대피소 지역별 테이블 저장 완료!');
  });
});
