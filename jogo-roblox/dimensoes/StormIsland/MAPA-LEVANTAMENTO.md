# Ilha das Tempestades: levantamento das estruturas

Este levantamento foi feito em 18/11/2026, no visualizador three.js. **Nada foi verificado no Roblox Studio.**

Todas as construções são geradas pelo código em `StormIsland/`, e nenhum arquivo de construção está faltando. Os modelos para o Studio saem do botão "Baixar pacote" (GLB por categoria).

## Regras deste ciclo

- **Oficina dos Inventores: CONGELADA.**
  - Fica igual à V2.3.5: geometria, materiais, luz, decoração, interior, Condensador e posição.
  - `Architecture/oficina.js` não é editado.
- **Torre Meteorológica:** já é um modelo detalhado (V2, 69 mil triângulos, 36 colisores). Não entra na fila. Só seria revista se aparecer um defeito.
- Nada é apagado, e a escala do cenário não muda.
- Cada estrutura é melhorada **uma vez**, sem versões repetidas.
- Ponto de restauração antes deste ciclo: `../v235-backup/`.

## Estado de cada estrutura

**Base da medição:**
- Diagnóstico Estrutural antes de qualquer mudança: 88 verdes, 5 amarelos, 0 vermelhos, 0 interseções e 24 de 24 rotas.
- Os triângulos são os da cena antes das mudanças.

### Construções

| # | Estrutura (id) | Arquivo | Triângulos | Estado atual | Problemas | Melhorias necessárias |
|---|---|---|---|---|---|---|
| 1 | **Casas da vila 1–5** (`STORM.ARCH.HOUSE.01–05`) | `Architecture/vila.js` | 550–750 cada | protótipo | <ul><li>Paredes são caixas maciças.</li><li>Porta e janelas são placas coladas na fachada, sem abertura.</li><li>Telhado é um prisma sólido, sem espessura, beiral ou calha.</li><li>Chaminé torta.</li><li>Na casa redonda, o cone do telhado ficava até 0,4 stud acima da parede (fresta).</li></ul> | <ul><li>Aberturas reais.</li><li>Cantaria e enxaimel.</li><li>Telhado estruturado.</li><li>Materiais da mesma família da oficina.</li></ul> |
| 2 | **Boca da Caverna do Trovão**, túnel e Bobina antiga (`STORM.ARCH.CAVE.*`, `STORM.EQUIP.01.MODEL`) | `Architecture/caverna.js` | 408 + 2.536 + 1.464 | protótipo, com defeito visual | <ul><li>A verga de 37 × 7,5 studs parece um bloco solto na frente do paredão.</li><li>As aduelas são caixas retas, desalinhadas da curva.</li><li>Túnel liso, sem escoramento nem iluminação.</li><li>Bobina com 3 primitivas.</li></ul> | <ul><li>Pórtico de mina em pedra e ferro encaixado na rocha.</li><li>Escoramento do túnel.</li><li>Trilhos e lanternas.</li><li>Bobina detalhada.</li></ul> |
| 3 | **Doca de chegada e arco do portal** (`STORM.ARCH.ARRIVAL`) | `Props/props.js` | 1.112 | protótipo | <ul><li>Arco de duas caixas com um anel.</li><li>Tablado liso.</li><li>É a primeira coisa que o jogador vê.</li></ul> | <ul><li>Portal com moldura de pedra e cobre e cristais.</li><li>Doca de tábuas com estacas e amarras.</li></ul> |
| 4 | **Barracas do mercado 1–2** (`STORM.PROP.STALL.*`) | `Architecture/vila.js` | 170–226 | protótipo | <ul><li>Balcão-caixa.</li><li>Toldo de placa reta.</li><li>Postes finos sem travamento.</li></ul> | <ul><li>Balcão de tábuas.</li><li>Toldo de lona com caimento.</li><li>Mercadorias.</li><li>Mesma família de materiais das casas.</li></ul> |
| 5 | **Praça do Coletor** (`STORM.ARCH.VILLAGE.PLAZA`) | `Architecture/vila.js` | 1.562 | simples | <ul><li>Pilar de cobre liso.</li><li>Bancos-caixa no anel.</li></ul> | <ul><li>Coletor com bobinas e isoladores.</li><li>Bancos de pedra.</li><li>Calçamento em anel.</li></ul> |
| 6 | **Santuário da Tempestade** (`STORM.ARCH.SANCTUARY`) | `Architecture/observatorio.js` | 412 | protótipo | <ul><li>Pilares hexagonais lisos.</li><li>Altar-caixa.</li><li>Base sem degraus.</li></ul> | <ul><li>Pilares com capitel e runas.</li><li>Altar esculpido.</li><li>Degraus.</li></ul> |
| 7 | **Mirante do Penhasco das Nuvens** (`STORM.ARCH.CLIFF.LOOKOUT`) | `Props/props.js` | 200 | protótipo | <ul><li>Cocho de caixas com um cilindro (luneta).</li></ul> | <ul><li>Mirante com guarda-corpo, piso de lajes e luneta de latão.</li></ul> |
| 8 | **Observatório Abandonado** (`STORM.ARCH.OBSERVATORY`) | `Architecture/observatorio.js` | 2.454 | razoável | <ul><li>O anexo são 5 placas retas.</li><li>As nervuras da cúpula se cruzam.</li><li>Cilindro sem aberturas além da porta.</li></ul> | <ul><li>Anexo em ruína com aberturas.</li><li>Nervuras alinhadas.</li><li>Janelas.</li></ul> |
| 9 | **Plataformas elevadas 1–2** (`STORM.ARCH.PLATFORM.*`) | `Architecture/pontes.js` | 560–588 | simples | <ul><li>Laje de caixa sem guarda-corpo real.</li><li>Escada de blocos.</li></ul> | <ul><li>Tablado de tábuas.</li><li>Guarda-corpo.</li><li>Escada de madeira apoiada.</li></ul> |
| 10 | **Torres e linha de transmissão** (`STORM.PROP.PYLON.*`, `POWERLINE`) | `Props/props.js` | 316 cada | aceitável | <ul><li>Treliça simples.</li></ul> | <ul><li>Isoladores e base de concreto.</li></ul> |
| 11 | **Ponte Suspensa da Fenda** (`STORM.BRIDGE.01`) | `Architecture/pontes.js` | 2.168 | boa | <ul><li>Amarelo conhecido: tábuas sobre o lábio da fenda.</li></ul> | <ul><li>Revisar as cabeceiras.</li></ul> |
| 12 | **Ruínas tecnológicas** (`STORM.PROP.RUINS`) | `Props/props.js` | 596 | simples | <ul><li>Amarelo: 3 pontos com folga ≤ 1,5.</li></ul> | <ul><li>Assentar.</li><li>Detalhar as peças.</li></ul> |
| 13 | Minas 1–4 e depósitos (`STORM.RES.*`) | `Resources/` | 400–6.000 | bom | — | — |
| — | Torre Meteorológica (`STORM.ARCH.TOWER`) | `Architecture/torre.js` | 69.248 | **detalhada (concluída)** | — | — |
| — | Oficina dos Inventores (`STORM.ARCH.WORKSHOP`) | `Architecture/oficina.js` | ~36 mil | **congelada** | — | — |

### Vegetação

Os amarelos das árvores 25, 27 e 48 são da vegetação, não de construções.

## Ordem recomendada

1. **Casas da vila.** São as que têm mais problemas somados: 5 modelos-protótipo, no centro da vila e ao lado da oficina aprovada. **Feito neste ciclo.**
2. Boca da Caverna, túnel e Bobina antiga, que têm o defeito visual mais evidente. **Feito.**
3. Doca de chegada e portal (primeira impressão). **Feito.**
4. Barracas e Praça do Coletor, para fechar a vila. **Feito.**
5. Santuário. **Feito.**
6. Mirante do Penhasco. **Feito.**
7. Observatório. **Feito.**
8. Plataformas elevadas.
9. Ponte e ruínas, para resolver os amarelos.
10. Torres de transmissão.

## 1ª estrutura: casas da vila (feito)

Arquivo alterado: `Architecture/vila.js`, apenas na função `I.buildHouse` e no novo `I.houseMats`.

**O que não mudou:**
- posição, orientação e altura;
- planta (w × d), variantes e alturas dos telhados (mesmo sorteio);
- os 4 ou 5 colisores de cada casa;
- laje pisável, degraus de `MM.seat` e ponta do para-raios (os cabos continuam ligados ao Coletor).

**O que mudou:**
- **Térreo:**
  - cantaria com aberturas reais;
  - porta em arco de 4 × 7 studs recuada 0,3 stud, com aduelas, fecho, tábuas, ferragens, argola e soleira;
  - janelas com caixilho, montante, travessa, peitoril e verga;
  - cunhais alternados nos 4 cantos.
- **Andar (casas de 2 pisos):**
  - balanço com viga de borda e consolos;
  - reboco com enxaimel (esteios, baldrame, frechal, travessa e escoras) e janelas.
- **Telhado:**
  - chapas com espessura e juntas em pé, cumeeira, guarda-pó nas empenas;
  - calhas e condutores até o plinto;
  - empenas fechadas com óculo de vidro aceso e aro de cobre.
- **Telhado de uma água:** paredes de fechamento de verdade.
- **Casa redonda:**
  - cone apoiado no topo da parede; antes ficava até 0,4 stud acima, com fresta;
  - forro do beiral, calha, 10 nervuras e remate de cobre;
  - porta com ombreiras e juntas;
  - janelas emolduradas e cintas de pedra.
- **Chaminé:** cantaria reta, sem a inclinação de antes, com capelo e dois potes.
- **Lanterna:** junto à porta. Quando não cabe, vai na lateral, perto da frente.
- **Para-raios:** isolador, bobinas e esfera.
- **Materiais:** 8 por casa, compartilhados por todas e da mesma família da oficina (cantaria, pedra lavrada, madeira, reboco, chapa azul-escura, ferro, cobre e vidro aceso).

**Validação no visualizador (não no Studio):**
- Diagnóstico: 88 verdes, 5 amarelos (os mesmos de antes), 0 vermelhos, 0 interseções e 24 de 24 rotas, incluindo as rotas até as portas das casas.
- Cada casa tem 7 a 8 malhas depois da fusão por material, com 3,4 a 6,7 mil triângulos (antes, 550 a 750).

**Custo da cena** (efeitos desligados, mesmas câmeras):

| Vista | Antes (chamadas / triângulos) | Depois (chamadas / triângulos) |
|---|---|---|
| Vila | 801 / 1.552.271 | 788 / 1.599.327 |
| Três quartos | 1.014 / 1.358.477 | 1.001 / 1.405.533 |
| Nível do jogador | 617 / 1.477.273 | 608 / 1.500.279 |

São cerca de 47 mil triângulos a mais e cerca de 13 chamadas a menos.

**Exportação:** `Architecture.glb` traz os materiais `Ilha*` (família compartilhada pelas estruturas da ilha). As duas pedras (triplanares) saem como "Rocha", como na oficina.

**Imagens:**
- `../../referencias/mapa-levantamento-estruturas.jpg`
- `../../referencias/mapa-casas-antes-depois.jpg`
- `../../referencias/mapa-casas-vistas.jpg`

**Pendências no Roblox Studio:**
- importar e conferir os nomes;
- conferir os colisores (as casas não são exploráveis por dentro);
- conferir como a pedra fica depois de virar "Rocha";
- medir o FPS na vila num aparelho real.

## 2ª estrutura: Caverna do Trovão (feito)

**Arquivos alterados:**
- `Architecture/caverna.js` (reescrito);
- `Props/props.js`: uma linha, que deixa de criar a rocha solta que atravessava o contraforte novo. O sorteio das outras rochas não muda.

**O que não mudou:**
- posição da boca;
- traçado e forma do túnel natural;
- câmara e estalactites;
- piso caminhável (dados de rota), ids e marcadores;
- mina STORM.MINE.02 e lugar da bobina STORM.EQUIP.01.

**O que mudou:**
- **Pórtico.** Antes eram uma verga-caixa de 37 × 7,5 studs que parecia solta na frente do paredão, 13 aduelas-caixa e 2 hastes soltas. Agora é uma fachada de cantaria de 34 × 22 studs, apoiada no adro e encostada no paredão:
  - arco de verdade, com 14 aduelas em cunha e fecho saliente;
  - emblema da tempestade no fecho: aro e raio de cobre, mais um cristal;
  - ombreiras em fiadas alternadas e impostas;
  - embasamento, fiada saliente, cornija e frontão escalonado;
  - placas de ferro rebitadas com moldura de cobre;
  - 2 lanternas de parede;
  - contrafortes em talude que escondem a junta com a rocha.
- **Atrás do arco.**
  - abóbada de alvenaria com 3 arcos de ferro;
  - anel de fechamento que esconde a fresta entre a abóbada e o túnel natural.
- **Na entrada.**
  - soleira e adro de lajes com juntas de ferro, cobrindo o recorte do terreno na boca;
  - degrau de 0,5 stud.
- **Túnel.**
  - piso contínuo de 12 studs (antes eram 40 placas com frestas na curva);
  - trilhos com dormentes até a câmara;
  - 4 quadros de escoramento (esteios, chapéu e mãos-francesas, cada um com sua lanterna), com colisores nos esteios;
  - entulho ao pé da parede da câmara.
- **Bobina antiga.**
  - pedestal octogonal e coluna de isoladores;
  - bobina helicoidal de cobre com 14 voltas e toroide;
  - armação de ferro e cabo até a parede.

**Validação no visualizador (não no Studio):**
- Diagnóstico: 88 verdes, 5 amarelos (os mesmos de antes), 0 vermelhos e 0 interseções.
- 24 de 24 rotas, incluindo a da caverna.
- Durante o trabalho apareceram e foram corrigidos:
  - uma rocha da ilha atravessando o contraforte;
  - duas rochas de acabamento que caíam dentro do vão;
  - entulho encostado na bobina.

**Custo** (vista Vila, efeitos desligados, depois das casas e da caverna): 802 chamadas e 1.614.739 triângulos. Só com as casas eram 788 e 1.599.327. A caverna somou cerca de 14 chamadas e 15 mil triângulos:
- pórtico: cerca de 6,1 mil triângulos;
- túnel: cerca de 4,6 mil;
- bobina: cerca de 5 mil.

**Imagem:** `../../referencias/mapa-caverna-antes-depois.jpg`

**Pendências no Roblox Studio:**
- O recorte da boca no Terrain do Roblox precisa ser feito no Studio (por exemplo, com subtração de região) ou coberto pelo pórtico importado. O heightmap sozinho fecha a boca.
- A abóbada e o túnel são vistos por dentro. No Roblox, conferir se a face interna aparece; senão, usar `DoubleSided` na MeshPart.
- Conferir os colisores dos esteios e das ombreiras com um personagem andando.

## 3ª estrutura: Doca de chegada e portal (feito)

Arquivo alterado: `Props/props.js`, só o bloco `STORM.ARCH.ARRIVAL`.

**O que não mudou:**
- posição da doca;
- spawn (STORM.SPAWN.01) e marcador do portal (STORM.PORTAL.01);
- área caminhável de 30 × 26 studs, com o topo do piso no mesmo nível;
- rota "chegada: doca → P1";
- o anel de energia continua com o nome `AnelPortal`, no mesmo centro e no mesmo raio.

**Praça:**
- Antes: tablado liso com 6 frisos escuros.
- Agora:
  - laje de cantaria com piso de pedra lavrada, juntas em grade e meio-fio;
  - rosa-dos-ventos de cobre com núcleo de energia no ponto de chegada;
  - alicerce de cantaria até o chão real, no lado do penhasco (antes a borda sul ficava a 0,6 stud do chão);
  - balaustrada de balaústres torneados nos cantos do lado do penhasco;
  - 4 postes de luz;
  - placa de direções com 3 setas (no lugar da placa antiga);
  - bagagens de quem chega: baús e barris.

**Portal:**
- Antes: 2 colunas-caixa, uma viga-caixa, um meio anel de cobre e o anel de energia.
- Agora:
  - estrado de dois degraus;
  - anel de 19 aduelas de pedra, em pé sobre o estrado e preso aos pilares;
  - fecho com o mesmo emblema da tempestade da caverna;
  - runas de cobre nas duas faces e 8 cristais voltados para o centro;
  - segundo anel de energia, mais fino;
  - pilares com base, fuste de cantaria, cintas e bobina de cobre em espiral, e capitel;
  - entablamento em degraus;
  - para-raios com bobinas e cristais nas pontas.

**Validação no visualizador (não no Studio):**
- Diagnóstico: 88 verdes, os mesmos 5 amarelos, 0 vermelhos e 0 interseções.
- 24 de 24 rotas.
- 11 colisores novos: estrado, pilares, balaustrada, postes, placa e bagagens.

**Custo:** a doca tem cerca de 14 mil triângulos (antes, 1,1 mil). Na vista da Vila ficou em 801 chamadas e 1.625.675 triângulos.

**Imagem:** `../../referencias/mapa-chegada-antes-depois.jpg`

**Pendências no Roblox Studio:**
- conferir os colisores do estrado, porque o degrau de 0,5 deve ser subido sem pulo;
- ligar o `AnelPortal` ao script de teleporte quando ele existir.

## 4ª estrutura: Praça do Coletor e barracas do mercado (feito)

Arquivo alterado: `Architecture/vila.js`, só os blocos da praça e das barracas. As casas e a oficina não foram mexidas.

**O que não mudou:**
- posição e assentamento da praça (raio de 17,6 studs);
- colisor do Coletor (9 × 18 × 9);
- altura da esfera de energia, que é a raiz dos cabos dos para-raios, então os cabos não mudam;
- regras de posição das barracas e o colisor do balcão de cada uma.

**Praça:**
- Antes: discos lisos com 24 blocos escuros em anel.
- Agora:
  - calçamento de cantaria com anel de pedra lavrada;
  - 3 frisos de cobre, 12 raios de pedra e 12 frisos de cobre diagonais;
  - 4 bancos curvos e 4 postes de luz, colocados só onde não há trilha (com colisores).

**Coletor:**
- Antes: coluna de cobre lisa com 3 argolas.
- Agora:
  - pedestal octogonal de 3 degraus;
  - colares de isoladores e anéis de pátina;
  - bobina helicoidal de cobre de 10 voltas e 6 travessas de ferro;
  - coroa de 6 garras segurando o cristal, com 3 cristais menores;
  - aro de cobre na esfera de energia.

**Barracas:**
- Antes: caixa, 4 varas e toldo de placa.
- Agora:
  - estrado de tábuas;
  - balcão de painéis com ferragens, tampo, prateleira e o emblema de cristal;
  - esteios com vigas e toldo listrado inclinado com babado;
  - mercadorias: cristais num caixote, uma peça de cobre, frascos e uma lanterna;
  - barril e caixote no estrado.
- Material novo: `IlhaLona`.

**Validação no visualizador (não no Studio):**
- Diagnóstico: 88 verdes, os mesmos 5 amarelos, 0 vermelhos e 0 interseções.
- 24 de 24 rotas.

**Custo:**
- praça: cerca de 9,8 mil triângulos;
- cada barraca: cerca de 1,5 mil triângulos;
- vista Vila: 814 chamadas e 1.640.031 triângulos (antes deste passo, 801 e 1.625.675).

**Imagem:** `../../referencias/mapa-praca-barracas-antes-depois.jpg`

**Pendências no Roblox Studio:**
- conferir os bancos e os postes (colisores) com o fluxo de jogadores na praça;
- a bobina helicoidal vira uma MeshPart: conferir a `RenderFidelity`.

## 5ª estrutura: Santuário da Tempestade (feito)

Arquivo alterado: `Architecture/observatorio.js`, só a função `I.buildSanctuary`. O observatório não foi mexido.

**O que não mudou:**
- posição e assentamento no platô;
- posições, raios (11/9), alturas (11/9) e cores dos 6 pilares;
- altura das gemas (materiais `Gema0`–`Gema5`);
- a Sétima Estrela no altar (material `SetimaEstrela`, mesma altura);
- colisor do altar (4 × 3 × 4) e rota "P5 → diante do altar".

**Defeitos corrigidos:**
- a base era **heptagonal** (7 lados) para 6 pilares; agora é hexagonal e alinhada com eles;
- os pilares **não tinham colisão**; agora cada fuste tem a sua.

**O que mudou:**
- **Plataforma:** dois degraus hexagonais, mais o degrau de entrada no lado da trilha P5, e um piso de cantaria com hexágono e círculo de cobre.
- **Pilares:**
  - plinto, fuste de cantaria e 3 cintas de cobre;
  - sulcos de runas acesos na cor da própria gema (para dentro e para fora);
  - capitel, colar de ferro e 3 garras segurando a gema.
- **Condutores:** 6 condutores de cobre descem dos capitéis até o altar, altos o bastante para não cruzar a cabeça do jogador.
- **Altar:** escalonado em 3 partes, com esfera armilar de cobre em volta da Sétima Estrela.
- **Muro curvo de runas ao sul:**
  - pilares de pedra nas pontas;
  - a constelação das Sete Estrelas, com a estrela central na cor do núcleo.
- **Braseiros:** 2 braseiros de cristal na entrada.
- **Rochas:** rochas que assentam a plataforma no platô.

**Validação no visualizador (não no Studio):**
- Diagnóstico: 88 verdes, os mesmos 5 amarelos, 0 vermelhos e 0 interseções.
- 24 de 24 rotas.
- Durante o trabalho, o teste de rota acusou bloqueio no pilar da entrada, que fica no eixo da trilha P5. Ajustes feitos:
  - fustes mais finos (faces a 1,08 na base);
  - colisor quadrado girado para alinhar com a chegada da trilha (o fuste é hexagonal);
  - o teste não foi alterado.
- O muro de runas ficava 0,7 stud acima do degrau de baixo; foi rebaixado e assentado.

**Custo:** o santuário tem cerca de 5,4 mil triângulos. Na vista Vila ficou em 820 chamadas e 1.648.902 triângulos (antes deste passo, 814 e 1.640.031).

**Imagem:** `../../referencias/mapa-santuario-antes-depois.jpg`

**Pendência no Roblox Studio:** conferir a passagem entre o pilar da entrada e os braseiros com um personagem de verdade.

## 6ª estrutura: Mirante do Penhasco das Nuvens (feito, com mudança de posição justificada)

Arquivo alterado: `Props/props.js`, só o bloco `STORM.ARCH.CLIFF.LOOKOUT`.

**Defeito de posicionamento encontrado.** O mirante foi pensado como "deck em balanço sobre o penhasco, escorado na rocha" (é assim nas notas e na exceção de flutuação do diagnóstico). Na prática:
- estava todo sobre terreno **plano**, 36 studs para dentro da borda;
- a ponta apontava para o interior da ilha;
- as escoras ficavam enterradas;
- eram 5 caixas de metal com paredes cheias e sem colisão nos lados.

**Correção:**
- **Posição.** Ele foi levado até a borda leste, na mesma região do penhasco, a ~40 studs da posição antiga (pivô em 260, 49,6). A borda é encontrada no código: a busca anda do penhasco para leste até o terreno cair ou a ilha acabar. Assim são 12 studs de balanço de verdade sobre as nuvens.
- **Acesso.** Uma trilha de lajes liga o fim da estrada P3 (214, 46) ao mirante. A rota de teste "mirante: P3 → deck" continua a mesma e passa.

**A nova construção:**
- encontro de cantaria em terra até o chão real;
- 2 vigas de ferro (alma e mesas), transversinas e tabuado;
- escoras de ferro até a encosta, com chapas de ancoragem rebitadas, e tirantes;
- guarda-corpo de montantes de ferro com pomos e corrimão de cobre, mais 3 cabos, com colisão nos três lados;
- luneta de latão em tripé, no mesmo ponto de antes;
- para-raios com bobinas nas duas pontas;
- 2 lanternas na entrada.

**Grama.** A grama instanciada da superfície que atravessava o tabuado foi zerada só dentro da planta do mirante (3 instâncias). O resto da vegetação não mudou.

**Caminhável.** O deck agora é uma superfície do tipo "ponte" com 4,6 studs de meia largura. Antes era um quadrado de 13 × 13 que não seguia o deck girado.

**Validação no visualizador (não no Studio):**
- Diagnóstico: 88 verdes, os mesmos 5 amarelos, 0 vermelhos e 0 interseções.
- 24 de 24 rotas.
- O mirante continua na lista de balanços intencionais.

**Custo:** o mirante tem cerca de 5,3 mil triângulos, contra 200 antes. Na vista Vila ficou em 822 chamadas e 1.654.403 triângulos.

**Imagem:** `../../referencias/mapa-mirante-antes-depois.jpg`. Em cima a posição antiga; embaixo a nova, com as câmeras na mesma posição relativa ao mirante.

**Pendências no Roblox Studio:**
- conferir se as escoras encostam na rocha do Terrain do Roblox (a encosta lá vem do heightmap e pode ter outra forma);
- testar o guarda-corpo com um personagem de verdade.

## 7ª estrutura: Observatório Abandonado (feito)

Arquivo alterado: `Architecture/observatorio.js`, só a função `I.buildObservatory`. O santuário, que fica no mesmo arquivo, não foi mexido.

**O que não mudou:**
- posição e assentamento;
- raio do tambor;
- porta em +Z, com a rota "observatório: P4 → porta";
- os 4 colisores do tambor;
- o grupo `Telescopio`, no mesmo ponto (puzzle STORM.PUZZLE.OBS).

**Defeitos corrigidos:**
- a argola da luneta flutuava acima da cúpula, solta;
- as nervuras eram toros girados ao acaso que cruzavam a cúpula;
- a porta era uma placa da altura do tambor, sem moldura;
- o anexo eram 5 placas soltas no chão.

**O que mudou:**
- **Tambor:**
  - plinto de pedra lavrada;
  - tambor de cantaria com 2 cintas, 12 pilastras e cornija com trilho de ferro;
  - janelas em arco tapadas com tábuas e travessas de ferro (é um lugar abandonado).
- **Porta:** pórtico saliente com arco, fecho, soleira e folhas de tábua recuadas, com ferragens e argolas.
- **Cúpula:**
  - de chapa azul-escura (a mesma família de telhado da oficina e das casas);
  - 16 nervuras meridianas de cobre de verdade e aro na base;
  - fenda de observação ao norte, com trilhos de ferro e veneziana recolhida até a metade;
  - um painel desabado a oés-sudoeste, com as placas caídas no chão.
- **Interior visível pela fenda:**
  - chão de tábuas;
  - pilar de pedra e montagem em garfo;
  - luneta de latão de 15 studs apontando pela fenda, com o aro da objetiva solto, pendurado (o "telescópio quebrado" do puzzle).
- **Anexo em ruínas:**
  - piso de lajes;
  - paredes de cantaria com topo quebrado e aberturas em arco;
  - pilares de canto;
  - um arco partido que ligava o anexo ao tambor;
  - entulho;
  - colisores nas paredes.

**Validação no visualizador (não no Studio):**
- Diagnóstico: 88 verdes, os mesmos 5 amarelos, 0 vermelhos e 0 interseções.
- 24 de 24 rotas.

**Custo:**
- o observatório tem cerca de 13,8 mil triângulos (antes, 2,5 mil);
- na vista Vila ficou em 820 chamadas e 1.666.348 triângulos;
- na vista Torre, onde ele aparece, ficou em 713 chamadas.

**Imagem:** `../../referencias/mapa-observatorio-antes-depois.jpg`

**Pendências no Roblox Studio:**
- a cúpula é uma casca vista dos dois lados: conferir `DoubleSided` na MeshPart;
- o puzzle de apontar a luneta deve girar o grupo `Telescopio` (garfo + tubo).
