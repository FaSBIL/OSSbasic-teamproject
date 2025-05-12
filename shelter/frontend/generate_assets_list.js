/**
 * generate-assets-list.js
 *
 * Scans the `assets/osm` directory for any subfolders containing PNG files
 * and writes the list of asset directories to `asset_dirs.txt`, each prefixed
 * with '- ' so you can paste directly into pubspec.yaml.
 *
 * Usage:
 *   node generate-assets-list.js
 */

const fs = require('fs');
const path = require('path');

// Paths
const PROJECT_ROOT = __dirname;
const ASSETS_PREFIX = 'assets/osm/';
const ASSETS_ROOT = path.join(PROJECT_ROOT, ...ASSETS_PREFIX.split('/'));
const OUTPUT_FILE = path.join(PROJECT_ROOT, 'asset_dirs.txt');

/**
 * Recursively finds directories under `dir` that contain at least one .png file.
 * If a directory contains .png files, it's added; otherwise, recurse into subdirs.
 */
function findAssetDirs(dir) {
  let assetDirs = [];
  const entries = fs.readdirSync(dir);
  const hasPng = entries.some(e => e.endsWith('.png') && fs.statSync(path.join(dir, e)).isFile());

  if (hasPng) {
    assetDirs.push(dir);
  } else {
    entries.forEach(e => {
      const fullPath = path.join(dir, e);
      if (fs.statSync(fullPath).isDirectory()) {
        assetDirs = assetDirs.concat(findAssetDirs(fullPath));
      }
    });
  }

  return assetDirs;
}

// Discover and format directories, prefixing each with '- '
const dirs = findAssetDirs(ASSETS_ROOT)
  .map(dir => {
    const rel = path.relative(PROJECT_ROOT, dir).replace(/\\/g, '/') + '/';
    return `    - ${rel}`;
  })
  .sort();

// Write to text file
fs.writeFileSync(OUTPUT_FILE, dirs.join('\n'), 'utf8');

console.log(`Asset directories list written to ${OUTPUT_FILE}:`);
dirs.forEach(d => console.log(`  ${d}`));
