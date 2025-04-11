const fs = require('fs');
const path = require('path');
const sqlite3 = require('sqlite3').verbose();

const regionToTableMap = {
  '서울특별시': 'civil_seoul',
  '부산광역시': 'civil_busan',
  '대구광역시': 'civil_daegu',
  '인천광역시': 'civil_incheon',
  '광주광역시': 'civil_gwangju',
  '대전광역시': 'civil_daejeon',
  '울산광역시': 'civil_ulsan',
  '세종특별자치시': 'civil_sejong',
  '경기도': 'civil_gyeonggi',
  '강원특별자치도': 'civil_gangwon',
  '충청북도': 'civil_chungbuk',
  '충청남도': 'civil_chungnam',
  '전북특별자치도': 'civil_jeonbuk',
  '전라남도': 'civil_jeonnam',
  '경상북도': 'civil_gyeongbuk',
  '경상남도': 'civil_gyeongnam',
  '제주특별자치도': 'civil_jeju'
};

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
      // 🔧 [수정됨] 지역명을 기반으로 영어 테이블명 결정
      const rawRegion = entry.region?.trim();
      const tableName = regionToTableMap[rawRegion];

      // 🔧 [수정됨] 매핑되지 않은 지역은 건너뜀
      if (!tableName) {
        console.warn(`⚠️ region 이름 인식 불가: "${rawRegion}" → 건너뜀`);
        return;
      }

      // 유효성 검증
      if (
        entry.name &&
        entry.address &&
        isValidCoord(entry.lat, entry.lng)
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
