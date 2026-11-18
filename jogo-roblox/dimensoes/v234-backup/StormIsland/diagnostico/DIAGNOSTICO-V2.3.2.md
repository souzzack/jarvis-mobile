# Ilha das Tempestades V2.3.2: diagnóstico estrutural (fase 1)

Nesta fase **nenhum modelo foi alterado**. As correções (fases 2 a 8) esperam aprovação.

## Versões e backups

| Pasta | Conteúdo | Commit |
|---|---|---|
| `../../v2-backup/` | V2 (antes do polimento) | `7d4b4a5` |
| `../../v23-backup/` | **V2.2 publicada**: a versão que você chamou de "V2.3" e que está aprovada como referência visual (torre e montanhas) | `4bdfa42` |
| `../../v231-backup/` | V2.3.1: a atual, ponto de partida da recuperação | `2ff8dc1` |

- **Arquivos alterados na V2.3.1:** 17 (`git diff --stat 4bdfa42 2ff8dc1`).
- **Axolote Nebular:** não foi tocado em nenhum commit da ilha.

## O que foi verificado e como

### Checagens automáticas

Os scripts estão em `diag.js` e `diag2.js`, e os resultados brutos em `v232-checagens.json` e `v232-interpenetracao.json`. Eles rodam na cena real, depois da montagem e da fusão das malhas, sobre os **100 modelos** registrados.

| Checagem | Resultado |
|---|---|
| Matriz com valor não finito (NaN/Inf) | 0 |
| Escala ≈ 0, escala negativa (espelhada), escala não uniforme em grupo com filhos | 0 · 0 · 0 |
| Modelo inclinado (rotação X/Z) sem intenção | 0 |
| Pivô fora da geometria (sinal de deslocamento aplicado 2×) | 0 |
| Geometria com NaN ou de tamanho zero | 0 |
| Material ausente | 0 |
| Malha escondida sem motivo | 0 (só os 2 níveis de detalhe do terreno, que se alternam pela distância) |
| Colisor fora da geometria do próprio modelo | 0 |
| Altura consultada × malha desenhada do terreno (349 raios verticais) | diferença máxima 0,000 |
| Apoio no terreno (raio vertical de baixo para cima, 5 691 pontos) | 2 pontos suspensos, os dois intencionais (lábio da fenda na ponte e raiz em arco) |
| Rotas ao nível do jogador, com as regras do boneco (degrau ≤ 2,6, raio 1,1, altura 5,2) | **24 de 24** aprovadas: trilhas, portas, escadas, ponte, caverna até a câmara, observatório, santuário, mirante, minas e plataformas |
| **Volumes de colisão de modelos diferentes que se cruzam** | **4** |
| **Vértices de outro modelo dentro de uma construção** | **2 casos reais** |
| **Instâncias de superfície (seixos, grama, plantas) dentro de construções** | **≈ 170 instâncias**, em 14 estruturas |

### Inspeção visual

Foram 30 vistas sem chuva e sem neblina, a cerca de 5,2 studs: `../../../referencias/v232-diagnostico-1.jpg` a `-3.jpg`.

**Vistas inconclusivas** (a câmera ficou dentro da rocha ou olhando para o chão): ponte A e B, passagem secreta, depósito e ruína 2. Serão refeitas na fase 7.

## Origem dos problemas: são 5 causas diferentes

1. **Ordem de geração.** A superfície (seixos, grama, plantas, cogumelos) é gerada **antes** das construções. Ela só evita um raio fixo em volta de cada ponto de interesse. Por isso aparecem instâncias dentro da escadaria da torre (59 seixos), da oficina, das casas, das minas e das plataformas. Isso vem da V2.2 e aumentou na V2.3.1, quando oficina, mina e escadaria mudaram de lugar.
2. **Relocações da V2.3.1 sem recalcular o que depende delas.** Há três casos (regressões minhas):
   - **Linha de transmissão:** movi a torre de transmissão 3, mas não refiz a rota da linha. Agora o cabo atravessa a casa 3 (25 vértices dentro da casa).
   - **Barraca 2:** saiu da frente da casa 2, mas foi parar em cima do anel da praça.
   - **Rochas da passagem secreta:** ao afastá-las da trilha, ficaram em cima das árvores 25, 46 e 49 e encostando na plataforma 2.
3. **Erro geométrico meu na V2.3.1.** As sapatas das torres de transmissão foram postas em ±1,75, mas a base real das pernas inclinadas fica em ±2,6. As sapatas ficaram soltas ao lado das pernas.
4. **Fachada plana em parede curva (desde a V1).** A porta da casa redonda (casa 2) e a do observatório são placas retas encostadas num cilindro. As bordas ficam soltas no ar.
5. **Boca da caverna (desde a V1).** O tubo do túnel aparece por fora do arco, e o arco não se encaixa no paredão. A confirmar de perto na fase 5.

Não encontrei transformações duplicadas, pivôs errados, escalas inválidas nem matrizes corrompidas.

## Classificação proposta

| Estrutura | Problema | Causa | Cat. | Correção proposta |
|---|---|---|---|---|
| Torre Meteorológica | 59 seixos e 3 tufos dentro da escadaria/base | 1 | B | Remover instâncias dentro dos volumes (sem mexer na torre) |
| Montanhas e terreno | nenhum | | A | Preservar |
| Casa 1, 4, 5 | seixos no alicerce | 1 | B | Idem |
| Casa 2 (redonda) | porta plana em parede curva | 4 | B | Porta curva que segue o cilindro, com moldura |
| Casa 3 | cabo da linha atravessa a casa; seixos | 2, 1 | B | Recalcular a rota da linha evitando construções |
| Oficina dos Para-raios | grama e arbustos dentro | 1 | B | Remover instâncias |
| Mercado: barraca 1 | nenhum | | A | Preservar |
| Mercado: barraca 2 | em cima do anel da praça | 2 | B | Reposicionar fora da praça e das portas |
| Praça do Coletor | nenhum | | A | Preservar |
| Linha de transmissão (5 torres + cabos) | sapatas fora das pernas; cabo na casa 3 | 3, 2 | B | Sapata na base real de cada perna; rota sem cruzar casas |
| Observatório | porta plana no cilindro; seixos dentro; muro de 20 studs a revisar | 4, 1 | B | Porta curva; revisar o corte da trilha P4 |
| Ponte da Fenda | rotas ok, apoio ok; vistas inconclusivas | | A* | Confirmar visualmente na fase 7 |
| Plataforma 1 | 1 planta e 1 seixo dentro | 1 | B | Remover instâncias |
| Plataforma 2 | encosta na rocha da passagem (0,3 stud); plantas dentro | 2, 1 | B | Afastar a rocha ou a plataforma |
| Boca da caverna | tubo exposto e arco sem encaixe no paredão | 5 | C (a confirmar) | Reconstruir o encaixe arco–paredão–túnel |
| Túnel e câmara | nenhum | | A | Preservar |
| Minas 01, 03, 04 | cogumelos, plantas e grama dentro | 1 | B | Remover instâncias |
| Mina 02 (câmara) | nenhum | | A | Preservar |
| Ruínas | apoio ok; 1 vista inconclusiva | | A* | Confirmar na fase 7 |
| Árvores 25, 46, 49 | dentro das rochas da passagem | 2 | B | Afastar as árvores (só elas) |
| Demais 49 árvores e Árvore Ancestral | nenhum | | A | Preservar |
| Rochas da passagem secreta | sobre 3 árvores e na plataforma 2 | 2 | B | Ajustar sem fechar a passagem (rota P5 continua ok) |
| Santuário, chegada, mirante | nenhum | | A | Preservar |
| Depósitos (4 tipos) | apoio ok; vista inconclusiva | | A* | Confirmar na fase 7 |

Nenhum modelo foi classificado como D (irrecuperável).

## Nomes do pedido que não existem no projeto

- **"Oficina dos Inventores":** é a **Oficina dos Para-raios** (`STORM.ARCH.WORKSHOP`).
- **"Mercado da Tempestade":** são as **2 barracas do mercado** (`STORM.PROP.STALL.01/02`).
- **"Estação de Energia":** **não existe nenhum modelo com esse nome ou função**. O mais próximo é a Praça do Coletor, que recebe os cabos dos para-raios. Não criei nada, porque o pedido proíbe construções novas nesta etapa.

## Desempenho de referência (antes das correções)

Navegador de teste sem GPU, mesmas vistas da V2.3.1. Chamadas de desenho / triângulos:

| Vista | Chamadas | Triângulos |
|---|---|---|
| Três quartos | 896 | 1,541 mi |
| Vila | 716 | 1,724 mi |
| Nível do jogador | 589 | 1,661 mi |

O FPS fica preso em cerca de 20 pelo ambiente de teste e não serve para comparar.
