// Renderiza as vistas da prévia em PNG (Chromium headless do ambiente).
const { chromium } = require('playwright');
const http = require('http');
const fs = require('fs');
const path = require('path');
const dir = __dirname;
const tipos = { '.html': 'text/html', '.js': 'text/javascript' };
const srv = http.createServer((req, res) => {
  const f = path.join(dir, decodeURIComponent(req.url.split('?')[0].split('#')[0]));
  if (!f.startsWith(dir) || !fs.existsSync(f)) { res.writeHead(404); return res.end(); }
  res.writeHead(200, { 'Content-Type': tipos[path.extname(f)] || 'application/octet-stream' });
  fs.createReadStream(f).pipe(res);
}).listen(8765, async () => {
  const b = await chromium.launch({ args: ['--use-gl=swiftshader', '--enable-unsafe-swiftshader'] });
  const p = await b.newPage({ viewport: { width: 1600, height: 900 }, deviceScaleFactor: 1 });
  p.on('pageerror', e => console.log('ERRO', e.message));
  for (const v of process.argv.slice(2)) {
    await p.goto(`http://localhost:8765/${v.startsWith('ui') ? 'ui.html' : 'cena.html'}#${v}`);
    await p.reload();
    await p.waitForFunction(() => window.__pronto === true, null, { timeout: 60000 });
    await p.screenshot({ path: path.join(dir, `previa-${v}.png`) });
    console.log('ok', v);
  }
  await b.close(); srv.close();
});
