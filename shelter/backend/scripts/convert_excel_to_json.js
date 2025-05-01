const path = require('path');
const xlsx = require('xlsx');
const fs = require('fs');

// 엑셀 파일 경로
const excelFilePath = path.resolve(__dirname, '../data/raw/korea_administrative_division_latitude_longitude.xlsx'); // 절대 경로
const outputFilePath = path.resolve(__dirname, '../data/user_locations/user_locations.json'); // 절대 경로

// 파일 존재 여부 확인
if (!fs.existsSync(excelFilePath)) {
  console.error(`❌ 엑셀 파일이 존재하지 않습니다: ${excelFilePath}`);
  process.exit(1);
}

// 엑셀 파일 읽기
const workbook = xlsx.readFile(excelFilePath);
const sheetName = workbook.SheetNames[0]; // 첫 번째 시트 사용
const sheet = workbook.Sheets[sheetName];

// JSON으로 변환
const jsonData = xlsx.utils.sheet_to_json(sheet);

// JSON 파일로 저장
fs.writeFileSync(outputFilePath, JSON.stringify(jsonData, null, 2), 'utf8');
console.log(`✅ 엑셀 데이터를 JSON으로 변환 완료: ${outputFilePath}`);