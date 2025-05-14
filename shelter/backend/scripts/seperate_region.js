const fs = require('fs');
const path = require('path');

// 지역 이름 → 코드 매핑
const regionMap = {
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
  '전북특별자치도': 'jeonbuk',
  '전라북도': 'jeonbuk',
  '전라남도': 'jeonnam',
  '경상북도': 'gyeongbuk',
  '경상남도': 'gyeongnam',
  '제주특별자치도': 'jeju'
};

const inputPath = '../data/tsunami/tsunamiForDB/shelters_tsunami_deduped.json';
const outputDir = './by_region_tsunami';

if (!fs.existsSync(outputDir)) {
  fs.mkdirSync(outputDir);
}

const rawData = fs.readFileSync(inputPath, 'utf-8');
const data = JSON.parse(rawData);

const regions = {};

// regionMap에 포함된 지역만 필터링 및 분류
data.forEach((shelter) => {
  const regionKo = shelter.region;
  const regionEn = regionMap[regionKo];

  if (regionEn) {
    if (!regions[regionEn]) {
      regions[regionEn] = [];
    }
    regions[regionEn].push(shelter);
  } else {
    console.warn(`⚠️ 미매핑 지역 발견: ${regionKo}`);
  }
});

// 각 지역 코드별로 파일 저장
for (const regionCode in regions) {
  const filePath = path.join(outputDir, `${regionCode}_tsunami.json`);
  fs.writeFileSync(filePath, JSON.stringify(regions[regionCode], null, 2), 'utf-8');
  console.log(`✅ 저장 완료: ${regionCode}_tsunami.json`);
}
