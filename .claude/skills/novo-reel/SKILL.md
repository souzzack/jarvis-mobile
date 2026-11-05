---
name: novo-reel
description: Produz um episódio novo de Davi & Deus (@davieopai) - roteiro, vozes, animação em three.js, edição, capa e legenda. Use quando o usuário pedir um episódio novo ou passar um tema.
argument-hint: "<tema, número do episódio ou caminho de um roteiro pronto>"
---

# Novo episódio: $ARGUMENTS

1. Se `$ARGUMENTS` aponta para um roteiro pronto em `personagem/mascote-claude/davi/`, use-o. Se é um tema, chame o `roteirista-reels` para escrever o episódio no formato da série e mostre ao usuário para aprovar.
2. Entregue ao usuário os **blocos de voz** (um por personagem) para gravar no ElevenLabs e peça os dois mp3 (`voz_davi.mp3`, `voz_deus.mp3`). Sem as vozes não dá para sincronizar boca e legenda.
3. Com as vozes em `personagem/eps101112/epNN/` (ou a pasta do lote atual), chame o `animador` para as etapas 1 a 6 do `personagem/LEIA-ME-SERIE-DAVI.md`.
4. Chame o `editor-de-reels` para trilha, composição e encode (etapas 7 a 9).
5. Em paralelo, chame o `designer-de-capas` (etapa 10) e o `redator-legendas` (Instagram + TikTok + comentário fixado, CVV 188 se for tema sensível).
6. Envie ao usuário o vídeo e a capa (SendUserFile), com a legenda pronta para copiar e o horário de postagem.
7. Atualize a tabela de episódios em `marca/perfil.md` e o calendário, e faça commit e push (vídeos não vão para o git).
