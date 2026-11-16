# Guia de estilo — Magnata do Multiverso

Este é o padrão visual do jogo. Todo modelo, efeito ou tela nova segue este guia.
A referência visual aprovada é a prévia `jogo-roblox/previa-magnata.html`.

O estilo foi inspirado nos vídeos de voxel neon que o dono do jogo mandou: são **referência de estilo, não de conteúdo**.
Todo modelo do jogo é desenhado do zero, com formas e temas nossos.

---

## 1. A regra de ouro

> **O corpo é escuro e sólido. Só os detalhes brilham.**

- No máximo **25% dos cubos de um modelo são Neon**. Se tudo brilhar, nada se destaca.
- O neon marca o que importa: rachaduras, veios, runas, bordas, olhos, pontas.
- Cada modelo usa **um par de cores**: uma cor de brilho principal e uma de destaque. Não passe de três cores de neon por peça.

## 2. Voxel: tamanho dos cubos

O personagem padrão do Roblox tem cerca de 5 studs de altura. Os cubos seguem esta tabela:

| Tipo de peça | Cubo | Tamanho total aproximado |
|---|---|---|
| Rochas de minério, máquinas, portais | 0,5 stud | 6 a 9 studs |
| Ovos, ajudantes, minérios na mão | 0,25 stud | 2 a 4 studs |
| Detalhes finos (olhos, runas, pontas) | 0,125 stud | só em pontos pequenos |

- Deixe as silhuetas **arredondadas**, montadas bloco a bloco, sem degraus enormes.
- Varie levemente o brilho dos cubos sólidos (±10%) para a textura parecer feita à mão.
- Construa só a **casca**. Cubos internos que ninguém vê são cortados.

### Limite de peças por modelo

| Modelo | Máximo de Parts |
|---|---|
| Minério (drop) | 150 |
| Ovo | 600 |
| Rocha de minério | 600 |
| Portal ou máquina | 900 |

Para ficar dentro do limite, **junte cubos vizinhos da mesma cor numa peça só**: uma faixa de 6 cubos iguais vira uma Part de 3×0,5×0,5.
Peças decorativas ficam `Anchored = true`, `CanCollide = false`, `CanQuery = false` e `CanTouch = false`. Peças Neon ficam com `CastShadow = false`.

> Não use **Union** em modelos que tenham partículas: o ParticleEmitter não aparece dentro de Unions.
> Coloque o emissor numa Part invisível separada.

## 3. Materiais

| Uso | Material | Observação |
|---|---|---|
| Corpo das peças | `SmoothPlastic` | Nunca `Plastic`, que tem textura de ruído |
| Brilho | `Neon` | Só nos detalhes (veja a regra de ouro) |
| Vidro, campos de contenção | `Glass` / `ForceField` | `Transparency` de 0,4 a 0,7 |
| Metal das ferramentas | `Metal` | Cinza azulado, nunca cromado |

## 4. Iluminação (Lighting)

Configurado uma vez, vale para o jogo todo:

- `Lighting.Technology = Future`
- **BloomEffect**: `Intensity 0.8`, `Size 24`, `Threshold 0.95`. É ele que faz o Neon "acender".
- **ColorCorrectionEffect** por mundo (tabela abaixo): `Saturation 0.15`, `Contrast 0.1`, `TintColor` do mundo.
- **Atmosphere**: `Density 0.35`, `Color` e `Decay` do mundo, `Glare 0`, `Haze 1`.
- Rochas e máquinas têm uma `PointLight` da cor do veio: `Brightness 1.5`, `Range 12`, `Shadows = false`.

## 5. Os mundos

Cada mundo tem uma paleta fixa: céu (topo e horizonte), chão, rocha e veio neon.

| Mundo | Céu topo | Horizonte | Chão | Rocha | Rocha clara | Veio neon |
|---|---|---|---|---|---|---|
| Ilha das Tempestades | `#070D2C` | `#26367E` | `#3D4466` | `#262C4A` | `#3A4470` | `#43D9FF` |
| Ilha dos Vulcões | `#160403` | `#5E1A0B` | `#4A3434` | `#2B1D1C` | `#45292A` | `#FF7A1A` |
| Cidade Congelada | `#031317` | `#0E4C56` | `#3A5458` | `#203A40` | `#2F5560` | `#6FF2E0` |

- O chão é cinza tingido com a cor do mundo e tem **pontinhos quadrados** (textura de grade), como na prévia.
- Toda peça de destaque tem um **anel tracejado neon** no chão, na cor do veio, girando devagar (1 volta a cada 25 s).

### Minérios de cada mundo

| Raridade | Tempestades | Vulcões | Cidade Congelada |
|---|---|---|---|
| Comum | Faísca Azul `#56D6FF` | Brasa Bruta `#FF8A3D` | Areia de Ampulheta `#F2D49B` |
| Raro | Cristal de Trovão `#2F6BFF` | Rubi de Magma `#FF2D55` | Cristal de Minuto `#3FF2D8` |
| Épico | Núcleo de Plasma `#B45CFF` | Obsidiana Viva `#8A3DFF` | Engrenagem Eterna `#C18BFF` |
| Lendário | Relâmpago Dourado `#FFC21A` | Gema Solar `#FFCC1A` | Hora Dourada `#FFCC33` |
| Secreto | Raio Negro (`#120E26` + listras `#C79BFF`) | Coração do Vulcão (`#2A0606` + `#FF5A3D`) | Segundo Zero (`#0B1C1F` + `#F4FFFD`) |

Minérios comuns até lendários são cristais **inteiros de neon**, com a ponta mais clara.
O **secreto é o contrário**: cristal escuro com listras de neon e brilho que muda de cor. Ele precisa parecer "errado", impossível.

## 6. Raridades

As cores de raridade valem para tudo: minérios, ajudantes, ovos, textos e bordas da interface.

| Raridade | Cor | Chance | Valor | Duração da cena |
|---|---|---|---|---|
| Comum | `#B9C6D8` | 60% | 5 | 1,5 s |
| Raro | `#4EA8FF` | 25% | 25 | 2 s |
| Épico | `#B86BFF` | 10% | 120 | 3 s |
| Lendário | `#FFCC33` | 4,5% | 900 | 4 s |
| Secreto | `#FF4FD8` | 0,5% (1 em 200) | 15.000 | 12 a 14 s |

### O que cada cena faz

Toda extração começa igual: **três golpes de picareta**, com pedaços da rocha voando e faíscas na cor do veio.
Esses golpes são a antecipação, e a espera faz parte da recompensa.

- **Comum**: o minério salta da rocha com algumas faíscas.
- **Raro**: igual ao comum, mais um anel tracejado que se expande e some.
- **Épico**: a câmera se aproxima, faíscas giram e se juntam no minério, ele gira rápido e a tela pisca na cor roxa.
- **Lendário**: a ilha escurece, um pilar de luz dourada sobe até o céu, uma onda de choque passa pelo chão e o servidor inteiro recebe o aviso.
- **Secreto**: alarme vermelho, o minério flutua num campo de contenção e os **cientistas malucos** entram correndo. A parte do meio muda em cada mundo:
  - **Tempestades**: cinco raios caem em volta, os cientistas levam choque e o cabelo fica em pé. O sexto raio acerta o minério.
  - **Vulcões**: o chão racha em lava, com brasas subindo, e os cientistas pulam sem parar para não queimar o pé.
  - **Cidade Congelada**: no meio do pulo dos cientistas o tempo **para** (tela dessaturada, relógio no centro, três tique-taques) e depois volta a correr.

  No fim, o nome aparece com efeito de falha na tela e os cientistas comemoram e saem correndo.
  Todo mundo novo ganha **a sua própria reviravolta** na cena do secreto.

### Lendário e secreto são eventos do servidor
Quando alguém tira um lendário ou um secreto, todos os jogadores do servidor veem um aviso no topo da tela com o nome de quem achou e o minério.

## 7. Os cientistas malucos

Personagens de cena, não jogáveis. São dois e são sempre os mesmos, para o público se apegar a eles.

| | Cientista 1 | Cientista 2 |
|---|---|---|
| Pele | `#F1C27D` | `#B9774A` |
| Cabelo espetado | branco `#F4F4F4` | laranja `#FF6B35` |
| Lentes do óculos (Neon) | verde `#7CFF6B` | rosa `#FF4FD8` |
| Gravata | rosa `#FF4FD8` | ciano `#43D9FF` |
| Objeto na mão | frasco com líquido neon | prancheta |

- Corpo em blocos: jaleco branco `#EEF2F6`, calça `#2B2D42`, sapato `#15151F`.
- Altura de cerca de 5 studs, para ficarem na escala do jogador.
- Na surpresa, aparece um **"!" amarelo neon** sobre a cabeça e a boca abre.
- Os nomes ainda estão **a definir** com o dono do jogo.

## 8. Efeitos (VFX)

### Partículas
- Textura: **quadrado** (cubinho), nunca círculo nem estrela, para combinar com o voxel.
- `LightEmission = 1`, `LightInfluence = 0`.
- `Size` de 0,15 a 0,4, diminuindo até 0 no fim da vida.
- Explosões curtas usam `emitter:Emit(n)` com o emissor desligado (`Enabled = false`).
- Faíscas ambiente: no máximo 15 por segundo por peça.

### Anéis tracejados
- Feitos de Parts Neon pequenas dispostas em círculo, com 55% de traço e 45% de espaço.
- A rotação acontece **só no cliente** (LocalScript), nunca no servidor.
- Anéis em volta de peças ficam levemente inclinados (cerca de 20°), como uma órbita.

### Halo
- Cada peça Neon importante tem um brilho suave atrás, feito com um `BillboardGui` com imagem de degradê radial ou com uma `PointLight`.

### Câmera
- Tremida só em momentos grandes (golpe de picareta, raio, lendário, secreto), curta e pequena.
- Nas cenas de lendário e secreto, a câmera vai para a frente da rocha e volta ao normal no fim.

## 9. Animação: vocabulário fixo

Use sempre estes `TweenInfo`, para o jogo inteiro ter o mesmo ritmo:

| Nome | Duração | Estilo | Uso |
|---|---|---|---|
| `RAPIDO` | 0,15 s | Quad Out | Hover, cliques, piscadas |
| `SALTO` | 0,3 s | Back Out | Minério saindo, painéis abrindo, "!" aparecendo |
| `SUAVE` | 0,6 s | Cubic InOut | Câmera, luz escurecendo e voltando |
| `LENTO` | 1,2 s | Sine InOut | Flutuação, entrada dos cientistas |

- Itens flutuantes sobem e descem 0,3 stud a cada 3 s e giram devagar.
- Toda moeda ganha **conta subindo** (nunca pular direto de 1.240 para 2.380) e um pulo de escala de 1,1× no contador.

## 10. Interface (HUD e lojas)

### Cores
| Função | Cor |
|---|---|
| Fundo dos painéis | `#151227` com 10% de transparência |
| Fundo de itens | `#1C1834` |
| Bordas | `#2C2650` |
| Texto | `#EEEAFF` |
| Texto secundário | `#A39DCC` |
| Ação principal | ciano `#43D9FF` |
| Moedas | dourado `#FFCC33` |

### Fontes
- Títulos, números grandes e botões: **Luckiest Guy**.
- Textos: **Builder Sans**.
- Números em tabelas e preços: **Roboto Mono**.

### Regras
- Pensada **primeiro para o celular**, que é a maioria dos jogadores. Teste sempre no emulador do Studio em celular pequeno, tablet e computador.
- Tamanhos em **Scale**, com `UIAspectRatioConstraint` em ícones e `UITextSizeConstraint` em textos.
- Cantos arredondados com `UICorner` de 12 px nos painéis e 999 nos botões em pílula.
- Botões têm hover, pressionado (pulo de escala) e desativado (dessaturado).
- O botão principal tem borda ciano e brilho.
- Itens de inventário mostram a raridade na **borda** com a cor da tabela.
- Painéis abrem com animação `SALTO`. Nada aparece "do nada".
- Nada importante perto dos cantos onde ficam o notch e a barra do celular.

### Aviso de descoberta (banner)
- Fica no topo central da tela.
- Tem três linhas: raridade (pequena, na cor da raridade, com espaçamento entre letras), nome do minério (grande, branco, com brilho na cor da raridade) e uma pílula com a chance e o valor.
- No secreto, o nome tem efeito de falha (rosa e ciano tremendo).

## 11. Som

- Toda ação tem som: golpe, salto do minério, moeda, abrir painel.
- Variar levemente o `PlaybackSpeed` (0,95 a 1,05) a cada toque, para não cansar.
- Cada raridade tem um som crescente: comum é um "pop" simples, lendário é um acorde e secreto tem sirene.
- Só sons criados para o jogo ou da biblioteca do Roblox com licença de uso. Nada de música de terceiros.

## 12. Checklist antes de aprovar um modelo

- [ ] O corpo é escuro e no máximo 25% é neon?
- [ ] Usa a paleta do mundo dele?
- [ ] O tamanho do cubo segue a tabela?
- [ ] Está dentro do limite de peças?
- [ ] Cubos vizinhos iguais foram juntados?
- [ ] Peças decorativas estão sem colisão e sem consulta, e o Neon está sem sombra?
- [ ] As partículas estão fora de Unions?
- [ ] Foi testado em Play (não só no editor), no celular e no computador?
- [ ] É um desenho nosso, e não cópia de outro jogo?
