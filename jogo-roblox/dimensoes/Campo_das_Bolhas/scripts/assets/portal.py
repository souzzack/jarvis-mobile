# A. Portal Dimensional — anel oval perolado sobre estrado redondo, pétalas que abrem atrás (mecanismo das Bolhas),
# anéis suspensos, inscrições luminosas, película de bolha e núcleo energético. Frente = -Y. Pivô no chão, no centro.
import math
import cb_lib as L

META = dict(id='Portal', titulo='Portal Dimensional', pasta='Portal', arquivo='CB_Portal')
TAU = math.tau

def cristal_bolha(nome, loc, s=1.0, sem=1, mat='Cristal'):
    """Cristal do Campo das Bolhas: 'bolha cristalizada' — cacho de esferas facetadas."""
    import random; r = random.Random(sem)
    for k in range(4):
        rr = s * (0.9 - k * 0.17); dx = (r.random() - 0.5) * s * 1.2; dy = (r.random() - 0.5) * s * 1.2
        L.rocha(f'{nome}_{k}', rr, (loc[0] + dx, loc[1] + dy, loc[2] + rr * 0.75), (1, 1, 1.05), (0, 0, r.random() * TAU),
                mat=mat, grupo='Cristais', semente=sem * 10 + k, sub=1, aspereza=0.06)

def build(N=3):
    root = L.raiz('CB_Portal')
    H = 2.4                     # topo do estrado
    R, r = 8.5, 1.1             # anel principal (raio médio, espessura)
    EZ = 1.15                   # oval: alongado na vertical
    CZ = H + R * EZ + r - 0.45  # centro do anel (encostado no estrado)
    # --- estrado redondo de 3 degraus
    if N == 1:
        L.cilindro('Estrado', 13, 13, H, mat='PedraPerolada', seg=48, chanfro=0.2)
    else:
        L.torno('Estrado', [(0, 0), (13, 0), (13, 0.8), (12.2, 0.8), (12.2, 1.6), (11.4, 1.6), (11.4, H), (0, H)], mat='PedraPerolada', seg=72, suave=False)
        for z, rr in ((0.8, 13.0), (1.6, 12.2), (H, 11.4)):
            L.toro(f'Friso{z}', rr, 0.09, (0, 0, z), mat='Dourado', grupo='Frisos', segM=96, segm=6)
    # --- anel principal
    L.toro('Anel', R, r, (0, 0, CZ), (math.pi / 2, 0, 0), mat='Perola', grupo='Anel', segM=96 if N > 1 else 48, segm=20 if N > 1 else 10, esc=(1, EZ, 1))
    # berço sob o anel
    L.caixa('Berco', (5.5, 3.0, 1.4), (0, 0, H + 0.55), mat='PedraPerolada', grupo='Anel', chanfro=0.35)
    # --- núcleo energético e película
    L.esfera('Nucleo', 1.4, (0, 0, CZ), mat='EnergiaTurquesa', grupo='Nucleo', seg=32, aneis=16)
    if N >= 2:
        L.cilindro('Pelicula', R - r * 0.8, R - r * 0.8, 0.06, (0, 0.03, CZ), (math.pi / 2, 0, 0), mat='Bolha', grupo='Pelicula', seg=96, chanfro=0)
        me = L._PECAS[-1].data  # oval: estica a película na vertical em volta do centro do anel
        for v in me.vertices: v.co.z = CZ + (v.co.z - CZ) * EZ
    # --- pétalas que abrem atrás do anel (abraçam o anel)
    if N == 1:
        for k in (-1, 0, 1):
            L.caixa(f'PetalaBloco{k}', (5, 1.2, 14), (k * 7, 4.5 - abs(k) * 1.5, H + 7), (0.2, 0, -k * 0.5), mat='Petala', grupo='Petalas', chanfro=0.4)
    else:
        n = 7
        for k in range(n):
            f = -1 + 2 * k / (n - 1); phi = f * math.radians(105)
            comp = 17 - 3.5 * abs(f); larg = 7.5 - 1.5 * abs(f)
            bx = 7.5 * math.sin(phi); by = 1.8 + 7.5 * math.cos(phi) * 0.75
            lean = 0.32 + 0.25 * abs(f)
            mat = 'Petala' if k % 2 == 0 else 'PetalaLilas'
            L.petala(f'Petala{k}', comp, larg, (bx, by, H - 0.4), (math.pi / 2 - lean, 0, -phi), mat=mat, grupo='Petalas',
                     curva=0.32, concha=0.35, esp=0.35, nu=16, nv=10)
            if N >= 3:  # nervura dourada no meio da pétala
                pts = []
                for i in range(7):
                    u = i / 6; y = u * comp; z = 0.32 * comp * u * u + 0.36
                    import mathutils
                    p = mathutils.Matrix.Translation((bx, by, H - 0.4)) @ mathutils.Euler((math.pi / 2 - lean, 0, -phi)).to_matrix().to_4x4() @ mathutils.Vector((0, y, z))
                    pts.append(tuple(p))
                L.tubo(f'Nervura{k}', pts, 0.12, mat='Dourado', grupo='Frisos', seg=6)
        # sépalas verdes na base das pétalas (prende as pétalas no estrado)
        for k in range(9):
            phi = -math.radians(120) + k * math.radians(30)
            L.petala(f'Sepala{k}', 4.5, 3.2, (6.2 * math.sin(phi), 1.5 + 6.2 * math.cos(phi) * 0.8, H - 0.3), (math.pi / 2 - 1.05, 0, -phi),
                     mat='Folha', grupo='Sepalas', curva=0.25, concha=0.3, esp=0.25, nu=8, nv=6)
    # --- anéis suspensos (giram no Roblox; flutuam de propósito em volta do anel)
    flut = []
    if N >= 2:
        L.toro('AnelSuspenso1', R + 2.3, 0.28, (0, 0, CZ), (math.pi / 2 + 0.38, 0.22, 0), mat='Dourado', grupo='AnelSuspenso1', segM=96, segm=10, esc=(1, EZ, 1))
        L.toro('AnelSuspenso2', R + 3.4, 0.2, (0, 0, CZ), (math.pi / 2 - 0.3, -0.35, 0), mat='DouradoEscovado', grupo='AnelSuspenso2', segM=96, segm=8, esc=(1, EZ, 1))
        flut = ['AnelSuspenso1', 'AnelSuspenso2']
        # luminárias de bolha nas laterais da frente
        for s in (-1, 1):
            x, y = s * 8.6, -6.8
            L.torno(f'Poste{s}', [(0.55, 0), (0.55, 0.3), (0.32, 0.5), (0.24, 3.5), (0.34, 4.6), (0.5, 4.9), (0, 5.0)], (x, y, H), mat='PedraPerolada', grupo='Luminarias', seg=16)
            L.esfera(f'LampadaBolha{s}', 0.9, (x, y, H + 5.85), mat='Bolha', grupo='Luminarias', seg=24, aneis=12)
            L.esfera(f'LampadaLuz{s}', 0.38, (x, y, H + 5.85), mat='EnergiaRosa', grupo='Luminarias', seg=12, aneis=8)
            if N >= 3:
                L.toro(f'LampadaAro{s}', 0.6, 0.08, (x, y, H + 5.05), mat='Dourado', grupo='Frisos', segM=24, segm=6)
    # --- detalhes finais: embutidos de ouro, inscrições, runas do piso, redemoinho do núcleo, cristais
    if N >= 3:
        for yy in (-r * 0.98, r * 0.98):
            L.toro(f'Embutido{yy:.1f}', R, 0.16, (0, yy, CZ), (math.pi / 2, 0, 0), mat='Dourado', grupo='Frisos', segM=96, segm=6, esc=(1, EZ, 1))
        ng = 28
        for face in (-1, 1):
            for k in range(ng):
                a = TAU * k / ng
                x = (R + 0.55) * math.cos(a); z = CZ + (R + 0.55) * math.sin(a) * EZ
                if k % 4 == 0:
                    L.toro(f'Glifo{face}_{k}', 0.24, 0.05, (x, face * (r * 0.62), z), (math.pi / 2, 0, 0), mat='Inscricao', grupo='Inscricoes', segM=12, segm=4)
                else:
                    L.caixa(f'Glifo{face}_{k}', (0.12, 0.08, 0.5 + 0.2 * (k % 3)), (x, face * (r * 0.66), z), (0, -a + math.pi / 2, 0), mat='Inscricao', grupo='Inscricoes', chanfro=0.03)
        for rr in (5.6, 9.6):
            L.toro(f'RunaPiso{rr}', rr, 0.12, (0, 0, H + 0.01), mat='Inscricao', grupo='Inscricoes', segM=96, segm=4, esc=(1, 1, 0.3))
        for k in range(12):
            a = TAU * k / 12
            L.caixa(f'RunaRaio{k}', (0.16, 2.6, 0.05), (7.6 * math.cos(a), 7.6 * math.sin(a), H + 0.02), (0, 0, a + math.pi / 2), mat='Inscricao', grupo='Inscricoes', chanfro=0.02)
        for k, (rr, rz) in enumerate(((2.2, 0.4), (2.8, -0.5))):
            L.toro(f'Redemoinho{k}', rr, 0.07, (0, 0, CZ), (math.pi / 2 + rz, rz, 0), mat='EnergiaRosa', grupo='Nucleo', segM=48, segm=4)
        for k, (x, y) in enumerate(((-10.6, -3.5), (10.4, -2.8), (-6.5, 6.5), (7.2, 6.0))):
            cristal_bolha(f'Cristal{k}', (x, y, H - 0.3 if math.hypot(x, y) < 11.4 else 0.6), 1.3 + 0.3 * (k % 2), sem=k + 1, mat='Cristal' if k % 2 == 0 else 'CristalRosa')
    anim = ['AnelSuspenso1', 'AnelSuspenso2', 'Nucleo', 'Petalas']
    objs = L.consolidar('CB_Portal', root)
    # colisores: estrado (octógono = 2 caixas), lados do anel, berço; gatilho do teleporte na película
    L.colisor(root, 'Estrado_A', (26, 18, H), (0, 0, H / 2)); L.colisor(root, 'Estrado_B', (18, 26, H), (0, 0, H / 2))
    for s in (-1, 1): L.colisor(root, f'AnelLado{s}', (2.4, 2.4, 2 * R * EZ), (s * R, 0, CZ))
    L.colisor(root, 'AnelTopo', (2 * R, 2.4, 2.4), (0, 0, CZ + R * EZ))
    trg = L.colisor(root, 'GatilhoTeleporte', (2 * (R - r), 1.0, 2 * (R - r) * EZ), (0, 0, CZ)); trg.name = 'TRG_Teleporte'
    return dict(root=root, centro=(0, 0, CZ * 0.75), raio=16, frente=(0, -1), animaveis=anim, flutuantes=flut, chao=70,
                detalhes=[dict(alvo=(0, -1.2, CZ + 2.5), raio=6.5, dir=(0.35, -1), elev=0.1),
                          dict(alvo=(8.0, -6.5, H + 3), raio=5.5, dir=(0.6, -1), elev=0.25)])
