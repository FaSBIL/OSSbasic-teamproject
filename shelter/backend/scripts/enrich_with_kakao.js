const fs = require('fs');
const axios = require('axios');

// 설정
const inputFile = './shelters_cleaned.json';
const outputFile = './shelters_enriched.json';
const kakaoKey = process.env.KAKAO_REST_KEY;

async function getAddress(lat, lng) {
  const url = `https://dapi.kakao.com/v2/local/geo/coord2address.json?x=${lng}&y=${lat}`;
  try {
    const res = await axios.get(url, {
      headers: { Authorization: `KakaoAK ${kakaoKey}` }
    });

    const doc = res.data.documents[0];
    if (!doc) return { address: '', region: '' };

    const addr = doc.road_address?.address_name || doc.address?.address_name || '';
    const region = addr.slice(0, 4); // 시/도명 추출

    return { address: addr, region };
  } catch (err) {
    console.error(`❌ 주소 요청 실패 (${lat}, ${lng})`);
    return { address: '', region: '' };
  }
}

(async () => {
  const raw = fs.readFileSync(inputFile, 'utf8');
  const shelters = JSON.parse(raw);

  const updated = [];

  for (const [i, shelter] of shelters.entries()) {
    if (!shelter.address || shelter.address.trim() === '') {
      const { address, region } = await getAddress(shelter.lat, shelter.lng);
      shelter.address = address;
      shelter.region = region;
      console.log(`📍 [${i + 1}] 주소 채움 → ${address}`);
    }
    updated.push(shelter);
  }

  fs.writeFileSync(outputFile, JSON.stringify(updated, null, 2), 'utf8');
  console.log(`✅ 전체 shelter 주소 보완 완료 → ${outputFile}`);
})();
