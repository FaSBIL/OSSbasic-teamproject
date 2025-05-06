const fs = require('fs');
const path = require('path');

const rootDir = './OSMPublicTransport'; // 타일 디렉토리의 최상위 경로

function fixMissingExtension(dir) {
  fs.readdirSync(dir, { withFileTypes: true }).forEach((entry) => {
    const fullPath = path.join(dir, entry.name);

    if (entry.isDirectory()) {
      fixMissingExtension(fullPath);
    } else if (entry.isFile()) {
      // 확장자가 없고 이름이 'png'로 끝나면 처리
      const parsed = path.parse(entry.name);
      if (!parsed.ext && parsed.name.endsWith('png')) {
        const cleanName = parsed.name.slice(0, -3); // 'png' 제거
        const newName = `${cleanName}.png`;
        const newPath = path.join(dir, newName);
        fs.renameSync(fullPath, newPath);
        console.log(`✅ fixed: ${entry.name} → ${newName}`);
      }
    }
  });
}

fixMissingExtension(rootDir);
