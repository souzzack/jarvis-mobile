// node story_run.js <outdir> <i0> <i1>  |  node story_run.js <outdir> t:1.5,4,8
const { chromium } = require('playwright');
const fs = require('fs');
const [, , out, a, b] = process.argv;
(async () => {
  fs.mkdirSync(out, { recursive: true });
  const br = await chromium.launch({ args: ['--use-gl=angle', '--use-angle=swiftshader', '--enable-unsafe-swiftshader'] });
  const p = await br.newPage({ viewport: { width: 1080, height: 1920 } });
  p.on('pageerror', e => console.log('err', e.message));
  await p.goto('http://localhost:8765/' + (process.env.PAGE || 'story.html'));
  await p.waitForFunction(() => window.__ready, null, { timeout: 120000 });
  const list = a.startsWith('t:') ? a.slice(2).split(',').map(Number).map(t => [t, 't' + t]) : [...Array(+b - +a).keys()].map(i => [(i + +a) / 24, String(i + +a).padStart(4, '0')]);
  for (const [t, name] of list) { await p.evaluate(t => window.frame(t), t); await p.screenshot({ path: `${out}/${name}.jpg`, type: 'jpeg', quality: 93 }); }
  await br.close();
})();
