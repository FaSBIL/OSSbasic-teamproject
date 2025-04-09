const fs = require('fs');

// 입력 파일
const raw = fs.readFileSync('./data/tsunami/RawJSON/response.json', 'utf8');
const parsed = JSON.parse(raw);
const body = parsed.body;

if (!Array.isArray(body)) {
  throw new Error('❌ body 항목이 배열이 아닙니다.');
}

// 정제
const cleaned = body.map(item => {
  const address = item.RN_DTL_ADRES || '';
  const region = address.slice(0, 4); // ex) "충청남도", "경상북도"
  return {
    name: item.SHNT_PLACE_NM ?? null,
    address: address,
    lat: item.LA ?? null,
    lng: item.LO ?? null,
    region: region
  };
});

// 저장
fs.writeFileSync('./shelters_cleaned.json', JSON.stringify(cleaned, null, 2), 'utf8');
console.log(`✅ ${cleaned.length}개의 대피소 정보를 정제하여 shelters_cleaned.json에 저장했습니다.`);
