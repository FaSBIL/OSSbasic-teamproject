const fs = require('fs');
const path = require('path');
const sqlite3 = require('sqlite3').verbose();

const civilDB = path.join(__dirname, '../data/civil/civilSheltersByRegion.db');
const earthquakeDB = path.join(__dirname, '../data/earthquake/earthquakeSheltersByRegion.db');
const tsunamiJSON = path.join(__dirname, '../data/tsunami/tsunamiForDB/shelters_tsunami_deduped.json');

const outputDB = path.join(__dirname, '../data/combineshelter_by_region.db');
const merged = [];

function isSameLocation(a, b) {
  return Math.abs(a.latitude - b.latitude) < 0.0001 &&
         Math.abs(a.longitude - b.longitude) < 0.0001;
}

function isValidCoord(lat, lng) {
  return typeof lat === 'number' && typeof lng === 'number' && !isNaN(lat) && !isNaN(lng);
}

// ✅ 유연한 지역명 → 슬러그 변환 함수 (전북특별자치도 포함)
function regionToSlug(regionName, fallbackAddress = '') {
    if (!regionName && !fallbackAddress) return null;
  
    const fullText = regionName || fallbackAddress;
  
    // 앞부분에서 도/광역시/특별시/특별자치도 등을 뽑아냄
    const topLevel = fullText.trim().split(/\s+/)[0]
      .replace(/특별자치도|광역시|특별시|자치시|도|시/g, '');
  
    const map = {
      '서울': 'seoul',
      '부산': 'busan',
      '대구': 'daegu',
      '인천': 'incheon',
      '광주': 'gwangju',
      '대전': 'daejeon',
      '울산': 'ulsan',
      '세종': 'sejong',
      '경기': 'gyeonggi',
      '강원': 'gangwon',
      '충북': 'chungbuk',
      '충남': 'chungnam',
      '전북': 'jeonbuk',
      '전남': 'jeonnam',
      '경북': 'gyeongbuk',
      '경남': 'gyeongnam',
      '제주': 'jeju',
      '전북특별자치도': 'jeonbuk',
      '제주특별자치도': 'jeju',
      '세종특별자치시': 'sejong'
    };
  
    return map[topLevel] || null;
  }
  

function insertOrUpdate(entry, type) {
  const lat = Number(entry.latitude || entry.lat);
  const lng = Number(entry.longitude || entry.lng);
  const region = (entry.region || '').trim();
  const slug = regionToSlug(region, entry.address);

  if (!isValidCoord(lat, lng) || !slug) {
    console.warn(`⚠️ ${type} 알 수 없는 지역: ${entry.address || region}`);
    return;
  }

  const existing = merged.find(e => isSameLocation(e, { latitude: lat, longitude: lng }));
  if (existing) {
    existing[type] = 1;
  } else {
    merged.push({
      name: entry.name || '이름없음',
      address: entry.address || '',
      latitude: lat,
      longitude: lng,
      regionSlug: slug,
      isFavorite: 0,
      civil: type === 'civil' ? 1 : 0,
      earthquake: type === 'earthquake' ? 1 : 0,
      tsunami: type === 'tsunami' ? 1 : 0
    });
  }
}

function loadFromSQLite(file, type) {
  return new Promise((resolve, reject) => {
    const src = new sqlite3.Database(file);
    src.all("SELECT name FROM sqlite_master WHERE type='table'", (err, tables) => {
      if (err) return reject(err);
      let pending = tables.length;
      if (pending === 0) return resolve();
      tables.forEach(t => {
        src.all(`SELECT * FROM ${t.name}`, (err, rows) => {
          rows?.forEach(row => insertOrUpdate(row, type));
          if (--pending === 0) {
            src.close();
            resolve();
          }
        });
      });
    });
  });
}

function loadFromTsunamiJSON() {
  const data = JSON.parse(fs.readFileSync(tsunamiJSON, 'utf8'));
  data.forEach(entry => insertOrUpdate(entry, 'tsunami'));
}

function saveToRegionTables() {
  return new Promise((resolve) => {
    const db = new sqlite3.Database(outputDB);
    db.serialize(() => {
      const regions = [...new Set(merged.map(e => e.regionSlug))];

      regions.forEach(slug => {
        const tableName = `shelters_${slug}`;
        db.run(`DROP TABLE IF EXISTS ${tableName}`);
        db.run(`
          CREATE TABLE ${tableName} (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            address TEXT NOT NULL,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            isFavorite INTEGER DEFAULT 0,
            civil INTEGER DEFAULT 0,
            earthquake INTEGER DEFAULT 0,
            tsunami INTEGER DEFAULT 0
          )
        `);

        const stmt = db.prepare(`
          INSERT INTO ${tableName} (name, address, latitude, longitude, isFavorite, civil, earthquake, tsunami)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        `);

        merged
          .filter(e => e.regionSlug === slug)
          .forEach(e => {
            stmt.run(
              e.name,
              e.address,
              e.latitude,
              e.longitude,
              e.isFavorite,
              e.civil,
              e.earthquake,
              e.tsunami
            );
          });

        stmt.finalize();
      });

      db.close();
      resolve();
    });
  });
}

async function main() {
  console.log('📥 지역별 DB 통합 시작...');
  await loadFromSQLite(civilDB, 'civil');
  await loadFromSQLite(earthquakeDB, 'earthquake');
  loadFromTsunamiJSON();
  console.log(`📊 병합 후 총 대피소 수: ${merged.length}`);
  await saveToRegionTables();
  console.log('✅ combineshelter_by_region.db 생성 완료 (지역별 테이블 분리)!');
}

main().catch(err => console.error('❌ 오류 발생:', err));
