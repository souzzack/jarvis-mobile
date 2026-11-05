// Interfaces de software desenhadas em canvas (1600 × 1000) para a tela do notebook.

let seed = 7;
const rnd = () => { seed = (seed * 16807) % 2147483647; return seed / 2147483647; };

function rr(g, x, y, w, h, r, fill, stroke, lw = 2) {
  g.beginPath(); g.roundRect(x, y, w, h, r);
  if (fill) { g.fillStyle = fill; g.fill(); }
  if (stroke) { g.strokeStyle = stroke; g.lineWidth = lw; g.stroke(); }
}
function txt(g, s, x, y, size, color, weight = 'normal', align = 'left') {
  g.font = `${weight} ${size}px DejaVu Sans, Arial`; g.fillStyle = color; g.textAlign = align; g.textBaseline = 'middle';
  g.fillText(s, x, y);
}

const PALETTES = {
  graded: { sky: ['#1d2748', '#7a3b52', '#ff8a4c'], sun: '#ffd58a', far: '#6b3f5e', mid: '#3d2342', near: '#160d1a', water: ['#ff9a5a', '#5a2c48'] },
  raw: { sky: ['#9a9b98', '#a8a69f', '#b7b2a6'], sun: '#dcd6c8', far: '#8a8a86', mid: '#737470', near: '#5d5e59', water: ['#a9a69e', '#8c8c87'] },
  dusk: { sky: ['#07060c', '#2a1424', '#c4532a'], sun: '#ffb46a', far: '#3a1e2c', mid: '#1f1019', near: '#08050a', water: ['#e0703a', '#2a1220'] },
};

// Paisagem de fim de tarde (usada como "frame de vídeo")
export function landscape(g, x, y, w, h, mode = 'graded', variant = 0) {
  const P = PALETTES[mode];
  g.save(); g.beginPath(); g.rect(x, y, w, h); g.clip();
  const sky = g.createLinearGradient(0, y, 0, y + h * 0.62);
  sky.addColorStop(0, P.sky[0]); sky.addColorStop(0.6, P.sky[1]); sky.addColorStop(1, P.sky[2]);
  g.fillStyle = sky; g.fillRect(x, y, w, h);
  const sx = x + w * (0.6 + variant * 0.07), sy = y + h * 0.55, sr = h * 0.1;
  if (mode !== 'raw') {
    const glow = g.createRadialGradient(sx, sy, sr * 0.5, sx, sy, sr * 5);
    glow.addColorStop(0, 'rgba(255,190,110,0.55)'); glow.addColorStop(1, 'rgba(255,140,60,0)');
    g.fillStyle = glow; g.fillRect(x, y, w, h);
  }
  g.fillStyle = P.sun; g.beginPath(); g.arc(sx, sy, sr, 0, Math.PI * 2); g.fill();
  const ridge = (base, amp, freq, phase, col) => {
    g.fillStyle = col; g.beginPath(); g.moveTo(x, y + h);
    for (let i = 0; i <= 60; i++) {
      const px = x + (w * i) / 60;
      g.lineTo(px, y + h * base - Math.abs(Math.sin(i * freq + phase)) * h * amp - Math.sin(i * freq * 2.3 + phase) * h * amp * 0.3);
    }
    g.lineTo(x + w, y + h); g.closePath(); g.fill();
  };
  ridge(0.6, 0.12, 0.21, 1 + variant, P.far);
  const water = g.createLinearGradient(0, y + h * 0.6, 0, y + h * 0.78);
  water.addColorStop(0, P.water[0]); water.addColorStop(1, P.water[1]);
  g.fillStyle = water; g.fillRect(x, y + h * 0.6, w, h * 0.18);
  if (mode !== 'raw') { g.fillStyle = 'rgba(255,220,160,0.5)'; for (let i = 0; i < 6; i++) g.fillRect(sx - 40 + i * 9 - w * 0.02, y + h * (0.63 + i * 0.022), 80 - i * 10, 2); }
  ridge(0.8, 0.08, 0.13, 2.5 + variant, P.mid);
  ridge(0.92, 0.05, 0.09, 0.7, P.near);
  // pessoa em silhueta sobre a colina
  const px = x + w * 0.3, py = y + h * 0.84;
  g.fillStyle = P.near;
  g.beginPath(); g.arc(px, py - h * 0.13, h * 0.022, 0, Math.PI * 2); g.fill();
  g.fillRect(px - h * 0.022, py - h * 0.11, h * 0.044, h * 0.1);
  g.restore();
}

function chrome(g, W, H, title) {
  g.fillStyle = '#0e0c0f'; g.fillRect(0, 0, W, H);
  g.fillStyle = '#1b181c'; g.fillRect(0, 0, W, 44);
  [['#ff5f57', 24], ['#febc2e', 48], ['#28c840', 72]].forEach(([c, x]) => { g.fillStyle = c; g.beginPath(); g.arc(x, 22, 7, 0, 7); g.fill(); });
  ['Arquivo', 'Editar', 'Clipe', 'Sequência', 'Exibir'].forEach((m, i) => txt(g, m, 110 + i * 92, 22, 15, '#8d8690'));
  txt(g, title, W / 2, 22, 16, '#d9d2d6', 'bold', 'center');
}
const panel = (g, x, y, w, h, title) => {
  rr(g, x, y, w, h, 8, '#18151a', '#2a252c', 1.5);
  if (title) { txt(g, title, x + 14, y + 20, 15, '#cfc6cc', 'bold'); g.fillStyle = '#2a252c'; g.fillRect(x, y + 38, w, 1.5); }
};
function waveform(g, x, y, w, h, color, density = 3) {
  g.fillStyle = color;
  for (let i = 0; i < w; i += density) {
    const a = (0.25 + 0.75 * Math.abs(Math.sin(i * 0.05) * rnd())) * h * 0.45;
    g.fillRect(x + i, y + h / 2 - a, Math.max(1, density - 1), a * 2);
  }
}
function videoClip(g, x, y, w, h, name, variant, selected = false) {
  rr(g, x, y, w, h, 5, '#2b3b6a');
  g.save(); g.beginPath(); g.roundRect(x + 2, y + 18, w - 4, h - 20, 3); g.clip();
  const tw = (h - 20) * 1.78;
  for (let px = x + 2; px < x + w; px += tw + 2) landscape(g, px, y + 18, tw, h - 20, 'graded', variant);
  g.restore();
  txt(g, name, x + 8, y + 10, 12, '#e6e9f5');
  if (selected) {
    rr(g, x - 1, y - 1, w + 2, h + 2, 6, null, '#ff8a3d', 3);
    g.fillStyle = '#ff8a3d'; g.fillRect(x - 4, y + 8, 6, h - 16); g.fillRect(x + w - 2, y + 8, 6, h - 16);
  }
}
function transport(g, cx, cy, color = '#d9d2d6') {
  g.fillStyle = color;
  const tri = (x, y, s, dir = 1) => { g.beginPath(); g.moveTo(x, y - s); g.lineTo(x, y + s); g.lineTo(x + dir * s * 1.4, y); g.closePath(); g.fill(); };
  tri(cx - 60, cy, 8, -1); g.fillRect(cx - 74, cy - 8, 3, 16);
  tri(cx - 8, cy, 12);
  tri(cx + 52, cy, 8); g.fillRect(cx + 66, cy - 8, 3, 16);
}
function ruler(g, x0, x1, y, labels, step) {
  g.fillStyle = '#141116'; g.fillRect(x0, y, x1 - x0, 28);
  g.fillStyle = '#5f5763';
  for (let x = x0, i = 0; x <= x1; x += step / 5, i++) g.fillRect(x, y + (i % 5 === 0 ? 8 : 18), 1.5, i % 5 === 0 ? 20 : 10);
  labels.forEach((l, i) => txt(g, l, x0 + 6 + i * step, y + 10, 11, '#8d8690'));
}

// ===== Cena 02: timeline organizada =====
export function telaTimeline(g, W, H, o = {}) {
  seed = 11;
  chrome(g, W, H, 'Projeto — Sequência 01');
  // Biblioteca de mídia
  panel(g, 12, 56, 300, 470, 'Mídia');
  const files = ['entrevista_01', 'entrevista_02', 'broll_praia', 'broll_cidade', 'drone_01', 'trilha'];
  files.forEach((f, i) => {
    const x = 26 + (i % 2) * 142, y = 108 + Math.floor(i / 2) * 136;
    if (f === 'trilha') { rr(g, x, y, 128, 72, 4, '#1f3a2c'); waveform(g, x + 6, y + 10, 116, 52, '#5fd39a', 3); }
    else landscape(g, x, y, 128, 72, 'graded', i * 0.4);
    txt(g, f + (f === 'trilha' ? '.wav' : '.mp4'), x, y + 88, 11, '#a39aa1');
  });
  // Visualizador
  panel(g, 324, 56, 952, 470);
  g.fillStyle = '#000'; g.fillRect(336, 66, 928, 400);
  landscape(g, 444, 70, 712, 392, 'graded', 0.2);
  txt(g, '00:00:12:08', 350, 494, 16, '#ff9a55', 'bold');
  transport(g, 800, 494);
  txt(g, 'Ajustar ▾', 1260, 494, 14, '#a39aa1', 'normal', 'right');
  // Inspetor
  panel(g, 1288, 56, 300, 470, 'Inspetor');
  [['Posição', '960, 540', 0.5], ['Escala', '100%', 0.62], ['Rotação', '0,0°', 0.5], ['Opacidade', '100%', 1], ['Volume', '-6 dB', 0.7]].forEach(([k, v, f], i) => {
    const y = 120 + i * 74;
    txt(g, k, 1304, y, 14, '#a39aa1'); txt(g, v, 1572, y, 14, '#e8e0e4', 'normal', 'right');
    rr(g, 1304, y + 20, 268, 6, 3, '#2a252c'); rr(g, 1304, y + 20, 268 * f, 6, 3, '#ff8a3d');
  });
  // Linha do tempo
  panel(g, 12, 538, 1576, 450);
  ['↖', '✂', '↔', '⌖'].forEach((t, i) => {
    rr(g, 24 + i * 40, 548, 32, 28, 5, i === 1 ? '#ff8a3d' : '#262128');
    txt(g, t, 40 + i * 40, 562, 15, i === 1 ? '#1a1013' : '#cfc6cc', 'bold', 'center');
  });
  txt(g, '00:00:12:08', 1572, 562, 15, '#ff9a55', 'bold', 'right');
  const X0 = 120, X1 = 1576;
  ruler(g, X0, X1, 586, ['00:00', '00:05', '00:10', '00:15', '00:20', '00:25', '00:30', '00:35', '00:40', '00:45'], 160);
  const tracks = [['V2', 622, 52], ['V1', 680, 92], ['A1', 778, 70], ['A2', 854, 70]];
  tracks.forEach(([n, y, h]) => {
    rr(g, 20, y, 92, h, 4, '#211d23'); txt(g, n, 34, y + h / 2, 14, '#cfc6cc', 'bold');
    g.fillStyle = '#151217'; g.fillRect(X0, y, X1 - X0, h);
  });
  // V2: títulos
  rr(g, 300, 626, 300, 44, 5, '#6a3fa0'); txt(g, 'T  Título', 312, 648, 13, '#f1e9ff');
  rr(g, 1010, 626, 260, 44, 5, '#6a3fa0'); txt(g, 'T  Legenda final', 1022, 648, 13, '#f1e9ff');
  // V1: clipes de vídeo com cortes
  const v1 = [[X0, 250, 'entrevista_01', 0], [X0 + 254, 190, 'broll_praia', 0.6], [X0 + 448, 300, 'entrevista_01', 0.1], [X0 + 752, 170, 'drone_01', 1.1], [X0 + 926, 280, 'entrevista_02', 0.3], [X0 + 1210, 240, 'broll_cidade', 0.8]];
  // o.arrange: 0 = clipes espalhados, 1 = organizados (cada clipe desliza e "encaixa")
  const ar = o.arrange ?? 1;
  const SCAT = [[560, 1], [-120, -1], [380, 1], [-520, 0], [200, -1], [-340, 1]];
  const ease = (x) => { x = Math.min(1, Math.max(0, x)); const c = 1.7; return 1 + (c + 1) * Math.pow(x - 1, 3) + c * Math.pow(x - 1, 2); };
  const off = v1.map((_, i) => { const e = ease(ar * 1.7 - i * 0.14); return [SCAT[i][0] * (1 - e), SCAT[i][1] * 96 * (1 - Math.min(1, e))]; });
  v1.forEach(([x, w, n, v], i) => videoClip(g, x + off[i][0], 684 + off[i][1], w, 84, n, v, ar >= 1 && i === 2));
  // A1: diálogo alinhado aos clipes
  [[X0, 250, 0], [X0 + 448, 300, 2], [X0 + 926, 280, 4]].forEach(([x, w, i]) => { x += off[i][0]; rr(g, x, 782, w, 62, 5, '#1f4a35'); waveform(g, x + 4, 784, w - 8, 58, '#62d69c'); });
  // A2: trilha contínua com fade
  rr(g, X0, 858, 1450, 62, 5, '#1d3b5c'); waveform(g, X0 + 4, 860, 1442, 58, '#6cb3ff', 4);
  g.strokeStyle = '#ffffff'; g.lineWidth = 2; g.beginPath(); g.moveTo(X0 + 1300, 862); g.lineTo(X0 + 1446, 916); g.stroke();
  // marcadores de corte e cabeçote
  [X0 + 252, X0 + 446, X0 + 750, X0 + 924, X0 + 1208].forEach(x => {
    g.fillStyle = '#ffb36b'; g.beginPath(); g.moveTo(x - 6, 590); g.lineTo(x + 6, 590); g.lineTo(x, 600); g.fill();
  });
  const ph = X0 + (o.ph ?? 610);
  g.fillStyle = '#ff5a36'; g.fillRect(ph - 1, 590, 3, 340);
  g.beginPath(); g.moveTo(ph - 9, 586); g.lineTo(ph + 10, 586); g.lineTo(ph + 1, 600); g.fill();
  // zoom
  rr(g, 1380, 952, 190, 6, 3, '#2a252c'); g.fillStyle = '#cfc6cc'; g.beginPath(); g.arc(1460, 955, 8, 0, 7); g.fill();
}

// ===== Cena 03: projeto de motion design =====
function drinkCan(g, cx, cy, s, alpha = 1) {
  g.save(); g.globalAlpha = alpha; g.translate(cx, cy); g.rotate(-0.08);
  const body = g.createLinearGradient(-55 * s, 0, 55 * s, 0);
  body.addColorStop(0, '#8d8f96'); body.addColorStop(0.35, '#f4f5f7'); body.addColorStop(0.6, '#c3c6cc'); body.addColorStop(1, '#6d7077');
  rr(g, -55 * s, -110 * s, 110 * s, 220 * s, 18 * s, body);
  const lab = g.createLinearGradient(-55 * s, 0, 55 * s, 0);
  lab.addColorStop(0, '#b63a1a'); lab.addColorStop(0.4, '#ff7a3d'); lab.addColorStop(1, '#8e2a12');
  g.fillStyle = lab; g.fillRect(-55 * s, -60 * s, 110 * s, 120 * s);
  g.fillStyle = 'rgba(255,255,255,0.85)';
  g.beginPath(); g.ellipse(0, 0, 26 * s, 26 * s, 0, 0, 7); g.fill();
  g.fillStyle = '#ff7a3d'; g.beginPath(); g.ellipse(0, 0, 14 * s, 14 * s, 0, 0, 7); g.fill();
  g.restore();
}
export function telaMotion(g, W, H, o = {}) {
  const tt = o.title ?? 1, bd = o.badge ?? 1, cp = o.caption ?? 1, sp = o.sparkle ?? 0;
  seed = 23;
  chrome(g, W, H, 'Anúncio vertical — Composição principal');
  // Camadas
  panel(g, 12, 56, 330, 640, 'Camadas');
  const layers = [['T', 'Título', '#8a5cff'], ['T', 'Legenda', '#8a5cff'], ['◆', 'Selo de oferta', '#ffc23d'], ['▣', 'Produto', '#3dd6c0'], ['✦', 'Brilhos', '#ff6fa8'], ['▤', 'Fundo', '#5f7cff']];
  layers.forEach(([ic, n, c], i) => {
    const y = 108 + i * 58;
    if (i === 0) rr(g, 20, y - 4, 314, 50, 6, '#2e2340');
    rr(g, 32, y + 6, 30, 30, 6, c); txt(g, ic, 47, y + 21, 15, '#120e16', 'bold', 'center');
    txt(g, n, 76, y + 21, 15, '#e3dbe8'); txt(g, '👁', 310, y + 21, 14, '#8d8690', 'normal', 'center');
  });
  // Área de trabalho com o artboard 9:16
  panel(g, 354, 56, 892, 640);
  for (let yy = 66; yy < 690; yy += 20) for (let xx = 364; xx < 1236; xx += 20) { if (((xx + yy) / 20) % 2 === 0) { g.fillStyle = '#1d1a20'; g.fillRect(xx, yy, 20, 20); } }
  const ax = 631, ay = 70, aw = 338, ah = 600;
  const bg = g.createLinearGradient(0, ay, 0, ay + ah);
  bg.addColorStop(0, '#2b1055'); bg.addColorStop(0.55, '#a33a6a'); bg.addColorStop(1, '#ff7a3d');
  g.fillStyle = bg; g.fillRect(ax, ay, aw, ah);
  // raios de luz e brilhos
  g.save(); g.beginPath(); g.rect(ax, ay, aw, ah); g.clip();
  g.globalAlpha = 0.18; g.fillStyle = '#fff';
  for (let i = 0; i < 7; i++) { g.beginPath(); g.moveTo(800, 400); g.lineTo(ax - 200 + i * 120, ay - 50); g.lineTo(ax - 150 + i * 120, ay - 50); g.fill(); }
  g.globalAlpha = 1; g.restore();
  // fantasmas do movimento do produto (onion skin)
  drinkCan(g, 760, 470, 1.1, 0.15); drinkCan(g, 780, 440, 1.15, 0.25);
  drinkCan(g, 800, 410, 1.2);
  [[690, 300], [905, 360], [700, 520], [920, 520], [870, 250]].forEach(([x, y], i) => {
    g.globalAlpha = 0.35 + 0.65 * Math.abs(Math.sin(sp * 3 + i * 1.3));
    g.fillStyle = i % 2 ? '#ffe3a0' : '#ffffff';
    g.beginPath(); g.moveTo(x, y - 10); g.lineTo(x + 3, y - 3); g.lineTo(x + 10, y); g.lineTo(x + 3, y + 3); g.lineTo(x, y + 10); g.lineTo(x - 3, y + 3); g.lineTo(x - 10, y); g.lineTo(x - 3, y - 3); g.fill();
  });
  // título selecionado com alças
  g.globalAlpha = 1;
  g.save(); g.globalAlpha = Math.min(1, tt * 1.5); g.translate(800, 154); const sc = 0.88 + 0.12 * tt; g.scale(sc, sc); g.translate(-800, -154);
  txt(g, 'NOVO', 800, 128, 52, '#ffffff', 'bold', 'center');
  txt(g, 'SABOR', 800, 182, 52, '#ffd36b', 'bold', 'center');
  g.restore();
  rr(g, 680, 96, 240, 116, 2, null, '#4da3ff', 2);
  [[680, 96], [920, 96], [680, 212], [920, 212], [800, 96], [800, 212], [680, 154], [920, 154]].forEach(([x, y]) => rr(g, x - 5, y - 5, 10, 10, 2, '#ffffff', '#4da3ff', 2));
  // selo com caminho de movimento
  g.setLineDash([6, 6]); g.strokeStyle = 'rgba(255,255,255,0.8)'; g.lineWidth = 2;
  g.beginPath(); g.moveTo(980, 260); g.bezierCurveTo(960, 300, 930, 300, 905, 300); g.stroke(); g.setLineDash([]);
  [[980, 260], [940, 296]].forEach(([x, y]) => { g.fillStyle = '#ffc23d'; g.beginPath(); g.moveTo(x, y - 6); g.lineTo(x + 6, y); g.lineTo(x, y + 6); g.lineTo(x - 6, y); g.fill(); });
  const bx = 980 + (895 - 980) * bd, by = 260 + (305 - 260) * Math.sin(bd * Math.PI / 2);
  g.save(); g.globalAlpha = Math.min(1, bd * 2);
  g.fillStyle = '#ffc23d'; g.beginPath(); g.arc(bx, by, 40, 0, 7); g.fill();
  txt(g, '-20%', bx, by, 22, '#2b1055', 'bold', 'center');
  g.restore();
  // legenda
  g.save(); g.beginPath(); g.rect(631, 70, 338, 600); g.clip(); g.globalAlpha = cp; g.translate(0, (1 - cp) * 40);
  rr(g, 655, 590, 290, 54, 10, 'rgba(0,0,0,0.55)');
  txt(g, 'Refrescante do primeiro', 800, 606, 16, '#ffffff', 'bold', 'center');
  txt(g, 'ao último gole.', 800, 628, 16, '#ffffff', 'bold', 'center');
  g.restore();
  txt(g, '1080 × 1920 · 30 fps', 800, 684, 13, '#8d8690', 'normal', 'center');
  // Propriedades
  panel(g, 1258, 56, 330, 640, 'Transformar');
  [['Posição', '540, 260'], ['Escala', '112%'], ['Rotação', '-4°'], ['Opacidade', '100%']].forEach(([k, v], i) => {
    const y = 116 + i * 56; txt(g, k, 1276, y, 15, '#a39aa1'); rr(g, 1450, y - 15, 122, 30, 5, '#231f26'); txt(g, v, 1562, y, 14, '#4da3ff', 'normal', 'right');
  });
  txt(g, 'Suavização', 1276, 362, 15, '#cfc6cc', 'bold');
  rr(g, 1276, 384, 296, 220, 6, '#141116');
  g.strokeStyle = '#2a252c'; g.lineWidth = 1;
  for (let i = 1; i < 4; i++) { g.beginPath(); g.moveTo(1276 + i * 74, 384); g.lineTo(1276 + i * 74, 604); g.stroke(); g.beginPath(); g.moveTo(1276, 384 + i * 55); g.lineTo(1572, 384 + i * 55); g.stroke(); }
  g.strokeStyle = '#ff8a3d'; g.lineWidth = 3; g.beginPath(); g.moveTo(1290, 590); g.bezierCurveTo(1420, 590, 1420, 400, 1558, 398); g.stroke();
  g.strokeStyle = '#8d8690'; g.lineWidth = 1.5; g.beginPath(); g.moveTo(1290, 590); g.lineTo(1420, 590); g.moveTo(1558, 398); g.lineTo(1420, 400); g.stroke();
  [[1420, 590], [1420, 400]].forEach(([x, y]) => { g.fillStyle = '#fff'; g.beginPath(); g.arc(x, y, 6, 0, 7); g.fill(); });
  // Linha do tempo com keyframes
  panel(g, 12, 708, 1576, 280);
  const X0 = 250, X1 = 1576;
  ruler(g, X0, X1, 716, ['0s', '1s', '2s', '3s', '4s', '5s', '6s', '7s', '8s'], 166);
  layers.forEach(([, n, c], i) => {
    const y = 752 + i * 38;
    txt(g, n, 30, y + 14, 13, '#cfc6cc');
    g.fillStyle = '#151217'; g.fillRect(X0, y, X1 - X0, 30);
    const start = X0 + [80, 300, 420, 0, 160, 0][i], end = X0 + [1100, 1250, 1000, 1300, 1320, 1320][i];
    g.globalAlpha = 0.55; rr(g, start, y + 3, end - start, 24, 4, c); g.globalAlpha = 1;
    [[start + 10, 0], [start + 120, 0], [start + 300, 0], [end - 20, 0]].forEach(([x]) => {
      g.fillStyle = '#ffffff'; g.beginPath(); g.moveTo(x, y + 6); g.lineTo(x + 8, y + 15); g.lineTo(x, y + 24); g.lineTo(x - 8, y + 15); g.fill();
    });
  });
  const ph = X0 + (o.ph ?? 540); g.fillStyle = '#4da3ff'; g.fillRect(ph - 1, 716, 3, 266);
}

// ===== Cena 04: antes e depois =====
export function telaAntesDepois(g, W, H, o = {}) {
  const lit = o.chips ?? 5;
  seed = 41;
  chrome(g, W, H, 'Comparar versões');
  panel(g, 12, 56, 1576, 932);
  const fw = 470, fh = 264, y = 150, lx = 318, rxx = 812;
  rr(g, lx, y - 52, 120, 32, 6, '#2a252c'); txt(g, 'Original', lx + 60, y - 36, 15, '#cfc6cc', 'bold', 'center');
  rr(g, rxx, y - 52, 120, 32, 6, '#ff8a3d'); txt(g, 'Editado', rxx + 60, y - 36, 15, '#1a1013', 'bold', 'center');
  // original: clipe bruto, sem tratamento
  landscape(g, lx, y, fw, fh, 'raw', 0);
  rr(g, lx, y, fw, fh, 4, null, '#3a343c', 2);
  // editado: mesma imagem com cor, título e legenda
  landscape(g, rxx, y, fw, fh, 'graded', 0);
  g.fillStyle = 'rgba(0,0,0,0.0)';
  const vig = g.createRadialGradient(rxx + fw / 2, y + fh / 2, fh * 0.3, rxx + fw / 2, y + fh / 2, fw * 0.7);
  vig.addColorStop(0, 'rgba(0,0,0,0)'); vig.addColorStop(1, 'rgba(0,0,0,0.45)');
  g.fillStyle = vig; g.fillRect(rxx, y, fw, fh);
  g.fillStyle = '#ff8a3d'; g.fillRect(rxx + 22, y + 28, 4, 44);
  txt(g, 'Fim de tarde', rxx + 36, y + 42, 22, '#ffffff', 'bold');
  txt(g, 'Capítulo 1', rxx + 36, y + 64, 13, '#ffd8b8');
  rr(g, rxx + 95, y + fh - 46, 280, 30, 6, 'rgba(0,0,0,0.6)');
  txt(g, 'Foi aqui que tudo começou.', rxx + fw / 2, y + fh - 31, 14, '#ffffff', 'normal', 'center');
  rr(g, rxx, y, fw, fh, 4, null, '#ff8a3d', 2);
  // divisória
  g.fillStyle = '#3a343c'; g.fillRect(799, y - 50, 2, fh + 330);
  // mini linhas do tempo
  const ty = 470;
  txt(g, 'Sequência', lx, ty - 18, 13, '#8d8690'); txt(g, 'Sequência', rxx, ty - 18, 13, '#8d8690');
  // original: um único clipe longo
  videoClip(g, lx, ty, fw, 60, 'clipe_bruto.mp4', 0);
  rr(g, lx, ty + 70, fw, 40, 4, '#1f4a35'); waveform(g, lx + 4, ty + 72, fw - 8, 36, '#62d69c');
  // editado: cortes, títulos, legendas e trilha
  [[0, 110, 0], [114, 90, 0.6], [208, 130, 0.1], [342, 128, 1.0]].forEach(([dx, w, v]) => videoClip(g, rxx + dx, ty, w, 60, '', v));
  rr(g, rxx, ty + 70, 470, 18, 4, '#6a3fa0'); txt(g, 'Título', rxx + 8, ty + 79, 11, '#f1e9ff');
  rr(g, rxx + 90, ty + 92, 300, 18, 4, '#8a5cff'); txt(g, 'Legendas', rxx + 98, ty + 101, 11, '#f1e9ff');
  rr(g, rxx, ty + 114, 470, 30, 4, '#1d3b5c'); waveform(g, rxx + 4, ty + 116, 462, 26, '#6cb3ff', 4);
  // etapas aplicadas
  const steps = ['Cortes', 'Cor', 'Títulos', 'Legendas', 'Áudio'];
  steps.forEach((s, i) => {
    const x = rxx + i * 96;
    const on = Math.max(0, Math.min(1, lit - i));
    rr(g, x, 660, 88, 34, 17, on > 0.5 ? '#2b1f17' : '#1c181d', on > 0.5 ? '#ff8a3d' : '#3a343c', 1.5);
    txt(g, (on > 0.5 ? '✓ ' : '') + s, x + 44, 677, 13, on > 0.5 ? '#ffcfa8' : '#6f666c', 'normal', 'center');
  });
  txt(g, 'Etapas de edição aplicadas', rxx, 636, 13, '#8d8690');
  txt(g, 'Sem tratamento', lx, 650, 13, '#8d8690');
  // barra inferior
  txt(g, '00:00:08:14', 800, 950, 16, '#ff9a55', 'bold', 'center');
  transport(g, 800, 900);
}

// ===== Cena 05: vídeo finalizado em reprodução =====
export function telaFinal(g, W, H) {
  seed = 59;
  g.fillStyle = '#000'; g.fillRect(0, 0, W, H);
  // quadro cinematográfico 2.39:1 dentro de 16:9
  const vx = 0, vw = 1600, vh = 900, vy = 30;
  g.fillStyle = '#000'; g.fillRect(vx, vy, vw, vh);
  const ih = vw / 2.39, iy = vy + (vh - ih) / 2;
  landscape(g, vx, iy, vw, ih, 'dusk', 0.2);
  // granulação leve
  for (let i = 0; i < 2500; i++) { g.fillStyle = `rgba(255,255,255,${rnd() * 0.05})`; g.fillRect(rnd() * vw, iy + rnd() * ih, 2, 2); }
  // controles do player
  g.fillStyle = 'rgba(255,255,255,0.18)'; g.fillRect(60, 950, 1480, 5);
  g.fillStyle = '#ff8a3d'; g.fillRect(60, 950, 1440, 5);
  g.beginPath(); g.arc(1500, 952, 9, 0, 7); g.fill();
  txt(g, '00:29 / 00:30', 1540, 978, 15, '#bdb5ba', 'normal', 'right');
  g.fillStyle = '#bdb5ba'; g.fillRect(64, 970, 5, 16); g.fillRect(74, 970, 5, 16);
}

// ===== Antes e depois com cortina deslizante (o.p de 0 a 1)
export function telaCortina(g, W, H, o = {}) {
  seed = 71;
  const p = o.p ?? 1;
  chrome(g, W, H, 'Correção de cor — Comparar');
  panel(g, 12, 56, 1576, 932);
  const x = 210, y = 110, w = 1180, h = 664;
  landscape(g, x, y, w, h, 'raw', 0);
  const cx = x + w * p;
  g.save(); g.beginPath(); g.rect(x, y, cx - x, h); g.clip();
  landscape(g, x, y, w, h, 'graded', 0);
  const vig = g.createRadialGradient(x + w / 2, y + h / 2, h * 0.3, x + w / 2, y + h / 2, w * 0.7);
  vig.addColorStop(0, 'rgba(0,0,0,0)'); vig.addColorStop(1, 'rgba(0,0,0,0.45)');
  g.fillStyle = vig; g.fillRect(x, y, w, h);
  const tA = Math.min(1, Math.max(0, (p - 0.55) / 0.3));
  g.globalAlpha = tA;
  g.fillStyle = '#ff8a3d'; g.fillRect(x + 50, y + 54, 7, 86);
  txt(g, 'Fim de tarde', x + 76, y + 82, 48, '#ffffff', 'bold');
  txt(g, 'Capítulo 1', x + 78, y + 124, 24, '#ffd8b8');
  rr(g, x + w / 2 - 290, y + h - 92, 580, 56, 10, 'rgba(0,0,0,0.6)');
  txt(g, 'Foi aqui que tudo começou.', x + w / 2, y + h - 64, 28, '#ffffff', 'normal', 'center');
  g.restore();
  // divisória com alça
  g.fillStyle = '#ffffff'; g.fillRect(cx - 2, y, 4, h);
  g.beginPath(); g.arc(cx, y + h / 2, 26, 0, 7); g.fill();
  g.fillStyle = '#1a1013';
  g.beginPath(); g.moveTo(cx - 14, y + h / 2); g.lineTo(cx - 5, y + h / 2 - 9); g.lineTo(cx - 5, y + h / 2 + 9); g.fill();
  g.beginPath(); g.moveTo(cx + 14, y + h / 2); g.lineTo(cx + 5, y + h / 2 - 9); g.lineTo(cx + 5, y + h / 2 + 9); g.fill();
  rr(g, x + 20, y + h - 52, 130, 36, 8, '#ff8a3d'); txt(g, 'DEPOIS', x + 85, y + h - 34, 18, '#1a1013', 'bold', 'center');
  rr(g, x + w - 150, y + h - 52, 130, 36, 8, 'rgba(0,0,0,0.6)'); txt(g, 'ANTES', x + w - 85, y + h - 34, 18, '#d9d2d6', 'bold', 'center');
  // ajustes de cor
  const sliders = [['Exposição', 0.55], ['Contraste', 0.68], ['Saturação', 0.72], ['Temperatura', 0.64]];
  sliders.forEach(([k, v], i) => {
    const sx = x + i * 300, sy = 840;
    txt(g, k, sx, sy, 18, '#a39aa1');
    rr(g, sx, sy + 24, 260, 8, 4, '#2a252c'); rr(g, sx, sy + 24, 260 * (0.5 + (v - 0.5) * p), 8, 4, '#ff8a3d');
    g.fillStyle = '#ffffff'; g.beginPath(); g.arc(sx + 260 * (0.5 + (v - 0.5) * p), sy + 28, 10, 0, 7); g.fill();
  });
}

// ===== Exportação com barra de progresso (o.p de 0 a 1)
export function telaExport(g, W, H, o = {}) {
  seed = 83;
  const p = o.p ?? 1;
  chrome(g, W, H, 'Exportar');
  g.fillStyle = '#0b090c'; g.fillRect(0, 44, W, H - 44);
  rr(g, 330, 120, 940, 760, 22, '#18151a', '#2a252c', 2);
  landscape(g, 380, 170, 840, 400, 'graded', 0.2);
  g.fillStyle = '#ff8a3d'; g.fillRect(410, 205, 6, 56);
  txt(g, 'Fim de tarde', 428, 233, 34, '#ffffff', 'bold');
  const done = p >= 1;
  txt(g, done ? 'Pronto!' : 'Exportando vídeo…', 380, 630, 36, '#ffffff', 'bold');
  txt(g, '1080 × 1920 · 30 fps · H.264 · 30 s', 380, 672, 20, '#a39aa1');
  rr(g, 380, 720, 840, 26, 13, '#2a252c');
  const grd = g.createLinearGradient(380, 0, 1220, 0); grd.addColorStop(0, '#ff6b1a'); grd.addColorStop(1, '#ffb36b');
  rr(g, 380, 720, Math.max(26, 840 * p), 26, 13, grd);
  txt(g, `${Math.round(p * 100)}%`, 1220, 630, 44, done ? '#5fd39a' : '#ff9a55', 'bold', 'right');
  if (done) {
    g.fillStyle = '#2bbf73'; g.beginPath(); g.arc(1180, 805, 34, 0, 7); g.fill();
    g.strokeStyle = '#ffffff'; g.lineWidth = 8; g.lineCap = 'round'; g.lineJoin = 'round';
    g.beginPath(); g.moveTo(1163, 806); g.lineTo(1176, 819); g.lineTo(1198, 793); g.stroke();
    txt(g, 'Arquivo salvo: fim-de-tarde.mp4', 380, 805, 22, '#cfc6cc');
  } else {
    txt(g, `Tempo restante: ${Math.max(1, Math.round((1 - p) * 12))} s`, 380, 805, 22, '#8d8690');
  }
}

// ===== Renderização quadro a quadro (o.n de 0 a 900)
export function telaRender(g, W, H, o = {}) {
  seed = 97;
  const n = Math.round(o.n ?? 3), total = 900, done = n >= total;
  chrome(g, W, H, 'Renderizar sequência');
  g.fillStyle = '#0b090c'; g.fillRect(0, 44, W, H - 44);
  txt(g, done ? 'Renderização concluída' : 'Renderizando quadro', 800, 200, 46, '#d9d2d6', 'bold', 'center');
  txt(g, `${n}/${total}`, 800, 360, 190, done ? '#5fd39a' : '#ff9a55', 'bold', 'center');
  rr(g, 260, 500, 1080, 36, 18, '#2a252c');
  const grd = g.createLinearGradient(260, 0, 1340, 0); grd.addColorStop(0, '#ff6b1a'); grd.addColorStop(1, '#ffb36b');
  rr(g, 260, 500, Math.max(36, 1080 * n / total), 36, 18, grd);
  // miniaturas dos quadros já prontos
  const cols = 16, shown = Math.min(48, Math.ceil(48 * n / total) || 1);
  for (let i = 0; i < 48; i++) {
    const x = 260 + (i % cols) * 68, y = 600 + Math.floor(i / cols) * 76;
    if (i < shown) landscape(g, x, y, 60, 68, 'graded', (i % 7) * 0.2); else rr(g, x, y, 60, 68, 4, '#18151a');
  }
  txt(g, done ? '30 s · 30 fps · 1080 × 1920' : `Tempo restante: ${Math.max(1, Math.round((total - n) * 3 / 60))} min`, 800, 880, 26, '#8d8690', 'normal', 'center');
}

// ===== Conversa com o pedido "deixa mais profissional" (o.typing de 0 a 1)
export function telaPedido(g, W, H, o = {}) {
  const ty = o.typing ?? 1;
  chrome(g, W, H, 'Projeto — Comentários');
  g.fillStyle = '#0e0c0f'; g.fillRect(0, 44, W, H - 44);
  landscape(g, 120, 110, 760, 428, 'graded', 0.3);
  txt(g, 'Prévia do vídeo', 120, 575, 20, '#8d8690');
  // balão do pedido
  rr(g, 920, 140, 630, 230, 26, '#2a2230');
  txt(g, 'Você', 960, 185, 22, '#b9a6ff', 'bold');
  const msg = 'Ficou bom! Mas dá pra deixar';
  const msg2 = 'mais profissional?';
  const k = Math.floor(ty * (msg.length + msg2.length));
  txt(g, msg.slice(0, Math.min(k, msg.length)), 960, 245, 31, '#ffffff', 'bold');
  txt(g, msg2.slice(0, Math.max(0, k - msg.length)), 960, 300, 31, '#ffffff', 'bold');
  // resposta "digitando"
  rr(g, 940, 420, 300, 90, 26, '#ff8a3d');
  for (let i = 0; i < 3; i++) { g.fillStyle = '#1a0d06'; g.beginPath(); g.arc(1030 + i * 50, 465, 11, 0, 7); g.fill(); }
  txt(g, 'Claude está digitando…', 940, 545, 20, '#8d8690');
}
