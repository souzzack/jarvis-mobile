// node render.js <pagina.html> <pasta_saida> <largura> <t0> <t1> [fps] [lista de tempos separados por vírgula]
// Renderiza quadros numerados pelo índice global (t*fps) e pula os que já existem (dá para retomar).
const { chromium } = require('playwright'); const fs = require('fs');
const [, , page, out, w = '1080', t0 = '0', t1 = '1', fps = '30', only] = process.argv;
(async () => {
  fs.mkdirSync(out, { recursive: true });
  const W = +w, H = Math.round(W * 16 / 9);
  const b = await chromium.launch({ args: ['--use-gl=angle', '--use-angle=swiftshader', '--enable-unsafe-swiftshader'] });
  const p = await b.newPage({ viewport: { width: W, height: H }, deviceScaleFactor: 1 });
  p.on('pageerror', e => console.log('err:', e.message));
  await p.goto(`http://localhost:8766/nova-conta/neon/${page}?w=${W}`);
  await p.waitForFunction(() => window.__ready, null, { timeout: 120000 });
  const F = +fps, list = only ? only.split(',').map(Number) : null;
  const frames = list ? list.map(t => Math.round(t * F)) : [...Array(Math.round((+t1 - +t0) * F)).keys()].map(i => Math.round(+t0 * F) + i);
  for (const f of frames) {
    const name = list ? `t${(f / F).toFixed(1)}` : String(f).padStart(5, '0');
    if (!list && fs.existsSync(`${out}/${name}.jpg`)) continue;
    await p.evaluate(t => window.frame(t), f / F);
    await p.screenshot({ path: `${out}/${name}.jpg`, type: 'jpeg', quality: 90 });
  }
  await b.close();
})();
