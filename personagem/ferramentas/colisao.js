// Checa colisões em todos os planos de um episódio: personagem × personagem, personagem × móveis, braço × próprio corpo.
// uso: node colisao.js ep07 [passo]
const { chromium } = require('playwright');
const [, , ep, stepArg] = process.argv; const step = +(stepArg || 0.5);
(async () => {
  const b = await chromium.launch({ args: ['--use-gl=angle', '--use-angle=swiftshader', '--enable-unsafe-swiftshader'] });
  const p0 = await b.newPage({ viewport: { width: 540, height: 960 } });
  await p0.goto(`http://localhost:8765/${ep}.html?shot=SH01&q=0.2`);
  await p0.waitForFunction(() => window.__ready, null, { timeout: 240000 });
  const shots = await p0.evaluate(() => Object.keys(window.__shots || {}));
  await p0.close();
  const list = shots.length ? shots : [...Array(30).keys()].map(i => 'SH' + String(i + 1).padStart(2, '0'));
  for (const sh of list) {
    const p = await b.newPage({ viewport: { width: 540, height: 960 } });
    try { await p.goto(`http://localhost:8765/${ep}.html?shot=${sh}&q=0.2`); await p.waitForFunction(() => window.__ready, null, { timeout: 240000 }); }
    catch (e) { await p.close(); continue; }
    const res = await p.evaluate(async (step) => {
      const THREE = window.__THREE; const { OBB } = await import('./node_modules/three/examples/jsm/math/OBB.js');
      const [t0, t1] = window.__range; const out = {};
      const charOf = (o) => { while (o) { if (o.userData && o.userData.char) return o.userData.char; o = o.parent; } return 0; };
      const partOf = (m) => { let o = m; const names = []; while (o && !(o.userData && o.userData.char)) { names.push(o); o = o.parent; } return names; };
      for (let t = t0 + 0.05; t < t1; t += step) {
        window.__update(t); window.__scene.updateMatrixWorld(true);
        const meshes = []; window.__scene.traverse(o => {
          if (!o.isMesh || !o.geometry || o.isSprite) return; let v = o; while (v) { if (!v.visible) return; v = v.parent; }
          if (o.material && o.material.transparent && o.material.opacity < 0.5) return;
          o.geometry.computeBoundingBox(); const bb = o.geometry.boundingBox; const size = bb.getSize(new THREE.Vector3()); if (size.x * size.y * size.z === 0 && Math.min(size.x, size.y, size.z) === 0 && Math.max(size.x, size.y, size.z) > 1) return;
          const ws = new THREE.Vector3(); o.getWorldScale(ws); const big = Math.max(size.x * ws.x, size.y * ws.y, size.z * ws.z);
          const ch = charOf(o); if (!ch && big > 3.5) return; // paredes/chão/ignorar
          const obb = new OBB(); obb.center.copy(bb.getCenter(new THREE.Vector3())); obb.halfSize.copy(size).multiplyScalar(0.5 * 0.9); obb.applyMatrix4(o.matrixWorld);
          meshes.push({ o, ch, obb, size: size.x * size.y * size.z });
        });
        const chars = meshes.filter(m => m.ch), props = meshes.filter(m => !m.ch && m.size > 0.0005); out.__n = [meshes.length, chars.length, props.length];
        const hit = (key) => { out[key] = out[key] || []; if (out[key].length < 6) out[key].push(+t.toFixed(2)); };
        // o próprio corpo: antebraço/mão atravessando tronco, cabeça ou pernas; uma perna na outra
        const roots = new Set(chars.map(m => { let o = m.o; while (!(o.userData && o.userData.char)) o = o.parent; return o; }));
        const obbOf = new Map(meshes.map(m => [m.o, m.obb]));
        const under = (g) => { const r = []; g.traverse(o => { if (obbOf.has(o)) r.push(obbOf.get(o)); }); return r; };
        for (const root of roots) {
          const api = root.userData.api; if (!api) continue;
          const arms = [...under(api.arms.L.elbow), ...under(api.arms.R.elbow)];
          const torso = api.body.children.filter(o => obbOf.has(o)).map(o => obbOf.get(o));
          const head = under(api.head), legs = api.legs.map(l => under(l.hip));
          for (const [nm, list] of [['tronco', torso], ['cabeça', head], ['perna', [...legs[0], ...legs[1]]]]) for (const a of arms) for (const x of list) if (a.intersectsOBB(x)) hit(`personagem ${root.userData.char}: braço × ${nm}`);
          for (const a of legs[0]) for (const x of legs[1]) if (a.intersectsOBB(x)) hit(`personagem ${root.userData.char}: perna × perna`);
        }
        // personagem × personagem
        for (let i = 0; i < chars.length; i++) for (let j = i + 1; j < chars.length; j++) if (chars[i].ch !== chars[j].ch && chars[i].obb.intersectsOBB(chars[j].obb)) hit(`personagem ${chars[i].ch} × personagem ${chars[j].ch}`);
        // personagem × móveis (exceto pés/sapatos no chão e quem está sentado: assento sob o quadril é normal)
        for (const c of chars) for (const pr of props) if (c.obb.intersectsOBB(pr.obb)) { const y = c.obb.center.y; hit(`personagem ${c.ch} × objeto (${pr.o.geometry.type} em y≈${pr.obb.center.y.toFixed(1)})`); }
      }
      return out;
    }, step);
    const nn = res.__n; delete res.__n; const keys = Object.keys(res); 
    console.log(`${sh}: ${keys.length ? keys.map(k => `${k} em ${res[k].join(',')}`).join(' | ') : 'ok'}`);
    await p.close();
  }
  await b.close();
})();
