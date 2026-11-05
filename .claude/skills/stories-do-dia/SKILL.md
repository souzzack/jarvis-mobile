---
name: stories-do-dia
description: Monta a sequência de stories de hoje do @davieopai com bastidores das animações, stickers de interação e teaser ou repost dos Reels. Use toda manhã ou quando o usuário pedir os stories.
---

# Stories do dia

1. Veja a data de hoje e abra o calendário da semana em `calendario/` para saber o tema do dia e se hoje tem Reels.
2. Leia `roteiros/stories/` de ontem para dar continuidade (resultado de enquete, resposta de caixinha).
3. Chame o agente `produtor-de-stories` com a data, o tema e o que aconteceu ontem. Ele grava `roteiros/stories/AAAA-MM-DD.md`.
4. Se algum story pedir animação curta, chame o `animador` com a descrição (até 15 s, 1080×1920) e entregue o arquivo.
5. Faça commit e push dos arquivos.

Entregue ao usuário a sequência numerada, pronta para seguir no celular: o que postar, o texto e o sticker de cada story, com horário sugerido.
