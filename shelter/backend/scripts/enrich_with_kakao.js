const fs = require('fs');
const axios = require('axios');

// 설정
const inputFile = './data/civil/civilForDB/seoul.json';
const outputFile = './data/civil/civilForDB/seoul.json';
const kakaoKey = ""; // Kakao REST API 키

// 주소만 가져오는 함수
async function getAddress(lat, lng) {
  const url = `https://dapi.kakao.com/v2/local/geo/coord2address.json?x=${lng}&y=${lat}`;
  try {
    const res = await axios.get(url, {
      headers: { Authorization: `KakaoAK ${kakaoKey}` }
    });

    const doc = res.data.documents[0];
    if (!doc) return '';

    return doc.road_address?.address_name || doc.address?.address_name || '';
  } catch (err) {
    console.error(`❌ 주소 요청 실패 (${lat}, ${lng})`);
    return '';
  }
}

(async () => {
  const raw = fs.readFileSync(inputFile, 'utf8');
  const shelters = JSON.parse(raw);

  const updated = [];

  for (const [i, shelter] of shelters.entries()) {
    if (!shelter.address || shelter.address.trim() === '') {
      const address = await getAddress(shelter.lat, shelter.lng);
      shelter.address = address;
      console.log(`📍 [${i + 1}] 주소 보완 → ${address}`);
    }
    updated.push(shelter);
  }

  fs.writeFileSync(outputFile, JSON.stringify(updated, null, 2), 'utf8');
  console.log(`✅ 주소 보완 완료 → ${outputFile}`);
})();
