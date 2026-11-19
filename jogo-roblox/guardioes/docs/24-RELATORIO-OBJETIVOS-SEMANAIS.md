# 24 · Relatório: objetivos semanais das companhias (sem o Studio)

Data: 19/11/2026. **Nada foi executado** no Studio nem em runtime Luau.

Fecha o item do GDD 10 que faltava nas companhias: **objetivos semanais cooperativos**.

## Como funciona

- **Semana:** começa na segunda 00:00 UTC.
- **Sorteio:** cada companhia recebe **3 objetivos** de uma lista de 4. O sorteio é fixo por companhia e semana, então todos os servidores mostram os mesmos objetivos sem precisar combinar.
- **Os 4 objetivos:**

  | Objetivo | Tipo | Alvo base | Prêmio para quem ajudou |
  |---|---|---|---|
  | Caça às Faíscas | Derrotar inimigos comuns | 40 | Fragmento de Faísca ×6 |
  | Chefes da Ilha | Derrotar chefes ou minibosses | 3 | Núcleo de Tempestade ×1 |
  | Mãos na Forja | Fabricar | 8 | Fragmento ×4, Casca Antiga ×2 |
  | Escudos Firmes | Aparar golpes | 30 | Semente Flutuante ×3 |

- **Alvo maior para companhias maiores:** cresce 15% por membro além do primeiro, no máximo 3 vezes o alvo base.
- **Cooperativo de verdade:** o objetivo só conclui com **pelo menos 2 pessoas** contribuindo. Uma companhia de 1 membro conclui sozinha.
- **O que conta como contribuição:** uma derrota conta para quem causou o mínimo de dano do saque (o mesmo critério do loot).
- **Prêmio:** XP da companhia (250 a 400) e materiais modestos para **cada** pessoa que contribuiu. Não dá poder de combate direto, como pede o GDD.

## Por que ficaram de fora "restaurar" e "depositar"

- **Restaurar:** cada estrutura só é restaurada uma vez por jogador. Depois de algumas semanas, o objetivo ficaria impossível.
- **Depositar no cofre:** daria para repetir sem jogar, depositando e retirando o mesmo item.

## Segurança e gravação

- **O progresso é juntado em memória** e gravado a cada **30 s**, numa escrita por companhia. Gravar a cada inimigo derrotado esgotaria o limite do DataStore.
- **Se o servidor cair:** perde-se no máximo esses 30 s de progresso, nunca um prêmio já gravado.
- **Gravação atômica:** a conclusão, o XP e os prêmios entram **na mesma gravação** (`UpdateAsync` da companhia). Os prêmios vão para `aDevolver` e seguem o mesmo caminho seguro das devoluções: entregues na hora a quem está online e guardados para quem está offline.
- **Cada objetivo paga uma vez só.** Depois de concluído, ele não soma mais.
- **Quem saiu da companhia** antes da gravação não conta.
- **Se a gravação falhar,** o lote volta para a fila. Se a companhia foi dissolvida, o lote é descartado.

## Arquivos

**Criados:**

| Arquivo | Conteúdo |
|---|---|
| `src/ReplicatedStorage/Guardioes/Companhias/Semanal.luau` | Lógica pura, sem `require` |
| `src/ReplicatedStorage/Guardioes/Config/ObjetivosSemanais.luau` | A lista de objetivos |
| `tests/Specs/Semanal.spec.luau` | 8 casos |

**Com acréscimos:**
- `CompanySystem`: conta o progresso, grava a cada 30 s e mostra a seção no painel.
- `Companhia`: campo `semanal`.
- `ConfigServidor`: `semanalSeg`.
- `JanelaDaCompanhia`: seção "Objetivos da semana".
- Executores de teste, doc 10 (seção 17), README.

**Fora de `jogo-roblox/guardioes/`:** nada.

## Verificado aqui

- **Equilíbrio de blocos:** 0 problemas nos 160 arquivos.
- **Segunda-feira:** o timestamp de 16/11/2026 00:00 UTC (1794787200) foi conferido em Python, e é segunda.
- **Alvo:** 40 com 5 membros = 64; com 30 membros = 120 (teto).

O Lune continua bloqueado, então os testes **não rodaram**.

## Pendente

- Relíquia.
- Portais entre places.
- Visual dos objetivos (hoje é só texto no painel).
- Roteiros W1 a W9 no Studio.
