const https = require('https');
const querystring = require('querystring');
const fs = require('fs');

// 설정
const serviceKey = "76MNTO4T2Q3GI284";
const baseUrl = 'https://www.safetydata.go.kr/V2/api/DSSP-IF-10943';
const numOfRows = 1000;

// 범위 설정
const startPage = 11;
const endPage = 20; // 필요한 만큼 조정 가능

// 저장 디렉토리
const outputDir = './data/earthquake/responses';
if (!fs.existsSync(outputDir)) fs.mkdirSync(outputDir, { recursive: true });

// 페이지별 요청 반복
const fetchPage = (pageNo) => {
  const params = querystring.stringify({
    serviceKey: serviceKey,
    pageNo: pageNo,
    numOfRows: numOfRows,
    returnType: 'json'
  });

  const url = `${baseUrl}?${params}`;
  https.get(url, (res) => {
    let rawData = '';

    res.on('data', chunk => rawData += chunk);

    res.on('end', () => {
      try {
        const json = JSON.parse(rawData);
        const filename = `${outputDir}/response${pageNo}.json`;
        fs.writeFileSync(filename, JSON.stringify(json, null, 2), 'utf8');
        console.log(`✅ ${filename} 저장 완료`);
      } catch (err) {
        console.error(`❌ JSON 파싱 실패 (page ${pageNo}):`, err.message);
      }
    });
  }).on('error', (e) => {
    console.error(`❌ 요청 실패 (page ${pageNo}):`, e.message);
  });
};

// 순차 실행
for (let i = startPage; i <= endPage; i++) {
  fetchPage(i);
}
