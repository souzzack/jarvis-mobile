# B. Gerador de Bolhas (Flor-Mãe) — torre monumental: base com raízes-contraforte, caule de pérola com cintas de ouro,
# três reservatórios translúcidos com líquido, condutos em espiral, mecanismo circular, plataforma de manutenção com
# guarda-corpo e escada, coroa de pétalas e a bolha-lago no topo. Frente = -Y. Pivô no chão, no centro.
import math, random
from mathutils import Vector, Matrix, Euler
import cb_lib as L
from portal import cristal_bolha

META = dict(id='Gerador', titulo='Gerador de Bolhas (Flor-Mãe)', pasta='BubbleGenerator', arquivo='CB_GeradorDeBolhas')
TAU = math.tau

def r_caule(z):  # raio do caule em função da altura (êntase suave)
    return 4.2 - 1.5 * (z / 36.0) + 0.35 * math.sin(z / 36.0 * math.pi)

def build(N=3):
    root = L.raiz('CB_GeradorDeBolhas')
    HB = 3.0       # topo da base
    HP = 24.0      # piso da plataforma de manutenção
    HT = 38.0      # topo do caule (início da coroa)
    # --- base: plinto redondo com degraus e raízes-contraforte
    if N == 1:
        L.cilindro('Base', 15, 15, HB, mat='PedraPerolada', seg=48, chanfro=0.3)
    else:
        L.torno('Base', [(0, 0), (15.5, 0), (15.5, 0.9), (14.6, 0.9), (14.6, 1.9), (13.6, 1.9), (13.6, HB), (0, HB)], mat='PedraPerolada', seg=80, suave=False)
        for z, rr in ((0.9, 15.5), (1.9, 14.6), (HB, 13.6)):
            L.toro(f'FrisoBase{z}', rr, 0.1, (0, 0, z), mat='Dourado', grupo='Frisos', segM=110, segm=6)
    # caule (torno com êntase)
    prof = [(r_caule(z), z) for z in [i * 2.0 for i in range(0, 20)]] + [(r_caule(HT), HT)]
    prof = [(prof[0][0] + 1.2, HB - 0.2)] + [(rr, zz + HB) for rr, zz in prof]
    L.torno('Caule', prof, mat='PedraPerolada', grupo='Caule', seg=48 if N > 1 else 24)
    if N >= 2:
        # raízes-contraforte: pétalas grossas que descem do caule e se apoiam na base
        for k in range(8):
            a = TAU * k / 8 + TAU / 16
            L.petala(f'Raiz{k}', 9.5, 3.4, (2.6 * math.cos(a), 2.6 * math.sin(a), HB + 11.5), (math.pi / 2 + 1.95, 0, a - math.pi / 2),
                     mat='PedraPerolada', grupo='Raizes', curva=-0.18, concha=0.25, esp=0.9, nu=12, nv=6, ponta=0.6)
        # cintas de ouro no caule
        for z in (6, 12, 18, 30, 34):
            L.toro(f'Cinta{z}', r_caule(z) + 0.15, 0.28, (0, 0, HB + z), mat='Dourado', grupo='Frisos', segM=64, segm=8)
    # --- reservatórios translúcidos (3) com líquido e suportes
    for k in range(3):
        a = TAU * k / 3 - math.pi / 2 + math.pi / 3
        R = 3.6; d = r_caule(14) + R + 0.8; cx, cy, cz = d * math.cos(a), d * math.sin(a), HB + 14.5
        L.esfera(f'Reservatorio{k}', R, (cx, cy, cz), mat='Vidro' if N > 1 else 'Blockout', grupo='Reservatorios', seg=40, aneis=20)
        if N >= 2:
            nivel = 0.15 + 0.2 * k  # líquido até parte da altura
            prof_l = []
            for i in range(13):
                t = -1 + (1 + nivel) * i / 12; zz = t * (R - 0.25)
                prof_l.append((math.sqrt(max(0.0, (R - 0.25) ** 2 - zz * zz)), zz))
            prof_l = [(0, prof_l[0][1])] + prof_l + [(0, prof_l[-1][1])]
            L.torno(f'Liquido{k}', prof_l, (cx, cy, cz), mat='Agua', grupo='Liquido', seg=40)
            L.toro(f'AroRes{k}', R + 0.05, 0.22, (cx, cy, cz), (math.pi / 2, 0, a), mat='Dourado', grupo='Frisos', segM=64, segm=8)
            L.toro(f'AroResH{k}', R + 0.05, 0.18, (cx, cy, cz), mat='DouradoEscovado', grupo='Frisos', segM=64, segm=8)
            # braço de sustentação até o caule e pé até a base
            L.caixa(f'Braco{k}', (d - R + 0.4, 1.0, 0.9), ((d - R) / 2 * math.cos(a), (d - R) / 2 * math.sin(a), cz), (0, 0, a), mat='DouradoEscovado', grupo='Suportes', chanfro=0.2)
            L.cilindro(f'Pe{k}', 0.6, 0.8, cz - R - HB + 0.3, (cx, cy, HB - 0.1), mat='PedraPerolada', grupo='Suportes', seg=16)
            L.torno(f'Calice{k}', [(0.6, 0), (1.6, 0.6), (2.4, 1.4), (0, 1.4)], (cx, cy, cz - R - 0.9), mat='Dourado', grupo='Suportes', seg=24)
            # tampa e conduto que sobe do reservatório ao caule
            L.torno(f'Tampa{k}', [(0, 0), (1.3, 0), (1.1, 0.7), (0.5, 1.0), (0, 1.1)], (cx, cy, cz + R - 0.2), mat='Dourado', grupo='Suportes', seg=24)
    # --- condutos em espiral (vidro com fio de energia por dentro)
    if N >= 2:
        for k in range(3):
            pts = []
            for i in range(26):
                t = i / 25; z = HB + 4 + t * (HT - 6); a = TAU * (k / 3 + t * 1.25)
                rr = r_caule(z - HB) + 0.75
                pts.append((rr * math.cos(a), rr * math.sin(a), z))
            L.tubo(f'Conduto{k}', pts, 0.42, mat='Vidro', grupo='Condutos', seg=10, res=4)
            if N >= 3: L.tubo(f'Fio{k}', pts, 0.16, mat='EnergiaTurquesa', grupo='Energia', seg=6, res=4)
    # --- mecanismo circular (anel dentado que gira) logo abaixo da plataforma
    if N >= 2:
        zm = HB + HP - 3.2
        L.toro('MecanismoAnel', 6.2, 0.55, (0, 0, zm), mat='DouradoEscovado', grupo='Mecanismo', segM=72, segm=10)
        if N >= 3:
            for k in range(36):
                a = TAU * k / 36
                L.caixa(f'Dente{k}', (0.6, 0.9, 0.7), (6.9 * math.cos(a), 6.9 * math.sin(a), zm), (0, 0, a), mat='Dourado', grupo='Mecanismo', chanfro=0.1)
            for k in range(6):
                a = TAU * k / 6
                L.caixa(f'Raio{k}', (6.2 - r_caule(HP - 3.2), 0.4, 0.4), ((6.2 + r_caule(HP - 3.2)) / 2 * math.cos(a), (6.2 + r_caule(HP - 3.2)) / 2 * math.sin(a), zm), (0, 0, a), mat='DouradoEscovado', grupo='Mecanismo', chanfro=0.08)
            for k in range(4):  # engrenagens menores presas ao anel
                a = TAU * k / 4 + 0.4
                L.cilindro(f'Engrenagem{k}', 1.3, 1.3, 0.6, (7.9 * math.cos(a), 7.9 * math.sin(a), zm - 0.3), mat='Dourado', grupo='Mecanismo', seg=12, chanfro=0.08)
                L.cilindro(f'EixoEng{k}', 0.25, 0.25, 1.4, (7.9 * math.cos(a), 7.9 * math.sin(a), zm - 0.7), mat='DouradoEscovado', grupo='Mecanismo', seg=8, chanfro=0)
    # --- plataforma de manutenção (anel caminhável) com guarda-corpo, mãos-francesas e escada
    rp_in, rp_out = r_caule(HP) - 0.2, 9.0
    if N == 1:
        L.cilindro('Plataforma', rp_out, rp_out, 0.8, (0, 0, HB + HP - 0.8), mat='MadeiraClara', seg=40, chanfro=0.1)
    else:
        L.torno('Plataforma', [(rp_in, 0), (rp_out, 0), (rp_out + 0.3, 0.3), (rp_out, 0.8), (rp_in, 0.8)], (0, 0, HB + HP - 0.8), mat='MadeiraClara', grupo='Plataforma', seg=72, suave=False)
        L.toro('BordaPlat', rp_out + 0.1, 0.2, (0, 0, HB + HP - 0.4), mat='Dourado', grupo='Frisos', segM=96, segm=6)
        for k in range(10):  # mãos-francesas curvas sob a plataforma
            a = TAU * k / 10
            p0 = (r_caule(HP - 6) * math.cos(a), r_caule(HP - 6) * math.sin(a), HB + HP - 6)
            p1 = ((rp_out - 2.5) * math.cos(a), (rp_out - 2.5) * math.sin(a), HB + HP - 2.2)
            p2 = ((rp_out - 0.5) * math.cos(a), (rp_out - 0.5) * math.sin(a), HB + HP - 0.9)
            L.tubo(f'MaoFrancesa{k}', [p0, p1, p2], 0.32, mat='DouradoEscovado', grupo='Plataforma', seg=8)
        # guarda-corpo: montantes, corrimão e travessa (vão de 2,4 studs onde chega a escada, em -Y)
        aesc = -math.pi / 2; gap = 2.6 / rp_out
        for k in range(40):
            a = TAU * k / 40
            if abs(math.atan2(math.sin(a - aesc), math.cos(a - aesc))) < gap: continue
            L.cilindro(f'Montante{k}', 0.12, 0.12, 3.2, ((rp_out - 0.35) * math.cos(a), (rp_out - 0.35) * math.sin(a), HB + HP), mat='Dourado', grupo='GuardaCorpo', seg=8, chanfro=0)
        for zz, rr in ((3.2, 0.16), (1.6, 0.08)):
            L.toro(f'Corrimao{zz}', rp_out - 0.35, rr, (0, 0, HB + HP + zz), (0, 0, aesc + gap), mat='Dourado', grupo='GuardaCorpo', segM=96, segm=6, arco=TAU - 2 * gap)
        # escada de mão no caule, da base até a plataforma (lado -Y)
        ze0, ze1 = HB, HB + HP
        for s in (-1, 1):
            pts = [(s * 0.7, -(r_caule(z - HB) + 0.35), z) for z in (ze0, (ze0 + ze1) / 2, ze1 + 1.2)]
            L.tubo(f'Banzo{s}', pts, 0.12, mat='DouradoEscovado', grupo='Escada', seg=6)
        for i in range(int((ze1 - ze0) / 0.9)):
            z = ze0 + 0.6 + i * 0.9
            L.cilindro(f'Degrau{i}', 0.08, 0.08, 1.4, (-0.7, -(r_caule(z - HB) + 0.35), z), (0, math.pi / 2, 0), mat='Dourado', grupo='Escada', seg=6, chanfro=0)
        # painel de controle na plataforma
        if N >= 3:
            a = math.radians(30); px, py = (rp_out - 1.5) * math.cos(a), (rp_out - 1.5) * math.sin(a)
            L.caixa('Painel', (1.6, 0.6, 1.3), (px, py, HB + HP + 0.65), (0, 0, a + math.pi / 2), mat='DouradoEscovado', grupo='Plataforma', chanfro=0.12)
            for j in range(3):
                L.esfera(f'Botao{j}', 0.13, (px + 0.3 * (j - 1) * math.cos(a + math.pi / 2), py + 0.3 * (j - 1) * math.sin(a + math.pi / 2), HB + HP + 1.35), mat='EnergiaRosa' if j == 1 else 'EnergiaTurquesa', grupo='Energia', seg=8, aneis=6)
    # --- coroa: sépalas e pétalas abertas, com a bolha-lago no topo
    ZC = HB + HT
    if N == 1:
        L.torno('Coroa', [(r_caule(HT), 0), (12, 4), (14, 7), (0, 7)], (0, 0, ZC - 0.5), mat='Petala', grupo='Petalas', seg=24)
        L.esfera('BolhaLago', 8, (0, 0, ZC + 12), mat='Bolha', grupo='BolhaLago', seg=32, aneis=16)
    else:
        L.torno('Receptaculo', [(r_caule(HT) - 0.1, -1.5), (3.4, 0), (5.5, 1.6), (6.2, 2.6), (5.2, 3.2), (0, 3.3)], (0, 0, ZC), mat='Caule', grupo='Coroa', seg=48)
        for k in range(10):  # sépalas verdes por baixo
            a = TAU * k / 10
            L.petala(f'SepalaC{k}', 7.0, 3.6, (2.6 * math.cos(a), 2.6 * math.sin(a), ZC + 0.6), (math.pi / 2 - 1.95, 0, a - math.pi / 2),
                     mat='Folha', grupo='Sepalas', curva=0.3, concha=0.35, esp=0.35, nu=10, nv=6)
        for k in range(12):  # pétalas grandes abertas (rosa e lilás alternados), duas camadas
            a = TAU * k / 12 + (TAU / 24 if k % 2 else 0)
            camada = k % 2; comp = 15 - 2.5 * camada; larg = 7.5 - 1.2 * camada
            L.petala(f'PetalaC{k}', comp, larg, (4.0 * math.cos(a), 4.0 * math.sin(a), ZC + 2.0 + camada * 0.6), (math.pi / 2 - (1.15 - 0.25 * camada), 0, a - math.pi / 2),
                     mat='Petala' if camada == 0 else 'PetalaLilas', grupo='Petalas', curva=0.42, concha=0.4, esp=0.4, nu=18, nv=10)
        # estames dourados em volta da bolha
        if N >= 3:
            for k in range(14):
                a = TAU * k / 14 + 0.2
                p0 = (2.0 * math.cos(a), 2.0 * math.sin(a), ZC + 3.0); p1 = (3.8 * math.cos(a), 3.8 * math.sin(a), ZC + 6.5); p2 = (4.4 * math.cos(a), 4.4 * math.sin(a), ZC + 8.5)
                L.tubo(f'Estame{k}', [p0, p1, p2], 0.11, mat='Dourado', grupo='Estames', seg=6)
                L.esfera(f'Antera{k}', 0.38, p2, mat='Dourado', grupo='Estames', seg=10, aneis=6)
        # bolha-lago: esfera de película com um lago (lente de água) dentro, apoiada no receptáculo
        RB = 8.0; zb = ZC + 3.0 + RB - 0.6
        L.esfera('BolhaLago', RB, (0, 0, zb), mat='Bolha', grupo='BolhaLago', seg=64, aneis=32)
        L.esfera('LagoInterno', RB - 0.6, (0, 0, zb - 2.2), esc=(1, 1, 0.32), mat='Agua', grupo='BolhaLago', seg=48, aneis=16)
        L.toro('AroBolha', 4.4, 0.35, (0, 0, ZC + 3.2), mat='Dourado', grupo='Frisos', segM=64, segm=8)
    # --- bolhas emitidas (sobem do topo; animadas no Roblox) e cristais na base
    flut = []
    if N >= 3:
        rnd = random.Random(9)
        for k in range(14):
            a = rnd.random() * TAU; rr = 6 + rnd.random() * 12; z = ZC + 16 + rnd.random() * 22
            L.esfera(f'BolhaEmitida{k}', 0.8 + rnd.random() * 1.8, (rr * math.cos(a), rr * math.sin(a), z), mat='Bolha', grupo='BolhasEmitidas', seg=24, aneis=12)
        flut = ['BolhasEmitidas']
        for k in range(7):
            a = TAU * k / 7 + 0.3; rr = 12.0 + (k % 2) * 1.0
            cristal_bolha(f'CristalBase{k}', (rr * math.cos(a), rr * math.sin(a), HB - 0.25), 1.2 + 0.4 * (k % 3), sem=20 + k, mat='Cristal' if k % 2 else 'CristalRosa')
        # entrada de manutenção na base do caule (porta em arco com moldura de ouro), em -Y
        L.caixa('Porta', (3.2, 0.5, 5.2), (0, -(r_caule(0.5) + 0.05), HB + 2.6), mat='Madeira', grupo='Porta', chanfro=0.12)
        L.toro('MolduraPorta', 1.8, 0.22, (0, -(r_caule(0.5) + 0.2), HB + 5.2), (math.pi / 2, 0, 0), mat='Dourado', grupo='Frisos', segM=32, segm=6, arco=math.pi)
        for s in (-1, 1): L.caixa(f'Ombreira{s}', (0.45, 0.5, 5.2), (s * 1.8, -(r_caule(0.5) + 0.2), HB + 2.6), mat='Dourado', grupo='Frisos', chanfro=0.08)
    anim = ['MecanismoAnel', 'Mecanismo', 'BolhasEmitidas', 'Energia', 'Petalas']
    L.consolidar('CB_GeradorDeBolhas', root)
    L.colisor(root, 'Base_A', (31, 22, HB), (0, 0, HB / 2)); L.colisor(root, 'Base_B', (22, 31, HB), (0, 0, HB / 2))
    L.colisor(root, 'Caule', (7, 7, HT), (0, 0, HB + HT / 2))
    L.colisor(root, 'Plataforma_A', (18, 12, 0.8), (0, 0, HB + HP - 0.4)); L.colisor(root, 'Plataforma_B', (12, 18, 0.8), (0, 0, HB + HP - 0.4))
    for k in range(3):
        a = TAU * k / 3 - math.pi / 2 + math.pi / 3; d = r_caule(14) + 4.4
        L.colisor(root, f'Reservatorio{k}', (7.2, 7.2, 7.2), (d * math.cos(a), d * math.sin(a), HB + 14.5), a)
    return dict(root=root, centro=(0, 0, 30), raio=34, frente=(0, -1), animaveis=anim, flutuantes=flut, chao=90,
                detalhes=[dict(alvo=(0, 0, HB + 15), raio=11, dir=(0.55, -1), elev=0.05),
                          dict(alvo=(0, 0, ZC + 9), raio=13, dir=(0.4, -1), elev=0.3),
                          dict(alvo=(0, -8, HB + HP + 1), raio=8, dir=(0.2, -1), elev=0.35)])
