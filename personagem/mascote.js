// Mascote "Claudinho" — pequeno robô editor. Módulo compartilhado por todas as cenas
// para manter o personagem idêntico de uma imagem para outra.
import * as THREE from 'three';
import { RoundedBoxGeometry } from 'three/addons/geometries/RoundedBoxGeometry.js';

export const COLORS = {
  orange: 0xe9773a,
  orangeDark: 0xc65a26,
  glow: 0xff7a2a,
  cloth: 0x1a171c,
  plastic: 0x121115,
};

const rb = (w, h, d, r, m, seg = 5) => new THREE.Mesh(new RoundedBoxGeometry(w, h, d, seg, r), m);

function starShape(R, r, points = 4) {
  const s = new THREE.Shape();
  for (let i = 0; i < points * 2; i++) {
    const a = i * Math.PI / points + Math.PI / 2;
    const rad = i % 2 === 0 ? R : r;
    i === 0 ? s.moveTo(Math.cos(a) * rad, Math.sin(a) * rad) : s.lineTo(Math.cos(a) * rad, Math.sin(a) * rad);
  }
  return s;
}

export function makeStar(size, material, depth = 0.08) {
  const g = new THREE.ExtrudeGeometry(starShape(size, size * 0.3), {
    depth, bevelEnabled: true, bevelThickness: depth * 0.6, bevelSize: size * 0.06, bevelSegments: 4,
  });
  g.center();
  return new THREE.Mesh(g, material);
}

function rulerTexture() {
  const c = document.createElement('canvas'); c.width = 96; c.height = 960;
  const g = c.getContext('2d');
  const grd = g.createLinearGradient(0, 0, 96, 0);
  grd.addColorStop(0, '#d9d4cc'); grd.addColorStop(0.5, '#f4f0ea'); grd.addColorStop(1, '#c9c3ba');
  g.fillStyle = grd; g.fillRect(0, 0, 96, 960);
  g.fillStyle = '#1b1a1f';
  for (let i = 0; i <= 90; i++) {
    const y = 30 + i * 10;
    const len = i % 10 === 0 ? 40 : i % 5 === 0 ? 28 : 16;
    g.fillRect(0, y, len, 3);
  }
  g.font = 'bold 22px DejaVu Sans, Arial';
  for (let i = 0; i <= 9; i++) g.fillText(String(i), 50, 38 + i * 100);
  const t = new THREE.CanvasTexture(c); t.colorSpace = THREE.SRGBColorSpace; t.anisotropy = 8;
  return t;
}

export function createMascot() {
  const orange = new THREE.MeshPhysicalMaterial({
    color: COLORS.orange, roughness: 0.48, clearcoat: 0.3, clearcoatRoughness: 0.45,
    sheen: 0.4, sheenColor: new THREE.Color(0xffb487), sheenRoughness: 0.6,
  });
  const orangeDark = orange.clone(); orangeDark.color.set(COLORS.orangeDark);
  const cloth = new THREE.MeshStandardMaterial({ color: COLORS.cloth, roughness: 0.88 });
  const plastic = new THREE.MeshPhysicalMaterial({ color: COLORS.plastic, roughness: 0.32, clearcoat: 0.7, clearcoatRoughness: 0.25 });
  const glow = new THREE.MeshStandardMaterial({ color: 0xffa060, emissive: COLORS.glow, emissiveIntensity: 3.2 });
  const eyeMat = new THREE.MeshPhysicalMaterial({ color: 0x060505, roughness: 0.12, clearcoat: 1, clearcoatRoughness: 0.03 });
  const shine = new THREE.MeshBasicMaterial({ color: 0xffffff });
  const blush = new THREE.MeshStandardMaterial({ color: 0xff8f70, roughness: 0.9, transparent: true, opacity: 0.45 });

  const root = new THREE.Group();
  const body = new THREE.Group();

  // Pernas
  const legH = 0.5;
  const legs = [];
  for (const x of [-0.55, 0.55]) for (const z of [-0.38, 0.38]) {
    const lg = new THREE.Group();
    lg.position.set(x, legH, z);
    const leg = rb(0.38, legH, 0.38, 0.07, x < 0 ? orange : orangeDark);
    leg.position.y = -legH / 2; lg.add(leg);
    const foot = rb(0.42, 0.08, 0.44, 0.03, plastic);
    foot.position.set(0, -legH + 0.04, 0.02); lg.add(foot);
    root.add(lg); legs.push(lg);
  }

  // Roupa: túnica preta com cinto, bolso e fivela luminosa
  const tunicY = legH + 0.36;
  const tunic = rb(2.0, 0.74, 1.46, 0.14, cloth);
  tunic.position.y = tunicY; body.add(tunic);
  const hem = rb(2.06, 0.08, 1.52, 0.04, plastic);
  hem.position.y = legH + 0.02; body.add(hem);
  const belt = rb(2.05, 0.12, 1.51, 0.05, plastic);
  belt.position.y = tunicY + 0.08; body.add(belt);
  const buckle = rb(0.2, 0.15, 0.04, 0.03, glow);
  buckle.position.set(-0.35, tunicY + 0.08, 0.76); body.add(buckle);
  const pocket = rb(0.42, 0.3, 0.06, 0.04, plastic);
  pocket.position.set(0.5, tunicY - 0.12, 0.74); body.add(pocket);
  const clip = rb(0.12, 0.08, 0.03, 0.015, glow);
  clip.position.set(0.5, tunicY + 0.0, 0.78); body.add(clip);
  for (const x of [-0.7, 0.7]) {
    const strap = rb(0.12, 0.74, 0.03, 0.02, plastic);
    strap.position.set(x, tunicY, 0.74); body.add(strap);
  }
  const emblem = makeStar(0.08, glow, 0.02);
  emblem.position.set(-0.35, tunicY - 0.15, 0.75); body.add(emblem);

  // Braços
  const armL = new THREE.Group();
  const aL = rb(0.26, 0.48, 0.3, 0.09, orange); aL.position.y = -0.2; armL.add(aL);
  armL.position.set(-1.07, tunicY + 0.2, 0.1); armL.rotation.z = -0.25;
  body.add(armL);

  const armR = new THREE.Group();
  const aR = rb(0.46, 0.26, 0.3, 0.09, orange); aR.position.x = 0.2; armR.add(aR);
  const hand = rb(0.28, 0.3, 0.32, 0.1, orange); hand.position.set(0.44, 0.02, 0.06); armR.add(hand);
  armR.position.set(0.98, tunicY + 0.18, 0.25);
  body.add(armR);

  // Régua (apoiada no chão, como um cajado)
  const ruler = new THREE.Group();
  const rm = new THREE.MeshPhysicalMaterial({ map: rulerTexture(), roughness: 0.35, metalness: 0.3, clearcoat: 0.6 });
  const rbody = new THREE.Mesh(new THREE.BoxGeometry(0.2, 2.1, 0.04), [plastic, plastic, plastic, plastic, rm, plastic]);
  ruler.add(rbody);
  for (const y of [1.05, -1.05]) {
    const cap = rb(0.24, 0.1, 0.07, 0.03, glow); cap.position.y = y; ruler.add(cap);
  }
  const rulerPivot = new THREE.Group();
  rulerPivot.position.set(1.42, 1.06, 0.36);
  rulerPivot.rotation.z = -0.06;
  ruler.position.y = -0.01;
  rulerPivot.add(ruler);
  body.add(rulerPivot);

  // Cabeça
  const head = new THREE.Group();
  const headY = legH + 0.74 + 0.7;
  head.position.y = headY;
  const skull = rb(2.25, 1.38, 1.6, 0.2, orange, 6);
  head.add(skull);
  const front = 0.8;
  const eyes = [];
  for (const x of [-0.48, 0.48]) {
    const eye = rb(0.3, 0.33, 0.06, 0.05, eyeMat); eye.position.set(x, 0.1, front); head.add(eye);
    const s1 = rb(0.09, 0.09, 0.02, 0.015, shine); s1.position.set(x + 0.06, 0.18, front + 0.035); head.add(s1);
    const s2 = rb(0.035, 0.035, 0.02, 0.01, shine); s2.position.set(x - 0.08, 0.0, front + 0.035); head.add(s2);
    eyes.push({ eye, s1, s2 });
    const ch = rb(0.22, 0.09, 0.02, 0.03, blush); ch.position.set(x * 1.45, -0.18, front - 0.005); head.add(ch);
  }
  // pequeno sorriso em blocos
  const smile = new THREE.Group();
  for (const [x, y] of [[-0.09, 0.02], [0, -0.01], [0.09, 0.02]]) {
    const b = rb(0.1, 0.045, 0.03, 0.015, eyeMat); b.position.set(x, y, 0); smile.add(b);
  }
  smile.position.set(0, -0.22, front + 0.005); head.add(smile);

  // Fones de ouvido
  const band = rb(2.6, 0.16, 0.36, 0.07, plastic); band.position.set(0, 0.8, -0.05); head.add(band);
  const bandPad = rb(1.4, 0.06, 0.26, 0.03, cloth); bandPad.position.set(0, 0.71, -0.05); head.add(bandPad);
  for (const s of [-1, 1]) {
    const side = rb(0.16, 0.55, 0.32, 0.06, plastic); side.position.set(s * 1.25, 0.52, -0.05); head.add(side);
    const cup = rb(0.36, 0.86, 0.86, 0.14, plastic); cup.position.set(s * 1.25, 0.0, -0.02); head.add(cup);
    const ring = rb(0.04, 0.68, 0.68, 0.1, glow); ring.position.set(s * 1.44, 0, -0.02); head.add(ring);
    const plate = rb(0.05, 0.56, 0.56, 0.08, plastic); plate.position.set(s * 1.46, 0, -0.02); head.add(plate);
    const st = makeStar(0.15, glow, 0.02); st.rotation.y = s * Math.PI / 2; st.position.set(s * 1.5, 0, -0.02); head.add(st);
  }

  // Estrela luminosa na cabeça
  const stem = new THREE.Mesh(new THREE.CylinderGeometry(0.04, 0.05, 0.4, 12), plastic);
  stem.position.set(0, 0.98, 0.15); head.add(stem);
  const starMat = new THREE.MeshStandardMaterial({ color: 0xffd09a, emissive: 0xff9a40, emissiveIntensity: 5 });
  const star = makeStar(0.36, starMat, 0.1);
  star.position.set(0, 1.4, 0.15); head.add(star);
  const starLight = new THREE.PointLight(0xff9a40, 6, 4, 2);
  starLight.position.set(0, 1.4, 0.5); head.add(starLight);

  body.add(head);
  root.add(body);
  root.traverse(o => { if (o.isMesh) { o.castShadow = true; o.receiveShadow = true; } });
  starLight.castShadow = false;

  return { root, body, head, armL, armR, ruler, rulerPivot, legs, star, starLight, eyes, legH, height: headY + 1.8 };
}

// Poses reaproveitáveis entre as cenas
export function pose(m, name) {
  if (name === 'apontar') {
    // braço levantado, régua apontando para cima e para trás (na direção da tela)
    m.armR.rotation.z = 0.6;
    m.rulerPivot.position.set(1.33, 1.31, 0.31);
    m.rulerPivot.rotation.set(-0.55, 0, -0.45);
    m.ruler.position.y = 0.6;
    m.armL.rotation.z = -0.45;
  } else if (name === 'sentado') {
    m.legs.forEach(l => { l.rotation.x = -Math.PI / 2; });
    m.legs.forEach(l => { if (l.position.z < 0) l.visible = false; });
    m.body.position.y = -(m.legH - 0.19);
    m.legs.forEach(l => { l.position.y -= (m.legH - 0.19); });
    // régua apoiada no ombro
    m.armR.rotation.z = 1.0;
    m.rulerPivot.position.set(1.22, 1.41, 0.3);
    m.rulerPivot.rotation.set(-0.45, 0, -0.4);
    m.ruler.position.y = 0.85;
  }
}
