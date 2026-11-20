# 38 · Terreno da Ilha das Tempestades (relatório 5, para revisão)

Data: 20/11/2026. Aprovado em "Pode gerar". Tudo foi feito na cópia de teste "11202026_2" (placeId 115368067307260), salva na **versão 12**. O place original não foi tocado.

## 1. O que foi feito (IMPLEMENTADO e TESTADO)

| Passo | Detalhe |
|---|---|
| **Fonte** | A grade real do gerador `StormIsland/Terrain/terreno.js`: alturas `H`, pesos de material `W` (rocha, solo, trilha) e o contorno `terrain.inside`. A parte de baixo da ilha flutuante foi medida com raios nas malhas `STORM.TERRAIN.BASE` e `CLIFFS` |
| **Exportação** | Pelo visualizador, servido localmente, para `jogo-roblox/dimensoes/Exports/StormIsland/Terrain/`: `terreno_voxels_4studs_v2.json` (colunas de 4 × 4 studs), mais o `heightmap.png`, o `heightmap16-RG.png`, o `colormap.png` e o `manifest_ilha.json` originais. Script: `exportar_terreno.js` |
| **Até o Studio** | O JSON virou um ModuleScript (`ServerStorage.StormIslandDados.TerrenoIlhaDados`), montado com o Rojo e carregado com `GetObjects`. Os dados não passaram por mim |
| **Escrita** | `WriteVoxels` em 80 blocos de 16 × 16 colunas, com o script `escrever_terreno.luau`. O centro fica em **(2000, 150, 0)**: mundo = centro + coordenada da ilha. São **11.491 colunas** e cerca de **440 mil voxels** |
| **Materiais** | Topo, até 8 studs de profundidade: grama, solo (floresta), trilha (Cobblestone), rocha (encostas) e rocha alta (Slate, acima de 95). O corpo e a parte de baixo ficam em basalto. A fenda e tudo fora do contorno ficam **vazios** |
| **Cores** | Grass `#4a6a4c`, Ground `#4a403a` e Cobblestone `#8a8780`, as cores autorais do `terreno.js`. O mapa atual **não usa** esses 3 materiais (conferido no mapa todo: só Water, Sand, Basalt, Slate e Rock). Rock, Slate e Basalt **não foram recoloridos** |
| **Área** | Conferida **vazia** antes de escrever: 0 voxels e 0 peças de terceiros na região |
| **Oficina** | Movida da área de teste para o **pivô dela na ilha**, (1915,96; 165,83; 98,04), com rotação de 141,6°. A área de teste provisória (piso, grade e boneco, 24 peças minhas) foi retirada |

## 2. Fidelidade ao gerador

Comparei a altura do Terrain com a do gerador nos 8 pontos de interesse do `plano.js`:

| Ponto | Gerador | Roblox | Erro |
|---|---|---|---|
| Chegada | 8,7 | 8,8 | 0,1 |
| Vila | 15,3 | 15,2 | 0,1 |
| Torre | 36,0 | 36,0 | 0,0 |
| Floresta | 7,3 | 7,2 | 0,1 |
| Santuário | 10,0 | 10,0 | 0,0 |
| Observatório | 66,0 | 66,0 | 0,0 |
| Penhasco | 27,9 | 27,8 | 0,1 |
| Boca da caverna | 25,1 | 31,1 | **6,0** |

Outras conferências:
- **Fenda:** aberta, sem chão, como no plano ("corta a ilha até as nuvens").
- **Canto do retângulo da grade (fora do contorno):** vazio, como deveria.
- **Assentamento da Oficina:** o terreno sob a planta vai de **−2,62 a +0,25** em relação ao pivô. A V2.3.5 dá −2,47 a +0,3. Nada fura o piso interno, e o pé da escada fica no chão (−0,6).

## 3. Testes no Play

| Teste | Resultado |
|---|---|
| Personagem solto na praça da vila | ✓ caiu e parou na calçada (Cobblestone), na altura certa |
| Vila → pé da escada da Oficina (andando, `MoveTo`) | ✓ chegou, sobre calçada |
| Escada → patamar → interior → saída | ✓ |
| Output | ✓ nenhum erro novo. Testes: 234 passaram, 0 falharam. Aparecem só o `203785492`, que já existia, e um aviso da própria ferramenta MCP sobre a câmera |

## 4. Capturas (`guardioes/docs/ilha-terreno/`)

1. `01-aerea-antes-retangular.jpg`: **primeira tentativa, com defeito** (seção 5).
2. `02-aerea-com-contorno.jpg`: a ilha com o contorno do visualizador. Aparecem a cordilheira ao norte, a fenda aberta, os caminhos P1–P6, a floresta em solo escuro e a Oficina perto da vila.
3. `03-oficina-assentada-na-ilha.jpg`: a Oficina na encosta da vila, com a calçada até a escada.

Para comparar, use `jogo-roblox/referencias/v232-antes-depois-1.jpg` (vista aérea do visualizador).

## 5. Problemas encontrados e corrigidos

| Problema | Correção |
|---|---|
| **A ilha saiu retangular** (600 × 504 inteiros) na primeira escrita: a grade tem alturas fora do contorno, que o gerador cobre com o paredão | Exportação refeita com `terrain.inside`: de 18.889 colunas para **11.351**. O JSON antigo ficou como `…_v1_SEM_CONTORNO_nao_usar.json` |
| **Superfície 2 studs acima** do gerador (sistemático, medido em 7 pontos) | Desconto de 2 studs (`AJUSTE = −2`), porque o terreno suave mostra a superfície cerca de meio voxel acima da ocupação. Depois disso, o erro ficou ≤ 0,1 |

## 6. Pendências

| # | Pendência |
|---|---|
| 1 | **Caverna:** o erro de 6 studs na boca vem do paredão íngreme dentro de uma célula de 4 studs. **O túnel não existe** num mapa de alturas: vai precisar ser escavado no Terrain quando a caverna for importada |
| 2 | **Borda:** a grade do gerador termina em x = ±300. Onde o contorno chega perto desse limite, a borda fica cortada reta (lâminas finas nas laterais da vista aérea). O mirante em balanço (até x = 326) depende da malha do mirante |
| 3 | **Paredão:** saiu como basalto liso, e a parte de baixo segue a malha BASE/CLIFFS. Os estratos e as ravinas da malha `CLIFFS` (40 mil triângulos) não foram reproduzidos |
| 4 | **Grama decorativa:** o place tem a grama alta do Terrain ligada (global). Ela aparece na ilha, coisa que o visualizador não tem |
| 5 | **Iluminação:** a da cópia é diurna (do tycoon). A noite de tempestade fica para a etapa de iluminação, porque mexe no place inteiro |
| 6 | **Pendências anteriores:** FPS real, brilho das runas, colisor 16 na fonte e o `203785492` |

## 7. Próxima ação proposta

Importar a **Doca de chegada** (`STORM.ARCH.ARRIVAL`, 14 mil triângulos) com o procedimento padrão (relatório 37, seção 6c) e colocar o spawn em (2000, 159, 184). Assim, a ilha passa a ter entrada. Depois vem a Torre Meteorológica. Uma estrutura por vez, com relatório.
