# Estúdio @davieopai

Este repositório é o estúdio de conteúdo do Instagram **@davieopai**. Aqui ficam o perfil da marca, o calendário, os roteiros, as animações e os relatórios. Não há código de produto.

## A conta

- Instagram: @davieopai
- Série **Davi & Deus**: conversas sinceras do Davi (menino em 3D de blocos) com Deus, a quem ele chama de Pai (luz quente da janela). Feita pelo usuário com o Claude; trouxe 12 mil seguidores em uma semana.
- Tudo da série (código three.js, roteiros, capas, vozes e o passo a passo de produção) está em `personagem/`. Comece por `personagem/LEIA-ME-SERIE-DAVI.md`.
- Público: **jovens e adolescentes que procuram a Deus**. Meta: **50 mil seguidores até 31/12/2026**, com cerca de **14 episódios por semana** (2 por dia).
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
| `animador` | Anima o episódio em three.js com o pipeline de `personagem/`. |
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
- `personagem/` — a série: `serie.js`, `davi.js`, `quarto.js`, `cenarios.js`, `epNN.html`, `capa.html`, `compose_ep.html`, roteiros e capas em `mascote-claude/`, vozes e configs em `eps101112/epNN/`.
- `animacoes/` — peças animadas para stories. Vídeos (`*.mp4`) não vão para o git; entregue ao usuário diretamente.
- `metricas/AAAA-MM-DD.md` — números que o usuário copia do Instagram.
- `relatorios/AAAA-Wnn.md` — análise semanal.
- `rotina/semana-padrao.md` — dias, horários e formatos fixos.

## Regras da casa

- **Nada de cortes de episódios antigos.** Isto não é podcast: o feed é feito só de episódios novos, com tema inédito. Quando faltar episódio, a resposta é um tema novo, não um corte.

- Escreva tudo em português do Brasil, no tom de `marca/perfil.md`.
- Use as habilidades instaladas de redes sociais (`social-media-skills:*`) em vez de improvisar o método. Para animar, siga o pipeline de `personagem/LEIA-ME-SERIE-DAVI.md` (three.js), não comece do zero.
- Vídeo sempre vertical 1080×1920, 30 fps, com legenda queimada e área segura (nada importante nos 250 px de cima e de baixo). Episódios têm cerca de 1min40.
- Personagens nunca podem se atravessar: rode a checagem de colisão antes de renderizar.
- Versículo sempre com referência conferida. Temas sensíveis levam o aviso do CVV 188 na legenda.
- Histórias de seguidores só anonimizadas e com permissão.
- Não invente números de alcance, seguidores ou métricas. Só use o que estiver em `metricas/` ou o que o usuário disser.
- Trilha: sintetizada por episódio (`trilha.py`), sem música de terceiros. Vozes: o usuário grava no ElevenLabs a partir dos roteiros.
- Não existe conexão com o Instagram neste ambiente: nada é publicado automaticamente. Entregue tudo pronto para o usuário postar ou agendar no próprio app.
- Campos marcados como "a confirmar" em `marca/` devem ser perguntados ao usuário, nunca inventados.
