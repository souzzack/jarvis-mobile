// Personagens da micronovela (estilo neon): silhuetas escuras e lisas, olhos de traço de luz,
// mochila de entrega com faixa luminosa (Kai = ciano, Luna = rosa). Pivôs: quadril, joelho, ombro, cotovelo.
import * as THREE from 'three';
import { RoundedBoxGeometry } from 'three/addons/geometries/RoundedBoxGeometry.js';
const rb = (w, h, d, r, m) => new THREE.Mesh(new RoundedBoxGeometry(w, h, d, 4, r), m);
export const luz = (c, i = 3) => new THREE.MeshStandardMaterial({ color: c, emissive: c, emissiveIntensity: i });

export function createPessoa({ faixa = 0x3ae0ff, rabo = false, capacete = true } = {}) {
  const pele = new THREE.MeshStandardMaterial({ color: 0x15131f, roughness: 0.42, metalness: 0.12 });
  const root = new THREE.Group(), body = new THREE.Group(); root.add(body);
  const legs = [], arms = [];
  for (const s of [-1, 1]) {
    const hip = new THREE.Group(); hip.position.set(s * 0.24, 1.35, 0); body.add(hip);
    const th = rb(0.34, 0.7, 0.38, 0.15, pele); th.position.y = -0.33; hip.add(th);
    const knee = new THREE.Group(); knee.position.y = -0.68; hip.add(knee);
    const sh = rb(0.3, 0.62, 0.34, 0.13, pele); sh.position.y = -0.3; knee.add(sh);
    const ft = rb(0.32, 0.14, 0.5, 0.06, pele); ft.position.set(0, -0.62, 0.08); knee.add(ft);
    legs.push({ hip, knee });
    const so = new THREE.Group(); so.position.set(s * 0.6, 2.55, 0.05); body.add(so);
    const up = rb(0.26, 0.6, 0.28, 0.12, pele); up.position.y = -0.28; so.add(up);
    const el = new THREE.Group(); el.position.y = -0.58; so.add(el);
    const fo = rb(0.24, 0.55, 0.26, 0.11, pele); fo.position.y = -0.26; el.add(fo);
    const hd = new THREE.Mesh(new THREE.SphereGeometry(0.14, 16, 12), pele); hd.position.y = -0.58; el.add(hd);
    so.rotation.z = s * 0.06; arms.push({ so, el, hand: hd });
  }
  const tr = rb(0.9, 1.3, 0.55, 0.22, pele); tr.position.y = 2.0; body.add(tr);
  const head = new THREE.Group(); head.position.y = 2.98; body.add(head);
  const cab = new THREE.Mesh(new THREE.SphereGeometry(0.42, 32, 24), pele); cab.scale.set(1, 1.08, 1); head.add(cab);
  if (capacete) { const v = new THREE.Mesh(new THREE.SphereGeometry(0.445, 32, 16, -0.9, 1.8, 1.0, 0.75), new THREE.MeshStandardMaterial({ color: 0x202034, roughness: 0.1, metalness: 0.8 })); v.position.y = 0.02; head.add(v); }
  if (rabo) { const r = rb(0.2, 0.62, 0.2, 0.09, pele); r.position.set(0, 0.0, -0.46); r.rotation.x = 0.35; head.add(r); }
  const eyeMat = luz(0xffffff, 2);
  const eyes = [-1, 1].map(s => { const o = rb(0.13, 0.035, 0.02, 0.01, eyeMat); o.position.set(s * 0.14, 0.04, 0.43); head.add(o); return o; });
  const moch = rb(0.95, 0.95, 0.7, 0.1, pele); moch.position.set(0, 2.2, -0.62); body.add(moch);
  const fx = rb(0.97, 0.08, 0.72, 0.03, luz(faixa, 2.5)); fx.position.set(0, 2.25, -0.62); body.add(fx);
  root.traverse(o => { if (o.isMesh) o.castShadow = true; });
  return { root, body, legs, arms, head, eyes, eyeMat };
}
// pose: sobe (1 = passo de escada), walk (0..1 intensidade), ph (fase em radianos), sit (0..1 sentado na moto), guidao (braços à frente)
export function pose(p, { walk = 0, ph = 0, sit = 0, guidao = 0, olhos = 1, arregala = 0, cabeca = [0, 0], sobe = 0 } = {}) {
  p.legs.forEach(({ hip, knee }, i) => {
    if (sobe) { const l = Math.max(0, Math.sin(ph + i * Math.PI)); hip.rotation.x = -(0.25 + 1.05 * l); knee.rotation.x = 0.15 + 1.35 * l; return; } // subir escada: joelho alto
    const sw = Math.sin(ph + i * Math.PI) * 0.55 * walk;
    hip.rotation.x = sw * (1 - sit) + (-1.25) * sit;
    knee.rotation.x = Math.max(0, -Math.sin(ph + i * Math.PI + 0.6)) * 0.7 * walk * (1 - sit) + 1.35 * sit;
  });
  p.arms.forEach(({ so, el }, i) => {
    const sw = -Math.sin(ph + i * Math.PI) * 0.45 * walk;
    so.rotation.x = sw * (1 - guidao) + (-0.85) * guidao; el.rotation.x = (-0.15 - 0.2 * walk) * (1 - guidao) + (-0.4) * guidao;
  });
  p.body.position.y = Math.abs(Math.sin(ph)) * 0.05 * walk - 0.22 * sit;
  p.eyes.forEach(e => e.scale.set(1 - 0.2 * arregala, Math.max(0.15, olhos) * (1 + 1.6 * arregala), 1));
  p.head.rotation.set(cabeca[1], cabeca[0], 0);
}
