# 40 · Ilha das Tempestades: importação em lote (relatório 7, para revisão)

Data: 20/11/2026. Decidido por você: "Importar em lote". Isso muda o protocolo "uma estrutura por vez" da supervisão. Tudo foi feito na cópia de teste "11202026_2", salva na **versão 14**. O place original não foi tocado.

## 1. O que entrou

| Lote | Arquivo (`dimensoes/Exports/StormIsland/Lote/`) | Tamanho | Malhas | Modelos | Colisores do manifest |
|---|---|---|---|---|---|
| Arquitetura | `Lote_Arquitetura.glb` | 11,9 MB | 219 | 15: Torre, praça, 5 casas, boca e túnel da caverna, observatório, santuário, ponte, 2 plataformas e mirante | 155 |
| Props | `Lote_Props.glb` | 2,9 MB | 55 | 14: barracas, cabos, lanternas, bobina antiga, rochas, rochas secretas, 5 torres de transmissão, linha e ruínas | 14 |
| Recursos | `Lote_Recursos.glb` | 1,5 MB | 56 | 8: 4 minas de cristal e depósitos | 4 |
| Vegetação | `Lote_Vegetacao.glb` | 3,4 MB | 163 | 54: 52 árvores retorcidas, Árvore Ancestral, troncos caídos e flores-faísca | 53 |

Validação dos GLBs:
- glTF 2.0 e nenhum vértice inválido.
- Nenhuma malha acima de 10 mil triângulos (a maior tem 9.592).
- Nomes únicos por malha (A/P/R/V + número) presentes em todos os nós.

Somando com a Oficina, a Doca e o terreno, **toda a ilha do visualizador está no Studio**, com uma exceção: a grama e as pedrinhas instanciadas do terreno, que o Terrain do Roblox substitui.

**Sobre a vegetação:** as 36 malhas instanciadas do gerador ("ArvoresInstanciadas", 156 cópias) são **cópias só de desenho** (`renderOnly`) das mesmas 52 árvores, que existem como modelos normais. A exportação as exclui de propósito. Por isso **não foi preciso clonar árvores**. O arquivo de instâncias ficou como `…_DUPLICATAS_DE_RENDER_nao_usar.json`.

## 2. Correções em lote (IMPLEMENTADO e TESTADO)

| Item | Resultado |
|---|---|
| Posição | Cada lote foi posicionado pelo centro da caixa, compensando o giro de 180°. **Erro máximo:** 0,001 (arquitetura), 0,003 (props), 0,001 (recursos) e 0,001 (vegetação, conferida pela posição) |
| Nomes repetidos na vegetação | O Importador 3D **reaproveita a malha e o nome** entre árvores da mesma forma: 120 peças vieram com o nome de outra árvore. Corrigi pela posição; os materiais conferem (0 diferenças) |
| Âncora e colisão | As 493 peças foram ancoradas e ficaram só visuais. Vieram 0 ancoradas, como nas importações anteriores |
| Cores lisas | 322 peças sem textura corrigidas: Rocha → Slate `#5b5e72`; emissivos → Neon; o resto pela cor autoral e pelo material deduzido do nome |
| Organização | `Dimensions/StormIsland/{Architecture, Props, Resources, Vegetation}`, com `Id` e tag em cada modelo. São **226 colisores** dos manifests |
| **Pisos fora dos manifests** | 73 peças em `Dimensions/StormIsland/Pisos`, vindas das superfícies caminháveis do gerador (`isl.walks`, salvas em `superficies_caminhaveis.json`) e de medições: patamar da Torre, 2 plataformas, **Ponte da Fenda** (12 segmentos que seguem o tabuleiro medido), **deck do mirante**, túnel e câmara da caverna, e a **Praça do Coletor** (disco e 3 degraus da base, pelo perfil radial medido: o calçamento ficava de 0,9 a 2,8 acima do terreno) |
| **Caverna escavada** | Um mapa de alturas não faz túnel. Escavei no Terrain o túnel (41 trechos, 12 de largura, do piso a +15) e a câmara (raio 16). O terreno do túnel ficou em 24, abaixo do piso projetado de 26,5, e o colisor de piso fica em 26,5 |
| Grama decorativa | O terreno sob as 17 construções passou de grama para calçada, como na Doca |

## 3. Testes no Play, estrutura por estrutura (TESTADO)

| Estrutura | Teste (andando com `MoveTo`) | Resultado |
|---|---|---|
| **Torre Meteorológica** | Do pé da escadaria (26,7) até o patamar da porta | ✓ chegou a **43,3** (projeto: 43,2) |
| **Ponte da Fenda** | Margem oeste → cabeceira A → meio → cabeceira B → margem leste | ✓ atravessou (7,0 → 7,8 → 12,8), terminando na calçada |
| **Caverna do Trovão** | Fora → boca → túnel → fim do túnel → câmara | ✓ túnel inteiro. Na câmara, o **depósito de cristais** (`STORM.MINE.02`, no centro) bloqueia a linha reta, como projetado; contornando, chegou à lateral, ao fundo e à bobina antiga |
| **Mirante** | Deck em balanço de ponta a ponta | ✓ (28,3 → 28,8). Parou no guarda-corpo da ponta |
| **Plataforma 1** | Personagem solto sobre ela | ✓ raiz em 22,50 (esperado cerca de 22,4) |
| **Vila e Praça do Coletor** | Entrada e volta no anel | ✓ leste, norte e oeste. O centro é bloqueado pelo pilar do Coletor (projeto). Este teste foi feito **antes** do piso da praça; o piso foi acrescentado depois e **não foi retestado no Play** |
| **Santuário** | Até o platô e o altar | ✓ (10,1) |
| **Observatório** | Fim da trilha P4 → porta | ✗ **parou.** Ver a seção 5 |
| Output | — | ✓ nenhum erro novo. Testes: 234 passaram, 0 falharam |

## 4. Capturas (`guardioes/docs/ilha-lote/`)

1. `01-ilha-completa-aerea.jpg`: a ilha inteira. Aparecem a Torre no centro, a vila, a floresta de árvores retorcidas, o observatório com a cúpula, a fenda, a doca ao sul e a cordilheira.
2. `02-vila-e-torre.jpg`: a Torre detalhada, as casas com enxaimel, a Praça do Coletor, a barraca, as lanternas, as torres de transmissão com cabos, a Ponte da Fenda, a boca da caverna e o observatório ao fundo.

As capturas de perto da ponte e da caverna **expiraram** (o Studio fica pesado com a ilha inteira): **PENDENTE**.

## 5. Problemas encontrados

| # | Problema | Status |
|---|---|---|
| 1 | **Observatório inacessível a pé.** No **próprio gerador**, a trilha P4 termina em 47,8 (z −106) e o platô da porta está em 65,7 (z −110): **cerca de 18 studs em 4**, sem rampa nem escada (conferi as alturas no visualizador e os colisores do modelo). A conversão para voxels foi fiel; o defeito é do **projeto-fonte**. Hoje só dá para chegar voando | **PENDENTE: decisão.** Opções: (a) uma rampa ou escadaria no terreno do platô; (b) corrigir o gerador e reimportar. Não inventei sem aprovação |
| 2 | O Importador 3D reaproveita o nome entre malhas idênticas | Contornado pela posição. Vale para as próximas importações com formas repetidas |
| 3 | Piso da praça sem teste no Play | **PENDENTE:** retestar |
| 4 | As capturas de perto da ponte e da caverna expiraram | **PENDENTE** |

## 6. Pendências que continuam

- **Jogabilidade:** spawn e portal de volta (decisões de jogo) e os chefes e marcadores na ilha nova.
- **Terreno:** as bordas laterais em x = ±300 e o paredão liso.
- **Desempenho:** FPS real. Agora com a ilha inteira (cerca de 290 mil triângulos de construções e vegetação, mais o terreno), isso **ficou mais importante**.
- **Outros:** o brilho das runas, o colisor 16 da Oficina na fonte e o `203785492`.

## 7. Arquivos

- **Lote:** `dimensoes/Exports/StormIsland/Lote/` (4 GLBs, 4 manifests, `lote_mapa.json`, `superficies_caminhaveis.json` e `LoteIlhaDados.luau`).
- **Torre isolada:** `dimensoes/Exports/StormIsland/Tower/` (o GLB isolado foi exportado; a Torre entrou pelo lote).
- **Procedimento:** `dimensoes/Exports/ferramentas/processar_lote.md`.

## 8. Próxima ação proposta

1. Decidir o **acesso ao observatório** (problema 1).
2. Retestar o piso da praça e fazer as capturas que faltaram.
3. Medir o **desempenho** com a ilha inteira, com o Studio em foco.
4. Depois disso: **chefes e marcadores** nos lugares do GDD (Guardião no topo da Torre, Rainha na câmara, Colosso nas Ruínas, Espectro no Observatório, Cão na Floresta), usando o patch `SoloDaArena` guardado. Isso já é jogabilidade e precisa da sua aprovação.
