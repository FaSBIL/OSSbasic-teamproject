const https = require('https');
const querystring = require('querystring');
const fs = require('fs');

// .env에 저장된 인증키
const serviceKey = "";

const baseUrl = 'https://www.safetydata.go.kr/V2/api/DSSP-IF-10943';
const params = querystring.stringify({
  serviceKey: serviceKey,
  pageNo: 10,
  numOfRows: 1000,
  returnType: 'json'
});

const url = `${baseUrl}?${params}`;

https.get(url, (res) => {
  let rawData = '';

  res.on('data', chunk => {
    rawData += chunk;
  });

  res.on('end', () => {
    try {
      const json = JSON.parse(rawData);
      const filename = './data/earthquake/RawJSON/response10.json';

      fs.writeFileSync(filename, JSON.stringify(json, null, 2), 'utf8');
      console.log(`✅ API 호출 성공: ${filename} 저장 완료`);
    } catch (err) {
      console.error('❌ JSON 파싱 오류:', err.message);
    }
  });
}).on('error', (e) => {
  console.error(`❌ 요청 실패: ${e.message}`);
});
