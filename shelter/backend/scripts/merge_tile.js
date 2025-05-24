// mergeTiles.js
const fs = require('fs');
const path = require('path');

// ★ 여기에 직접 경로를 지정하세요 ★
const sourceDir = 'OSM/16UpperRight/16/';
const targetDir = 'OSM/16/';

function mergeRecursively(src, dst) {
  if (!fs.existsSync(src)) return;
  const entries = fs.readdirSync(src, { withFileTypes: true });
  for (let entry of entries) {
    const srcPath = path.join(src, entry.name);
    const dstPath = path.join(dst, entry.name);

    if (entry.isDirectory()) {
      // 대상에 같은 디렉터리 없으면 생성
      if (!fs.existsSync(dstPath)) {
        fs.mkdirSync(dstPath, { recursive: true });
      }
      mergeRecursively(srcPath, dstPath);
    } else if (entry.isFile() && entry.name.endsWith('.png')) {
      if (fs.existsSync(dstPath)) {
        // 중복 파일이면 source 쪽 파일 삭제
        fs.unlinkSync(srcPath);
        console.log(`🗑  Deleted duplicate: ${srcPath}`);
      } else {
        // 없으면 디렉터리 만들고 이동
        fs.mkdirSync(path.dirname(dstPath), { recursive: true });
        fs.renameSync(srcPath, dstPath);
        console.log(`✅ Moved: ${srcPath} → ${dstPath}`);
      }
    }
  }
}

function removeEmptyDirs(dir) {
  if (!fs.existsSync(dir)) return;
  let entries = fs.readdirSync(dir);
  if (entries.length === 0) {
    fs.rmdirSync(dir);
    console.log(`📁 Removed empty dir: ${dir}`);
    return;
  }
  for (let name of entries) {
    const full = path.join(dir, name);
    if (fs.lstatSync(full).isDirectory()) {
      removeEmptyDirs(full);
    }
  }
  // 다시 확인해서 비어있으면 지움
  entries = fs.readdirSync(dir);
  if (entries.length === 0) {
    fs.rmdirSync(dir);
    console.log(`📁 Removed empty dir: ${dir}`);
  }
}

// 실행
console.log(`Starting merge from:\n  ${sourceDir}\ninto:\n  ${targetDir}\n`);
mergeRecursively(sourceDir, targetDir);
removeEmptyDirs(sourceDir);
console.log('🎉 Merge complete!');
