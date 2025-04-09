const https = require('https');
const fs = require('fs');
const querystring = require('querystring');
const createCsvWriter = require('csv-writer').createObjectCsvWriter;

// 설정값
const serviceKey = '여기에_서비스_키_입력';
const pageNo = '1';
const numOfRows = '1000';
const baseUrl = 'https://www.safetydata.go.kr/V2/api/DSSP-IF-10944';

// CSV로 저장할 시/도 설정
const targetCity = '부산광역시'; // <- 원하는 지역으로 바꿔줘

const queryParams = querystring.stringify({
  serviceKey: serviceKey,
  pageNo: pageNo,
  numOfRows: numOfRows,
});

const requestUrl = `${baseUrl}?${queryParams}`;

https.get(requestUrl, (res) => {
  let data = '';

  if (res.statusCode < 200 || res.statusCode >= 300) {
    console.error('요청 실패:', res.statusCode);
    return;
  }

  res.on('data', (chunk) => {
    data += chunk;
  });

  res.on('end', async () => {
    try {
      const json = JSON.parse(data);

      // 응답 구조 확인 후 row 리스트 가져오기
      const rows = json?.DisasterShelter?.[1]?.row;
      if (!rows) {
        console.error('데이터가 존재하지 않음.');
        return;
      }

      // 시/도 필터링
      const filtered = rows.filter(item => item.siNm === targetCity);

      if (filtered.length === 0) {
        console.log(`${targetCity}에 해당하는 대피소가 없습니다.`);
        return;
      }

      // CSV 작성기 정의
      const csvWriter = createCsvWriter({
        path: `shelters_${targetCity}.csv`,
        header: [
          { id: 'shel_nm', title: '대피소명' },
          { id: 'address', title: '주소' },
          { id: 'lon', title: '경도' },
          { id: 'lat', title: '위도' },
          { id: 'shel_av', title: '수용가능인원' },
          { id: 'shel_div_type', title: '유형' },
        ]
      });

      // CSV 저장
      await csvWriter.writeRecords(filtered);
      console.log(`${targetCity} 대피소 정보가 CSV로 저장되었습니다.`);

    } catch (err) {
      console.error('처리 중 오류 발생:', err.message);
    }
  });
}).on('error', (err) => {
  console.error('요청 에러:', err.message);
});
