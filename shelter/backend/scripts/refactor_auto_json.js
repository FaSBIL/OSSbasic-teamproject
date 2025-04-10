const fs = require('fs');
const path = require('path');

// 설정
const startPage = 11;
const endPage = 12;

const baseDir = './data/earthquake/responses';
const resultDir='./data/earthquake/RawJSON';

for (let i = startPage; i <= endPage; i++) {
  const inputPath = path.join(baseDir, `response${i}.json`);
  const outputPath = path.join(resultDir, `earthquake_shelters${i}.json`);

  try {
    const raw = fs.readFileSync(inputPath, 'utf8');
    const parsed = JSON.parse(raw);
    const shelters = parsed.body;

    if (!Array.isArray(shelters)) {
      console.warn(`⚠️ response${i}.json 안의 body가 배열이 아닙니다. → 건너뜀`);
      continue;
    }

    fs.writeFileSync(outputPath, JSON.stringify(shelters, null, 2), 'utf8');
    console.log(`✅ response${i}.json → ${outputPath} (${shelters.length}개 항목 저장됨)`);
  } catch (err) {
    console.error(`❌ response${i}.json 처리 실패:`, err.message);
  }
}
