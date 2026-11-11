// Personagem da série de orações: 3D estilo filme de animação (cabeça esculpida numa malha lisa,
// olhos com íris/córnea e pálpebras, mechas de cabelo esculpidas, moletom com brilho de tecido).
// Diferente do Davi (blocos): aqui tudo é orgânico e liso. Escala em metros; ele olha para +z.
import * as THREE from 'three';

const ss = (a, b, x) => { const t = Math.min(1, Math.max(0, (x - a) / (b - a))); return t * t * (3 - 2 * t); };
const gauss = (p, c, s) => Math.exp(-p.distanceToSquared(c) / (2 * s * s));
const V = (x, y, z) => new THREE.Vector3(x, y, z);
let seed = 7; const rnd = () => { seed = (seed * 16807) % 2147483647; return seed / 2147483647; };

export const CORES = { skin: 0xc98863, hair: 0x2a1b15, hoodie: 0xd9a23a, iris: [0x2a160c, 0x6b3d1e, 0xb07a3c] };

// ---------- cabeça esculpida (unidades da cabeça: raio ≈ 1)
function headSurface(p) {
  const n = p.clone().normalize(); let x = n.x * 0.9, y = n.y * 1.06, z = n.z * 0.95;
  const j = ss(-0.25, -0.95, n.y); x *= (1 - 0.16 * j) * (1 + 0.04 * Math.exp(-((n.y + 0.3) ** 2) / 0.05)); z *= 1 - 0.08 * j;
  if (n.y < 0) y *= 1 - 0.1 * ss(0, -1, n.y);
  z += 0.07 * ss(-0.55, -1, n.y) * Math.max(0, n.z);
  if (n.z < 0) { z *= 1.07; y += 0.03 * -n.z; }
  let d = 0;
  for (const s of [-1, 1]) {
    d += 0.09 * gauss(n, V(s * 0.55, -0.32, 0.72), 0.25);   // bochechas
    d -= 0.09 * gauss(n, V(s * 0.35, 0.05, 0.92), 0.16);    // cavidade dos olhos
    d += 0.03 * gauss(n, V(s * 0.36, 0.3, 0.88), 0.13);     // arco das sobrancelhas
    d -= 0.03 * gauss(n, V(s * 0.85, 0.25, 0.35), 0.2);     // têmporas
  }
  d -= 0.02 * gauss(n, V(0, -0.62, 0.78), 0.12);            // vinco acima do queixo
  const r = V(x, y, z); return r.addScaledVector(n, d);
}
function sculptSphere(radius = 1, wS = 160, hS = 120, f = headSurface, k = 1) {
  const g = new THREE.SphereGeometry(radius, wS, hS); const pos = g.attributes.position, v = new THREE.Vector3();
  for (let i = 0; i < pos.count; i++) { v.fromBufferAttribute(pos, i); const s = f(v).multiplyScalar(k); pos.setXYZ(i, s.x, s.y, s.z); }
  g.computeVertexNormals(); return g;
}
const hairlineY = (n) => { // acima disso é cabelo
  const front = Math.max(0, n.z), side = Math.abs(n.x);
  return n.z > 0 ? 0.48 - 0.42 * side * side - 0.05 * Math.sin(n.x * 9) : 0.05 - 0.55 * -n.z;
};

export function createPersonagem(opts = {}) {
  const C = { ...CORES, ...opts };
  const skin = new THREE.MeshPhysicalMaterial({ color: C.skin, roughness: 0.52, sheen: 0.5, sheenRoughness: 0.5, sheenColor: new THREE.Color(0xff9a7a), clearcoat: 0.08, clearcoatRoughness: 0.6 });
  const skinDark = skin.clone(); skinDark.color.set(new THREE.Color(C.skin).multiplyScalar(0.78));
  const hairM = new THREE.MeshPhysicalMaterial({ color: C.hair, roughness: 0.42, sheen: 0.6, sheenColor: new THREE.Color(0x7a5a48), clearcoat: 0.25, clearcoatRoughness: 0.4 });
  const cloth = new THREE.MeshPhysicalMaterial({ color: C.hoodie, roughness: 0.9, sheen: 1, sheenRoughness: 0.8, sheenColor: new THREE.Color(0xffe2a8) });
  const clothDark = cloth.clone(); clothDark.color.set(new THREE.Color(C.hoodie).multiplyScalar(0.78));

  const root = new THREE.Group(), body = new THREE.Group(); root.add(body);
  const head = new THREE.Group(); head.position.set(0, 1.548, 0.0); body.add(head);
  const H = new THREE.Group(); H.scale.setScalar(0.128); head.add(H); // tudo da cabeça em unidades ~1

  const skull = new THREE.Mesh(sculptSphere(), skin); H.add(skull);
  // projeta um ponto (x, y) da frente do rosto na superfície (unidades da cabeça)
  const ray = new THREE.Raycaster(); skull.updateMatrixWorld(true);
  const onFace = (x, y, out = 0) => { ray.set(V(x, y, 3), V(0, 0, -1)); const h = ray.intersectObject(skull)[0]; const p = h.point.clone(); p.addScaledVector(h.face.normal, out); p.n = h.face.normal.clone(); return p; };

  // nariz e asas
  const nose = new THREE.Mesh(new THREE.SphereGeometry(0.13, 32, 24), skin); nose.scale.set(0.9, 0.78, 0.75); nose.position.copy(onFace(0, -0.2, -0.06)); H.add(nose);
  const bridge = new THREE.Mesh(new THREE.CapsuleGeometry(0.055, 0.16, 8, 16), skin); bridge.position.copy(onFace(0, -0.05, -0.06)); bridge.rotation.x = -0.25; H.add(bridge);
  for (const s of [-1, 1]) { const w = new THREE.Mesh(new THREE.SphereGeometry(0.055, 24, 16), skin); w.position.copy(onFace(s * 0.085, -0.25, -0.05)); H.add(w); }
  // orelhas
  for (const s of [-1, 1]) {
    const e = new THREE.Mesh(new THREE.SphereGeometry(0.2, 32, 24), skin); e.scale.set(0.4, 1, 0.7); e.position.set(s * 0.86, -0.02, -0.05); e.rotation.y = s * 0.3; H.add(e);
    const ein = new THREE.Mesh(new THREE.SphereGeometry(0.12, 24, 16), skinDark); ein.scale.set(0.3, 0.9, 0.6); ein.position.set(s * 0.93, -0.02, 0.0); ein.rotation.y = s * 0.3; H.add(ein);
  }

  // olhos: globo, íris em calota com cores por vértice, córnea brilhante, pálpebras que fecham
  const eyes = [];
  const eyeR = 0.215;
  const irisGeo = (() => {
    const g = new THREE.SphereGeometry(eyeR * 1.003, 48, 24, 0, Math.PI * 2, 0, 0.62); g.rotateX(Math.PI / 2);
    const pos = g.attributes.position, col = [], c = new THREE.Color(), v = new THREE.Vector3();
    const [c0, c1, c2] = C.iris.map(h => new THREE.Color(h));
    for (let i = 0; i < pos.count; i++) {
      v.fromBufferAttribute(pos, i).normalize(); const a = Math.acos(Math.min(1, v.z)), ang = Math.atan2(v.y, v.x);
      if (a < 0.24) c.set(0x0b0604); else if (a > 0.56) c.set(0x1a0d06);
      else { const t = (a - 0.24) / 0.32; c.copy(c1).lerp(c2, Math.max(0, Math.sin(ang * 3) * 0.15) + 0.6 * (1 - Math.abs(t - 0.55) * 1.6)); if (v.y > 0.1) c.lerp(c0, 0.35); }
      col.push(c.r, c.g, c.b);
    }
    g.setAttribute('color', new THREE.Float32BufferAttribute(col, 3)); return g;
  })();
  for (const s of [-1, 1]) {
    const sp = onFace(s * 0.345, 0.04); const g = new THREE.Group(); g.position.set(sp.x, sp.y, sp.z - 0.178); g.rotation.y = s * 0.12; H.add(g);
    const ball = new THREE.Group(); g.add(ball);
    ball.add(new THREE.Mesh(new THREE.SphereGeometry(eyeR, 48, 32), new THREE.MeshPhysicalMaterial({ color: 0xf6f1ea, roughness: 0.25 })));
    ball.add(new THREE.Mesh(irisGeo, new THREE.MeshPhysicalMaterial({ vertexColors: true, roughness: 0.3 })));
    ball.add(new THREE.Mesh(new THREE.SphereGeometry(eyeR * 1.03, 48, 32), new THREE.MeshPhysicalMaterial({ color: 0xffffff, roughness: 0.02, transmission: 1, thickness: 0.05, transparent: true, opacity: 0.12, clearcoat: 1 })));
    const shine = new THREE.Mesh(new THREE.SphereGeometry(0.028, 16, 12), new THREE.MeshBasicMaterial({ color: 0xffffff })); shine.position.set(0.05, 0.06, eyeR * 0.97); g.add(shine);
    // pálpebras (cascas de esfera) + cílios
    const lidUp = new THREE.Group(); g.add(lidUp);
    const th = 1.0;
    lidUp.add(new THREE.Mesh(new THREE.SphereGeometry(eyeR * 1.02, 48, 24, 0, Math.PI * 2, 0, th), skin));
    const lash = new THREE.Mesh(new THREE.TorusGeometry(eyeR * 1.02 * Math.sin(th), 0.026, 8, 32, Math.PI), new THREE.MeshStandardMaterial({ color: 0x1a0f0b, roughness: 0.6 }));
    lash.rotation.x = Math.PI / 2; lash.position.y = eyeR * 1.06 * Math.cos(th); lash.scale.set(1.09, 1.09, 1); lidUp.add(lash);
    const lidLow = new THREE.Group(); g.add(lidLow);
    lidLow.add(new THREE.Mesh(new THREE.SphereGeometry(eyeR * 1.015, 48, 24, 0, Math.PI * 2, Math.PI - 0.85, 0.85), skin));
    eyes.push({ g, ball, lidUp, lidLow, shine, s });
  }
  // sobrancelhas (tubos sobre a pele)
  const browM = new THREE.MeshStandardMaterial({ color: 0x3a2418, roughness: 0.7 });
  const brows = [-1, 1].map(s => {
    const pts = [onFace(s * 0.16, 0.36, 0.015), onFace(s * 0.33, 0.4, 0.015), onFace(s * 0.5, 0.33, 0.015)];
    const grp = new THREE.Group(); const mid = pts[1].clone(); grp.position.copy(mid); H.add(grp);
    const curve = new THREE.CatmullRomCurve3(pts.map(p => p.clone().sub(mid)));
    const tube = new THREE.Mesh(new THREE.TubeGeometry(curve, 24, 0.03, 10, false), browM); tube.scale.set(1, 1, 1); grp.add(tube);
    return grp;
  });
  // boca: cavidade escura que abre + dentes; linha de sorriso quando fechada
  const mp = onFace(0, -0.5);
  const mouth = new THREE.Group(); mouth.position.copy(mp); mouth.lookAt(mp.clone().add(mp.n)); H.add(mouth);
  const cav = new THREE.Mesh(new THREE.SphereGeometry(0.15, 32, 20), new THREE.MeshStandardMaterial({ color: 0x2a0c10, roughness: 0.95 })); cav.position.z = -0.02; mouth.add(cav);
  const teeth = new THREE.Mesh(new THREE.SphereGeometry(0.12, 24, 12), new THREE.MeshStandardMaterial({ color: 0xd8cfc0, roughness: 0.5 })); teeth.scale.set(0.9, 0.28, 0.4); mouth.add(teeth);
  const tongue = new THREE.Mesh(new THREE.SphereGeometry(0.1, 24, 12), new THREE.MeshStandardMaterial({ color: 0xc04a55, roughness: 0.6 })); tongue.scale.set(1, 0.4, 0.6); mouth.add(tongue);
  const lipM = new THREE.MeshPhysicalMaterial({ color: 0xb06a58, roughness: 0.45, clearcoat: 0.2 });
  const smileLine = new THREE.Mesh(new THREE.TubeGeometry(new THREE.QuadraticBezierCurve3(V(-0.16, 0.02, 0), V(0, -0.05, 0.02), V(0.16, 0.02, 0)), 20, 0.018, 8, false), lipM); mouth.add(smileLine);
  const lowerLip = new THREE.Mesh(new THREE.SphereGeometry(0.1, 24, 12), skin); lowerLip.scale.set(1.1, 0.35, 0.5); lowerLip.visible = false; mouth.add(lowerLip);

  // cabelo: uma malha esculpida só (volume no topo, topete, sulcos seguindo o fluxo das mechas, franja com pontas)
  const crown = V(-0.25, 0.75, -0.6).normalize(), e1 = new THREE.Vector3().crossVectors(crown, V(1, 0, 0)).normalize(), e2 = new THREE.Vector3().crossVectors(crown, e1);
  const hairEdge = (n) => n.z > 0
    ? 0.5 + 0.07 * Math.abs(Math.sin(n.x * 7.5 + 0.6)) - 0.5 * n.x * n.x - 0.12 * Math.max(0, n.x) // franja com pontas, mais alta à direita
    : 0.12 - 0.62 * -n.z;
  const hairGeo = sculptSphere(1, 300, 220, (v) => {
    const n = v.clone().normalize(), base = headSurface(v), hl = hairEdge(n);
    const m = ss(hl - 0.04, hl + 0.06, n.y);
    const u = Math.atan2(n.dot(e2), n.dot(e1));
    const groove = Math.pow(Math.abs(Math.sin(u * 6.5 + n.y * 2)), 0.6);
    const vol = 0.03 + 0.13 * ss(hl, hl + 0.55, n.y) + 0.08 * gauss(n, V(0.2, 0.72, 0.6), 0.3);
    return base.multiplyScalar(0.965 + m * (0.035 + vol * (0.82 + 0.18 * groove)));
  });
  H.add(new THREE.Mesh(hairGeo, hairM));

  // ---------- pescoço e moletom
  const neck = new THREE.Mesh(new THREE.CylinderGeometry(0.045, 0.05, 0.12, 32), skin); neck.position.y = 1.44; body.add(neck);
  const prof = [[0.0, 0.7], [0.19, 0.72], [0.215, 0.85], [0.22, 1.05], [0.215, 1.2], [0.2, 1.3], [0.17, 1.37], [0.11, 1.415], [0.06, 1.43], [0.0, 1.43]].map(([r, y]) => new THREE.Vector2(r, y));
  const torsoG = new THREE.LatheGeometry(prof, 64); torsoG.scale(1.08, 1, 0.68); torsoG.computeVertexNormals();
  const torso = new THREE.Mesh(torsoG, cloth); body.add(torso);
  const hood = new THREE.Mesh(new THREE.TorusGeometry(0.062, 0.012, 16, 48), clothDark); hood.rotation.x = Math.PI / 2; hood.position.set(0, 1.425, 0); body.add(hood);
  const cordM = new THREE.MeshPhysicalMaterial({ color: 0xf6f1e8, roughness: 0.7, sheen: 1 });
  for (const s of [-1, 1]) { const c = new THREE.Mesh(new THREE.TubeGeometry(new THREE.QuadraticBezierCurve3(V(s * 0.045, 1.4, 0.12), V(s * 0.05, 1.32, 0.16), V(s * 0.055, 1.22, 0.165)), 16, 0.0065, 8), cordM); body.add(c);
    const tip = new THREE.Mesh(new THREE.CylinderGeometry(0.009, 0.009, 0.03, 12), new THREE.MeshStandardMaterial({ color: 0x9a9a9a, metalness: 0.7, roughness: 0.3 })); tip.position.set(s * 0.055, 1.2, 0.165); body.add(tip); }
  // fone no pescoço
  const phM = new THREE.MeshPhysicalMaterial({ color: 0x18181c, roughness: 0.35, clearcoat: 0.6 }), padM = new THREE.MeshPhysicalMaterial({ color: 0xf2efe8, roughness: 0.8, sheen: 0.6 });
  const phones = new THREE.Group(); phones.position.set(0, 1.4, 0.05); phones.rotation.x = -Math.PI / 2 + 0.6; // fone removido da silhueta
  phones.add(new THREE.Mesh(new THREE.TorusGeometry(0.12, 0.011, 12, 48, Math.PI), phM));
  for (const s of [-1, 1]) { const cup = new THREE.Mesh(new THREE.CylinderGeometry(0.038, 0.038, 0.03, 32), phM); cup.rotation.z = Math.PI / 2; cup.position.x = s * 0.122; phones.add(cup);
    const pad = new THREE.Mesh(new THREE.TorusGeometry(0.028, 0.009, 12, 32), padM); pad.rotation.y = Math.PI / 2; pad.position.x = s * 0.105; phones.add(pad); }

  // ---------- braços (IK) e mãos
  const arms = {};
  for (const s of [-1, 1]) {
    const upper = new THREE.Mesh(new THREE.CapsuleGeometry(0.046, 0.2, 12, 24), cloth); body.add(upper);
    const fore = new THREE.Mesh(new THREE.CapsuleGeometry(0.041, 0.17, 12, 24), cloth); body.add(fore);
    const cuff = new THREE.Mesh(new THREE.TorusGeometry(0.04, 0.012, 12, 32), clothDark); body.add(cuff);
    const hand = makeHand(skin, s); body.add(hand.g);
    arms[s < 0 ? 'R' : 'L'] = { s, upper, fore, cuff, hand, sh: V(s * 0.18, 1.34, -0.01) };
  }

  root.traverse(o => { if (o.isMesh) { o.castShadow = true; o.receiveShadow = true; } });
  const api = { root, body, head, H, eyes, brows, mouth, cav, teeth, tongue, smileLine, lowerLip, arms };
  root.userData.api = api; root.userData.char = 1;
  setFace(api, {});
  return api;
}

function makeHand(skin, s) {
  const g = new THREE.Group();
  const palmG = new THREE.SphereGeometry(1, 32, 24); palmG.scale(0.042, 0.05, 0.02); palmG.translate(0, 0.045, 0);
  g.add(new THREE.Mesh(palmG, skin));
  const fingers = [];
  [0.04, 0.046, 0.044, 0.036].forEach((len, i) => {
    const base = new THREE.Group(); base.position.set((i - 1.5) * 0.02, 0.09, 0); g.add(base);
    const a = new THREE.Mesh(new THREE.CapsuleGeometry(0.0098, len * 0.55, 8, 16), skin); a.position.y = len * 0.28; base.add(a);
    const mid = new THREE.Group(); mid.position.y = len * 0.55; base.add(mid);
    const b = new THREE.Mesh(new THREE.CapsuleGeometry(0.0092, len * 0.45, 8, 16), skin); b.position.y = len * 0.25; mid.add(b);
    fingers.push({ base, mid });
  });
  const thumb = new THREE.Group(); thumb.position.set(-s * 0.035, 0.035, 0.008); thumb.rotation.z = s * 0.8; g.add(thumb);
  const t1 = new THREE.Mesh(new THREE.CapsuleGeometry(0.012, 0.03, 8, 16), skin); t1.position.y = 0.02; thumb.add(t1);
  return { g, fingers, thumb };
}
export function setFingers(h, { curl = 0, spread = 0.1, point = false } = {}) {
  h.fingers.forEach((f, i) => { const c = point && i === 1 ? 0 : curl; f.base.rotation.set(c * 1.3, 0, (i - 1.5) * -spread); f.mid.rotation.x = c * 1.4; });
  h.thumb.children[0].rotation.x = curl * 0.7;
}
const Y = V(0, 1, 0), _v = new THREE.Vector3(), _m = new THREE.Matrix4();
const placeSeg = (mesh, a, b) => { mesh.position.copy(a).add(b).multiplyScalar(0.5); _v.copy(b).sub(a).normalize(); mesh.quaternion.setFromUnitVectors(Y, _v); };
export function setArm(api, side, wrist, fingerDir, palmDir, pole = V(0, -1, -0.3)) {
  const A = api.arms[side], S = A.sh, L1 = 0.27, L2 = 0.24;
  const d = wrist.clone().sub(S); const dist = Math.min(d.length(), L1 + L2 - 1e-4); const dir = d.normalize();
  const W = S.clone().addScaledVector(dir, dist);
  const a = (L1 * L1 - L2 * L2 + dist * dist) / (2 * dist), h = Math.sqrt(Math.max(0, L1 * L1 - a * a));
  const pl = pole.clone().sub(dir.clone().multiplyScalar(pole.dot(dir))).normalize();
  const E = S.clone().addScaledVector(dir, a).addScaledVector(pl, h);
  placeSeg(A.upper, S, E); placeSeg(A.fore, E, W);
  const fwd = W.clone().sub(E).normalize(); A.cuff.position.copy(W).addScaledVector(fwd, -0.015); A.cuff.quaternion.setFromUnitVectors(V(0, 0, 1), fwd);
  const fy = fingerDir.clone().normalize(), fz = palmDir.clone().sub(fy.clone().multiplyScalar(palmDir.dot(fy))).normalize(), fx = new THREE.Vector3().crossVectors(fy, fz);
  _m.makeBasis(fx, fy, fz); A.hand.g.quaternion.setFromRotationMatrix(_m); A.hand.g.position.copy(W).addScaledVector(fy, -0.01);
}

// rosto. open 0..1 (pálpebra), talk 0..1, smile 0..1, browUp/browSad, look [x, y]
export function setFace(api, { open = 1, talk = 0, smile = 0, browUp = 0, browSad = 0, look = [0, 0] } = {}) {
  api.eyes.forEach(({ g, ball, lidUp, lidLow, shine }) => {
    g.userData.z0 ??= g.position.z; g.position.z = g.userData.z0 - 0.01 * (1 - open); // fechado: o olho afunda e não estufa
    lidUp.rotation.x = -0.12 + (1 - open) * 1.22; lidLow.rotation.x = -0.05 - 0.12 * smile - 0.2 * (1 - open);
    ball.rotation.set(-look[1] * 0.3, look[0] * 0.4, 0); shine.visible = open > 0.35;
  });
  api.brows.forEach((b, i) => { const s = i ? 1 : -1; b.position.y += 0; b.userData.y0 ??= b.position.y; b.position.y = b.userData.y0 + 0.05 * browUp; b.rotation.z = s * 0.25 * browSad; });
  const t = Math.max(0, Math.min(1, talk));
  api.cav.scale.set(1 + 0.25 * smile, 0.12 + 0.62 * t, 0.35); api.cav.visible = t > 0.05;
  api.teeth.visible = t > 0.2; api.teeth.position.set(0, 0.025 + 0.055 * t, -0.03); api.tongue.visible = t > 0.3; api.tongue.position.set(0, -0.06 * t, -0.04);
  api.smileLine.visible = t <= 0.05; api.smileLine.scale.set(0.9 + 0.3 * smile, 0.4 + 1.6 * smile, 1);
  api.lowerLip.position.set(0, -0.06 - 0.1 * t, -0.03);
}
