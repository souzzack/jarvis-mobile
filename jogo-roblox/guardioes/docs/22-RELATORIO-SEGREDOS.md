# 22 · Relatório: segredo ??? do Ato 1 (sem o Studio)

Data: 19/11/2026. **Nada foi executado** no Studio nem em runtime Luau.

O `SecretDiscoverySystem` implementa a cadeia que leva ao **Arco das Asas Perdidas** (qualidade ???). Ele segue o GDD (7.3 e "Segredo ??? do Ato 1") e o modelo de segurança do rascunho `luau-rascunho/DescobertasServico.lua`, que **não foi alterado**.

## A cadeia

| # | Etapa | Como se faz | Onde |
|---|---|---|---|
| 1 | O vidro que lembra do céu (`LentesNaOrdem`) | O telescópio mostra uma anotação que cita **3 mundos**. O jogador liga cada mundo à cor da sua estrela e gira as lentes nessa ordem | Observatório restaurado |
| 2 | Anotações nas margens (`MargensDosLivros`) | Examinar as margens dos 3 livros lidos (botão no diário) | Diário (Y) |
| 3 | Sete estrelas sob a chuva (`SeteEstrelasSobChuva`) | Contemplar no Santuário, **sob chuva**, com o Axolote ativo (Juvenil ou Adulto). O jogador fica **parado 11 s**, medidos pelo servidor. A constelação aparece com uma estrela maior | Santuário |
| 4 | Os seis pilares (`PilaresDasSeteEstrelas`) | Tocar os 6 pilares coloridos a partir da estrela maior, dando a volta no anel. Errar apaga todos | Altar |
| 5 | Artefato Desconhecido nº 1 | A câmara sob o altar se abre. O diário mostra a descrição com palavras ainda como "???"; elas aparecem conforme a cadeia avança | Altar |
| 6 | O Manuscrito Sem Nome (`ReceitaArcoDasAsas_Parte1`) | Ler o Manuscrito, que pede as etapas 2 e 3. Isso já existia no `MagicBookSystem` | Livro |
| 7 | Orvalho entre mundos | Componente **do Campo das Bolhas**: bloqueado até essa dimensão existir. O diário mostra só "O que falta não existe nesta ilha." | — |
| 8 | Arco das Asas Perdidas (`ArcoForjado`) | Ritual no altar: as etapas 5 a 7, mais Coração da Tormenta ×1, Pena do Relâmpago Antigo ×3 e Lente Espectral ×2, numa transação só. Dá o Arco no estágio 1 | Altar |

## Como fica difícil de copiar e seguro

- **Ordens por jogador.** A ordem das lentes e a estrela inicial dos pilares saem de uma **semente por jogador**, que usa um **sal secreto** guardado só no servidor. Quem conhece o algoritmo não calcula a ordem de outro jogador. A lógica (mundo → cor, dar a volta no anel) continua a mesma para todos, como pede o GDD.
- **O cliente só pede.** Os lugares usam ProximityPrompt (tecla B). O servidor confere tudo: restauração, etapa anterior, livro lido, Axolote ativo, chuva e posição parada medida por ele mesmo. Há também limite de pedidos.
- **O cliente não recebe a cadeia.** A cadeia, os textos e as soluções ficam em `ConfigSecreta/SegredosAto1` (só servidor). O cliente recebe nome e texto **só** do que o jogador já descobriu; o resto chega como "???". Os prompts não têm nome de objeto.
- **Nada à venda e nada por sorte.** Os materiais do ritual vêm de chefes com drop garantido (Loot).
- **Descoberta individual.** O progresso fica no perfil de cada jogador. A companhia pode ajudar, mas não desbloqueia por ninguém.

## Ciclo corrigido no design

O GDD dizia "fazer a Contemplação Celestial", mas essa habilidade é do Axolote **adulto**. Para ficar adulto ele precisa do marco `AxoSeteEstrelas`, e esse marco só pode sair desta cadeia. Era um ciclo sem saída.

- **Correção:** contemplar no Santuário é uma **ação do jogador** com o Axolote Juvenil ou Adulto ativo. O GDD foi atualizado nesse ponto.
- **Marcos que agora são registrados:** o sistema registra três que **nenhum sistema registrava antes**:
  - `AxoPrimeiraConstelacao`, em qualquer contemplação completa;
  - o desafio `AxoNoiteDeTormenta`, ao contemplar sob chuva;
  - `AxoSeteEstrelas`, ao completar os pilares.
- **Resultado:** o Axolote consegue chegar a Adulto.
- **Ainda pendente:** `AxoExplorarCaverna` (exigido para Juvenil) continua sem quem o registre.

## Chuva

Não existia clima no jogo.

- Se nenhum sistema marcar `Workspace.GuardioesChuva`, o próprio sistema roda um ciclo simples: chove 4 min a cada 20 min.
- O **visual da chuva** ainda não existe.
- No teste, `ignorarChuva` deixa contemplar a qualquer hora.

## Arquivos criados

| Arquivo | Conteúdo |
|---|---|
| `src/ReplicatedStorage/Guardioes/Segredos/Descoberta.luau` | Lógica pura, sem segredos: hash, semente, permutação, ordem circular, sequência, revelação gradual, situação da cadeia |
| `src/ServerScriptService/Guardioes/ConfigSecreta/SegredosAto1.luau` | A cadeia, textos, sal, lentes, ritual (só servidor) |
| `src/ServerScriptService/Guardioes/Sistemas/SecretDiscoverySystem.luau` | Lugares, prompts, contemplação, ritual, diário, chuva |
| `src/StarterPlayer/StarterPlayerScripts/Guardioes/Controladores/DiarioDeDescobertas.luau` | Diário (Y), margens, contagem e constelação na tela |
| `tests/Specs/Descoberta.spec.luau` | 9 casos, incluindo a coerência da cadeia (sem ciclo, ids, materiais) |

**Arquivos existentes com acréscimos:**
- `ConfigServidor`: marcadores de teste, `ignorarChuva`, `ignorarAxolote`.
- `Remotos`: Segredo e EventoSegredo.
- `Main.server`, `Main.client`.
- Executores de teste.
- Docs 01 (o ciclo) e 10 (seção 15), README.

**Fora de `jogo-roblox/guardioes/`:** nada. Os rascunhos em `luau-rascunho/` foram só lidos. Nada do Campo das Bolhas foi tocado: o componente dele é só uma etapa bloqueada na configuração.

## Verificado aqui

- **Equilíbrio de blocos:** 0 problemas nos 152 arquivos.
- **Ligações:** `require` e `ctx.obter` conferidos.
- **Hash:** `Descoberta.hash` foi conferido em Python contra o FNV-1a de referência ("a" = 3826002220).
- **Bug de precisão corrigido antes do commit:** `h × 16777619` passaria de 2^53 e perderia dígitos no Luau. A multiplicação agora é dividida.
- **Permutação:** 40 sementes geram as 6 ordens possíveis de 3 lentes.

O Lune continua bloqueado, então os testes **não rodaram**.

## Pendente

- Visual: chuva, brilho das lentes e dos pilares, a câmara se abrindo, o Arco.
- A direção do anel nos pilares não é indicada. O jogador pode precisar de duas tentativas; é aceitável, mas pode virar dica.
- Etapa 7 e o desafio "A Sétima Estrela" (estágio 2 do Arco): dependem do Campo das Bolhas e de dimensões futuras.
- Marco `AxoExplorarCaverna`.
- Portais entre places, relíquia, Bancada e Depósito da base, objetivos semanais das companhias.
- Roteiros S1 a S16 no Studio.
