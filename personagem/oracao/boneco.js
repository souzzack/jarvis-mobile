// Boneco da série de orações no estilo "cubos de quina viva": cabeça cúbica, olhos quadrados grandes com pupila
// quadrada, sobrancelhas em bloco, nariz em cubinho, boca retangular, cabelo de cubos irregulares.
// Cores próprias (moletom vermelho, fone preto) para ter identidade própria. Mesma interface do gael.js.
import * as THREE from 'three';
import { RoundedBoxGeometry } from 'three/addons/geometries/RoundedBoxGeometry.js';

const bx = (w, h, d, m, r = 0.025) => new THREE.Mesh(new RoundedBoxGeometry(w, h, d, 2, Math.min(r, w / 2.1, h / 2.1, d / 2.1)), m);
const V = (x, y, z) => new THREE.Vector3(x, y, z);

export const CORES = { skin: 0xb5714a, skinDark: 0x9a5c3a, hair: 0x241610, hoodie: 0xc9433a, hoodieDark: 0xa53530, pants: 0x1f2433, phones: 0x15161c, cord: 0xf2eee8 };

export function createPersonagem(opts = {}) {
  const C = { ...CORES, ...opts };
  const M = (color, r = 0.75, extra = {}) => new THREE.MeshStandardMaterial({ color, roughness: r, ...extra });
  const skin = M(C.skin, 0.6), skinDark = M(C.skinDark, 0.6), hair = M(C.hair, 0.8), hood = M(C.hoodie, 0.85), hoodD = M(C.hoodieDark, 0.85);
  const white = M(0xcfc9be, 0.6), black = new THREE.MeshBasicMaterial({ color: 0x050404 }), mouthIn = M(0x1e0c0c, 0.9), teethM = M(0xcfc8bc, 0.7), shine = new THREE.MeshBasicMaterial({ color: 0xffffff });

  const root = new THREE.Group(), body = new THREE.Group(); root.add(body);
  const hipY = 1.18;
  // colo (sentado), tronco, gola, cordões chatos
  for (const s of [-1, 1]) { const th = bx(0.44, 0.36, 1.1, M(C.pants, 0.85)); th.position.set(s * 0.23, hipY - 0.12, 0.42); body.add(th); }
  const torso = bx(0.98, 1.02, 0.56, hood, 0.04); torso.position.y = hipY + 0.45; body.add(torso);
  const pocket = bx(0.6, 0.24, 0.04, hoodD, 0.01); pocket.position.set(0, hipY + 0.16, 0.29); body.add(pocket);
  const collar = bx(0.56, 0.12, 0.46, hoodD, 0.02); collar.position.set(0, hipY + 0.98, 0); body.add(collar);
  const hoodBack = bx(0.78, 0.3, 0.3, hoodD, 0.03); hoodBack.position.set(0, hipY + 0.95, -0.24); hoodBack.rotation.x = 0.3; body.add(hoodBack);
  for (const s of [-1, 1]) { const c = bx(0.05, 0.36, 0.02, M(C.cord, 0.7), 0.008); c.position.set(s * 0.12, hipY + 0.72, 0.29); body.add(c); }
  const neck = bx(0.26, 0.16, 0.24, skinDark, 0.02); neck.position.y = hipY + 1.04; body.add(neck);
  // fone no pescoço (em cubos): conchas dos lados do pescoço, apoiadas nos ombros; arco por trás da nuca
  const phM = M(C.phones, 0.45), padM = M(0xff6a3d, 0.6);
  for (const s of [-1, 1]) {
    const cup = new THREE.Group(); cup.position.set(s * 0.34, hipY + 0.97, 0.03); cup.rotation.z = s * 0.2; body.add(cup);
    cup.add(bx(0.13, 0.22, 0.22, phM, 0.03));
    const ring = bx(0.03, 0.14, 0.14, padM, 0.01); ring.position.x = s * 0.075; cup.add(ring);
    const arm = bx(0.05, 0.05, 0.2, phM, 0.012); arm.position.set(0, 0.06, -0.16); cup.add(arm);
  }
  const bandB = bx(0.66, 0.06, 0.06, phM, 0.015); bandB.position.set(0, hipY + 1.04, -0.28); body.add(bandB);

  // cabeça cúbica
  const head = new THREE.Group(); head.position.y = hipY + 1.62; body.add(head);
  head.add(bx(1.0, 1.06, 0.96, skin, 0.04));
  const F = 0.48;
  for (const s of [-1, 1]) { const ear = bx(0.08, 0.2, 0.16, skinDark, 0.015); ear.position.set(s * 0.52, -0.02, 0); head.add(ear); }
  // cabelo: tampa + cubos irregulares + fios espetados + franja + costeletas
  const cap = bx(1.06, 0.24, 1.02, hair, 0.03); cap.position.y = 0.5; head.add(cap);
  const backH = bx(1.04, 0.5, 0.12, hair, 0.03); backH.position.set(0, 0.3, -0.47); head.add(backH);
  for (const s of [-1, 1]) { const sb = bx(0.08, 0.36, 0.6, hair, 0.02); sb.position.set(s * 0.51, 0.3, -0.12); head.add(sb); }
  let seed = 23; const rnd = () => { seed = (seed * 16807) % 2147483647; return seed / 2147483647; };
  for (let i = 0; i < 22; i++) {
    const w = 0.22 + rnd() * 0.12, c = bx(w, 0.14 + rnd() * 0.1, w * (0.8 + rnd() * 0.4), hair, 0.02);
    c.position.set(-0.42 + rnd() * 0.84, 0.62 + rnd() * 0.08, -0.4 + rnd() * 0.8); c.rotation.set(rnd() * 0.3 - 0.15, rnd() * 0.6, rnd() * 0.3 - 0.15); head.add(c);
  }
  [[-0.18, 0.08], [0.06, -0.1], [0.24, 0.12]].forEach(([x, z]) => { const sp = bx(0.1, 0.22, 0.1, hair, 0.015); sp.position.set(x, 0.82, z); sp.rotation.z = (rnd() - 0.5) * 0.8; head.add(sp); });
  [[-0.36, 0.4, 0.2], [-0.12, 0.38, 0.24], [0.12, 0.4, 0.22], [0.35, 0.39, 0.2]].forEach(([x, y, w]) => { const f = bx(w, 0.16, 0.12, hair, 0.02); f.position.set(x, y, F + 0.02); f.rotation.z = (rnd() - 0.5) * 0.3; head.add(f); });
  // sobrancelhas em bloco grosso
  const brows = [-1, 1].map(s => { const b = new THREE.Group(); b.position.set(s * 0.22, 0.2, F + 0.02); b.add(bx(0.3, 0.085, 0.06, hair, 0.015)); head.add(b); return b; });
  // olhos quadrados: branco, pupila quadrada, brilho; pálpebra de pele para piscar; linha de olho fechado
  const lineM = M(0x2a1810, 0.6);
  const eyes = [-1, 1].map(s => {
    const g = new THREE.Group(); g.position.set(s * 0.21, -0.01, F); head.add(g);
    const w = bx(0.26, 0.25, 0.04, white, 0.02); g.add(w);
    const ir = bx(0.14, 0.16, 0.03, black, 0.01); ir.position.set(-s * 0.02, -0.01, 0.015); g.add(ir);
    const hl = bx(0.04, 0.04, 0.01, shine, 0.005); g.add(hl);
    // pálpebra de cima (desce a partir do topo) e de baixo (sobe no sorriso)
    const lidG = new RoundedBoxGeometry(0.28, 0.27, 0.03, 2, 0.012); lidG.translate(0, -0.135, 0);
    const lid = new THREE.Mesh(lidG, skin); lid.position.set(0, 0.13, 0.025); g.add(lid);
    const lowG = new RoundedBoxGeometry(0.28, 0.27, 0.03, 2, 0.012); lowG.translate(0, 0.135, 0);
    const low = new THREE.Mesh(lowG, skin); low.position.set(0, -0.13, 0.025); g.add(low);
    // olho fechado: arco tranquilo (oração) ou "^" (feliz)
    const calm = new THREE.Group(); calm.position.z = 0.03; g.add(calm);
    const c0 = bx(0.12, 0.045, 0.03, lineM, 0.01); c0.position.y = -0.05; calm.add(c0);
    for (const k of [-1, 1]) { const c = bx(0.09, 0.045, 0.03, lineM, 0.01); c.position.set(k * 0.09, -0.03, 0); c.rotation.z = k * 0.45; calm.add(c); }
    const happy = new THREE.Group(); happy.position.z = 0.03; g.add(happy);
    for (const k of [-1, 1]) { const c = bx(0.15, 0.05, 0.03, lineM, 0.01); c.position.set(k * 0.055, 0.0, 0); c.rotation.z = -k * 0.5; happy.add(c); }
    return { g, w, ir, hl, lid, low, calm, happy, s };
  });
  const nose = bx(0.12, 0.12, 0.12, skinDark, 0.02); nose.position.set(0, -0.18, F + 0.05); head.add(nose);
  // boca em blocos: barra do meio + cantos que sobem (sorriso) ou descem (tristeza); abertura com dentes
  const mouth = new THREE.Group(); mouth.position.set(0, -0.34, F); head.add(mouth);
  const lipM = M(0x5a2a20, 0.6);
  const inner = bx(0.26, 0.1, 0.03, mouthIn, 0.015); mouth.add(inner);
  const teeth = bx(0.22, 0.045, 0.02, teethM, 0.008); teeth.position.z = 0.012; mouth.add(teeth);
  const tongue = bx(0.14, 0.04, 0.02, M(0xb04450, 0.6), 0.01); tongue.position.z = 0.01; mouth.add(tongue);
  const line = bx(0.16, 0.045, 0.03, lipM, 0.01); mouth.add(line);
  const corners = [-1, 1].map(s => { const c = bx(0.08, 0.045, 0.03, lipM, 0.01); c.position.set(s * 0.11, 0, 0.002); mouth.add(c); return c; });
  const smileL = corners;
  // braços (IK) e mãos em cubo
  const arms = {};
  for (const s of [-1, 1]) {
    const upper = bx(0.27, 0.48, 0.29, hood, 0.03); body.add(upper);
    const fore = bx(0.25, 0.44, 0.27, hood, 0.03); body.add(fore);
    const cuff = bx(0.27, 0.08, 0.29, hoodD, 0.02); body.add(cuff);
    const g = new THREE.Group(); body.add(g);
    const palm = bx(0.21, 0.21, 0.11, skin, 0.025); palm.position.y = 0.1; g.add(palm);
    const fingers = new THREE.Group(); fingers.position.y = 0.21; g.add(fingers);
    const fb = bx(0.2, 0.17, 0.1, skin, 0.025); fb.position.y = 0.085; fingers.add(fb);
    const thumb = new THREE.Group(); thumb.position.set(-s * 0.11, 0.08, 0.02); thumb.rotation.z = s * 0.5; g.add(thumb);
    const tb = bx(0.07, 0.13, 0.07, skin, 0.02); tb.position.y = 0.06; thumb.add(tb);
    arms[s < 0 ? 'R' : 'L'] = { s, upper, fore, cuff, hand: { g, fingers, thumb }, sh: V(s * 0.57, hipY + 0.84, 0) };
  }
  root.traverse(o => { if (o.isMesh) { o.castShadow = true; o.receiveShadow = true; } });
  const api = { root, body, head, eyes, brows, mouth, inner, teeth, tongue, line, corners, arms, hipY };
  root.userData.api = api; root.userData.char = 1;
  setFace(api, {});
  return api;
}

export function setFingers(h, { curl = 0 } = {}) { h.fingers.rotation.x = curl * 1.3; h.thumb.rotation.x = curl * 0.6; }
const Y = V(0, 1, 0), _v = new THREE.Vector3(), _m = new THREE.Matrix4();
const placeSeg = (mesh, a, b) => { mesh.position.copy(a).add(b).multiplyScalar(0.5); _v.copy(b).sub(a).normalize(); mesh.quaternion.setFromUnitVectors(Y, _v); };
export function setArm(api, side, wrist, fingerDir, palmDir, pole = V(0, -1, -0.3)) {
  const A = api.arms[side], S = A.sh, L1 = 0.46, L2 = 0.44;
  const d = wrist.clone().sub(S); const dist = Math.min(d.length(), L1 + L2 - 1e-4); const dir = d.normalize(); const W = S.clone().addScaledVector(dir, dist);
  const a = (L1 * L1 - L2 * L2 + dist * dist) / (2 * dist), h = Math.sqrt(Math.max(0, L1 * L1 - a * a));
  const pl = pole.clone().sub(dir.clone().multiplyScalar(pole.dot(dir))).normalize(); const E = S.clone().addScaledVector(dir, a).addScaledVector(pl, h);
  placeSeg(A.upper, S, E); placeSeg(A.fore, E, W);
  const fwd = W.clone().sub(E).normalize(); A.cuff.position.copy(W).addScaledVector(fwd, -0.04); A.cuff.quaternion.setFromUnitVectors(Y, fwd);
  const fy = fingerDir.clone().normalize(), fz = palmDir.clone().sub(fy.clone().multiplyScalar(palmDir.dot(fy))).normalize(), fx = new THREE.Vector3().crossVectors(fy, fz);
  _m.makeBasis(fx, fy, fz); A.hand.g.quaternion.setFromRotationMatrix(_m); A.hand.g.position.copy(W);
}
// rosto: open 0..1, talk 0..1, smile 0..1, sad 0..1, browUp, browSad (compaixão: pontas de dentro sobem), look [x, y]
export function setFace(api, { open = 1, talk = 0, smile = 0, sad = 0, browUp = 0, browSad = 0, look = [0, 0] } = {}) {
  api.eyes.forEach(({ w, ir, hl, lid, low, calm, happy, s }) => {
    const shut = open < 0.12;
    w.visible = ir.visible = hl.visible = !shut; lid.visible = low.visible = !shut;
    calm.visible = shut && smile <= 0.5; happy.visible = shut && smile > 0.5;
    lid.scale.y = Math.max(0.001, (1 - open) * 0.95 + 0.04); low.scale.y = Math.max(0.001, 0.38 * smile + 0.03);
    ir.position.x = -s * 0.02 + look[0] * 0.04; ir.position.y = -0.01 + look[1] * 0.03;
    hl.position.set(ir.position.x + 0.035, ir.position.y + 0.045, 0.035);
  });
  api.brows.forEach((b, i) => { const s = i ? 1 : -1; b.position.y = 0.2 + 0.05 * browUp + 0.02 * browSad; b.rotation.z = -s * 0.32 * browSad + s * 0.06 + s * 0.12 * smile * (1 - browSad); });
  const t = Math.max(0, Math.min(1, talk)), open_ = t > 0.06;
  const cy = 0.04 * smile - 0.035 * sad;
  api.inner.visible = open_; api.inner.scale.set(1 + 0.25 * smile, 0.35 + 1.5 * t, 1); api.inner.position.y = -0.045 * t + 0.01 * smile;
  api.teeth.visible = open_ && t > 0.2; api.teeth.position.y = api.inner.position.y + 0.05 * api.inner.scale.y - 0.025;
  api.tongue.visible = open_ && t > 0.45; api.tongue.position.y = api.inner.position.y - 0.05 * api.inner.scale.y + 0.025;
  api.line.visible = !open_; api.line.scale.x = 1 - 0.2 * smile;
  api.corners.forEach((c, i) => { const s = i ? 1 : -1; c.visible = true;
    c.position.set(s * (open_ ? 0.16 + 0.03 * smile : 0.11 - 0.01 * smile), open_ ? cy + 0.01 : cy * 0.6, 0.004); c.rotation.z = s * (0.6 * smile - 0.5 * sad); });
}
