# 19 · Relatório: EquipmentSystem (sem o Studio)

Data: 19/11/2026. **Nada foi executado** no Studio nem em runtime Luau.

## O que foi feito

| Área | Entrega |
|---|---|
| **Encaixes** (GDD 7.4) | Cabeça, Corpo, Pernas, Acessório 1 e Acessório 2. A arma continua sendo o artefato equipado; a relíquia fica para depois |
| **Itens** | GUID em `perfil.equipamentos`, criados só pelo servidor (fabricação). A validação do perfil recusa item inexistente equipado e o mesmo item em dois encaixes |
| **Atributos** | Base × multiplicador da raridade (orçamento de poder), com tetos globais: defesa 120, vida +200, aparo +0,08 s, energia +40 |
| **Efeitos ligados** | Defesa → mitigação no `CombatSystem` (antes era 0 fixo); aparo extra → janela de aparo; vida → `ProgressionSystem`; energia de voo → `MovementSystem` (aplica na hora, sem dar energia de graça) |
| **Catálogo** | Comuns: Capuz e Botas de Viajante (Forja 1). Druida: **Elmo da Matilha** (Alfa: defesa e aparo mais tolerante), **Couraça das Ruínas** (Colosso: defesa e vida), **Amuleto Espectral** (Espectro: energia de voo). Os três pedem a **Forja nível 3** e são liberados pelo **esboço da primeira vitória**, como no GDD 7.3 |
| **Interface** | Seção "Equipamentos" na Bolsa (I): itens, atributos, efeito, Equipar/Retirar e totais |

**Isto fecha a pendência do relatório 18:** os materiais Druida do Alfa, do Colosso e do Espectro agora viram itens de verdade.

## Arquivos criados

| Arquivo | Linhas |
|---|---|
| `src/ReplicatedStorage/Guardioes/Config/Equipamentos.luau` | 19 |
| `src/ReplicatedStorage/Guardioes/Equipamento/Equipamento.luau` | 64 |
| `src/ServerScriptService/Guardioes/Sistemas/EquipmentSystem.luau` | 147 |
| `tests/Specs/Equipamento.spec.luau` | 51 |

**Arquivos existentes com acréscimos:**
- **Sistemas:** `CombatSystem` (defesa e aparo do equipamento), `ProgressionSystem` (vida extra), `MovementSystem` (energia extra), `InventorySystem` (`darEquipamento` na transação), `CraftingSystem` (resultado "equipamento"), `BossSystem` (os três esboços).
- **Dados e configurações:** `Dados/Perfil` (equipamentos e encaixes), `Config/Receitas`.
- **Rede, cliente e carga:** `Remotos`, `Mensagens`, `HudDeProgresso`, `Main.server`.
- **Testes e docs:** executores de teste, docs 10 e README.

**Fora de `jogo-roblox/guardioes/`:** nada.

## Verificado aqui

- Equilíbrio de blocos nos 138 arquivos: 0 problemas.
- Todos os sistemas estão na ordem de carga; `require` e RemoteEvents conferidos.
- 5 casos novos conferidos à mão. Exemplo: o conjunto completo dá defesa 48,02 → 48, vida 42,6 → 43, energia 21,3 → 21.

O Lune continua bloqueado pelo ambiente.

## Pendente

- Melhoria +1 a +10 dos equipamentos (teto já definido em `Raridades.tetoMelhoria`).
- Equipamentos Lendário e Épico vindos de elites e baús.
- Relíquia.
- Visual das armaduras no personagem.
- Roteiro Q1 a Q8 no Studio.
