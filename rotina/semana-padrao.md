# Semana padrão

> Meta: **50 mil seguidores até 31/12/2026**. Ritmo: cerca de **14 episódios de Davi & Deus por semana** (2 por dia), mais stories todos os dias. Ajuste os horários pelo painel do Instagram (Público → Horários mais ativos).

## Reels: 2 episódios por dia

| Horário | O quê |
|---|---|
| 12h | Episódio (temas mais leves: amizade, escola, comparação, dons) |
| 19h–20h | Episódio (temas mais profundos: ansiedade, luto, perdão, família) |

Só episódios novos no feed, nunca cortes de episódios antigos. Revisar horários depois de 2 semanas de métricas.

## Stories: todos os dias, 4 a 7

1. **Abertura:** Davi olhando a luz da janela ou um quadro do episódio do dia.
2. **Interação:** caixinha "o que você queria perguntar pra Deus?" ou enquete do próximo tema (alimenta o banco de temas).
3. **Antes de cada episódio:** contagem regressiva ou capa.
4. **Depois de cada episódio:** repost com "assiste até o final".
5. **Fechamento:** versículo do dia ou resposta a uma pergunta da caixinha.

## Linha de produção (14 por semana)

O gargalo é voz e render, então tudo vai em lote:

- **Domingo:** `/planejar-semana` gera os 14 roteiros e um arquivo único com todos os blocos de voz. O usuário grava as vozes da semana de uma vez no ElevenLabs.
- **Segunda a sábado:** o `animador` monta e renderiza em segundo plano 2 a 3 episódios por dia, sempre um dia à frente da postagem.
- **Todo dia de manhã:** `/stories-do-dia`.
- **Segunda:** métricas em `metricas/` e `/relatorio-semanal`. Acompanhar o ritmo de crescimento contra a meta de 50 mil.
