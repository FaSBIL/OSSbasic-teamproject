const fs = require('fs');
const path = require('path');

const dir = '../data/earthquake/earthquakeForDB'; // JSON 파일들이 위치한 폴더

fs.readdirSync(dir).forEach((filename) => {
  if (filename.endsWith('.json')) {
    const filePath = path.join(dir, filename);
    const rawData = fs.readFileSync(filePath, 'utf-8');
    const data = JSON.parse(rawData);

    const updated = data.map((shelter) => {
      return {
        ...shelter,
        lat: parseFloat(shelter.lat),
        lng: parseFloat(shelter.lng),
      };
    });

    const newFilename = filename.replace('.json', '_numeric.json');
    const newFilePath = path.join(dir, newFilename);
    fs.writeFileSync(newFilePath, JSON.stringify(updated, null, 2), 'utf-8');

    console.log(`✅ 변환 완료: ${filename} → ${newFilename}`);
  }
});
