const fs = require('fs');
const path = require('path');

// 입력 디렉터리
const inputDir = './data/earthquake/RefinedJSON';
// 출력 디렉터리
const outputDir = './data/earthquake/earthquakeForDB';

// 출력 폴더 생성
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

// 파일로 저장
for (const region in regionMap) {
  const regionCode = region
    .replace(/특별자치도|특별자치시|광역시|특별시|도/g, '') // 접미사 제거
    .trim()
    .toLowerCase(); // 예: 'jeonnam'

  const filePath = path.join(outputDir, `${regionCode}_earthquake.json`);
  fs.writeFileSync(filePath, JSON.stringify(regionMap[region], null, 2), 'utf8');
  console.log(`✅ ${region} (${regionMap[region].length}개) → ${regionCode}_earthquake.json`);
}
