# 34 · Auditoria da Ilha das Tempestades (relatório 1, para revisão)

Data: 20/11/2026. Nesta etapa só olhei: **nenhuma estrutura foi alterada**. A única mudança no place foi a pasta de backup.

## 1. Arquivo aberto

| Item | Valor |
|---|---|
| Place aberto no Studio | **"11202026_2"**, placeId **115368067307260** (universo 10777933840) |
| O que é | A **cópia de teste** do Magnata do Multiverso, onde está todo o código dos Guardiões. O doc 04 manda testar o RPG numa cópia, não no original |
| Original | "Magnata do Multiverso", placeId 86899143559754. **Não foi aberto nem tocado** |

**Ponto para decisão:** o pedido diz "projeto real". Hoje, o projeto real dos Guardiões é esta cópia, porque o original não tem o código do RPG. Se "projeto real" quer dizer o place original, preciso dessa confirmação antes de qualquer correção.

## 2. Backup verificável (IMPLEMENTADO e TESTADO)

- **Pasta no place:** `ServerStorage.Backup_IlhaTempestades_20261120_v5`. Tem cópias de `Workspace.Mundos.Tempestades`, `Workspace.Galpao`, `Workspace.GuardioesViagem`, `Workspace.GuardioesParcelas` e `Workspace.GuardioesMisterios`.
- **Conferência:** cada cópia bate com o original no número de itens, no número de peças e numa assinatura de posição e tamanho.

| Original | Itens | Peças | Assinatura | Cópia |
|---|---|---|---|---|
| Workspace.Mundos.Tempestades | 392 | 308 | 14,417 | igual |
| Workspace.Galpao | 1111 | 936 | 941,631 | igual |
| Workspace.GuardioesViagem | 7 | 6 | -0,953 | igual |
| Workspace.GuardioesParcelas | 6 | 6 | 10,005 | igual |
| Workspace.GuardioesMisterios | 26 | 14 | -8,067 | igual |

- **Histórico da nuvem:** versão **5** (antes da auditoria) e versão **6** (com o backup). Para restaurar, use File → Version History no Studio.
- **Código:** está no git, último commit `702831f`.

## 3. Referência: o que são as "prévias finais"

As imagens de `docs/previas/` **não são prévias finais**. O LEIA-ME delas diz que são reconstruções em three.js dos **blocos provisórios** da arena de teste. Por isso, comparei o Studio com duas referências:
- **(a)** o que as prévias mostram;
- **(b)** o que o GDD define para a Ilha (seção 6.2, minibosses e Guardião; seção 8, estruturas a restaurar).

**Para a revisão:** se existem outras prévias finais (imagens de arte aprovada), elas não estão no repositório. Peço que sejam enviadas.

## 4. O que existe no Studio

### 4a. No Edit (salvo no place)

`Workspace.Mundos.Tempestades` é a **área de mineração do tycoon**: um disco de basalto de uns 123×117 studs, rodeado de água.

| Caminho | O que é |
|---|---|
| `Workspace.Mundos.Tempestades.Rochas` (6× `Rocha`) | Rochas mineráveis do tycoon |
| `…Tempestades.Venda` | Ponto de venda do tycoon |
| `…Tempestades.Anel` (2) | Anéis decorativos no chão |
| `…Tempestades.PortalVolta` | Portal de volta ao Galpão (tycoon) |
| `…Tempestades.Chegada` | Ponto de chegada do tycoon, em (0, 1, 40) |
| `…Tempestades.Decoracao` | 8 `ArvoreRaio` e 4 `Tempestades_2` (cristais) |

**Nenhuma** construção do RPG da Ilha existe como modelo no place. Procurei por nome no Workspace, no ServerStorage e no ReplicatedStorage: Oficina, Observatório, Torre, Caverna, Mina, Vila, Ponte, Santuário, Altar, Ruínas, Floresta, Arena e Doca. Só achei:
- `ServerStorage.Oficina`, `ServerStorage.Oficina2` e `ServerStorage.Oficina3`, que são modelos do **tycoon** guardados e não usados no mapa;
- as pontes das Bolhas e da Biblioteca, que são de outras áreas.

### 4b. No Play (criado pelo código)

O código dos Guardiões cria **marcadores provisórios** quando o jogo começa. Medi onde cada grupo fica em relação ao chão.

| Pasta criada no Play | Posição | Situação |
|---|---|---|
| `GuardioesEstruturas` (Oficina, Observatório, Torre) | (30–46, 4, 36) | Base em 1,5; o chão ali está em 9,4–9,9 (dentro de uma árvore ou rocha) |
| `GuardioesInimigos.GuardiaoDaTormenta` | (110, −13, −50) | **No fundo do mar**, 12 studs abaixo da superfície da água |
| `GuardioesInimigos.ColossoDasRuinas` | (120, −12, 100) | **No fundo do mar** |
| `GuardioesInimigos.CaoTrovaoAlfa` | (−90, −13, −20) | **No fundo do mar** |
| `GuardioesInimigos.EspectroDoObservatorio` | (−120, 8, 100) | Sobre a água (como fantasma, pode ser intencional) |
| `GuardioesInimigos.RainhaBobina` | (1, 12, −49) | Sobre a ilha (basalto). Não existe "caverna" |
| `ParaRaios1–4` | (90–130, 5, −30 a −70) | Saindo da água |
| `Lente1–4`, `Telescopio` | (−136 a −104, 1,5–7, 84–116) | Flutuando sobre a água |
| `GuardioesSegredos` (santuário, altar, 6 pilares) | (−49 a −31, 0–3, 110–150) | Sobre a água |
| `GuardioesSegredos` (telescópio, 3 lentes) | (36–40, 6–7, 44–46) | Dentro da copa de uma árvore (o chão medido ali é 9–10) |
| `GuardioesMisterios` (sala dos capítulos 1 a 4, 30 peças) | (40–110, 1–16, 110–136) | **Flutuando 5 studs acima da água**, fora da ilha |
| `GuardioesOcultos`, `GuardioesCorrentes` | (−30, 6, 80) / (30, 24, 100) | Sobre a água |
| `GuardioesViagem.Ponto_Arena` | (0, 1, 52) | **Dentro do PortalVolta do tycoon** (o chão medido é 13) |
| `GuardioesViagem.Ponto_Oficina` | (36, 1, 48) | Dentro de uma árvore |
| Arena de teste (Boneco de Treino) | (0, 4, 40) | **Em cima da `Chegada` do tycoon** |
| `GuardioesLivros` (3 pedestais) | (−12 a 4, 2,5, 18) | No chão da ilha. Sem problema de posição |
| `GuardioesEstacoes`, `Base_<UserId>` | (−132 a −104, 9, 316–336) | Na parcela do Galpão. Sem problema |

**Capturas reais (Play, interface escondida):**
- `docs/auditoria-ilha/01-ilha-vista-de-cima.jpg`: a ilha e, ao redor, os marcadores no mar (sala de mistérios embaixo à direita, santuário e pilares embaixo à esquerda, lentes à esquerda).
- `docs/auditoria-ilha/02-sala-misterios-sobre-a-agua.jpg`: a sala dos capítulos 1 a 4 flutuando sobre a água e, ao fundo, os para-raios saindo da água.
- `docs/auditoria-ilha/03-guardiao-no-fundo-do-mar.jpg`: o Guardião (esfera provisória) no fundo de areia.

## 5. Ausentes, incompletos, deslocados e com problema

### AUSENTE: nenhum modelo existe; só há marcador provisório ou nada

1. Portal (doca de chegada)
2. Oficina dos Inventores
3. Mina / Caverna do Trovão, com a câmara da Rainha-Bobina
4. Observatório
5. Torre Meteorológica, com a arena do Guardião no topo
6. Santuário (altar)
7. Vila: NPCs, comerciantes e quadro de missões
8. Ponte suspensa e estrada do penhasco
9. Ruínas tecnológicas (território do Colosso)
10. Floresta das árvores retorcidas (território do Cão-Trovão)
11. Mirante

### DESLOCADO: o código posiciona fora do lugar

1. **Bosses no mar:** Guardião, Colosso e Cão-Trovão ficam no fundo do mar, 12 studs abaixo d'água. **Problema de jogo real:** a luta acontece debaixo d'água.
2. **Sala de mistérios dos capítulos 1 a 4:** flutua 5 studs acima da água, fora da ilha. A Porta sem Moldura só era alcançada graças à correção de hoje (prompt perto da base).
3. **Marcadores no mar:** segredos do santuário, do altar e dos pilares, lentes do Espectro, telescópio, para-raios, trilha escondida e corrente.
4. **Marcadores dentro de árvores ou rochas:** estruturas da Oficina, do Observatório e da Torre, telescópio e lentes dos segredos, e o ponto de viagem "Oficina".
5. **Sobreposições com o tycoon:**
   - o ponto de viagem "Arena" fica dentro do PortalVolta;
   - a arena de teste (Boneco) fica em cima da Chegada.

### PROBLEMA: escala

A ilha do tycoon tem uns 120 studs de diâmetro. As coordenadas do RPG (`ConfigServidor`) vão de −136 a +130 em X e de −90 a +150 em Z, numa área de uns 270 por 240 studs. **O conteúdo planejado não cabe na ilha que existe.** Isso precisa de uma decisão de projeto:
- **(A)** aumentar a ilha;
- **(B)** reposicionar e compactar o conteúdo;
- **(C)** criar a Ilha dos Guardiões como área nova.

### OUTPUT

- **Erros do jogo:** 0 durante o Play. Os testes de lógica passaram (234 de 234).
- **Avisos esperados:** DataStore indisponível no Studio, e animações de combate ainda sem IDs.
- **`ContentId rbxassetid://203785492 … Asset type does not match` (3 vezes, PENDENTE):** no place, esse ID só aparece no plugin Rojo arquivado em `ServerStorage.Arquivo_NaoUsado`, que não roda. Provavelmente vem do plugin Rojo instalado no Studio, não do jogo. Falta confirmar.

## 6. Status

| Item | Status |
|---|---|
| Backup verificável | **IMPLEMENTADO e TESTADO** (conferência de contagem e assinatura; nuvem nas versões 5 e 6) |
| Inventário do Edit e do Play | **TESTADO** (medido no Studio, com capturas) |
| Construções da Ilha (11 itens da seção 5) | **AUSENTES**: correção **PLANEJADA**, aguardando decisão |
| Marcadores deslocados (bosses, sala de mistérios, segredos) | **PENDENTE**: correção **PLANEJADA**, aguardando aprovação |
| Erro do `203785492` | **PENDENTE** (confirmar a origem) |

## 7. Proposta de correção em pequenos conjuntos (PLANEJADO, nada aplicado)

Nada aqui cria mecânica nova: só muda posições, terreno e modelos de lugares que já existem no código.
1. **Conjunto 1, bosses fora d'água.** Mudar as posições em `ConfigServidor.chefes` para pontos sobre terra. Também dá para criar plataformas ou ilhotas de arena: a Torre para o Guardião, as Ruínas para o Colosso e a Floresta para o Cão-Trovão. Teste: Play, conferir chão sob cada boss e uma luta curta.
2. **Conjunto 2, sala de mistérios e segredos sobre terra.** Colocar a origem de `marcadoresDeTeste` sobre terra (ou numa ilhota própria) e tirar os segredos e as lentes da água. Teste: alcançar cada marca no Play.
3. **Conjunto 3, sobreposições com o tycoon.** Mover o ponto "Arena", o Boneco e os marcadores que estão dentro de árvores. Teste: medir o chão e checar colisões.
4. **Conjunto 4 em diante, construções.** Uma estrutura por vez, começando pela Oficina, Observatório e Torre, que já existem como marcadores e têm restauração no código. **Antes**, falta a decisão de escala (A, B ou C).

**Aguardo aprovação** para começar pelo conjunto 1, e a decisão sobre a escala da ilha antes do conjunto 4.
