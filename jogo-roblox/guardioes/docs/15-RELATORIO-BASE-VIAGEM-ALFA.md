# 15 · Relatório: base pessoal, viagem rápida e Cão-Trovão Alfa (sem o Studio)

Data: 19/11/2026. **Nada foi executado** no Studio nem em runtime Luau (o Lune continua bloqueado pelo ambiente).

## 1. O que foi feito

| Área | Entrega |
|---|---|
| **Base pessoal** | Uma parcela por jogador no servidor (no place real, os terrenos do tycoon recebem um atributo, sem trocar modelo). Os níveis ficam **salvos no perfil**, então a base volta igual em qualquer parcela ou servidor. **Forja** (níveis 1 a 5) é a estação da base: só o dono usa, e o nível conta para as receitas. **Jardim** (níveis 1 a 3) produz Sementes Flutuantes e Cascas Antigas com o tempo, inclusive fora do jogo, até um teto de 12; colher duas vezes ao mesmo tempo não duplica. O **Expositor** mostra troféus dos chefes. Melhorar consome materiais e sobe o nível na mesma transação |
| **Viagem rápida** | Pontos descobertos ao chegar perto (salvos), mais "Minha base". Só se viaja a pé, sem dano nos últimos 8 s e com recarga de 30 s; a conferência de movimento é reancorada no destino. Janela com M ou aba na tela |
| **Cão-Trovão Alfa** | Segundo miniboss. Chama a matilha (2 cães) em 70% e 40%. A cada cerca de 14 s corre **carregado e imune** por 4 s; **só aparar** um golpe dele quebra a corrida e o derruba por 4 s. Ensina o aparo, como pede o GDD |
| **BossSystem** | Generalizado: cada chefe declara a sua mecânica. Corrigido também: a barra do segundo chefe não aparecia para quem já tinha visto o primeiro |
| **Receita Druida** | Agora no lugar do GDD (**Forja da base nível 3**). O desvio provisório da rodada anterior foi removido |
| **Missões novas** | *O Alfa da matilha* e *Fogo na forja* (Forja nível 3) |

**Caminho completo até o primeiro equipamento Druida:**
1. Vencer o Alfa, que dá a Juba.
2. Levar a Forja ao nível 3.
3. Vencer a Rainha, que dá o Esboço e as Glândulas.
4. Colher Sementes e Cascas no Jardim.
5. Fabricar o Escudo do Firmamento Druida.

## 2. Arquivos criados nesta rodada

| Arquivo | Linhas |
|---|---|
| `src/ReplicatedStorage/Guardioes/Base/Base.luau` | 69 |
| `src/ReplicatedStorage/Guardioes/Chefes/MatilhaDoAlfa.luau` | 53 |
| `src/ReplicatedStorage/Guardioes/Config/Base.luau` | 45 |
| `src/ReplicatedStorage/Guardioes/Config/Inimigos/CaoDaMatilha.luau` | 20 |
| `src/ReplicatedStorage/Guardioes/Config/Inimigos/CaoTrovaoAlfa.luau` | 23 |
| `src/ReplicatedStorage/Guardioes/Viagem/Viagem.luau` | 40 |
| `src/ServerScriptService/Guardioes/Sistemas/DimensionSystem.luau` | 207 |
| `src/ServerScriptService/Guardioes/Sistemas/PersonalBaseSystem.luau` | 350 |
| `src/StarterPlayer/StarterPlayerScripts/Guardioes/Controladores/JanelaDeViagem.luau` | 148 |
| `tests/Specs/BaseViagemAlfa.spec.luau` | 94 |

**Arquivos existentes com acréscimos:**
- **Sistemas:** `BossSystem` (mecânicas, troféus, aviso por chefe), `CraftingSystem` (nível e dono da estação), `EnemySystem` (sinal `aparado`), `QuestSystem`.
- **Lógica e dados:** `Fabricacao/Receita` (nível da estação), `Dados/Perfil` (base e pontos descobertos), configs de receitas, materiais, saque, missões e servidor.
- **Rede, cliente e carga:** `Remotos` (Base, Viagem e eventos novos de chefe), `HudDeChefe`, `Mensagens`, `Main.server`, `Main.client`.
- **Testes e docs:** executores e specs, docs 04, 08, 10 e README.

**Fora de `jogo-roblox/guardioes/`:** nada.

## 3. Verificado aqui

| Verificação | Resultado |
|---|---|
| Equilíbrio de blocos nos 119 arquivos `.luau` | 0 problemas |
| `require`, ordem de carga (servidor e cliente) e nomes de RemoteEvent usados existem | Ok |
| Valores dos 8 casos novos | Conferidos à mão. Exemplos: Jardim nível 1 em 3000 s = 2 itens e o relógio vai a 2400 s; nível 2 em 10 h = teto 12; a corrida do Alfa começa em 14 s e acaba em 33 s, e a próxima fica para 47 s |

## 4. Pendente

- **Studio:** roteiros H1 a H8 e A1 a A6 (`10`, seção 9), além dos anteriores; e os 130 casos automáticos.
- **Ainda não feito:**
  - Bancada e Depósito da base;
  - posicionamento livre (fase 2);
  - servidor de bases ou instância própria;
  - Colosso das Ruínas e Espectro do Observatório;
  - Guardião da Tormenta;
  - portais entre places;
  - Companhias;
  - SecretDiscoverySystem.
- **Arte:** os visuais da base, do Alfa e dos cães ainda são blocos provisórios.
