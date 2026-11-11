// Gael (nome provisório), 17 anos: personagem da série de orações no estilo de blocos arredondados do Davi.
// Diferenças em relação ao Davi: adolescente mais velho (cabeça menor, corpo mais comprido), moletom com capuz e
// cordões, fone grande no pescoço, cabelo ondulado jogado para o lado com degradê, risquinho na sobrancelha.
// Braços montados por IK (punho no lugar desejado), para orar, levantar a mão e apontar no plano de selfie.
import * as THREE from 'three';
import { RoundedBoxGeometry } from 'three/addons/geometries/RoundedBoxGeometry.js';

const rb = (w, h, d, r, m, seg = 4) => new THREE.Mesh(new RoundedBoxGeometry(w, h, d, seg, r), m);
const V = (x, y, z) => new THREE.Vector3(x, y, z);

export const CORES = {
  skin: 0xb97a52, skinDark: 0x9e6442, hair: 0x15100d, fade: 0x6e4a36,
  hoodie: 0x3f6f8f, hoodieDark: 0x325a75, pants: 0x2b2f3a, cord: 0xf4efe6,
  phones: 0x1a1a1e, accent: 0xff6a3d,
};

export function createPersonagem(opts = {}) {
  const C = { ...CORES, ...opts };
  const skin = new THREE.MeshPhysicalMaterial({ color: C.skin, roughness: 0.55, sheen: 0.3, sheenColor: new THREE.Color(0xffc9a0) });
  const skinDark = skin.clone(); skinDark.color.set(C.skinDark);
  const hair = new THREE.MeshStandardMaterial({ color: C.hair, roughness: 0.7 });
  const fade = new THREE.MeshStandardMaterial({ color: C.fade, roughness: 0.95 });
  const hood = new THREE.MeshStandardMaterial({ color: C.hoodie, roughness: 0.9 });
  const hoodD = hood.clone(); hoodD.color.set(C.hoodieDark);
  const white = new THREE.MeshStandardMaterial({ color: 0xe2dbd0, roughness: 0.45 });
  const iris = new THREE.MeshPhysicalMaterial({ color: 0x2a1a10, roughness: 0.1, clearcoat: 1 });
  const shine = new THREE.MeshBasicMaterial({ color: 0xffffff });
  const lip = new THREE.MeshStandardMaterial({ color: 0x8a4e3c, roughness: 0.6 });
  const mouthIn = new THREE.MeshStandardMaterial({ color: 0x3a1512, roughness: 0.8 });
  const teethM = new THREE.MeshStandardMaterial({ color: 0xf2ece2, roughness: 0.5 });
  const dark = new THREE.MeshStandardMaterial({ color: 0x1a0f0b, roughness: 0.6 });

  const root = new THREE.Group(), body = new THREE.Group(); root.add(body);
  const hipY = 1.18;

  // tronco: moletom com bolso, capuz caído nas costas, cordões
  const torso = rb(0.92, 1.0, 0.52, 0.14, hood); torso.position.y = hipY + 0.45; body.add(torso);
  const band = rb(0.94, 0.1, 0.54, 0.04, hoodD); band.position.y = hipY - 0.03; body.add(band);
  const pocket = rb(0.58, 0.26, 0.04, 0.04, hoodD); pocket.position.set(0, hipY + 0.17, 0.26); body.add(pocket);
  const hoodBack = rb(0.74, 0.32, 0.3, 0.13, hoodD); hoodBack.position.set(0, hipY + 0.96, -0.22); hoodBack.rotation.x = 0.35; body.add(hoodBack);
  const collar = rb(0.5, 0.1, 0.42, 0.05, hoodD); collar.position.set(0, hipY + 0.97, 0.0); body.add(collar);
  for (const s of [-1, 1]) {
    const cord = rb(0.035, 0.3, 0.035, 0.015, new THREE.MeshStandardMaterial({ color: C.cord, roughness: 0.7 })); cord.position.set(s * 0.1, hipY + 0.78, 0.27); body.add(cord);
    const tip = rb(0.045, 0.06, 0.045, 0.015, new THREE.MeshStandardMaterial({ color: 0x8a8a8a, metalness: 0.6, roughness: 0.3 })); tip.position.set(s * 0.1, hipY + 0.6, 0.27); body.add(tip);
  }
  // colo: sentado na cama, coxas para a frente
  const pantsM = new THREE.MeshStandardMaterial({ color: C.pants, roughness: 0.85 });
  for (const s of [-1, 1]) { const th = rb(0.42, 0.36, 1.1, 0.1, pantsM); th.position.set(s * 0.23, hipY - 0.12, 0.42); body.add(th); }
  const neck = rb(0.24, 0.18, 0.22, 0.05, skin); neck.position.y = hipY + 1.02; body.add(neck);
  // fone grande no pescoço (arco para trás, conchas nos ombros)
  const phonesM = new THREE.MeshStandardMaterial({ color: C.phones, roughness: 0.4, metalness: 0.2 }), accent = new THREE.MeshStandardMaterial({ color: C.accent, roughness: 0.5 });
  const phones = new THREE.Group(); phones.position.set(0, hipY + 0.98, 0.1); phones.rotation.x = -Math.PI / 2 + 0.55; body.add(phones);
  phones.add(new THREE.Mesh(new THREE.TorusGeometry(0.36, 0.035, 10, 32, Math.PI), phonesM));
  for (const s of [-1, 1]) { const cup = rb(0.12, 0.26, 0.26, 0.06, phonesM); cup.position.x = s * 0.37; phones.add(cup); const ring = rb(0.02, 0.17, 0.17, 0.01, accent); ring.position.x = s * 0.44; phones.add(ring); }

  // cabeça (menor e mais alta que a do Davi, queixo marcado)
  const head = new THREE.Group(); head.position.y = hipY + 1.6; body.add(head);
  head.add(rb(0.96, 1.04, 0.92, 0.15, skin, 5));
  const jaw = rb(0.8, 0.2, 0.84, 0.08, skin); jaw.position.y = -0.47; head.add(jaw);
  const F = 0.46;
  for (const s of [-1, 1]) { const ear = rb(0.1, 0.22, 0.16, 0.04, skinDark); ear.position.set(s * 0.5, -0.02, 0); head.add(ear); }
  // cabelo: degradê baixo + topo ondulado tombado para a direita
  for (const s of [-1, 1]) { const f = rb(0.02, 0.2, 0.6, 0.01, fade); f.position.set(s * 0.485, 0.39, -0.07); head.add(f); }
  const back = rb(0.8, 0.22, 0.02, 0.01, fade); back.position.set(0, 0.39, -0.465); head.add(back);
  const cap = rb(0.9, 0.16, 0.86, 0.07, hair); cap.position.y = 0.52; head.add(cap);
  let seed = 11; const rnd = () => { seed = (seed * 16807) % 2147483647; return seed / 2147483647; };
  for (let row = 0; row < 4; row++) for (let i = 0; i < 5; i++) {
    const w = rb(0.24 + rnd() * 0.06, 0.12 + rnd() * 0.05, 0.24, 0.05, hair);
    w.position.set(-0.36 + i * 0.18 + (row % 2) * 0.05, 0.62 + rnd() * 0.05 - row * 0.012, 0.32 - row * 0.21);
    w.rotation.set(rnd() * 0.2 - 0.1, rnd() * 0.4 - 0.2, -0.28 - rnd() * 0.15); head.add(w);
  }
  const fringe = rb(0.5, 0.14, 0.16, 0.06, hair); fringe.position.set(0.12, 0.52, F - 0.02); fringe.rotation.z = -0.32; head.add(fringe);
  // sobrancelhas (a esquerda tem o risquinho)
  const brows = [-1, 1].map(s => {
    const b = new THREE.Group(); b.position.set(s * 0.21, 0.2, F + 0.01);
    if (s > 0) b.add(rb(0.25, 0.07, 0.05, 0.03, hair));
    else { const a = rb(0.12, 0.07, 0.05, 0.03, hair); a.position.x = -0.07; const c = rb(0.09, 0.07, 0.05, 0.03, hair); c.position.x = 0.085; b.add(a, c); }
    head.add(b); return b;
  });
  // olhos: branco, íris, brilho, pálpebra (cor de pele) e linha de olho fechado
  const eyes = [-1, 1].map(s => {
    const g = new THREE.Group(); g.position.set(s * 0.21, 0.01, F + 0.005); head.add(g);
    const w = rb(0.25, 0.19, 0.04, 0.06, white); g.add(w);
    const ir = rb(0.15, 0.17, 0.03, 0.05, iris); ir.position.set(-s * 0.012, -0.01, 0.02); g.add(ir);
    const hl = rb(0.045, 0.045, 0.01, 0.012, shine); hl.position.set(-s * 0.012 + 0.025, 0.02, 0.04); g.add(hl);
    const lid = rb(0.27, 0.06, 0.03, 0.025, skin); lid.position.set(0, 0.08, 0.02); g.add(lid);
    const closed = rb(0.24, 0.035, 0.03, 0.015, dark); closed.position.set(0, -0.01, 0.03); closed.visible = false; g.add(closed);
    return { g, w, ir, hl, lid, closed };
  });
  const nose = rb(0.12, 0.17, 0.09, 0.04, skinDark); nose.position.set(0, -0.12, F + 0.035); head.add(nose);
  const mouth = new THREE.Group(); mouth.position.set(0, -0.31, F + 0.005); head.add(mouth);
  const inner = rb(0.2, 0.1, 0.02, 0.03, mouthIn); mouth.add(inner);
  const teeth = rb(0.16, 0.03, 0.025, 0.01, teethM); teeth.position.y = 0.03; mouth.add(teeth);
  const lips = rb(0.22, 0.045, 0.03, 0.02, lip); lips.position.y = -0.045; mouth.add(lips);
  const smile = new THREE.Mesh(new THREE.TorusGeometry(0.1, 0.022, 10, 28, Math.PI * 0.62), new THREE.MeshStandardMaterial({ color: 0x5a2a20, roughness: 0.6 }));
  smile.rotation.z = Math.PI + Math.PI * 0.19; smile.position.set(0, 0.04, 0.01); smile.visible = false; mouth.add(smile);

  // braços (IK) e mãos em bloco
  const arms = {};
  for (const s of [-1, 1]) {
    const upper = rb(0.26, 0.48, 0.28, 0.09, hood); body.add(upper);
    const fore = rb(0.23, 0.44, 0.25, 0.08, hood); body.add(fore);
    const cuff = rb(0.25, 0.08, 0.27, 0.03, hoodD); body.add(cuff);
    const g = new THREE.Group(); body.add(g);
    const palm = rb(0.2, 0.2, 0.1, 0.05, skin); palm.position.y = 0.1; g.add(palm);
    const fingers = new THREE.Group(); fingers.position.y = 0.2; g.add(fingers);
    const fb = rb(0.19, 0.17, 0.09, 0.045, skin); fb.position.y = 0.085; fingers.add(fb);
    const thumb = new THREE.Group(); thumb.position.set(-s * 0.1, 0.08, 0.02); g.add(thumb);
    const tb = rb(0.07, 0.13, 0.07, 0.03, skin); tb.position.y = 0.06; thumb.add(tb); thumb.rotation.z = s * 0.5;
    arms[s < 0 ? 'R' : 'L'] = { s, upper, fore, cuff, hand: { g, fingers, thumb }, sh: V(s * 0.55, hipY + 0.84, 0) };
  }
  root.traverse(o => { if (o.isMesh) { o.castShadow = true; o.receiveShadow = true; } });
  const api = { root, body, head, eyes, brows, mouth, inner, teeth, lips, smile, arms, hipY };
  root.userData.api = api; root.userData.char = 1;
  setFace(api, {});
  return api;
}

export function setFingers(h, { curl = 0, point = false } = {}) { h.fingers.rotation.x = curl * 1.3; h.thumb.rotation.x = curl * 0.6; }
const Y = V(0, 1, 0), _v = new THREE.Vector3(), _m = new THREE.Matrix4();
const placeSeg = (mesh, a, b) => { mesh.position.copy(a).add(b).multiplyScalar(0.5); _v.copy(b).sub(a).normalize(); mesh.quaternion.setFromUnitVectors(Y, _v); };
// punho em "wrist" (coordenadas do corpo), dedos para fingerDir, palma para palmDir, cotovelo para o lado de "pole"
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
// rosto: open 0..1, talk 0..1, smile 0..1, browUp, browSad, look [x, y]
export function setFace(api, { open = 1, talk = 0, smile = 0, browUp = 0, browSad = 0, look = [0, 0] } = {}) {
  api.eyes.forEach(({ g, w, ir, hl, lid, closed }, i) => {
    const shut = open < 0.15; w.visible = ir.visible = !shut; hl.visible = !shut && open > 0.5; lid.visible = !shut; closed.visible = shut;
    lid.position.y = 0.08 - 0.09 * (1 - open);
    ir.position.x = (i ? -1 : 1) * 0.012 + look[0] * 0.035; ir.position.y = -0.01 + look[1] * 0.025;
    hl.position.set(ir.position.x + 0.025, ir.position.y + 0.03, 0.04);
  });
  api.brows.forEach((b, i) => { const s = i ? 1 : -1; b.position.y = 0.2 + 0.05 * browUp; b.rotation.z = -s * 0.25 * browSad; });
  const t = Math.max(0, Math.min(1, talk)), sm = t < 0.06 && smile > 0.5;
  api.smile.visible = sm; api.inner.visible = !sm; api.lips.visible = !sm;
  api.inner.scale.y = 0.2 + 1.4 * t; api.inner.position.y = -0.01 - 0.035 * t; api.teeth.visible = !sm && t > 0.25;
}
