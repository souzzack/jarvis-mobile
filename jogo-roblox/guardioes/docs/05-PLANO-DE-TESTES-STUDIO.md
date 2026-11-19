# 05 · Plano de testes no Roblox Studio

> Nada aqui foi executado ainda. Marque cada item conforme testar e anote o que falhar (com a mensagem do Output).

## 0. Preparar sem arriscar o place original

1. **Abrir uma cópia.** Abra uma **cópia** do place (File → Save to File → `Guardioes-teste.rbxl`). Nunca teste no place publicado.
2. **Trazer o código.** Escolha uma das duas formas:
   - **Com Rojo (recomendado):**
     - instale o Rojo 7 e o plugin do Studio;
     - em `jogo-roblox/guardioes/`, rode `rojo serve`;
     - no plugin, clique em *Connect*.
     - O `default.project.json` só cria pastas chamadas `Guardioes` (mais `ServerStorage.GuardioesTestes`). O resto do place não é tocado.
   - **Sem Rojo:** recrie a árvore à mão.
     - Cada pasta de `src/` vira uma Folder.
     - Cada `.luau` vira um ModuleScript com o mesmo nome, sem a extensão.
     - `Main.server.luau` vira um **Script** chamado `Main`.
     - `Main.client.luau` vira um **LocalScript** chamado `Main`.
3. **Ativar a checagem de tipos.** Em *Script Analysis*, confirme que não há erros. Todos os arquivos usam `--!strict`, e os avisos de tipo devem ser anotados.

## 1. Testes de lógica pura (rápidos, sem jogar)

- [ ] Na barra de comandos: `require(game.ServerStorage.GuardioesTestes.Studio)()`
- [ ] Esperado: `Resultado: N passaram, 0 falharam`.
- [ ] Quem tiver o **Lune** pode rodar `lune run tests/rodar-lune.luau` em `jogo-roblox/guardioes/`; o resultado deve ser o mesmo.

## 2. Teste solo (Play, 1 jogador)

| # | Passo | Esperado | ✓ |
|---|---|---|---|
| 2.1 | Dar Play | Output sem erros. Aparecem o Boneco e duas Faíscas perto de (0, 4, 40). `ReplicatedStorage.Remotos.Combate` existe. O tycoon funciona como antes. | |
| 2.2 | Clicar uma vez perto do Boneco | Efeito de arco. O número 10 aparece sobre o Boneco, e a barra de vida dele cai. | |
| 2.3 | Clicar 3 vezes no ritmo | Golpes de 10, 12 e 18. O 3º leva mais postura (barra amarela), com o bônus de combo perfeito. | |
| 2.4 | Clicar muito rápido, sem ritmo | Os cliques cedo demais são ignorados. Nada de golpes duplicados nem de combo acelerado. | |
| 2.5 | Apertar R | Golpe pesado: preparo longo e 28 de dano. | |
| 2.6 | Atacar até a estamina acabar | A barra verde cai, aparece o aviso "Sem estamina" e o golpe não sai. Ela recupera depois de cerca de 0,8 s. | |
| 2.7 | Q ou Shift andando / parado | Dash de cerca de 12 studs na direção do movimento; parado, vai para trás. Gasta 25 de estamina. Não dá para esquivar de novo antes de cerca de 0,8 s. | |
| 2.8 | Golpear o Boneco até a postura encher | A postura zera, o Boneco fica atordoado por 2,5 s e o dano sobe cerca de 30%. | |
| 2.9 | Aproximar-se de uma Faísca | Ela persegue, **brilha** antes de atacar e então investe. | |
| 2.10 | Levar a Investida sem defender | 14 de dano na vida. | |
| 2.11 | Segurar o botão direito **logo no começo** do brilho (bem antes do impacto), virado para ela | Aviso "Defendido (4)": 14 × 30% ≈ 4. A estamina cai cerca de 8,4. | |
| 2.12 | Apertar a defesa **no instante** do impacto | Aviso "Aparado!", sem dano. A Faísca ganha postura. | |
| 2.13 | Defender virado de costas | Leva o dano cheio (a defesa vale só de frente). | |
| 2.14 | Esquivar no meio do impacto | Aviso "Esquivou", sem dano. | |
| 2.15 | Defender com a estamina quase zerada | Aviso "Guarda quebrada!" e atordoamento de 1,2 s. | |
| 2.16 | Matar a Faísca | Ela some depois de cerca de 1,5 s e renasce em cerca de 60 s. | |
| 2.17 | Fugir para mais de 60 studs | A Faísca desiste e volta ao ponto de surgimento. | |
| 2.18 | Ficar a mais de 250 studs | As criaturas param de pensar (sono). Medir a CPU no MicroProfiler. | |

## 3. Teste multiplayer (Test → Clients and Servers, 2 ou 3 jogadores)

- [ ] Dois jogadores batem no mesmo inimigo: os dois veem os números de dano e as barras sincronizadas.
- [ ] A Faísca escolhe um alvo e o troca quando ele foge.
- [ ] Com *Incoming Replication Lag* de 0,2 s (Studio → Network), os golpes de perto ainda acertam. Pode haver um pequeno salto visual na correção.
- [ ] Um jogador morre e renasce: o combate dele recomeça do zero, sem estado preso.
- [ ] Um jogador sai no meio do combate: nenhum erro no Output.

## 4. Segurança (pelo console do cliente, em Play)

- [ ] **Flood:**
  ```lua
  for i = 1, 500 do
  	game.ReplicatedStorage.Remotos.Combate:FireServer(1)
  end
  ```
  Esperado: no máximo cerca de 12 golpes aceitos no instante e nenhum erro no servidor.
- [ ] **Tipo inválido:** `FireServer("x")` e `FireServer(99)` → ignorados.
- [ ] **Alvo falso:** `FireServer(1, string.rep("a", 500))` → o alvo é ignorado e o golpe é normal.
- [ ] **Alvo longe:** mandar o id de uma Faísca a 30 studs → não acerta (a mira não aumenta o alcance).

## 5. Celular e controle

- [ ] **Emulador de celular** (Test → Device): aparecem 4 botões de toque (Atacar, Pesado, Defesa, Esquiva). Eles não cobrem o joystick.
- [ ] **Segurar Defesa no toque:** a defesa fica ativa enquanto o dedo está no botão.
- [ ] **Controle:** R2 ataca, Y faz o pesado, L2 defende e B esquiva.

## 6. Coexistência com o tycoon

- [ ] O `MagnataHUD` continua aparecendo e funcionando.
- [ ] Os terrenos, as moedas e os funcionários funcionam como antes do Rojo.
- [ ] O save do tycoon carrega igual: as DataStores não mudaram.

## 7. Como relatar

Para cada falha, anote:

- o número do teste;
- a mensagem do Output (com o nome do script e a linha);
- o que aconteceu de fato.

Com isso eu corrijo direto no código. Os ajustes de equilíbrio ficam todos nos arquivos `Config/`, como tempos, dano e custo.
