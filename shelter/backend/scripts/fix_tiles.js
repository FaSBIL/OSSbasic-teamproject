const fs = require('fs');
const path = require('path');

const rootDir = './OSMPublicTransport'; // 여기에 zoom/x/y"png.tile" 구조가 있다고 가정

function fixTileFilenames(dir) {
  fs.readdirSync(dir, { withFileTypes: true }).forEach((entry) => {
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      fixTileFilenames(fullPath); // 재귀적으로 처리
    } else if (entry.isFile() && entry.name.endsWith('png.tile')) {
      // 예: 391png.tile → 391.png
      const newName = entry.name.replace('png.tile', 'png');
      const newPath = path.join(dir, newName);
      fs.renameSync(fullPath, newPath);
      console.log(`✅ renamed: ${entry.name} → ${newName}`);
    }
  });
}

fixTileFilenames(rootDir);
