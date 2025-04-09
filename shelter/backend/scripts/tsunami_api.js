const https = require('https');
const querystring = require('querystring');
const fs = require('fs');
require('dotenv').config();

// 설정값
const serviceKey = "8R5DA95M0CLD27Q0";//process.env.TSUNAMI_KEY;
const baseUrl = 'https://www.safetydata.go.kr/V2/api/DSSP-IF-10944';

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

      // 전체 구조 디버깅용 출력
      console.log('[INFO] 응답 구조 확인용:', Object.keys(json));

      // rows 데이터 가져오기 (구조에 따라 수정 필요)
      const rows =
        json?.DisasterShelter?.row ||  // 가장 가능성 높은 구조
        json?.DisasterShelter?.[1]?.row ||  // 원래 쓰던 구조
        null;

      if (!rows || !Array.isArray(rows)) {
        console.error('❌ 응답 데이터 구조가 예상과 다릅니다.');
        // 응답 전체 저장해서 분석할 수 있도록 로그
        fs.writeFileSync('./response.json', JSON.stringify(json, null, 2));
        console.log('📄 response.json 파일에 전체 응답 저장됨');
        return;
      }

      // 저장 경로
      const outputPath = './data/tsunami/RawJSON/all_shelters.json';

      // JSON 파일로 저장
      fs.writeFileSync(outputPath, JSON.stringify(rows, null, 2), 'utf8');
      console.log(`✅ 전체 대피소 정보를 JSON으로 저장했습니다: ${outputPath}`);
    } catch (e) {
      console.error('데이터 처리 오류:', e.message);
    }
  });
}).on('error', (err) => {
  console.error('요청 중 오류:', err.message);
});

console.log('[DEBUG] 서비스키:', process.env.TSUNAMI_KEY);
