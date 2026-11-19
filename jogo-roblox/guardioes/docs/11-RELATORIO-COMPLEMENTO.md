# 11 · Relatório do complemento: o que foi feito, verificado e pendente

Data: 19/11/2026.

Este relatório cobre o complemento: criaturas, montarias, voo, raças, livros, transportes e artefatos.

## Em uma frase

A arquitetura unificada e os documentos estão completos. O **núcleo de locomoção e voo**, o **planador**, os **controles móveis** e a **Espada do Horizonte (espada ↔ prancha)** foram **escritos** de ponta a ponta: lógica pura, servidor e cliente. Os companheiros têm a lógica pura de dados, crescimento e Vínculo Dimensional. **Nada foi executado**: não houve Roblox Studio nem runtime Luau nesta sessão.

## 1. Estado anterior verificado antes de começar

- **Commit de partida:** `3aa407f`. Havia 2 sistemas de servidor (Combat e Enemy), 2 controladores no cliente e 7 specs.
- **Dependências reaproveitadas, sem duplicar:**
  - `Estamina` virou também a energia de voo;
  - `LimiteDeTaxa`, `Sinal`, `Remotos` e o padrão `Init`/`Start`;
  - o laço de 10 Hz do EnemySystem como modelo para a IA.
- **Arquivos preservados:**
  - Ilha das Tempestades, oficina, cristal, construções e Campo das Bolhas: **nenhum arquivo alterado**, porque todo o trabalho ficou dentro de `jogo-roblox/guardioes/`;
  - o modelo aprovado do Axolote V12 foi apenas **referenciado** na config da espécie, não modificado.

## 2. Arquivos realmente criados (45, contando este relatório)

| Arquivo | Linhas |
|---|---|
| `docs/07-COMPLEMENTO-CRIATURAS-VOO-ARTEFATOS.md` | 303 |
| `docs/08-ARQUITETURA-ESTADOS-CONTRATOS.md` | 150 |
| `docs/09-PLANO-ANIMACOES-EFEITOS.md` | 66 |
| `docs/11-RELATORIO-COMPLEMENTO.md` | 114 |
| `docs/10-TESTES-COMPLEMENTO.md` | 79 |
| `src/ReplicatedStorage/Guardioes/Artefatos/MaquinaDeArtefato.luau` | 99 |
| `src/ReplicatedStorage/Guardioes/Artefatos/ProgressaoDeArtefato.luau` | 65 |
| `src/ReplicatedStorage/Guardioes/Companheiros/Crescimento.luau` | 79 |
| `src/ReplicatedStorage/Guardioes/Companheiros/DadosDaCriatura.luau` | 100 |
| `src/ReplicatedStorage/Guardioes/Companheiros/VinculoDimensional.luau` | 90 |
| `src/ReplicatedStorage/Guardioes/Config/AfinidadesDimensionais.luau` | 64 |
| `src/ReplicatedStorage/Guardioes/Config/Armas/EspadaDoHorizonte.luau` | 18 |
| `src/ReplicatedStorage/Guardioes/Config/Artefatos/CajadoDosVentosAntigos.luau` | 25 |
| `src/ReplicatedStorage/Guardioes/Config/Artefatos/EscudoDoFirmamento.luau` | 28 |
| `src/ReplicatedStorage/Guardioes/Config/Artefatos/EspadaDoHorizonte.luau` | 47 |
| `src/ReplicatedStorage/Guardioes/Config/Especies/AxoloteNebular.luau` | 35 |
| `src/ReplicatedStorage/Guardioes/Config/Especies/CaoTrovao.luau` | 35 |
| `src/ReplicatedStorage/Guardioes/Config/Especies/LebreDeFaisca.luau` | 29 |
| `src/ReplicatedStorage/Guardioes/Config/Especies/RaiaDasNuvens.luau` | 41 |
| `src/ReplicatedStorage/Guardioes/Config/LivrosMagicos.luau` | 62 |
| `src/ReplicatedStorage/Guardioes/Config/Locomocao/Habilidades.luau` | 58 |
| `src/ReplicatedStorage/Guardioes/Config/Locomocao/Perfis.luau` | 80 |
| `src/ReplicatedStorage/Guardioes/Config/Locomocao/Regras.luau` | 32 |
| `src/ReplicatedStorage/Guardioes/Config/Racas.luau` | 67 |
| `src/ReplicatedStorage/Guardioes/Locomocao/FisicaDeVoo.luau` | 136 |
| `src/ReplicatedStorage/Guardioes/Locomocao/MaquinaDeLocomocao.luau` | 291 |
| `src/ReplicatedStorage/Guardioes/Locomocao/PerfilEfetivo.luau` | 82 |
| `src/ReplicatedStorage/Guardioes/Locomocao/ValidadorDeDeslocamento.luau` | 72 |
| `src/ReplicatedStorage/Guardioes/Util/Mensagens.luau` | 40 |
| `src/ServerScriptService/Guardioes/ConfigSecreta/ArcoDasAsasPerdidas.luau` | 34 |
| `src/ServerScriptService/Guardioes/ConfigSecreta/Livros.luau` | 25 |
| `src/ServerScriptService/Guardioes/Sistemas/MetamorphicArtifactSystem.luau` | 317 |
| `src/ServerScriptService/Guardioes/Sistemas/MovementAbilitySystem.luau` | 135 |
| `src/ServerScriptService/Guardioes/Sistemas/MovementSystem.luau` | 570 |
| `src/StarterPlayer/StarterPlayerScripts/Guardioes/Controladores/CameraDeVoo.luau` | 58 |
| `src/StarterPlayer/StarterPlayerScripts/Guardioes/Controladores/ControleDeLocomocao.luau` | 463 |
| `src/StarterPlayer/StarterPlayerScripts/Guardioes/Controladores/EfeitosDeVoo.luau` | 172 |
| `src/StarterPlayer/StarterPlayerScripts/Guardioes/Controladores/HudDeLocomocao.luau` | 86 |
| `src/StarterPlayer/StarterPlayerScripts/Guardioes/Controladores/TransformacaoDeArtefato.luau` | 238 |
| `tests/Specs/Artefatos.spec.luau` | 80 |
| `tests/Specs/Companheiros.spec.luau` | 126 |
| `tests/Specs/FisicaDeVoo.spec.luau` | 95 |
| `tests/Specs/MaquinaDeLocomocao.spec.luau` | 185 |
| `tests/Specs/PerfilEfetivo.spec.luau` | 44 |
| `tests/Specs/ValidadorDeDeslocamento.spec.luau` | 51 |

### Arquivos anteriores alterados (8, só acréscimos de integração)

| Arquivo | O que mudou |
|---|---|
| `Rede/Remotos.luau` | Mensagens `Locomocao` e `Artefato`; dois RemoteEvents novos |
| `ConfigServidor.luau` | `concessoesDeTeste` (habilidades e artefatos de TESTE, não salvos) e a pasta de zonas sem voo |
| `Main.server.luau` | Ordem de carga com os 3 sistemas novos |
| `Sistemas/CombatSystem.luau` | Guardas (`registrarGuarda`), sinal `jogadorAtingido`, `atordoado(p)` e `definirArma(p, arma)`. A arma escolhida sobrevive ao renascer |
| `Controladores/ControleDeCombate.luau` | Avisos de recusa pelo `Mensagens`; botões de toque de combate somem no voo |
| `Main.client.luau` | Ordem dos 7 controladores |
| `tests/Studio.luau`, `tests/rodar-lune.luau` | Módulos e specs novos |

## 3. Verificações que DE FATO rodaram aqui

| Verificação | Resultado |
|---|---|
| Equilíbrio de blocos (`function / if / do … end`) nos 70 arquivos `.luau` (script Python) | 0 problemas. Um falso positivo inicial era limitação do próprio verificador (`if` como expressão dentro de `[ ]`); o verificador foi corrigido |
| Todo `require(G.…)` aponta para arquivo existente | Ok |
| Todo `require` do executor Lune aponta para arquivo existente (módulos e 13 specs) | Ok |
| Valores esperados dos 47 casos novos | **Conferidos à mão** contra a lógica e as configs (por exemplo: 36 × 0,1 = 3,6; 32 − 30 × 0,5 = 17; 25 + 25 + 30 + 20 = 100) |

**Não houve** execução de Luau, checagem de tipos `--!strict`, nem teste no Studio. Os erros que só aparecem rodando continuam possíveis.

## 4. Pendente

### Precisa do Studio, ou de você

- [ ] Rodar os testes automáticos (34 casos antigos + 47 novos = 81) e os roteiros L1–L15 e A1–A8 (`10`).
- [ ] Confirmar os riscos técnicos do `08`, seção 6. O principal é o humanoide em queda livre "brigando" com a LinearVelocity.
- [ ] Autorizar o **Lune** nesta sessão, se quiser que os testes de lógica rodem aqui.
- [ ] Animações e modelos definitivos (`09`). Hoje só há peças provisórias e nenhuma ID.

### Próximas etapas de código

| Etapa | Falta |
|---|---|
| 6 | CompanionSystem + CompanionAI (servidor, 10 Hz, comportamento por espécie) + tela de companheiros |
| 7 | Ligar `Crescimento.evoluir` ao servidor e à persistência; trocar o modelo por estágio |
| 8 | MountSystem + MountController (terrestre: física própria; voadora: registrar o perfil da espécie com `montaria = true`) |
| 9 | MagicBookSystem: interação com o livro no mundo, conferência de `ConfigSecreta/Livros`, `conceder` e salvar |
| 10 | Ligar o Vínculo Dimensional aos eventos de missão (QuestSystem) |
| 11 | Formas de combate do Cajado e do Arco (armas do Arcanista e do Patrulheiro); Escudo como defesa real |
| 12 | Persistência real (PlayerDataSystem), inventário com GUID e transação atômica de estágio |
| 13 e 14 | Testes multiplayer e de desempenho; marcadores nos mapas reais (`10`, seções 4 e 5) |
