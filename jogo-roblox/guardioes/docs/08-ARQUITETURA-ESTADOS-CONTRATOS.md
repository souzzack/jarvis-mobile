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
