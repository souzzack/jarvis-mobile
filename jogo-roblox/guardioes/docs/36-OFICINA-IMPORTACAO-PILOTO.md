# 36 · Oficina dos Inventores: exportação e importação piloto (relatório 3, para revisão)

Data: 20/11/2026. Responde à "Aprovação da Supervisão 02". Só a Oficina foi exportada e importada. Nenhuma outra estrutura foi tocada, a oficina do tycoon continua igual e o place original não foi aberto.

## 1. GLB exportado (IMPLEMENTADO e TESTADO)

| Item | Valor |
|---|---|
| Caminho | `jogo-roblox/dimensoes/Exports/StormIsland/Workshop/STORM.ARCH.WORKSHOP.glb` (em disco: `C:\Users\VICTOR\GuardioesTeste\jogo-roblox\dimensoes\Exports\StormIsland\Workshop\`) |
| Tamanho | **3.703.524 bytes** (3,53 MB) |
| Arquivo ao lado | `STORM.ARCH.WORKSHOP.manifest.json` (4.129 bytes): pivô, rotação, tamanho e os **24 colisores** |
| Como foi gerado | Pela rotina de exportação do próprio visualizador (`buildPack([modelo])`), a mesma do botão "Exportar GLB". A Oficina é a V2.3.5. A página mandou os bytes para um servidor local, que só aceita gravar em `Exports/StormIsland/Workshop/` e nunca sobrescreve |
| Fonte | Os arquivos de `StormIsland/`, os backups `v2*-backup` e os arquivos da ilha antiga **não foram alterados** |

### Validação do GLB

| Teste | Resultado |
|---|---|
| Leitura independente em Python (sem bibliotecas) | glTF **2.0**, cabeçalho e tamanho batem, 112 nós, **49 malhas**, **40.870 triângulos**, nenhum vértice NaN ou infinito |
| Limite do Roblox por malha | A maior malha tem **6.568 triângulos** (nenhuma passa de 10 mil) |
| Materiais | 17 materiais, com 9 texturas PNG embutidas |
| Escala (1 unidade = 1 stud) | Caixa exata de **41,97 × 28,84 × 39,95 studs**. O documento da V2.3.5 dá 26 × 20 só para o edifício, e o total soma escada, beiral e rochas |
| Pivô | (−84,04; 15,83; 98,04), com rotação Y de 141,6°. Igual ao documento da V2.3.5 |
| Reabertura (three.js `GLTFLoader`) | Abre sem erro: 49 malhas, 40.870 triângulos, nenhuma malha sem material |
| Nomes usados pelos scripts Luau | Presentes: `Planetario`, `Pistoes`, `EngrenagensCondensador`, `VolanteGerador`, `PonteiroManometro`, `InteriorLOD` |

## 2. Importação piloto (IMPLEMENTADO e TESTADO)

- **Quem fez:** você, pelo Importador 3D do Studio, na cópia "11202026_2". Eu não tenho ferramenta para operar o importador.
- **Caminho final:** `Workspace.Dimensions.StormIsland.Architecture["Oficina dos Inventores"]`. O invólucro `AuxScene/Node0`, que o importador cria, ficou vazio e foi removido.
- **Atributos no modelo:** `IdVisualizador`, `VersaoVisualizador`, `PivoNaIlha` e `Origem`.
- **Área de teste isolada:** `Workspace.Dimensions.StormIsland.AreaDeTeste`. Tem um piso provisório de 100 × 100 em y = 150 (topo), uma grade a cada 10 studs e um boneco de escala de 5,2 studs. **Não é terreno definitivo.**
- **Posição:** o pivô da Oficina está em **(2000, 150, 0)**, com a mesma rotação da ilha (141,6°).
- **Place:** cópia de teste salva na **versão 8**.

### Verificações

| Item | Resultado |
|---|---|
| **Geometria** | **49 de 49 MeshParts**, nenhuma peça faltando. Caixa de 41,96 × 28,84 × 39,95 studs, igual ao GLB |
| **Escala** | Correta (stud). O avatar fica proporcional à porta de 8 studs (captura 02) |
| **Orientação** | O importador **girou o modelo 180° em Y**, porque o glTF e o Roblox usam frentes opostas. É uma rotação pura, sem espelhamento. Corrigi na hora de posicionar. Conferência: telhado e planetário ficaram a **0,005 stud** da posição esperada |
| **Ancoragem** | **0 de 49 vieram ancoradas**, então a Oficina cairia no Play. **Corrigido:** 73 de 73 peças ancoradas (49 malhas e 24 colisores), conferido no Play |
| **Texturas** | 28 peças com SurfaceAppearance (cor e normal), 5 com TextureID e 16 sem textura. As 2 malhas de **Runas** vieram com textura (provavelmente a das runas que brilham) |
| **Cores das peças lisas** | **As 16 peças sem textura perderam a cor**: o importador deixou todas no cinza padrão (#a3a2a5). **Corrigido** com a cor-base de cada material no GLB, convertida para sRGB. A peça de cada malha foi achada pela posição (erro abaixo de 0,05 stud) |
| **Emissão** | O Roblox não importa material emissivo. Usei uma aproximação: Neon nas luzes e no núcleo, Glass no cristal. O brilho das runas não existe no Roblox (as 2 peças ficam como vieram) |
| **Cor por vértice** | As Moitas usam cor por vértice, que **não veio** na importação. Ficou a cor média do GLB (#26362b) |
| **Colisão** | As 49 malhas vieram **com colisão ligada**. **Corrigido:** desligada nas malhas (são visuais) e criadas as **24 caixas do manifest** em `…Oficina dos Inventores.Colisores`, invisíveis e ancoradas, encaixadas pelo pivô. Todas ficam dentro do volume do modelo, e a porta está livre |

Correção das cores das peças lisas:

| Material no GLB | No Roblox | Peças |
|---|---|---|
| Rocha | Slate #a1a3b2 | 7 |
| OficinaVidro (alfa 0,6) | Glass #6f8c99, transparência 0,4 | 3 |
| OficinaLuzQuente (emissivo) | Neon #ffd9a0 | 3 |
| OficinaNucleo (emissivo) | Neon #c8f6ff | 1 |
| OficinaCristal (alfa 0,92) | Glass #b8eeff, transparência 0,08 | 1 |
| OficinaMoitas (cor por vértice) | LeafyGrass #26362b (média das cores de vértice) | 1 |

### Teste no Play (TESTADO)

O personagem andou com `Humanoid:MoveTo`, como um jogador. As posições estão em coordenadas locais da Oficina (altura 3,1 = no chão; 4,7 = sobre o plinto):

| Trecho | Resultado |
|---|---|
| Fora → pé da escada | (0; 3,1; 18,7) ✓ |
| Escada → patamar | (0; 4,6; 12,7) ✓ (subiu os degraus) |
| Porta → interior | (0; 4,7; 3,6) ✓ (passou pelo vão da porta) |
| Tentar ir ao fundo | Parou em z = −0,4, no Condensador (colisores 11 e 12) ✓ |
| Tentar atravessar a lateral | Parou em x = −8,8, nas bancadas, antes da parede ✓ |
| Voltar e sair | (0; 3,1; 21,4) ✓ |

### Output

- **Erros novos: nenhum.** Os testes de lógica passaram (234 de 234).
- O único erro continua sendo o `rbxassetid://203785492 … Asset type does not match` (3 vezes). Já existia antes desta etapa, vem de fora do jogo e segue **PENDENTE** do relatório 34.

## 3. Capturas reais do Studio (`guardioes/docs/oficina-piloto/`)

1. `01-importada-antes.jpg`: como o importador deixou o modelo, flutuando sobre o mar onde a câmera estava.
2. `02-exterior-area-de-teste.jpg`: na área de teste, com o avatar e a grade. Aparecem a porta em arco, as janelas, as lanternas, o telhado em chapa, as calhas e os 3 para-raios.
3. `03-interior-condensador.jpg`: o interior, com o Condensador Atmosférico, as estantes, a mesa, os manômetros e o gerador.
4. `04-colisores-sem-telhado.jpg`: os 24 colisores em rosa, com o telhado escondido. Paredes com o vão da porta, degraus, Condensador, bancadas e estantes.

## 4. Problemas encontrados

| # | Problema | Status |
|---|---|---|
| 1 | O importador gira o modelo 180° em Y | **Contornado** ao posicionar. **Vale para todas as próximas importações** |
| 2 | Peças importadas sem âncora | **Corrigido**. Nas próximas, marcar "Anchored" no importador ou aplicar a mesma correção |
| 3 | Malhas importadas com colisão ligada | **Corrigido** (visuais sem colisão, mais 24 caixas) |
| 4 | Cor-base dos materiais sem textura não importada (16 peças em cinza) | **Corrigido** com a tabela acima |
| 5 | Emissão e brilho perdidos (luzes, núcleo, cristal, runas) | **Aproximado** com Neon e Glass. O brilho das runas **PENDENTE** |
| 6 | Cor por vértice (moitas) não importada | **Aproximado** com a cor média |
| 7 | **Interior escuro**: o visualizador tem luz quente interna, e o Roblox não recebe luzes pelo GLB | **PENDENTE**. A luz vem do script de rascunho `OficinaServidor`, que não foi aplicado para não criar comportamento nesta etapa |
| 8 | **O telhado não tem colisor**: os 24 previstos não incluem o telhado, então quem chegar voando ou de planador atravessa por cima | **PENDENTE**. Recomendo uma caixa de telhado (fora dos 24 previstos) |
| 9 | Os nomes das peças são `NodeNN` (os nós do GLB não tinham nome nas malhas) | Os grupos com nome vieram certos. Cada peça ganhou os atributos `MaterialGLB` e `NoGLB` para rastrear |
| 10 | Rotação 141,6° herdada da ilha | Mantida para os colisores baterem. Na ilha nova, é só posicionar o pivô pelas coordenadas do plano |

## 5. Próxima correção recomendada (PLANEJADO, aguarda aprovação)

1. **Luz interna da Oficina:** uma PointLight quente no ponto do Condensador, como no visualizador. É visual, sem mecânica.
2. **Colisor do telhado:** uma caixa inclinada ou duas caixas, para quem chega voando.
3. **Transformar as correções desta importação num procedimento único:**
   - girar 180° e posicionar pelo pivô;
   - ancorar;
   - malhas sem colisão e colisores do manifest;
   - cores dos materiais lisos.
   
   Assim, a **próxima estrutura** (proposta: a Torre Meteorológica, peça central e futura arena do Guardião) é importada do mesmo jeito.
4. Só depois disso: o terreno da nova ilha pelo heightmap, em (2000, 150, 0), quando você aprovar.

## 6. Status

| Item | Status |
|---|---|
| GLB da Oficina | **IMPLEMENTADO e TESTADO** |
| Importação piloto, escala, orientação, peças, ancoragem e colisores | **IMPLEMENTADO e TESTADO** (Play) |
| Materiais | **IMPLEMENTADO** (16 peças corrigidas). O brilho das runas e a luz interna estão **PENDENTES** |
| Demais estruturas | **Não importadas** (aguardam revisão) |
| Terreno definitivo | **Não gerado** |

## 7. Revisão 03: luz interna e colisor do telhado (aprovado: "Pode aplicar")

| Item | O que foi feito | Status |
|---|---|---|
| **Luz interna** | Peça âncora invisível `…Oficina dos Inventores.LuzInterna`, sem colisão, com uma PointLight. Valores do projeto (`OficinaConfig.lua`): local (0; 10,1; 1), cor (255, 180, 104), brilho 1,6, alcance 34, sem sombra. É só visual: o "apagar de longe" do script cliente **não** foi aplicado | **IMPLEMENTADO e TESTADO** (captura `05-interior-com-luz.jpg`) |
| **Telhado** | 2 caixas, `Colisor25_TelhadoFrente` e `Colisor26_TelhadoFundo`, com a geometria de `oficina.js`: inclinação 0,55, cumeeira em 18,45, água de 28,8 × 13,24. Marcadas com o atributo `ForaDoManifest` | **IMPLEMENTADO e TESTADO** |
| **Defeito no colisor 16 do manifest** (verga da porta) | No manifest a caixa ficava entre 13,0 e 16,4, **toda acima do topo da parede (12,6)**. Isso fazia um calombo invisível de cerca de 2,5 studs sobre o telhado, no beiral, e deixava o vão de colisão da porta aberto até 13,0, mais alto que o arco visual (cerca de 9,25, medido por raios). Corrigi **só no Studio**: caixa de 6,4 × 3,3 × 0,9 entre 9,3 e 12,6. O valor original ficou no atributo `ManifestOriginal` | **IMPLEMENTADO e TESTADO** (raio). **PENDENTE:** corrigir também a fonte (`oficina.js` / manifest), que não alterei para preservar os arquivos-fonte |

**Testes no Play:**
- **Telhado:** o personagem foi solto 30 studs acima de cada água e ficou **em cima do telhado** (raiz em y = 19,3, pés na chapa em torno de 16). Antes, cairia até o piso interno (4,7).
- **Raios:** o colisor do telhado fica 0,19 stud abaixo da chapa visual nas duas águas. No beiral, 13,44 contra 13,63.
- **Entrada:** escada, patamar, porta e interior continuam passando.
- **Pulo à frente da porta:** a raiz subiu 3,8 studs, o pulo configurado pelo `MovementSystem`. Ele não testou a verga por baixo; a verga foi conferida pela geometria.
- **Output:** nenhum erro novo. Testes: 234 passaram, 0 falharam.
- **Colisores:** agora são 26 (24 do manifest e 2 do telhado). A cópia de teste está salva na **versão 9**.

**Observação para decisão:** com os valores do projeto, a luz deixa o interior **laranja saturado** no Roblox, mais forte que no render do visualizador (as duas iluminações são diferentes). Sugiro calibrar: brilho perto de 0,8 e alcance perto de 24. Não alterei sem a sua aprovação.

**Pendências que restam:** o brilho das runas (sem equivalente direto), a calibragem da luz, a correção do colisor 16 na fonte e o procedimento padrão de importação para a próxima estrutura.
