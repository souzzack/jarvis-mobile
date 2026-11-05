// Cenários extras do vídeo do Davi: igreja (lembrança do Lucas), cidade ao amanhecer e o prédio visto de fora à noite.
import * as THREE from 'three';
import { RoundedBoxGeometry } from 'three/addons/geometries/RoundedBoxGeometry.js';

const rb = (w, h, d, r, m, seg = 3) => new THREE.Mesh(new RoundedBoxGeometry(w, h, d, seg, r), m);
const std = (color, roughness = 0.8, extra = {}) => new THREE.MeshStandardMaterial({ color, roughness, ...extra });
const tex = (w, h, draw) => { const c = document.createElement('canvas'); c.width = w; c.height = h; draw(c.getContext('2d'), w, h); const t = new THREE.CanvasTexture(c); t.colorSpace = THREE.SRGBColorSpace; return t; };
let seed = 9; const rnd = () => { seed = (seed * 16807) % 2147483647; return seed / 2147483647; };

// ---------- Igreja: bancos de madeira, vitral colorido, luz dourada
export function createIgreja(scene) {
  scene.background = new THREE.Color(0x2a1f18);
  const floor = new THREE.Mesh(new THREE.PlaneGeometry(30, 30), std(0x7a5a3c, 0.7)); floor.rotation.x = -Math.PI / 2; floor.receiveShadow = true; scene.add(floor);
  const wall = new THREE.Mesh(new THREE.BoxGeometry(30, 12, 0.3), std(0xe8dcc6, 0.95)); wall.position.set(0, 6, -6); scene.add(wall);
  const vitral = tex(512, 768, (g, w, h) => {
    g.fillStyle = '#1b1530'; g.fillRect(0, 0, w, h);
    const cols = ['#e8b23a', '#3a7bd5', '#c0392b', '#2ecc71', '#9b59b6', '#f39c12'];
    for (let y = 0; y < h; y += 64) for (let x = 0; x < w; x += 64) { g.fillStyle = cols[Math.floor(rnd() * cols.length)]; g.fillRect(x + 3, y + 3, 58, 58); }
    g.fillStyle = '#fff5d6'; g.fillRect(w / 2 - 28, 110, 56, 520); g.fillRect(w / 2 - 150, 240, 300, 56);
  });
  const win = new THREE.Mesh(new THREE.PlaneGeometry(3, 4.5), new THREE.MeshStandardMaterial({ color: 0x000000, emissive: 0xffffff, emissiveMap: vitral, emissiveIntensity: 1.4 }));
  win.position.set(0, 5.2, -5.84); scene.add(win);
  const arch = new THREE.Mesh(new THREE.CircleGeometry(1.5, 32, 0, Math.PI), new THREE.MeshStandardMaterial({ color: 0x000000, emissive: 0xffe2a0, emissiveIntensity: 1.2 }));
  arch.position.set(0, 7.45, -5.84); scene.add(arch);
  const wood = std(0x6b4128, 0.6);
  for (let r = 0; r < 4; r++) for (const sx of [-2.6, 2.6]) {
    const z = -3.2 + r * 2.0;
    const seat = rb(3.6, 0.18, 0.8, 0.05, wood); seat.position.set(sx, 0.85, z); scene.add(seat);
    const back = rb(3.6, 1.0, 0.14, 0.05, wood); back.position.set(sx, 1.4, z - 0.38); scene.add(back);
    for (const ex of [-1.75, 1.75]) { const leg = rb(0.14, 0.85, 0.8, 0.03, wood); leg.position.set(sx + ex, 0.42, z); scene.add(leg); }
  }
  scene.add(new THREE.HemisphereLight(0xfff0d6, 0x3a2a20, 0.9));
  const sun = new THREE.SpotLight(0xffd79a, 220, 30, 0.6, 0.6, 1.2); sun.position.set(0, 8, -4); sun.target.position.set(2.6, 1, 1); sun.castShadow = true; scene.add(sun, sun.target);
  const fill = new THREE.PointLight(0xffe6c8, 18, 20, 2); fill.position.set(3, 4, 6); scene.add(fill);
  return { pew: { x: 2.6, z: 0.8, top: 0.94 } };
}

// ---------- Cidade (amanhecer ou noite) com prédios em blocos
function predio(w, h, d, wallColor, lit, warmWin) {
  const g = new THREE.Group();
  const body = new THREE.Mesh(new THREE.BoxGeometry(w, h, d), std(wallColor, 0.9)); body.position.y = h / 2; g.add(body);
  const winDark = std(0x1a2238, 0.4), winLit = new THREE.MeshStandardMaterial({ color: 0x000000, emissive: warmWin ? 0xffc36a : 0xbfd6ff, emissiveIntensity: 1.2 });
  for (let y = 1.0; y < h - 0.6; y += 1.1) for (let x = -w / 2 + 0.6; x < w / 2 - 0.4; x += 0.9) {
    const m = new THREE.Mesh(new THREE.PlaneGeometry(0.45, 0.6), rnd() < lit ? winLit : winDark);
    m.position.set(x, y, d / 2 + 0.01); g.add(m);
  }
  return g;
}
export function createCidade(scene, mode) {
  const dawn = mode === 'amanhecer';
  const skyC = document.createElement('canvas'); skyC.width = 16; skyC.height = 512;
  const skyT = new THREE.CanvasTexture(skyC); skyT.colorSpace = THREE.SRGBColorSpace; scene.background = skyT;
  function paintSky(k) { // k: 0 = noite, 1 = amanhecer
    const g = skyC.getContext('2d'); const gr = g.createLinearGradient(0, 0, 0, 512);
    const mixc = (a, b) => { const pa = a.match(/\w\w/g).map(v => parseInt(v, 16)), pb = b.match(/\w\w/g).map(v => parseInt(v, 16)); return `rgb(${pa.map((v, i) => Math.round(v + (pb[i] - v) * k)).join(',')})`; };
    gr.addColorStop(0, mixc('0b1230', '3a5fa8')); gr.addColorStop(0.55, mixc('1d2457', 'f0a46a')); gr.addColorStop(1, mixc('3a2f5c', 'ffd9a0'));
    g.fillStyle = gr; g.fillRect(0, 0, 16, 512); skyT.needsUpdate = true;
  }
  paintSky(dawn ? 0 : 0);
  const ground = new THREE.Mesh(new THREE.PlaneGeometry(200, 200), std(0x1b1e2c, 1)); ground.rotation.x = -Math.PI / 2; scene.add(ground);
  const cols = [0x3a4060, 0x2f3550, 0x454b6e, 0x353a58];
  for (let row = 0; row < 3; row++) for (let i = -9; i <= 9; i++) {
    const w = 3 + rnd() * 3, h = 6 + rnd() * (14 + row * 6), d = 4;
    const b = predio(w, h, d, cols[(i + 9 + row) % 4], dawn ? 0.15 : 0.35, true);
    b.position.set(i * 6.5 + rnd() * 2, 0, -12 - row * 14); scene.add(b);
  }
  const hemi = new THREE.HemisphereLight(0x8fa0ff, 0x1a1420, 0.5); scene.add(hemi);
  const sunMat = new THREE.MeshBasicMaterial({ color: 0xffe0a0 });
  const sun = new THREE.Mesh(new THREE.SphereGeometry(5, 32, 24), sunMat); sun.position.set(8, -4, -75); scene.add(sun);
  const sunLight = new THREE.DirectionalLight(0xffc27a, 0); sunLight.position.set(6, 4, -60); scene.add(sunLight);
  const moon = new THREE.Mesh(new THREE.SphereGeometry(2.2, 24, 16), new THREE.MeshBasicMaterial({ color: 0xf4ecd2 })); moon.position.set(-18, 34, -80); scene.add(moon);
  function setDawn(k) { // nascer do sol de 0 a 1
    paintSky(k); sun.position.y = -4 + 30 * k; sunLight.intensity = 3.2 * k; hemi.intensity = 0.5 + 0.8 * k; moon.visible = k < 0.35;
  }
  // prédio do Davi (para o plano final) com a janela quente
  const home = predio(8, 18, 6, 0x4a4f72, 0.12, false); home.position.set(0, 0, 0); scene.add(home);
  const hw = new THREE.Mesh(new THREE.PlaneGeometry(1.4, 1.2), new THREE.MeshStandardMaterial({ color: 0x000000, emissive: 0xffc77a, emissiveIntensity: 2.6 }));
  hw.position.set(-1.0, 9.0, 3.02); scene.add(hw);
  const glow = new THREE.PointLight(0xffc77a, 30, 8, 2); glow.position.set(-1.0, 9.0, 4.0); scene.add(glow);
  home.visible = hw.visible = glow.visible = !dawn;
  return { setDawn, homeWindow: hw.position.clone() };
}

// ---------- Pátio da escola (episódio 2): quadra, prédio, árvores, bancos
export function createEscola(scene) {
  scene.background = new THREE.Color(0x9fd0f2);
  scene.fog = new THREE.Fog(0x9fd0f2, 30, 70);
  const ground = new THREE.Mesh(new THREE.PlaneGeometry(80, 80), std(0xcdbb98, 0.95)); ground.rotation.x = -Math.PI / 2; ground.receiveShadow = true; scene.add(ground);
  const court = new THREE.Mesh(new THREE.PlaneGeometry(14, 9), std(0x4f8f6a, 0.9)); court.rotation.x = -Math.PI / 2; court.position.set(3, 0.01, -1); court.receiveShadow = true; scene.add(court);
  const lineM = new THREE.MeshBasicMaterial({ color: 0xf2efe6 });
  for (const [w, h, x, z] of [[14, 0.08, 3, 3.5], [14, 0.08, 3, -5.5], [0.08, 9, -4, -1], [0.08, 9, 10, -1], [0.08, 9, 3, -1]]) { const l = new THREE.Mesh(new THREE.PlaneGeometry(w, h), lineM); l.rotation.x = -Math.PI / 2; l.position.set(x, 0.02, z); scene.add(l); }
  const ring = new THREE.Mesh(new THREE.RingGeometry(1.4, 1.48, 48), lineM); ring.rotation.x = -Math.PI / 2; ring.position.set(3, 0.02, -1); scene.add(ring);
  // prédio da escola ao fundo
  const bld = new THREE.Mesh(new THREE.BoxGeometry(34, 7, 3), std(0xe8b98a, 0.9)); bld.position.set(2, 3.5, -12); bld.receiveShadow = true; scene.add(bld);
  const roof = new THREE.Mesh(new THREE.BoxGeometry(35, 0.5, 3.6), std(0xa4553c, 0.8)); roof.position.set(2, 7.2, -12); scene.add(roof);
  const winM = std(0x7fb6d9, 0.3), frm = std(0xf4efe6, 0.7);
  for (let x = -13; x <= 17; x += 3) for (const y of [2.2, 5.0]) {
    const f = rb(1.7, 1.5, 0.12, 0.04, frm); f.position.set(x, y, -10.48); scene.add(f);
    const w = new THREE.Mesh(new THREE.PlaneGeometry(1.45, 1.25), winM); w.position.set(x, y, -10.4); scene.add(w);
  }
  const door = rb(2.2, 3, 0.2, 0.05, std(0x3c6e9e, 0.6)); door.position.set(2, 1.5, -10.45); scene.add(door);
  // árvores
  const trunkM = std(0x6b4128, 0.9), leafM = std(0x4c9a4a, 0.85);
  for (const [x, z, s] of [[-8, -6, 1.2], [18, -10, 1.4], [-11, 1, 1.0], [16, 3, 1.1]]) {
    const tr = rb(0.5 * s, 2.6 * s, 0.5 * s, 0.08, trunkM); tr.position.set(x, 1.3 * s, z); scene.add(tr);
    for (const [dx, dy, dz, r] of [[0, 3.3, 0, 1.3], [0.8, 2.9, 0.2, 0.9], [-0.7, 3.0, -0.2, 1.0], [0.1, 4.0, 0.1, 0.9]]) {
      const l = rb(2 * r * s, 1.7 * r * s, 2 * r * s, 0.3 * r, leafM); l.position.set(x + dx * s, dy * s, z + dz * s); scene.add(l);
    }
  }
  // bancos: o do Davi (perto) e o do fundo (onde o menino novo fica)
  const wood = std(0x8a5a35, 0.7), metal = std(0x4a4f5c, 0.5);
  const bench = (x, z, ry) => {
    const g = new THREE.Group(); g.position.set(x, 0, z); g.rotation.y = ry;
    const seat = rb(3.0, 0.14, 0.7, 0.04, wood); seat.position.y = 0.8; g.add(seat);
    const back = rb(3.0, 0.5, 0.1, 0.04, wood); back.position.set(0, 1.35, -0.32); g.add(back);
    for (const ex of [-1.3, 1.3]) { const l = rb(0.12, 0.8, 0.6, 0.02, metal); l.position.set(ex, 0.4, 0); g.add(l); const p = rb(0.1, 0.7, 0.1, 0.02, metal); p.position.set(ex, 1.15, -0.32); g.add(p); }
    scene.add(g); return g;
  };
  const benchA = bench(-5.5, 3.2, 0.5), benchB = bench(12.5, -6.5, -0.3);
  // gol pequeno
  const goal = new THREE.Group(); goal.position.set(10, 0, -1);
  for (const z of [-1, 1]) { const p = rb(0.12, 1.4, 0.12, 0.02, frm); p.position.set(0, 0.7, z); goal.add(p); }
  const bar = rb(0.12, 0.12, 2.1, 0.02, frm); bar.position.set(0, 1.4, 0); goal.add(bar); scene.add(goal);
  scene.add(new THREE.HemisphereLight(0xcfe8ff, 0x8a7a5a, 1.1));
  const sun = new THREE.DirectionalLight(0xfff0d8, 2.6); sun.position.set(-8, 14, 9); sun.castShadow = true;
  sun.shadow.mapSize.set(2048, 2048); Object.assign(sun.shadow.camera, { left: -20, right: 20, top: 20, bottom: -20, near: 1, far: 50 }); scene.add(sun);
  return { benchA, benchB };
}
