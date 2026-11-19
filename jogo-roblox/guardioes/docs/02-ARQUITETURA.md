# Guardiões do Multiverso: arquitetura técnica (Luau / Roblox)

> Nada aqui foi executado no Roblox Studio nem em runtime Luau (veja `00-AUDITORIA.md`, seção 3). Tudo foi escrito para `--!strict` e organizado para sincronizar com o **Rojo**, que é gratuito e opcional; o mesmo código também pode ser colado à mão no Studio.

## 1. Princípios

1. **O servidor manda.** O cliente envia **intenções** ("quero atacar", "quero esquivar") e o servidor decide. Dano, recompensas, itens e progresso só mudam no servidor.
2. **Orientado a dados.** Armas, inimigos, raridades, materiais, receitas, missões, segredos e dimensões são **tabelas de configuração** em `Shared/Config`. Uma dimensão nova é uma pasta de dados nova, sem mexer nos sistemas.
3. **Lógica pura separada da API do Roblox.** Cálculos (dano, combo, estamina, rolagem de recompensa, validação de receita) ficam em módulos **puros**, testáveis sem Studio. Os sistemas só ligam essa lógica a `Players`, `Humanoid`, `DataStore` e afins.
4. **Um sistema, uma responsabilidade.** Os sistemas conversam por métodos públicos e sinais, nunca mexendo nos dados internos um do outro.
5. **Poucas chamadas de rede.** Um RemoteEvent por sistema, com o tipo de mensagem como primeiro argumento, limite de frequência por jogador e mensagens pequenas.
6. **Sem dependências pagas.** O que é de terceiros é opcional e gratuito: Rojo para sincronizar; TestEZ ou Jest-Lua para testes.

## 2. Estrutura de diretórios (em `jogo-roblox/guardioes/src`, compatível com Rojo)

```
src/
  ReplicatedStorage/Guardioes/            (compartilhado: cliente + servidor)
    Config/                               SÓ DADOS
      Combate.luau                        regras globais (estamina, esquiva, defesa, aparar, postura)
      Raridades.luau                      as 8 raridades oficiais (ordem, cor, multiplicador de poder)
      Armas/Espada.luau                   combo, pesado, alcance, custos (Espadachim)
      Inimigos/BonecoDeTreino.luau        alvo de teste (não ataca)
      Inimigos/FaiscaErrante.luau         inimigo de teste com padrão próprio
      (futuro) Dimensoes/<Id>/ Regioes, Criaturas, Materiais, Receitas, Missoes, Segredos
    Combate/                              LÓGICA PURA
      MaquinaDeCombo.luau                 estados do personagem (ocioso, preparo, golpe, recuperação, esquiva, defesa…)
      Dano.luau                           fórmula de dano, defesa, aparar, postura
      Estamina.luau                       gasto e recuperação
      Alcance.luau                        teste de alcance e arco de acerto
    Util/
      Sinal.luau                          sinal simples (conectar, disparar, desconectar)
      LimiteDeTaxa.luau                   balde de fichas por jogador (anti-spam)
    Rede/Remotos.luau                     nomes e tipos de mensagem; cria ou busca os RemoteEvents
  ServerScriptService/Guardioes/
    Main.server.luau                      inicializa os sistemas na ordem (Init → Start)
    Sistemas/
      CombatSystem.luau                   valida intenções, aplica dano, replica eventos
      EnemySystem.luau                    criaturas: surgimento, IA, telegrafia, morte
      (próximas etapas) PlayerDataSystem, ProgressionSystem, InventorySystem, LootSystem,
      CraftingSystem, BossSystem, QuestSystem, DimensionSystem, RestorationSystem,
      PersonalBaseSystem, CompanySystem, SecretDiscoverySystem
  StarterPlayer/StarterPlayerScripts/Guardioes/
    Main.client.luau                      inicializa os controladores do cliente
    Controladores/
      ControleDeCombate.luau              entrada (PC e toque), previsão local, envio de intenções
      HudDeCombate.luau                   barras de vida e estamina, mira, avisos
tests/                                    testes dos módulos puros (TestEZ-like; rodam no Studio ou no Lune)
default.project.json                      mapa do Rojo
```

## 3. Os 14 sistemas

| Sistema | Responsabilidade | Depende de | Estado |
|---|---|---|---|
| **PlayerDataSystem** | Carregar e salvar o perfil (esquema versionado, trava de sessão, autosave, `BindToClose`, migração de esquema) | — | Planejado (Etapa D) |
| **ProgressionSystem** | XP, nível, atributos, maestria por arma, afinidade por dimensão | PlayerData | Planejado (D) |
| **InventorySystem** | Itens com ID único, pilhas de materiais, equipamento, transações | PlayerData | Planejado (D) |
| **CombatSystem** | Estado de combate por jogador, validação de ataques, esquiva, defesa e aparar, aplicação de dano | Enemy, Progression, Inventory (atributos) | **Protótipo (Etapa C)** |
| **EnemySystem** | Criaturas por configuração: surgimento por regiões, IA a 10 Hz, telegrafia, postura, sono longe dos jogadores | Combat, Loot | **Protótipo (C)** |
| **BossSystem** | Minibosses e Guardiões: fases, arenas, instâncias, regras de retorno | Enemy, Loot | Planejado (E) |
| **LootSystem** | Tabelas de recompensa, garantias, proteção contra azar, entrega pelo Inventory | Inventory | Planejado (E) |
| **CraftingSystem** | Receitas, estações, conhecimento, consumo atômico de materiais | Inventory, Restoration, PersonalBase | Planejado (F) |
| **QuestSystem** | Missões principais e secundárias, objetivos por evento, NPCs | Progression, Inventory | Planejado (G) |
| **DimensionSystem** | Registro das dimensões, portal, viagem (TeleportService ou mesmo place), travas de habilidade | PlayerData | Planejado (G/H) |
| **RestorationSystem** | Estados por estrutura (Abandonada / Em restauração / Restaurada), contribuição cooperativa | Inventory, Quest | Planejado (H) |
| **PersonalBaseSystem** | Parcela, espaços predefinidos, níveis, depois posicionamento livre validado | PlayerData, Inventory | Planejado (H) |
| **CompanySystem** | Companhias, cargos, permissões, cofre com limites e registro | PlayerData, Inventory | Planejado (I) |
| **SecretDiscoverySystem** | Gatilhos de segredo validados no servidor, revelação gradual, receitas ??? (herda o padrão de `luau-rascunho/DescobertasServico.lua`) | PlayerData, Crafting | Planejado (I) |

Cada sistema é um ModuleScript com esta interface:

```lua
local Sistema = {}
Sistema.Nome = "CombatSystem"
function Sistema.Init(ctx) end   -- guarda referências; nada de laços aqui
function Sistema.Start() end     -- conecta eventos e começa os laços
return Sistema
```

O `Main.server.luau` chama `Init` em todos e depois `Start` em todos. O `ctx.obter(nome)` devolve outro sistema já iniciado, sem `require` circular.

## 4. Rede

**Um RemoteEvent por sistema**, em `ReplicatedStorage.Guardioes.Remotos`.

| Direção | Formato |
|---|---|
| Cliente → servidor | `(tipo: number, ...dados pequenos)` |
| Servidor → cliente | `(tipo: number, ...)`, com `FireAllClients` só para eventos visíveis a todos (golpe acertado, morte do inimigo) |

**Combate:**
- O cliente envia **apenas** o tipo de ação e o alvo pretendido (id curto do inimigo).
- O servidor usa a **sua** posição do personagem, a sua contagem de tempo (`os.clock`) e a máquina de combo do próprio servidor.

**Limites e checagens:**
- Limite de frequência por jogador: balde de 12 fichas, recarga de 8 por segundo para combate (T). Excesso é descartado e contado. Abuso persistente gera registro, não expulsão automática.
- Nada de `RemoteFunction` do servidor para o cliente: um cliente travado não pode segurar o servidor.

## 5. Persistência e anti-duplicação

**Perfil:**
- DataStore com **trava de sessão**: `UpdateAsync` grava `{sessao = JobId, quando = os.time()}`; se outro servidor estiver com a trava há menos de 30 min, espera e tenta de novo.
- Autosave a cada 120 s e no `PlayerRemoving`.
- `BindToClose` salva todos com prazo.

**Esquema versionado:**
- Campo `versao`, com migrações `v1 → v2 → …` em funções puras e testáveis.
- Nunca se apaga um campo desconhecido; ele é preservado.

**Itens:**
- Equipamentos têm **ID único** (GUID) e materiais são pilhas.
- Toda mudança passa por `InventorySystem.transacao(jogador, operacoes)`, que é atômica e falha inteira se faltar material.

**Trocas e cofre da companhia** (quando existirem):
- Registro de transação com ID.
- O item sai de um lado e entra no outro na **mesma** gravação lógica, com registro idempotente: repetir a mesma transação não duplica.

**Recompensas:**
- Só o servidor rola o drop, no momento da morte confirmada.
- Quem recebe é decidido por contribuição de dano registrada no servidor.

## 6. Desempenho multiplayer

- **IA de criaturas a 10 Hz** num único laço por servidor, em lote, sem um `while true` por criatura. Quem está a mais de 250 studs de qualquer jogador dorme.
- O movimento das criaturas usa `Humanoid:MoveTo` ou `AlignPosition` no servidor. A animação e os efeitos são só no cliente.
- Golpes não usam `.Touched` (pouco confiável); usam **teste geométrico** no servidor: distância + arco + altura.
- Efeitos visuais (brilho, faíscas, números de dano) são criados no **cliente** a partir dos eventos do servidor.
- **Celular:** botões por `ContextActionService`, mira suave automática, nada de clique fino obrigatório.
- `StreamingEnabled` (já previsto na direção de arte): as criaturas são parentadas a pastas por região.

## 7. Configuração por dimensão (expansão)

```
Config/Dimensoes/StormIsland/
  Dimensao.luau     id, nome, travas, afinidade, preset de luz (aponta para a direção de arte)
  Regioes.luau      regiões (centro, raio, nível, segura?), pontos de surgimento
  Criaturas.luau    quais Config/Inimigos aparecem em cada região, densidade, retorno
  Materiais.luau    materiais (raridade, origem)
  Receitas.luau     receitas (resultado, materiais, estação, conhecimento)
  Missoes.luau      missões e objetivos
  Segredos.luau     gatilhos e passos (servidor; nunca replicado ao cliente)
```

**Regra:** dados de segredos e de receitas ??? ficam em `ServerStorage`, e não em `ReplicatedStorage`, para o cliente não poder ler.

## Complemento (criaturas, voo, montarias, raças, livros, transportes e artefatos)

Os módulos novos, estados, contratos e pastas estão em [`08-ARQUITETURA-ESTADOS-CONTRATOS.md`](08-ARQUITETURA-ESTADOS-CONTRATOS.md). Os princípios deste documento continuam valendo.

**Sistemas novos no servidor:** MovementAbilitySystem, MovementSystem e MetamorphicArtifactSystem.
