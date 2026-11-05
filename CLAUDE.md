# Estúdio @davieopai

Este repositório é o estúdio de conteúdo do Instagram **@davieopai**. Aqui ficam o perfil da marca, o calendário, os roteiros, as animações e os relatórios. Não há código de produto.

## A conta

- Instagram: @davieopai
- Davi e o Pai são **personagens animados** criados com o Claude. A conta inteira é feita dessas animações, que trouxeram 12 mil seguidores em uma semana.
- Público: **jovens que procuram a Deus**. Objetivo: **crescer**.
- Rotina: **stories todos os dias** e **Reels**, sempre ligados às animações.
- Detalhes da marca, público e tom de voz: `marca/perfil.md`. Leia antes de escrever qualquer coisa.
- Estilo visual das animações: `marca/estilo-animacao.md`. Leia antes de animar.

## A equipe (`.claude/agents/`)

| Agente | Quando chamar |
|---|---|
| `diretor-de-conteudo` | Pedidos amplos: planejar a semana, montar a pauta do dia, decidir prioridades. Ele distribui para os outros. |
| `estrategista-instagram` | Perfil da marca, pilares, metas, posicionamento, bio. |
| `pauteiro` | Ideias, tendências, calendário. |
| `roteirista-reels` | Roteiro de Reels: gancho, cenas, falas, texto na tela. |
| `produtor-de-stories` | Sequência diária de stories com enquetes, caixinhas e teasers. |
| `animador` | Cria as animações em código (Remotion) a partir do roteiro. |
| `editor-de-reels` | Junta animação, áudio e legendas e entrega o vídeo 1080×1920. |
| `redator-legendas` | Legenda, hashtags, texto do carrossel, palavras-chave para busca. |
| `designer-de-capas` | Capa do Reels, artes de stories e destaques. |
| `analista-de-resultados` | Lê as métricas em `metricas/` e diz o que repetir e o que cortar. |
| `gestor-de-comunidade` | Respostas a comentários e DMs, rotina de engajamento. |

## Atalhos (`.claude/skills/`)

- `/planejar-semana` — plano completo da semana com roteiros e legendas.
- `/stories-do-dia` — sequência de stories de hoje.
- `/novo-reel <ideia>` — do roteiro ao vídeo renderizado.
- `/relatorio-semanal` — análise das métricas coladas em `metricas/`.

## Onde cada coisa fica

- `calendario/AAAA-Wnn.md` — plano da semana (semana ISO). Um arquivo por semana.
- `roteiros/reels/AAAA-MM-DD-slug.md` — roteiro de cada Reels, com legenda e capa no fim.
- `roteiros/stories/AAAA-MM-DD.md` — stories do dia.
- `animacoes/AAAA-MM-DD-slug/` — projeto Remotion de cada animação. Renders (`out/`, `*.mp4`) não vão para o git; entregue o vídeo ao usuário diretamente.
- `metricas/AAAA-MM-DD.md` — números que o usuário copia do Instagram.
- `relatorios/AAAA-Wnn.md` — análise semanal.
- `rotina/semana-padrao.md` — dias, horários e formatos fixos.

## Regras da casa

- Escreva tudo em português do Brasil, no tom de `marca/perfil.md`.
- Use as habilidades instaladas de redes sociais (`social-media-skills:*`) e de animação (`remotion:*`, `motion-reel`) em vez de improvisar o método.
- Vídeo sempre vertical 1080×1920, 30 fps, com legenda queimada e área segura (nada importante nos 250 px de cima e de baixo).
- Não invente números de alcance, seguidores ou métricas. Só use o que estiver em `metricas/` ou o que o usuário disser.
- Música: só áudio licenciado ou da biblioteca do Instagram. Indique o tipo de som; quem escolhe a faixa é o usuário no app.
- Não existe conexão com o Instagram neste ambiente: nada é publicado automaticamente. Entregue tudo pronto para o usuário postar ou agendar no próprio app.
- Campos marcados como "a confirmar" em `marca/` devem ser perguntados ao usuário, nunca inventados.
