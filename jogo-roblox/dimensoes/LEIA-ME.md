# Atlas das Dimensões: padrões das seis ilhas

Ambiente de desenvolvimento das ilhas de **Magnata do Multiverso** no navegador, enquanto o Roblox Studio não está disponível.
Visualizador: `visualizador.html` (three.js r128, o mesmo do Axolote Nebular, que não foi alterado).

> **Situação:** só a **Ilha das Tempestades** (piloto) está construída. As outras cinco aparecem no visualizador como "aguardando aprovação" e **não têm nada modelado ainda**, de propósito: este piloto precisa ser aprovado antes.

## 1. Ferramentas encontradas na auditoria

| O que existe no projeto | Como foi usado |
|---|---|
| three.js r128 (via CDN), OrbitControls, EffectComposer/Bloom e GLTFExporter, já usados nos visualizadores do Axolote | Mesma versão e mesmos addons, para não haver duas pilhas 3D |
| `DIRECAO-ARTISTICA.md` (paleta e vocabulário de forma de cada dimensão, escala do avatar, limite de 10% de energia) | Base da direção artística abaixo; nada foi contrariado |
| Nenhum React Three Fiber, nenhum bundler e nenhum terminal disponível para o usuário | Arquivos `.js` simples carregados por `<script>`, sem build: abrem em qualquer navegador e podem ser publicados como artifact |

## 2. Estrutura de arquivos

```
dimensoes/
  visualizador.html          página: palco 3D + painel (ilhas, câmera, camadas, modelos, exportar)
  nucleo/base.js             ruído, materiais, registro de modelos, colisores, boneco de escala, zip
  nucleo/visualizador.js     câmera livre, caminhada, inspeção, camadas, exportação (comum às 6 ilhas)
  StormIsland/
    plano.js                 layout: pontos de interesse, caminhos, fenda, pontes, minas, marcadores, paleta
    ilha.js                  montagem (chama os módulos na ordem e registra cada modelo)
    Terrain/terreno.js       campo de alturas, cores por vértice, boca da caverna, base flutuante
    Architecture/            torre.js · vila.js · caverna.js · observatorio.js (+ santuário) · pontes.js
    Vegetation/floresta.js   árvores retorcidas (12 formas), Árvore Ancestral, troncos, flores-faísca
    Resources/cristais.js    as 4 minas de cristal
    Props/props.js           rochas, linha de transmissão, doca de chegada, mirante, ruínas, rochas secretas
    Interactions/marcadores.js   marcadores técnicos com ID
    Lighting/iluminacao.js   céu, mar de nuvens, bancos de nuvem, névoa, luzes
    Effects/efeitos.js       relâmpagos, clarão, chuva, arcos, anemômetro
  BubbleField/ … LostAndFound/   (a criar depois da aprovação, com a mesma estrutura)
```

Cada modelo importante é um objeto separado com `id`, nome, pasta, colisores e notas, e pode ser inspecionado e exportado sozinho.

## 3. Padrões para as seis dimensões

**Escala e unidades**
- 1 unidade = 1 stud. Y para cima; +Z aponta para a chegada de cada ilha.
- Boneco de escala com as proporções do avatar padrão (≈5,2 studs).
- No modo caminhada: velocidade 16 studs/s, pulo de 7,2 studs, gravidade 196,2 e degrau máximo de 2,6 studs (valores padrão do Roblox).
- Caminhos principais com 12–16 studs de largura, e mínimo de 8 nas rotas secretas.
- Portas com pelo menos 8 studs de altura e rampa máxima de 0,33 (≈18°).
- Monumento central com 100 studs ou mais, visível da chegada.

**Forma e material**
- Silhueta antes de tudo: a ilha tem que ser legível **sem efeitos e com iluminação simples**. Essa vista existe no visualizador para conferir.
- Poucos materiais nomeados por ilha (pedra, pedra clara/escura, alvenaria, metal, cobre, pátina, madeira, telhado, cristal, energia…). No Roblox, viram MaterialVariant/SurfaceAppearance.
- Energia (emissivo) só em peças pequenas e com fonte: núcleo da torre, cristais, veios, lanternas.
- Repetição com variação: árvores e rochas vêm de sementes diferentes, nunca a mesma malha idêntica em fila.

**Luz** (por ilha, em `Lighting/`)
- Uma luz direcional com sombra, uma hemisférica e no máximo 1–2 luzes pontuais.
- Céu e mar de nuvens próprios, névoa na cor da dimensão.
- Preset "simples" para aparelhos fracos.

**Desempenho**
- Peças estáticas de cada modelo fundidas por material (`MM.bake`).
- Geometria repetida compartilhada (as árvores).
- Efeitos desligáveis, e gráfico reduzido automático em tela de toque ou estreita.
- Na Ilha das Tempestades: cerca de 650 chamadas de desenho e 400 mil triângulos visíveis por quadro em alta qualidade.

**Identificadores**
- Formato `DIMENSAO.CATEGORIA.NOME.NN`, por exemplo `STORM.ARCH.TOWER`, `STORM.MINE.02`, `STORM.NPC.01`.
- Os marcadores de interação usam o mesmo ID que o sistema terá no jogo.

## 4. Exportação

O botão **Baixar pacote** gera um `.zip` com:
- um GLB por pasta (Terrain, Architecture, Vegetation, Resources e Props);
- `heightmap.png` (8 bits) e `heightmap16-RG.png` (16 bits);
- `colormap.png`;
- `marcadores.json`;
- `manifest.json`, com o ID, a pasta, os triângulos, o tamanho, o pivô e os colisores de cada modelo.

Cada modelo também pode ser exportado sozinho pelo painel de inspeção. Dentro do visualizador de artifacts, o arquivo sai como `.zip` (é o formato que o download permite).

**Verificado:** o pacote foi gerado e cada GLB foi reimportado com o GLTFLoader sem erro.
**Não verificado:** a importação no Roblox Studio. Este ambiente não tem o Studio.
