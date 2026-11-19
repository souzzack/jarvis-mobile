# 23 · Relatório: Bancada, Depósito e consumíveis (sem o Studio)

Data: 19/11/2026. **Nada foi executado** no Studio nem em runtime Luau.

Fecham-se os dois espaços da base que faltavam no GDD 9: **Bancada** (consumíveis e acessórios) e **Depósito** (espaço extra de inventário).

## O que foi feito

| Área | Entrega |
|---|---|
| **Bancada** (níveis 1 a 3) | Estação da base, só do dono, como a Forja. Receitas: Bálsamo de Casca e Tônico de Vento (nível 1), Infusão de Faísca (nível 2) e o acessório **Pingente de Pena** (Comum, energia de voo +6). Os ingredientes vêm do Jardim: a base alimenta a si mesma |
| **Consumíveis** | **Bálsamo**: cura 35 em 3 s, também no ar. **Tônico**: energia de voo +40. **Infusão**: estamina +50, só no chão. A recarga é **por tipo de efeito** (20 s, 25 s e 30 s). Os valores são pequenos de propósito: ajudam, mas não substituem defender, aparar e pousar |
| Barra | Teclas **2, 3 e 4**; o bálsamo também no **L1** do controle; ou toque. Mostra quantidade e recarga, e some quando o jogador não tem nenhum consumível |
| **Depósito** (níveis 1 a 4) | Quantos equipamentos o jogador guarda: **30, 45, 60 e 80**. Fabricar além disso é recusado **sem consumir nada**. O letreiro mostra "Equipamentos N/limite", e a Bolsa mostra o mesmo número |
| **Desmontar** | Só um item **não equipado**, com dois cliques (Desmontar → Confirmar?). Devolve Fragmento de Faísca ×2, mais 1 do material de origem nos Druida. É menos do que o item custou, e as melhorias não voltam. O item sai e o material entra **na mesma gravação** |

## Segurança

- **Uso de consumível:** o cliente só pede. O servidor confere posse, recarga, voo, atordoamento e se o jogador está vivo. Ele **consome primeiro** e só então aplica o efeito.
- **Cura:** para no máximo da vida e é interrompida se o jogador morrer.
- **Limite do Depósito:** é conferido **dentro** da transação do inventário. Dois pedidos ao mesmo tempo não passam do limite.
- **Desmontar:** confere de novo, dentro da gravação, se o item ainda existe e não foi equipado no meio.

## Corrigido de passagem

- **`Config/Base` usava `Vector3`** no layout. O Lune não tem esse tipo sem a biblioteca do Roblox, então `rodar-lune.luau` falharia ao carregar o módulo. O layout agora usa números `{ x, y, z }`, e o servidor converte.
- **Motivo de recusa na fabricação:** o inventário agora devolve o motivo real da falha (por exemplo, `depositoCheio`) em vez de sempre "gravação". A fabricação mostra a mensagem certa.

## Arquivos criados

| Arquivo | Conteúdo |
|---|---|
| `src/ReplicatedStorage/Guardioes/Config/Consumiveis.luau` | Os 3 consumíveis |
| `src/ReplicatedStorage/Guardioes/Consumiveis/Consumivel.luau` | Lógica pura: pode usar, recarga, pulsos de cura |
| `src/ServerScriptService/Guardioes/Sistemas/ConsumableSystem.luau` | Uso no servidor |
| `src/StarterPlayer/StarterPlayerScripts/Guardioes/Controladores/BarraDeConsumiveis.luau` | Barra de consumíveis |
| `tests/Specs/BancadaDeposito.spec.luau` | 7 casos |

**Arquivos existentes com acréscimos:**
- **Configuração:** `Config/Base` (Bancada, Depósito, layout em números), `Config/Materiais` (consumíveis), `Config/Receitas` (4 da Bancada), `Config/Equipamentos` (Pingente).
- **Lógica pura:** `Base/Base` (`capacidadeDoDeposito`), `Combate/Estamina` (`recuperar`), `Equipamento/Equipamento` (`desmontar`).
- **Sistemas:**
  - `InventorySystem`: limite do Depósito e motivo da falha;
  - `CraftingSystem`: mensagem de Depósito cheio;
  - `PersonalBaseSystem`: estações genéricas e letreiro;
  - `EquipmentSystem`: DESMONTAR e capacidade na lista;
  - `MovementSystem` (`recuperarEnergia`) e `CombatSystem` (`recuperarEstamina`).
- **Rede, cliente e carga:** `Remotos`, `Mensagens`, `HudDeProgresso` (capacidade e Desmontar), `Main.server`, `Main.client`.
- **Testes e docs:** executores de teste, doc 10 (seção 16), README.

**Fora de `jogo-roblox/guardioes/`:** nada.

## Verificado aqui

- **Equilíbrio de blocos:** 0 problemas nos 157 arquivos.
- **Ligações:** `require`, mensagens e nomes de RemoteEvent conferidos.
- **Lune:** nenhum módulo carregado pelo executor do Lune usa mais tipos do Roblox.
- **Conta à mão:** os pulsos da cura somam 35 (6 × 5,833…).

O Lune continua bloqueado, então os testes **não rodaram**.

## Pendente

- Visual: modelos da Bancada e do Depósito (hoje são blocos coloridos), efeito de cura e ícones da barra.
- Portais entre places, relíquia, objetivos semanais das companhias.
- Roteiros D1 a D13 no Studio.
