# 31 · Relatório: mistérios, capítulo 4 — a Chave Incompleta (sem o Studio)

Data: 19/11/2026. **Nada foi executado** no Studio nem em runtime Luau.

## Uma correção de rumo

No relatório 30 eu disse que o capítulo 4 exigiria registrar o primeiro artefato ??? jogável. Relendo o complemento, o capítulo 4 pede "um artefato que **não pode ser ativado completamente** na Ilha". Por isso:
- o capítulo entrega a **Chave Incompleta**, um **Fragmento Desconhecido**, e não uma arma;
- a chave **abre a pesquisa** da Lâmina do Não-Existente;
- a Lâmina continua sem registro no sistema de artefatos, porque a fabricação dela depende dos capítulos 6 e 7.

## O que foi feito

| Peça | Entrega |
|---|---|
| Capítulo 4 | O nicho que as torres abriram e a anotação de A. dizem onde estão os **três dentes da chave**. Enigma de **coleta**, em qualquer ordem |
| Dente do alto | Fica sobre uma coluna de 14 studs. Dá para alcançar **voando, de planador, de montaria ou pelos 7 degraus**. O voo não é obrigatório (seção 13 do complemento). O servidor confere a distância, então pegar de baixo não funciona |
| Recompensa | Folha de Registro, 300 XP, o registro "A Chave Incompleta" (**Fragmento Desconhecido**, o primeiro do jogo) e a **marca interdimensional** `ChaveIncompleta`. A marca fica salva e será usada por um enigma Interdimensional no Campo das Bolhas (capítulo 5) |
| Pesquisa ??? | As pesquisas dos 3 artefatos ??? agora entram no diário. A da Lâmina aparece depois do capítulo 4 como **"Artefato desconhecido (???)"**: o nome real só aparece na etapa 4, quando a receita é descoberta, e as etapas futuras aparecem como "???" |
| Diário | Registros com a categoria (registro antigo, conhecimento proibido, fragmento desconhecido). A coleta mostra "Você guardou o … (n de 3)" |
| Lore | Cânone **v3**: a chave tem três dentes separados de propósito, a outra metade da fechadura está noutra dimensão e o metal está "fora do índice". Nada anterior foi contradito |

## Arquivos

- **Configs:** `InvestigationChapters` (capítulo 4), `Puzzles` (DentesDaChave), `Secrets` (5 marcas, recompensa, registro) e `SecretArtifacts` (`revelaNomeNaEtapa`).
- **Código:**
  - `Dados/Perfil`: `misterios.marcas`, com validação e migração automática;
  - `SecretRewardService`: concede marcas;
  - `SecretRegistry`: pesquisas dos artefatos; marcas de coleta e exploração;
  - `ArtifactResearchService`: nome escondido;
  - `DiscoveryService`: marcas no contexto do enigma, dentes, coluna e degraus de teste;
  - `PuzzleService`: texto da coleta;
  - `AtlasDosArquivistas`: categorias e textos.
- **Testes e docs:** specs, lore v3, doc 29 (tabela de estado), doc 10 (seção 22), este relatório e o README.

**Fora de `jogo-roblox/guardioes/`:** nada. Nenhum mapa ou modelo foi alterado.

## Verificado aqui

- **Equilíbrio de blocos:** 0 problemas nos 190 arquivos.
- **Degraus:** 7 degraus de 2 studs até o topo da coluna (14). O pulo padrão do Roblox, de uns 7 studs, alcança cada degrau com folga.

O Lune continua bloqueado, então os testes **não rodaram**.

## O que vem depois (precisa de você)

| Próximo | Depende de |
|---|---|
| **Capítulo 5** (a Mensagem Entre Dimensões) | O **Campo das Bolhas** existir como dimensão jogável. Você pediu para não mexer nele: preciso da sua autorização |
| **Capítulo 6** e a **Biblioteca do Vazio** | Aprovação para construir o **primeiro mapa secreto** |
| **Capítulo 7** e o **primeiro artefato ??? jogável** | Capítulos 5 e 6. Aí registro a Lâmina (arma, perfil e registro no sistema de artefatos) |

Até lá, a investigação para no capítulo 5 com "ainda não disponível", como o complemento pede.
