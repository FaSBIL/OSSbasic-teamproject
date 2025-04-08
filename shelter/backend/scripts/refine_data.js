const fs = require('fs');
const csv = require('csv-parser');

const results = [];

fs.createReadStream('./data/raw/daejeon.csv')
  .pipe(csv())
  .on('data', (row) => {
    results.push({
      name: row['시설명'],
      address: row['도로명전체주소'],
      lat: parseFloat(row['위도(EPSG4326)']),
      lng: parseFloat(row['경도(EPSG4326)']),
      region: '대전광역시'
    });
  })
  .on('end', () => {
    fs.writeFileSync('./data/processed/refinedJSON/daejeon.json', JSON.stringify(results, null, 2));
    console.log('✅ 정제된 daejeon.json 생성 완료!');
  });
