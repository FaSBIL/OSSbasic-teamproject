const fs = require("fs");
const path = require("path");

// Git LFS로 트래킹할 최소 크기 (100MB = 100 * 1024 * 1024 bytes)
const SIZE_THRESHOLD = 100 * 1024 * 1024;

// 💡 수정된 올바른 경로 설정
const targetDir = path.resolve(__dirname, "../data/region_graphs");

// Git LFS 설정 파일
const gitattributesPath = path.resolve(__dirname, "../../.gitattributes");

const walk = (dir) => {
  let files = [];
  for (const file of fs.readdirSync(dir)) {
    const fullPath = path.join(dir, file);
    const stat = fs.statSync(fullPath);
    if (stat.isDirectory()) {
      files = files.concat(walk(fullPath));
    } else {
      files.push({ path: fullPath, size: stat.size });
    }
  }
  return files;
};

const allFiles = walk(targetDir).filter(f => f.size >= SIZE_THRESHOLD);

// Git LFS로 추적할 경로 추가
let output = "";
for (const file of allFiles) {
  const relativePath = path.relative(path.resolve(__dirname, "../../"), file.path).replace(/\\/g, "/");
  output += `${relativePath} filter=lfs diff=lfs merge=lfs -text\n`;
  console.log(`📦 ${relativePath} (${(file.size / 1024 / 1024).toFixed(2)}MB) → LFS 등록`);
}

// .gitattributes에 추가
if (output) {
  fs.appendFileSync(gitattributesPath, output);
  console.log("\n✅ .gitattributes에 Git LFS 항목 추가 완료!");
} else {
  console.log("📁 100MB를 초과하는 파일이 없습니다. 변경 없음.");
}

