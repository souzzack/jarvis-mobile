// node colisao.js [passo] [t0] [t1]  — checa, por caixas (Box3) a cada `passo` segundos, Kai × Luna e Kai/Luna × cenário.
// Pés tocando degrau/chão e a pessoa sentada na própria moto são esperados e ignorados.
const { chromium } = require('playwright');
(async () => {
  const passo = +(process.argv[2] || 0.25);
  const b = await chromium.launch({ args: ['--use-gl=angle', '--use-angle=swiftshader', '--enable-unsafe-swiftshader'] });
  const p = await b.newPage({ viewport: { width: 270, height: 480 } });
  await p.goto('http://localhost:8766/nova-conta/neon/cap01.html?w=270&t0=${process.argv[3] || 0}&t1=${process.argv[4] || 72}'); await p.waitForFunction(() => window.__ready);
  const res = await p.evaluate((passo) => {
    const { KAI, LUNA, THREE, SET } = window.__dbg; const out = [];
    const caixas = (root, filtro = () => true) => { const r = []; root.updateMatrixWorld(true); root.traverse(o => { if (o.isMesh && filtro(o)) r.push([o, new THREE.Box3().setFromObject(o).expandByScalar(-0.02)]); }); return r; };
    const visivel = o => { let x = o; while (x) { if (!x.visible) return false; x = x.parent; } return true; };
    const T0 = +(new URLSearchParams(location.search).get("t0") || 0), T1 = +(new URLSearchParams(location.search).get("t1") || window.__dur); for (let t = T0; t < T1; t += passo) {
      window.frame(t);
      const pessoas = [['Kai', KAI], ['Luna', LUNA]].filter(([, q]) => visivel(q.root));
      for (const [n, q] of pessoas) {
        const bx = caixas(q.root, o => o.geometry.type !== 'SphereGeometry' || o.position.y !== -0.58 || true);
        for (const [nome, obj] of Object.entries(SET)) {
          if (!visivel(obj)) continue; if (nome === 'MOTO' && q.root.parent === obj) continue;
          const so = caixas(obj); if (nome === 'ESC') { /* degraus: só acusa se o corpo (acima dos pés) entra */ }
          for (const [m, a] of bx) for (const [m2, c] of so) {
            if (!a.intersectsBox(c)) continue;
            const pe = m.parent !== q.body && m.position.y < -0.55; // pé
            if (nome === 'ESC' && pe) continue;
            out.push(`${t.toFixed(2)}s ${nome} parte=${m.parent === q.body ? 'corpo' : m.parent.parent === q.body ? 'coxa/braco' : 'canela/pe/mao'} meshY=${m.getWorldPosition(new THREE.Vector3()).y.toFixed(2)} degrau y=${m2.position.y.toFixed(2)} z=${m2.position.z.toFixed(2)} kaiY=${q.root.position.y.toFixed(2)} kaiZ=${q.root.position.z.toFixed(2)}`); break;
          }
        }
      }
      if (pessoas.length === 2) { const A = caixas(KAI.root), B = caixas(LUNA.root);
        if (A.some(([, a]) => B.some(([, c]) => a.intersectsBox(c)))) out.push(`${t.toFixed(2)}s Kai × Luna`); }
    }
    return [...new Set(out)];
  }, passo);
  console.log(res.length ? res.join('\n') : 'Sem colisões.');
  await b.close();
})();
