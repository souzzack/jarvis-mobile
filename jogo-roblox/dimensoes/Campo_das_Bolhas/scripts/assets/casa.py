# C. Vila Encantada — kit de casas arredondadas. Três tipologias, cada uma em duas variações (cor, janelas, detalhes):
#   A = Casa-Cabaça (bojo de reboco, telhado curvo de telhas-pétala, chaminé-cogumelo)
#   B = Casa-Concha (térreo de pedra, varanda de madeira em volta, escada externa, cúpula de bolha com nervuras de ouro)
#   C = Casa-Flor  (corpo oval, telhado em botão de pétalas sobrepostas, alpendre com cobertura e floreiras)
# Comuns: base de pedra com degraus, porta em arco com moldura, janelas redondas com peitoril, luminária e floreiras.
# Frente = -Y, pivô no chão (centro). Variações: A1 A2 B1 B2 C1 C2.
import math, random
import cb_lib as L

META = dict(id='Casa', titulo='Casa da Vila Encantada', pasta='Village', arquivo='CB_Casa')
TAU = math.tau
VAR = {
    'A1': dict(tipo='A', telhado='TelhadoRosa', janelas=4, chamine=0.6, flores='Petala'),
    'A2': dict(tipo='A', telhado='TelhadoTurquesa', janelas=5, chamine=-0.9, flores='PetalaLilas'),
    'B1': dict(tipo='B', telhado='VidroLilas', janelas=4, nervura='Dourado', flores='Petala'),
    'B2': dict(tipo='B', telhado='Vidro', janelas=6, nervura='DouradoEscovado', flores='PetalaLilas'),
    'C1': dict(tipo='C', telhado='TelhadoLilas', janelas=3, flores='Petala', tecido='TecidoRosa'),
    'C2': dict(tipo='C', telhado='TelhadoRosa', janelas=4, flores='PetalaLilas', tecido='Tecido'),
}

def ang_frente(a):  # rotação Z para um elemento modelado "de frente para -Y" olhar na direção do ângulo a
    return a + math.pi / 2

def janela(n, a, z, R, rj=0.9, N=3, quente=True):
    th = ang_frente(a); cx, cy = R * math.cos(a), R * math.sin(a)
    L.toro(f'{n}_moldura', rj, 0.16, (cx, cy, z), (math.pi / 2, 0, th), mat='MadeiraClara', grupo='Janelas', segM=28, segm=6)
    L.cilindro(f'{n}_vidro', rj - 0.05, rj - 0.05, 0.08, (cx - 0.02 * math.cos(a), cy - 0.02 * math.sin(a), z), (math.pi / 2, 0, th), mat='VidroLilas', grupo='Vidros', seg=24, chanfro=0)
    if N >= 3:
        L.caixa(f'{n}_peitoril', (rj * 2.2, 0.55, 0.18), (cx + 0.2 * math.cos(a), cy + 0.2 * math.sin(a), z - rj - 0.1), (0, 0, th), mat='PedraPerolada', grupo='Janelas', chanfro=0.06)
        L.caixa(f'{n}_cruzV', (0.08, 0.08, rj * 1.9), (cx, cy, z), (0, 0, th), mat='MadeiraClara', grupo='Janelas', chanfro=0)
        L.caixa(f'{n}_cruzH', (rj * 1.9, 0.08, 0.08), (cx, cy, z), (0, 0, th), mat='MadeiraClara', grupo='Janelas', chanfro=0)

def porta(n, a, z0, R, larg=2.6, alt=4.4, N=3):
    th = ang_frente(a); cx, cy = (R + 0.05) * math.cos(a), (R + 0.05) * math.sin(a)
    L.caixa(f'{n}_folha', (larg, 0.35, alt - larg / 2), (cx, cy, z0 + (alt - larg / 2) / 2), (0, 0, th), mat='Madeira', grupo='Porta', chanfro=0.06)
    L.cilindro(f'{n}_topo', larg / 2, larg / 2, 0.35, (cx + 0.175 * math.cos(a), cy + 0.175 * math.sin(a), z0 + alt - larg / 2), (math.pi / 2, 0, th), mat='Madeira', grupo='Porta', seg=24, chanfro=0)
    fx, fy = (R + 0.3) * math.cos(a), (R + 0.3) * math.sin(a)
    L.toro(f'{n}_arco', larg / 2 + 0.2, 0.2, (fx, fy, z0 + alt - larg / 2), (math.pi / 2, 0, th), mat='Dourado', grupo='Molduras', segM=24, segm=6, arco=math.pi)
    for s in (-1, 1):
        ox = s * (larg / 2 + 0.2)
        L.caixa(f'{n}_omb{s}', (0.4, 0.45, alt - larg / 2), (fx + ox * math.cos(th), fy + ox * math.sin(th), z0 + (alt - larg / 2) / 2), (0, 0, th), mat='Dourado', grupo='Molduras', chanfro=0.06)
    if N >= 3:
        L.esfera(f'{n}_macaneta', 0.15, (cx + 0.25 * math.cos(a) + 0.8 * math.cos(th), cy + 0.25 * math.sin(a) + 0.8 * math.sin(th), z0 + 2.0), mat='Dourado', grupo='Molduras', seg=8, aneis=6)
        for k in range(3):  # tábuas
            ox = (k - 1) * larg / 3
            L.caixa(f'{n}_tabua{k}', (0.05, 0.4, alt - larg / 2 - 0.3), (cx + ox * math.cos(th) + 0.02 * math.cos(a), cy + ox * math.sin(th) + 0.02 * math.sin(a), z0 + (alt - larg / 2) / 2), (0, 0, th), mat='MadeiraClara', grupo='Porta', chanfro=0)

def degraus(n, a, R, z_topo, larg=4.0, N=3):
    th = ang_frente(a); k = 0; z = z_topo
    while z > 0.05:
        h = min(0.6, z); d = R + 0.7 + k * 0.9
        L.caixa(f'{n}_d{k}', (larg + 0.6 - k * 0.2, 1.0, z), (d * math.cos(a), d * math.sin(a), z / 2), (0, 0, th), mat='PedraPerolada', grupo='Base', chanfro=0.12)
        z -= h; k += 1
    return k

def luminaria(n, x, y, z, N=3):
    L.torno(f'{n}_poste', [(0.35, 0), (0.35, 0.2), (0.16, 0.4), (0.13, 3.0), (0.25, 3.3), (0, 3.35)], (x, y, z), mat='DouradoEscovado', grupo='Luminarias', seg=12)
    L.esfera(f'{n}_bolha', 0.55, (x, y, z + 3.85), mat='Bolha', grupo='Luminarias', seg=20, aneis=10)
    L.esfera(f'{n}_luz', 0.22, (x, y, z + 3.85), mat='EnergiaRosa', grupo='Luminarias', seg=10, aneis=6)

def floreira(n, a, R, z, cor, N=3):
    th = ang_frente(a); cx, cy = (R + 0.4) * math.cos(a), (R + 0.4) * math.sin(a)
    L.caixa(f'{n}_caixa', (2.2, 0.7, 0.6), (cx, cy, z), (0, 0, th), mat='Madeira', grupo='Floreiras', chanfro=0.08)
    if N >= 3:
        r = random.Random(hash(n) & 0xffff)
        for k in range(5):
            ox = (k - 2) * 0.42
            L.esfera(f'{n}_f{k}', 0.28 + r.random() * 0.1, (cx + ox * math.cos(th), cy + ox * math.sin(th), z + 0.55), mat=cor, grupo='Flores', seg=10, aneis=6)
            L.esfera(f'{n}_fo{k}', 0.24, (cx + (ox + 0.2) * math.cos(th), cy + (ox + 0.2) * math.sin(th), z + 0.4), mat='Folha', grupo='Flores', seg=8, aneis=5)

def base(R, H=1.2, N=3):
    if N == 1:
        L.cilindro('Base', R + 1.2, R + 1.2, H, mat='PedraPerolada', seg=32, chanfro=0.15)
    else:
        L.torno('Base', [(0, 0), (R + 1.3, 0), (R + 1.3, H - 0.3), (R + 1.0, H), (0, H)], mat='PedraPerolada', grupo='Base', seg=48)
        L.toro('BaseFriso', R + 1.15, 0.1, (0, 0, H - 0.05), mat='Dourado', grupo='Molduras', segM=64, segm=6)

# ------------------------------------------------------------------ A: Casa-Cabaça
def casa_A(v, N):
    R = 5.6; H = 1.2
    base(R, H, N)
    perfil = [(R * 0.92, H), (R, H + 1.5), (R * 1.03, H + 3.5), (R * 0.97, H + 5.5), (R * 0.86, H + 7.0), (R * 0.75, H + 7.6)]
    L.torno('Corpo', perfil if N > 1 else [(R, H), (R, H + 7.6)], mat='Reboco', grupo='Corpo', seg=48)
    if N >= 2:
        L.toro('Cinta', R * 1.0 + 0.05, 0.22, (0, 0, H + 1.5), mat='PedraLilas', grupo='Molduras', segM=64, segm=8)
    # telhado curvo: cúpula alongada com beiral virado e ponta torcida
    zt = H + 7.4
    roof = [(R * 1.12, zt - 0.2), (R * 1.15, zt + 0.2), (R * 0.95, zt + 1.6), (R * 0.65, zt + 3.4), (R * 0.32, zt + 5.4), (R * 0.1, zt + 6.8), (0, zt + 7.4)]
    L.torno('Telhado', roof, mat=v['telhado'], grupo='Telhado', seg=48)
    if N >= 3:
        # telhas-pétala em duas fiadas sobre o beiral
        for fiada, (zz, rr, n) in enumerate(((zt + 0.4, R * 1.12, 18), (zt + 2.2, R * 0.86, 14))):
            for k in range(n):
                a = TAU * k / n + fiada * 0.17
                L.petala(f'Telha{fiada}_{k}', 2.4, 1.7, (rr * math.cos(a), rr * math.sin(a), zz + 1.5), (math.pi / 2 + 1.2, 0, a - math.pi / 2),
                         mat=v['telhado'], grupo='Telhas', curva=-0.15, concha=0.25, esp=0.12, nu=6, nv=4)
        L.torno('Ponta', [(0.35, 0), (0.15, 0.8), (0.05, 1.6), (0, 1.9)], (0, 0, zt + 7.2), (0.2, 0, 0), mat='Dourado', grupo='Molduras', seg=12)
        # chaminé-cogumelo
        cx = v['chamine'] * 2.8; cy = 1.8
        L.cilindro('Chamine', 0.55, 0.65, 4.2, (cx, cy, zt + 2.4), mat='PedraPerolada', grupo='Chamine', seg=16)
        L.torno('ChapeuChamine', [(0.3, 0), (1.3, 0.2), (1.1, 0.7), (0.4, 1.0), (0, 1.05)], (cx, cy, zt + 6.5), mat='CogumeloRosa', grupo='Chamine', seg=24)
    nj = v['janelas']
    for k in range(nj):
        a = -math.pi / 2 + (k + 1) * TAU / (nj + 1)
        janela(f'Jan{k}', a, H + 3.8, R * 1.02, 0.95, N)
        if N >= 3 and k % 2 == 0: floreira(f'Flo{k}', a, R * 1.02, H + 2.4, v['flores'], N)
    janela('JanAlta', -math.pi / 2, H + 6.2, R * 0.86, 0.6, N)
    porta('Porta', -math.pi / 2, H, R * 1.0, N=N)
    degraus('Deg', -math.pi / 2, R + 0.6, H, N=N)
    if N >= 2:
        for s in (-1, 1): luminaria(f'Lum{s}', s * 2.6, -(R + 1.4), H, N)
    return R + 2.5, zt + 7.4

# ------------------------------------------------------------------ B: Casa-Concha
def casa_B(v, N):
    R = 5.2; H = 1.2; H1 = H + 5.0
    base(R + 0.6, H, N)
    L.torno('Terreo', [(R, H), (R + 0.2, H + 0.6), (R + 0.1, H1 - 0.6), (R + 0.5, H1)] if N > 1 else [(R, H), (R, H1)], mat='PedraLilas', grupo='Corpo', seg=48)
    # piso da varanda em volta (madeira), guarda-corpo
    RV = R + 2.6
    L.torno('Varanda', [(R, H1), (RV, H1), (RV + 0.2, H1 + 0.25), (RV, H1 + 0.5), (R, H1 + 0.5)], mat='MadeiraClara', grupo='Varanda', seg=56, suave=False)
    zs = H1 + 0.5
    # andar de cima: tambor de reboco + cúpula de bolha com nervuras
    R2 = R * 0.82
    L.torno('Andar', [(R2, zs), (R2 + 0.15, zs + 2.6), (R2 + 0.3, zs + 3.0)], mat='Reboco', grupo='Corpo', seg=48)
    zd = zs + 3.0
    L.cilindro('PisoSup', R2 + 0.1, R2 + 0.1, 0.3, (0, 0, zs - 0.3), mat='MadeiraClara', grupo='Varanda', seg=48, chanfro=0)
    if N >= 3:  # interior visível pela cúpula: mesa redonda e luminária
        L.cilindro('Mesa', 1.2, 1.2, 0.2, (1.0, 0.5, zs + 1.2), mat='Madeira', grupo='Interior', seg=20, chanfro=0.05)
        L.cilindro('PeMesa', 0.18, 0.3, 1.2, (1.0, 0.5, zs), mat='Madeira', grupo='Interior', seg=10, chanfro=0)
        L.esfera('LuzInterna', 0.4, (1.0, 0.5, zs + 1.8), mat='EnergiaRosa', grupo='Interior', seg=12, aneis=8)
    L.esfera('Cupula', R2 + 0.2, (0, 0, zd), (1, 1, 0.85), mat=v['telhado'] if N > 1 else 'Blockout', grupo='Cupula', seg=48, aneis=24)
    if N >= 2:
        L.toro('AroCupula', R2 + 0.3, 0.28, (0, 0, zd), mat=v['nervura'], grupo='Molduras', segM=64, segm=8)
        for k in range(8):
            a = TAU * k / 8
            L.toro(f'Nervura{k}', R2 + 0.25, 0.14, (0, 0, zd), (math.pi / 2, 0, a), mat=v['nervura'], grupo='Molduras', segM=40, segm=6, arco=math.pi, esc=(1, 0.85, 1))
        L.torno('Pinaculo', [(0.6, 0), (0.4, 0.6), (0.15, 1.6), (0.35, 2.0), (0, 2.6)], (0, 0, zd + (R2 + 0.2) * 0.85 - 0.1), mat=v['nervura'], grupo='Molduras', seg=12)
        # guarda-corpo da varanda (com vão na escada, em +X)
        for k in range(36):
            a = TAU * k / 36
            if abs(a - 0.0) < 0.22 or abs(a - TAU) < 0.22: continue
            L.cilindro(f'Bal{k}', 0.1, 0.1, 2.0, ((RV - 0.3) * math.cos(a), (RV - 0.3) * math.sin(a), zs), mat='MadeiraClara', grupo='GuardaCorpo', seg=6, chanfro=0)
        L.toro('Corrimao', RV - 0.3, 0.14, (0, 0, zs + 2.0), (0, 0, 0.22), mat='Madeira', grupo='GuardaCorpo', segM=64, segm=6, arco=TAU - 0.44)
        # mãos-francesas sob a varanda
        for k in range(10):
            a = TAU * k / 10 + 0.3
            L.tubo(f'MaoF{k}', [((R + 0.2) * math.cos(a), (R + 0.2) * math.sin(a), H1 - 2.2), ((RV - 1.0) * math.cos(a), (RV - 1.0) * math.sin(a), H1 - 0.6), ((RV - 0.3) * math.cos(a), (RV - 0.3) * math.sin(a), H1 - 0.05)], 0.18, mat='Madeira', grupo='Varanda', seg=6)
        # escada externa curva: sobe pelo lado +X até a varanda
        nd = 9; zstep = (zs - H) / nd
        for i in range(nd):
            a = 0.35 - i * 0.16; rr = RV + 1.0
            L.caixa(f'EscExt{i}', (2.2, 1.2, 0.35), (rr * math.cos(a), rr * math.sin(a), H + (i + 1) * zstep - 0.18), (0, 0, a), mat='MadeiraClara', grupo='Escada', chanfro=0.06)
            L.cilindro(f'EscPe{i}', 0.14, 0.14, H + (i + 1) * zstep - 0.35, ((rr + 0.8) * math.cos(a), (rr + 0.8) * math.sin(a), 0), mat='Madeira', grupo='Escada', seg=6, chanfro=0)
        L.tubo('EscCorrimao', [((RV + 1.9) * math.cos(0.35 - i * 0.16), (RV + 1.9) * math.sin(0.35 - i * 0.16), H + (i + 1) * zstep + 1.8) for i in range(0, nd, 2)], 0.1, mat='Dourado', grupo='Escada', seg=6)
    nj = v['janelas']
    for k in range(nj):
        a = -math.pi / 2 + (k + 1) * TAU / (nj + 1)
        janela(f'JanT{k}', a, H + 2.9, R + 0.15, 0.85, N)
        janela(f'JanS{k}', a + 0.3, zs + 1.5, R2 + 0.12, 0.7, N)
        if N >= 3 and k % 2 == 1: floreira(f'Flo{k}', a + 0.3, R2 + 0.1, zs + 0.4, v['flores'], N)
    porta('Porta', -math.pi / 2, H, R + 0.1, N=N)
    porta('PortaSup', -math.pi / 2 + 0.6, zs, R2 + 0.05, 2.2, 3.6, N=N)
    degraus('Deg', -math.pi / 2, R + 1.0, H, N=N)
    if N >= 2: luminaria('Lum', -3.2, -(R + 2.4), H, N)
    return RV + 3.5, zd + R2 * 0.85 + 2.6

# ------------------------------------------------------------------ C: Casa-Flor
def casa_C(v, N):
    R = 6.4; H = 1.2; SY = 0.82  # oval
    base(R, H, N)
    perfil = [(R * 0.95, H), (R, H + 1.0), (R * 1.02, H + 4.5), (R * 0.96, H + 5.6)]
    L.torno('Corpo', perfil if N > 1 else [(R, H), (R, H + 5.6)], mat='Reboco', grupo='Corpo', seg=48, esc=(1, SY, 1))
    zt = H + 5.3
    if N == 1:
        L.torno('Telhado', [(R * 1.1, zt), (R * 0.9, zt + 3), (0, zt + 7)], mat=v['telhado'], grupo='Telhado', seg=32, esc=(1, SY, 1))
    else:
        L.torno('TelhadoNucleo', [(R * 0.95, zt), (R * 0.75, zt + 3.0), (R * 0.4, zt + 6.0), (0, zt + 7.6)], mat=v['telhado'], grupo='Telhado', seg=40, esc=(1, SY, 1))
        # pétalas sobrepostas em botão (3 fiadas)
        for fiada, (n, comp, larg, zz, rr, inc) in enumerate(((10, 6.4, 4.6, zt - 0.4, R * 0.98, 0.95), (8, 5.6, 4.0, zt + 1.9, R * 0.72, 0.62), (6, 4.6, 3.2, zt + 4.0, R * 0.42, 0.35))):
            for k in range(n):
                a = TAU * k / n + fiada * 0.3
                L.petala(f'PetalaT{fiada}_{k}', comp, larg, (rr * math.cos(a), rr * SY * math.sin(a), zz), (math.pi / 2 - inc, 0, a - math.pi / 2),
                         mat=v['telhado'], grupo='Telhas', curva=0.35, concha=0.35, esp=0.25, nu=10, nv=6)
        L.torno('Botao', [(0.9, 0), (1.0, 0.5), (0.6, 1.2), (0, 1.6)], (0, 0, zt + 7.3), mat='Dourado', grupo='Molduras', seg=16)
    # alpendre na frente: estrado de madeira, colunas, cobertura de tecido curvada
    if N >= 2:
        yA = -(R * SY + 2.2)
        L.caixa('Alpendre', (8.4, 4.4, 0.35), (0, yA + 0.6, H + 0.18), mat='MadeiraClara', grupo='Alpendre', chanfro=0.08)
        for s in (-1, 1):
            L.torno(f'Coluna{s}', [(0.32, 0), (0.25, 0.4), (0.2, 3.6), (0.35, 4.0), (0, 4.05)], (s * 3.8, yA - 1.2, H + 0.35), mat='MadeiraClara', grupo='Alpendre', seg=12)
        L.petala('Cobertura', 5.2, 9.6, (0, -(R * SY) + 0.2, H + 4.6), (math.pi - 0.25, 0, math.pi), mat=v['tecido'], grupo='Cobertura', curva=0.12, concha=0.12, esp=0.12, nu=8, nv=10, ponta=0.3)
        if N >= 3:
            L.caixa('Banco', (3.0, 0.9, 0.3), (2.0, yA + 0.9, H + 1.1), mat='Madeira', grupo='Alpendre', chanfro=0.06)
            for s in (-1, 1): L.caixa(f'PeBanco{s}', (0.25, 0.8, 0.75), (2.0 + s * 1.2, yA + 0.9, H + 0.72), mat='Madeira', grupo='Alpendre', chanfro=0.04)
            L.cilindro('Vaso', 0.5, 0.7, 0.9, (-3.0, yA + 0.6, H + 0.35), mat='PedraLilas', grupo='Alpendre', seg=16)
            L.esfera('Arbusto', 0.9, (-3.0, yA + 0.6, H + 1.6), (1, 1, 0.8), mat='FolhaEscura', grupo='Flores', seg=12, aneis=8)
    nj = v['janelas']
    for k in range(nj):
        a = -math.pi / 2 + (k + 1) * TAU / (nj + 1) + 0.25
        x, y = R * math.cos(a), R * SY * math.sin(a); rr = math.hypot(x, y); aa = math.atan2(y, x)
        janela(f'Jan{k}', aa, H + 3.0, rr * 1.02, 1.0, N)
        if N >= 3: floreira(f'Flo{k}', aa, rr * 1.02, H + 1.6, v['flores'], N)
    porta('Porta', -math.pi / 2, H, R * SY, 2.8, 4.4, N=N)
    degraus('Deg', -math.pi / 2, R * SY + 2.2 + (1.6 if N >= 2 else 0), H, larg=5.0, N=N)
    if N >= 2: luminaria('Lum', 4.6, -(R * SY + 4.6), H, N)
    return R + 3, zt + 8.5

def build(N=3, var='A1'):
    v = VAR[var]; root = L.raiz(f'CB_Casa_{var}')
    R, Ht = {'A': casa_A, 'B': casa_B, 'C': casa_C}[v['tipo']](v, N)
    L.consolidar(f'CB_Casa_{var}', root)
    r0 = {'A': 5.8, 'B': 5.8, 'C': 6.6}[v['tipo']]
    L.colisor(root, 'Base', (2 * r0 + 2, 2 * r0 + 2, 1.2), (0, 0, 0.6))
    L.colisor(root, 'Corpo_A', (2 * r0, 2 * r0 * 0.7, Ht * 0.6), (0, 0, 1.2 + Ht * 0.3))
    L.colisor(root, 'Corpo_B', (2 * r0 * 0.7, 2 * r0, Ht * 0.6), (0, 0, 1.2 + Ht * 0.3))
    if v['tipo'] == 'B':
        L.colisor(root, 'Varanda', (2 * (r0 + 2.4), 2 * (r0 + 2.4), 0.5), (0, 0, 6.45))
    return dict(root=root, centro=(0, 0, Ht * 0.45), raio=max(R, Ht * 0.6), frente=(0, -1), chao=45, animaveis=[], flutuantes=[],
                detalhes=[dict(alvo=(0, -R * 0.75, 4.0), raio=4.8, dir=(0.45, -1), elev=0.15)])
