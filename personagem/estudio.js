// Estúdio compartilhado: mesa, notebook, estante ao fundo, luzes e pós-processamento.
// Cada cena passa o desenho da tela e posiciona câmera e mascote.
import * as THREE from 'three';
import { RoundedBoxGeometry } from 'three/addons/geometries/RoundedBoxGeometry.js';
import { RectAreaLightUniformsLib } from 'three/addons/lights/RectAreaLightUniformsLib.js';
import { EffectComposer } from 'three/addons/postprocessing/EffectComposer.js';
import { RenderPass } from 'three/addons/postprocessing/RenderPass.js';
import { UnrealBloomPass } from 'three/addons/postprocessing/UnrealBloomPass.js';
import { BokehPass } from 'three/addons/postprocessing/BokehPass.js';
import { OutputPass } from 'three/addons/postprocessing/OutputPass.js';
import { makeStar } from './mascote.js';

export const W = 1080, H = 1920;
export const KEY_TOP = 0.7;
const PITCH = 1.16, COLS = 12;

const rb = (w, h, d, r, m, seg = 4) => new THREE.Mesh(new RoundedBoxGeometry(w, h, d, seg, r), m);
const std = (color, roughness = 0.6, extra = {}) => new THREE.MeshStandardMaterial({ color, roughness, ...extra });

export function keyPos(r, k) {
  return new THREE.Vector3((k - (COLS - 1) / 2) * PITCH + (r % 2) * 0.25, KEY_TOP, -4.0 + r * PITCH);
}

export function createStudio({ drawScreen, screenIntensity = 0.9, screenLight = 2.2, exposure = 0.85, pressedKey = null, showMug = true, screenScale = 1.5, shadowSize = 2048 }) {
  const renderer = new THREE.WebGLRenderer({ antialias: true, preserveDrawingBuffer: true });
  renderer.setPixelRatio(1); renderer.setSize(W, H);
  renderer.toneMapping = THREE.ACESFilmicToneMapping; renderer.toneMappingExposure = exposure;
  renderer.shadowMap.enabled = true; renderer.shadowMap.type = THREE.PCFSoftShadowMap;
  document.body.appendChild(renderer.domElement);
  RectAreaLightUniformsLib.init();

  const scene = new THREE.Scene();
  scene.background = new THREE.Color(0x0a0706);
  scene.fog = new THREE.Fog(0x0a0706, 22, 50);

  // Mesa
  const desk = new THREE.Mesh(new THREE.BoxGeometry(80, 0.4, 50), new THREE.MeshPhysicalMaterial({ color: 0x1a1412, roughness: 0.35, clearcoat: 0.5 }));
  desk.position.y = -0.2; scene.add(desk);

  // Notebook
  const laptop = new THREE.Group();
  const alu = new THREE.MeshPhysicalMaterial({ color: 0x2a272d, metalness: 0.7, roughness: 0.32, clearcoat: 0.4 });
  const base = rb(17, 0.45, 11.5, 0.2, alu); base.position.set(0, 0.225, 0); laptop.add(base);
  const well = new THREE.Mesh(new THREE.BoxGeometry(15.4, 0.04, 6.6), std(0x0b0a0c, 0.8));
  well.position.set(0, 0.45, -1.2); laptop.add(well);
  const pad = rb(5.5, 0.03, 3.2, 0.1, new THREE.MeshPhysicalMaterial({ color: 0x232026, metalness: 0.5, roughness: 0.4 }));
  pad.position.set(0, 0.45, 3.9); laptop.add(pad);

  const keyMat = new THREE.MeshPhysicalMaterial({ color: 0x141216, roughness: 0.6, clearcoat: 0.1 });
  const rows = ['1234567890-=', 'QWERTYUIOP[]', 'ASDFGHJKLÇ;\'', 'ZXCVBNM,.;/↑'];
  const legendTex = (ch) => {
    const c = document.createElement('canvas'); c.width = c.height = 64;
    const g = c.getContext('2d'); g.fillStyle = '#fff'; g.font = 'bold 30px DejaVu Sans, Arial';
    g.textAlign = 'center'; g.textBaseline = 'middle'; g.fillText(ch, 32, 34);
    return new THREE.CanvasTexture(c);
  };
  const pressed = {};
  for (let r = 0; r < 4; r++) for (let k = 0; k < COLS; k++) {
    const p = keyPos(r, k);
    const isPressed = pressedKey && pressedKey[0] === r && pressedKey[1] === k;
    const m = isPressed ? keyMat.clone() : keyMat;
    if (isPressed) { m.emissive = new THREE.Color(0xff6a20); m.emissiveIntensity = 1.4; }
    const key = rb(1.0, 0.24, 1.0, 0.07, m);
    key.position.set(p.x, isPressed ? 0.5 : 0.58, p.z); laptop.add(key);
    if (isPressed) pressed.key = key, pressed.mat = m;
    const lg = new THREE.Mesh(new THREE.PlaneGeometry(0.42, 0.42), new THREE.MeshBasicMaterial({
      map: legendTex(rows[r][k]), transparent: true, opacity: isPressed ? 1 : 0.35, color: isPressed ? 0xffb070 : 0xffffff,
    }));
    lg.rotation.x = -Math.PI / 2; lg.position.set(p.x, key.position.y + 0.121, p.z); laptop.add(lg);
    if (isPressed) {
      const kl = new THREE.PointLight(0xff7a2a, 9, 4, 2); kl.position.set(p.x, 0.8, p.z + 0.3); laptop.add(kl);
      pressed.light = kl; pressed.legend = lg; pressed.pos = p;
    }
  }
  const spaceZ = -4.0 + 4 * PITCH;
  const space = rb(6.8, 0.24, 1.0, 0.07, keyMat); space.position.set(0, 0.58, spaceZ); laptop.add(space);
  for (const x of [-6.0, -4.6, 4.6, 6.0]) { const k = rb(1.2, 0.24, 1.0, 0.07, keyMat); k.position.set(x, 0.58, spaceZ); laptop.add(k); }

  // Tela
  const c = document.createElement('canvas'); c.width = 1600 * screenScale; c.height = 1000 * screenScale;
  const g = c.getContext('2d'); g.scale(screenScale, screenScale);
  drawScreen(g, 1600, 1000);
  const redraw = (draw) => { g.setTransform(screenScale, 0, 0, screenScale, 0, 0); g.clearRect(0, 0, 1600, 1000); draw(g, 1600, 1000); screenTex.needsUpdate = true; };
  const screenTex = new THREE.CanvasTexture(c);
  screenTex.colorSpace = THREE.SRGBColorSpace; screenTex.anisotropy = 16;
  const lid = new THREE.Group();
  const lidBody = rb(17, 11, 0.35, 0.2, alu); lidBody.position.y = 5.5; lid.add(lidBody);
  const bezel = new THREE.Mesh(new THREE.PlaneGeometry(16.4, 10.4), std(0x050405, 0.3)); bezel.position.set(0, 5.5, 0.18); lid.add(bezel);
  const display = new THREE.Mesh(new THREE.PlaneGeometry(15.6, 9.75),
    new THREE.MeshStandardMaterial({ color: 0x000000, roughness: 0.25, emissive: 0xffffff, emissiveMap: screenTex, emissiveIntensity: screenIntensity }));
  display.position.set(0, 5.5, 0.185); lid.add(display);
  lid.position.set(0, 0.45, -5.75); lid.rotation.x = -0.22;
  laptop.add(lid);
  scene.add(laptop);

  // ponto da tela em coordenadas do canvas (0..1600, 0..1000) -> mundo
  const screenPoint = (u, v) => display.localToWorld(new THREE.Vector3((u / 1600 - 0.5) * 15.6, (0.5 - v / 1000) * 9.75, 0));

  const sl = new THREE.RectAreaLight(0xffc49a, screenLight, 15.6, 9.75);
  sl.position.set(0, 5.9, -5.0); sl.lookAt(0, 1.5, 2); scene.add(sl);

  // Fundo: estante, fitas de LED e monitor secundário
  const shelf = new THREE.Group();
  const wood = std(0x140f0d, 0.8);
  for (const y of [0, 4, 8, 12, 16]) { const s = new THREE.Mesh(new THREE.BoxGeometry(60, 0.25, 2), wood); s.position.y = y; shelf.add(s); }
  const bookCols = [0x5a2a1a, 0x8a3c1c, 0x2a2228, 0x3c2a22, 0xb5561f, 0x1e1a22, 0x6e4a32];
  let i = 0;
  for (const row of [0.12, 4.12, 8.12, 12.12]) {
    let x = -29.5;
    while (x < 29) {
      const w = 0.45 + ((i * 37) % 10) / 22, h = 2.4 + ((i * 53) % 9) / 8;
      const b = new THREE.Mesh(new THREE.BoxGeometry(w, h, 1.5), std(bookCols[(i * 3) % bookCols.length], 0.7));
      b.position.set(x + w / 2, row + h / 2, 0); shelf.add(b);
      x += w + 0.06; i++; if (i % 9 === 0) x += 1.6;
    }
  }
  const led = new THREE.MeshStandardMaterial({ color: 0xff8a40, emissive: 0xff6a20, emissiveIntensity: 4 });
  for (const y of [3.85, 7.85, 11.85, 15.85]) { const l = new THREE.Mesh(new THREE.BoxGeometry(60, 0.06, 0.06), led); l.position.set(0, y, 1.0); shelf.add(l); }
  shelf.position.set(-2, -1, -26);
  scene.add(shelf);
  const mon = rb(9, 5.5, 0.4, 0.2, std(0x0c0a0b, 0.4)); mon.position.set(-14, 7, -18); mon.rotation.y = 0.4; scene.add(mon);
  const frame = new THREE.Mesh(new THREE.BoxGeometry(8.4, 0.08, 0.1), led); frame.position.set(-14, 9.5, -17.7); frame.rotation.y = 0.4; scene.add(frame);

  if (showMug) {
    const mug = new THREE.Group();
    const mm = new THREE.MeshPhysicalMaterial({ color: 0x141215, roughness: 0.35, clearcoat: 0.8 });
    const cyl = rb(1.6, 1.9, 1.6, 0.25, mm); cyl.position.y = 0.95; mug.add(cyl);
    const handle = new THREE.Mesh(new THREE.TorusGeometry(0.5, 0.14, 12, 24), mm); handle.position.set(1.0, 1.0, 0); mug.add(handle);
    const st = makeStar(0.35, new THREE.MeshStandardMaterial({ color: 0xff9a50, emissive: 0xff6a20, emissiveIntensity: 2.5 }), 0.03);
    st.position.set(0, 1.05, 0.82); mug.add(st);
    mug.position.set(10.5, 0, 3.5); mug.rotation.y = -0.4;
    scene.add(mug);
  }

  // Luzes
  scene.add(new THREE.HemisphereLight(0x6a4a3a, 0x0a0706, 0.35));
  const key = new THREE.SpotLight(0xffa066, 45, 34, 0.35, 0.9, 1.6);
  key.position.set(5, 8, 10); key.target.position.set(0, 1.6, 0);
  key.castShadow = true; key.shadow.mapSize.set(shadowSize, shadowSize); key.shadow.bias = -0.0004; key.shadow.normalBias = 0.02;
  scene.add(key, key.target);
  const rim = new THREE.DirectionalLight(0xff8a40, 2.2); rim.position.set(-6, 5, -8); scene.add(rim);
  const fill = new THREE.PointLight(0xffc29a, 32, 14, 2); fill.position.set(6, 4, 8); scene.add(fill);
  const cool = new THREE.DirectionalLight(0x5a78ff, 0.5); cool.position.set(8, 3, -4); scene.add(cool);

  function makeComposer(camera, focusPoint, { aperture = 0.0018, maxblur = 0.01, bloom = 0.5, samples = 4 } = {}) {
    scene.traverse(o => { if (o.isMesh) { o.castShadow = true; o.receiveShadow = true; } });
    const rt = new THREE.WebGLRenderTarget(W, H, { samples, type: THREE.HalfFloatType });
    const composer = new EffectComposer(renderer, rt);
    composer.addPass(new RenderPass(scene, camera));
    composer.addPass(new UnrealBloomPass(new THREE.Vector2(W, H), bloom, 0.5, 0.9));
    const bokeh = new BokehPass(scene, camera, { focus: camera.position.distanceTo(focusPoint), aperture, maxblur });
    composer.addPass(bokeh);
    composer.addPass(new OutputPass());
    return { composer, bokeh };
  }

  function render(camera, focusPoint, { aperture = 0.0018, maxblur = 0.01, bloom = 0.5 } = {}) {
    scene.traverse(o => { if (o.isMesh) { o.castShadow = true; o.receiveShadow = true; } });
    display.castShadow = false;
    const rt = new THREE.WebGLRenderTarget(W, H, { samples: 4, type: THREE.HalfFloatType });
    const composer = new EffectComposer(renderer, rt);
    composer.addPass(new RenderPass(scene, camera));
    composer.addPass(new UnrealBloomPass(new THREE.Vector2(W, H), bloom, 0.5, 0.9));
    composer.addPass(new BokehPass(scene, camera, { focus: camera.position.distanceTo(focusPoint), aperture, maxblur }));
    composer.addPass(new OutputPass());
    composer.render();
    requestAnimationFrame(() => { composer.render(); window.__done = true; });
  }

  return { scene, renderer, laptop, display, screenPoint, screenLightRect: sl, key, fill, rim, pressed, redraw, render, makeComposer };
}
