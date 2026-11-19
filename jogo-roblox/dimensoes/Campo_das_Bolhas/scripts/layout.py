# Campo das Bolhas — planta geral (fonte única de verdade para terreno, montagem e validação)
# Unidade: 1 unidade do Blender = 1 stud do Roblox. Eixos do Blender: X = leste, Y = norte, Z = para cima.
# Escala de referência: personagem 5 studs; porta 5 x 8; degrau até 1; caminho principal 12; secundário 8.
# Rotação "rz" em graus em volta de Z. Toda estrutura é modelada com a frente voltada para -Y (sul) e o pivô
# no centro da base, no chão; aqui ela é girada para olhar para o caminho de chegada.

# ---------------------------------------------------------------- ilhas
# Ilha principal: contorno r(theta) = elipse (A, B) com ruído; topo entre 10 e 40 studs; parte de baixo rochosa
# que afunila até a ponta (-150).
ILHA_PRINCIPAL = dict(nome="Ilha Principal", cx=0.0, cy=0.0, A=170.0, B=150.0, base=12.0, fundo=-150.0, semente=11)

# Contorno: o terreno garante que todo platô e toda cabeceira de ponte fiquem dentro da ilha (margem de 4 studs).
# Ilhas secundárias: discos com contorno ruidoso, topo quase plano (platô) e base rochosa própria.
ILHAS_SECUNDARIAS = [
    dict(id="ObsIsland", nome="Ilha do Observatório", cx=-250.0, cy=50.0, r=50.0, topo=30.0, fundo=-70.0, semente=21),
    dict(id="AltarIsland", nome="Ilha do Altar", cx=178.0, cy=143.0, r=42.0, topo=27.0, fundo=-60.0, semente=31),
    # ilhotas decorativas (sem acesso): pedras flutuantes com vegetação e bolhas
    dict(id="Ilhota1", nome="Ilhota Sul-Oeste", cx=-150.0, cy=-205.0, r=16.0, topo=4.0, fundo=-30.0, semente=41),
    dict(id="Ilhota2", nome="Ilhota Sudeste", cx=195.0, cy=-170.0, r=12.0, topo=18.0, fundo=-14.0, semente=42),
    dict(id="Ilhota3", nome="Ilhota Norte", cx=-60.0, cy=215.0, r=18.0, topo=44.0, fundo=8.0, semente=43),
]

# ---------------------------------------------------------------- platôs (áreas praticáveis niveladas)
# Cada platô vira um círculo plano no terreno (com rampa suave de 'borda' studs) na altura 'z'.
PLATOS = [
    dict(id="PracaPortal", x=0.0, y=-112.0, r=30.0, z=14.0, borda=14.0),
    dict(id="PracaMercado", x=46.0, y=-58.0, r=26.0, z=15.0, borda=14.0),
    dict(id="PracaVila", x=-14.0, y=12.0, r=18.0, z=18.0, borda=12.0),
    dict(id="Casa1", arquivo="Village/CB_Casa_A1.blend", x=-48.0, y=-10.0, rz=-60.0, plato="Casa1"),
    dict(id="Casa2", arquivo="Village/CB_Casa_B1.blend", x=-52.0, y=28.0, rz=-100.0, plato="Casa2"),
    dict(id="Casa3", arquivo="Village/CB_Casa_C1.blend", x=-22.0, y=50.0, rz=-160.0, plato="Casa3"),
    dict(id="Casa4", arquivo="Village/CB_Casa_A2.blend", x=18.0, y=44.0, rz=150.0, plato="Casa4"),
    dict(id="Casa5", arquivo="Village/CB_Casa_B2.blend", x=24.0, y=6.0, rz=95.0, plato="Casa5"),
    dict(id="Casa6", arquivo="Village/CB_Casa_C2.blend", x=-30.0, y=-34.0, rz=-30.0, plato="Casa6"),
]

# pontes: de cabeceira a cabeceira (x, y, z do tabuleiro em cada ponta)
PONTES = [
    dict(id="PonteSuspensa", arquivo="Bridges/CB_PonteSuspensa.blend", a=(-150.0, 39.0, 24.0), b=(-206.0, 48.0, 30.0)),
    dict(id="PonteArco", arquivo="Bridges/CB_PonteArco.blend", a=(118.0, 96.0, 25.0), b=(147.0, 118.0, 27.0)),
]

# ---------------------------------------------------------------- zonas de exploração (para o relatório e a planta)
ZONAS = [
    ("Chegada", "Praça do Portal, ao sul: o jogador entra pelo Portal Dimensional e vê o Gerador no alto, ao norte."),
    ("Mercado", "Praça a leste da avenida, com quiosques."),
    ("Vila Encantada", "Centro da ilha, em terraços: praça, seis casas e um laguinho."),
    ("Colina do Gerador", "Norte, 34 studs: o Gerador de Bolhas (Flor-Mãe), visível de toda a ilha."),
    ("Lagos Mágicos", "Leste: dois lagos turquesa em degraus."),
    ("Prado das Flores", "Sudeste: flores gigantes e cogumelos."),
    ("Mirante", "Sudoeste: vista para as ilhotas."),
    ("Ilha do Observatório", "Oeste, ligada pela Ponte Suspensa."),
    ("Ilha do Altar", "Nordeste, ligada pela Ponte em Arco."),
]
