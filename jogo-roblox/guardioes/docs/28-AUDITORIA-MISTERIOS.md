# 28 · Auditoria para o sistema de mistérios (complemento 03, fase A)

Data: 19/11/2026. Feita lendo o repositório. **Nada foi executado** no Studio.

**Ponto de retorno (backup versionado):** o commit `a7fa510` (branch `claude/intelligent-cerf-lfd2d7`) é o estado anterior a qualquer mudança desta etapa. Todas as alterações em arquivos existentes ficam no histórico do git e podem ser desfeitas uma a uma.

## Dependências existentes e como foram usadas

| Precisa de | Existe? | Interface usada | Observação |
|---|---|---|---|
| PlayerData (persistência) | Sim, `PlayerDataSystem` | `obter`, `atualizar` (transação), `carregado` | Campo novo `perfil.misterios` (com migração) |
| Inventory | Sim, `InventorySystem` | `transacao` (atômica), `contar` | É o **serviço central de recompensas** do projeto: usado pelo `SecretRewardService` |
| Crafting | Sim, `CraftingSystem` | `estacoesPerto` | Receitas ??? **não** entram em `Config/Receitas` (pública); a fabricação secreta é do `ArtifactResearchService`, com a mesma transação |
| Progression | Sim, `ProgressionSystem` | `ganharXp`, `nivel` | — |
| Companions | Sim, `CompanionSystem` | `ativa`, `ativaTemHabilidade` | **Não** foi criado outro sistema de criaturas; as capacidades investigativas leem as habilidades que as espécies já têm |
| Equipment | Sim, `EquipmentSystem` | `perfil.equipado` (leitura) | Equipamentos como fonte de capacidade |
| MovementAbilities / Flight | Sim | (só documentado) | Enigmas de Exploração usam a posição medida pelo servidor; nenhum código de voo foi tocado |
| Dimensions | Sim, `DimensionSystem` | **novo** `atravessarPara(p, destino)` | O teleporte foi extraído para uma função única; passagens secretas usam o mesmo caminho seguro |
| Restoration | Sim, `RestorationSystem` | (planejado: condição de portal/pista) | Não usado no protótipo |
| Livros | Sim, `MagicBookSystem` | `perfil.livrosLidos` (leitura) | Livro como fonte alternativa de capacidade |
| Segredos ??? do Ato 1 | Sim, `SecretDiscoverySystem` | Reaproveitado: `Segredos/Descoberta` (semente por jogador) | **Não foi substituído**: continua sendo a cadeia do Arco das Asas Perdidas |
| Artefatos metamórficos | Sim, `MetamorphicArtifactSystem` | Mesmo formato de config | Os 3 artefatos ??? usam o formato existente; **ainda não registrados** (ninguém consegue obtê-los nesta versão) |
| Serviço central de recompensas | **Não existe** como serviço separado | `InventorySystem.transacao` | Documentado como o caminho central; o `SecretRewardService` é o único que paga mistérios |

## Arquivos existentes alterados (com dependências identificadas)

| Arquivo | Mudança | Quem depende |
|---|---|---|
| `Dados/Perfil.luau` | Campo `misterios`, validação e migração de subcampos | Todos os sistemas que gravam o perfil (validação mais rígida só nesse campo) |
| `Sistemas/DimensionSystem.luau` | `teleportar` extraído e `atravessarPara` público | O portal comum continua com o mesmo comportamento |
| `Config/Materiais.luau` | 2 materiais de teste | Bolsa, fabricação |
| `Rede/Remotos.luau`, `Util/Mensagens.luau` | Evento "Misterio" e 1 mensagem | — |
| `ConfigServidor.luau` | Marcador da sala de teste | — |
| `Main.server`, `Main.client` | Carga dos novos módulos | — |

Nenhum mapa, modelo, a Ilha das Tempestades, o Campo das Bolhas ou a oficina original foi tocado.
