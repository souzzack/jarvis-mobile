# 16 · Conferência do prompt complementar, item por item (19/11/2026)

O prompt complementar foi reenviado **igual** ao já implementado (`07` a `15`). Nada foi refeito. Este documento confere cada exigência contra o código real e registra o que esta rodada acrescentou para fechar as lacunas.

**Legenda:**
- ✅ **escrito:** existe no código; **não executado**, porque não há Studio nem Lune nesta sessão.
- 🟡 **parcial**
- ⏳ **planejado**

## Sistemas 1 a 16

| Exigência | Situação | Onde |
|---|---|---|
| **1. Criaturas companheiras** com GUID, espécie, nome, estágio, XP, vínculo, habilidades, afinidade, cosmético, estado e salvamento | ✅ | `Companheiros/DadosDaCriatura`, `CompanionSystem`, `perfil.companheiros` |
| 1. **Atributos** | ✅ **nesta rodada.** Derivados de papel × estágio × vínculo; usados no dano e mostrados no cartão | `Crescimento.atributos` |
| 1. Comandos acompanhar, permanecer, retornar e montar | ✅ | T / V e o painel |
| 1. Comportamento diferente por espécie | ✅ | `IADoCompanheiro` + `comportamento` da espécie |
| 1. Ajudar na **coleta** e **descobrir áreas escondidas** | ✅ **nesta rodada.** Farejadoras dão 30% de chance de +1 material no saque; habilidades revelam trilhas e correntes escondidas só para o dono | `LootSystem`, `CompanionSystem` (REVELAR) |
| **2. Evolução** em 3 estágios, sem depender só de tempo nem de compra, salva | ✅ | `Crescimento`, EVOLUIR |
| 2. Modelos e animações por estágio | 🟡 | Planejados (`09`); hoje o visual é provisório e só muda a escala |
| **3. Vínculo Dimensional** por objetivos, reversível com ritual, extensível por config | ✅ | `VinculoDimensional`, `AfinidadesDimensionais`, recompensas de missão |
| **4. Montarias** terrestres e voadoras, com as 8 verificações | ✅ | `MountSystem`, `MovementSystem.montar` |
| **5. Voo cinematográfico**: 8 estados, física, câmera estabilizada, efeitos por qualidade, energia, altitude, servidor | ✅ | `MaquinaDeLocomocao`, `FisicaDeVoo`, `MovementSystem`, controladores |
| 5. Animações e sons originais | ⏳ | Plano em `09` (sem IDs inventadas; som provisório do próprio Roblox) |
| **6. Raças** com vantagens, limitações e habilidades | ✅ | `Config/Racas` |
| 6. **Escolha** de raça | ✅ **nesta rodada.** Janela na primeira entrada, troca livre até o nível 5 (valores provisórios) | `RaceSystem`, `JanelaDoPersonagem` |
| **7. Livros mágicos**: requisitos no servidor, aprendizado salvo | ✅ | `MagicBookSystem`, `ConfigSecreta/Livros` |
| 7. **Tela de livros descobertos** | ✅ **nesta rodada.** Ocultos aparecem como "???" | `JanelaDoPersonagem` |
| 7. Bibliotecas nos mapas reais | ⏳ | Posições planejadas (`07`, seção 7); nenhum mapa tocado |
| **8A. Planador** | ✅ | perfil Planador |
| 8A. **Correntes de ar** | ✅ **nesta rodada.** Marcadores `GuardioesCorrente`; a Raia revela a corrente | `ControleDeLocomocao.correnteEm` |
| 8B. Pranchas mágicas | 🟡 | Como forma de artefato ✅; prancha **comum** (item de transporte simples) ⏳ |
| 8C. Montarias / 8D. Artefatos de locomoção | ✅ | — |
| 8E. Viagem rápida | ✅ | `DimensionSystem` |
| 8E. Portais entre dimensões | ⏳ | Precisa de um segundo place |
| **9 a 11. Artefatos metamórficos** (4 iniciais, formas, troca, recarga, estágios) | ✅ | `MetamorphicArtifactSystem`, `ProgressaoDeArtefato` |
| 9. **Habilidades por forma** (especiais de armas e escudos) | ✅ **nesta rodada.** Linha de Relâmpago (Espada), Bastião (Escudo), Rajada Ascendente (Cajado), Flecha Estelar (Arco ???, só no servidor) | `SpecialAbilitySystem`, `Config/Especiais` |
| 11. Estágio 4 da Espada ("Corte em Voo") | ✅ **nesta rodada.** Da prancha, a especial volta à espada na hora e golpeia | `Especial.pode` (usoEmVoo), `forcarFormaDeCombate` |
| **12. Integração e conflitos impedidos** | ✅ | `08`, seção 3; guardas do combate; transações |
| **13. Arquitetura**: os 20 módulos | ✅ / 🟡 | Tabela no `08` (seções 1 e 7 a 10). EquipmentSystem: o encaixe da arma é o artefato equipado; armaduras ⏳ |
| **14. Interface** | ✅ / 🟡 | Criaturas, Bolsa, energia, botões contextuais, personagem (raça, habilidades, livros), viagem; gerenciar transporte ⏳ |
| **15. Desempenho e multiplayer** | ✅ (estratégias no código) | Testes reais pendentes (`10`, seção 4) |
| **16. Etapas 1 a 12** | ✅ | — |
| 16. Etapas 13 e 14 | ⏳ | Precisam do Studio |

## Arquivos criados nesta rodada

| Arquivo | Linhas |
|---|---|
| `src/ReplicatedStorage/Guardioes/Combate/Especial.luau` | 41 |
| `src/ReplicatedStorage/Guardioes/Config/Especiais.luau` | 54 |
| `src/ServerScriptService/Guardioes/Sistemas/RaceSystem.luau` | 84 |
| `src/ServerScriptService/Guardioes/Sistemas/SpecialAbilitySystem.luau` | 130 |
| `src/StarterPlayer/StarterPlayerScripts/Guardioes/Controladores/ControleDeEspecial.luau` | 137 |
| `src/StarterPlayer/StarterPlayerScripts/Guardioes/Controladores/JanelaDoPersonagem.luau` | 192 |
| `tests/Specs/EspeciaisAtributos.spec.luau` | 63 |

**Arquivos existentes com acréscimos:**
- **Sistemas:** `CombatSystem` (estamina e Bastião para especiais), `MetamorphicArtifactSystem` (`equipado`, `forcarFormaDeCombate`), `MovementAbilitySystem` (`definirRaca`), `CompanionSystem` (atributos, revelar), `LootSystem` (bônus de faro), `MagicBookSystem` (lista de livros).
- **Lógica, dados e rede:** `Crescimento` (atributos), `Remotos`, `Mensagens`, `ConfigServidor` (Lebre de teste, ocultos e corrente), `ConfigSecreta/ArcoDasAsasPerdidas` (especial).
- **Cliente:** `ControleDeLocomocao` (correntes), `PainelDeCompanheiros` (atributos, revelar), `Main.server`, `Main.client`.
- **Testes:** executores.

**Fora de `jogo-roblox/guardioes/`:** nada.

## Verificado aqui

| Verificação | Resultado |
|---|---|
| 126 arquivos `.luau`, equilíbrio de blocos | 0 problemas |
| `require`, ordem de carga, nomes de RemoteEvent | Ok |
| Todo sistema e controlador existente está na ordem de carga | Ok |
| 4 casos novos (`EspeciaisAtributos.spec`) conferidos à mão | Exemplo: Cão adulto com vínculo 7 = vida 137, dano 11 |

O Lune continua bloqueado pelo ambiente, e nada foi executado.

## Roteiro no Studio desta rodada (soma ao `10`)

| # | Passo | Esperado |
|---|---|---|
| X1 | Primeira entrada | A tela "Personagem" abre para escolher a raça. Escolher Alado: aparecem as Asas, o planador some e a vida cai 8% |
| X2 | Espada do Horizonte, tecla 1 | Avança cerca de 10 studs e acerta em linha; recarga de 8 s ("Aguarde a recarga") |
| X3 | Escudo equipado, 1 e depois levar um golpe de frente | Aura verde; o golpe vira "Aparado" por 1,5 s |
| X4 | Cajado, 1 | Pulo para cima e dano em volta |
| X5 | Espada no estágio 4, na prancha, 1 | Sai da prancha, a espada aparece na hora e o golpe sai (Corte em Voo) |
| X6 | Pipoca (Lebre adulta) ativa, perto de (-30, 2, 40) da arena | "Pipoca encontrou algo escondido!": uma trilha dourada aparece e dá para pisar (só para você) |
| X7 | Brisa (Raia) ativa, perto da coluna em (30, 20, 60) | A corrente aparece; planando dentro dela, o personagem sobe |
| X8 | Derrotar Faíscas com a Pipoca por perto | Às vezes vem 1 fragmento a mais |
| X9 | P → Livros | Grimório e Tomo com o requisito ou ✓; Manuscrito como "???" |
