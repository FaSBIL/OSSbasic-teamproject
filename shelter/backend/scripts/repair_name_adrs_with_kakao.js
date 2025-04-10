const fs = require('fs');
const axios = require('axios');

const input = './shelters_fixed.json';
const output = './shelters_final.json';
const kakaoKey = "f82e6cb25da330769e61eec64472d61d";

async function getAddressAndName(lat, lng) {
  const url = `https://dapi.kakao.com/v2/local/geo/coord2address.json?x=${lng}&y=${lat}`;
  try {
    const res = await axios.get(url, {
      headers: { Authorization: `KakaoAK ${kakaoKey}` }
    });

    const doc = res.data.documents[0];
    const address = doc?.road_address?.address_name || doc?.address?.address_name || '';
    const region = address.split(' ')[0] || '';
    const name = doc?.address?.address_name?.split(' ')?.slice(-1)[0] || '대피소'; // 예: "○○리" 등

    return { address, region, name };
  } catch (err) {
    console.error(`❌ 주소 요청 실패 (${lat}, ${lng}):`, err.message);
    return { address: '', region: '', name: '' };
  }
}

(async () => {
  const raw = fs.readFileSync(input, 'utf8');
  const shelters = JSON.parse(raw);
  const updated = [];

  for (const [i, shelter] of shelters.entries()) {
    const needsFix =
      (shelter.address.includes('�') || shelter.name.includes('�'));

    if (needsFix) {
      console.log(`📍 [${i + 1}] 깨진 항목 복구 시도 중...`);
      const { address, region, name } = await getAddressAndName(shelter.lat, shelter.lng);

      if (address) shelter.address = address;
      if (region) shelter.region = region;
      if (name && shelter.name.includes('�')) shelter.name = `${name} 주변`; // ex: "문동리 주변"

      console.log(`✅ 복구 완료 → ${shelter.name}`);
    }

    updated.push(shelter);
  }

  fs.writeFileSync(output, JSON.stringify(updated, null, 2), 'utf8');
  console.log(`✅ 모든 주소·이름 보완 완료: ${output}`);
})();
