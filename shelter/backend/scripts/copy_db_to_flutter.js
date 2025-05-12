const fs = require('fs');
const path = require('path');

const srcPath = path.join(__dirname, 'shelters.db'); // 백엔드에서 생성된 DB 경로
const destDir = path.join(__dirname, '../../frontend/shelter_db'); // Flutter 내부 디렉토리
const destPath = path.join(destDir, 'shelters.db');

// 디렉토리가 없으면 생성
if (!fs.existsSync(destDir)) {
  fs.mkdirSync(destDir, { recursive: true });
}

// DB 파일 복사
try {
  fs.copyFileSync(srcPath, destPath);
  console.log(`✅ shelters.db successfully copied to Flutter: ${destPath}`);
} catch (err) {
  console.error(`❌ Failed to copy shelters.db: ${err.message}`);
}
