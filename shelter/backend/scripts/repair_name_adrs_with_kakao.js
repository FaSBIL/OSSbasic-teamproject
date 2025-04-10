const fs = require('fs');
const axios = require('axios');

const input = './shelters_fixed.json';
const output = './shelters_final.json';
const kakaoKey = "f82e6cb25da330769e61eec64472d61d";

// 1. 기본 주소 + 행정구역 추출
async function getAddress(lat, lng) {
  const url = `https://dapi.kakao.com/v2/local/geo/coord2address.json?x=${lng}&y=${lat}`;
  try {
    const res = await axios.get(url, {
      headers: { Authorization: `KakaoAK ${kakaoKey}` }
    });

    const doc = res.data.documents[0];
    const address = doc?.road_address?.address_name || doc?.address?.address_name || '';
    const region = address.split(' ')[0] || '';
    return { address, region };
  } catch (err) {
    console.error(`❌ coord2address 실패 (${lat}, ${lng}):`, err.message);
    return { address: '', region: '' };
  }
}

// 2. 장소 검색 API로 주변 장소명 가져오기
async function getPlaceName(lat, lng) {
  const url = `https://dapi.kakao.com/v2/local/search/keyword.json?query=대피소&y=${lat}&x=${lng}&radius=200`;
  try {
    const res = await axios.get(url, {
      headers: { Authorization: `KakaoAK ${kakaoKey}` }
    });
    const place = res.data.documents[0];
    return place?.place_name || '';
  } catch (err) {
    console.error(`❌ 장소명 검색 실패 (${lat}, ${lng}):`, err.message);
    return '';
  }
}

(async () => {
  const raw = fs.readFileSync(input, 'utf8');
  const shelters = JSON.parse(raw);
  const updated = [];

  for (const [i, shelter] of shelters.entries()) {
    const hasBroken = (shelter.address.includes('�') || shelter.name.includes('�'));

    if (hasBroken) {
      console.log(`📍 [${i + 1}] 깨진 항목 보완 중...`);

      // 주소 & 지역
      const { address, region } = await getAddress(shelter.lat, shelter.lng);
      if (address) shelter.address = address;
      if (region) shelter.region = region;

      // name 복원: 주변 장소명
      if (shelter.name.includes('�')) {
        const placeName = await getPlaceName(shelter.lat, shelter.lng);
        if (placeName) {
          shelter.name = placeName;
          console.log(`✅ 이름 복구 → ${placeName}`);
        } else {
          shelter.name = `${address.split(' ')[2] || '인근'} 공터`;
          console.warn(`⚠️ 주변 장소명 없어서 '${shelter.name}'로 대체`);
        }
      }
    }

    updated.push(shelter);
  }

  fs.writeFileSync(output, JSON.stringify(updated, null, 2), 'utf8');
  console.log(`✅ 최종 보완 완료: ${output}`);
})();
