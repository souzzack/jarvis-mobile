# Ilha das Tempestades V2.2: polimento cinematográfico

Etapa de polimento sobre a V2. A composição, os pontos de interesse, os caminhos e os sistemas do visualizador foram mantidos. A V2 inteira foi copiada para `../v2-backup/`, que abre sozinho com `v2-backup/visualizador.html`.

Evidências visuais (todas renderizadas no visualizador three.js; **não** são o Roblox):

- `../../referencias/ilha-tempestades-v22-validacao.jpg`: 12 vistas da V2.2.
- `../../referencias/ilha-tempestades-v2-vs-v22.jpg`: V2 e V2.2 lado a lado, com a **mesma câmera** em 11 enquadramentos. A V2 foi renderizada a partir do backup.

## 1. Arquivos modificados

| Arquivo | O que mudou |
|---|---|
| `Terrain/terreno.js` | Montanhas reconstruídas, estratos irregulares, oclusão por vértice, trilhas com largura variável e drenagem, paredões da borda refeitos, contrafortes e mais 5 quedas d'água |
| `Terrain/superficie.js` | Vegetação variada (arbustos, samambaias, altitude, cogumelos, raízes), pedras de borda de trilha, afloramentos com lógica geológica, seixos mais leves |
| `Architecture/torre.js` | Captador em cardã real, balaustrada da escadaria, mãos-francesas, escoras, cabos, rebites, bronze oxidado e metal escovado |
| `Resources/depositos.js` (novo) | 4 tipos de depósito com modelagem própria (21 pontos) |
| `Vegetation/floresta.js` | Árvores desenhadas por instanciamento, mantendo cada árvore como modelo próprio |
| `Lighting/iluminacao.js`, `Effects/efeitos.js` | Iluminação quente e fria, névoa, chuva, contraluz, modo de iluminação neutra |
| `nucleo/triplanar.js`, `nucleo/texturas.js`, `nucleo/base.js`, `nucleo/visualizador.js`, `visualizador.html`, `ilha.js` | Oclusão (AO) no shader, estratos menos repetidos, rocha e alvenaria menos azuladas, bloom contido, novo botão de iluminação neutra, 4 vistas novas, exportação dos proxies das árvores, `MM.merge` com cores |

## 2. Geometria reconstruída

### Montanhas

Antes eram cristas de ruído com picos finos e parecidos. Agora o relevo é formado por:

- um maciço largo de base;
- cristas suavizadas;
- **12 formações com perfis diferentes**: domos, mesas de topo plano com bordas de paredão, chifres assimétricos de 3 lóbulos com arestas rochosas e cristas longas onduladas;
- platôs em duas cotas;
- um **desfiladeiro** entre os maciços oeste e central, afastado do túnel da caverna (a câmara continua coberta e foi verificada por dentro);
- ravinas de erosão.

### Estratos

- **Terreno:** espessura variável por região (6 a 11,5 studs), camadas inclinadas, degraus com bordas erodidas de nitidez variável e intensidade que muda de lugar para lugar.
- **Shader:** três frequências de faixa somadas e variação de tom em grande escala, para não repetir.

### Detalhes nas montanhas

Os afloramentos agora seguem uma regra geológica, em vez de serem espalhados ao acaso:

- **bordas de estrato:** degraus pouco inclinados no meio da encosta;
- **tálus:** no pé dos paredões, onde a oclusão marca uma cavidade;
- **meio enterrados.**

Completam o detalhe: vegetação de altitude só nas bordas de estrato, cristais nas encostas altas e os depósitos de cristal atmosférico.

### Borda suspensa

O paredão passou a ter 56 anéis. Tem:

- camadas mergulhando ao redor da ilha;
- só algumas camadas avançam (rocha dura); as moles ficam recuadas;
- fissuras verticais estreitas e nichos de erosão;
- 4 formas de contraforte embutidas, instanciadas;
- 7 quedas d'água no total.

### Torre

A silhueta, o núcleo e o captador foram preservados.

**Captador:** é um cardã de verdade. O anel externo gira no eixo vertical, apoiado em mancais de bronze no mastro e no topo. O anel médio gira sobre eixos presos ao externo, e o interno sobre eixos presos ao médio. Os anéis ficaram mais grossos e ganharam:
- frisos de bronze;
- nós;
- coroa de aletas no anel externo.

O cristal foi reduzido para nunca cruzar o anel interno e fica suspenso num eixo de energia. As 5 agulhas condutoras saem de um colar de bronze no topo.

**Corpo da torre:**
- mãos-francesas da passarela e braços de fixação das bobinas;
- 8 escoras da plataforma de antenas;
- 4 cabos em catenária entre a plataforma e a galeria;
- rebites nas chapas;
- reforços de cobre no mastro.

**Base:**
- balaustrada com pilaretes, corrimão e pilares de arranque com capitel de bronze;
- cada degrau inferior apoiado numa fundação até o terreno;
- pedra menos azulada.

## 3. Terreno e recursos

### Solo

- Oclusão por vértice: vales, fendas e pés de paredão escurecem.
- Trilhas com largura variável, bordas irregulares e valeta de drenagem úmida (mais escura e brilhante).
- 387 pedras de borda, colocadas fora da faixa de passagem.

### Vegetação

São 3 030 plantas instanciadas, sem colisão para não atrapalhar a caminhada:

- arbustos (3 formas e cores) nas bordas da floresta, pés de rocha e manchas;
- samambaias (2 formas) em lugares úmidos;
- almofadas de altitude;
- cogumelos em anéis, levemente bioluminescentes;
- raízes superficiais na floresta.

### Depósitos

Arquivo `Resources/depositos.js`. São só visuais, mas cada ponto já tem um id para a futura coleta.

| Tipo | Onde | Modelagem |
|---|---|---|
| `STORM.RES.ATMOS` (6) | Bordas de estrato das montanhas | Pedestal de rocha com 7 a 11 prismas de cristal |
| `STORM.RES.CONDUTORA` (5) | Zona de raios: torre e linha de transmissão | Rocha fraturada com veios de cobre nativo e nódulos |
| `STORM.RES.GEODO` (5) | Fenda e penhascos | Geodo rachado com cristais violeta e arco elétrico interno |
| `STORM.RES.FRAGMENTO` (5) | Observatório, ruínas e santuário | Estilhaço flutuante (animado) sobre um disco rúnico de pedra |

## 4. Atmosfera

- **Luz ambiente:** céu frio e rebote do chão quente.
- **Luz principal:** fria, mais forte.
- **Contraluz:** violeta, para ler os paredões do lado da sombra.
- **Luzes quentes:** só 2 pontuais dinâmicas (porta da torre e praça da vila). O resto é emissivo: janelas da vila e vidros da torre.
- **Névoa:** um pouco mais leve, para separar os planos sem esconder a forma.
- **Chuva:** 2 400 → 1 800 gotas, menos opaca, inclinada pelo vento numa só direção e com comprimentos variados.
- **Bloom:** força 0,42 → 0,30, limiar 0,82 → 0,88.
- **Iluminação neutra** (botão novo): luz branca, sem névoa nem céu, para inspecionar forma e material.

## 5. Materiais (o que é e o que não é PBR)

| Material | Cor | Normal | Rugosidade | Metal | AO | Emissivo |
|---|---|---|---|---|---|---|
| Terreno e rocha (triplanar) | textura procedural | sim | por camada e umidade | 0 | por vértice no terreno; não nas rochas | não |
| Pedra da torre | textura `blocos` | sim | sim | 0 | não | não |
| Metal escovado, bronze, cobre | sim | sim | mapa | valor fixo | não | só nos condutores (pulso) |
| Vidro e cristais | cor | não | valor | 0 | não | sim |

**Não é PBR completo:**
- não há mapa de AO nas peças;
- a metalicidade é um valor fixo por material;
- as texturas são procedurais (512² e 256²) e geradas no navegador, sem fotos.

A escala foi conferida por tipo: rocha cerca de 25 studs por repetição; blocos, lajes e metal entre 7 e 14.

## 6. Navegação (avatar de cerca de 5,2 studs)

Verificado por script. Os resultados são **idênticos na V2 e na V2.2**: o polimento não criou bloqueio novo.

- **Trilhas:** 8 a 16 studs de largura, contando a variação de ±14%.
- **Degraus da torre:** 0,9 stud de altura por 2 de piso.
- **Bloqueios já existentes desde a V1:**
  - o centro da praça da vila (o Coletor fica no meio do caminho P1);
  - a oficina na saída da P2;
  - a mina STORM.MINE.01 e a Árvore Ancestral encostadas na P2.

  Ficam para as fases da vila e da floresta.
- **Maior inclinação:** 46° na passagem secreta P5, perto de (-214, 122). Também já existia.

## 7. Desempenho

Medido no navegador de teste (CPU, sem GPU), vista "Três quartos":

| | V2 | V2.2 |
|---|---|---|
| Chamadas de desenho | 905 a 929 | 884 a 900 |
| Triângulos por quadro (com sombra) | 1,30 milhão | 1,54 milhão |
| FPS no teste | cerca de 20 (limitado pelo ambiente de teste) | cerca de 20 (idem) |

O que reduziu o custo:

- **Árvores:** de cerca de 270 para 71 chamadas, desenhadas por instanciamento.
- **Seixos:** de 330 mil para 72 mil triângulos, com forma simples e sem sombra.
- **Pedras de borda:** sem sombra.
- **Cogumelos e arbustos:** simplificados.

Objetos mais caros hoje:

| Objeto | Custo |
|---|---|
| Vegetação rasteira | cerca de 380 mil triângulos |
| Árvores V1 (tubos) | cerca de 515 mil |
| Torre | cerca de 137 mil e 157 chamadas |
| Arquitetura V1 da vila | cerca de 240 chamadas |

**Pendente:**
- LOD das árvores;
- divisão espacial da vegetação instanciada (hoje não é cortada por distância);
- vila.

## 8. Problemas ainda existentes

- **Chifre principal:** de perto ainda tem silhueta cônica. Precisa de esculpimento à mão ou de uma malha de rocha própria.
- **Borda leste:** fica no lado da sombra e continua escura. Os contrafortes ali parecem placas.
- **Arquitetura e floresta da V1:** a vila, o observatório, a ponte e as árvores continuam com o acabamento da V1 e destoam da torre.
- **Tom geral:** azul e violeta. As luzes quentes ajudam, mas o contraste quente e frio ainda está longe do Fragmento Celestial.
- **Comparação:** a V2 pode ser aberta em `v2-backup/visualizador.html` no repositório, mas não foi publicada no artifact.

## 9. Roblox

**Nada foi testado no Roblox Studio.**

**Pode virar MeshPart pelo GLB exportado:**
- torre (separada por peças animadas);
- depósitos;
- contrafortes;
- pedras e afloramentos (6 formas base);
- arbustos, samambaias e cogumelos (formas base para clonar);
- árvores, agora exportadas pelo material real.

**Precisa ser reconstruído no Roblox:**
- terreno: Terrain pelo heightmap mais MaterialVariants;
- triplanar, AO por vértice e estratos do shader;
- cachoeiras: Beam/ParticleEmitter;
- pulso dos condutores e eixo de energia: Beam;
- chuva, névoa, céu e bloom: ParticleEmitter, Atmosphere e Lighting;
- giro do cardã: HingeConstraint ou TweenService no cliente.
