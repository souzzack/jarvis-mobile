// Davi — menino em blocos arredondados (inspirado no usuário, versão criança).
import * as THREE from 'three';
import { RoundedBoxGeometry } from 'three/addons/geometries/RoundedBoxGeometry.js';

const rb = (w, h, d, r, m, seg = 4) => new THREE.Mesh(new RoundedBoxGeometry(w, h, d, seg, r), m);

export function createDavi(opts = {}) {
  const C = { skin: 0xa8714b, skinDark: 0x8f5d3d, hair: 0x17110f, fade: 0x5e4030, shirt: 0x6e3b26, shirtDark: 0x5a2f1e, pants: 0x2c3442, curls: true, ...opts };
  const skin = new THREE.MeshPhysicalMaterial({ color: C.skin, roughness: 0.55, sheen: 0.3, sheenColor: new THREE.Color(0xffc9a0) });
  const skinDark = skin.clone(); skinDark.color.set(C.skinDark);
  const hair = new THREE.MeshStandardMaterial({ color: C.hair, roughness: 0.75 });
  const fade = new THREE.MeshStandardMaterial({ color: C.fade, roughness: 0.95 });
  const shirt = new THREE.MeshStandardMaterial({ color: C.shirt, roughness: 0.85 });
  const shirtDark = shirt.clone(); shirtDark.color.set(C.shirtDark);
  const pants = new THREE.MeshStandardMaterial({ color: C.pants, roughness: 0.8 });
  const shoe = new THREE.MeshStandardMaterial({ color: 0xece7de, roughness: 0.6 });
  const sole = new THREE.MeshStandardMaterial({ color: 0xbdb5a8, roughness: 0.7 });
  const white = new THREE.MeshPhysicalMaterial({ color: 0xf6f1ea, roughness: 0.3, clearcoat: 0.6 });
  const iris = new THREE.MeshPhysicalMaterial({ color: 0x24150e, roughness: 0.1, clearcoat: 1 });
  const shine = new THREE.MeshBasicMaterial({ color: 0xffffff });
  const lip = new THREE.MeshStandardMaterial({ color: 0x7e4535, roughness: 0.6 });
  const mouthIn = new THREE.MeshStandardMaterial({ color: 0x3a1512, roughness: 0.8 });

  const root = new THREE.Group();
  const body = new THREE.Group(); root.add(body);

  // ----- pernas (pivô no quadril e no joelho)
  const hipY = 0.78;
  const legs = [];
  for (const s of [-1, 1]) {
    const hip = new THREE.Group(); hip.position.set(s * 0.22, hipY, 0);
    const thigh = rb(0.32, 0.42, 0.36, 0.08, pants); thigh.position.y = -0.2; hip.add(thigh);
    const knee = new THREE.Group(); knee.position.y = -0.4; hip.add(knee);
    const shin = rb(0.3, 0.38, 0.34, 0.08, pants); shin.position.y = -0.18; knee.add(shin);
    const sh = rb(0.34, 0.16, 0.48, 0.07, shoe); sh.position.set(0, -0.36, 0.06); knee.add(sh);
    const so = rb(0.35, 0.05, 0.49, 0.02, sole); so.position.set(0, -0.43, 0.06); knee.add(so);
    body.add(hip); legs.push({ hip, knee });
  }

  // ----- tronco
  const torso = rb(0.86, 0.86, 0.52, 0.12, shirt); torso.position.y = hipY + 0.4; body.add(torso);
  const hem = rb(0.88, 0.07, 0.54, 0.03, shirtDark); hem.position.y = hipY + 0.0; body.add(hem);
  const neck = rb(0.26, 0.14, 0.24, 0.05, skin); neck.position.y = hipY + 0.87; body.add(neck);
  const collar = new THREE.Mesh(new THREE.TorusGeometry(0.16, 0.035, 8, 24), shirtDark);
  collar.rotation.x = Math.PI / 2; collar.position.y = hipY + 0.82; body.add(collar);

  // ----- braços (ombro e cotovelo)
  const arms = {};
  for (const s of [-1, 1]) {
    const sh = new THREE.Group(); sh.position.set(s * 0.53, hipY + 0.72, 0);
    const sleeve = rb(0.26, 0.34, 0.3, 0.08, shirt); sleeve.position.y = -0.14; sh.add(sleeve);
    const elbow = new THREE.Group(); elbow.position.y = -0.3; sh.add(elbow);
    const fore = rb(0.2, 0.32, 0.22, 0.07, skin); fore.position.y = -0.14; elbow.add(fore);
    const hand = rb(0.22, 0.2, 0.22, 0.08, skin); hand.position.y = -0.36; elbow.add(hand);
    sh.rotation.z = s * 0.08;
    body.add(sh); arms[s < 0 ? 'L' : 'R'] = { sh, elbow, hand };
  }

  // ----- cabeça (grande, proporção de criança)
  const head = new THREE.Group(); head.position.y = hipY + 1.48; body.add(head);
  const skull = rb(1.08, 1.08, 0.98, 0.16, skin, 5); head.add(skull);
  const front = 0.49;
  for (const s of [-1, 1]) { const ear = rb(0.1, 0.22, 0.16, 0.04, skinDark); ear.position.set(s * 0.56, -0.02, 0); head.add(ear); }
  // cabelo: laterais baixas + topo de cachos
  for (const s of [-1, 1]) { const f = rb(0.02, 0.2, 0.7, 0.01, fade); f.position.set(s * 0.545, 0.4, -0.06); head.add(f); }
  const back = rb(0.9, 0.22, 0.02, 0.01, fade); back.position.set(0, 0.4, -0.495); head.add(back);
  const cap = rb(1.0, 0.16, 0.92, 0.07, hair); cap.position.y = 0.53; head.add(cap);
  let seed = 5; const rnd = () => { seed = (seed * 16807) % 2147483647; return seed / 2147483647; };
  if (C.curls) {
  const curlGeo = new THREE.SphereGeometry(1, 10, 8);
  for (let i = 0; i < 120; i++) {
    const x = (rnd() - 0.5) * 0.98, z = (rnd() - 0.5) * 0.9;
    const r = 0.07 + rnd() * 0.06;
    const c = new THREE.Mesh(curlGeo, hair); c.scale.setScalar(r);
    c.position.set(x, 0.6 + rnd() * 0.13 - Math.abs(x) * 0.12, z);
    head.add(c);
  }
  for (let i = 0; i < 26; i++) { // cachos nas laterais altas
    const sd = i % 2 ? 1 : -1; const c = new THREE.Mesh(curlGeo, hair); c.scale.setScalar(0.06 + rnd() * 0.04);
    c.position.set(sd * (0.48 + rnd() * 0.04), 0.52 + rnd() * 0.08, -0.4 + rnd() * 0.8); head.add(c);
  }
  for (let i = 0; i < 16; i++) { // franja de cachos na testa
    const c = new THREE.Mesh(curlGeo, hair); const r = 0.06 + rnd() * 0.04; c.scale.setScalar(r);
    c.position.set(-0.42 + i * 0.056, 0.47 + rnd() * 0.05, front - 0.02); head.add(c);
  }
  } else {
    const top = rb(1.06, 0.22, 0.98, 0.08, hair); top.position.y = 0.6; head.add(top);
    const fr = rb(1.06, 0.2, 0.12, 0.05, hair); fr.position.set(-0.05, 0.47, front + 0.02); fr.rotation.z = -0.12; head.add(fr);
    for (const sd of [-1, 1]) { const sdh = rb(0.06, 0.4, 0.9, 0.03, hair); sdh.position.set(sd * 0.54, 0.38, -0.04); head.add(sdh); }
  }
  // sobrancelhas grossas
  const brows = [];
  for (const s of [-1, 1]) {
    const b = rb(0.27, 0.08, 0.05, 0.03, hair); b.position.set(s * 0.23, 0.22, front + 0.01); head.add(b); brows.push(b);
  }
  // olhos
  const eyes = [];
  for (const s of [-1, 1]) {
    const g = new THREE.Group(); g.position.set(s * 0.23, 0.02, front + 0.005);
    const w = rb(0.27, 0.23, 0.04, 0.07, white); g.add(w);
    const ir = rb(0.17, 0.2, 0.03, 0.06, iris); ir.position.set(-s * 0.015, -0.005, 0.02); g.add(ir);
    const hl = rb(0.06, 0.06, 0.01, 0.015, shine); hl.position.set(-s * 0.015 + 0.03, 0.03, 0.04); g.add(hl);
    head.add(g); eyes.push(g);
  }
  const nose = rb(0.13, 0.15, 0.08, 0.04, skinDark); nose.position.set(0, -0.1, front + 0.03); head.add(nose);
  // boca: lábio + interior que abre ao falar
  const mouth = new THREE.Group(); mouth.position.set(0, -0.28, front + 0.005);
  const inner = rb(0.2, 0.1, 0.02, 0.03, mouthIn); mouth.add(inner);
  const lips = rb(0.24, 0.05, 0.03, 0.02, lip); lips.position.y = -0.05; mouth.add(lips);
  head.add(mouth);
  for (const s of [-1, 1]) { const ch = rb(0.14, 0.06, 0.02, 0.02, new THREE.MeshStandardMaterial({ color: 0xc46a5a, transparent: true, opacity: 0.35 })); ch.position.set(s * 0.33, -0.18, front); head.add(ch); }

  const tearMat = new THREE.MeshPhysicalMaterial({ color: 0xbfe4ff, roughness: 0.05, transmission: 0.3, transparent: true, opacity: 0.85, emissive: 0x4a90c8, emissiveIntensity: 0.4 });
  const tears = [-1, 1].map(s => { const t = new THREE.Mesh(new THREE.SphereGeometry(0.04, 12, 10), tearMat); t.scale.set(1, 1.4, 0.7); t.position.set(s * 0.23, -0.12, front + 0.04); t.visible = false; head.add(t); return t; });
  root.traverse(o => { if (o.isMesh) { o.castShadow = true; o.receiveShadow = true; } });
  tears.forEach(t => { t.castShadow = false; });

  const api = { root, body, head, brows, eyes, mouth, inner, arms, legs, hipY, tears };
  setSitting(api, 0);
  return api;
}

// 0 = em pé, 1 = sentado na beira de algo (coxas para frente, canelas para baixo)
export function setSitting(d, s) {
  d.legs.forEach(({ hip, knee }) => { hip.rotation.x = -Math.PI / 2 * s; knee.rotation.x = Math.PI / 2 * s; });
  d.body.position.y = -0.38 * s;
}
// expressões simples
export function setFace(d, { open = 1, talk = 0, browUp = 0, browSad = 0, look = [0, 0] } = {}) {
  d.eyes.forEach((e, i) => {
    e.scale.y = Math.max(0.08, open);
    const ir = e.children[1], hl = e.children[2];
    ir.position.x = (i ? -1 : 1) * 0.015 + look[0] * 0.04; ir.position.y = -0.005 + look[1] * 0.03;
    hl.position.x = ir.position.x + 0.03; hl.position.y = ir.position.y + 0.035; hl.visible = open > 0.4;
  });
  d.brows.forEach((b, i) => {
    const s = i ? 1 : -1;
    b.position.y = 0.22 + 0.05 * browUp;
    b.rotation.z = -s * 0.25 * browSad;
  });
  d.inner.scale.y = 0.2 + 1.3 * talk;
  d.inner.position.y = -0.01 - 0.03 * talk;
}
