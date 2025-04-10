const fs = require('fs');
const path = require('path');

// 설정
const startPage = 1;
const endPage = 10;

const inputDir = './data/earthquake/responses';
const outputDir = './data/earthquake/RefinedJSON';

// 디렉터리 없으면 생성
if (!fs.existsSync(outputDir)) {
  fs.mkdirSync(outputDir, { recursive: true });
}

for (let i = startPage; i <= endPage; i++) {
  const inputPath = path.join(inputDir, `response${i}.json`);
  const outputPath = path.join(outputDir, `shelters_cleaned${i}.json`);

  try {
    const raw = fs.readFileSync(inputPath, 'utf8');
    const parsed = JSON.parse(raw);
    const body = parsed.body;

    if (!Array.isArray(body)) {
      console.warn(`⚠️ response${i}.json 안의 body가 배열이 아닙니다. → 건너뜀`);
      continue;
    }

    const cleaned = body.map(item => {
      const address = item.EQK_ACMDFCLTY_ADRES || '';
      const region = address.split(' ')[0]; // 시/도 추출
      return {
        name: item.VT_ACMDFCLTY_NM ?? null,
        address: address,
        lat: item.LA ?? null,
        lng: item.LO ?? null,
        region: region
      };
    });

    fs.writeFileSync(outputPath, JSON.stringify(cleaned, null, 2), 'utf8');
    console.log(`✅ shelters_cleaned${i}.json 저장 완료 (${cleaned.length}개 항목)`);
  } catch (err) {
    console.error(`❌ response${i}.json 처리 실패:`, err.message);
  }
}
