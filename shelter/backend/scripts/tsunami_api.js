const https = require('https');
const querystring = require('querystring');
const fs = require('fs');
const createCsvWriter = require('csv-writer').createObjectCsvWriter;

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

  res.on('end', async () => {
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

      // CSV 저장 설정
      const csvWriter = createCsvWriter({
        path: `./data/tsunami/raw/shelters_${targetCity}.csv`,
        header: [
          { id: 'SHNT_PLACE_NM', title: '대피소명' },
          { id: 'RN_DTL_ADRES', title: '도로명주소' },
          { id: 'LO', title: '경도' },
          { id: 'LA', title: '위도' },
          { id: 'PSBL_NMPR', title: '수용인원' },
          { id: 'EV_ANTCTY', title: '해발고도' },
          { id: 'USE_AT', title: '사용여부' },
          { id: 'SHNT_PLACE_DTL_POSITION', title: '상세위치' },
          { id: 'SHNT_PLACE_TY_CD', title: '대피소종류' },
          { id: 'ERTHQK_SHUNT_AT', title: '내진설계여부' },
        ]
      });

      await csvWriter.writeRecords(filtered);
      console.log(`✅ ${targetCity} 지역 대피소 정보를 shelters_${targetCity}.csv로 저장했습니다.`);

    } catch (e) {
      console.error('데이터 처리 오류:', e.message);
    }
  });
}).on('error', (err) => {
  console.error('요청 중 오류:', err.message);
});
