# 39 · Doca de chegada (STORM.ARCH.ARRIVAL) (relatório 6, para revisão)

Data: 20/11/2026. Aprovado em "Pode importar a Doca". Tudo foi feito na cópia de teste "11202026_2", salva na **versão 13**. É a segunda estrutura importada; a primeira foi a Oficina. Segui o procedimento padrão do relatório 37, seção 6c.

## 1. GLB (IMPLEMENTADO e TESTADO)

| Item | Valor |
|---|---|
| Arquivo | `jogo-roblox/dimensoes/Exports/StormIsland/Arrival/STORM.ARCH.ARRIVAL.glb` |
| Tamanho | **1.563.824 bytes**. SHA-256 `8e51a26877552bc43f928f61558a560370db1432b2049ea5354f629887a75cd5` |
| Ao lado | `STORM.ARCH.ARRIVAL.manifest.json`: pivô (0, 9, 186), rotY 0, **13 colisores** |
| Validação | glTF 2.0; 9 malhas; **14.248 triângulos** (a maior tem 7.516); 7 materiais; 6 texturas; nenhum vértice inválido. Caixa de **31,0 × 31,13 × 26,75** studs, igual ao manifest |

## 2. Importação e correções (IMPLEMENTADO)

- **Quem importou:** você, pelo Importador 3D.
- **Resultado bruto:** `Workspace.AuxScene`, com 9 MeshParts e o tamanho igual ao GLB.
- **Defeitos repetidos da Oficina:** 0 peças ancoradas, colisão em todas as malhas, cores lisas perdidas e giro de 180°.

**Caminho final:** `Workspace.Dimensions.StormIsland.Architecture["Doca de chegada e arco do portal"]`, com atributo e tag `STORM.ARCH.ARRIVAL`.

| Correção | Resultado |
|---|---|
| Posição | Pivô em **(2000, 159, 186)**, que é o centro da ilha mais (0, 9, 186). Rotação 0, compensando o giro de 180°. As 9 peças casaram com a tabela do GLB **a menos de 0,1 stud** |
| Âncora e colisão | As 9 malhas foram ancoradas e ficaram só visuais. **13 colisores do manifest** (balaustradas, estrado, pilares do arco e pilaretes) |
| Piso da praça | **Não havia colisor no manifest.** As lajes ficam de 0,17 a 0,42 acima do pivô, e o terreno em cerca de −0,2, então o personagem afundaria cerca de 0,5 stud. **Acrescentei o `Colisor14_PisoDaPraca`** (31 × 16, topo em 0,19, pela mediana de 406 amostras das lajes), marcado `ForaDoManifest` |
| Cores e materiais | **Rocha** (2 peças), em Slate `#5b5e72`. **Energia** (anel e vão do portal, 2 peças), em Neon `#43d9ff` com transparência 0,35 e **sem colisão** (dá para passar). **CristalEnergizado**, em Neon `#7fe4ff` com transparência 0,18. **VidroAceso** (lanternas), em Neon `#ffc27a`. Cobre, ferro e madeira vieram com textura (SurfaceAppearance/TextureID) |
| Nomes | Formato `<Grupo>_<Material>`. O nome original ficou no atributo `NomeImportado` |
| Grama atravessando as lajes | A grama decorativa do terreno aparecia pelas lajes da praça e do estrado (captura 01). **O terreno sob a Doca passou de grama para Cobblestone** (213 voxels), que não tem grama decorativa (captura 02) |
| Spawn | **Só marcadores**, sem SpawnLocation: `Dimensions.StormIsland.Interactions["STORM.SPAWN.01"]` em (2000; 160,2; 184) e `["STORM.PORTAL.01"]` em (2000; 165,2; 198). São invisíveis e sem colisão, com Id/Tipo/Descrição/Implementado=false, no formato do `marcadores.js`. Um SpawnLocation de verdade mudaria onde **todos** os jogadores nascem (hoje é o Galpão do tycoon), o que é mecânica nova. **Fica para a sua decisão** |

## 3. Testes no Play (TESTADO)

| Teste | Resultado |
|---|---|
| Personagem no ponto `STORM.SPAWN.01` | ✓ ficou **sobre as lajes**, com a raiz em 162,34 (esperado cerca de 162,2) |
| Praça → estrado | ✓ subiu (local 11,9) |
| Entrar no vão de energia do portal | ✓ passou (z local 13,8). A energia não bloqueia |
| Voltar à praça | ✓ |
| Sair da praça para a trilha P1 | ✓ chegou a (1996, 150), sobre a calçada |
| Seguir pela trilha rumo à vila | ✓ chegou a (1980, 118), sobre a calçada |
| Output | ✓ nenhum erro novo |

## 4. Capturas (`guardioes/docs/doca-piloto/`)

1. `01-doca-na-ilha-grama-atravessando.jpg`: a Doca na ponta sul da ilha. Aparecem o arco com o anel de energia, os cristais e para-raios, a balaustrada na beira do penhasco, a trilha P1 e a Oficina ao fundo. **Mostra a grama atravessando as lajes.**
2. `02-doca-na-ilha-corrigida.jpg`: o mesmo enquadramento depois da correção.

## 5. Ferramentas do procedimento (no repositório)

Pasta `jogo-roblox/dimensoes/Exports/ferramentas/`:
- `validar_glb.py`: confere estrutura, triângulos, materiais, NaN e caixa exata.
- `tabela_glb.py`: gera a tabela de malhas com a posição final no Studio e o material. Já trata a "Rocha" como `#5b5e72` sem conversão.
- `servir_utf8.py`: servidor local do visualizador. Grava só em `Exports/StormIsland/{Workshop,Terrain,Arrival}`.

## 6. Pendências

| # | Pendência |
|---|---|
| 1 | **Spawn de verdade** (SpawnLocation ou viagem do hub até a doca): decisão de jogo |
| 2 | **Portal de volta** (`STORM.PORTAL.01`): ligar ao `DimensionSystem`, como as Bolhas e a Biblioteca, quando a ilha nova virar o hub. Isso é mecânica, então fica para outra etapa |
| 3 | Pendências anteriores: túnel da caverna, bordas laterais em x = ±300, paredão liso, FPS real, brilho das runas, colisor 16 na fonte e o `203785492` |

## 7. Próxima ação proposta

Importar a **Torre Meteorológica** (`STORM.ARCH.TOWER`: 69 mil triângulos, 110 malhas, 189 studs de altura, a maior malha com 9.592), pelo mesmo procedimento. É a peça central e a futura arena do Guardião. Antes de importar, vale conferir o número de colisores e a escadaria.
