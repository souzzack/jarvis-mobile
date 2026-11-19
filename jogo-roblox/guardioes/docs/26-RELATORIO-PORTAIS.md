# 26 · Relatório: portais entre dimensões (sem o Studio)

Data: 19/11/2026. **Nada foi executado** no Studio nem em runtime Luau.

Fecha o "DimensionSystem — portal" da arquitetura: viagem entre **places** do Roblox, cada dimensão no seu. **Nenhum mapa novo foi criado e o Campo das Bolhas não foi tocado:** só o id dele aparece na configuração.

## O que foi feito

| Área | Entrega |
|---|---|
| `Config/Dimensoes` | Ilha das Tempestades (hub) e Campo das Bolhas, com `placeId = 0` (a preencher quando os places forem publicados no mesmo experience). O Campo das Bolhas pede o diário do Guardião (Ato 1, passo 6) e mostra esse requisito em texto público |
| Portal | Part com o atributo `GuardioesPortal` (há um de teste perto da arena). O prompt "Atravessar" (B) abre a lista de dimensões na janela de viagem, com o estado de cada uma: "você está aqui", "atravessar", "bloqueada" (com o requisito) ou "em construção" |
| Regras | Perto do portal, a pé, sem montaria e sem dano recente (as regras da viagem rápida). Dimensão liberada e place publicado. **Voltar ao hub é sempre permitido** |
| Chegada | A dimensão fica marcada como **visitada** (`perfil.dimensoes`), o que livros e segredos usam. O jogador aparece ao lado do portal |

## Os dois riscos de verdade, e como foram tratados

**1. Trava de sessão no teleporte.**

- **O problema:** sem cuidado, o servidor de destino tenta carregar o perfil enquanto o de origem ainda segura a trava. O destino espera e pode até expulsar o jogador ("não foi possível carregar").
- **Antes do teleporte:**
  - `PlayerDataSystem.liberarParaPortal` **grava o perfil e libera a trava**;
  - a sessão de origem para de aceitar mudanças (`saindo`), então nada feito entre a gravação e a saída se perde;
  - o destino carrega na hora.
- **Se o teleporte falhar** (erro na chamada ou `TeleportInitFailed`), `retomarAposPortal` pega a trava de volta e o jogo continua normal.
- **Se outro servidor já tiver pegado a trava,** a sessão de origem fica só leitura. Assim nunca há dois servidores escrevendo o mesmo perfil.
- **Ajuste no salvamento:** o `salvar` agora **espera** um autosave em andamento em vez de desistir, porque a saída pelo portal precisa do resultado.

**2. TeleportData forjado.**

- **O problema:** os dados de teleporte passam pelo cliente.
- **O que se faz:** eles **só decidem onde o jogador aparece** e são lidos por `Portal.lerChegada`, que só aceita o formato exato com uma origem conhecida. Nenhum progresso vem dali; tudo vem do DataStore.

## Arquivos

**Criados:**

| Arquivo | Conteúdo |
|---|---|
| `src/ReplicatedStorage/Guardioes/Config/Dimensoes.luau` | Dimensões e places |
| `src/ReplicatedStorage/Guardioes/Viagem/Portal.luau` | Lógica pura: dimensão atual, estado do destino, TeleportData |
| `tests/Specs/Portal.spec.luau` | 4 casos |

**Com acréscimos:**
- `DimensionSystem`: portal, ATRAVESSAR, chegada, visitada, portal de teste.
- `PlayerDataSystem`: `liberarParaPortal`, `retomarAposPortal`, sessão `saindo`, `salvar` que espera.
- `ConfigServidor`: `raioPortal` e o marcador do portal.
- `Remotos`, `Mensagens`, `JanelaDeViagem` (lista do portal).
- Executores de teste, doc 10 (seção 19), README.

**Fora de `jogo-roblox/guardioes/`:** nada.

## Verificado aqui

- **Equilíbrio de blocos:** 0 problemas nos 167 arquivos.
- **Ligações:** `require` e nomes de RemoteEvent conferidos.
- **Mensagens:** nenhuma chave duplicada em `Mensagens`.

O Lune continua bloqueado, então os testes **não rodaram**.

## Limites honestos

- **Nada do teleporte real roda no Studio.** O `TeleportService` não funciona lá, e com os `placeId` em 0 o portal só mostra "em construção". Os roteiros X6 a X11 exigem **dois places publicados no mesmo experience**.
- **Os `placeId` precisam ser preenchidos por você** quando os places existirem. Não inventei números.
- **Ainda não há viagem em grupo** (a companhia atravessando junta).
- **A criatura ativa** reaparece normalmente no outro place, porque é recriada a partir do perfil salvo. Isso **não foi testado**.

## Pendente

- O place do Campo das Bolhas, que depende da sua autorização para mexer nele.
- Visual do portal.
- Viagem em grupo.
- Roteiros X1 a X11.
