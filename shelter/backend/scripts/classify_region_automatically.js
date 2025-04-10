const fs = require('fs');
const path = require('path');

// 지역명 → 영문 코드 매핑 테이블
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
  '강원특별자치도': 'gangwon',
  '충청북도': 'chungbuk',
  '충청남도': 'chungnam',
  '전라북도': 'jeonbuk',
  '전라남도': 'jeonnam',
  '경상북도': 'gyeongbuk',
  '경상남도': 'gyeongnam',
  '제주특별자치도': 'jeju'
};

// 입력 디렉터리
const inputDir = './data/earthquake/RefinedJSON';
// 출력 디렉터리
const outputDir = './data/earthquake/earthquakeForDB';
fs.mkdirSync(outputDir, { recursive: true });

// 1~12번 파일 탐색
let allShelters = [];
for (let i = 1; i <= 12; i++) {
  const filePath = path.join(inputDir, `shelters_cleaned${i}.json`);
  try {
    const raw = fs.readFileSync(filePath, 'utf8');
    const shelters = JSON.parse(raw);
    allShelters.push(...shelters);
  } catch (err) {
    console.error(`❌ shelters_cleaned${i}.json 처리 실패:`, err.message);
  }
}

// 지역별 분류
const regionMap = {};
allShelters.forEach(item => {
  const region = item.region;
  if (!region) return;

  if (!regionMap[region]) {
    regionMap[region] = [];
  }
  regionMap[region].push(item);
});

// 파일 저장 (영문 지역코드 기반)
for (const region in regionMap) {
  const regionCode = regionNameMap[region];

  if (!regionCode) {
    console.warn(`⚠️ 매핑되지 않은 지역: ${region} → 건너뜀`);
    continue;
  }

  const filePath = path.join(outputDir, `${regionCode}_earthquake.json`);
  fs.writeFileSync(filePath, JSON.stringify(regionMap[region], null, 2), 'utf8');
  console.log(`✅ ${region} (${regionMap[region].length}개) → ${regionCode}_earthquake.json`);
}
