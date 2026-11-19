# 10 · Casos de teste do complemento

> Nada aqui foi executado. A seção 1 tem testes automáticos já escritos (mesmo executor do `05`). As seções 2 a 5 são roteiros para o Studio.

## 1. Testes automáticos (lógica pura): 47 casos novos em 6 specs

Para rodar no Studio: `require(game.ServerStorage.GuardioesTestes.Studio)()`. Para rodar no Lune: `lune run tests/rodar-lune.luau`.

| Spec | Casos | Cobre |
|---|---|---|
| `MaquinaDeLocomocao.spec` | 13 | Decolagem → Pairar; Pairar ⇄ Voo; recusas (zona, espaço, energia, atordoado, dois voos); impulso; pouso completo; energia zerada → Interrompido → Descida → Pouso; zona e atordoamento; pouso automático (e a plataforma que não pousa sozinha); planador; um modo por vez; montaria terrestre e voadora; ataque só a pé |
| `FisicaDeVoo.spec` | 9 | Aceleração gradual e teto; frenagem; impulso; velocidade vertical; inclinação na curva dentro do limite; custos; planador (afundar e corrente); teto da plataforma; limites do servidor |
| `PerfilEfetivo.spec` | 6 | Cópia sem efeito colateral; Correntes Astrais; Leveza; teto de 1,35×; piso de custo; bônus que não vaza entre perfis |
| `ValidadorDeDeslocamento.spec` | 4 | Limites horizontal, de subida e de altitude; tolerância a uma violação; correção após duas; reancorar |
| `Artefatos.spec` | 7 | Forma inicial e bloqueio por estágio; nenhuma forma ativa durante a troca; recarga; recusas; cancelamento; retorno ao combate; avaliação de estágios e bônus |
| `Companheiros.spec` | 8 | Registro; nome; teto diário de vínculo; crescimento (XP + vínculo + marcos + desafio); montaria só adulta e só de espécie certa; Vínculo Dimensional (uma vez por objetivo, adulto, limiar, indisponível, incompatível, ritual) |

## 2. Roteiro no Studio: locomoção (1 jogador)

A preparação é a mesma do `05`, seção 0. As concessões de teste dão Voo mágico, Correntes Astrais e Planador, mais a Espada do Horizonte e o Escudo do Firmamento no estágio 2.

| # | Passo | Esperado |
|---|---|---|
| L1 | Play; Output | `[Guardioes] servidor iniciado: EnemySystem, CombatSystem, MovementAbilitySystem, MovementSystem, MetamorphicArtifactSystem`, sem erros |
| L2 | Pular e apertar Espaço no ar | Decolagem (sobe cerca de 0,45 s), depois Pairar. A barra azul de energia aparece |
| L3 | Andar (WASD) | Acelera aos poucos até cerca de 32 studs/s; o corpo inclina nas curvas; o FOV abre um pouco |
| L4 | Olhar para cima ou para baixo andando para frente | Sobe ou desce junto com a câmera |
| L5 | Espaço / Ctrl segurados | Sobe / desce a até cerca de 16 studs/s |
| L6 | Shift no voo | Impulso (cerca de 48), FOV maior, rastro mais forte, energia cai mais rápido (cerca de 16/s) |
| L7 | X | Descida, pouso e volta ao chão; a energia recupera depois de cerca de 1,2 s |
| L8 | Voar até a energia acabar | Aviso "A energia acabou", queda amortecida e pouso, sem dano de queda absurdo |
| L9 | Espaço duas vezes rápido no chão | Pula e decola |
| L10 | Do alto (≥ 8 studs), G | Planador abre, perde altura devagar, curva limitada; no chão, fecha sozinho |
| L11 | Planando, Espaço | Troca para o voo (um modo só por vez) |
| L12 | Pairando, atacar (clique) | Nada sai; o combate recusa ("Indisponível enquanto se desloca") |
| L13 | Ser atingido por uma Faísca em voo (Investida 14) | "Derrubado do voo!", queda amortecida |
| L14 | Criar uma Part (caixa grande) em `workspace.GuardioesZonasSemVoo` e voar para dentro | "Não é possível voar aqui", queda até o chão |
| L15 | Câmera | O horizonte nunca rola; o FOV muda suavemente; dá para ler o cenário |

## 3. Roteiro no Studio: Espada do Horizonte

| # | Passo | Esperado |
|---|---|---|
| A1 | Entrar | A espada provisória (peça azul) aparece na mão; os ataques usam os tempos da Espada do Horizonte |
| A2 | E no chão | 0,6 s de troca (a peça pisca); a prancha aparece sob os pés; decola baixo e paira rente ao chão |
| A3 | Atacar na prancha | Recusado ("Volte à forma de arma para atacar") |
| A4 | Voar alto e apertar E | Sai da prancha na hora, cai amortecido, a espada se monta; no chão, ataca normalmente |
| A5 | E duas vezes rápido | A segunda recusa: "Aguarde a recarga" |
| A6 | Levar golpe ≥ 12 durante a troca | A troca é cancelada e volta à forma anterior |
| A7 | Pousar na prancha (X) e apertar E de novo no chão | Volta para a espada |
| A8 | Morrer em voo e renascer | Renasce no chão, com a espada na mão |

## 4. Multiplayer e desempenho (Etapa 13)

- **Teste com 4 clientes** (Test → Clients and Servers, 4 jogadores):
  - todos voam ao mesmo tempo;
  - cada um vê os rastros dos outros, que somem a mais de 180 studs;
  - o voo continua fluido, sem engasgos.
- **Lag de rede** (*Incoming Replication Lag* de 0,25 s):
  - o voo continua fluido para o dono;
  - não há correções falsas, ou no máximo raras, em voo normal.
- **Trapaça simulada no cliente:** pelo console do cliente, rodar `game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame += Vector3.new(80, 0, 0)` em voo, duas vezes seguidas. Esperado: aviso de correção e volta para a posição anterior.
- **Remotos inválidos:**
  - `FireServer(1, "AsasPerdidas")` em `Locomocao` → recusado (`perfilInvalido`);
  - `FireServer(1, "VooMagico")` com 500 repetições → o balde limita.
- **Artefato inexistente:** `FireServer(1, "guid-falso", "Prancha")` em `Artefato` → "Item não encontrado".
- **Desempenho:**
  - no MicroProfiler, o custo do MovementSystem com 4 jogadores voando deve ficar bem abaixo de 1 ms por quadro no servidor (meta T);
  - no celular emulado, conferir a qualidade "Baixo" (sem partículas).

## 5. Integração com os mapas reais (Etapa 14, quando o Studio estiver disponível)

Nada disso altera os modelos aprovados: são **marcadores** (Parts invisíveis) em pastas próprias.

- [ ] **Zonas sem voo:** marcar interiores (oficina, Observatório por dentro) e a arena do Guardião em `GuardioesZonasSemVoo`.
- [ ] **Teto de voo da Ilha:** medir a altura das nuvens de tempestade e ajustar `alturaMaxAbsoluta` (ou criar a configuração por dimensão).
- [ ] **Correntes ascendentes:** pontos de corrente para o planador, perto das falésias e da Torre, como Parts com o atributo `GuardioesCorrente = força` (o FisicaDeVoo já aceita `correnteAscendente`; falta ler o marcador no cliente).
- [ ] **Bibliotecas:** posição planejada da biblioteca no Observatório e da estante no topo da Torre, como marcadores (os modelos ficam para depois).
- [ ] **Desempenho:** conferir FPS no celular voando sobre a vegetação instanciada da Ilha.
