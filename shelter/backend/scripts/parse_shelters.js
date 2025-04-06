const fs = require('fs-extra');
const iconv = require('iconv-lite');
const csv = require('csv-parser');

const results = [];

fs.createReadStream('./data/raw/충청북도_민방위대피시설_위치정보_20240903.csv')
  .pipe(iconv.decodeStream('euc-kr')) // 한글 깨짐 방지
  .pipe(csv())
  .on('data', (row) => {
    // 필요한 필드만 추출해서 구조화
    results.push({
      name: row['시설명'],                // 실제 열 이름 확인 필요
      address: row['소재지도로명주소'],   // 실제 열 이름 확인 필요
      lat: parseFloat(row['위도']),
      lng: parseFloat(row['경도']),
      region: '충청북도'
    });
  })
  .on('end', () => {
    fs.outputJson('./data/processed/chungbuk.json', results, { spaces: 2 });
    console.log('✅ 충청북도 대피소 JSON 변환 완료!');
  });
