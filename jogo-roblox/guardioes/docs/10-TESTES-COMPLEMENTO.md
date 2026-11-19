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

## 6. Etapas 6 a 9: casos automáticos e roteiro no Studio

**Automáticos novos:** 23 casos (no total, 104 em 16 specs).
- `IADoCompanheiro.spec` (8): escolta por espécie, ritmo, teleporte, coragem, curiosidade, permanecer, retornar e montada.
- `Requisitos.spec` (6): avaliador e os requisitos **reais** dos livros.
- `PerfilSalvo.spec` (8): migração sem perda, validação e trava de sessão.
- `PerfilEfetivo.spec` (+1): a montaria mantém o perfil da espécie.

| # | Passo | Esperado |
|---|---|---|
| C1 | Play | O Output lista os 9 sistemas. Sem API do Studio, aparece o aviso "progresso SÓ EM MEMÓRIA". Uma criatura de teste aparece ao lado do personagem |
| C2 | Andar e correr | A criatura segue do lado da espécie: o Cão à direita, trotando no chão; o Axolote à esquerda, flutuando; a Raia acima e atrás |
| C3 | Teleportar o personagem para longe (mais de 80 studs) | A criatura reaparece ao lado |
| C4 | Aproximar de uma Faísca com o Cão ativo | O Cão ataca. Com o Axolote ativo, ele se esconde atrás do jogador |
| C5 | K → Ativar outra criatura | Troca; a anterior some |
| C6 | T (comando) | Acompanhar → Permanecer (fica parada no lugar) → Retornar (corre de volta) → Acompanhar |
| C7 | H perto da criatura | O vínculo sobe; repetir antes de 10 s → "Espere um pouco" |
| C8 | Ativar o Nebu (Axolote filhote, XP 590, vínculo 290) e derrotar uma Faísca com ele por perto | A XP passa de 600 e o vínculo de 300, mas **ainda não** evolui: faltam os marcos. O cartão mostra o que falta |
| C9 | Cão ativo, V | Monta: o jogador sobe, a velocidade passa a cerca de 34 e o pulo fica mais alto. V de novo desmonta |
| C10 | Raia ativa, V, depois Espaço duas vezes | Monta e decola com o perfil da Raia (decolagem de 0,8 s). Os livros do jogador não mudam a Raia. V em voo → "Pouse primeiro" |
| C11 | Montado, apertar E (artefato) | Recusado: um modo por vez |
| C12 | Pedestais da arena: segurar B no Grimório | "Grimório dos Céus: aprendeu Voo mágico". Ler de novo → "Você já aprendeu com este livro" |
| C13 | Códice da Leveza | Recusado com o texto público: "Disponível quando o Campo das Bolhas for liberado" |
| C14 | Com acesso à API: ler o Grimório, sair, entrar de novo | O livro continua lido e a habilidade continua sabida (origem `livro:`) |
| C15 | Dois servidores (Team Test) e o mesmo jogador | O segundo só carrega depois que o primeiro libera a trava; nada é duplicado |

## 7. Inventário, saque, missões e progressão: casos e roteiro

**Automáticos novos:** 12 casos (total: 116 em 17 specs).
- `Inventario.spec` (11): consumo entre bolsas, falta, pilha, consumo negativo impossível, proteção contra azar, faixa de quantidade, saque pessoal, missão genérica e missão real, curva de nível, vida.
- `PerfilSalvo.spec` (+1): validação de inventário e de nível.

| # | Passo | Esperado |
|---|---|---|
| P1 | Play | O canto superior esquerdo mostra "Nv 1"; à direita aparecem as missões *O Horizonte Partido* (0/5), *Primeira caçada*, *Olhar as estrelas*, *Vento nas asas* e *Travessia da tormenta* |
| P2 | Derrotar Faíscas | "+1 ou +2 Fragmento de Faísca"; +15 de XP cada; a missão conta 1/5, 2/5… Em até 15 derrotas, cai pelo menos um Núcleo de Tempestade |
| P3 | 5ª Faísca | "Missão concluída: O Horizonte Partido", +120 de XP, +1 Núcleo. O nível sobe e a vida enche |
| P4 | Com o Cão ativo, derrotar uma Faísca | "Primeira caçada" concluída; o cartão do Cão mostra o marco cumprido |
| P5 | I (Bolsa) | Lista os materiais de teste e os 3 artefatos de teste |
| P6 | Bolsa → Espada do Horizonte → Evoluir | Estágio 3 (os materiais de teste bastam); os números da bolsa diminuem. Na prancha, a velocidade máxima passa de 42 para 46 |
| P7 | Evoluir de novo | Mostra "Falta: Anel Dos Relampagos · Guardiao Da Tormenta Sem Cair" (desafios de estágio 4) |
| P8 | Bolsa → Cajado → Equipar | Golpes de vento (alcance 12, arco largo). E transforma em vassoura (velocidade 38, mais ágil) |
| P9 | Afagar a Raia adulta algumas vezes (a cada 10 s) | Às vezes: "+1 Pena de Raia" |
| P10 | Golpes da Espada do Horizonte em ritmo rápido | Sem recusas "cedo" frequentes (a correção da arma no cliente) |
| P11 | Com acesso à API: subir de nível, sair e voltar | Nível, XP, materiais salvos e missões concluídas continuam. Os artefatos e materiais de **teste** não são salvos |

## 8. Fabricação, restauração e Rainha-Bobina: casos e roteiro

**Automáticos novos:** 8 casos (total: 123 em 18 specs).
- `FabricacaoRestauracaoChefe.spec` (7): Liga Arcana, faltas listadas, esboço Druida, requisito de mundo, etapas da restauração, ajuda cooperativa, cargas da Rainha.
- `PerfilSalvo.spec` (+1): progresso de restauração inválido.

| # | Passo | Esperado |
|---|---|---|
| F1 | Marcadores cinza (x +30 a +46 da arena) → segurar B em "Oficina dos Inventores" | "Oficina — etapa 1/2: Tirar os destroços… Falta: Fragmento de Faísca × 4" |
| F2 | Derrotar Faíscas e voltar ao marcador | Entrega parcial; ao completar, etapa 2. Depois de concluir a etapa 2: "Oficina dos Inventores restaurada!" e a missão *A fornalha dos inventores* concluída |
| F3 | Dois jogadores: o B entrega 1 fragmento da etapa 1; o A conclui a mesma etapa com o B por perto | O B recebe "Etapa concluída com a ajuda de A" |
| F4 | Bancada marrom → B "Fabricar" | A janela mostra a Liga Arcana (com o que falta). Fabricar consome 6 fragmentos e 1 núcleo e entrega 1 Liga Arcana; a missão *A liga dos inventores* é concluída |
| F5 | Restaurar o Observatório e a Torre | Os livros do Grimório e do Tomo passam a abrir por requisito **real** (sem depender do progresso de teste) |
| B1 | Ir até a arena da Rainha (z −90 da arena) | Aparece a barra do chefe; ela persegue e telegrafa ferrão, pulso e investida |
| B2 | Baixar a vida até 75% | "Os pilares acenderam!": a barra fica azul (imune), surgem 3 pilares e uma contagem de 12 s |
| B3 | Quebrar os 3 pilares a tempo | "A Rainha caiu! Ataque agora!": ela fica atordoada por 4 s e leva +30% de dano |
| B4 | Deixar o tempo acabar e esquivar no instante | "DESCARGA!" quem esquivou não leva dano; quem não esquivou leva 45 |
| B5 | Vencer | Glândulas (3 a 5), XP, missão *A Rainha da caverna* e, na primeira vez, "Esboço Druida aprendido!". A receita aparece na bancada |
| B6 | Fabricar o Escudo do Firmamento Druida | Um artefato **novo** (GUID salvo) aparece na Bolsa, no estágio 1 |
| B7 | Sair da arena por 20 s no meio da luta | A Rainha volta com a vida cheia e os pilares somem |

## 9. Base pessoal, viagem rápida e Cão-Trovão Alfa: casos e roteiro

**Automáticos novos:** 8 casos (total: 130 em 19 specs).
- `BaseViagemAlfa.spec` (7): melhoria da Forja, Forja 3 exige Juba, nível máximo, jardim (sobra e teto), divisão da colheita, regras de viagem, chamadas da matilha e corrida carregada com aparo.
- `PerfilSalvo.spec` (+1): base inválida.
- Também mudou: o caso Druida de `FabricacaoRestauracaoChefe.spec` agora exige a Forja nível 3.

| # | Passo | Esperado |
|---|---|---|
| H1 | Play | Aparece uma parcela de teste com "Base de <nome>", com Forja, Jardim, Expositor e placas |
| H2 | Placa da Forja → N ("Melhorar") com nível 1 de jogador | "Para melhorar falta: Nível 1/3" |
| H3 | Subir ao nível 3 e ter 10 Fragmentos → N | "Forja agora no nível 2"; o bloco cresce; os Fragmentos são consumidos |
| H4 | Jardim → B ("Colher") logo ao entrar | "O jardim ainda está crescendo" (ou algumas Sementes e Cascas, se houve tempo) |
| H5 | Forja da base de **outro** jogador → "Fabricar" | "Esta base não é sua" |
| H6 | M ("Viagem") | Lista com "Minha base". Andar perto dos discos azuis → "Ponto de viagem descoberto" |
| H7 | Viajar para a Arena; tentar de novo logo depois | Teleporta; a criatura chega junto. Segunda tentativa → "Aguarde a recarga" |
| H8 | Levar dano e tentar viajar | "Não dá para viajar em combate" |
| A1 | Arena do Alfa (x −90, z −60) | Barra do chefe; ataques rápidos (mordida, bote carregado) |
| A2 | Levar o Alfa a 70% | "O Alfa chamou a matilha!" e 2 cães aparecem |
| A3 | Esperar a corrida carregada | Barra azul ("imune"); golpes dão "Imune" |
| A4 | Aparar um golpe dele durante a corrida (defender no instante do impacto) | "Caiu! Ataque agora!": ele fica atordoado por 4 s |
| A5 | Vencer | Juba Estática (3 a 5), XP, missão *O Alfa da matilha*; aparece um troféu no Expositor da base |
| A6 | Forja ao nível 3 (Juba e Núcleos) e esboço da Rainha | O Escudo Druida pode ser fabricado **na Forja da base** (a Oficina não serve mais para ele) |

## 10. Guardião da Tormenta: casos e roteiro

**Automáticos novos:** 6 casos em `Tormenta.spec` (total: 140 em 21 specs).

| # | Passo | Esperado |
|---|---|---|
| G1 | Com `ignorarTravasDeChefe = false` e sem a Torre restaurada, ir à arena (x +110, z −90 da arena) | É empurrado para fora: "A Torre ainda não tem energia…" |
| G2 | Com a Torre restaurada (ou a trava de teste ligada) | Barra do Guardião; lança, investida aérea e trovão |
| G3 | Baixar a vida a 65% | "Fase 2…": a barra fica azul (imune) e golpes dão "Imune". Um dos 4 para-raios acende (amarelo) |
| G4 | Ativar (B) o para-raios aceso | "O raio atingiu o Guardião!": cerca de 480 de dano, atordoado por 3 s e ferível nessa janela; depois volta a ficar imune |
| G5 | Ativar um apagado | Choque de 10 em quem ativou |
| G6 | Deixar o aceso sem ativar por 5 s | "O raio caiu na arena!": 30 de dano em quem estiver a até 10 studs dele |
| G7 | Baixar a 30% | "Fase 3": áreas vermelhas no chão (centro, anel ou cruz) por 1,2 s e depois descarga de 35 em quem ficou nelas (esquivar no instante evita) |
| G8 | Vencer | Coração da Tormenta e Penas do Relâmpago Antigo, 800 de XP, missão, troféu. Na primeira vez: "Códice Arcano aprendido!…" e o segredo de história *DiarioDoGuardiao* |
| G9 | Oficina restaurada, com Coração, 2 Penas, 2 Glândulas e 2 Jubas | Fabricar a **Espada do Horizonte (Arcano)**: um artefato novo na Bolsa, que vira prancha a partir do estágio 2 (Exemplo 4 do complemento) |

## 11. Colosso das Ruínas e Espectro do Observatório: casos e roteiro

**Automáticos novos:** 5 casos em `ColossoEspectro.spec` (total: 145 em 22 specs).

| # | Passo | Esperado |
|---|---|---|
| R1 | Arena do Colosso (x +120, z +60 da arena) | Barra azul (couraça imune); golpes dão "Imune"; socos e varreduras lentos |
| R2 | Aparar um golpe dele (defender no instante do impacto) | "Aparo 1/3", depois "2/3" |
| R3 | Terceiro aparo | "O núcleo abriu! Ataque agora!": ferível por 8 s; depois "A couraça fechou de novo" e a contagem zera |
| R4 | Esperar cerca de 11 s | Anel laranja em volta dele (1,5 s) e depois a onda: 30 de dano em quem está a até 14 studs (esquivar no instante evita) |
| R5 | Vencer | Núcleo Enferrujado (3 a 5) e **Essência de Vento** (2 a 3; agora há fonte para o estágio 3 do Cajado), XP, missão e troféu |
| E1 | Arena do Espectro (x −120, z +60), com `ignorarNoite = false` e de dia (Lighting.ClockTime = 12) | Ele não aparece; com ClockTime = 22, ele surge |
| E2 | Lutar sem o telescópio | Imune; a cada 9 s pula para outra lente ("O Espectro foi para a lente N") |
| E3 | Telescópio no centro, segurar B | Sem o Observatório restaurado (e com a trava de teste desligada): "O telescópio está quebrado…". Com ele restaurado: "O reflexo revelou o Espectro!": ferível por 6 s, atordoado por 2 s, sem teleporte nesse tempo; recarga de 15 s |
| E4 | Vencer | Lente Espectral (2 a 3), XP, missão (que exige o Observatório restaurado) e troféu. Ele só volta depois de 300 s **e** de noite |
| E5 | Amanhecer sem ninguém lutando | Ele some e volta na próxima noite |

## 12. Equipamentos (armaduras e acessórios): casos e roteiro

**Automáticos novos:** 5 casos em `Equipamento.spec` (total: 150 em 23 specs).

| # | Passo | Esperado |
|---|---|---|
| Q1 | Forja da base (nível 1) → Fabricar | Aparecem Capuz e Botas de Viajante (4 Fragmentos cada). Fabricar põe o item na Bolsa → Equipamentos |
| Q2 | Bolsa (I) → Equipar o Capuz | "Defesa 4" nos totais; golpes recebidos causam um pouco menos de dano (100/(100+4)) |
| Q3 | Vencer o Alfa, o Colosso e o Espectro (primeira vez) | "Esboço Druida aprendido: Elmo da Matilha / Couraça das Ruínas / Amuleto Espectral!" |
| Q4 | Forja nível 3 → fabricar os três Druida | Itens com raridade Druida (atributos × 1,42) |
| Q5 | Equipar Elmo + Couraça + Botas + Amuleto | Totais: **Defesa 48 · Vida +43 · Energia de voo +21**; a vida máxima sobe 43; a barra de energia fica maior |
| Q6 | Com o Elmo, aparar um pouco "atrasado" (até 0,21 s depois de começar a defender) | Ainda conta como aparo (0,18 + 0,03) |
| Q7 | Pedir pelo console para equipar um GUID falso ou o Elmo no Corpo | "Item não encontrado" / "Esse item não vai nesse lugar" |
| Q8 | Sair e entrar (com API) | Itens e encaixes salvos e reaplicados |

## 13. Melhorias e transportes: casos e roteiro

**Automáticos novos:** 6 casos em `MelhoriaTransporte.spec` (total: 156 em 24 specs).

| # | Passo | Esperado |
|---|---|---|
| U1 | Bolsa (I) → Equipamentos → "Melhorar +1" longe das estações | "Melhorias até +5: na Oficina dos Inventores restaurada" |
| U2 | Perto da bancada da Oficina (restaurada) com Fragmentos | Item "+1"; Fragmentos consumidos; atributos sobem um pouco |
| U3 | Sem material suficiente | "Para melhorar falta: Fragmento de Faísca 3/8 · …" |
| U4 | Tentar o +6 na Oficina | "Melhorias +6 a +10: na Forja da sua base, nível 4" |
| U5 | Elmo Druida no +10 | Defesa do Elmo 15 (10 × 1,46): melhor que o +0, mas abaixo de um item Arcano equivalente |
| T1 | J ("Transportes") | Lista com todos os meios; os indisponíveis mostram "Falta: …" (o Arco ??? não aparece) |
| T2 | Fabricar a Prancha de viagem na Forja nível 2 (12 Fragmentos + 2 Penas de Raia) | Ela fica disponível; fabricar de novo não consome nada (já tem) |
| T3 | "Preferir" a Prancha de viagem e apertar Espaço no ar | Decola na prancha: baixa (até 6 studs do chão), velocidade 24, gasto de 4/s, sem impulso |
| T4 | Pedir pelo console `DECOLAR "PranchaComum"` sem possuí-la | "Item não encontrado" |
| T5 | Sair e entrar (com API) | Prancha e preferido salvos |

## 14. Companhias (guildas de jogadores): casos e roteiro

**Automáticos novos:** 12 casos em `Companhia.spec` (total: 168 em 25 specs).

Os roteiros abaixo pedem **dois jogadores** (Test → Clients and Servers → 2 Players). Os passos com "com API" precisam do acesso a DataStore ligado no place de teste.

| # | Passo | Esperado |
|---|---|---|
| K1 | Jogador 1: U → nome "Vigias", escolher emblema → Criar | Painel mostra "Vigias", nível 1, cargo Lider; registro "criou" |
| K2 | Criar outra com o mesmo nome (outro jogador) | "Já existe uma companhia com esse nome" |
| K3 | Nome "ab" ou com `<` | "Nome inválido…"; um nome bloqueado pelo filtro do Roblox → "Esse nome não é permitido" |
| K4 | Pelo console, convidar o jogador 2 (`CONVIDAR, userId`) | Jogador 2 recebe o aviso "Convite para a companhia Vigias (U)"; no painel, Aceitar/Recusar |
| K5 | Jogador 2 aceita | Entra como **Recruta**; os dois painéis mostram 2 membros |
| K6 | Jogador 2 (Recruta) deposita 10 Fragmentos | Saem da bolsa dele; o cofre mostra ×10. "Retirar" não aparece para ele |
| K7 | Com concessões de teste ligadas, depositar um material que só existe na bolsa de teste | "Item não encontrado no inventário" (teste nunca entra no cofre) |
| K8 | Líder promove o 2 a Membro; o Membro tenta retirar | "Nada disponível desse material para o seu cargo" |
| K9 | Líder marca o material como livre (→ livre); o Membro retira 10, depois mais 10, depois mais 1 | 20 no total; a terceira dá "Limite diário de retirada atingido" |
| K10 | Líder marca como travado; promove o 2 a Oficial; o Oficial tenta retirar | Recusado; o líder retira normalmente |
| K11 | Líder expulsa o jogador 2 depois de ele depositar 5 | 2 recebe "Você saiu da companhia. Seus depósitos voltaram para você." e os 5 na bolsa |
| K12 | Expulsar alguém que está offline (com API) | Ao entrar, o campo de companhia some e os depósitos chegam na bolsa |
| K13 | Líder → "Líder" em um membro | Painel: "Liderança passa para … em 48 h"; "Cancelar T." desfaz |
| K14 | Mudar `TRANSFERENCIA_SEG` para 30 numa cópia de teste e esperar o ciclo (60 s) | O membro vira Lider; o antigo vira Oficial; aviso para os dois |
| K15 | Líder → Dissolver | "Confirme a dissolução: aperte de novo." → "Confirmar" → "Dissolução agendada para daqui a 72 h" |
| K16 | Com `DISSOLUCAO_SEG` curto (cópia de teste) | Todos recebem "A companhia … foi dissolvida…"; cada um recebe de volta só o que depositou; o nome fica livre |
| K17 | Derrotar um miniboss com os dois membros contribuindo | XP da companhia +240 (120 por membro elegível) |
| K18 | Apertar várias ações seguidas muito rápido | Algumas recusadas com "Aguarde a ação anterior terminar" (uma ação por vez por jogador) |
| K19 | Bolsa cheia (9999) e retirar | "Bolsa cheia: N ficaram guardados para você."; entregues ao abrir espaço e entrar de novo |
| K20 | Dois servidores (com API, publicado em teste privado) | Mudanças feitas num servidor aparecem no outro em até 60 s |
