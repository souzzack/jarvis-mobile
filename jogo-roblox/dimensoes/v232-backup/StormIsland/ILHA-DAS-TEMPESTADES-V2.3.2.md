# Ilha das Tempestades V2.3.2: recuperação estrutural

Recuperação estrutural, sem expansão: nenhuma construção, vegetação, efeito ou mecânica nova.

- **Diagnóstico da fase 1:** `diagnostico/DIAGNOSTICO-V2.3.2.md`.
- **Backups:** `../v23-backup/` (V2.2, referência visual aprovada) e `../v231-backup/` (V2.3.1, ponto de partida).
- **Axolote Nebular:** não foi tocado.

## Evidências (render do visualizador three.js, não do Roblox)

- `../../referencias/v232-antes-depois-1.jpg` a `-3.jpg`: 27 estruturas, V2.3.1 × V2.3.2, mesma câmera, sem chuva, neblina ou névoa. Inclui:
  - vista aérea e vila ao nível do jogador;
  - escadarias e pontes;
  - oficina, Praça do Coletor e mercado;
  - observatório, caverna e minas;
  - santuário, ruínas e passagem secreta.
- `../../referencias/v232-modo-diagnostico.jpg`: o modo **Diagnóstico Estrutural** na vila, na torre, no observatório, no santuário e na vista aérea.
- `../../referencias/v232-diagnostico-1.jpg` a `-3.jpg`: a inspeção da fase 1.

## Causas encontradas e corrigidas

| # | Causa | Correção na geração |
|---|---|---|
| 1 | Superfície (grama, seixos, plantas, cogumelos, raízes, afloramentos, poças) gerada antes das construções, evitando só um raio fixo por área | Depois de tudo montado, as instâncias que cruzam o colisor de uma construção são removidas (196 removidas). Nada foi escondido. |
| 2 | Mudanças da V2.3.1 sem recalcular o que dependia delas | Torre de transmissão escolhida testando também o vão do cabo; barraca fora da praça; árvores fora das rochas da passagem; rocha 4 afastada da plataforma 2 |
| 3 | Sapatas das torres de transmissão em ±1,75, mas as pernas inclinadas tocam o chão em ±2,6 | Sapata na base real de cada perna |
| 4 | Porta plana encostada em parede cilíndrica (desde a V1) | `MM.arcSlab`: porta e verga em arco, cravadas no cilindro (casa redonda e observatório) |
| 5 | Boca da caverna: arco solto diante de um corte retangular, com o túnel exposto | Pórtico com muros de arrimo laterais e verga de pedra encaixados no corte do paredão |
| 6 | **Fora do contorno da ilha a função de altura devolvia um chão 5 studs abaixo** (as células nem são desenhadas) | Fora do contorno passa a ser vazio, no assentamento e na auditoria. Assim apareceu o caso seguinte. |
| 7 | **Santuário planejado além do contorno** (desde a V1): 0 de 72 amostras da base estavam sobre a ilha | Ponto de interesse movido 48 studs para dentro, com platô, fim da trilha P5 e marcador |
| 8 | Trilha escavando platô construído: o fim da P4 abria um corte de 20 studs no observatório e a P5 rebaixava o santuário | A trilha não escava dentro da área do **edifício** (pode rampar no resto do platô); o fim da P4 vai para diante da porta |
| 9 | Colisor do observatório era um quadrado de 28 (os cantos fechavam a frente da porta) | Quatro faixas que seguem o cilindro |
| 10 | Escadaria da torre entrava 0,5 stud no vão da porta | Primeiro degrau começa depois da soleira |

**Sem defeito, conferido nos 100 modelos:**

- matrizes não finitas;
- escala nula, negativa ou não uniforme em grupo;
- rotação X/Z indevida;
- pivô fora da geometria (deslocamento aplicado duas vezes);
- geometria com NaN;
- material ausente;
- colisor fora do modelo.

## Tabela de estruturas

| Estrutura | Problema encontrado | Causa | Correção aplicada | Validação |
|---|---|---|---|---|
| Torre Meteorológica | 59 seixos e grama dentro da base e da escadaria; 1º degrau no vão da porta | 1, 10 | Recorte da superfície; degrau recuado 0,6 | Verde; rota pé da escada → porta ok |
| Montanhas e terreno | nenhum | — | preservados (só as regras de trilha nos platôs) | — |
| Casas 1, 3, 4, 5 | seixos no alicerce; cabo atravessando a casa 3 | 1, 2 | Recorte; nova rota da linha | Verde; portas ok |
| Casa 2 (redonda) | porta plana em parede curva | 4 | Porta e verga em arco | Verde; porta ok |
| Oficina dos Para-raios | grama e arbustos dentro | 1 | Recorte | Verde; frente → interior ok |
| Mercado (barracas 1 e 2) | barraca 2 sobre o anel da praça | 2 | Reposicionada fora da praça e das portas | Verde |
| Praça do Coletor ("Estação de Energia") | nenhum | — | preservada | Verde |
| Linha de transmissão | sapatas soltas; cabo na casa 3 | 3, 2 | Sapatas nas pernas; vão do cabo livre de casas | Verde (cabo = exceção, preso às torres) |
| Observatório | porta plana; muro de 20 studs; colisor quadrado; trilha terminando dentro | 4, 8, 9 | Porta em arco; trilha não escava; colisor por faixas; fim da P4 diante da porta | Verde; P4 → porta ok |
| Ponte da Fenda | nenhum estrutural | — | preservada | Amarelo: 2 bordas de tábua sobre o lábio da fenda (início do vão), exceção documentada |
| Plataformas 1 e 2 | plantas dentro; plataforma 2 encostada na rocha | 1, 2 | Recorte; rocha afastada 2,5 | Verde; escada → piso ok |
| Caverna (boca) | arco sem encaixe no paredão, túnel exposto | 5 | Pórtico com muros de arrimo e verga | Verde; P2 → câmara ok |
| Minas 01, 03, 04 | plantas e grama dentro | 1 | Recorte | Verde; trilha → frente ok |
| Ruínas | aro e barras apoiados só pelo centro | — | Barras deitadas pelos extremos; aro pelo ponto mais baixo | Amarelo: 3 pontos com folga ≤ 1,5 |
| Santuário (secreto) | 100% sobre a franja sem chão, além da borda | 6, 7 | Movido para dentro da ilha com platô, P5 e marcador | Verde; P5 → altar ok |
| Árvores 25, 46, 49 | dentro das rochas da passagem | 2 | Afastadas das rochas (só elas) | 25 e 27 amarelas (3 pontos com folga ≤ 1,5), 46 e 49 verdes |
| Árvore 48 | raiz em arco a 1,7 do chão | — | nenhuma (raiz orgânica) | Amarelo: inspecionar |
| Depósitos (4 tipos) | geodos com a casca no ar numa encosta | — | Geodo inclinado com a encosta e 85% da base enterrada | Verde |

## Testes automáticos (`nucleo/diagnostico.js`, botão "Diagnóstico Estrutural")

Rodam na cena montada:

1. **Transformações:** NaN/Inf, escala ≈ 0, escala negativa, inclinação indevida.
2. **Pivô fora da geometria.**
3. **Geometria e material:** geometria com NaN, material ausente.
4. **Colisor fora do modelo.**
5. **Interseções:** entre volumes de colisão de modelos diferentes.
6. **Invasões:** vértices de outro modelo e instâncias de superfície dentro de uma construção.
7. **Apoio:** raio vertical de baixo para cima, por ponto de contato, peça a peça nos conjuntos. Fora do contorno conta como vazio.
8. **Rotas:** 24 rotas com as regras do boneco (degrau ≤ 2,6, raio 1,1, altura 5,2).

**Regra das cores:** um modelo só fica **verde** se tiver contato com o chão **medido**; pivô perto do terreno não conta.

### Exceções explícitas (`MM.excecoesFlutuacao`)

- **Modelos:**
  - mirante em balanço;
  - cabos da vila;
  - cabos da linha de transmissão;
  - nuvens.
- **Peças:**
  - captador de tempestades (anéis e cristal);
  - estilhaços de energia;
  - fragmentos flutuantes da borda e o musgo deles;
  - quedas d'água;
  - eixo de energia.
- **Peças apoiadas no próprio objeto:**
  - aduelas da caverna;
  - cavidade e cristais internos do geodo;
  - veios de cobre;
  - lado de dentro do aro das ruínas.

### Resultado

| | V2.3.1 (fase 1) | V2.3.2 |
|---|---|---|
| Interseções entre modelos | 4 | **0** |
| Instâncias dentro de construções | ≈ 170 | **0** |
| Modelos vermelhos | (não havia teste) | **0** |
| Modelos amarelos (inspecionar) | — | **5** (ponte, árvores 25, 27, 48, ruínas) |
| Modelos verdes | — | **88** |
| Rotas aprovadas | 24/24 | **24/24** |
| Santuário sobre a ilha | 0/72 amostras | 72/72 |

## Ao nível do jogador (5,2 studs)

O visualizador **tem** caminhada com colisão: o modo "Caminhar (boneco)", com degrau máximo de 2,6, salto e gravidade. As rotas automáticas usam exatamente essas regras.

A inspeção visual das 27 estruturas está nas folhas de antes e depois. Nesta rodada não foi feita caminhada manual com teclado.

## Desempenho (navegador de teste sem GPU, mesmas vistas, efeitos e chuva desligados)

| Vista | V2.3.1: chamadas / triângulos | V2.3.2: chamadas / triângulos |
|---|---|---|
| Três quartos | 896 / 1,541 mi | 898 / 1,528 mi |
| Vila | 716 / 1,724 mi | 717 / 1,712 mi |
| Torre | 652 / 1,695 mi | 654 / 1,682 mi |
| Aérea | 912 / 1,543 mi | 914 / 1,530 mi |
| Nível do jogador | 589 / 1,661 mi | 590 / 1,648 mi |

- **Chamadas:** +1 a +2 (portas em arco e pórtico).
- **Triângulos:** −12 mil, pelas instâncias removidas.
- **FPS:** fica em cerca de 20 nas duas versões, que é o limite do ambiente de teste, então não serve para comparar.
- **Captura de referência:** os 1,66 mi / 602 chamadas que você citou são de outra máquina e outra vista, e não dá para comparar diretamente. A vista "Nível do jogador" daqui (590 chamadas / 1,65 mi) é a mais parecida.

## Arquivos modificados

`nucleo/base.js`, `nucleo/apoio.js`, `nucleo/visualizador.js`, `nucleo/diagnostico.js` (novo), `visualizador.html`, `StormIsland/ilha.js`, `StormIsland/plano.js`, `StormIsland/Terrain/terreno.js`, `StormIsland/Architecture/vila.js`, `StormIsland/Architecture/observatorio.js`, `StormIsland/Architecture/caverna.js`, `StormIsland/Architecture/torre.js` (só o recuo da escadaria), `StormIsland/Props/props.js`, `StormIsland/Vegetation/floresta.js`, `StormIsland/Resources/depositos.js`, `StormIsland/Resources/cristais.js` (sem mudança nesta etapa).

## O que ainda permanece

- **5 amarelos para inspeção:** 2 bordas de tábua da ponte no lábio da fenda, árvores 25, 27 e 48 (raízes em arco, folga ≤ 1,7) e 3 pontos de folga nas ruínas. Na imagem parecem naturais, mas ficam listados.
- **"Estação de Energia":** continua sem existir como construção. Usei a Praça do Coletor, porque o pedido proíbe construções novas nesta etapa.
- **Mais vegetação:** os testes de interseção cobrem só construções com colisor. Árvores e arbustos não foram testados entre si.
- **Rochas da passagem secreta:** a regra de pegada quadrada dos colisores delas é aproximada (não segue a forma).
- **Roblox:** nada foi testado no Roblox Studio. O pacote de exportação continua gerando os 10 arquivos (Terrain, Architecture e Vegetation em GLB, com colisores no manifesto).
