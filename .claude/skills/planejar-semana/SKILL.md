---
name: planejar-semana
description: Planeja a semana do @davieopai - calendário, roteiros dos Reels, tema dos stories de cada dia, legendas e capas. Use no domingo ou quando o usuário pedir o plano da semana.
---

# Planejar a semana

Você é o diretor de conteúdo nesta tarefa. Siga `CLAUDE.md` e `.claude/agents/diretor-de-conteudo.md`.

1. Descubra a semana ISO seguinte (ou a indicada pelo usuário) e as datas de cada dia.
2. Leia `marca/perfil.md`, `rotina/semana-padrao.md`, o último `relatorios/` e o calendário da semana anterior.
3. Chame o agente `pauteiro` para montar `calendario/AAAA-Wnn.md` com os **14 episódios** da semana (2 por dia, sem repetir tema da lista de episódios) e o tema dos stories de cada dia.
4. Chame o `roteirista-reels` em paralelo, em lotes de até 4 episódios por chamada, passando número, data, tema, passagem bíblica e caminho do arquivo. Revise que nenhuma citação esteja errada.
5. Com os roteiros prontos, chame em paralelo o `redator-legendas` e o `designer-de-capas` para cada Reels.
6. Revise tudo contra a marca. Atualize o status no calendário para "roteiro".
7. Junte os blocos de voz dos 14 episódios num só arquivo (`calendario/AAAA-Wnn-vozes.md`) para o usuário gravar tudo de uma vez no ElevenLabs. Pergunte quais episódios animar primeiro. Para cada um, chame o `animador` e depois o `editor-de-reels` (ou use `/novo-reel`).
8. Faça commit dos arquivos (`git add calendario roteiros && git commit -m "Plano da semana nn"`) e envie com `git push`.

Entregue: tabela da semana, links dos arquivos e a lista do que o usuário precisa fazer (gravar narração, escolher música, aprovar roteiros).
