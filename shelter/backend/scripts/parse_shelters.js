const fs = require('fs');
const csv = require('csv-parser');

const results = [];

fs.createReadStream('./data/raw/chungbuk.csv')
  .pipe(csv())
  .on('data', (row) => {
    results.push({
      name: row['민방위 대피시설명'],
      address: row['시설 주소'],
      lat: parseFloat(row['위도']),
      lng: parseFloat(row['경도']),
      region: '충청북도'
    });
  })
  .on('end', () => {
    fs.writeFileSync('./data/processed/chungbuk.json', JSON.stringify(results, null, 2));
    console.log('✅ 정제된 chungbuk.json 생성 완료!');
  });
