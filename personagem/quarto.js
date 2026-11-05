// Quarto do Davi à noite: janela com a cidade, cama, abajur, calendário e a luz quente "de Deus" pela janela.
import * as THREE from 'three';
import { RoundedBoxGeometry } from 'three/addons/geometries/RoundedBoxGeometry.js';

const rb = (w, h, d, r, m, seg = 3) => new THREE.Mesh(new RoundedBoxGeometry(w, h, d, seg, r), m);
const std = (color, roughness = 0.8, extra = {}) => new THREE.MeshStandardMaterial({ color, roughness, ...extra });
const tex = (w, h, draw) => { const c = document.createElement('canvas'); c.width = w; c.height = h; draw(c.getContext('2d'), w, h); const t = new THREE.CanvasTexture(c); t.colorSpace = THREE.SRGBColorSpace; t.anisotropy = 8; return t; };

export function cityNight(g, w, h, glow = 0) {
  const sky = g.createLinearGradient(0, 0, 0, h);
  sky.addColorStop(0, '#0b1230'); sky.addColorStop(0.6, '#1d2457'); sky.addColorStop(1, '#3a2f5c');
  g.fillStyle = sky; g.fillRect(0, 0, w, h);
  let s = 3; const r = () => { s = (s * 16807) % 2147483647; return s / 2147483647; };
  for (let i = 0; i < 120; i++) { g.fillStyle = `rgba(255,255,255,${0.3 + r() * 0.7})`; g.fillRect(r() * w, r() * h * 0.55, 2, 2); }
  g.fillStyle = '#f4ecd2'; g.beginPath(); g.arc(w * 0.78, h * 0.2, w * 0.06, 0, 7); g.fill();
  let x = 0;
  while (x < w) {
    const bw = 40 + r() * 90, bh = h * (0.25 + r() * 0.4);
    g.fillStyle = '#0d0f22'; g.fillRect(x, h - bh, bw, bh);
    for (let yy = h - bh + 12; yy < h - 8; yy += 18) for (let xx = x + 8; xx < x + bw - 10; xx += 16) {
      if (r() < 0.35) { g.fillStyle = r() < 0.5 ? '#ffd27a' : '#ffb85c'; g.fillRect(xx, yy, 7, 9); }
    }
    x += bw + 4;
  }
}

function calendario(g, w, h) {
  g.fillStyle = '#f4efe6'; g.fillRect(0, 0, w, h);
  g.fillStyle = '#c0392b'; g.fillRect(0, 0, w, 120);
  g.fillStyle = '#fff'; g.font = 'bold 64px DejaVu Sans'; g.textAlign = 'center'; g.fillText('OUTUBRO', w / 2, 84);
  const cw = w / 7, top = 150, ch = (h - top - 20) / 5;
  g.font = 'bold 26px DejaVu Sans'; g.textAlign = 'left';
  const notes = { 3: 'nunca mais!', 9: 'agora vai', 14: 'última vez', 20: 'juro', 26: 'de verdade' };
  for (let i = 0; i < 31; i++) {
    const cx = (i % 7) * cw, cy = top + Math.floor(i / 7) * ch;
    g.strokeStyle = '#d6cfc3'; g.lineWidth = 2; g.strokeRect(cx, cy, cw, ch);
    g.fillStyle = '#5b5550'; g.fillText(String(i + 1), cx + 10, cy + 32);
    if (notes[i]) {
      g.fillStyle = '#1f5fbf'; g.font = 'italic bold 22px DejaVu Sans'; g.fillText(notes[i], cx + 8, cy + ch - 22); g.font = 'bold 26px DejaVu Sans';
      g.strokeStyle = '#d6271c'; g.lineWidth = 7; g.lineCap = 'round';
      g.beginPath(); g.moveTo(cx + 14, cy + 14); g.lineTo(cx + cw - 14, cy + ch - 14); g.moveTo(cx + cw - 14, cy + 14); g.lineTo(cx + 14, cy + ch - 14); g.stroke();
    }
  }
}

function soft(color, opacity) {
  const t = tex(64, 256, (g, w, h) => { const gr = g.createLinearGradient(0, 0, 0, h); gr.addColorStop(0, 'rgba(255,255,255,1)'); gr.addColorStop(1, 'rgba(255,255,255,0)'); g.fillStyle = gr; g.fillRect(0, 0, w, h); });
  return new THREE.MeshBasicMaterial({ color, map: t, transparent: true, opacity, depthWrite: false, blending: THREE.AdditiveBlending, side: THREE.DoubleSide });
}

export function createQuarto(scene) {
  scene.background = new THREE.Color(0x0b0c18);
  // piso de madeira
  const planks = tex(512, 512, (g, w, h) => {
    for (let i = 0; i < 8; i++) { g.fillStyle = ['#6b4a35', '#634330', '#734f39'][i % 3]; g.fillRect(0, i * 64, w, 62); g.fillStyle = '#4a3122'; g.fillRect(0, i * 64 + 62, w, 2); }
  });
  planks.wrapS = planks.wrapT = THREE.RepeatWrapping; planks.repeat.set(3, 3);
  const floor = new THREE.Mesh(new THREE.PlaneGeometry(16, 16), new THREE.MeshStandardMaterial({ map: planks, roughness: 0.7 }));
  floor.rotation.x = -Math.PI / 2; floor.receiveShadow = true; scene.add(floor);
  const wallMat = std(0x2f3a5c, 0.95);
  const backWall = new THREE.Group();
  // parede do fundo com a abertura da janela (x -3.2..-0.4, y 1.9..4.5)
  const WX0 = -3.2, WX1 = -0.4, WY0 = 1.9, WY1 = 4.5, WZ = -4;
  const piece = (x0, x1, y0, y1) => { const m = new THREE.Mesh(new THREE.BoxGeometry(x1 - x0, y1 - y0, 0.2), wallMat); m.position.set((x0 + x1) / 2, (y0 + y1) / 2, WZ); m.receiveShadow = true; backWall.add(m); };
  piece(-8, WX0, 0, 7); piece(WX1, 8, 0, 7); piece(WX0, WX1, 0, WY0); piece(WX0, WX1, WY1, 7);
  scene.add(backWall);
  const side = new THREE.Mesh(new THREE.BoxGeometry(0.2, 7, 12), wallMat); side.position.set(-6, 3.5, 2); scene.add(side);
  const skirting = new THREE.Mesh(new THREE.BoxGeometry(16, 0.25, 0.1), std(0x1e2438)); skirting.position.set(0, 0.12, WZ + 0.12); scene.add(skirting);

  // janela: vidro com a cidade, moldura, cortinas
  const cityTex = tex(1024, 960, cityNight);
  const glassMat = new THREE.MeshStandardMaterial({ color: 0x000000, emissive: 0xffffff, emissiveMap: cityTex, emissiveIntensity: 0.9 });
  const glass = new THREE.Mesh(new THREE.PlaneGeometry(WX1 - WX0, WY1 - WY0), glassMat);
  glass.position.set((WX0 + WX1) / 2, (WY0 + WY1) / 2, WZ - 0.08); scene.add(glass);
  const frameMat = std(0xe9e4da, 0.5);
  const fx = (WX0 + WX1) / 2, fy = (WY0 + WY1) / 2;
  [[WX1 - WX0 + 0.2, 0.14, fx, WY1 + 0.07], [WX1 - WX0 + 0.2, 0.2, fx, WY0 - 0.1], [0.14, WY1 - WY0, WX0 - 0.07, fy], [0.14, WY1 - WY0, WX1 + 0.07, fy], [0.07, WY1 - WY0, fx, fy], [WX1 - WX0, 0.07, fx, fy]].forEach(([w, h, x, y]) => {
    const b = rb(w, h, 0.16, 0.02, frameMat); b.position.set(x, y, WZ + 0.05); scene.add(b);
  });
  const sill = rb(WX1 - WX0 + 0.5, 0.1, 0.45, 0.03, frameMat); sill.position.set(fx, WY0 - 0.2, WZ + 0.2); scene.add(sill);
  const curtainMat = std(0x2d6d73, 0.9);
  for (const [x, w] of [[WX0 - 0.45, 0.7], [WX1 + 0.45, 0.7]]) {
    const cu = rb(w, 3.4, 0.12, 0.05, curtainMat); cu.position.set(x, 3.3, WZ + 0.25); scene.add(cu);
  }
  const rod = new THREE.Mesh(new THREE.CylinderGeometry(0.035, 0.035, 4.6, 12), std(0x2b2b2b, 0.4, { metalness: 0.6 }));
  rod.rotation.z = Math.PI / 2; rod.position.set(fx, 5.05, WZ + 0.3); scene.add(rod);

  // cama (encostada no fundo, à direita) — topo do colchão em y = 0.95
  const bedX = 1.9, bedZ = -2.75;
  const wood = std(0x5a3d2b, 0.7);
  const bframe = rb(2.4, 0.45, 2.6, 0.06, wood); bframe.position.set(bedX, 0.32, bedZ); scene.add(bframe);
  const headb = rb(2.4, 1.6, 0.16, 0.06, wood); headb.position.set(bedX, 1.0, bedZ - 1.3); scene.add(headb);
  const mattress = rb(2.3, 0.35, 2.5, 0.1, std(0xeae6df, 0.9)); mattress.position.set(bedX, 0.72, bedZ); scene.add(mattress);
  const blanket = rb(2.36, 0.12, 1.7, 0.06, std(0x3b5f8a, 0.95)); blanket.position.set(bedX, 0.92, bedZ + 0.42); scene.add(blanket);
  const fold = rb(2.36, 0.12, 0.3, 0.05, std(0xf0ebe2, 0.9)); fold.position.set(bedX, 0.93, bedZ - 0.4); scene.add(fold);
  const pillow = rb(1.2, 0.26, 0.6, 0.13, std(0xf4f0e8, 0.95)); pillow.position.set(bedX, 1.0, bedZ - 0.85); pillow.rotation.x = -0.15; scene.add(pillow);
  // criado-mudo + abajur
  const ns = rb(0.9, 0.9, 0.8, 0.05, wood); ns.position.set(bedX + 1.8, 0.45, bedZ - 0.6); scene.add(ns);
  const lampBase = new THREE.Mesh(new THREE.CylinderGeometry(0.12, 0.18, 0.5, 16), std(0xd9c7a8, 0.5)); lampBase.position.set(bedX + 1.8, 1.15, bedZ - 0.6); scene.add(lampBase);
  const shade = new THREE.Mesh(new THREE.CylinderGeometry(0.28, 0.4, 0.42, 20, 1, true), new THREE.MeshStandardMaterial({ color: 0xffe2b0, emissive: 0xffb76a, emissiveIntensity: 1.6, side: THREE.DoubleSide }));
  shade.position.set(bedX + 1.8, 1.55, bedZ - 0.6); scene.add(shade);
  const lamp = new THREE.PointLight(0xffb070, 9, 9, 2); lamp.position.set(bedX + 1.8, 1.5, bedZ - 0.6); lamp.castShadow = true; lamp.shadow.mapSize.set(1024, 1024); scene.add(lamp);
  // cruz de madeira acima da cama
  const cross = new THREE.Group();
  const cv = rb(0.12, 0.7, 0.06, 0.02, wood); cross.add(cv);
  const chz = rb(0.42, 0.12, 0.06, 0.02, wood); chz.position.y = 0.12; cross.add(chz);
  cross.position.set(bedX, 2.6, WZ + 0.14); scene.add(cross);
  // calendário na parede (corte "qual das vezes?")
  const cal = new THREE.Mesh(new THREE.PlaneGeometry(1.3, 1.5), new THREE.MeshStandardMaterial({ map: tex(700, 800, calendario), roughness: 0.8 }));
  cal.position.set(-4.6, 3.1, WZ + 0.12); scene.add(cal);
  // tapete, bola, prateleira
  const rug = new THREE.Mesh(new THREE.CircleGeometry(1.8, 48), std(0x8a3f3a, 0.95)); rug.rotation.x = -Math.PI / 2; rug.position.set(0.6, 0.01, 0.6); scene.add(rug);
  const ballTex = tex(256, 128, (g, w, h) => { g.fillStyle = '#f3f3f3'; g.fillRect(0, 0, w, h); g.fillStyle = '#1c1c1c'; for (let i = 0; i < 8; i++) { g.beginPath(); g.arc((i * 37) % w, 20 + (i * 53) % 90, 14, 0, 7); g.fill(); } });
  const ball = new THREE.Mesh(new THREE.SphereGeometry(0.33, 24, 16), new THREE.MeshStandardMaterial({ map: ballTex, roughness: 0.5 })); ball.position.set(-1.8, 0.33, 0.9); scene.add(ball);
  const shelf = rb(1.6, 0.08, 0.35, 0.02, wood); shelf.position.set(4.6, 3.0, WZ + 0.2); scene.add(shelf);
  ['#c0392b', '#2e86de', '#f1c40f', '#27ae60', '#8e44ad'].forEach((c, i) => { const b = rb(0.16, 0.45 + (i % 2) * 0.1, 0.28, 0.02, std(c)); b.position.set(4.0 + i * 0.2, 3.27 + (i % 2) * 0.05, WZ + 0.2); scene.add(b); });

  // luzes da noite
  scene.add(new THREE.HemisphereLight(0x5b6aa8, 0x1a1420, 0.55));
  const moon = new THREE.DirectionalLight(0x8fa6ff, 0.6); moon.position.set(-3, 6, -8); scene.add(moon);
  const fill = new THREE.PointLight(0xffd7b8, 10, 14, 2); fill.position.set(2.8, 3.2, 3.2); scene.add(fill);
  const cool = new THREE.PointLight(0x7f95ff, 6, 12, 2); cool.position.set(-2.5, 2.5, 2.5); scene.add(cool);

  // luz de Deus: feixe quente entrando pela janela + raios visíveis + brilho no vidro
  const god = new THREE.SpotLight(0xffd59a, 0, 25, 0.55, 0.6, 1.2);
  god.position.set(fx - 0.6, 6.2, WZ - 3.5); god.target.position.set(bedX - 0.6, 0.8, -0.6);
  god.castShadow = true; god.shadow.mapSize.set(1024, 1024); god.shadow.bias = -0.0005;
  scene.add(god, god.target);
  const shafts = [];
  for (let i = 0; i < 4; i++) {
    const p = new THREE.Mesh(new THREE.PlaneGeometry(0.7 + i * 0.25, 5.6), soft(0xffd59a, 0));
    p.position.set(fx + 0.6 + i * 0.25 - 0.4, 2.4, -2.6 + i * 0.12);
    p.rotation.set(-0.55, 0.15 * (i - 1.5), 0.42);
    scene.add(p); shafts.push(p);
  }
  const windowGlow = new THREE.Mesh(new THREE.PlaneGeometry(WX1 - WX0 + 1.4, WY1 - WY0 + 1.4), soft(0xffe2b0, 0));
  windowGlow.material.map = tex(256, 256, (g, w, h) => { const gr = g.createRadialGradient(w / 2, h / 2, 10, w / 2, h / 2, w / 2); gr.addColorStop(0, 'rgba(255,255,255,1)'); gr.addColorStop(1, 'rgba(255,255,255,0)'); g.fillStyle = gr; g.fillRect(0, 0, w, h); });
  windowGlow.position.set(fx, fy, WZ + 0.3); scene.add(windowGlow);

  function setGod(v) { // 0 = só a noite, 1 = presença forte
    god.intensity = 200 * v;
    shafts.forEach((s, i) => { s.material.opacity = (0.06 + 0.03 * (i % 2)) * v; });
    windowGlow.material.opacity = 0.55 * v;
    glassMat.emissiveIntensity = 0.9 + 1.6 * v;
  }
  setGod(0.4);

  return { setGod, lamp, bed: { x: bedX, z: bedZ, top: 0.95 }, window: { x: fx, y: fy, z: WZ }, calendar: cal, cross };
}
