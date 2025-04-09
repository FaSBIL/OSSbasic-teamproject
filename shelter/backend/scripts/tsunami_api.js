const https = require('https');
const querystring = require('querystring');
const fs = require('fs');
require('dotenv').config();

// 설정값
const serviceKey = process.env.TSUNAMI_KEY;
const baseUrl = 'https://www.safetydata.go.kr/V2/api/DSSP-IF-10944';
const targetCity = '충청북도'; // 시/도 필터링용

// 요청 파라미터 구성
const queryParams = querystring.stringify({
  serviceKey: serviceKey,
  numOfRows: 1000,
  pageNo: 1,
  returnType: 'json',
});

const requestUrl = `${baseUrl}?${queryParams}`;

https.get(requestUrl, (res) => {
  let data = '';

  res.on('data', chunk => data += chunk);

  res.on('end', () => {
    try {
      const json = JSON.parse(data);

      const rows = json?.DisasterShelter?.[1]?.row;
      if (!rows || !Array.isArray(rows)) {
        console.error('응답 데이터가 올바르지 않습니다.');
        return;
      }

      // 필터: 시/도 이름 포함된 주소 기준
      const filtered = rows.filter(item =>
        item.RN_DTL_ADRES && item.RN_DTL_ADRES.includes(targetCity)
      );

      if (filtered.length === 0) {
        console.log(`${targetCity} 지역 대피소 정보가 없습니다.`);
        return;
      }

      // 저장 경로
      const outputPath = `./data/tsunami/raw/shelters_${targetCity}.json`;

      // JSON 파일로 저장
      fs.writeFileSync(outputPath, JSON.stringify(filtered, null, 2), 'utf8');
      console.log(`✅ ${targetCity} 대피소 정보를 JSON으로 저장했습니다: ${outputPath}`);

    } catch (e) {
      console.error('데이터 처리 오류:', e.message);
    }
  });
}).on('error', (err) => {
  console.error('요청 중 오류:', err.message);
});
