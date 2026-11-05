const { chromium } = require('playwright');
(async () => { const b = await chromium.launch({ args: ['--use-gl=angle', '--use-angle=swiftshader', '--enable-unsafe-swiftshader'] });
  const p = await b.newPage({ viewport: { width: 1080, height: 1920 }, deviceScaleFactor: +(process.env.DSF || 1) }); p.on('pageerror', e => console.log('err', e.message));
  await p.goto('http://localhost:8765/' + process.argv[2]); await p.waitForFunction(() => window.__ready, null, { timeout: 120000 });
  await p.screenshot({ path: process.argv[3], omitBackground: true }); await b.close(); })();
