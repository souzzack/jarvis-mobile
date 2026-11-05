// node render_ep.js <pagina> <plano> <saida> [tempos]  — renderiza um plano (24 fps; quadros nomeados pelo tempo do vídeo)
const { chromium } = require('playwright');
const fs = require('fs');
const [, , page, shot, outdir, only] = process.argv;
(async () => {
  fs.mkdirSync(outdir, { recursive: true });
  const b = await chromium.launch({ args: ['--use-gl=angle', '--use-angle=swiftshader', '--enable-unsafe-swiftshader'] });
  const p = await b.newPage({ viewport: { width: 1080, height: 1920 }, deviceScaleFactor: 1 });
  p.on('pageerror', e => console.log('err:', e.message));
  await p.goto(`http://localhost:8765/${page}?shot=${shot}`);
  await p.waitForFunction(() => window.__ready, null, { timeout: 240000 });
  const [t0, t1] = await p.evaluate(() => window.__range);
  const f0 = Math.round(t0 * 24), f1 = Math.round(t1 * 24);
  const frames = only ? only.split(',').map(t => Math.round(Number(t) * 24)) : [...Array(f1 - f0).keys()].map(i => f0 + i);
  for (const f of frames) {
    const name = only ? `${shot}_${(f / 24).toFixed(2)}` : String(f).padStart(5, '0');
    if (!only && fs.existsSync(`${outdir}/${name}.jpg`)) continue;
    await p.evaluate(t => window.frame(t), f / 24);
    await p.screenshot({ path: `${outdir}/${name}.jpg`, type: 'jpeg', quality: 92, timeout: 0 });
  }
  await b.close();
})();
