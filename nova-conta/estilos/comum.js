// Utilidades dos estilos novos (independentes do pipeline do Davi).
import * as THREE from 'three';
import { mergeVertices } from 'three/addons/utils/BufferGeometryUtils.js';
// ruído de valor 3D simples e determinístico
const h = (x, y, z) => { const s = Math.sin(x * 127.1 + y * 311.7 + z * 74.7) * 43758.5453; return s - Math.floor(s); };
const lerp = (a, b, t) => a + (b - a) * t, sm = t => t * t * (3 - 2 * t);
export function noise3(x, y, z) {
  const xi = Math.floor(x), yi = Math.floor(y), zi = Math.floor(z), xf = sm(x - xi), yf = sm(y - yi), zf = sm(z - zi);
  const c = (a, b, d) => h(xi + a, yi + b, zi + d);
  return lerp(lerp(lerp(c(0,0,0), c(1,0,0), xf), lerp(c(0,1,0), c(1,1,0), xf), yf),
              lerp(lerp(c(0,0,1), c(1,0,1), xf), lerp(c(0,1,1), c(1,1,1), xf), yf), zf);
}
// desloca vértices ao longo da normal (massinha: amp baixa/freq baixa; papel amassado: amp alta)
export function deform(geo, amp, freq, seed = 0) {
  if (!geo.index) { geo.deleteAttribute('normal'); geo.deleteAttribute('uv'); geo = mergeVertices(geo); } // poliedros: junta vértices para não rachar
  const p = geo.attributes.position, v = new THREE.Vector3(), n = new THREE.Vector3();
  geo.computeVertexNormals(); const nn = geo.attributes.normal;
  for (let i = 0; i < p.count; i++) {
    v.fromBufferAttribute(p, i); n.fromBufferAttribute(nn, i);
    const k = (noise3(v.x * freq + seed, v.y * freq, v.z * freq) - 0.5) * 2 * amp;
    p.setXYZ(i, v.x + n.x * k, v.y + n.y * k, v.z + n.z * k);
  }
  geo.computeVertexNormals(); return geo;
}
// textura de ruído para bumpMap (digitais da massinha / fibra do papel)
export function noiseTex(size = 256, scale = 24, fibras = false) {
  const c = document.createElement('canvas'); c.width = c.height = size; const g = c.getContext('2d');
  const img = g.createImageData(size, size);
  for (let y = 0; y < size; y++) for (let x = 0; x < size; x++) {
    let v = noise3(x / scale, y / scale, 0) * 0.6 + noise3(x / 4, y / 4, 9) * 0.4;
    if (fibras) v = 0.7 + 0.3 * noise3(x / 1.5, y / 40, 3);
    const i = (y * size + x) * 4; img.data[i] = img.data[i + 1] = img.data[i + 2] = v * 255; img.data[i + 3] = 255;
  }
  g.putImageData(img, 0, 0);
  const t = new THREE.CanvasTexture(c); t.wrapS = t.wrapT = THREE.RepeatWrapping; return t;
}
export function setup(W = 1080, H = 1920) {
  const renderer = new THREE.WebGLRenderer({ antialias: true, preserveDrawingBuffer: true });
  renderer.setPixelRatio(1); renderer.setSize(W, H);
  renderer.toneMapping = THREE.ACESFilmicToneMapping; renderer.shadowMap.enabled = true; renderer.shadowMap.type = THREE.PCFSoftShadowMap;
  document.body.appendChild(renderer.domElement);
  return { renderer, scene: new THREE.Scene() };
}
