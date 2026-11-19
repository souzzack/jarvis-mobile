# 27 · Revisão de código dos sistemas (sem o Studio)

Data: 19/11/2026. Revisão **estática**, lendo o código. **Nada foi executado** no Studio nem em runtime Luau.

Foco: o que mais quebra um jogo publicado.

- **Mensagens do cliente:** validação e limite de pedidos.
- **Salvamento:** duplicação e perda de itens.
- **Memória:** tabelas por jogador que nunca são limpas.
- **Laços do servidor:** os que morrem em silêncio.

## Corrigido nesta revisão

| # | Gravidade | Onde | Problema | Correção |
|---|---|---|---|---|
| 1 | **Alta** (duplicação) | `CompanySystem.despachar` | Com membros da mesma companhia em **dois servidores**, os dois liam a mesma devolução, somavam na chave do jogador e depois limpavam: **itens em dobro** | Duas gravações com **token idempotente**, descritas abaixo |
| 2 | **Alta** (perda) | `CompanySystem.despachar` | A limpeza apagava `aDevolver[uid]` inteiro, inclusive um prêmio que tivesse chegado entre a leitura e a limpeza | Só o lote retirado sai; o que chega depois fica para o próximo |
| 3 | **Alta** (duplicação) | `CompanySystem.reclamar` | Duas chamadas ao mesmo tempo (ao entrar e no despacho) liam o mesmo pendente e **entregavam duas vezes** | **Retira primeiro** (atômico) e entrega depois; o que não couber na bolsa volta para a chave. Uma chamada por jogador por vez |
| 4 | **Alta** (itens presos) | `CompanySystem.mudar` | Qualquer operação numa companhia **dissolvida** era recusada, inclusive o despacho das devoluções: os depósitos de todos **ficariam presos para sempre** | As operações internas de devolução passam (`mesmoDissolvida`). O ciclo de 60 s e a entrada de ex-membros tentam de novo até não sobrar nada |
| 5 | Média (memória) | `MovementSystem.energiaExtra`, `ProgressionSystem.vidaExtra` | Tabelas por jogador **nunca limpas** ao sair: cada jogador que passava ficava na memória do servidor | Limpas no `PlayerRemoving` |
| 6 | Média (sistema para) | 6 laços `while true` (barra do chefe, revelar ocultos e lista dos companheiros, ciclo da companhia, descoberta de pontos de viagem, montarias) | Sem `pcall`: **um erro qualquer matava o laço em silêncio** até o servidor reiniciar | Corpo de cada laço em `pcall`, com aviso no log |

**Como ficou a devolução (itens 1 e 2):**
1. Numa gravação da companhia, o lote sai de `aDevolver` para `emTransito[token]`. Como a gravação é atômica, **só um servidor ganha**.
2. O lote é somado na chave da pessoa **com o token**. O mesmo token nunca soma duas vezes.
3. `emTransito[token]` é apagado.
4. Se o servidor cair entre os passos 2 e 3, outro servidor refaz o passo 2 **com o mesmo token** depois de 5 min, e nada duplica.

## Conferido e sem problema

- **Mensagens do cliente (15 sistemas):** todos conferem o tipo de cada argumento e o tamanho dos textos. Todos têm limite de pedidos por jogador.
- **Números do cliente:** NaN e números quebrados são recusados onde importam (quantidades do cofre). A direção da esquiva não é usada pelo servidor.
- **Gravações do perfil (`PlayerDataSystem.atualizar`):** toda mudança de perfil passa por elas. Nenhum sistema altera a cópia de `obter` achando que salva. Nenhuma função de transação pausa no meio, então uma não atropela a outra.
- **Tabelas por jogador:** limpas no `PlayerRemoving` em todos os outros sistemas.
- **Missões:** marcar a missão como concluída confere `missoes[id]` dentro da gravação, então não paga duas vezes.
- **Catálogo secreto:** relíquias ??? entram só no `porId` do servidor, e nenhum sistema envia o catálogo inteiro ao cliente.
- **Mensagens para todos os jogadores** (`FireAllClients`): só eventos pequenos (golpe, morte, aviso de ataque).

## Riscos que continuam (não corrigidos, de propósito ou por precisar do Studio)

| Risco | Por que ficou |
|---|---|
| Recompensa de **material de missão** é entregue numa gravação separada da conclusão: com a pilha cheia (9999), o material se perde | Raro. Corrigir exige reorganizar o `QuestSystem` em uma transação; fica para depois do teste no Studio |
| `vistos` da barra do chefe cresce um pouco a cada vez que o chefe volta | Uns poucos bytes por jogador por sessão; é limpo quando o jogador sai |
| O desempenho real (laços de 0,2 s a 1 s, IA a 10 Hz) não foi medido | Só no Studio, com o Micro Profiler |
| Nenhum teste rodou | O Lune continua bloqueado aqui |

## Arquivos alterados

- `CompanySystem`.
- `Companhia` (campo `emTransito`).
- `MovementSystem`, `ProgressionSystem`.
- `BossSystem`, `CompanionSystem`, `DimensionSystem`, `MountSystem`.
- Este documento e o README.

**Fora de `jogo-roblox/guardioes/`:** nada.

## Verificado aqui

- **Equilíbrio de blocos:** 0 problemas nos 167 arquivos.
- **Laços:** os laços envolvidos em `pcall` não tinham `return` nem `break` no corpo, então o comportamento continua igual.
