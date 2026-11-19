# 12 · Relatório das Etapas 6 a 9 (feitas sem o Roblox Studio)

Data: 19/11/2026. **Nada foi executado** no Studio nem em runtime Luau.

## Em uma frase

Ficaram escritos, de ponta a ponta (servidor, cliente e lógica pura com testes), cinco blocos:
- as **criaturas companheiras** com IA por espécie;
- a **evolução** salva;
- as **montarias** terrestres e voadoras;
- os **livros mágicos** com aprendizado permanente;
- o **PlayerDataSystem**, que faltava para que algo ficasse salvo de verdade.

## 1. O que foi feito

| Etapa | Entrega |
|---|---|
| Base | **PlayerDataSystem.** DataStore nova (o save do tycoon não é tocado), trava de sessão dentro de UpdateAsync, transação com cópia e validação, autosave que renova a trava, BindToClose. Perfil de versão mais nova fica só para leitura. Save antigo vira `legadoMagnata` intacto. Sem acesso à API, roda só em memória e avisa |
| 6 | **CompanionSystem e IA.** Uma criatura ativa por jogador. A IA roda a 10 Hz e a personalidade vem da espécie: lado, distância, altura, coragem e curiosidade. Comandos acompanhar, permanecer e retornar; afagar com recarga; renomear com o filtro de texto do Roblox; teleporte quando fica longe; ataque ou fuga em combate. Modelo provisório feito de blocos |
| 7 | **Evolução.** O servidor confere XP, vínculo, marcos e desafio. É permanente, é salva, e a criatura troca de porte. A XP e o vínculo vêm de vitórias com a criatura por perto. Há ganchos `registrarMarco`, `registrarDesafio` e `registrarObjetivoDimensional` para o QuestSystem |
| 8 | **Montarias.** O MountSystem confere espécie e estágio, distância, a caixa de espaço da espécie e o estado do jogador. A montaria terrestre usa a velocidade e o salto da espécie. A voadora usa o mesmo núcleo de voo, com o perfil da espécie (as habilidades do jogador não alteram a criatura). Só desmonta no chão. Renascer, trocar de criatura ou um teleporte desfazem a montagem |
| 9 | **MagicBookSystem.** Livros como ProximityPrompt (tecla B), requisitos avaliados no servidor, texto público quando recusado (o Manuscrito não revela nada). O livro lido e as habilidades são salvos e nunca precisam ser achados de novo. Na arena há pedestais provisórios |
| Cliente | **PainelDeCompanheiros.** Painel recolhível (K) com cartões e o que falta para evoluir; atalhos T, H e V; placas de nome; avisos de livros. Montado numa criatura voadora, Espaço duas vezes faz decolar |

## 2. Arquivos criados nesta etapa

| Arquivo | Linhas |
|---|---|
| `src/ReplicatedStorage/Guardioes/Companheiros/IADoCompanheiro.luau` | 110 |
| `src/ReplicatedStorage/Guardioes/Util/Requisitos.luau` | 57 |
| `src/ServerScriptService/Guardioes/Dados/Perfil.luau` | 139 |
| `src/ServerScriptService/Guardioes/Dados/TravaDeSessao.luau` | 37 |
| `src/ServerScriptService/Guardioes/Sistemas/CompanionSystem.luau` | 632 |
| `src/ServerScriptService/Guardioes/Sistemas/MagicBookSystem.luau` | 179 |
| `src/ServerScriptService/Guardioes/Sistemas/MountSystem.luau` | 230 |
| `src/ServerScriptService/Guardioes/Sistemas/PlayerDataSystem.luau` | 220 |
| `src/StarterPlayer/StarterPlayerScripts/Guardioes/Controladores/PainelDeCompanheiros.luau` | 309 |
| `tests/Specs/IADoCompanheiro.spec.luau` | 91 |
| `tests/Specs/PerfilSalvo.spec.luau` | 89 |
| `tests/Specs/Requisitos.spec.luau` | 49 |
| `docs/12-RELATORIO-ETAPAS-6-A-9.md` | 65 |

**Arquivos já existentes que receberam acréscimos:** `Remotos` (3 RemoteEvents novos), `Mensagens`, `PerfilEfetivo` (montaria fora do "*"), `ConfigServidor` (criaturas, progresso e livros de teste; seção `dados`), `Main.server`, `Main.client`, `MovementAbilitySystem` (persistência), `MovementSystem` (montar, desmontar, voo da montaria), `ControleDeLocomocao`, os executores de teste e os docs 08, 10 e README.

**Fora de `jogo-roblox/guardioes/`:** nada foi alterado (Ilha, oficina e Campo das Bolhas intactos).

## 3. O que foi verificado aqui

| Verificação | Resultado |
|---|---|
| Equilíbrio de blocos nos 82 arquivos `.luau` | 0 problemas |
| Todos os `require` (compartilhados, `script.Parent.Parent.…` do servidor e os do executor Lune) apontam para arquivos existentes | Ok |
| Valores esperados dos 23 casos novos | Conferidos à mão (exemplo: a escolta do Cão fica em (5,6; 0; 3,5); o Nebu chega a XP 610 e vínculo 300, mas faltam os marcos) |

Não houve execução de Luau nem checagem de tipos.

## 4. Pendente

- **Studio:**
  - rodar os 104 testes automáticos e os roteiros C1 a C15 (`10`, seção 6);
  - confirmar os riscos 6 a 8 do `08` (sela por HipHeight, criaturas sem desvio de obstáculos, DataStore no Studio).
- **Etapa 10:** ligar os objetivos dimensionais aos eventos reais do QuestSystem. A lógica e os ganchos já existem.
- **Etapas 11 e 12:** InventorySystem com GUID (os artefatos passam a ser salvos e a troca de estágio fica atômica), formas de combate do Cajado e do Arco, QuestSystem e ProgressionSystem.
- **Arte:** modelos e animações reais das criaturas e dos estágios (`09`); sons próprios.
- **Lune:** continua não instalado. Se for autorizado, os testes de lógica rodam aqui.
