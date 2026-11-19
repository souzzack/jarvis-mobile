# 14 · Relatório: fabricação, restauração e o primeiro chefe (sem o Studio)

Data: 19/11/2026. **Nada foi executado** no Studio nem em runtime Luau.

## 1. O que foi feito

| Área | Entrega |
|---|---|
| **Fabricação** | Estações por marcador (a do teste fica ao lado da arena; os modelos aprovados não são tocados). Prompt "Fabricar" abre a janela com as receitas **conhecidas** e o que falta. O servidor confere receita, estação a até 12 studs, requisitos e materiais, e consome e entrega **numa só transação**. Receitas: **Liga Arcana** e **Escudo do Firmamento Druida**; esta segunda só depois do esboço |
| **Restauração** | Oficina, Observatório e Torre, por jogador, com etapas. A entrega parcial vale; o pagamento e o progresso vão na mesma gravação. **Ajuda cooperativa:** quem entregou ao menos 25% da etapa conclui junto com o vizinho. A estrutura restaurada destrava receitas, livros e missões. Quando a maioria dos presentes restaurou, uma marca global fica disponível para visuais futuros |
| **Rainha-Bobina** | Primeiro miniboss, com a IA comum mais **3 fases de carga** (75%, 50%, 25%): fica imune, surgem 3 pilares e há 12 s para quebrá-los. Se der certo, ela fica atordoada (+30% de dano); se não, **descarga** de 45 em toda a arena, que dá para esquivar ou aparar. Com a arena vazia por 20 s, ela reseta. Volta em 300 s |
| **Recompensas** | Glândula de Bobina Viva (material Druida), XP, missão e **Esboço Druida na primeira vitória** de cada participante (quem fez ao menos 10% do dano) |
| **Missões novas** | *A fornalha dos inventores* (restaurar), *A liga dos inventores* (fabricar), *A Rainha da caverna* (derrotar) |
| **Cliente** | Janela de fabricação; avisos de restauração e de ajuda; barra do chefe (azul quando imune), contagem da carga e avisos de descarga e de sucesso |

**O que esta rodada destrava:**
- A **Liga Arcana**, usada no estágio 3 da Espada e na Torre, agora tem origem real.
- A restauração do **Observatório e da Torre**, exigida pelos livros, agora existe.
- O **Escudo Druida** sai da Rainha, como pede o GDD.

## 2. Arquivos criados nesta rodada

| Arquivo | Linhas |
|---|---|
| `src/ReplicatedStorage/Guardioes/Chefes/CargaDaRainha.luau` | 54 |
| `src/ReplicatedStorage/Guardioes/Config/Inimigos/PilarDeCristal.luau` | 18 |
| `src/ReplicatedStorage/Guardioes/Config/Inimigos/RainhaBobina.luau` | 24 |
| `src/ReplicatedStorage/Guardioes/Config/Receitas.luau` | 33 |
| `src/ReplicatedStorage/Guardioes/Config/Restauracoes.luau` | 48 |
| `src/ReplicatedStorage/Guardioes/Fabricacao/Receita.luau` | 50 |
| `src/ReplicatedStorage/Guardioes/Restauracao/Restauracao.luau` | 90 |
| `src/ServerScriptService/Guardioes/Sistemas/BossSystem.luau` | 210 |
| `src/ServerScriptService/Guardioes/Sistemas/CraftingSystem.luau` | 194 |
| `src/ServerScriptService/Guardioes/Sistemas/RestorationSystem.luau` | 232 |
| `src/StarterPlayer/StarterPlayerScripts/Guardioes/Controladores/HudDeChefe.luau` | 99 |
| `src/StarterPlayer/StarterPlayerScripts/Guardioes/Controladores/JanelaDeFabricacao.luau` | 171 |
| `tests/Specs/FabricacaoRestauracaoChefe.spec.luau` | 104 |

**Arquivos existentes com acréscimos:**
- **Sistemas:** `EnemySystem` (API de chefe e mecanismo, "Imune", sem renascer quando não há retorno), `InventorySystem` (entregas e `alterarPerfil` na transação), `QuestSystem` (restaurar e fabricar).
- **Dados e configurações:** `Dados/Perfil` (receitas e progresso de restauração), `Config/Materiais`, `Config/Loot`, `Config/Missoes`, `ConfigServidor` (marcadores e chefe de teste).
- **Rede e carga:** `Remotos` (Fabricacao, Restauracao, Chefe), `Main.server`, `Main.client`.
- **Testes e docs:** executores de teste, docs 08, 10 e README.

**Fora de `jogo-roblox/guardioes/`:** nada.

## 3. Verificado aqui

| Verificação | Resultado |
|---|---|
| Equilíbrio de blocos nos 109 arquivos `.luau` | 0 problemas |
| `require` apontando para arquivos existentes; sistemas e controladores pedidos por `obter` na ordem de carga | Ok |
| Valores dos 8 casos novos | Conferidos à mão. Exemplos: etapa 2 da Oficina com 6 de 7 entregues = fração 6/7; a ajuda exige exatamente 25%; as cargas não se sobrepõem e são no máximo três |

O Lune continua indisponível (bloqueado pelo ambiente). Os testes não foram executados.

## 4. Pendente

- **Studio:** roteiros F1 a F5 e B1 a B7 (`10`, seção 8), além dos anteriores; e os 123 casos automáticos.
- **Desvio provisório:** a receita Druida usa a Oficina até a **Forja da base pessoal** existir.
- **Próximas etapas:**
  - base pessoal (terrenos do tycoon viram parcelas);
  - os outros minibosses (Cão-Trovão Alfa, Colosso, Espectro) e o Guardião da Tormenta;
  - viagem rápida e portais;
  - Companhias (guildas);
  - SecretDiscoverySystem (???).
- **Arte e áudio:** modelos e efeitos da Rainha, dos pilares e das estações. Hoje são blocos provisórios.
