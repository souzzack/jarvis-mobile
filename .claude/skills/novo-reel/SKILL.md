---
name: novo-reel
description: Leva uma ideia de Reels do @davieopai do roteiro ao vídeo final - roteiro, animação em Remotion, edição, legenda e capa. Use quando o usuário pedir um Reels novo ou passar uma ideia.
argument-hint: "<ideia ou caminho de um roteiro já pronto>"
---

# Novo Reels: $ARGUMENTS

1. Se `$ARGUMENTS` é um caminho de `roteiros/reels/`, use esse roteiro. Se é uma ideia, chame o `roteirista-reels` para criar o roteiro com a data de postagem (pergunte se não souber) e mostre ao usuário para aprovar.
2. Chame o `animador` com o caminho do roteiro. Ele cria `animacoes/AAAA-MM-DD-slug/` e renderiza.
3. Chame o `editor-de-reels` para finalizar `out/final.mp4` (legendas, áudio, checagem técnica).
4. Em paralelo, chame o `redator-legendas` e o `designer-de-capas`.
5. Entregue o vídeo ao usuário (envie o arquivo), junto com a legenda pronta para copiar, a capa e o horário de postagem.
6. Atualize o status no calendário para "pronto" e faça commit e push (os vídeos não vão para o git).
