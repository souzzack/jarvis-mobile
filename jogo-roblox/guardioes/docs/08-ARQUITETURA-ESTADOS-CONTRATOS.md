# 08 · Arquitetura do complemento: módulos, estados e contratos

> Atualiza o `02-ARQUITETURA.md` sem apagá-lo: os princípios de lá continuam valendo. Nada foi executado no Studio.

## 1. Os 20 módulos pedidos → onde estão

Regra: **sem módulos redundantes.**
- Voo, planador, prancha, plataforma, vassoura, asas e montaria voadora são **perfis** de **um** núcleo de física com **uma** máquina de estados.
- Por isso FlightSystem, GliderSystem e a parte de servidor do TransportSystem moram juntos no `MovementSystem`.

| Módulo pedido | Arquivo | Tipo | Situação |
|---|---|---|---|
| MovementStateMachine | `ReplicatedStorage/Guardioes/Locomocao/MaquinaDeLocomocao.luau` | lógica pura (servidor oficial + cópia no cliente) | **Escrito + testes** |
| FlightSystem | `ServerScriptService/Guardioes/Sistemas/MovementSystem.luau` (+ `Locomocao/FisicaDeVoo.luau`, `ValidadorDeDeslocamento.luau`, `PerfilEfetivo.luau`) | servidor + puro | **Escrito** (puro com testes) |
| FlightController | `StarterPlayerScripts/Guardioes/Controladores/ControleDeLocomocao.luau` | cliente | **Escrito** |
| FlightCamera | `Controladores/CameraDeVoo.luau` | cliente | **Escrito** |
| FlightEffects | `Controladores/EfeitosDeVoo.luau` | cliente | **Escrito** (som provisório) |
| GliderSystem | Perfil `Planador` em `MovementSystem` + `FisicaDeVoo` (modo sem motor) | servidor + puro | **Escrito** |
| MovementAbilitySystem | `Sistemas/MovementAbilitySystem.luau` | servidor | **Escrito** (memória de teste; persistência no contrato) |
| MetamorphicArtifactSystem | `Sistemas/MetamorphicArtifactSystem.luau` + `Artefatos/MaquinaDeArtefato.luau` | servidor + puro | **Escrito** (puro com testes) |
| ArtifactTransformationController | `Controladores/TransformacaoDeArtefato.luau` | cliente | **Escrito** (visual provisório) |
| ArtifactProgressionSystem | `Artefatos/ProgressaoDeArtefato.luau` (avaliação) + `MetamorphicArtifactSystem.avaliarEvolucao` | puro + servidor | **Avaliação escrita**; a troca de estágio depende do InventorySystem |
| TransportSystem | `Config/Locomocao/Perfis.luau` (dados) + `MovementSystem` (regras) | dados + servidor | **Parcial**: viagem rápida e seleção de transporte pendentes |
| RaceSystem | `Config/Racas.luau` + `MovementAbilitySystem.raca` | dados + servidor | **Parcial**: os efeitos fora da locomoção (vida, resistências) entram com o ProgressionSystem |
| MagicBookSystem | `Config/LivrosMagicos.luau` (público) + `ConfigSecreta/Livros.luau` (servidor) | dados | **Configs escritas**; sistema de leitura pendente (Etapa 9) |
| CompanionData | `Companheiros/DadosDaCriatura.luau` | puro | **Escrito + testes** |
| CompanionGrowthSystem | `Companheiros/Crescimento.luau` | puro | **Escrito + testes** (o sistema de servidor fica pendente) |
| DimensionalBondSystem | `Companheiros/VinculoDimensional.luau` + `Config/AfinidadesDimensionais.luau` | puro + dados | **Escrito + testes** |
| CompanionSystem | — | servidor | **Pendente** (Etapa 6): contrato na seção 4 |
| CompanionAI | — | servidor | **Pendente** (Etapa 6): mesmo laço de 10 Hz do EnemySystem, com os parâmetros de `comportamento` |
| MountSystem | — (a máquina já tem `montar`, `desmontar` e o voo de montaria) | servidor | **Pendente** (Etapa 8): contrato na seção 4 |
| MountController | — | cliente | **Pendente** (Etapa 8): reaproveita o `ControleDeLocomocao` com o perfil da espécie |

## 2. Estrutura de pastas (o que foi acrescentado)

```
src/ReplicatedStorage/Guardioes/
  Config/
    Locomocao/Regras.luau  Perfis.luau  Habilidades.luau     dados de locomoção
    Artefatos/EspadaDoHorizonte.luau  EscudoDoFirmamento.luau  CajadoDosVentosAntigos.luau
    Armas/EspadaDoHorizonte.luau                               forma de combate da espada
    Especies/AxoloteNebular.luau  LebreDeFaisca.luau  CaoTrovao.luau  RaiaDasNuvens.luau
    Racas.luau  LivrosMagicos.luau  AfinidadesDimensionais.luau
  Locomocao/  MaquinaDeLocomocao  FisicaDeVoo  PerfilEfetivo  ValidadorDeDeslocamento   (puros)
  Artefatos/  MaquinaDeArtefato  ProgressaoDeArtefato                                    (puros)
  Companheiros/  DadosDaCriatura  Crescimento  VinculoDimensional                       (puros)
  Util/Mensagens.luau                                          textos de requisito (sem segredos)
src/ServerScriptService/Guardioes/
  ConfigSecreta/ArcoDasAsasPerdidas.luau  Livros.luau          SÓ servidor (segredos ???)
  Sistemas/MovementAbilitySystem  MovementSystem  MetamorphicArtifactSystem
src/StarterPlayer/StarterPlayerScripts/Guardioes/Controladores/
  ControleDeLocomocao  CameraDeVoo  EfeitosDeVoo  HudDeLocomocao  TransformacaoDeArtefato
tests/Specs/  MaquinaDeLocomocao  FisicaDeVoo  PerfilEfetivo  ValidadorDeDeslocamento  Artefatos  Companheiros
```

**Separação:**
- **Configurações:** `Config/` (públicas) e `ConfigSecreta/` (servidor).
- **Lógica pura:** `Locomocao/`, `Artefatos/`, `Companheiros/`.
- **Servidor:** `Sistemas/`.
- **Cliente:** controles, câmera, efeitos e HUD em `Controladores/`.
- **Dados persistentes:** os formatos de `DadosDaCriatura` e o contrato do perfil (seção 4).

## 3. Estados e transições

### 3.1 Locomoção (`MaquinaDeLocomocao`)

```
 Solo ──decolar──▶ Decolagem ──(perfil.decolagem s)──▶ Pairar ◀──(sem/ com entrada)──▶ Voo ◀──impulso──▶ Impulso
  ▲ ▲                                                   │ pousar · tocar o chão (>0,3 s)          │
  │ └──(perfil.pouso s)── Pouso ◀──(tocou o chão)── Descida ◀────────────────────────────────────┘
  │                                                    ▲
  │                   Interrompido ──(duração)─────────┘     ◀── energia 0 · zona proibida · atordoado · golpe ≥ 12
  └──(tocou o chão)── Planando ◀──abrirPlanador── Solo no ar (altura ≥ 8) · Descida · Interrompido
 Solo ◀─desmontar / montar─▶ Montado ──decolar (perfil.montaria)──▶ Decolagem … Pouso ──▶ Montado
```

| Regra | Detalhe |
|---|---|
| Um modo por vez | `modo` = perfil ativo. `decolar` só a partir de Solo, Planando ou Montado (este só com perfil de montaria) |
| Ataque | Só em `Solo` (`podeAtacar`). A prancha nunca corta |
| Energia | Gasta em Decolagem, Pairar, Voo e Impulso. Recupera só em Solo ou Montado. Congela no ar sem motor |
| Descida | Não é interrompida por falta de energia (pousar é sempre possível) |
| Plataforma | Não pousa sozinha ao encostar; tem teto de altura sobre o chão |
| Renascer, desconectar ou teleporte do servidor | `reiniciar`: volta ao chão e solta a montaria |

### 3.2 Artefato (`MaquinaDeArtefato`)

```
 [forma A ativa] ──transformar(B)──▶ [trocando: nenhuma forma ativa] ──(duração)──▶ [forma B ativa] + recarga
                                         │ golpe ≥ limiar / atordoado
                                         └──cancelar──▶ [forma A ativa] + meia recarga
```

**Recusas:** formaInexistente · bloqueada (estágio) · transformando · jaNaForma · recarga. O sistema ainda pode recusar por posse, zona, espaço ou energia.

### 3.3 Companheiro

```
 Filhote ──(XP + vínculo + marcos)──▶ Juvenil ──(XP + vínculo + marcos + desafio)──▶ Adulto ──(afinidade ≥ limiar)──▶ Adulto especializado
                                                                                          ▲            │ ritual de realinhamento
                                                                                          └────────────┘
 Estado de uso: Acompanhando ⇄ Permanecendo ⇄ Guardada ;  Adulto montável: Acompanhando ⇄ Montada (liga com Montado da locomoção)
```

## 4. Contratos com os sistemas anteriores

**Já implementados** (o código chama estes pontos):

| Contrato | Quem expõe | Quem usa |
|---|---|---|
| `CombatSystem.registrarGuarda(fn(p) → (ok, motivo))` | Combate | Movimento (sem ataque fora do chão), Artefatos (troca, forma de locomoção) |
| `CombatSystem.jogadorAtingido` (sinal: p, dano, tipo) | Combate | Movimento (derruba do voo), Artefatos (cancela a troca) |
| `CombatSystem.atordoado(p)`, `CombatSystem.definirArma(p, arma)` | Combate | Movimento; Artefatos (forma de combate = arma) |
| `MovementAbilitySystem.tem / conceder / fontes / raca` | Habilidades | Movimento; no futuro, os livros |
| `MovementSystem.podeEntrarModo / entrarModoDeArtefato / sairModoDeArtefato / energia / gastarEnergia / registrarPerfil / registrarFonteDeMods / reancorar / estado` | Movimento | Artefatos; no futuro, montarias e portais |

**A implementar** nas próximas etapas (assinaturas definidas):

| Sistema | Contrato | Uso |
|---|---|---|
| **PlayerDataSystem** | `obter(p) → perfil`; `atualizar(p, fn)` (transação com trava de sessão); sinal `carregado(p)` | Campos novos no esquema v2: `habilidades {[id]=origem}`, `raca`, `livrosLidos {[id]=true}`, `companheiros {[guid]=Criatura}`, `artefatos {[guid]={id, estagio}}`, `criaturaAtiva`, `montariaPreferida` |
| **InventorySystem** | `possui(p, guid)`, `artefatos(p)`, `transacao(p, {consumir, alterar})`, que é **atômica** | Troca de estágio de artefato com consumo de materiais; GUID no lugar da concessão de teste |
| **EquipmentSystem** | `equipar(p, guid, encaixe)`, sinal `mudou(p)` | O artefato equipado define a arma e a forma; o escudo vai para o encaixe da outra mão |
| **ProgressionSystem** | `xpCompartilhada(p, quanto, origem)` → divide com a criatura ativa; modificadores de raça (vida, resistências) | Crescimento e raças |
| **QuestSystem** | Sinal `missaoConcluida(p, id)`, `concluiu(p, id)` | Livros, estágios de artefato, objetivos dimensionais, marcos |
| **LootSystem / CraftingSystem** | Materiais dos artefatos (Núcleo de Tempestade, Pena de Raia, Liga Arcana…) em tabelas e receitas | Estágio 3 dos artefatos |
| **DimensionSystem** | `liberada(p, dimensaoId)`; portal chama `MovementSystem.reancorar(p)` depois de teleportar | Afinidade disponível; viagem rápida |
| **SecretDiscoverySystem** | `revelar(p, segredoId)` | Manuscrito Sem Nome e receita do Arco das Asas Perdidas |
| **CompanionSystem** | `criaturas(p)`, `ativa(p)`, `comandar(p, guid, comando)`, `evoluir(p, guid)` (usa `Crescimento.evoluir` + PlayerData) | Interface; Montaria |
| **MountSystem** | `montar(p, guid)`: valida `Crescimento.podeMontar`, distância ≤ 12, espaço da espécie, e chama `MaqLoc.montar`; o perfil de voo da espécie é registrado com `MovementSystem.registrarPerfil({..., montaria = true})` | Montarias |

## 5. Rede (mensagens novas)

| RemoteEvent | Cliente → servidor (intenções) | Servidor → cliente |
|---|---|---|
| `Locomocao` | DECOLAR(perfilId) · POUSAR · IMPULSO(bool) · PLANADOR_ABRIR · PLANADOR_FECHAR | ESTADO · PERFIL (o perfil efetivo, só do dono) · ENERGIA (no máximo 5×/s) · REJEITADO · CORRECAO · HABILIDADES |
| `Artefato` | TRANSFORMAR(guid, forma) | INVENTARIO · REJEITADO · FORMA |

**Regras:**
- **Limites por jogador:** cada intenção passa por um balde de fichas próprio de cada sistema (locomoção: 10 fichas, recarga de 6/s; artefatos: 6 fichas, 3/s).
- **Nada de física pelo cliente:** posição, velocidade e perfil **nunca** vêm do cliente.
- **Estado visível para todos:** o que os outros jogadores precisam ver vai em **atributos do personagem**, que o Roblox já replica: `LocEstado`, `LocModo`, `LocEfeito`, `ArtefatoId`, `ArtefatoForma` e `ArtefatoAlvo`.

## 6. Riscos técnicos conhecidos (a confirmar no Studio)

1. **Controles a partir do humanoide.** O voo usa `Humanoid.MoveDirection` com `AutoRotate = false` e LinearVelocity (sem PlatformStand). É preciso confirmar que o humanoide não "briga" com a LinearVelocity no estado de queda livre.
2. **Tipagem estrita.** `require(G.Config...)` depende de o analisador do Studio resolver a árvore. Se não resolver, ele avisa sobre tipos, mas o código roda; a solução é usar caminhos com `script.Parent`.
3. **Detecção do chão.** A altura sobre o chão usa `HipHeight` + metade do HRP (R15). Personagens R6 ou escalados precisam de conferência.
4. **Validação a pé desligada** (`VALIDAR_A_PE = false`), para não quebrar teleportes do tycoon. Deve ser ligada depois da auditoria do tycoon.
5. **Som provisório.** O vento usa `rbxasset://sounds/action_falling.mp3`, um som que já vem com o Roblox. Ele precisa ser trocado por sons próprios.

## 7. Atualização: Etapas 6 a 9 (feita sem o Studio)

A tabela da seção 1 continua como registro histórico. A situação atual é esta:

| Módulo | Arquivo | Situação agora |
|---|---|---|
| **PlayerDataSystem** (do plano original) | `Sistemas/PlayerDataSystem.luau` + `Dados/Perfil.luau` + `Dados/TravaDeSessao.luau` | **Escrito** (lógica pura com testes) |
| CompanionSystem + CompanionAI | `Sistemas/CompanionSystem.luau` + `Companheiros/IADoCompanheiro.luau` | **Escrito** (IA pura com testes) |
| CompanionGrowthSystem | `Crescimento` ligado ao `CompanionSystem` (EVOLUIR, salvo) | **Escrito** |
| MountSystem | `Sistemas/MountSystem.luau` + `MovementSystem.montar/desmontar` | **Escrito** |
| MountController | `ControleDeLocomocao` (voo da montaria) + `PainelDeCompanheiros` (montar e desmontar) | **Escrito** |
| MagicBookSystem | `Sistemas/MagicBookSystem.luau` + `Util/Requisitos.luau` | **Escrito** (requisitos puros com testes) |
| Interface de companheiros | `Controladores/PainelDeCompanheiros.luau` | **Escrita** (painel recolhível, cartões e placas de nome) |

**Ordem de carga no servidor:** PlayerData → Enemy → Combat → MovementAbility → Movement → MetamorphicArtifact → Companion → Mount → MagicBook.

**Persistência:**
- **Já salvos:** habilidades (por origem), livros lidos, segredos revelados, criaturas (registro completo) e a criatura ativa.
- **Nunca salvo:** o que é de **teste**. A validação do perfil recusa habilidade com origem "teste", e as criaturas de teste não entram no perfil.
- **Artefatos:** continuam em memória até o InventorySystem existir.

**Rede nova:**
- `Companheiro`: ATIVAR, COMANDO, AFAGAR, RENOMEAR, EVOLUIR, ESPECIALIZAR → LISTA, REJEITADO, EVOLUIU.
- `Montaria`: MONTAR, DESMONTAR → REJEITADO, MONTADO.
- `Livro`: LIDO e RECUSADO. A leitura começa pelo ProximityPrompt no servidor.

**Riscos novos a confirmar no Studio:**
6. **Montaria:** o jogador "sobe" na sela aumentando `HipHeight`, com a criatura soldada embaixo, sem colisão e sem massa. É preciso conferir a aparência e se o personagem não flutua ou afunda.
7. **Movimento das criaturas:** usa `AlignPosition` sem desvio de obstáculos, então a criatura pode atravessar paredes. O PathfindingService entra quando houver mapa real para testar.
8. **DataStore no Studio:** precisa de *Enable Studio Access to API Services*. Sem isso, o sistema roda só em memória e avisa no Output.

## 8. Atualização: inventário, saque, missões, progressão e armas (sem o Studio)

| Sistema | Arquivo | Situação |
|---|---|---|
| **InventorySystem** | `Sistemas/InventorySystem.luau` + `Inventario/Bolsa.luau` | **Escrito.** Bolsa salva (perfil) + bolsa de teste (memória); `transacao` atômica (consumo + estágio) |
| **LootSystem** | `Sistemas/LootSystem.luau` + `Loot/Saque.luau` + `Config/Loot.luau` | **Escrito.** Saque pessoal (≥ 10% do dano) e proteção contra azar |
| **QuestSystem** | `Sistemas/QuestSystem.luau` + `Missoes/Missao.luau` + `Config/Missoes.luau` | **Escrito.** 5 missões; eventos de derrotar, derrotar com criatura, ler, voar e planar |
| **ProgressionSystem** | `Sistemas/ProgressionSystem.luau` + `Progressao/Nivel.luau` | **Escrito.** Nível 1 a 60, XP salva, vida por nível e raça (Alado −8%) |
| Artefatos: **equipar e evoluir** | `MetamorphicArtifactSystem` (EQUIPAR, EVOLUIR) | **Escrito.** Os artefatos agora vêm do inventário (salvos quando não são de teste) |
| Armas do Cajado e do Arco | `Config/Armas/CajadoDosVentos.luau`; arma do Arco em `ConfigSecreta/ArcoDasAsasPerdidas.luau` | **Escritas** (o Arco é tiro instantâneo de longo alcance, sem projétil físico no protótipo) |
| Correção | `CombatSystem.definirArma` envia `EventoCombate.ARMA` ao dono | A previsão do cliente passou a usar os tempos da arma **real**. Antes, usava sempre os da Espada comum, e o servidor recusava golpes da Espada do Horizonte como "cedo" |

**Ordem de carga:** PlayerData → Enemy → Combat → MovementAbility → Movement → Inventory → MetamorphicArtifact → Companion → Mount → Progression → MagicBook → Loot → Quest.

**Recompensa de missão sem pagamento duplo:**
1. A missão é marcada como concluída numa transação do PlayerData, que recusa se ela já estiver concluída.
2. Só depois são entregues XP, materiais, marco e objetivo dimensional.

Cada uma dessas entregas é uma transação separada no seu sistema.

**Esquema do perfil v2 completado** (perfis já salvos ganham os campos sozinhos na migração): `materiais`, `artefatoEquipado`, `nivel`, `xp`, `missoesProgresso`.

## 9. Atualização: fabricação, restauração e primeiro chefe (sem o Studio)

| Sistema | Arquivos | Situação |
|---|---|---|
| **CraftingSystem** | `Sistemas/CraftingSystem.luau` + `Fabricacao/Receita.luau` + `Config/Receitas.luau` | **Escrito.** Estações por marcador; receita conhecida + estação + requisitos + materiais; consumo e entrega numa transação |
| **RestorationSystem** | `Sistemas/RestorationSystem.luau` + `Restauracao/Restauracao.luau` + `Config/Restauracoes.luau` | **Escrito.** Por jogador, com etapas e entrega parcial; pagamento e progresso na mesma transação; ajuda cooperativa (≥ 25% dentro de 30 studs); melhoria global por maioria |
| **BossSystem** | `Sistemas/BossSystem.luau` + `Chefes/CargaDaRainha.luau` + `Config/Inimigos/RainhaBobina.luau` + `PilarDeCristal.luau` | **Escrito.** Rainha-Bobina com 3 cargas (75/50/25%), pilares, descarga esquivável, reset com a arena vazia, esboço Druida na primeira vitória |

**Mudanças em sistemas existentes:**
- **EnemySystem:** ganhou `surgirEm`, `definirInvulneravel` (golpes viram "Imune"), `atordoarPor`, `info` e `remover`. Inimigos sem `retornoSeg` não renascem sozinhos.
- **InventorySystem.transacao:** agora também entrega materiais e artefatos e aceita `alterarPerfil`, tudo na mesma gravação. Pilha cheia desfaz tudo.
- **QuestSystem:** ganhou os eventos `restaurar` e `fabricar`.
- **Perfil:** ganhou `receitas` e `restauracoesProgresso`.

**Ordem de carga:** … MagicBook → Crafting → Restoration → Boss → Loot → Quest.

**Integração com o que já existia:**
- Os livros pedem a restauração do Observatório e da Torre, que agora dá para fazer de verdade.
- O estágio 3 da Espada pede Liga Arcana, que agora pode ser fabricada.
- A Torre usa a Glândula da Rainha.

**Desvio provisório do GDD:** a receita Druida deveria pedir a Forja da base pessoal no nível 3. Até a base existir, ela usa a Oficina restaurada. Isso está anotado em `Config/Receitas.luau`.
