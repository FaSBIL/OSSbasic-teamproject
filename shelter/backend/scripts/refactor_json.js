const fs = require('fs');
const path = require('path');

// 원본 파일 경로
const inputPath = './data/earthquake/RawJSON/response10.json';
// 저장할 파일 경로
const outputPath = './data/earthquake/RawJSON/earthquake_shelters10.json';

// JSON 읽기
const raw = fs.readFileSync(inputPath, 'utf8');
const parsed = JSON.parse(raw);

// body만 추출
const shelters = parsed.body;

if (!Array.isArray(shelters)) {
  throw new Error('❌ response10.json 안의 body가 배열이 아닙니다.');
}

// 저장
fs.writeFileSync(outputPath, JSON.stringify(shelters, null, 2), 'utf8');
console.log(`✅ 총 ${shelters.length}개의 대피소 데이터를 earthquake_shelters10.json에 저장했습니다.`);
