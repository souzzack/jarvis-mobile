# Ilha das Tempestades: ilha piloto

Visualizador: `dimensoes/visualizador.html`. Imagens: `referencias/ilha-tempestades-validacao.png`.
Pacote exportado de teste: 5 GLBs + heightmap + colormap + marcadores + manifesto (≈12 MB).

## 1. Identidade

Uma ilha flutuante numa noite de tempestade eterna. Energia elétrica, tecnologia meteorológica antiga e cristais.
- **Paleta:** azul elétrico, ciano, prata, violeta e ardósia escura (de `DIRECAO-ARTISTICA.md`).
- **Contraste:** musgo verde-acinzentado no chão e lajes claras e quentes nos caminhos.
- **Forma:** vertical, pontiaguda, em ziguezague: cordilheira em crista ao norte, torre-agulha e pinheiros de raio retorcidos.

## 2. Mapa (studs)

Ilha de ≈560 × 440 studs, flutuando sobre um mar de nuvens. A base rochosa vai até ≈280 studs abaixo.

| Lugar | Posição (x, z) | Altura do chão | Como se chega |
|---|---|---|---|
| Chegada (doca + arco do portal) | 0, 186 | 9 | Spawn |
| Vila dos Para-raios | −34, 92 | 16 | Caminho principal P1 |
| Torre Meteorológica | 32, −26 | 36 (colina em terraços de 6 studs) | P1 continua até a porta da torre |
| Floresta Eletrificada | −158, 18 | 8–20 | Trilha P2 (oeste) |
| Caverna do Trovão | boca em −150, −104 | 26 | Fim da P2, túnel até a câmara |
| Penhasco das Nuvens | 222, 44 | 26 | Estrada P3, **atravessa a Ponte Suspensa da Fenda** |
| Observatório Abandonado | 150, −128 | 66 | Serpentina P4 a partir da torre, ou crista leste P6 (alternativa) |
| Santuário da Tempestade (secreto) | −228, 150 | 10 | Fresta entre rochas na floresta (STORM.HIDDEN.01) → trilha P5 de 8 studs |
| Cordilheira norte | z < −120 | até ≈180 | Visual e zona de evento climático (STORM.WEATHER.01) |

**Rotas:**
- **Principal:** chegada → vila → torre.
- **Ramais:** floresta/caverna, penhasco e observatório.
- **Alternativa:** a crista leste até o observatório.
- **Secreta:** o santuário.
- **Elevações:** colina da torre, platô do observatório, mirantes de madeira na floresta e o deck do penhasco.

## 3. O que foi efetivamente modelado

| Pasta | Modelo (ID) | Triângulos | Tamanho (studs) |
|---|---|---|---|
| Terrain | Terreno principal `STORM.TERRAIN.MAIN` (campo de alturas 301 × 252, passo 2; caminhos escavados; fenda; boca da caverna vazada) | 102.282 | 600 × 324 × 502 |
| Terrain | Base flutuante `STORM.TERRAIN.BASE` (raiz de rocha com pontas e cristais pendurados) | 2.934 | 615 × 234 × 470 |
| Architecture | **Torre Meteorológica** `STORM.ARCH.TOWER` (base com contrafortes e porta 10 × 12, fuste com escada em espiral de 40 degraus, sacada, treliça com núcleo de energia e 3 bobinas, cúpula de cobre, anemômetro e cata-vento animados, agulha para-raios) | 7.376 | 56 × 134 × 54 |
| Architecture | Praça do Coletor `STORM.ARCH.VILLAGE.PLAZA` | 1.338 | 35 × 23 × 35 |
| Architecture | 5 casas `STORM.ARCH.HOUSE.01–05` (variantes: duas águas, cônica, uma água; enxaimel; chaminé; para-raios com bobinas) | 490–590 cada | ≈20 × 30 × 20 |
| Architecture | Oficina dos Para-raios `STORM.ARCH.WORKSHOP` (NPC 02) | 1.152 | 31 × 15 × 30 |
| Architecture | Boca, túnel e câmara da caverna `STORM.ARCH.CAVE.*` | 240 + 2.536 | túnel de 15 studs de largura |
| Architecture | Observatório Abandonado `STORM.ARCH.OBSERVATORY` (cúpula partida, telescópio, anexo em ruínas) | 2.074 | 50 × 27 × 45 |
| Architecture | Santuário `STORM.ARCH.SANCTUARY` (seis pilares + altar: o símbolo das Sete Estrelas) | 412 | 31 × 14 × 30 |
| Architecture | Ponte Suspensa da Fenda `STORM.BRIDGE.01` (caminhável) | 2.012 | vão de 37 studs |
| Architecture | Doca de chegada e arco do portal, mirante do penhasco, 2 plataformas elevadas | 1.112 / 200 / 270 | — |
| Vegetation | 52 árvores retorcidas (**12 formas diferentes**, com veios elétricos) `STORM.VEG.TREE.01–52` | 4.392–6.280 cada | — |
| Vegetation | Árvore-Para-raios Ancestral `STORM.VEG.ANCESTRAL` | 13.004 | 18 × 43 × 16 |
| Resources | 4 minas de cristal `STORM.RES.MINE.01–04` | 416–500 cada | ≈12 × 9 × 10 |
| Props | 70 rochas únicas, linha de transmissão (5 torres + cabos), cabos da vila, lanternas, barracas, ruínas tecnológicas, rochas da passagem oculta, bobina antiga | ≈13 mil no total | — |
| Lighting | Céu de tempestade animado, mar de nuvens, 26 bancos de nuvem, névoa, lua, contraluz violeta, farol da torre | — | — |
| Effects | Relâmpagos distantes e na agulha da torre (a cada 9–17 s), clarão do céu, chuva fina, arcos elétricos nas bobinas e nos para-raios | — | — |

Colisão no visualizador:
- **90 caixas de colisão.** Mais as superfícies caminháveis: a ponte, os decks, a doca e o chão do túnel.
- **Caminhada testada:** o boneco percorreu o caminho principal seguindo o terreno, com o chão do túnel correto dentro da caverna.

## 4. Marcadores de interação (não são mecânicas)

19 marcadores técnicos, cada um com a posição prevista e um ID: `STORM.SPAWN.01`, `STORM.PORTAL.01`, `STORM.NPC.01–03`, `STORM.MINE.01–04`, `STORM.COLLECT.01–03`, `STORM.PUZZLE.TOWER`, `STORM.PUZZLE.OBS`, `STORM.SECRET.01`, `STORM.DISCOVERY.01`, `STORM.EQUIP.01`, `STORM.WEATHER.01` e `STORM.HIDDEN.01`. A lista completa está em `plano.js` e em `marcadores.json` no pacote.

## 5. O que ainda é só planejado

- **Mecânicas:** mineração, coleta, NPCs, puzzles da torre e do telescópio, portal, descoberta, equipamento secreto e evento climático. Existe só o marcador.
- **Interiores:** só a caverna tem interior. A torre, as casas e o observatório não têm.
- **Os sete ambientes pedidos:** Vila, Floresta, Caverna, Torre, Penhasco, Observatório e Santuário estão modelados. Pontes suspensas, plataformas elevadas, cabos e ruínas também.
- **Nuvens:** são estilizadas (malhas), não volumétricas.
- **Texturas:** não há. As cores vêm de materiais e de cores por vértice.

## 6. Caminho para o Roblox Studio (não testado)

| Parte | Formato pronto | Plano no Studio |
|---|---|---|
| Terreno | `heightmap.png`/`heightmap16-RG.png` + `colormap.png` (2 studs por pixel, altura −50 a 184) e `Terrain.glb` | Terrain gerado pelo heightmap + colormap no editor de terreno, ou o GLB recortado em blocos de MeshPart. **A confirmar:** limites atuais de tamanho e resolução |
| Arquitetura, props, minas | GLB por pasta, um nó por modelo, pivô na base, sem texturas | Importar pelo 3D Importer (glTF/GLB, se a versão aceitar; senão passar pelo Blender → FBX). Materiais → MaterialVariant/SurfaceAppearance. Colisões: usar as caixas do `manifest.json` como peças invisíveis |
| Árvores | 12 formas compartilhadas (4,4–6,3 mil triângulos cada) | Reduzir para ≈1,5 mil triângulos por forma no Blender e clonar as MeshParts |
| Peças animadas | Anemômetro e cata-vento separados no GLB | Girar no cliente (RenderStepped) |
| Céu, nuvens, chuva, relâmpagos, arcos | Só no navegador (shaders e linhas) | Refazer com Sky, Atmosphere, ParticleEmitter, Beam e um script de relâmpago no cliente |
| Marcadores | `marcadores.json` | Parts invisíveis com atributos `Id`, `Tipo` e `Descricao` numa pasta `Interactions` |

O terreno principal tem cerca de 100 mil triângulos. Para Roblox, o terreno deve ir como **Terrain** pelo heightmap, e não como malha.
