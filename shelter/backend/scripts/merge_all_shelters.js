const fs = require('fs');
const path = require('path');
const Database = require('better-sqlite3');

// DB 파일 생성
const db = new Database('shelters.db');

// 지역 리스트
const regions = [
  'busan', 'chungbuk', 'chungnam', 'daegu', 'daejeon',
  'gangwon', 'gwangju', 'gyeongbuk', 'gyeonggi', 'gyeongnam',
  'incheon', 'jeju', 'jeonbuk', 'jeonnam', 'sejong', 'seoul', 'ulsan'
];

// 소스 폴더 경로들
const civilPath = path.join(__dirname, '../data/civil/civilForDB');
const eqPath = path.join(__dirname, '../data/earthquake/earthquakeForDB');
const tsuPath = path.join(__dirname, '../data/tsunami/tsunamiForDB/by_region_tsunami');

// 테이블 생성
function createTable(region) {
  db.prepare(`
    CREATE TABLE IF NOT EXISTS ${region} (
      name TEXT,
      address TEXT,
      latitude REAL,
      longitude REAL,
      isFavorite INTEGER DEFAULT 0,
      civil INTEGER DEFAULT 0,
      earthquake INTEGER DEFAULT 0,
      tsunami INTEGER DEFAULT 0,
      UNIQUE(name, address)
    )
  `).run();
}

// 삽입 함수
function insertShelters(region, shelters, type) {
  const insertStmt = db.prepare(`
    INSERT OR IGNORE INTO ${region} (name, address, latitude, longitude, isFavorite, civil, earthquake, tsunami)
    VALUES (?, ?, ?, ?, 0, ?, ?, ?)
  `);

  const updateStmt = db.prepare(`
    UPDATE ${region} SET
      civil = civil OR ?,
      earthquake = earthquake OR ?,
      tsunami = tsunami OR ?
    WHERE name = ? AND address = ?
  `);

  let count = 0;
  for (const shelter of shelters) {
    const name = shelter.name || '';
    const address = shelter.address || '';
    const latitude =
      typeof shelter.latitude === 'number' ? shelter.latitude :
      typeof shelter.lat === 'number' ? shelter.lat : 0.0;
    const longitude =
      typeof shelter.longitude === 'number' ? shelter.longitude :
      typeof shelter.lng === 'number' ? shelter.lng : 0.0;

    const flags = {
      civil: type === 'civil' ? 1 : 0,
      earthquake: type === 'earthquake' ? 1 : 0,
      tsunami: type === 'tsunami' ? 1 : 0
    };

    const result = insertStmt.run(name, address, latitude, longitude, flags.civil, flags.earthquake, flags.tsunami);
    if (result.changes === 0) {
      updateStmt.run(flags.civil, flags.earthquake, flags.tsunami, name, address);
    } else {
      count++;
    }
  }
  return count;
}

// 전체 삽입
let totalCount = 0;

for (const region of regions) {
  createTable(region);

  let regionCount = 0;

  const civilFile = path.join(civilPath, `${region}.json`);
  if (fs.existsSync(civilFile)) {
    const data = JSON.parse(fs.readFileSync(civilFile));
    regionCount += insertShelters(region, data, 'civil');
  }

  const eqFile = path.join(eqPath, `${region}_earthquake.json`);
  if (fs.existsSync(eqFile)) {
    const data = JSON.parse(fs.readFileSync(eqFile));
    regionCount += insertShelters(region, data, 'earthquake');
  }

  const tsuFile = path.join(tsuPath, `${region}_tsunami.json`);
  if (fs.existsSync(tsuFile)) {
    const data = JSON.parse(fs.readFileSync(tsuFile));
    regionCount += insertShelters(region, data, 'tsunami');
  }

  console.log(`[${region}] inserted: ${regionCount} new shelters`);
  totalCount += regionCount;
}

console.log(`✅ Total shelters newly inserted: ${totalCount}`);
