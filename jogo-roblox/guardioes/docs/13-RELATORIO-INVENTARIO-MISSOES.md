# 13 · Relatório: inventário, saque, missões, progressão e armas (sem o Studio)

Data: 19/11/2026. **Nada foi executado** no Studio nem em runtime Luau.

## 1. Tentativa de rodar os testes aqui

Tentei de novo obter o **Lune** (runtime de Luau fora do Roblox) para executar os testes. Primeiro testei os downloads: GitHub e crates.io responderam 403 pelo proxy da rede. Depois, a busca nos registros de pacotes (cargo, pip, npm) foi **barrada pelo classificador de permissões** desta sessão. Não contornei o bloqueio. Os testes continuam escritos e conferidos à mão.

## 2. O que foi feito

| Área | Entrega |
|---|---|
| Correção | **Previsão de golpes no cliente.** O servidor agora envia a arma ativa ao dono (`EventoCombate.ARMA`). Antes, o cliente previa sempre com os tempos da Espada comum, o que gerava recusas "cedo" com a Espada do Horizonte |
| Inventário | **InventorySystem.** Materiais e artefatos com GUID, numa bolsa salva e numa de teste. A transação atômica consome materiais e muda o estágio juntos. Itens só nascem no servidor |
| Artefatos | **Os artefatos vêm do inventário** (salvos de verdade quando não são de teste), com **Equipar** (só a pé) e **Evoluir** (missões, desafios e materiais conferidos no servidor). O artefato equipado também é salvo |
| Saque | **LootSystem.** Saque pessoal (quem fez ao menos 10% do dano), proteção contra azar (o Núcleo de Tempestade cai garantido em até 15 derrotas) e XP por inimigo |
| Missões | **QuestSystem.** 5 missões da Ilha, com aceite automático. Os eventos vêm do servidor (derrotar, derrotar com criatura, ler, voar, planar). As recompensas são XP, materiais, marco da criatura e objetivo dimensional (liga a Etapa 10). Não há pagamento duplo |
| Progressão | **ProgressionSystem.** Nível de 1 a 60 salvo, curva de XP e vida máxima por nível e raça (Alado −8%); subir de nível cura |
| Armas | **Cajado dos Ventos** (Arcanista: médio alcance, arco largo, mais postura) e **Arco das Asas** (Patrulheiro, tiro de longo alcance, **só no servidor** por ser ???) |
| Criaturas | A Raia adulta solta **Pena de Raia** às vezes, quando afagada (material do estágio 3 da Espada) |
| Interface | **HudDeProgresso**: nível e XP, rastreador de missões, avisos de saque e a janela **Bolsa** (tecla I ou aba na tela) com Equipar e Evoluir e o que falta |

## 3. Arquivos criados nesta rodada

| Arquivo | Linhas |
|---|---|
| `src/ReplicatedStorage/Guardioes/Config/Armas/CajadoDosVentos.luau` | 16 |
| `src/ReplicatedStorage/Guardioes/Config/Loot.luau` | 17 |
| `src/ReplicatedStorage/Guardioes/Config/Materiais.luau` | 19 |
| `src/ReplicatedStorage/Guardioes/Config/Missoes.luau` | 57 |
| `src/ReplicatedStorage/Guardioes/Inventario/Bolsa.luau` | 82 |
| `src/ReplicatedStorage/Guardioes/Loot/Saque.luau` | 51 |
| `src/ReplicatedStorage/Guardioes/Missoes/Missao.luau` | 45 |
| `src/ReplicatedStorage/Guardioes/Progressao/Nivel.luau` | 35 |
| `src/ServerScriptService/Guardioes/Sistemas/InventorySystem.luau` | 213 |
| `src/ServerScriptService/Guardioes/Sistemas/LootSystem.luau` | 53 |
| `src/ServerScriptService/Guardioes/Sistemas/ProgressionSystem.luau` | 106 |
| `src/ServerScriptService/Guardioes/Sistemas/QuestSystem.luau` | 162 |
| `src/StarterPlayer/StarterPlayerScripts/Guardioes/Controladores/HudDeProgresso.luau` | 253 |
| `tests/Specs/Inventario.spec.luau` | 130 |

**Arquivos existentes com acréscimos:**
- **Servidor:** `Remotos` (3 RemoteEvents novos e tipos novos), `CombatSystem` (envio da arma), `MetamorphicArtifactSystem` (inventário, equipar, evoluir), `CompanionSystem` (pena), `MagicBookSystem` (sinal `lido`), `ConfigServidor` (materiais e Cajado de teste).
- **Dados e configurações:** `Dados/Perfil` (campos e validação novos), `ConfigSecreta/ArcoDasAsasPerdidas` (arma), `Racas` (vida do Alado).
- **Cliente:** `ControleDeCombate` (recebe a arma), `Main.server`, `Main.client`.
- **Testes e docs:** executores de teste, docs 08, 10 e README.

**Fora de `jogo-roblox/guardioes/`:** nada.

## 4. Verificado aqui

| Verificação | Resultado |
|---|---|
| Equilíbrio de blocos nos 96 arquivos `.luau` | 0 problemas |
| Todos os `require` apontam para arquivos existentes | Ok |
| Todo sistema pedido por `ctx.obter` está na ordem de carga do servidor | Ok |
| Valores dos 12 casos novos conferidos à mão | Exemplos: `xpParaProximo(4) = 800`; de 250 XP no nível 1 sobra 150 no nível 2; vida no nível 10 com Alado = 125; o raro cai garantido na 3ª tentativa com o contador zerado |

## 5. Pendente

- **Studio:**
  - rodar os 116 casos automáticos e os roteiros P1 a P11, C1 a C15, L1 a L15 e A1 a A8;
  - confirmar os riscos listados no `08`.
- **Ainda não feito:**
  - **Fabricação (CraftingSystem):** a Liga Arcana ainda não tem como ser fabricada; hoje vem só dos materiais de teste.
  - **Restauração (RestorationSystem)** e missões de história que dependem dela.
  - **BossSystem** (Rainha-Bobina…) e projétil físico do Arco.
  - Contador de azar salvo entre sessões.
  - Maestria de arma e afinidade do jogador por dimensão.
- **Arte e áudio:** modelos, animações e sons definitivos.
