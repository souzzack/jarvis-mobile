// Base comum dos episódios do Davi: helpers, personagens, quarto com poses, pós-processamento.
import * as THREE from 'three';
import { RoundedBoxGeometry } from 'three/addons/geometries/RoundedBoxGeometry.js';
import { EffectComposer } from 'three/addons/postprocessing/EffectComposer.js';
import { RenderPass } from 'three/addons/postprocessing/RenderPass.js';
import { UnrealBloomPass } from 'three/addons/postprocessing/UnrealBloomPass.js';
import { BokehPass } from 'three/addons/postprocessing/BokehPass.js';
import { OutputPass } from 'three/addons/postprocessing/OutputPass.js';
import { createDavi, setSitting, setFace } from './davi.js';
import { createQuarto } from './quarto.js';

export { THREE, createDavi, setSitting, setFace };
export const W = 1080, H = 1920;
// resolução interna do 3D (ampliada para 1080×1920 na tela): ?q=1 para resolução cheia
const Q = +(new URLSearchParams(location.search).get('q') || 0.667), RW = Math.round(W * Q), RH = Math.round(H * Q);
export const clamp = (x, a = 0, b = 1) => Math.min(b, Math.max(a, x));
export const smooth = (x) => { x = clamp(x); return x * x * (3 - 2 * x); };
export const seg = (t, a, b) => smooth((t - a) / (b - a));
export const mix = (a, b, k) => a + (b - a) * k;
export const V = (x, y, z) => new THREE.Vector3(x, y, z);
export const rb = (w, h, d, r, m) => new THREE.Mesh(new RoundedBoxGeometry(w, h, d, 3, r), m);
export const std = (color, roughness = 0.8, extra = {}) => new THREE.MeshStandardMaterial({ color, roughness, ...extra });
export const blink = (T, off = 0) => { const ph = ((T + off) * 0.31) % 1; return ph > 0.97 ? 0.1 : 1; };
export const headW = (k) => k.head.getWorldPosition(new THREE.Vector3());
export const canvasTex = (w, h, draw) => { const c = document.createElement('canvas'); c.width = w; c.height = h; draw(c.getContext('2d'), w, h); const t = new THREE.CanvasTexture(c); t.colorSpace = THREE.SRGBColorSpace; t.userData.canvas = c; return t; };
const glowTex = canvasTex(256, 256, (g) => { const r = g.createRadialGradient(128, 128, 0, 128, 128, 128); r.addColorStop(0, 'rgba(255,240,200,1)'); r.addColorStop(0.35, 'rgba(255,205,120,0.6)'); r.addColorStop(1, 'rgba(255,190,100,0)'); g.fillStyle = r; g.fillRect(0, 0, 256, 256); });
export const glowSprite = (s, op = 1) => { const sp = new THREE.Sprite(new THREE.SpriteMaterial({ map: glowTex, transparent: true, depthWrite: false, blending: THREE.AdditiveBlending, opacity: op })); sp.scale.set(s, s, 1); return sp; };

export async function loadEnv(path) {
  const ENV = await (await fetch(path)).json();
  const at = (arr, T) => arr[Math.min(arr.length - 1, Math.max(0, Math.round(T * ENV.fps)))] || 0;
  return { davi: (T) => at(ENV.davi, T), deus: (T) => at(ENV.deus, T) };
}
// quadros-chave de expressão: transição de 0,45 s a partir de cada chave
export function makeExpr(BASE, K) {
  const KEYS = (() => { let cur = { ...BASE }; return K.map(([t, v]) => { cur = { ...cur, ...v }; return [t, { ...cur }]; }); })();
  return (T) => {
    let i = 0; while (i < KEYS.length - 1 && KEYS[i + 1][0] <= T) i++;
    const [ta, a] = KEYS[i], prev = i > 0 ? KEYS[i - 1][1] : a, kk = smooth((T - ta) / 0.45), o = {};
    for (const key in a) o[key] = mix(prev[key], a[key], kk);
    return o;
  };
}

// ---------- personagens
let CHAR_ID = 0;
export function addSmile(d) {
  d.root.userData.char = ++CHAR_ID; d.root.userData.api = d; // usados pela checagem de colisões
  const sm = new THREE.Mesh(new THREE.TorusGeometry(0.1, 0.022, 10, 28, Math.PI * 0.7), std(0x5a2a20, 0.6));
  sm.rotation.z = Math.PI + Math.PI * 0.15; sm.position.set(0, 0.04, 0.01); sm.visible = false; d.mouth.add(sm);
  d.setSmile = (on) => { sm.visible = on; d.mouth.children[1].visible = !on; d.inner.visible = !on; };
  return d;
}
export function addGlasses(k, color = 0x222222) {
  const m = std(color, 0.4);
  for (const s of [-1, 1]) { const f = new THREE.Mesh(new THREE.TorusGeometry(0.14, 0.022, 8, 4), m); f.rotation.z = Math.PI / 4; f.scale.set(1.1, 0.9, 1); f.position.set(s * 0.23, 0.02, 0.53); k.head.add(f); }
  const br = rb(0.16, 0.03, 0.03, 0.01, m); br.position.set(0, 0.04, 0.53); k.head.add(br);
}
export function addLongHair(k, color) { // cabelo comprido (mãe)
  const m = std(color, 0.75);
  const back = rb(1.24, 1.5, 0.3, 0.12, m); back.position.set(0, -0.12, -0.5); k.head.add(back);
  for (const s of [-1, 1]) { const side = rb(0.16, 1.35, 0.9, 0.06, m); side.position.set(s * 0.62, -0.1, -0.08); k.head.add(side); }
  const top = rb(1.16, 0.2, 1.04, 0.08, m); top.position.set(0, 0.6, -0.02); k.head.add(top);
  const fringe = rb(1.1, 0.16, 0.1, 0.05, m); fringe.position.set(0, 0.47, 0.5); k.head.add(fringe);
}
export function addBun(k, color) { // coque (vó)
  const b = new THREE.Mesh(new THREE.SphereGeometry(0.24, 16, 12), std(color, 0.8)); b.position.set(0, 0.62, -0.42); k.head.add(b);
}
export const PALETTE = {
  LUCAS: { skin: 0xe9c2a0, skinDark: 0xd9a983, hair: 0xb07a3a, shirt: 0x8ec5ff, shirtDark: 0x6aa7e6, pants: 0xd9c7a3, curls: false },
  THEO: { skin: 0xd8a47c, skinDark: 0xc28e66, hair: 0x2b1a12, shirt: 0x5b7fbf, shirtDark: 0x4a6aa3, pants: 0x3b3b3b, curls: false },
  VO: { skin: 0x9a6644, skinDark: 0x845436, hair: 0xd8d4cc, shirt: 0xb48ac2, shirtDark: 0x9a72a8, pants: 0x5a4a6a, curls: true },
  MAE: { skin: 0xa8714b, skinDark: 0x8f5d3d, hair: 0x1e1410, shirt: 0xd9a441, shirtDark: 0xbf8c30, pants: 0x3a3f5c, curls: false },
  PAI: { skin: 0x8f5d3d, skinDark: 0x7a4c30, hair: 0x120c08, shirt: 0x4f6d8f, shirtDark: 0x3f5a78, pants: 0x2c2c34, curls: true },
};
export function walk(k, ph, amt = 1) {
  const s = Math.sin(ph) * 0.55 * amt;
  k.legs[0].hip.rotation.x = s; k.legs[1].hip.rotation.x = -s;
  k.legs[0].knee.rotation.x = Math.max(0, -s) * 0.8; k.legs[1].knee.rotation.x = Math.max(0, s) * 0.8;
  k.arms.L.sh.rotation.x = -s * 0.7; k.arms.R.sh.rotation.x = s * 0.7;
  k.body.position.y = Math.abs(Math.cos(ph)) * 0.05 * amt;
}
// poses de braço calculadas para não atravessar o corpo (busca automática)
export function pray(k, a = 1) { // mãos quase juntas na frente do peito
  k.arms.R.sh.rotation.set(mix(-0.35, -1.4, a), 0, mix(0.08, -0.15, a)); k.arms.R.elbow.rotation.set(mix(-0.8, -0.2, a), 0, -0.8 * a);
  k.arms.L.sh.rotation.set(mix(-0.35, -1.4, a), 0, mix(-0.08, 0.15, a)); k.arms.L.elbow.rotation.set(mix(-0.8, -0.2, a), 0, 0.8 * a);
}
export function chestHand(k, a = 1) { // mão direita no peito
  k.arms.R.sh.rotation.set(mix(-0.35, -1.0, a), 0, mix(0.08, 0.2, a)); k.arms.R.elbow.rotation.set(mix(-0.8, -0.5, a), 0, -1.2 * a);
}
export function stand(k) { k.legs.forEach(l => { l.hip.rotation.x = 0; l.knee.rotation.x = 0; }); k.body.position.y = 0; Object.values(k.arms).forEach(a => { a.sh.rotation.set(0, 0, a === k.arms.R ? 0.08 : -0.08); a.elbow.rotation.set(0, 0, 0); }); }

// ---------- renderer + pós
export function setupRenderer() {
  const renderer = new THREE.WebGLRenderer({ antialias: true, preserveDrawingBuffer: true });
  renderer.setPixelRatio(1); renderer.setSize(RW, RH, false);
  Object.assign(renderer.domElement.style, { width: W + 'px', height: H + 'px' });
  renderer.toneMapping = THREE.ACESFilmicToneMapping; renderer.toneMappingExposure = 1.05;
  renderer.shadowMap.enabled = true; renderer.shadowMap.type = THREE.PCFSoftShadowMap;
  document.body.appendChild(renderer.domElement);
  const scene = new THREE.Scene();
  const camera = new THREE.PerspectiveCamera(40, W / H, 0.1, 400);
  return { renderer, scene, camera };
}
export function finish({ renderer, scene, camera }, update, T0, bloom = 0.5) {
  scene.traverse(o => { if (o.isMesh && !(o.material && o.material.transparent)) { o.castShadow = true; o.receiveShadow = true; } });
  const f0 = update(T0);
  scene.traverse(o => { if (o.isMesh && !(o.material && o.material.transparent)) { o.castShadow = true; o.receiveShadow = true; } });
  const rt = new THREE.WebGLRenderTarget(RW, RH, { samples: 0, type: THREE.HalfFloatType });
  const composer = new EffectComposer(renderer, rt);
  composer.addPass(new RenderPass(scene, camera));
  composer.addPass(new UnrealBloomPass(new THREE.Vector2(RW, RH), bloom, 0.55, 0.85));
  const bokeh = new BokehPass(scene, camera, { focus: camera.position.distanceTo(f0), aperture: 0.0016, maxblur: 0.008 });
  composer.addPass(bokeh); composer.addPass(new OutputPass());
  window.frame = (t) => { const f = update(t); bokeh.uniforms['focus'].value = camera.position.distanceTo(f); composer.render(); };
  window.__scene = scene; window.__update = update; window.__THREE = THREE;
  window.frame(T0); window.__ready = true;
}

// ---------- quarto com o Davi em várias poses
// e: parâmetros de expressão (hx, hy, hz, lean, brUp, brSad, eyes, lx, ly, tear, smile, wipe, knees, god, lamp, turn, laugh)
export function quartoRig(scene, camera) {
  const q = createQuarto(scene); q.calendar.visible = false; q.lamp.castShadow = false; // sombra do abajur custa 6 passadas por quadro
  const d = addSmile(createDavi()); scene.add(d.root);
  const blanket = rb(2.3, 0.32, 1.95, 0.12, std(0x3b5f8a, 0.95)); blanket.position.set(q.bed.x, 1.18, q.bed.z + 0.25); scene.add(blanket);
  const faceLight = new THREE.PointLight(0xffd9c2, 7, 5, 2); faceLight.position.set(1.0, 3.0, 0.2); scene.add(faceLight);
  const BED = V(q.bed.x - 0.3, 0.84, q.bed.z + 1.17), BEDROT = -0.45; // sentado em cima do colchão, sem afundar
  const FLOOR = V(-0.4, -0.05, -0.9);
  const WIN = V(q.window.x, q.window.y, q.window.z);
  const CAMS = {
    WIDE: [V(-0.3, 2.5, 6.8), V(0.4, 2.4, -2.2)], MED: [V(0.9, 2.45, 3.4), V(1.35, 2.25, -1.6)],
    CLOSE: [V(0.85, 2.72, 1.7), V(1.5, 2.55, -1.6)], CLOSE2: [V(2.35, 2.78, 1.75), V(1.55, 2.55, -1.6)],
    R3Q: [V(-0.4, 2.7, 2.4), V(1.5, 2.35, -1.6)],
  };
  const camMove = (A, B, k, pushA = 0, pushB = 0) => {
    const [pa, la] = CAMS[A], [pb, lb] = CAMS[B];
    const p = pa.clone().lerp(pb, k), l = la.clone().lerp(lb, k);
    const dir = l.clone().sub(p).normalize(); p.addScaledVector(dir, mix(pushA, pushB, k));
    camera.up.set(0, 1, 0); camera.position.copy(p); camera.lookAt(l); return l;
  };
  // câmera "de frente" para a cabeça do Davi (funciona em qualquer pose)
  const faceCam = (dist, side = 0, up = 0.1, lookDown = 0) => {
    d.root.updateMatrixWorld(true);
    const q4 = d.head.getWorldQuaternion(new THREE.Quaternion()), h = headW(d);
    const f = V(0, 0, 1).applyQuaternion(q4), s = V(1, 0, 0).applyQuaternion(q4), u = V(0, 1, 0).applyQuaternion(q4);
    camera.position.copy(h).addScaledVector(f, dist).addScaledVector(s, side).addScaledVector(u, up);
    camera.up.copy(u); camera.lookAt(h.clone().addScaledVector(u, -lookDown)); return h;
  };
  const arms = (e, T) => {
    const R = d.arms.R, L = d.arms.L, k = e.knees || 0, w = e.wipe || 0;
    R.sh.rotation.set(mix(mix(-0.35, -0.95, k), -1.6, w), 0, mix(0.08, -0.2, w));
    R.elbow.rotation.set(mix(mix(-0.8, -1.35, k), -0.2 + Math.sin(T * 6) * 0.08 * w, w), 0, 0);
    L.sh.rotation.set(mix(-0.35, -0.95, k), 0, -0.08); L.elbow.rotation.x = mix(-0.8, -1.35, k);
  };
  const face = (e, T, talk) => {
    setFace(d, { open: e.eyes * blink(T), talk, browUp: e.brUp, browSad: e.brSad, look: [e.lx, e.ly] });
    d.setSmile(talk < 0.06 && (e.smile || 0) > 0.5);
    d.tears.forEach(t => { t.visible = (e.tear || 0) > 0.05; t.scale.setScalar(0.4 + 0.6 * (e.tear || 0)); t.scale.y *= 1.4; t.position.y = -0.12; });
  };
  const pose = (mode, e, T, talk) => {
    blanket.visible = mode === 'lying';
    d.body.rotation.set(0, 0, 0); d.body.position.set(0, 0, 0); d.root.rotation.set(0, 0, 0);
    if (mode === 'bed') {
      setSitting(d, 1); d.root.position.copy(BED); d.root.rotation.y = BEDROT;
      const lg = (e.laugh || 0) * Math.abs(Math.sin(T * 16));
      d.body.rotation.x = (e.lean || 0); d.body.position.y += Math.sin(T * 1.6) * 0.006 + lg * 0.03;
      d.head.rotation.set((e.hx + Math.sin(T * 0.9) * 0.015) * (1 - (e.wipe || 0)), e.hy, e.hz);
      arms(e, T);
    } else if (mode === 'floor') {
      // sentado no chão abraçando os joelhos; "turn" gira o corpo para a janela
      setSitting(d, 0);
      const k = e.knees ?? 1;
      d.legs.forEach(({ hip, knee }) => { hip.rotation.x = mix(-1.5, -2.25, k); knee.rotation.x = mix(1.5, 2.3, k); });
      d.body.position.y = -0.78 + 0.33; d.body.rotation.x = 0.12 * k + (e.lean || 0);
      d.root.position.copy(FLOOR); d.root.rotation.y = mix(0.25, -2.55, e.turn || 0);
      d.head.rotation.set(e.hx + Math.sin(T * 0.9) * 0.015, e.hy, e.hz);
      const R = d.arms.R, L = d.arms.L, w = e.wipe || 0;
      R.sh.rotation.set(mix(mix(-0.4, -1.25, k), -1.8, w), 0, mix(0.12, -0.2, w)); R.elbow.rotation.set(mix(mix(-0.6, -1.1, k), -0.2 + Math.sin(T * 6) * 0.08 * w, w), 0, 0);
      L.sh.rotation.set(mix(-0.4, -1.25, k), 0, -0.12); L.elbow.rotation.x = mix(-0.6, -1.1, k);
    } else if (mode === 'lying') {
      setSitting(d, 0);
      d.legs.forEach(({ hip, knee }) => { hip.rotation.x = -0.25; knee.rotation.x = 0.35; }); // pernas esticadas sob a coberta
      d.root.rotation.set(-Math.PI / 2, 0, 0); d.root.position.set(q.bed.x, 1.42, q.bed.z + 1.75);
      d.head.rotation.set(-0.2, 0.15 + (e.hy0 || 0) + Math.sin(T * 0.5) * 0.03, 0);
      Object.values(d.arms).forEach(a => { a.sh.rotation.set(0, 0, 0); a.elbow.rotation.set(0, 0, 0); });
    }
    face(e, T, talk);
  };
  // câmera para o Davi deitado (de frente para o rosto)
  const lyingCam = (dist, k = 0) => {
    d.root.updateMatrixWorld(true);
    const hp = headW(d), q4 = d.head.getWorldQuaternion(new THREE.Quaternion());
    const nF = V(0, 0, 1).applyQuaternion(q4), nU = V(0, 1, 0).applyQuaternion(q4);
    const near = hp.clone().addScaledVector(nF, dist).addScaledVector(nU, -0.9).add(V(0.4, 0, 0)), far = V(-0.8, 4.6, 4.0);
    faceLight.position.copy(hp).addScaledVector(nF, 1.4).add(V(0.4, 0.3, 0)); faceLight.intensity = 3.5;
    camera.position.copy(near.clone().lerp(far, k)); camera.up.copy(nU.clone().lerp(V(0, 1, 0), smooth(k * 1.5)).normalize());
    camera.lookAt(hp.clone().addScaledVector(nU, -0.25).lerp(V(0, 2.5, -3.5), 0.25 * k));
    return hp;
  };
  return { q, d, blanket, faceLight, CAMS, camMove, faceCam, lyingCam, pose, WIN, FLOOR, BED };
}
