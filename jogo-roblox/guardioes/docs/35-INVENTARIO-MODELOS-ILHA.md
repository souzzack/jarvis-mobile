# 35 · Inventário dos modelos 3D da Ilha das Tempestades (relatório 2, para revisão)

Data: 20/11/2026. Responde à "Decisão da Supervisão 01" (opção C).

## 0. Backup e o conjunto 1 desfeito

Quando a decisão chegou, eu já tinha começado o conjunto 1. Ele criou quatro ilhotas de terreno ao redor da ilha do tycoon e mudou a posição de três chefes. Como a decisão manda **não gerar terreno antes da verificação** e **preservar a ilha atual**, desfiz tudo:

| Item | Status |
|---|---|
| Terreno | **RESTAURADO**. Colei de volta o `TerrainRegion` salvo antes da mudança (`ServerStorage.Backup_IlhaTempestades_20261120_v5.Terreno_Regiao_Ilha`). Conferi por raio: água em −4 nos pontos dos chefes, e a ilha continua em basalto 2,0 |
| Código | **REVERTIDO**. O repositório está no commit `beeb26a`, sem mudanças. O trabalho do conjunto 1 ficou guardado como patch em `C:\Users\VICTOR\conjunto1-pausado.patch`, fora do repositório. Ele inclui o módulo `SoloDaArena`, que posiciona as peças da arena pelo chão real. Pode ser reaplicado quando as arenas estiverem na nova ilha |
| Backup | **CONFIRMADO**: pasta `ServerStorage.Backup_IlhaTempestades_20261120_v5` (5 grupos de modelos e o terreno da região) e versões 5 e 6 da nuvem |
| Original (86899143559754) | **Não foi tocado** |

## 1. Onde procurei

| Local | Resultado |
|---|---|
| `C:\Users\VICTOR` inteiro (.blend, .glb, .gltf, .fbx, .obj, .dae, .stl, .usd, .rbxm, .rbxmx, .rbxl, .rbxlx) | Só 2 .obj do Lunar Client (cosméticos de Minecraft) e arquivos do Roblox (plugins, autosaves e as cópias de sincronização que eu gerei). **Nada do jogo** |
| Disco `E:` inteiro | Só jogos e ferramentas: OMSI2, BeamNG, Wallpaper Engine e bibliotecas `.obj` do Visual Studio. **Nada do jogo** |
| Disco `D:` inteiro | Nenhum arquivo 3D |
| `Downloads` | Nenhum pacote da ilha |
| Pacotes exportados (`*Storm*`, `Architecture.glb`, `Terrain.glb`, `manifest.json`, `heightmap*.png`, `*pacote*.zip`) | **Nenhum** em lugar nenhum |
| Repositório (todas as branches e todo o histórico) | **Fonte real encontrada**, descrita abaixo |
| Place no Studio | Nenhuma construção do RPG (relatório 34) |

## 2. O que existe de verdade

### 2a. Ilha das Tempestades: geradores procedurais (o trabalho artístico)

- **Pasta:** `jogo-roblox/dimensoes/` (versão atual V2.3.2, com a Oficina V2.3.5; backups `v2-backup` a `v235-backup`).
- **Formato:** **código JavaScript** (three.js r128) que **gera** a geometria. Não há arquivo de malha salvo. O visualizador (`visualizador.html`) monta a ilha e exporta GLB.
- **Validado agora:**
  - servi a pasta localmente (127.0.0.1, só leitura) e abri no navegador embutido;
  - a ilha montou sem erro: **100 modelos e 263 colisores em 2,5 s**;
  - gerei o pacote **só em memória**, sem gravar nada em disco.

| Arquivo do pacote | Tamanho |
|---|---|
| `Dimensions/StormIsland/Architecture/Architecture.glb` | 15,20 MB |
| `…/Terrain/Terrain.glb` | 6,18 MB |
| `…/Vegetation/Vegetation.glb` | 3,22 MB |
| `…/Props/Props.glb` | 2,78 MB |
| `…/Resources/Resources.glb` | 1,48 MB |
| `…/Terrain/heightmap.png`, `heightmap16-RG.png`, `colormap.png` | 0,07 / 0,24 / 0,11 MB |
| `…/Interactions/marcadores.json`, `manifest.json` | pequenos |

- **Estado de importação:** **nunca exportado para disco e nunca importado no Roblox.** Os documentos da própria pasta dizem que tudo é "render do visualizador three.js, não do Roblox".

**Construções medidas no visualizador** (1 unidade = 1 stud):

| ID | Estrutura | Tamanho (X×Y×Z) | Centro | Triângulos | Malhas | Estado no levantamento |
|---|---|---|---|---|---|---|
| STORM.ARCH.TOWER | Torre Meteorológica | 68×189×84 | (32, 120, −18) | 69.248 | 110 | **detalhada (concluída)** |
| STORM.ARCH.WORKSHOP | Oficina dos Inventores | 45×29×45 | (−85, 25, 98) | 40.870 | 49 | **congelada (V2.3.5)** |
| STORM.ARCH.OBSERVATORY | Observatório | 58×40×44 | (150, 71, −124) | 15.657 | 6 | razoável |
| STORM.ARCH.ARRIVAL | Doca e arco do portal | 31×31×27 | (0, 19, 192) | 14.248 | 9 | refeito no levantamento |
| STORM.ARCH.VILLAGE.PLAZA | Praça do Coletor | 37×25×37 | (−34, 26, 92) | 9.880 | 8 | refeito |
| STORM.ARCH.HOUSE.01–05 | Casas da vila | ~18–25 × 26–36 × 20–26 | vila | 3.502–6.666 | 7–8 | refeitas |
| STORM.BRIDGE.01 | Ponte Suspensa da Fenda | 57×37×27 | (114, 6, 89) | 7.020 | 7 | boa |
| STORM.ARCH.CAVE.MOUTH / TUNNEL | Boca e túnel da Caverna do Trovão | 52×28×18 / 38×28×72 | (−150, 38, −101) | 5.776 / 4.596 | 8 / 9 | refeita |
| STORM.ARCH.SANCTUARY | Santuário (altar) | 38×15×36 | (−187, 17, 125) | 5.404 | 14 | refeito |
| STORM.ARCH.CLIFF.LOOKOUT | Mirante do Penhasco | 63×19×23 | (247, 27, 47) | 5.304 | 6 | refeito |
| STORM.ARCH.PLATFORM.01–02 | Plataformas elevadas | 13×26×28 | floresta | ~1.900 | 6 | refeitas |
| STORM.PROP.STALL.01–02 | Barracas (quiosques) | 10–12 × 8–9 × 9–10 | vila | ~1.500 | 9 | refeitas |
| STORM.PROP.PYLON.01–05 + POWERLINE | Torres e linha de transmissão | 9×27–31×7 | vila | 1.648 cada | 4 | aceitável |
| STORM.PROP.RUINS | Ruínas tecnológicas | 218×27×44 | (21, 17, −33) | 2.784 | 7 | simples |
| STORM.EQUIP.01.MODEL | Bobina antiga | 7×9×9 | caverna | 5.036 | 4 | refeita |

Além disso: 54 itens de vegetação (árvores retorcidas, Árvore Ancestral), 8 recursos (4 minas de cristal e depósitos) e o terreno, que tem cerca de 485 mil triângulos de superfície mais 171 mil do corpo principal.

**Referências visuais reais** (renders do visualizador) estão em `jogo-roblox/referencias/`: `v232-antes-depois-1..3.jpg`, `mapa-*-antes-depois.jpg`, `v235-oficina-12-vistas.jpg` e `ilha-tempestades-v22-validacao.jpg`, entre outras. **São estas as prévias finais**, e não as de `guardioes/docs/previas`.

### 2b. Campo das Bolhas: arquivos Blender reais

- **Pasta:** `jogo-roblox/dimensoes/Campo_das_Bolhas/`.
- **Arquivos:**
  - `.blend` do terreno e do portal;
  - exportações `CB_Terreno.glb`, `CB_Portal.glb` e `CB_Portal_Colisores.glb`, mais as FBX;
  - heightmap (PNG e JSON) e scripts `bpy` geradores.
- **Estado de importação:** não foram importados. A área das Bolhas que existe no place é a do tycoon. Fica fora desta etapa, mas é material aproveitável.

### 2c. Scripts Luau de rascunho da Oficina

`jogo-roblox/luau-rascunho/OficinaDosInventores/` tem a configuração, 24 colisores, o servidor e o cliente. O LEIA-ME diz que **não foram testados no Roblox** e que esperam o modelo em `Workspace/Dimensions/StormIsland/Architecture/`.

### 2d. O que NÃO existe

- Nenhum `.blend`, `.fbx` ou `.glb` **da Ilha das Tempestades** foi salvo em disco: os modelos existem só como código gerador.
- Nenhum modelo de **Quiosque** com esse nome. O mais próximo são as Barracas do mercado (`STORM.PROP.STALL.01–02`).
- O **"Altar"** é o Santuário (`STORM.ARCH.SANCTUARY`), e as **"Torres"** são as torres de transmissão (`STORM.PROP.PYLON.*`).

## 3. Escala e dimensões da área nova

- **Ilha:** cerca de **560 × 440 studs** de chão (plano: "Ilha ≈ 560 × 440"). Com a saia de paredão, a caixa vai de −302 a 326 em X e de −296 a 294 em Z. O desenho é de ilha **flutuante sobre mar de nuvens**, sem mar de água.
- **Altura:** chão de 9 (chegada) a 66 (observatório). O topo da torre fica perto de 214. A saia desce até −290 abaixo da referência.
- **Área a reservar no place:** cerca de **700 × 650 studs** de largura, mais 500 de altura livre.
- **Ocupação atual do place** (para não sobrepor):
  - tycoon: ilha das Tempestades a ±62 em torno de (0, 0) e Bolhas em x −435…−225, z 198…402;
  - Galpão em x −158…142, z 200…404;
  - Biblioteca em y 600, x ±64, z −990…−876.
- **Local proposto:** centro em **(2000, 150, 0)**, na faixa x 1.650–2.350 e z −325…325. Fica fora de todo o mapa atual e não toca na ilha do tycoon. A nova ilha entraria como área própria (`noPlace`) no `DimensionSystem`, do mesmo jeito que as Bolhas e a Biblioteca, sem mecânica nova.

## 4. Proposta técnica de organização

1. **Terreno:**
   - importar o `heightmap16-RG.png` e o `colormap.png` pelo Importador de Terreno do Studio;
   - a malha `Terrain.glb`, com 656 mil triângulos, é pesada demais para virar MeshPart;
   - o paredão (saia) pode ser a malha `CLIFFS`, com 40 mil triângulos, se couber nos limites do importador.
2. **Arquitetura, um modelo por vez:**
   - exportar cada construção sozinha (o visualizador tem "Exportar GLB" por modelo) e importar pelo Importador 3D;
   - destino: `Workspace/Dimensions/StormIsland/Architecture/`, como os rascunhos esperam.
3. **Colisão:** usar os colisores do `manifest.json` (263 caixas). As malhas visuais ficam sem colisão, como o rascunho da Oficina já prevê.
4. **Marcadores:** o `marcadores.json` usa os mesmos IDs que o jogo (`STORM.SPAWN.01`, `STORM.PORTAL.01`, `STORM.MINE.*`, `STORM.PUZZLE.*`). Eles viram as Parts de chegada, portal e mistérios.
5. **Chefes**, só depois do terreno no lugar:

| Chefe | Arena na nova ilha |
|---|---|
| Guardião | Topo da Torre (o GDD já pede isso) |
| Rainha-Bobina | Câmara da caverna, perto de `STORM.MINE.02` |
| Colosso | Ruínas |
| Espectro | Observatório |
| Cão-Trovão | Floresta |

Aí o patch `SoloDaArena` volta a ser útil.

## 5. Primeiro modelo para importar e validar

**Recomendado: Oficina dos Inventores (`STORM.ARCH.WORKSHOP`).**
- **Mais revisada:** está congelada na V2.3.5 e é a única com 12 vistas de validação, diagnóstico e tabela de colisores.
- **Tamanho adequado:** 45×29×45 studs, com 49 malhas e uns 41 mil triângulos no total. Cada malha deve caber no limite por malha do Roblox, o que precisa ser confirmado na importação.
- **Teste completo:** já tem os scripts Luau de preparação. Dá para validar escala, orientação, materiais, colisão (24 caixas) e animação.

**Alternativa:** a **Torre Meteorológica**, que é a peça central (69 mil triângulos, 110 malhas, 189 studs de altura) e a futura arena do Guardião. É mais pesada para um primeiro teste.

## 6. Pendências que precisam de você

| # | Pendência | Por quê |
|---|---|---|
| 1 | **Autorizar a exportação** da Oficina para um arquivo GLB em disco (gerado localmente pelo visualizador; uns 3 a 5 MB) e dizer em qual pasta salvar | Gravar o arquivo é um download, e isso precisa da sua autorização |
| 2 | **Importar o GLB no Studio** pelo Importador 3D (Arquivo → Importar 3D) | O importador sobe a malha para a sua conta Roblox. Eu não tenho ferramenta para isso, e uma malha criada por script não fica salva no place |
| 3 | Confirmar o **local da nova área** (proposto: centro em 2000, 150, 0) | Decisão de projeto |
| 4 | Confirmar o **primeiro modelo** (Oficina ou Torre) | Decisão de projeto |
| 5 | Confirmar a **origem do `rbxassetid://203785492`** no Output | Pendente do relatório 34 |

## 7. Status

| Item | Status |
|---|---|
| Backup | **IMPLEMENTADO e TESTADO** |
| Conjunto 1 | **DESFEITO** (terreno restaurado e conferido; código revertido; patch guardado) |
| Busca de modelos | **TESTADO**: C:, D:, E:, Downloads, repositório e histórico |
| Geradores da ilha | **TESTADO**: montam sem erro, 100 modelos e 263 colisores; pacote gerado em memória |
| Exportação em disco e importação no Studio | **PENDENTE** (itens 1 e 2) |
| Nova área, chefes e marcadores | **PLANEJADO** |

## Observações técnicas

- Para abrir o visualizador, usei um servidor local mínimo que declara UTF-8 (`servir_utf8.py`, no scratchpad da sessão). Com o `http.server` padrão do Python, a página quebra com `I.buildMarkers is not a function`, porque a chave `Mineração` é lida em Latin-1. **Não há defeito no projeto.**
- Acrescentei uma configuração `dimensoes` ao `E:\alfred-kit\.claude\launch.json`, só para esse servidor local.
