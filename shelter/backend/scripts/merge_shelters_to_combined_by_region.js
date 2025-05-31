const fs = require('fs');
const path = require('path');
const Database = require('better-sqlite3');

// SQLite DB 파일 경로
const db = new Database(path.join(__dirname, '../db/combined_shelters.db'));

// 지역명 매핑 테이블
const regionNameMap = {
  '서울특별시': 'seoul',
  '부산광역시': 'busan',
  '대구광역시': 'daegu',
  '인천광역시': 'incheon',
  '광주광역시': 'gwangju',
  '대전광역시': 'daejeon',
  '울산광역시': 'ulsan',
  '세종특별자치시': 'sejong',
  '경기도': 'gyeonggi',
  '강원도': 'gangwon',
  '강원특별자치도': 'gangwon',
  '충청북도': 'chungbuk',
  '충청남도': 'chungnam',
  '전라북도': 'jeonbuk',
  '전라남도': 'jeonnam',
  '경상북도': 'gyeongbuk',
  '경상남도': 'gyeongnam',
  '제주특별자치도': 'jeju'
};

// 저장할 테이블 목록
const regionTables = Object.values(regionNameMap);

// 테이블 생성 (없으면 생성)
regionTables.forEach(table => {
  db.prepare(`
    CREATE TABLE IF NOT EXISTS ${table} (
      id TEXT PRIMARY KEY,
      name TEXT,
      address TEXT,
      latitude REAL,
      longitude REAL,
      isFavorite INTEGER DEFAULT 0,
      earthquake INTEGER DEFAULT 0,
      tsunami INTEGER DEFAULT 0,
      civil INTEGER DEFAULT 0
    )
  `).run();
});

// 중복 제거용 ID 저장용
const shelterIdSet = new Set();

// 각 JSON 종류별 디렉토리 경로
const quakeDir = path.join(__dirname, '../data/earthquake/earthquakeForDB');
const civilDir = path.join(__dirname, '../data/civil/civilForDB');
const tsunamiFile = path.join(__dirname, '../data/tsunami/tsunamiForDB/shelters_tsunami_deduped.json');

// 함수: 파일 읽고 삽입
function insertShelters(filePath, typeFlag) {
  const raw = fs.readFileSync(filePath, 'utf-8');
  const shelters = JSON.parse(raw);

  shelters.forEach(shelter => {
    const regionKey = Object.keys(regionNameMap).find(key => shelter.address.startsWith(key));
    if (!regionKey) {
      console.warn(`⚠️ ${typeFlag} 알 수 없는 지역: ${shelter.address}`);
      return;
    }
    const region = regionNameMap[regionKey];
    const id = shelter.id || `${region}_${shelter.name}_${shelter.address}`;

    if (!shelterIdSet.has(id)) {
      shelterIdSet.add(id);
      db.prepare(`
        INSERT OR IGNORE INTO ${region} (id, name, address, latitude, longitude, earthquake, tsunami, civil)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
      `).run(
        id,
        shelter.name,
        shelter.address,
        shelter.latitude,
        shelter.longitude,
        typeFlag === 'earthquake' ? 1 : 0,
        typeFlag === 'tsunami' ? 1 : 0,
        typeFlag === 'civil' ? 1 : 0
      );
    } else {
      db.prepare(`
        UPDATE ${region}
        SET
          earthquake = earthquake OR ?,
          tsunami = tsunami OR ?,
          civil = civil OR ?
        WHERE id = ?
      `).run(
        typeFlag === 'earthquake' ? 1 : 0,
        typeFlag === 'tsunami' ? 1 : 0,
        typeFlag === 'civil' ? 1 : 0,
        id
      );
    }
  });
}

// ① 지진 파일 처리
fs.readdirSync(quakeDir).forEach(file => {
  if (file.endsWith('.json')) {
    insertShelters(path.join(quakeDir, file), 'earthquake');
  }
});

// ② 민방위 파일 처리
fs.readdirSync(civilDir).forEach(file => {
  if (file.endsWith('.json')) {
    insertShelters(path.join(civilDir, file), 'civil');
  }
});

// ③ 쓰나미 파일 처리
insertShelters(tsunamiFile, 'tsunami');

console.log('✅ 지역별 shelter 병합 완료');
