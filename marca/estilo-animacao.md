# Estilo das animações: Davi & Deus

> O `animador` mantém este arquivo. O passo a passo técnico completo está em `personagem/LEIA-ME-SERIE-DAVI.md`. Folha do personagem: `personagem/davi_folha.png`.

## Técnica

- **3D em three.js** com blocos arredondados (`RoundedBoxGeometry`), não Remotion. Cada episódio é uma página `personagem/epNN.html` que usa a base comum `personagem/serie.js`.
- Peças reaproveitáveis: `davi.js` (personagem e expressões), `quarto.js` (quarto com poses), `cenarios.js` (escola, cidade, igreja), `telas.js`, `estudio.js`.
- Pós-processamento: bloom (brilho da luz de Deus) e profundidade de campo (bokeh).
- Vertical 1080×1920, 30 fps. Render interno a 2/3 da resolução e ampliado (`?q=1` para resolução cheia).
- Boca e luz sincronizadas com as vozes (envelopes gerados pelo `pipeline.py`).

## Personagens

- **Davi:** cabeça grande em bloco, cabelo cacheado escuro em bolinhas, olhos quadrados com brilho, pele morena, camiseta marrom, calça escura, tênis branco. Expressões controladas por `makeExpr` (sobrancelha, olhos, boca, lágrima).
- **Deus:** luz quente (dourada) entrando pela janela, com raios e partículas. A intensidade da luz acompanha a voz de Deus.
- Outros personagens (colegas, pais, Caio) usam a mesma base com variações (`addGlasses`, `addLongHair`, cores de roupa).
- **Regra de ouro:** personagens nunca se atravessam. Rodar a checagem de colisão sempre.

## Paleta

- Noite: azul-marinho profundo (#0a0f24 aprox.) e roxo escuro no chão.
- Luz de Deus: dourado e âmbar quente.
- Davi: pele #b8744a aprox., camiseta marrom-avermelhada.

## Legendas e textos na tela

- Etiqueta do personagem (**DAVI** / **DEUS**) antes da fala.
- Versículo na tela com referência quando Deus cita a Bíblia.
- Título do episódio em duas linhas no começo; texto final + "Manda pra alguém que…" no fim.

## Capa (`personagem/capa.html`)

- Marca **DAVI & DEUS** no topo com ícone de cruz dourada.
- Quadro forte do episódio (close com emoção, luz dourada em raios).
- Selo em pílula com o tema (ex.: "DONS INVISÍVEIS").
- Título em duas linhas: primeira em branco, segunda em dourado, fonte pesada com contorno escuro.
- Referência bíblica embaixo, entre filetes dourados; moldura dourada fina; base azul-marinho.
- Sem número do episódio na capa.

## Som

- Vozes do usuário (ElevenLabs), uma por arquivo, com marcações de emoção em inglês entre colchetes nos roteiros (`[sad]`, `[warm]`).
- Trilha sintetizada por episódio (`trilha.py`) com sidechain sob as vozes.

## O que funciona

- Episódios sobre dores comuns de adolescente (rejeição, comparação, ansiedade, vergonha da fé).
- Humor gentil de Deus quebrando a tensão no meio da conversa.
- Final sem fala com a virada visual e frase curta para compartilhar.
- (O analista acrescenta aqui o que as métricas mostrarem.)
