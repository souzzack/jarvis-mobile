// Variante voxel do personagem: cubos de quinas retas e rosto pintado em pixels (16×16).
// As expressões trocam a pintura do rosto (olhos abertos/fechados, boca falando, sorriso).
// Mesma interface do personagem3d.js: createPersonagem, setFace, setArm, setFingers.
import * as THREE from 'three';

const PAL = { skin: '#c98863', skinD: '#b0714f', hair: '#3a2418', hairL: '#55372a', white: '#d9d2c6', iris: '#5a3420', irisD: '#2a160c', blush: '#e08a7a', mouth: '#4a1418', teeth: '#f2ece2', brow: '#2a1810', hood: '#d9a23a', hoodD: '#b8852a', cord: '#f6f1e8' };
const cv = (draw) => { const c = document.createElement('canvas'); c.width = c.height = 16; const g = c.getContext('2d'); draw(g); const t = new THREE.CanvasTexture(c); t.magFilter = t.minFilter = THREE.NearestFilter; t.colorSpace = THREE.SRGBColorSpace; t.userData.g = g; return t; };
const px = (g, x, y, c, w = 1, h = 1) => { g.fillStyle = c; g.fillRect(x, y, w, h); };
const mat = (t, extra = {}) => new THREE.MeshStandardMaterial({ map: t, roughness: 0.85, ...extra });

function drawFace(g, { open = 1, talk = 0, smile = 0, browSad = 0 } = {}) {
  px(g, 0, 0, PAL.skin, 16, 16);
  px(g, 0, 0, PAL.hair, 16, 3); // a franja vem da camada de cabelo
  // sobrancelhas (inclinam na compaixão)
  const by = 6;
  px(g, 3, by, PAL.brow, 2); px(g, 5, by - (browSad > 0.5 ? 1 : 0), PAL.brow, 1);
  px(g, 11, by, PAL.brow, 2); px(g, 10, by - (browSad > 0.5 ? 1 : 0), PAL.brow, 1);
  if (open > 0.5) {
    for (const [x, m] of [[3, 1], [10, -1]]) {
      px(g, x, 7, PAL.white, 3, 2);
      const ix = m > 0 ? x + 1 : x; px(g, ix, 7, PAL.iris, 2, 2); px(g, ix + (m > 0 ? 1 : 0), 8, PAL.irisD); px(g, ix, 7, '#ffffff');
    }
  } else {
    px(g, 3, 9, PAL.brow, 3); px(g, 10, 9, PAL.brow, 3); // olhos fechados: cílios
  }
  px(g, 2, 10, PAL.blush, 2); px(g, 12, 10, PAL.blush, 2);
  px(g, 7, 10, PAL.skinD, 2); // nariz
  if (talk > 0.5) { px(g, 6, 12, PAL.mouth, 4, 2); px(g, 6, 12, PAL.teeth, 4); }
  else if (talk > 0.15) { px(g, 6, 12, PAL.mouth, 4, 2); px(g, 6, 12, PAL.teeth, 4); }
  else if (smile > 0.5) { px(g, 5, 11, PAL.mouth); px(g, 10, 11, PAL.mouth); px(g, 6, 12, PAL.mouth, 4); }
  else px(g, 6, 12, PAL.mouth, 4);
}

export function createPersonagem() {
  const root = new THREE.Group(), body = new THREE.Group(); root.add(body);
  const S = 0.25; // aresta da cabeça
  const head = new THREE.Group(); head.position.set(0, 1.565, 0); body.add(head);
  const face = cv((g) => drawFace(g, {}));
  const side = cv((g) => { px(g, 0, 0, PAL.skin, 16, 16); px(g, 0, 0, PAL.hair, 16, 6); px(g, 0, 6, PAL.hair, 5, 3); px(g, 9, 8, PAL.skinD, 2, 3); });
  const top = cv((g) => { px(g, 0, 0, PAL.hair, 16, 16); for (let i = 0; i < 12; i++) px(g, (i * 5) % 16, (i * 7) % 16, PAL.hairL, 2, 1); });
  const back = cv((g) => { px(g, 0, 0, PAL.hair, 16, 12); px(g, 0, 12, PAL.skin, 16, 4); for (let i = 0; i < 8; i++) px(g, (i * 3) % 16, (i * 5) % 10, PAL.hairL, 2, 1); });
  const sideL = side.clone(); sideL.needsUpdate = true;
  const chin = cv((g) => px(g, 0, 0, PAL.skinD, 16, 16));
  const headMesh = new THREE.Mesh(new THREE.BoxGeometry(S, S, S), [mat(side), mat(sideL), mat(top), mat(chin), mat(face), mat(back)]); // +x, -x, +y, -y, +z, -z
  head.add(headMesh);
  // camada de cabelo (um pouco maior), com a franja recortada em pixels
  const fringe = cv((g) => { g.clearRect(0, 0, 16, 16); px(g, 0, 0, PAL.hair, 16, 4); [1, 0, 1, 2, 1, 0, 2, 1, 0, 0, 0, 1, 0, 0, 1, 2].forEach((h, x) => px(g, x, 4, PAL.hair, 1, h)); px(g, 0, 4, PAL.hair, 1, 5); px(g, 15, 4, PAL.hair, 1, 5); for (let i = 0; i < 6; i++) px(g, 2 + i * 2, 1 + (i % 2), PAL.hairL, 2, 1); });
  const hairSide = cv((g) => { g.clearRect(0, 0, 16, 16); px(g, 0, 0, PAL.hair, 16, 6); px(g, 0, 6, PAL.hair, 6, 3); });
  const hairBack = cv((g) => { g.clearRect(0, 0, 16, 16); px(g, 0, 0, PAL.hair, 16, 12); });
  const hm = (t) => new THREE.MeshStandardMaterial({ map: t, transparent: true, alphaTest: 0.5, roughness: 0.8, side: THREE.DoubleSide });
  const hairLayer = new THREE.Mesh(new THREE.BoxGeometry(S * 1.1, S * 1.1, S * 1.1), [hm(hairSide), hm(hairSide.clone()), hm(top), new THREE.MeshBasicMaterial({ visible: false }), hm(fringe), hm(hairBack)]);
  hairLayer.material[1].map.needsUpdate = true; hairLayer.position.y = 0.005; head.add(hairLayer);

  // tronco: moletom com cordões e bolso pintados
  const hoodFront = cv((g) => { px(g, 0, 0, PAL.hood, 16, 16); px(g, 5, 0, PAL.hoodD, 6, 2); px(g, 6, 2, PAL.cord, 1, 5); px(g, 9, 2, PAL.cord, 1, 5); px(g, 3, 11, PAL.hoodD, 10, 4); px(g, 3, 11, PAL.hood, 10, 1); });
  const hoodPlain = cv((g) => { px(g, 0, 0, PAL.hood, 16, 16); px(g, 0, 15, PAL.hoodD, 16, 1); });
  const torso = new THREE.Mesh(new THREE.BoxGeometry(0.4, 0.5, 0.22), [mat(hoodPlain), mat(hoodPlain), mat(hoodPlain), mat(hoodPlain), mat(hoodFront), mat(hoodPlain)]); torso.position.y = 1.18; body.add(torso);
  const neck = new THREE.Mesh(new THREE.BoxGeometry(0.12, 0.05, 0.12), mat(cv((g) => px(g, 0, 0, PAL.skinD, 16, 16)))); neck.position.y = 1.43; body.add(neck);

  // braços: dois blocos (braço e antebraço) + mão em bloco
  const sleeve = mat(hoodPlain), skinM = mat(cv((g) => { px(g, 0, 0, PAL.skin, 16, 16); px(g, 0, 0, PAL.skinD, 16, 2); }));
  const arms = {};
  for (const s of [-1, 1]) {
    const upper = new THREE.Mesh(new THREE.BoxGeometry(0.1, 0.27, 0.1), sleeve); body.add(upper);
    const fore = new THREE.Mesh(new THREE.BoxGeometry(0.095, 0.24, 0.095), sleeve); body.add(fore);
    const cuff = new THREE.Mesh(new THREE.BoxGeometry(0.1, 0.03, 0.1), mat(cv((g) => px(g, 0, 0, PAL.hoodD, 16, 16)))); body.add(cuff);
    const g = new THREE.Group(); body.add(g);
    const palm = new THREE.Mesh(new THREE.BoxGeometry(0.08, 0.1, 0.04), skinM); palm.position.y = 0.05; g.add(palm);
    const fingers = new THREE.Mesh(new THREE.BoxGeometry(0.08, 0.06, 0.035), skinM); fingers.position.y = 0.13; g.add(fingers);
    const thumb = new THREE.Mesh(new THREE.BoxGeometry(0.03, 0.06, 0.03), skinM); thumb.position.set(-s * 0.05, 0.05, 0.01); g.add(thumb);
    arms[s < 0 ? 'R' : 'L'] = { s, upper, fore, cuff, hand: { g, fingers, thumb }, sh: new THREE.Vector3(s * 0.25, 1.36, 0) };
  }
  root.traverse(o => { if (o.isMesh) { o.castShadow = true; o.receiveShadow = true; } });
  const api = { root, body, head, face, arms, H: head };
  root.userData.api = api; root.userData.char = 1;
  return api;
}
export function setFace(api, f = {}) { drawFace(api.face.userData.g, f); api.face.needsUpdate = true; }
export function setFingers(h, { curl = 0 } = {}) { h.fingers.rotation.x = curl * 1.2; h.fingers.position.z = curl * 0.03; }
const Y = new THREE.Vector3(0, 1, 0), _v = new THREE.Vector3(), _m = new THREE.Matrix4();
const placeSeg = (mesh, a, b) => { mesh.position.copy(a).add(b).multiplyScalar(0.5); _v.copy(b).sub(a).normalize(); mesh.quaternion.setFromUnitVectors(Y, _v); };
export function setArm(api, side, wrist, fingerDir, palmDir, pole = new THREE.Vector3(0, -1, -0.3)) {
  const A = api.arms[side], S = A.sh, L1 = 0.27, L2 = 0.24;
  const d = wrist.clone().sub(S); const dist = Math.min(d.length(), L1 + L2 - 1e-4); const dir = d.normalize(); const W = S.clone().addScaledVector(dir, dist);
  const a = (L1 * L1 - L2 * L2 + dist * dist) / (2 * dist), h = Math.sqrt(Math.max(0, L1 * L1 - a * a));
  const pl = pole.clone().sub(dir.clone().multiplyScalar(pole.dot(dir))).normalize(); const E = S.clone().addScaledVector(dir, a).addScaledVector(pl, h);
  placeSeg(A.upper, S, E); placeSeg(A.fore, E, W);
  const fwd = W.clone().sub(E).normalize(); A.cuff.position.copy(W).addScaledVector(fwd, -0.015); A.cuff.quaternion.setFromUnitVectors(Y, fwd);
  const fy = fingerDir.clone().normalize(), fz = palmDir.clone().sub(fy.clone().multiplyScalar(palmDir.dot(fy))).normalize(), fx = new THREE.Vector3().crossVectors(fy, fz);
  _m.makeBasis(fx, fy, fz); A.hand.g.quaternion.setFromRotationMatrix(_m); A.hand.g.position.copy(W);
}
