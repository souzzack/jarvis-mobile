const { chromium } = require('playwright');
(async () => {
  const b = await chromium.launch(); const p = await b.newPage();
  await p.goto('http://localhost:8765/tune.html'); await p.waitForFunction(() => window.__ready);
  const res = await p.evaluate(() => {
    const out = {}; const R = (a, b, n) => [...Array(n).keys()].map(i => a + (b - a) * i / (n - 1));
    // orar: mãos juntas na frente do peito
    let best = null;
    for (const sx of R(-1.6, -0.5, 12)) for (const sz of R(-0.7, 0.1, 9)) for (const ex of R(-2.2, -0.6, 12)) {
      const r = window.test({ sx, sz, ex }); if (r.hits) continue;
      const [x1, y1, z1] = r.hr, [x2, y2, z2] = r.hl; const gap = Math.hypot(x1 - x2, y1 - y2, z1 - z2);
      const score = gap * 3 + Math.abs(y1 - 1.35) + Math.max(0, 0.55 - z1) * 4;
      if (!best || score < best.score) best = { score, sx, sz, ex, r };
    }
    out.pray = best;
    // mão no peito (só a direita)
    best = null;
    for (const sx of R(-1.4, -0.2, 13)) for (const sz of R(-0.9, 0.2, 12)) for (const ex of R(-2.4, -0.4, 11)) {
      const r = window.test({ sx, sz, ex, sxL: -0.35, szL: -0.08, exL: -0.8 }); if (r.hits) continue;
      const [x, y, z] = r.hr; const score = Math.abs(x - 0.0) + Math.abs(y - 1.3) * 1.5 + Math.abs(z - 0.42) * 2;
      if (!best || score < best.score) best = { score, sx, sz, ex, r };
    }
    out.chest = best;
    // enxugar o olho (mão direita perto do olho, na frente do rosto)
    best = null;
    for (const sx of R(-3.0, -1.4, 13)) for (const sz of R(-0.6, 0.6, 9)) for (const ex of R(-2.6, -0.6, 11)) {
      const r = window.test({ sx, sz, ex, sxL: -0.35, szL: -0.08, exL: -0.8 }); if (r.hits) continue;
      const [x, y, z] = r.hr, [hx, hy, hz] = r.head; const score = Math.abs(x - (hx - 0.25)) + Math.abs(y - (hy + 0.0)) * 1.5 + Math.abs(z - (hz + 0.72)) * 2;
      if (!best || score < best.score) best = { score, sx, sz, ex, r };
    }
    out.wipe = best;
    // cobrir o rosto (espelho, em pé): mão na frente do rosto
    best = null;
    for (const sx of R(-3.0, -1.4, 13)) for (const sz of R(-0.6, 0.6, 9)) for (const ex of R(-2.6, -0.6, 11)) {
      const r = window.test({ sx, sz, ex, sxL: -0.35, szL: -0.08, exL: -0.8 }); if (r.hits) continue;
      const [x, y, z] = r.hr, [hx, hy, hz] = r.head; const score = Math.abs(x - hx) + Math.abs(y - hy) * 1.5 + Math.abs(z - (hz + 0.7)) * 2;
      if (!best || score < best.score) best = { score, sx, sz, ex, r };
    }
    out.cover = best;
    // segurar algo (celular/bilhete/pedra) na frente do peito com as duas mãos
    best = null;
    for (const sx of R(-1.4, -0.4, 11)) for (const sz of R(-0.1, 0.5, 7)) for (const ex of R(-1.8, -0.2, 9)) {
      const r = window.test({ sx, sz, ex }); if (r.hits) continue;
      const [x1, y1, z1] = r.hr, [x2] = r.hl; const score = Math.abs(Math.abs(x1 - x2) - 0.45) + Math.abs(y1 - 1.15) + Math.abs(z1 - 0.65);
      if (!best || score < best.score) best = { score, sx, sz, ex, r };
    }
    out.hold = best;
    out.atual = { pray: window.test({ sx: -1.2, sz: -0.45, ex: -1.25 }), chest: window.test({ sx: -0.95, sz: -0.45, ex: -1.6, sxL: -0.35, szL: -0.08, exL: -0.8 }), wipe: window.test({ sx: -2.4, sz: 0.35, ex: -2.0, sxL: -0.35, szL: -0.08, exL: -0.8 }), hold: window.test({ sx: -0.95, sz: 0.3, ex: -0.95 }) };
    return out;
  });
  console.log(JSON.stringify(res, null, 0).replace(/},"/g, '},\n"'));
  await b.close();
})();
