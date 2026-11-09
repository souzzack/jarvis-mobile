// Personagens da micronovela "Entrega 23:47" (estilo neon).
// Jovens adultos estilizados, formas LISAS (cápsulas e elipsoides — nada de blocos), proporção de ~6 cabeças.
// Rosto simples e expressivo (olhos com íris e brilho, sobrancelhas, nariz, boca). O "neon" vem da luz de recorte.
// Kai: jaqueta de entregador azul-noite com faixa refletiva ciano, mochila térmica. Luna: jaqueta vinho, faixa rosa, rabo de cavalo.
import * as THREE from 'three';
import { RoundedBoxGeometry } from 'three/addons/geometries/RoundedBoxGeometry.js';
export const luz = (c, i = 3) => new THREE.MeshStandardMaterial({ color: c, emissive: c, emissiveIntensity: i });
const cap = (r, h, m, seg = 16) => new THREE.Mesh(new THREE.CapsuleGeometry(r, h, 8, seg), m);
const esf = (r, m, s = [1, 1, 1]) => { const o = new THREE.Mesh(new THREE.SphereGeometry(r, 32, 24), m); o.scale.set(...s); return o; };

const PRESETS = {
  kai: { pele: 0x8d5a3c, cabelo: 0x120c0a, jaqueta: 0x1b2440, calca: 0x16161c, faixa: 0x3ae0ff, tenis: 0xd9d9e0, rabo: false, mochila: true },
  luna: { pele: 0xc58b62, cabelo: 0x2a1410, jaqueta: 0x4a1830, calca: 0x16161c, faixa: 0xff3fb4, tenis: 0x2a2a30, rabo: true, mochila: true },
};

export function createPessoa(nome = 'kai') {
  const C = PRESETS[nome];
  const pele = new THREE.MeshPhysicalMaterial({ color: C.pele, roughness: 0.5, sheen: 0.4, sheenColor: new THREE.Color(0xffc9a8) });
  const cabelo = new THREE.MeshStandardMaterial({ color: C.cabelo, roughness: 0.55, metalness: 0.05 });
  const jaq = new THREE.MeshStandardMaterial({ color: C.jaqueta, roughness: 0.55, metalness: 0.1 });
  const calca = new THREE.MeshStandardMaterial({ color: C.calca, roughness: 0.8 });
  const tenis = new THREE.MeshStandardMaterial({ color: C.tenis, roughness: 0.6 });
  const faixaM = luz(C.faixa, 1.4);
  const root = new THREE.Group(), body = new THREE.Group(); root.add(body);
  const H = 1.62; // altura do quadril
  // ---- pernas
  const legs = [];
  for (const s of [-1, 1]) {
    const hip = new THREE.Group(); hip.position.set(s * 0.17, H, 0); body.add(hip);
    const coxa = cap(0.13, 0.62, calca); coxa.position.y = -0.4; hip.add(coxa);
    const knee = new THREE.Group(); knee.position.y = -0.78; hip.add(knee);
    const canela = cap(0.115, 0.6, calca); canela.position.y = -0.34; knee.add(canela);
    const pe = new THREE.Mesh(new RoundedBoxGeometry(0.22, 0.14, 0.42, 4, 0.06), tenis); pe.position.set(0, -0.77, 0.08); knee.add(pe);
    legs.push({ hip, knee });
  }
  // ---- tronco: jaqueta (elipsoide alongado) + quadril
  const quadril = esf(0.26, calca, [1.15, 0.6, 0.85]); quadril.position.y = H + 0.02; body.add(quadril);
  const torso = cap(0.29, 0.55, jaq, 20); torso.scale.set(1.05, 1, 0.72); torso.position.y = H + 0.5; body.add(torso);
  const ombros = cap(0.17, 0.62, jaq); ombros.rotation.z = Math.PI / 2; ombros.position.y = H + 0.86; ombros.scale.set(1, 1, 0.8); body.add(ombros);
  const gola = new THREE.Mesh(new THREE.TorusGeometry(0.13, 0.05, 10, 24), jaq); gola.rotation.x = Math.PI / 2; gola.position.y = H + 0.98; body.add(gola);
  // faixa refletiva no peito e nas costas
  const fx = new THREE.Mesh(new THREE.CylinderGeometry(0.31, 0.31, 0.05, 32, 1, true), faixaM); fx.scale.set(1.05, 1, 0.74); fx.position.y = H + 0.55; body.add(fx);
  const pescoco = cap(0.075, 0.12, pele); pescoco.position.y = H + 1.06; body.add(pescoco);
  // ---- braços
  const arms = [];
  for (const s of [-1, 1]) {
    const so = new THREE.Group(); so.position.set(s * 0.4, H + 0.86, 0); body.add(so);
    const braco = cap(0.1, 0.48, jaq); braco.position.y = -0.29; so.add(braco);
    const el = new THREE.Group(); el.position.y = -0.56; so.add(el);
    const ante = cap(0.09, 0.42, jaq); ante.position.y = -0.2; el.add(ante);
    const punho = new THREE.Mesh(new THREE.CylinderGeometry(0.075, 0.075, 0.06, 16), faixaM); punho.position.y = -0.42; el.add(punho);
    const mao = esf(0.095, pele, [0.9, 1.2, 0.75]); mao.position.y = -0.53; el.add(mao);
    so.rotation.z = s * 0.1; arms.push({ so, el, hand: mao });
  }
  // ---- cabeça
  const head = new THREE.Group(); head.position.y = H + 1.36; head.scale.setScalar(1.28); body.add(head);
  const cranio = esf(0.24, pele, [0.92, 1.12, 1.0]); head.add(cranio);
  for (const s of [-1, 1]) { const o = esf(0.05, pele, [0.5, 1, 0.8]); o.position.set(s * 0.22, 0, -0.01); head.add(o); }
  // cabelo: casco liso + topete (Kai) / franja + rabo de cavalo (Luna)
  const casco = new THREE.Mesh(new THREE.SphereGeometry(0.255, 32, 20, 0, Math.PI * 2, 0, Math.PI * 0.5), cabelo); casco.scale.set(0.95, 1.1, 1.04); casco.position.set(0, 0.03, -0.02); casco.rotation.x = -0.62; head.add(casco);
  if (!C.rabo) { const top = esf(0.13, cabelo, [1.55, 0.62, 1.2]); top.position.set(0.02, 0.25, 0.04); top.rotation.set(-0.3, 0, -0.12); head.add(top);
    for (const s of [-1, 1]) { const lat = esf(0.1, cabelo, [0.5, 1, 1.3]); lat.position.set(s * 0.2, 0.1, -0.04); head.add(lat); } }
  else {
    const franja = esf(0.15, cabelo, [1.45, 0.45, 0.65]); franja.position.set(-0.05, 0.2, 0.13); franja.rotation.set(-0.3, 0, 0.3);
    for (const s of [-1, 1]) { const lat = esf(0.1, cabelo, [0.5, 1.4, 1.2]); lat.position.set(s * 0.2, 0.05, -0.03); head.add(lat); } head.add(franja);
    const rabo = cap(0.07, 0.34, cabelo); rabo.position.set(0, 0.0, -0.3); rabo.rotation.x = 0.45; head.add(rabo);
    const prendedor = new THREE.Mesh(new THREE.TorusGeometry(0.06, 0.02, 8, 16), faixaM); prendedor.position.set(0, 0.17, -0.25); prendedor.rotation.x = 0.9; head.add(prendedor);
  }
  // rosto
  const branco = new THREE.MeshPhysicalMaterial({ color: 0xf3eee8, roughness: 0.25, clearcoat: 0.5 });
  const iris = new THREE.MeshPhysicalMaterial({ color: 0x2a160d, roughness: 0.1, clearcoat: 1 });
  const brilho = new THREE.MeshBasicMaterial({ color: 0xffffff });
  const eyes = [], brows = [];
  for (const s of [-1, 1]) {
    const g = new THREE.Group(); g.position.set(s * 0.092, 0.015, 0.19); head.add(g);
    g.add(esf(0.055, branco, [1.1, 1.0, 0.55]));
    const ir = esf(0.036, iris, [1, 1.08, 0.5]); ir.position.z = 0.018; g.add(ir);
    const hl = esf(0.011, brilho); hl.position.set(0.012, 0.016, 0.038); g.add(hl);
    eyes.push(g);
    const b = cap(0.016, 0.07, cabelo, 8); b.rotation.z = Math.PI / 2 + s * 0.12; b.position.set(s * 0.095, 0.095, 0.215); head.add(b); brows.push(b);
  }
  const nariz = esf(0.028, pele, [0.85, 1.1, 0.9]); nariz.position.set(0, -0.055, 0.235); head.add(nariz);
  const boca = new THREE.Group(); boca.position.set(0, -0.12, 0.2); head.add(boca);
  const labio = cap(0.014, 0.075, new THREE.MeshStandardMaterial({ color: 0x4a2620, roughness: 0.6 }), 8); labio.rotation.z = Math.PI / 2; boca.add(labio);
  const interior = esf(0.03, new THREE.MeshStandardMaterial({ color: 0x1a0808 }), [1.3, 0.2, 0.4]); interior.position.z = -0.005; boca.add(interior);
  // ---- mochila térmica
  if (C.mochila) {
    const m = new THREE.Mesh(new RoundedBoxGeometry(0.62, 0.62, 0.42, 4, 0.06), new THREE.MeshStandardMaterial({ color: 0x15151d, roughness: 0.5 }));
    m.position.set(0, H + 0.58, -0.45); body.add(m);
    const f = new THREE.Mesh(new RoundedBoxGeometry(0.635, 0.05, 0.435, 2, 0.02), faixaM); f.position.set(0, H + 0.62, -0.45); body.add(f);
    for (const s of [-1, 1]) { const al = cap(0.03, 0.5, new THREE.MeshStandardMaterial({ color: 0x0c0c12 }), 6); al.position.set(s * 0.2, H + 0.62, -0.2); al.rotation.x = 0.15; body.add(al); }
  }
  root.traverse(o => { if (o.isMesh) { o.castShadow = true; o.receiveShadow = true; } });
  return { root, body, legs, arms, head, eyes, brows, boca: interior, H, faixaM };
}

// pose(p, opções): walk 0..1 (intensidade do passo), ph fase, sit 0..1 (sentado na moto), guidao 0..1,
// olhos 0..1 (abertura), arregala 0..1, franze 0..1 (preocupado), fala 0..1 (boca), cabeca [giro, inclinação]
export function pose(p, { walk = 0, ph = 0, sit = 0, guidao = 0, olhos = 1, arregala = 0, franze = 0, fala = 0, cabeca = [0, 0], respira = 0 } = {}) {
  p.legs.forEach(({ hip, knee }, i) => {
    const s = Math.sin(ph + i * Math.PI);
    hip.rotation.set(s * 0.5 * walk * (1 - sit) - 1.4 * sit, 0, (i ? 1 : -1) * 0.12 * sit);
    knee.rotation.x = Math.max(0, -Math.sin(ph + i * Math.PI - 0.9)) * 0.85 * walk * (1 - sit) + 1.55 * sit;
  });
  p.arms.forEach(({ so, el }, i) => {
    const s = -Math.sin(ph + i * Math.PI);
    so.rotation.set(s * 0.4 * walk * (1 - guidao) - 1.05 * guidao, 0, (i ? 1 : -1) * (0.1 + 0.05 * guidao));
    el.rotation.x = (-0.2 - 0.35 * walk * Math.max(0, -s)) * (1 - guidao) - 0.55 * guidao;
  });
  p.body.position.y = Math.abs(Math.cos(ph)) * 0.04 * walk - 0.55 * sit + Math.sin(respira * 2.2) * 0.006;
  p.body.rotation.x = 0.06 * walk + 0.25 * sit;
  p.eyes.forEach(e => e.scale.set(1 + 0.15 * arregala, Math.max(0.08, olhos) * (1 + 0.35 * arregala), 1));
  p.brows.forEach((b, i) => { const s = i ? 1 : -1; b.position.y = 0.095 + 0.025 * arregala + 0.01 * franze; b.rotation.z = Math.PI / 2 + s * (0.12 - 0.4 * franze); });
  p.boca.scale.set(1.3, 0.2 + 2.2 * fala, 0.4); p.boca.visible = fala > 0.05; // boca fechada: só o lábio
  p.head.rotation.set(cabeca[1], cabeca[0], 0);
}
