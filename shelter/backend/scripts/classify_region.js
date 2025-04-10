const fs = require('fs');
const path = require('path');

// ✅ 지역 설정
const targetRegion = '전라남도'; // 바꾸면 다른 지역도 가능
const regionCode = 'jeonnam'; // 파일명에 들어갈 코드

// ✅ 입력 파일 위치
const inputDir = './data/earthquake/RefinedJSON';
const outputPath = `./data/earthquake/earthquakeForDB/${regionCode}_earthquake.json`;

// 출력 폴더 없으면 생성
fs.mkdirSync(path.dirname(outputPath), { recursive: true });

// 1~12번 파일 탐색
const allShelters = [];

for (let i = 1; i <= 12; i++) {
  const filePath = path.join(inputDir, `shelters_cleaned${i}.json`);

  try {
    const raw = fs.readFileSync(filePath, 'utf8');
    const shelters = JSON.parse(raw);

    const filtered = shelters.filter(item => item.region === targetRegion);
    allShelters.push(...filtered);
  } catch (err) {
    console.error(`❌ shelters_cleaned${i}.json 처리 실패:`, err.message);
  }
}

// 저장
fs.writeFileSync(outputPath, JSON.stringify(allShelters, null, 2), 'utf8');
console.log(`✅ ${targetRegion} 대피소 ${allShelters.length}개가 ${outputPath}에 저장되었습니다.`);
