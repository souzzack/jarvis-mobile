# 03 · Protótipo de combate (Etapa C)

> **Situação:** código escrito, **nunca executado**. Não houve Roblox Studio nem runtime Luau nesta sessão. Os passos para testar estão em `05-PLANO-DE-TESTES-STUDIO.md`.

## 1. O que o protótipo faz

- **Jogador (classe Espadachim):**
  - combo de 3 golpes (Corte 1, Corte 2, Estocada) e ataque pesado;
  - esquiva com invulnerabilidade de 0,05 s a 0,30 s;
  - defesa frontal de 120° que reduz 70% do dano;
  - aparar nos primeiros 0,18 s da defesa;
  - estamina, e guarda quebrada quando a estamina zera defendendo.
- **Criaturas:**
  - **Boneco de Treino:** 400 de vida, não ataca.
  - **Faísca Errante:**
    - 120 de vida e 60 de postura;
    - persegue o jogador e telegrafa o ataque com um brilho;
    - ataques: Investida (cone de 50°) e Descarga (círculo).
  - A postura cheia derruba a criatura por 2,5 s, e ela recebe +30% de dano nesse tempo.
  - Ela renasce depois de 60 s.
- **Arena de teste:** surge sozinha em (0, 4, 40) quando o place não tem pontos de surgimento. Para desligar: `ConfigServidor.arenaDeTeste.ativa = false`.

## 2. Fluxo de um golpe

```
Cliente (ControleDeCombate)                         Servidor (CombatSystem)
───────────────────────────                         ───────────────────────
clique → cópia local da MaquinaDeCombo aceita?
  sim → FireServer(ATACAR, idDoAlvoMirado) ───────▶ balde de taxa (12 fichas, 8/s)
        (efeito do arco quando a cópia                avança a máquina OFICIAL (os.clock do servidor)
         chega ao evento "Golpe")                     pedirAtaque → cobra estamina
                                                      … preparo …
                                                      evento "Golpe" → teste geométrico com a posição
                                                      do SERVIDOR: distância + arco + altura (sem .Touched)
                                                      até 3 alvos → EnemySystem.receberGolpe
◀──────── RESULTADO_GOLPE (todos) ◀──────────────── dano / postura / quebra
◀──────── REJEITADO (só o autor) ◀───────────────── se recusou: cliente volta ao estado neutro
```

**Criatura atacando.** O EnemySystem telegrafa (o evento `TELEGRAFIA` chega a todos os clientes). No impacto, ele chama `CombatSystem.danoAoJogador`. O servidor resolve a defesa nesta ordem: esquiva → aparar → defesa → acerto (`Dano.resolver`). Quando o jogador apara, a criatura recebe postura.

## 3. Por que é seguro contra trapaça

| Ataque de trapaça | Defesa no protótipo |
|---|---|
| Mandar "acertei" | O cliente **não** diz o que acertou. Só pede o golpe e sugere um alvo. O servidor testa com a própria posição. |
| Acelerar o combo | O tempo vem do `os.clock()` do servidor. Pedidos cedo demais são recusados (`"cedo"`). |
| Inundar o RemoteEvent | Balde de fichas por jogador. O excesso é descartado e contado. |
| Mira sugerida falsa | Ganha só +30° de arco, **nunca** mais alcance, e apenas se o alvo existir. |
| Tipos inválidos | O tipo de mensagem precisa ser um número conhecido, e o id do alvo uma string curta. Qualquer outra coisa é ignorada. |
| Estamina infinita | A estamina existe só no servidor. O cliente apenas mostra o número recebido. |

## 4. Peças

| Arquivo | Tipo | Responsabilidade |
|---|---|---|
| `Config/Combate.luau` | dados | regras globais (estamina, esquiva, defesa, aparar, combo, postura, rede, mira) |
| `Config/Armas/Espada.luau` | dados | tempos, alcance, arco, dano, postura e custo de cada golpe |
| `Config/Inimigos/*.luau` | dados | vida, postura, ataques e IA de cada criatura |
| `Config/Raridades.luau` | dados | as 8 raridades e o teto de melhoria (ainda não usado no combate) |
| `Combate/MaquinaDeCombo.luau` | lógica pura | estados do personagem, combo, buffer, esquiva, defesa e atordoamento |
| `Combate/Dano.luau` | lógica pura | fórmula e resolução de um golpe |
| `Combate/Estamina.luau`, `Combate/Postura.luau` | lógica pura | recursos com recuperação |
| `Combate/Alcance.luau` | lógica pura | arco, frente e distância no plano |
| `Util/LimiteDeTaxa.luau`, `Util/Sinal.luau` | lógica pura | limite de rede e sinal simples |
| `Rede/Remotos.luau` | Roblox | tipos de mensagem; o servidor cria `ReplicatedStorage.Remotos.Combate` |
| `Sistemas/CombatSystem.luau` | servidor | autoridade do combate do jogador |
| `Sistemas/EnemySystem.luau` | servidor | criaturas, IA a 10 Hz, sono a mais de 250 studs |
| `Controladores/ControleDeCombate.luau` | cliente | entrada (PC, controle e toque), previsão local, esquiva física, mira suave |
| `Controladores/HudDeCombate.luau` | cliente | vida, estamina, barras dos inimigos, números de dano, avisos, telegrafia |

## 5. Limites conhecidos do protótipo

- **Animações:** nenhuma ID foi inventada. A tabela `Animacoes` do controlador começa vazia, e por enquanto só aparece um efeito de arco provisório.
- **Ainda não implementado:**
  - atributos e equipamento: o multiplicador de dano é sempre 1 (Etapa D);
  - XP e loot: o evento `morreu` já existe, mas ninguém o escuta ainda (Etapas D e E);
  - troca manual de alvo por Tab ou toque. Por enquanto a mira é só automática.
- **Previsão do cliente:** quando o servidor rejeita um pedido, o cliente reinicia a cópia local da máquina. Pode haver um pequeno salto visual se o ping for alto.
- **Pesado em botão próprio:** o pesado usa R ou Y, e não "segurar o ataque". Assim o ataque leve sai sem esperar o "segurar" ser detectado. O GDD 5.1 já foi atualizado.
