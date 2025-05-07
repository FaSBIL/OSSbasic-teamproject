/**
 * generate-mbtiles.js
 *
 * Scans the `tiles/{z}/{x}/{y}.png` directory structure,
 * creates an MBTiles SQLite file, and inserts each tile as a BLOB,
 * converting Slippy Y to TMS row numbering:
 *
 *   tile_row = (2^z - 1) - y
 *
 * Usage:
 *   # install dependencies
 *   npm install sqlite3
 *
 *   # run the script from project root (where `tiles/` lives)
 *   node generate-mbtiles.js
 */

const fs = require('fs');
const path = require('path');
const sqlite3 = require('sqlite3').verbose();

// Configuration
const TILES_DIR = path.join(__dirname, 'OSM');           // folder containing z/x/y.png
const MBTILES_FILE = path.join(__dirname, 'kr-map.mbtiles'); // output MBTiles file

// Remove existing MBTiles if present
if (fs.existsSync(MBTILES_FILE)) {
  fs.unlinkSync(MBTILES_FILE);
}

// Open SQLite database
const db = new sqlite3.Database(MBTILES_FILE, sqlite3.OPEN_READWRITE | sqlite3.OPEN_CREATE, err => {
  if (err) throw err;
  console.log(`Creating MBTiles: ${MBTILES_FILE}`);
});

// Initialize schema
db.serialize(() => {
  db.run(`CREATE TABLE metadata (name TEXT, value TEXT);`);
  db.run(`CREATE TABLE tiles (
    zoom_level INTEGER,
    tile_column INTEGER,
    tile_row INTEGER,
    tile_data   BLOB
  );`);
  db.run(`CREATE UNIQUE INDEX tile_index ON tiles(
    zoom_level, tile_column, tile_row
  );`);

  const insertTile = db.prepare(`
    INSERT INTO tiles (zoom_level, tile_column, tile_row, tile_data)
    VALUES (?, ?, ?, ?);
  `);

  // Recursive traversal of tiles/{z}/{x}/{y}.png
  function traverseZ(dirZ) {
    const z = parseInt(path.basename(dirZ), 10);
    if (Number.isNaN(z)) return;
    fs.readdirSync(dirZ, { withFileTypes: true }).forEach(direntX => {
      if (!direntX.isDirectory()) return;
      const x = parseInt(direntX.name, 10);
      const dirX = path.join(dirZ, direntX.name);
      fs.readdirSync(dirX).forEach(file => {
        if (path.extname(file).toLowerCase() !== '.png') return;
        const y = parseInt(path.basename(file, '.png'), 10);
        const filePath = path.join(dirX, file);
        const data = fs.readFileSync(filePath);
        // Convert Slippy y to TMS tile_row
        const tmsRow = ((1 << z) - 1) - y;
        insertTile.run(z, x, tmsRow, data);
      });
    });
  }

  // Walk through zoom folders
  fs.readdirSync(TILES_DIR, { withFileTypes: true }).forEach(direntZ => {
    if (direntZ.isDirectory()) {
      traverseZ(path.join(TILES_DIR, direntZ.name));
    }
  });

  insertTile.finalize();

  // Optional: add basic metadata
  const metadata = db.prepare(`INSERT INTO metadata (name, value) VALUES (?, ?);`);
  const metaEntries = [
    ['name', 'Offline Tiles'],
    ['format', 'png'],
    ['version', '1'],
    ['minzoom', '0'],
    ['maxzoom', '15'],
    ['bounds', '-180.0,-85.0511,180.0,85.0511'],
  ];
  metaEntries.forEach(([name, value]) => metadata.run(name, value));
  metadata.finalize();

  db.close(err => {
    if (err) throw err;
    console.log('MBTiles creation complete.');
  });
});
