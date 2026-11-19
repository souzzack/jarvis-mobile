# Campo das Bolhas — terreno: ilha principal, ilhas secundárias, lagos, afloramentos e muretas.
# Uso: python build_terrain.py [--previas]
# Saídas: Terrain/CB_Terreno.blend, Exports/glTF/CB_Terreno.glb, Exports/FBX/CB_Terreno.fbx,
#         Exports/Heightmap/CB_Heightmap_IlhaPrincipal.png (+ .json), Renders/Terrain/*.png
import sys, os, math, json
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import bpy, bmesh
from mathutils import Vector, noise
import cb_lib as L
import layout as P

TAU = math.tau

def ss(a, b, x):
    t = max(0.0, min(1.0, (x - a) / (b - a))); return t * t * (3 - 2 * t)

def lerp(a, b, t): return a + (b - a) * t

def segdist(px, py, ax, ay, bx, by):
    dx, dy = bx - ax, by - ay; L2 = dx * dx + dy * dy
    t = 0 if L2 == 0 else max(0, min(1, ((px - ax) * dx + (py - ay) * dy) / L2))
    qx, qy = ax + dx * t, ay + dy * t
    return math.hypot(px - qx, py - qy), t

def mix_rgb(a, b, t): return tuple(a[i] + (b[i] - a[i]) * t for i in range(3))
def C(h): return L.hexrgb(h)[:3]

# ------------------------------------------------------------------ contorno
def contorno(cx, cy, A, B, semente, obrigatorios, n=360, amp=0.07):
    off = Vector((semente * 13.1, semente * 7.7, 0))
    R = []
    for i in range(n):
        a = TAU * i / n; u = (math.cos(a), math.sin(a))
        re = 1 / math.sqrt(u[0] ** 2 / A ** 2 + u[1] ** 2 / B ** 2)
        nz = noise.fractal(Vector((math.cos(a) * 2.2, math.sin(a) * 2.2, 0)) + off, 0.7, 2.0, 4)
        r = re * (1 + amp * nz)
        for (ox, oy, orad) in obrigatorios:  # garante que o círculo obrigatório fique dentro (margem 4)
            px, py = ox - cx, oy - cy; cu = px * u[0] + py * u[1]; d2 = px * px + py * py - cu * cu
            if d2 <= orad * orad: r = max(r, cu + math.sqrt(orad * orad - d2) + 4)
        R.append(r)
    for _ in range(3):  # suaviza
        R = [(R[i - 1] + 2 * R[i] + R[(i + 1) % n]) / 4 for i in range(n)]
    return R

def r_em(R, a):
    n = len(R); f = (a % TAU) / TAU * n; i = int(f) % n; t = f - int(f)
    return R[i] * (1 - t) + R[(i + 1) % n] * t

# ------------------------------------------------------------------ altura da ilha principal
I = P.ILHA_PRINCIPAL
PLAT = {p['id']: p for p in P.PLATOS}

def h_bruta(x, y):
    v = Vector((x * 0.012, y * 0.012, 0.5))
    h = I['base'] + 7.0 * noise.fractal(v, 0.6, 2.1, 4) + 3.0 * noise.fractal(v * 3.1 + Vector((5, 1, 0)), 0.5, 2.0, 3)
    h += 20.0 * math.exp(-((x - 0) ** 2 + (y - 104) ** 2) / (2 * 42 ** 2))      # colina do Gerador
    h += 6.0 * math.exp(-((x + 20) ** 2 + (y - 20) ** 2) / (2 * 55 ** 2))      # terraços da vila
    h += 8.0 * math.exp(-((x + 140) ** 2 + (y - 40) ** 2) / (2 * 40 ** 2))     # oeste mais alto (cabeceira)
    h += 9.0 * math.exp(-((x - 112) ** 2 + (y - 90) ** 2) / (2 * 34 ** 2))     # nordeste (cabeceira leste)
    h += 4.0 * math.exp(-((x + 95) ** 2 + (y + 80) ** 2) / (2 * 26 ** 2))      # mirante
    return h

def aplica_lagos(x, y, h):
    for l in P.LAGOS:
        d = math.hypot(x - l['x'], y - l['y'])
        if d < l['r']:                      # cava: sobe do fundo até logo abaixo da água
            h = lerp(l['fundo'], l['agua'] - 0.2, ss(l['r'] * 0.25, l['r'], d))
        elif d < l['r'] + 9:                # margem: sempre acima da água, emendando no chão natural
            h = lerp(l['agua'] + 0.7, max(h, l['agua'] + 0.7), ss(l['r'], l['r'] + 9, d))
    return h

def aplica_platos(x, y, h):
    for p in P.PLATOS:
        d = math.hypot(x - p['x'], y - p['y'])
        if d < p['r'] + p['borda']: h = lerp(p['z'], h, ss(p['r'], p['r'] + p['borda'], d))
    return h

def h_base(x, y): return aplica_platos(x, y, aplica_lagos(x, y, h_bruta(x, y)))

# perfil de cada caminho: amostra a cada 2 studs, média móvel e limite de inclinação 0,28
PERFIS = []
for c in P.CAMINHOS:
    pts = c['pts']; S = []
    for k in range(len(pts) - 1):
        (ax, ay), (bx, by) = pts[k], pts[k + 1]; n = max(1, int(math.hypot(bx - ax, by - ay) / 2))
        for i in range(n): S.append((ax + (bx - ax) * i / n, ay + (by - ay) * i / n))
    S.append(pts[-1]); Z = [h_base(x, y) for x, y in S]
    for _ in range(6): Z = [(Z[max(0, i - 3)] + Z[max(0, i - 1)] + 2 * Z[i] + Z[min(len(Z) - 1, i + 1)] + Z[min(len(Z) - 1, i + 3)]) / 6 for i in range(len(Z))]
    for i in range(1, len(Z)): Z[i] = max(Z[i - 1] - 0.56, min(Z[i - 1] + 0.56, Z[i]))
    for i in range(len(Z) - 2, -1, -1): Z[i] = max(Z[i + 1] - 0.56, min(Z[i + 1] + 0.56, Z[i]))
    xs = [q[0] for q in S]; ys = [q[1] for q in S]; m = c['largura'] / 2 + 6
    PERFIS.append((c, S, Z, (min(xs) - m, max(xs) + m, min(ys) - m, max(ys) + m)))

def caminho_info(x, y):
    """(peso 0..1 dentro do caminho, altura do caminho, distância à borda)"""
    best = (0.0, None, 1e9)
    for c, S, Z, bb in PERFIS:
        if x < bb[0] or x > bb[1] or y < bb[2] or y > bb[3]: continue
        hw = c['largura'] / 2
        for i in range(len(S) - 1):
            d, t = segdist(x, y, *S[i], *S[i + 1])
            if d < hw + 5 and d - hw < best[2]:
                z = lerp(Z[i], Z[i + 1], t); w = 1 - ss(hw, hw + 5, d)
                best = (w, z, d - hw)
    return best

def altura_exata(x, y):
    h = h_base(x, y)
    w, z, _ = caminho_info(x, y)
    if z is not None: h = lerp(h, z, w)
    return aplica_platos(x, y, h)

# grade pré-calculada (1,5 stud): altura e peso de caminho; o resto do script interpola nela
GX0, GY0, GD, GNX, GNY = -205.0, -185.0, 1.5, 274, 248
_GH = None; _GW = None
def _grade():
    global _GH, _GW
    if _GH is not None: return
    _GH = []; _GW = []
    for j in range(GNY):
        y = GY0 + j * GD; rh = []; rw = []
        for i in range(GNX):
            x = GX0 + i * GD
            hb = h_base(x, y); w, z, db = caminho_info(x, y)
            h = lerp(hb, z, w) if z is not None else hb
            rh.append(aplica_platos(x, y, h)); rw.append(w)
        _GH.append(rh); _GW.append(rw)

def _bil(G, x, y):
    _grade()
    fx = min(max((x - GX0) / GD, 0), GNX - 1.001); fy = min(max((y - GY0) / GD, 0), GNY - 1.001)
    i, j = int(fx), int(fy); tx, ty = fx - i, fy - j
    return (G[j][i] * (1 - tx) + G[j][i + 1] * tx) * (1 - ty) + (G[j + 1][i] * (1 - tx) + G[j + 1][i + 1] * tx) * ty

def altura(x, y): _grade(); return _bil(_GH, x, y)
def peso_caminho(x, y): _grade(); return _bil(_GW, x, y)

# ------------------------------------------------------------------ cores do terreno
G1, G2, G3 = C('#5fc457'), C('#2f8a4c'), C('#9bd65a')
CAM, CAM2 = C('#e6d2c2'), C('#c3aed6')
AREIA = C('#f3e3c8')
ROCHA = [C('#9b8cc0'), C('#7d6fa8'), C('#b3a2cf'), C('#6f6396')]
MUSGO = C('#5aa86e')

def cor_topo(x, y, z, incl):
    n = noise.fractal(Vector((x * 0.05, y * 0.05, 1.7)), 0.6, 2, 3); n2 = noise.noise(Vector((x * 0.21, y * 0.21, 3.3)))
    c = mix_rgb(G1, G2, ss(-0.3, 0.5, n)); c = mix_rgb(c, G3, ss(0.35, 0.7, n2) * 0.5)
    for l in P.LAGOS:
        d = math.hypot(x - l['x'], y - l['y'])
        if d < l['r'] + 5: c = mix_rgb(c, AREIA, 1 - ss(l['r'] + 1, l['r'] + 5, d))
    w = peso_caminho(x, y)
    if w > 0:
        pc = mix_rgb(CAM, CAM2, ss(-0.4, 0.6, n2)); c = mix_rgb(c, pc, ss(0.45, 0.85, w))
    for p in P.PLATOS:
        d = math.hypot(x - p['x'], y - p['y'])
        if d < p['r'] - 1: c = mix_rgb(c, mix_rgb(CAM, CAM2, 0.3 + 0.3 * n2), 1 - ss(p['r'] - 6, p['r'] - 1, d))
    if incl > 0.55: c = mix_rgb(c, ROCHA[0], ss(0.55, 0.9, incl))
    return c

def cor_rocha(z, x, y):
    k = int((z + 1000) / 7) % len(ROCHA); n = noise.noise(Vector((x * 0.08, y * 0.08, z * 0.15)))
    c = mix_rgb(ROCHA[k], ROCHA[(k + 1) % len(ROCHA)], ss(-0.4, 0.4, n))
    return mix_rgb(c, C('#6f6690'), ss(-20, -120, z) * 0.6)

# ------------------------------------------------------------------ malha da ilha (topo radial + base rochosa)
def ilha(nome, cx, cy, R, hfun, fundo, aneis=60, seg=360, semente=1, grupo='Ilha'):
    bm = bmesh.new(); cl = bm.loops.layers.color.new('Cor')
    V = []; cols = []
    centro = bm.verts.new((cx, cy, hfun(cx, cy))); centro_c = cor_topo(cx, cy, hfun(cx, cy), 0)
    # topo: anéis s em (0,1]
    for k in range(1, aneis + 1):
        s = (k / aneis) ** 0.85; ring = []; rc = []
        for i in range(seg):
            a = TAU * i / seg; r = r_em(R, a) * s; x = cx + r * math.cos(a); y = cy + r * math.sin(a)
            z = hfun(x, y)
            if k >= aneis - 2:  # borda: lábio orgânico um pouco abaixo
                z -= (k - (aneis - 3)) * 0.6 * (1 + 0.5 * noise.noise(Vector((x * 0.1, y * 0.1, 9))))
            ring.append(bm.verts.new((x, y, z))); rc.append(None)
        V.append(ring); cols.append(rc)
    top_rings = len(V)
    # base rochosa: desce em estratos e afunila
    z_borda = [V[-1][i].co.z for i in range(seg)]
    D = fundo; niveis = 34
    for k in range(1, niveis + 1):
        t = k / niveis
        f = (1 - t ** 1.6) * (0.97 + 0.04 * math.sin(t * 40))  # degraus de estrato
        f = max(0.02, f)
        ring = []
        for i in range(seg):
            a = TAU * i / seg; zb = z_borda[i]
            z = lerp(zb - 1.5, D, t ** 1.15)
            nz = noise.fractal(Vector((math.cos(a) * 3, math.sin(a) * 3, z * 0.06 + semente)), 0.6, 2, 4)
            r = r_em(R, a) * f * (1 + 0.08 * nz) + (2.0 if k == 1 else 0)
            ring.append(bm.verts.new((cx + r * math.cos(a), cy + r * math.sin(a), z + 2.5 * nz)))
        V.append(ring); cols.append([None] * seg)
    ponta = bm.verts.new((cx, cy, D - 12))
    bm.verts.ensure_lookup_table()
    F = []
    for i in range(seg):
        F.append(bm.faces.new((centro, V[0][i], V[0][(i + 1) % seg])))
    for k in range(len(V) - 1):
        for i in range(seg):
            i2 = (i + 1) % seg
            F.append(bm.faces.new((V[k][i], V[k + 1][i], V[k + 1][i2], V[k][i2])))
    for i in range(seg):
        F.append(bm.faces.new((V[-1][i], ponta, V[-1][(i + 1) % seg])))
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    bm.normal_update(); bm.verts.index_update()
    # cores por canto (loop): topo pela inclinação, base por estrato
    cache = {}
    for v in bm.verts:
        co = v.co
        if v.normal.z > 0.35 and co.z > hfun(co.x, co.y) - 3.0:
            cache[v.index] = cor_topo(co.x, co.y, co.z, 1 - max(0.0, v.normal.z))
        else:
            cache[v.index] = cor_rocha(co.z, co.x, co.y)
    for f in bm.faces:
        for lp in f.loops: lp[cl] = (*cache[lp.vert.index], 1.0)
    return L._obj(nome, bm, 'Terreno', grupo, suave=True, angulo=55)

def z_min_topo(cx, cy, x, y, hfun):
    return hfun(x, y) - 2.5

# ------------------------------------------------------------------ ilhas secundárias
def h_secundaria(s):
    def f(x, y):
        d = math.hypot(x - s['cx'], y - s['cy']) / s['r']
        v = Vector((x * 0.03, y * 0.03, s['semente']))
        return s['topo'] + 1.6 * noise.fractal(v, 0.6, 2, 3) + 2.5 * (1 - d * d) * (s['r'] > 30) - 1.5 * ss(0.75, 1.0, d)
    return f

def build(L_estagio=3):
    L.reset(); root = L.raiz('CB_Terreno')
    obrig = [(p['x'], p['y'], p['r'] + p['borda'] * 0.3) for p in P.PLATOS] + [(b['a'][0], b['a'][1], 6) for b in P.PONTES]
    obrig += [(l['x'], l['y'], l['r'] + 10) for l in P.LAGOS]
    R = contorno(I['cx'], I['cy'], I['A'], I['B'], I['semente'], obrig)
    ilha('CB_Terreno_IlhaPrincipal', I['cx'], I['cy'], R, altura, I['fundo'], aneis=64 if L_estagio > 1 else 40, seg=360 if L_estagio > 1 else 180, semente=I['semente'])
    for s in P.ILHAS_SECUNDARIAS:
        obr = [(b['b'][0], b['b'][1], 5) for b in P.PONTES if math.hypot(b['b'][0] - s['cx'], b['b'][1] - s['cy']) < s['r'] + 10]
        Rs = contorno(s['cx'], s['cy'], s['r'], s['r'] * 0.92, s['semente'], obr, n=180, amp=0.12)
        ilha('CB_Terreno_' + s['id'], s['cx'], s['cy'], Rs, h_secundaria(s), s['fundo'], aneis=22, seg=180, semente=s['semente'], grupo=s['id'])
    if L_estagio >= 2:
        # água dos lagos (superfície turquesa, um pouco maior que a cava para encostar na margem)
        for l in P.LAGOS:
            o = L.cilindro('Agua_' + l['id'], l['r'] + 2.2, l['r'] + 2.2, 0.3, (l['x'], l['y'], l['agua'] - 0.3), mat='Agua', grupo='Lagos', seg=64, chanfro=0)
    if L_estagio >= 3:
        afloramentos(R)
        muretas()
        rochas_suspensas()
    pecas = L.consolidar('CB_Terreno', root, separados=())
    # terreno vira objetos por ilha (cada ilha = um objeto com cor por vértice)
    return root, R

def sobre(x, y):
    return altura(x, y)

def afloramentos(R):
    import random; rnd = random.Random(7); n = 0; tent = 0
    while n < 46 and tent < 2000:
        tent += 1; a = rnd.random() * TAU; s = math.sqrt(rnd.random()) * 0.97
        r = r_em(R, a) * s; x = r * math.cos(a); y = r * math.sin(a)
        if peso_caminho(x, y) > 0.0 or peso_caminho(x + 3, y) > 0 or peso_caminho(x - 3, y) > 0 or peso_caminho(x, y + 3) > 0 or peso_caminho(x, y - 3) > 0: continue
        if any(math.hypot(x - p['x'], y - p['y']) < p['r'] + 3 for p in P.PLATOS): continue
        if any(math.hypot(x - l['x'], y - l['y']) < l['r'] + 3 for l in P.LAGOS): continue
        g = min(altura(x + dx, y + dy) for dx, dy in ((0, 0), (2, 0), (-2, 0), (0, 2), (0, -2)))
        sz = 1.5 + rnd.random() ** 2 * 5 + (2.5 if s > 0.85 else 0)
        L.rocha(f'Aflor{n}', sz, (x, y, g + sz * 0.15), (1.2 + rnd.random() * 0.6, 1 + rnd.random() * 0.5, 0.55 + rnd.random() * 0.35),
                (0, 0, rnd.random() * TAU), mat='PedraLilas', grupo='Afloramentos', semente=n + 3, sub=3, aspereza=0.32)
        if rnd.random() < 0.5:  # pedra menor encostada
            L.rocha(f'AflorB{n}', sz * 0.45, (x + sz * 0.9, y + sz * 0.4, g + sz * 0.05), (1.1, 1, 0.7), (0, 0, rnd.random() * TAU),
                    mat='PedraLilas', grupo='Afloramentos', semente=n + 103, sub=2, aspereza=0.3)
        n += 1

def muretas():
    """Muros de arrimo curvos onde o platô fica acima do chão em volta (terraços da vila e cabeceiras)."""
    for p in P.PLATOS:
        segs = 48
        for i in range(segs):
            a0 = TAU * i / segs; a1 = TAU * (i + 1) / segs; am = (a0 + a1) / 2
            rx = p['x'] + (p['r'] + 0.6) * math.cos(am); ry = p['y'] + (p['r'] + 0.6) * math.sin(am)
            fora = h_bruta(rx + 3 * math.cos(am), ry + 3 * math.sin(am))
            queda = p['z'] - fora
            if queda < 1.6: continue
            hgt = min(queda + 1.0, 7.0); L_ = 2 * (p['r'] + 0.6) * math.sin(math.pi / segs) + 0.25
            L.caixa(f'Mureta_{p["id"]}_{i}', (L_, 1.1, hgt + 0.6), (rx, ry, p['z'] - hgt / 2 + 0.3), (0, 0, am + math.pi / 2),
                    mat='PedraPerolada', grupo='Muretas', chanfro=0.18)
            L.caixa(f'MuretaTopo_{p["id"]}_{i}', (L_ + 0.05, 1.4, 0.35), (rx, ry, p['z'] + 0.75), (0, 0, am + math.pi / 2),
                    mat='DouradoEscovado' if i % 6 == 0 else 'PedraLilas', grupo='Muretas', chanfro=0.1)

def rochas_suspensas():
    """Pedras e cristais pendurados sob a ilha principal, presos à base (não soltos)."""
    import random; rnd = random.Random(5)
    for k in range(10):
        a = rnd.random() * TAU; r = 30 + rnd.random() * 70; x, y = r * math.cos(a), r * math.sin(a)
        z = -40 - rnd.random() * 50 + r * 0.45
        L.rocha(f'Suspensa{k}', 4 + rnd.random() * 5, (x, y, z), (1, 1, 1.8), (0, 0, a), mat='RochaBase', grupo='BaseRochosa', semente=200 + k, sub=2)
        for j in range(3):
            L.torno(f'CristalSusp{k}_{j}', [(0, 0), (0.9, -0.6), (1.0, -3.5), (0, -6.5)], (x + rnd.uniform(-2, 2), y + rnd.uniform(-2, 2), z - 4),
                    (rnd.uniform(-.3, .3), rnd.uniform(-.3, .3), 0), mat='Cristal', grupo='CristaisBase', seg=6)

# ------------------------------------------------------------------ mapa de altura para o Terrain do Roblox
def heightmap(R, caminho, res=512):
    import numpy as np
    x0, x1, y0, y1 = -I['A'] * 1.15, I['A'] * 1.15, -I['B'] * 1.15, I['B'] * 1.15
    H = np.zeros((res, res), dtype=np.float32); zmin, zmax = -10.0, 60.0
    for j in range(res):
        y = y1 - (y1 - y0) * j / (res - 1)
        for i in range(res):
            x = x0 + (x1 - x0) * i / (res - 1); a = math.atan2(y, x)
            if math.hypot(x, y) > r_em(R, a): H[j, i] = 0.0; continue
            H[j, i] = (altura(x, y) - zmin) / (zmax - zmin)
    img = bpy.data.images.new('CB_Heightmap', res, res, float_buffer=True, is_data=True)
    px = np.zeros((res, res, 4), dtype=np.float32); px[..., 0] = px[..., 1] = px[..., 2] = H[::-1]; px[..., 3] = 1
    img.pixels.foreach_set(px.ravel())
    img.filepath_raw = caminho; img.file_format = 'PNG'
    sc = bpy.context.scene; s = sc.render.image_settings; s.file_format = 'PNG'; s.color_depth = '16'; s.color_mode = 'BW'
    img.save_render(caminho, scene=sc)
    meta = dict(arquivo=os.path.basename(caminho), resolucao=res, studs_x=[x0, x1], studs_y_norte=[y0, y1],
                altura_preto=zmin, altura_branco=zmax, nota='16 bits; fora da ilha = 0 (preto). Topo da ilha principal apenas (sem base rochosa).')
    json.dump(meta, open(caminho.replace('.png', '.json'), 'w'), ensure_ascii=False, indent=1)

if __name__ == '__main__':
    previas = '--previas' in sys.argv
    root, R = build(3)
    # colisores: o próprio terreno é colisor (no Roblox: Terrain pelo heightmap ou MeshPart com CollisionFidelity PreciseConvexDecomposition)
    destino = os.path.join(L.ROOT, 'Terrain', 'CB_Terreno.blend')
    objs = [root] + list(root.children)
    info = dict(objetos=[o.name for o in root.children], triangulos=L.tris(root.children))
    L.salvar_blend(destino)
    L.exportar(objs, 'CB_Terreno')
    os.makedirs(os.path.join(L.ROOT, 'Exports', 'Heightmap'), exist_ok=True)
    heightmap(R, os.path.join(L.ROOT, 'Exports', 'Heightmap', 'CB_Heightmap_IlhaPrincipal.png'))
    json.dump(info, open(os.path.join(L.ROOT, 'Terrain', 'CB_Terreno_info.json'), 'w'), ensure_ascii=False, indent=1)
    print('TERRENO', json.dumps(info)[:400])

# ------------------------------------------------------------------ prévias (blockout, intermediário, final)
def previas():
    pasta = os.path.join(L.ROOT, 'Renders', 'Terrain'); nomes = []
    etapas = [(1, 'blockout', 12), (2, 'intermediario', 16), (3, 'final', 28)]
    vistas = [('aerea', (-0.55, -1.0), 0.78, (0, 0, 10), 300), ('lateral_base', (1.0, -0.25), -0.08, (0, 0, -40), 230),
              ('detalhe_lagos', (0.3, -1.0), 0.45, (100, -5, 12), 55), ('detalhe_vila', (0.2, -1.0), 0.55, (-15, 15, 18), 70)]
    for nivel, etapa, amostras in etapas:
        build(nivel)
        L.mundo(sol_elev=18, sol_rot=235, forca=1.0)
        if nivel == 1:
            bpy.context.view_layer.material_override = L.get_mat('Blockout')
        cam = L.camera(lente=32); L.config_render(1280, 720, amostras)
        for nome, d, elev, alvo, raio in vistas:
            L.enquadrar(cam, alvo, raio, d, elev, folga=1.0)
            arq = os.path.join(pasta, f'CB_Terreno_{etapa}_{nome}.png'); L.renderizar(arq); nomes.append(arq)
    # planta (vista de cima, ortográfica) do modelo final, para anotar
    build(3); L.mundo(sol_elev=55, sol_rot=200, forca=1.0)
    cam = L.camera(); cam.data.type = 'ORTHO'; cam.data.ortho_scale = 560; L.mirar(cam, (-20, 20, 400), (-20, 20, 0))
    L.config_render(1600, 1200, 16); arq = os.path.join(pasta, 'CB_Planta_base.png'); L.renderizar(arq); nomes.append(arq)
    return nomes

if __name__ == '__main__' and '--previas' in sys.argv:
    print('PREVIAS', previas())
