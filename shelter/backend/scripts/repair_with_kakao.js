const fs = require('fs');
const axios = require('axios');

const input = './data/tsunami/tsunamiForDB/shelters_normalized.json';
const output = './shelters_fixed.json';
const kakaoKey = "f82e6cb25da330769e61eec64472d61d";

async function getAddressFromCoords(lat, lng) {
  const url = `https://dapi.kakao.com/v2/local/geo/coord2address.json?x=${lng}&y=${lat}`;
  try {
    const res = await axios.get(url, {
      headers: {
        Authorization: `KakaoAK ${kakaoKey}`
      }
    });
    const doc = res.data.documents[0];
    const addr = doc?.road_address?.address_name || doc?.address?.address_name || '';
    return addr;
  } catch (err) {
    console.error(`❌ 주소 조회 실패 (${lat}, ${lng}):`, err.message);
    return '';
  }
}

(async () => {
  const raw = fs.readFileSync(input, 'utf8');
  const shelters = JSON.parse(raw);

  const updated = [];

  for (const [i, shelter] of shelters.entries()) {
    const hasBrokenText = (shelter.address.includes('�') || shelter.name.includes('�'));
    if (hasBrokenText) {
      console.log(`📍 [${i + 1}] 깨진 항목 주소 재요청 중...`);
      const newAddr = await getAddressFromCoords(shelter.lat, shelter.lng);
      if (newAddr) {
        shelter.address = newAddr;
        shelter.region = newAddr.split(' ')[0]; // 시/도 추출
        console.log(`✅ 대체 주소 → ${newAddr}`);
      } else {
        console.warn(`⚠️ 대체 주소 조회 실패`);
      }
    }
    updated.push(shelter);
  }

  fs.writeFileSync(output, JSON.stringify(updated, null, 2), 'utf8');
  console.log(`✅ 주소 보완 완료: ${output}`);
})();
