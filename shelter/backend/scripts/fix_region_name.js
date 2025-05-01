const axios = require('axios');
const fs = require('fs');
const path = require('path');

const API_KEY = ""; // 카카오 API 키

async function getDoFromCoords(lat, lng) {
  const res = await axios.get('https://dapi.kakao.com/v2/local/geo/coord2regioncode.json', {
    params: { x: lng, y: lat },
    headers: { Authorization: `KakaoAK ${API_KEY}` },
  });
  return res.data.documents[0]?.region_1depth_name || null;
}

async function updateDoValues(data) {
  for (const entry of data) {
    const region = await getDoFromCoords(entry.latitude, entry.longitude);
    if (region) entry.do = region;
  }
  return data;
}

// JSON 파일 경로
const inputPath = path.resolve(__dirname, '../data/user_locations/user_locations.json');
const outputPath = path.resolve(__dirname, '../data/user_locations/user_locations_corrected.json');

// 파일 존재 여부 확인
if (!fs.existsSync(inputPath)) {
  console.error(`❌ JSON 파일이 존재하지 않습니다: ${inputPath}`);
  process.exit(1);
}

// JSON 파일 읽기
const rawData = fs.readFileSync(inputPath, 'utf8');
const locationData = JSON.parse(rawData);

// 보정 후 저장
updateDoValues(locationData).then((corrected) => {
  fs.writeFileSync(outputPath, JSON.stringify(corrected, null, 2));
  console.log(`✅ 도 정보가 보완된 파일을 저장했습니다: ${outputPath}`);
});
