const fs = require('fs');
const path = require('path');

const dir = '../data/earthquake/earthquakeForDB'; // JSON 파일들이 위치한 폴더

fs.readdirSync(dir).forEach((filename) => {
  if (filename.endsWith('.json')) {
    const filePath = path.join(dir, filename);
    const rawData = fs.readFileSync(filePath, 'utf-8');
    const data = JSON.parse(rawData);

    const updated = data.map((shelter) => ({
      ...shelter,
      lat: parseFloat(shelter.lat),
      lng: parseFloat(shelter.lng),
    }));

    fs.writeFileSync(filePath, JSON.stringify(updated, null, 2), 'utf-8');
    console.log(`✅ 변환 완료 (덮어씀): ${filename}`);
  }
});
