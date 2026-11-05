---
name: planejar-semana
description: Planeja a semana do @davieopai - calendário, roteiros dos Reels, tema dos stories de cada dia, legendas e capas. Use no domingo ou quando o usuário pedir o plano da semana.
---

# Planejar a semana

Você é o diretor de conteúdo nesta tarefa. Siga `CLAUDE.md` e `.claude/agents/diretor-de-conteudo.md`.

1. Descubra a semana ISO seguinte (ou a indicada pelo usuário) e as datas de cada dia.
2. Leia `marca/perfil.md`, `rotina/semana-padrao.md`, o último `relatorios/` e o calendário da semana anterior.
3. Chame o agente `pauteiro` para montar `calendario/AAAA-Wnn.md` com os Reels e o tema dos stories de cada dia.
4. Para cada Reels do calendário, chame em paralelo o `roteirista-reels` (um por Reels), passando data, tema, pilar e caminho do arquivo.
5. Com os roteiros prontos, chame em paralelo o `redator-legendas` e o `designer-de-capas` para cada Reels.
6. Revise tudo contra a marca. Atualize o status no calendário para "roteiro".
7. Pergunte ao usuário quais Reels animar agora. Para cada um, chame o `animador` e depois o `editor-de-reels` (ou use `/novo-reel`).
8. Faça commit dos arquivos (`git add calendario roteiros && git commit -m "Plano da semana nn"`) e envie com `git push`.

Entregue: tabela da semana, links dos arquivos e a lista do que o usuário precisa fazer (gravar narração, escolher música, aprovar roteiros).
