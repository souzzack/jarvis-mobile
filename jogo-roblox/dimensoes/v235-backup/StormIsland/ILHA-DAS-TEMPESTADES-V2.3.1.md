# Ilha das Tempestades V2.3.1: posicionamento, apoio e colisões

Correção localizada sobre a versão publicada (a "V2.3"). O backup completo dela está em `../v23-backup/` e abre sozinho.

Evidências (render do visualizador three.js, não do Roblox):

- `../../referencias/ilha-tempestades-v231-antes-depois.jpg`: 10 enquadramentos com a mesma câmera, V2.3 ao lado de V2.3.1.
- `../../referencias/ilha-tempestades-v231-depuracao.jpg`: o modo de depuração de apoio, antes e depois.

> A imagem citada no pedido não chegou junto da mensagem, então não sei qual construção ela mostra. Por isso a correção cobriu a ilha inteira. Os casos com escadaria e base suspensas que encontrei foram a escadaria da torre e as escadas das plataformas da floresta.

## 1. Causas encontradas (não eram uma só)

| # | Causa | Onde | Correção |
|---|---|---|---|
| 1 | Posição pela altura do **centro** ou por uma **altura fixa** | Casas (altura fixa 16), oficina, barracas, plataformas, torres de transmissão, árvores, troncos, ruínas, minas, rochas, depósitos | `MM.seat` amostra a área inteira e põe alicerce, rodapé e degraus. Peças naturais vão pelo ponto mais baixo do chão em volta. Peças deitadas usam uma reta ajustada ao chão. |
| 2 | Degraus "empilhados no ar" | 8 degraus da torre, com até 6 studs de vão por baixo; escadas das plataformas eram tábuas soltas | Todo degrau é maciço até o terreno real sob ele. |
| 3 | **Escadaria da torre que não encontrava a trilha** | Piso de 2 studs passando por cima do terraço da trilha P1, mais um lance de 27 degraus morro abaixo terminando >2,6 acima do chão | Escadaria refeita (detalhe no item 2). |
| 4 | Peça com **centro fixo e altura variável** | Paredes do anexo do observatório (as baixas flutuavam) | Cada parede apoiada no próprio chão. |
| 5 | **Estratos aplicados por cima dos platôs** | Platôs da torre, do observatório e do santuário deixavam de ser planos | Máscara de áreas planas no terreno. |
| 6 | Altura consultada ≠ altura desenhada | `heightAt` era bilinear; a malha usa triângulos. Diferença de décimos de stud nas encostas | `heightAt` usa o mesmo triângulo da malha. |
| 7 | **Colisores girados espelhados** | A física girava os colisores para o lado errado (−θ). Afetava casas, oficina, barracas e degraus girados. O desenho dos colisores estava certo, por isso não aparecia. | Inversa correta da rotação. |
| 8 | Topo de colisor não era chão | Degraus com colisor não podiam ser subidos no modo caminhar | Topo de colisor até 2,6 studs acima conta como degrau; só bloqueia o que for mais alto. |
| 9 | Conflitos de traçado (já existiam desde a V1) | Ver lista abaixo | Posição corrigida. |

### Conflitos de traçado corrigidos (item 9)

- **Trilhas P1 e P4:** a P1 terminava **dentro** da base da torre, e a P4 começava dentro dela. As duas agora ligam no pé da escadaria.
- **Oficina:** estava interpenetrando a casa 1 e em cima do início da P2. Foi movida para o lugar livre mais próximo, com a frente aberta virada para um espaço livre.
- **Barraca 2 e torre de transmissão 3:** ficavam coladas nas portas de casas. Foram afastadas.
- **Escada da plataforma 2:** entrava numa rocha da passagem secreta. Foi virada para o sul.
- **Passagem secreta P5:** as rochas ficavam em cima da trilha (vão real de ≈1,4 stud). Agora flanqueiam a trilha com ≈9 studs livres.
- **Mina STORM.MINE.01:** estava dentro da faixa da P2. Foi movida 8 studs, e o marcador foi junto.
- **Árvore Ancestral:** estava a 1,4 stud do eixo da P2. Foi movida 10 studs, dentro da clareira.
- **Santuário:** estava fixo em 10, mas o chão está em ≈5. Agora assenta no chão real.

## 2. Fundações e degraus (`MM.seat`, em `nucleo/base.js`)

**Como funciona:**

- Amostra o retângulo girado (ou o disco) a cada 1,5 stud.
- O piso fica 0,4 stud abaixo do ponto **mais alto** (nada enterrado além disso).
- Se o chão desce, cria um alicerce até 1 stud abaixo do ponto **mais baixo**, um rodapé mais largo e o colisor.
- Na porta, cria um patamar de 2,4 studs e degraus de transição de 0,75 × 1,3 até o chão real em frente.
- Cada construção recebe o próprio deslocamento. O relatório fica em `userData.assento`.

**Alicerces resultantes:**

| Construção | Alicerce (studs) |
|---|---|
| Torre | 6 (anel de contenção na borda do platô) |
| Observatório | até 20 (no lado onde a trilha P4 corta o platô) |
| Santuário | 5,8 |
| Oficina | 2,4 |
| Praça | 0,9 |
| Casas | 0 a 0,2 |

**Escadaria da torre:**

- Degraus de 0,9 × 1,3, do patamar da porta (y 43,2) até o terraço da trilha: 19 degraus.
- Muretes laterais maciços, pilaretes e corrimão.

**Ponte:**

- Pilares descem até o chão com sapata.
- Encontros de pedra sob as tábuas que ficam sobre terra firme.

**Plataformas da floresta:**

- Cada pilar tem o próprio comprimento e sapata.
- Escada de pedra maciça encostada no piso.

## 3. Auditoria e modo de depuração (`nucleo/apoio.js`)

**Botão "Apoio (depuração)" no visualizador.** Para cada modelo:

- Varre a projeção no chão (até cerca de 420 colunas) e lança um **raio vertical de baixo para cima** contra as peças de base.
- Compara o ponto atingido com a superfície de apoio real naquela coluna: terreno exato, piso de túnel ou ponte.
- Só conta superfície virada para baixo, para que o flanco arredondado de uma rocha não conte como base.
- Desenha cada ponto de contato em cor e a linha da folga até o chão. O resumo aparece no rodapé.

**Classificação:**

| Classe | Folga |
|---|---|
| contato | ≤ 0,35 |
| folga | ≤ 1,5 |
| suspenso | > 1,5 |
| enterrado | alicerce, é o esperado |

**Flutuação intencional (fica fora da auditoria):**

- cristal do captador e anéis;
- estilhaços de energia;
- fragmentos de rocha da borda;
- nuvens;
- mirante em balanço sobre o penhasco;
- cabos;
- aduelas do arco da caverna (apoiadas nas ombreiras).

**Resultado, com o mesmo critério nas duas versões:**

| | V2.3 | V2.3.1 |
|---|---|---|
| Modelos com trecho suspenso | 9 | 2 |
| Colunas suspensas | 187 | 2 |
| Modelos só com folga (0,35–1,5) | 53 (434 colunas) | 16 (22 colunas, quase todas raízes de árvore < 0,8) |

**Os 2 pontos restantes foram conferidos na imagem:**

1. **STORM.BRIDGE.01, 1 coluna, 2,7 studs:** a borda da primeira tábua sobre o lábio da fenda, onde o vão da ponte começa. É intencional.
2. **STORM.VEG.TREE.48, 1 coluna, 1,7 stud:** uma raiz de escora que sai do tronco em arco. É normal numa árvore.

A boca da caverna saiu da lista porque as aduelas foram marcadas como "apoiadas pelo arco", e não por mudança de geometria.

## 4. Rotas (mesmas regras do boneco: degrau ≤ 2,6, raio 1,1, altura 5,2)

`window.__walkTest` percorre cada rota a passos de 0,25 stud. A V2.3 também foi testada, já com a função copiada para ela.

| | V2.3 | V2.3.1 |
|---|---|---|
| Rotas aprovadas | 6 de 18 | **18 de 18** |

**Rotas testadas:** trilhas P1 a P6, escadaria da torre, ligação P1→P4, as 2 plataformas, as 5 portas de casa, a oficina e a ponte.

Maior degrau encontrado: 1,8 stud (escadaria da torre).

## 5. Desempenho (navegador de teste sem GPU; não vale como medida do Roblox)

Mesmos enquadramentos, efeitos e chuva desligados:

| Vista | V2.3: chamadas / triângulos | V2.3.1: chamadas / triângulos |
|---|---|---|
| Três quartos | 884 / 1,536 mi | 896 / 1,541 mi |
| Vila | 704 / 1,720 mi | 716 / 1,724 mi |
| Torre | 645 / 1,692 mi | 652 / 1,695 mi |
| Aérea | 900 / 1,538 mi | 912 / 1,543 mi |
| Nível do jogador | 583 / 1,658 mi | 589 / 1,661 mi |

- **Chamadas:** +0,8% a +1,7%. A primeira versão da correção chegava a +8% porque separava a fusão por material; isso foi desfeito. As fundações usam o material que cada modelo já tinha.
- **Triângulos:** +0,3%.
- **Colisores:** 124 → 168.
- **FPS:** fica em cerca de 20 nas duas versões, que é o limite do ambiente de teste.
- **Auditoria:** cerca de 2,6 s. Só roda quando o botão de depuração é ligado, então não pesa no carregamento.

## 6. Roblox

- **Fundações, degraus, muretes e sapatas:** são malhas comuns. Saem no GLB dentro do modelo de cada construção, com o mesmo pivô e na mesma escala.
- **Colisores:** novos e corrigidos estão no `manifest.json`.
- **Física:** a correção da rotação dos colisores é do visualizador. No Roblox, a colisão vem das próprias Parts e MeshParts.
- **Testes:** nada disto foi testado no Roblox Studio.
