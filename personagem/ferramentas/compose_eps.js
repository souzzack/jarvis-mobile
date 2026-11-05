// Gera os quadros pós-produzidos: node compose_run.js <outdir> [lista de tempos]
const { chromium } = require('playwright');
const fs = require('fs');
const [, , outdir, a0, a1] = process.argv; const only = null;
(async () => {
  fs.mkdirSync(outdir, { recursive: true });
  const b = await chromium.launch();
  const p = await b.newPage({ viewport: { width: 1080, height: 1920 }, deviceScaleFactor: 1 });
  p.on('pageerror', e => console.log('err:', e.message));
  await p.goto('http://localhost:8765/compose_ep.html?ep=' + process.env.EP);
  await p.waitForFunction(() => window.__ready, null, { timeout: 60000 });
  const times = only ? only.split(',').map(Number) : [...Array(+a1 - +a0).keys()].map(i => (i + +a0) / 24);
  const t0 = Date.now();
  for (let i = 0; i < times.length; i++) {
    await p.evaluate(T => window.draw(T), times[i]);
    const name = only ? `t${times[i]}` : String(i + +a0).padStart(4, '0');
    await p.screenshot({ path: `${outdir}/${name}.jpg`, type: 'jpeg', quality: 93, timeout: 0 });
    if (i % 120 === 0) console.log(`quadro ${i}/${times.length} ${((Date.now() - t0) / 1000).toFixed(0)}s`);
  }
  await b.close();
})();
