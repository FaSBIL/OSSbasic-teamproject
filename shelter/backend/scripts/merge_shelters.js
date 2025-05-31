const fs = require('fs');
const path = require('path');
const Database = require('better-sqlite3');

// 파일 경로
const inputDir = path.join(__dirname, '../../data/refinedJSON');
const outputDBPath = path.join(__dirname, '../../data/db/combineshelter_by_region.db');

// 시도명 추출용 정규표현식
const provinceRegex = /(서울|부산|대구|인천|광주|대전|울산|세종|경기|강원|충북|충남|전북|전남|경북|경남|제주)[도시]/;

// 중복 제거용 Map
const shelterMap = new Map();

// 불일치 지역 로그용
const unknownLog = {
  earthquake: [],
  tsunami: [],
  civil: [],
};

// 각 파일을 불러와서 JSON 객체로 파싱
function loadShelterData(filename, flagKey) {
  const filePath = path.join(inputDir, filename);
  const data = JSON.parse(fs.readFileSync(filePath, 'utf-8'));

  for (const shelter of data) {
    const address = shelter.address?.trim();
    if (!address) continue;

    const key = address;

    if (!shelterMap.has(key)) {
      shelterMap.set(key, {
        name: shelter.name,
        address: address,
        isFavorite: false,
        earthquake: false,
        tsunami: false,
        civil: false,
      });
    }

    shelterMap.get(key)[flagKey] = true;
  }
}

// 지역명 추출 (시도 기준)
function extractProvince(address) {
  const match = address.match(provinceRegex);
  if (!match) return null;

  const province = match[0];
  switch (province) {
    case '서울특별시': return 'seoul';
    case '부산광역시': return 'busan';
    case '대구광역시': return 'daegu';
    case '인천광역시': return 'incheon';
    case '광주광역시': return 'gwangju';
    case '대전광역시': return 'daejeon';
    case '울산광역시': return 'ulsan';
    case '세종특별자치시': return 'sejong';
    case '경기도': return 'gyeonggi';
    case '강원도': return 'gangwon';
    case '충청북도': return 'chungbuk';
    case '충청남도': return 'chungnam';
    case '전라북도': return 'jeonbuk';
    case '전라남도': return 'jeonnam';
    case '경상북도': return 'gyeongbuk';
    case '경상남도': return 'gyeongnam';
    case '제주특별자치도': return 'jeju';
    default: return null;
  }
}

// SQLite DB 초기화 및 테이블 생성
function createTables(db, regionSet) {
  for (const region of regionSet) {
    db.prepare(`
      CREATE TABLE IF NOT EXISTS ${region} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        address TEXT,
        isFavorite BOOLEAN,
        earthquake BOOLEAN,
        tsunami BOOLEAN,
        civil BOOLEAN
      );
    `).run();
  }
}

// DB에 데이터 삽입
function insertShelters(db) {
  const regionSet = new Set();

  for (const [address, shelter] of shelterMap) {
    const region = extractProvince(address);

    if (!region) {
      const flag = shelter.earthquake
        ? 'earthquake'
        : shelter.tsunami
        ? 'tsunami'
        : 'civil';
      unknownLog[flag].push(address);
      continue;
    }

    regionSet.add(region);

    if (!db.transaction(() => {
      const stmt = db.prepare(`
        INSERT INTO ${region} (name, address, isFavorite, earthquake, tsunami, civil)
        VALUES (?, ?, ?, ?, ?, ?)
      `);
      stmt.run(
        shelter.name,
        shelter.address,
        shelter.isFavorite ? 1 : 0,
        shelter.earthquake ? 1 : 0,
        shelter.tsunami ? 1 : 0,
        shelter.civil ? 1 : 0
      );
    })) {
      console.error(`❌ Failed to insert: ${shelter.name}`);
    }
  }

  return regionSet;
}

// 메인 실행 함수
function main() {
  console.log('📦 병합 시작...');
  loadShelterData('earthquake.json', 'earthquake');
  loadShelterData('tsunami.json', 'tsunami');
  loadShelterData('civil.json', 'civil');

  const db = new Database(outputDBPath);
  const regionSet = new Set(
    Array.from(shelterMap.values())
      .map((shelter) => extractProvince(shelter.address))
      .filter(Boolean)
  );

  createTables(db, regionSet);
  const finalRegions = insertShelters(db);
  db.close();

  console.log(`📊 병합 후 총 대피소 수: ${shelterMap.size}`);
  console.log(`✅ combineshelter_by_region.db 생성 완료 (지역별 테이블 수: ${finalRegions.size})`);

  // 오류 로그
  for (const [flag, list] of Object.entries(unknownLog)) {
    if (list.length > 0) {
      console.warn(`⚠️ ${flag} 알 수 없는 지역 수: ${list.length}`);
    }
  }
}

main();
