// Рендер кадров сцены через headless Chromium: node render.mjs <outDir> [fps] [only-frames,comma]
import { chromium } from '/opt/node-tools/node_modules/playwright/index.mjs';
import fs from 'node:fs';
import path from 'node:path';
import url from 'node:url';

const out = process.argv[2] || 'frames';
const fps = Number(process.argv[3] || 30);
const only = process.argv[4] ? process.argv[4].split(',').map(Number) : null;
fs.mkdirSync(out, { recursive: true });
const here = path.dirname(url.fileURLToPath(import.meta.url));
const browser = await chromium.launch();
const page = await browser.newPage({ viewport: { width: 2400, height: 600 } });
page.on('pageerror', e => { console.error('PAGE ERROR', e); process.exit(1); });
await page.goto(url.pathToFileURL(path.join(here, 'scene.html')).href + '?capture');
const loop = await page.evaluate(() => window.LOOP);
const total = Math.round(loop * fps);
const list = only || [...Array(total).keys()];
for (const i of list) {
  const data = await page.evaluate(t => { window.render(t); return document.getElementById('c').toDataURL('image/png'); }, i / fps);
  fs.writeFileSync(path.join(out, `f${String(i).padStart(4, '0')}.png`), Buffer.from(data.split(',')[1], 'base64'));
}
await browser.close();
console.log(`rendered ${list.length}/${total} frames`);
