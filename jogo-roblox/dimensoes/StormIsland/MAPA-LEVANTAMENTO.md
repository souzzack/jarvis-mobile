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
2. Boca da Caverna, túnel e Bobina antiga, que têm o defeito visual mais evidente.
3. Doca de chegada e portal (primeira impressão).
4. Barracas e Praça do Coletor, para fechar a vila.
5. Santuário.
6. Mirante do Penhasco.
7. Observatório.
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

**Exportação:** `Architecture.glb` traz os materiais `Vila*`. As duas pedras (triplanares) saem como "Rocha", como na oficina.

**Imagens:**
- `../../referencias/mapa-levantamento-estruturas.jpg`
- `../../referencias/mapa-casas-antes-depois.jpg`
- `../../referencias/mapa-casas-vistas.jpg`

**Pendências no Roblox Studio:**
- importar e conferir os nomes;
- conferir os colisores (as casas não são exploráveis por dentro);
- conferir como a pedra fica depois de virar "Rocha";
- medir o FPS na vila num aparelho real.
