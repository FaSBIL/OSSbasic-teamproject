const fs = require('fs');

const input = './shelters_enriched.json';
const output = './shelters_normalized.json';

const raw = fs.readFileSync(input, 'utf8');
const data = JSON.parse(raw);

// 정규화 함수
function normalizeRegion(region) {
  if (!region) return '';

  const rules = [
    { prefix: '서울', full: '서울특별시' },
    { prefix: '부산', full: '부산광역시' },
    { prefix: '대구', full: '대구광역시' },
    { prefix: '인천', full: '인천광역시' },
    { prefix: '광주', full: '광주광역시' },
    { prefix: '대전', full: '대전광역시' },
    { prefix: '울산', full: '울산광역시' },
    { prefix: '세종', full: '세종특별자치시' },
    { prefix: '경기', full: '경기도' },
    { prefix: '강원', full: '강원특별자치도' },
    { prefix: '충북', full: '충청북도' },
    { prefix: '충남', full: '충청남도' },
    { prefix: '전북', full: '전라북도' },
    { prefix: '전남', full: '전라남도' },
    { prefix: '경북', full: '경상북도' },
    { prefix: '경남', full: '경상남도' },
    { prefix: '제주', full: '제주특별자치도' }
  ];

  for (const rule of rules) {
    if (region.startsWith(rule.prefix)) return rule.full;
  }

  return region; // fallback: 그대로 유지
}

// 보완 처리
const updated = data.map(item => ({
  ...item,
  region: normalizeRegion(item.region)
}));

fs.writeFileSync(output, JSON.stringify(updated, null, 2), 'utf8');
console.log(`✅ region 필드 정규화 완료 → ${output}`);
