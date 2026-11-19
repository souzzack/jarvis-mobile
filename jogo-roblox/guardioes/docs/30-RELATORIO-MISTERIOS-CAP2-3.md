# 30 · Relatório: mistérios, capítulos 2 e 3 (sem o Studio)

Data: 19/11/2026. **Nada foi executado** no Studio nem em runtime Luau.

O motor do complemento 03 (doc 29) foi usado como pedido: **só dados**, mais três pequenas extensões genéricas, sem script por capítulo.

## O que foi feito

| Capítulo | Como funciona | Integração |
|---|---|---|
| **2 · O Guardião Adormecido** | Acordar o **Vigia de Cristal**, uma criatura pacífica; no protótipo é um bloco neutro no lugar de um modelo. Ele passa a revelar dois símbolos ("o cristal da … voltado para o …"). Enigma de **alinhamento**: girar três cristais entre 4 direções até ficarem como nos símbolos. A direção de cada cristal é diferente para cada jogador | **Alternativa** ao Vigia (o complemento pede): os símbolos também se revelam com Faro de Cristal ou Trilha Escondida (criatura ativa perto) ou com o Grimório dos Céus lido |
| **3 · As Três Torres Esquecidas** | A ordem das torres (vento, raio, maré) vem de uma placa e da **cantiga do Vigia** (a mesma criatura diz outra coisa no capítulo 3). Enigma de **sequência** | **Restauração**: as torres só respondem com a Torre Meteorológica restaurada; senão, "estão sem energia" |
| Capítulo 4 em diante | Continua **não lançado**: aparece como "ainda não disponível" | — |

**Recompensas** (cada uma uma vez só, numa gravação só):

| Capítulo | Recompensa |
|---|---|
| 2 | Folha de Registro, registro "fragmento 2", conhecimento "A voz dos cristais", 200 XP |
| 3 | Folha de Registro ×2, Núcleo de Tempestade, registro "fragmento 3" (Conhecimento Proibido), 250 XP |

**Lore:** cânone na **versão 2** (`docs/lore/ARQUIVISTAS.md`): o Vigia como testemunha, as torres e o primeiro sinal de desacordo entre os Arquivistas. Nada da versão 1 foi contradito, e a pergunta sobre a Fratura continua em aberto.

## Extensões genéricas (servem para os próximos capítulos)

- **Marca com uma pista por capítulo** (`pistas = {…}`): a mesma criatura ou objeto diz coisas diferentes conforme o capítulo em que o jogador está.
- **Fonte de capacidade "pistas":** ter encontrado uma pista conta como capacidade. É o "a criatura ajuda".
- **Dicas por tipo de enigma** (`PuzzleService.dicasDe`):
  - na sequência, o nome de cada elemento na ordem;
  - no alinhamento, "<elemento> voltado para o <direção>".

  O texto das pistas usa as dicas **do enigma do mesmo capítulo**.
- **Requisitos de outros sistemas num enigma** (`requisitos`, a mesma regra dos livros, com o progresso fingido só na arena de teste) e o texto `semRequisito`.
- **Alinhamento:** cada toque devolve um texto curto ("o cristal agora aponta para…"); nunca o alvo.
- **Estado "Investigando" entre capítulos:** depois de concluir um capítulo, a investigação fica "Investigando" (antes voltava para "Descoberta").

## Arquivos

**Configs alteradas:** `InvestigationChapters` (capítulos 2 e 3), `Puzzles` (OlhosDoVigia, TresTorres) e `Secrets` (10 marcas, capacidade Olhar do Vigia, 2 recompensas, 2 registros, 1 conhecimento).

**Código:** `Investigacao` (estado entre capítulos), `Diario` (pistas por capítulo), `SecretRegistry` (`pista`, marcas com lista), `DiscoveryService` (pista por capítulo, fonte "pistas", blocos de teste), `PuzzleService` (`dicasDe`, requisitos, texto curto), `DiscoveryJournalService`, `MysterySystem` (progresso para requisitos), `AtlasDosArquivistas` (texto curto), `Remotos`.

**Testes e docs:** specs atualizados e novos, lore v2, doc 29 (tabela de estado), doc 10 (seção 21), este relatório e o README.

**Fora de `jogo-roblox/guardioes/`:** nada. Nenhum mapa ou modelo foi alterado: o Vigia, os cristais e as torres são blocos de teste.

## Verificado aqui

- **Equilíbrio de blocos:** 0 problemas nos 190 arquivos.
- **Spec novo:** confere que **todo elemento de enigma de capítulo tem uma marca no mapa** e que toda marca aponta para uma pista existente.

O Lune continua bloqueado, então os testes **não rodaram**.

## Pendente

- **Capítulo 4, a Chave Incompleta:** exige registrar o primeiro artefato ??? (arma, perfil e registro no `MetamorphicArtifactSystem`).
- **Modelo do Vigia:** você decide se reaproveita uma criatura existente ou faz um modelo novo; não mexi em nenhum modelo.
- **Roteiros V1 a V11 no Studio.**
