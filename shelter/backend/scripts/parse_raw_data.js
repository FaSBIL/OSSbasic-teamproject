const fs = require('fs');
const csv = require('csv-parser');

const results = [];

fs.createReadStream('./data/raw/ulsan.csv') // 업로드한 경로
  .pipe(csv())
  .on('data', (row) => {
    // 먼저 열 키 확인
    console.log(row);
    results.push(row);
  })
  .on('end', () => {
    fs.writeFileSync('./data/processed/rawJSON/ulsan_raw.json', JSON.stringify(results, null, 2));
    console.log('✅ 변환 완료! ulsan_raw.json 생성됨');
  });
