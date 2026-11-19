# 06 · Relatório: o que foi feito e o que falta

Data: 19/11/2026.

## Em uma frase

A auditoria, o design, a arquitetura, a migração e o plano de testes estão escritos. O protótipo de combate está **escrito** (servidor, cliente, configurações e testes), mas **não foi executado**: não houve Roblox Studio nem runtime Luau nesta sessão.

## 1. Concluído (de verdade)

| Entrega | Arquivo | Observação |
|---|---|---|
| 1. Inventário e avaliação de reaproveitamento | `docs/00-AUDITORIA.md` | Feito a partir do repositório e do histórico. O código do tycoon **não está no repositório**: só existe no place v20. |
| 2. Documento de design | `docs/01-GDD.md` | Premissa, pilares, combate, criaturas, as 8 raridades, fabricação, companhias, dimensões, restauração e bases. |
| 3. Arquitetura modular | `docs/02-ARQUITETURA.md` | 14 sistemas com responsabilidades e dependências, rede, persistência e desempenho. |
| 4. Estrutura de diretórios | `src/`, `tests/`, `default.project.json` | Layout do Rojo. |
| 5. Plano de migração do tycoon | `docs/04-MIGRACAO-TYCOON.md` | Coexistência, esquema v1 → v2, nada é apagado. |
| 6. Primeira implementação do combate | `src/**`, explicada em `docs/03-PROTOTIPO-DE-COMBATE.md` | **Escrita, não executada.** |
| 7. Plano de testes no Studio | `docs/05-PLANO-DE-TESTES-STUDIO.md` | Solo, multiplayer, segurança, celular e coexistência. |
| 8. Este relatório | `docs/06-RELATORIO.md` | — |
| Testes automáticos | `tests/` | 7 specs dos módulos puros, que rodam no Studio ou no Lune. **Não executados.** |

### Verificações que de fato rodaram aqui

- **Blocos:** uma checagem estática (script Python) do equilíbrio de `function / if / do … end` nos 30 arquivos `.luau` não achou nenhum problema.
- **`require`:** todos os `require(G.…)` apontam para arquivos que existem.
- **Rojo:** o `default.project.json` é um JSON válido.
- **Testes:** os valores esperados foram conferidos à mão contra as configurações.

Isso **não substitui** a execução real. Erros de tipo do `--!strict` e erros de execução só aparecem no Studio ou no Lune.

### Correções de design feitas durante o trabalho

- **Teto de melhoria (+10).** A regra "raridade seguinte × 0,96" deixava o Arcano com teto 1,4976, **abaixo** do próprio Arcano (1,50). A regra nova cobre metade do salto até a próxima raridade, e o GDD 7.2 foi atualizado.
- **Ataque pesado.** Ele passou a ter botão próprio (R / Y / toque), em vez de "segurar o ataque", para o golpe leve não esperar. O GDD 5.1 foi atualizado.
- **Texto do GDD.** Ele dizia que os saltos de raridade "diminuem", o que não era verdade em toda a tabela. O texto foi corrigido.

## 2. Preservado (REGRA ZERO)

| Item | Situação |
|---|---|
| Ilha das Tempestades, Oficina, cristal, animações e construções | **Nada alterado.** Nenhum arquivo fora de `jogo-roblox/guardioes/` foi modificado nesta reformulação. |
| Campo das Bolhas | **Congelado.** O commit `8adae7a` guarda o estado exato do trabalho em andamento, e nenhum arquivo dele foi tocado depois. |
| Tycoon (place v20) | Intocado: ele não está no repositório, e o plano manda fazer o backup `.rbxl` antes de qualquer sincronização. |
| Backup versionado | O histórico do git. O ponto de restauração antes da reformulação é o `8adae7a`. |

**Sobre a branch.** Esta sessão só tem permissão de enviar para `claude/intelligent-cerf-lfd2d7`. Por isso a área isolada é a pasta `jogo-roblox/guardioes/`. Se quiser uma branch separada, é só autorizar.

## 3. Pendente

### Precisa de você ou do Studio

- [ ] Rodar o `05-PLANO-DE-TESTES-STUDIO.md` e mandar o que falhar.
- [ ] Fazer a auditoria do tycoon dentro do Studio (`04`, seção 6). Ela é necessária para escrever a migração de dados real.
- [ ] Mandar os IDs das animações de combate quando forem publicadas. Nenhuma ID foi inventada.
- [ ] (Opcional) Autorizar a instalação do **Lune** nesta sessão. Com ele, os testes de lógica rodam aqui e os resultados viram fatos. A instalação foi bloqueada pela política de permissões.

### Próximas etapas de código

| Etapa | Conteúdo |
|---|---|
| C (resto) | Troca manual de alvo (Tab ou toque), animações reais e efeitos visuais definitivos do arco e do impacto |
| D | PlayerDataSystem (trava de sessão, esquema v2, migração), ProgressionSystem, InventorySystem; o multiplicador de dano passa a vir de atributos e equipamento |
| E | LootSystem (proteção contra azar), BossSystem e o primeiro miniboss (Rainha-Bobina) |
| F | CraftingSystem e a Oficina dos Inventores como estação |
| G | QuestSystem e DimensionSystem |
| H | RestorationSystem, PersonalBaseSystem e a migração dos terrenos, do galpão e dos funcionários |
| I | CompanySystem e SecretDiscoverySystem (a raridade ???, sem Robux e sem depender só de sorte) |

## Atualização: complemento oficial (criaturas, voo e artefatos)

O que foi feito, verificado e pendente no complemento está em [`11-RELATORIO-COMPLEMENTO.md`](11-RELATORIO-COMPLEMENTO.md).
