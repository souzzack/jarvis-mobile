---
name: relatorio-semanal
description: Analisa as métricas da semana do @davieopai coladas em metricas/ e gera o relatório com o que repetir, o que mudar e o próximo teste. Use às segundas ou quando o usuário colar números do Instagram.
---

# Relatório semanal

1. Se o usuário colou números na conversa, grave-os em `metricas/AAAA-MM-DD.md` (data de hoje).
2. Se não houver métricas novas, peça ao usuário para colar seguindo o modelo de `metricas/README.md`. Não invente números.
3. Chame o agente `analista-de-resultados` com o arquivo de métricas e o calendário da semana passada. Ele grava `relatorios/AAAA-Wnn.md`.
4. Aplique as atualizações que o analista sugerir em `marca/estilo-animacao.md` e `rotina/semana-padrao.md`, se o usuário concordar.
5. Faça commit e push.

Entregue o resumo em 3 linhas e as 3 decisões para a próxima semana.
