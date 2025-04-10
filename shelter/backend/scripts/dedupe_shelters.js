const fs = require('fs');
const path = require('path');

// 입력 파일과 출력 파일 경로
const inputPath = './shelters_tsunami.json';
const outputPath = './shelters_tsunami_deduped.json';

const raw = fs.readFileSync(inputPath, 'utf8');
const shelters = JSON.parse(raw);

// 중복 제거: name + lat + lng 조합으로 키 생성
const seen = new Set();
const deduped = [];

for (const shelter of shelters) {
  const key = `${shelter.name}_${shelter.lat}_${shelter.lng}`;
  if (!seen.has(key)) {
    seen.add(key);
    deduped.push(shelter);
  }
}

fs.writeFileSync(outputPath, JSON.stringify(deduped, null, 2), 'utf8');
console.log(`✅ 중복 제거 완료: ${shelters.length - deduped.length}개 제거됨`);
console.log(`📦 결과 저장: ${outputPath}`);
