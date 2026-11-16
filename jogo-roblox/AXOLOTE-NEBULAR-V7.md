# Axolote Nebular v7: Guardião das Constelações

Prévia: `jogo-roblox/pilotos/axolote-nebular.html` (a v6 está preservada em `axolote-nebular-v6.html`).
Símbolo: `jogo-roblox/simbolos/sete-estrelas.svg`.
Rascunhos em Luau: `jogo-roblox/luau-rascunho/` (**não testados**: o Roblox Studio não estava conectado).

> **Importante:** a prévia roda no navegador (three.js). Ela serve para aprovar forma, materiais, tempos de animação e efeitos. **Nada disto está implementado no Roblox ainda.** A seção "Transferência" diz o que entra direto e o que precisa ser refeito.

---

## 1. O que mudou da v6 para a v7

| Área | v7 |
|---|---|
| Anatomia | Focinho um pouco mais longo e olhos ~7% menores (menos infantil); volumes discretos de ombro e flanco; crista dorsal sutil; cauda 30 cm mais longa, que afina até a ponta |
| Nebulosa | Mantida. Constelações dos flancos reposicionadas para dar lugar à assinatura |
| Assinatura | **As Sete Estrelas em miniatura no dorso**, com as cores dos seis mundos e a estrela central |
| Brânquias | Veios luminosos finos nas membranas, além das estrelas internas do shader |
| Cauda | Ponta com energia cósmica suave (brilho pulsante) |
| Anéis | **Agora são peças 3D**, com espessura real (seção retangular), metal e gravações. A Órbita Primordial é de ouro gravado com inscrições e tem 6 cristais orbitais. A Órbita Nebular é violeta e azul, com poeira estelar gravada e 12 fragmentos |
| Comportamento dos anéis | Idle: giro lento. Deslocamento: inclinam levemente com a curva. Trabalho: alinhamento parcial e brilho no feixe. Comemoração: aceleram e brilham. Descoberta: alinham e pulsam. Contemplação: param quase por completo e se alinham |
| Idle | Duas variações novas: **acompanhar um fragmento dourado com os olhos** e **um pequeno círculo no ar** |
| Comemoração | Mais majestosa: subida menor, giro elegante e uma **pequena constelação** acima no lugar da explosão de partículas |
| Trabalho | Os anéis se aproximam do alinhamento e as constelações do corpo acendem enquanto ele concentra a energia |
| Novos estados | **Despertar Celestial** (desbloqueio, com opção de pular) e **Contemplação Celestial** (secreta) |

## 2. Estados e prioridades

O controlador é um só. Cada estado define a pose-alvo, e a troca de estado é sempre suavizada: não há loops paralelos competindo.

| Estado | Entra quando | Pode ser interrompido por |
|---|---|---|
| Despertar | Desbloqueio do ajudante (uma vez) | Pular, ou qualquer estado pedido pelo jogo |
| Idle | Padrão | Tudo |
| Deslocamento | O ajudante precisa se mover | Trabalho, Comemoração, Descoberta |
| Trabalho | O sistema de coleta pede ajuda | Comemoração, Descoberta |
| Comemoração | Recurso coletado (confirmado pelo servidor) | Descoberta |
| Descoberta rara | Recurso raro confirmado pelo servidor | Nada (é curta, cerca de 3,4 s) |
| Contemplação | Ver a seção 3 | **Qualquer input do jogador** e qualquer outro estado |

## 3. Contemplação Celestial (comportamento secreto)

**Gatilho:** o jogador está parado há 12 s, o ajudante está em Idle há pelo menos 2 s, o último estado concluído não foi uma Contemplação nos últimos 60 s, os efeitos estão ligados, e o ajudante está perto da câmera e dentro do enquadramento.
**Interrupção:** qualquer clique, toque, tecla ou rolagem. O estado volta para Idle e o controlador suaviza a pose e os anéis. Os efeitos temporários se apagam em até 1,3 s.
**Intervalo:** 60 s contados a partir de uma Contemplação **concluída**. Uma interrompida não conta.

| Fase | Tempo | Corpo | Anéis | Efeito |
|---|---|---|---|---|
| 1. Percepção | 0–1 s | Desacelera cauda, brânquias e patas; ergue a cabeça para o céu | Normais | Estrelas da pele acendem de leve |
| 2. Alinhamento | 1–3 s | Flutua 6 cm mais alto, quase imóvel | Desaceleram até 12% e se alinham no plano seguro da Órbita Primordial | — |
| 3. Formação | 3–5 s | Olhando para cima | Alinhados | Seis luzes saem da cabeça e viram as seis estrelas; as linhas se desenham; a Sétima Estrela surge no centro |
| 4. Pulso | 5–6 s | Expressão serena (pálpebras abaixam um pouco) | Brilho percorre os anéis | Pulso violeta e dourado na constelação, que percorre as constelações e as estrelas do corpo. A descoberta é pedida aqui |
| 5. Dissipação | 6–8 s | Abaixa a cabeça e volta ao Idle | Voltam às inclinações e velocidades normais | A constelação some devagar |

## 4. O Segredo das Sete Estrelas

- **Símbolo:** dois triângulos de raios diferentes (o maior com Tempestades, Vulcões e Costas do Gigante; o menor com Campo das Bolhas, Cidade Congelada e Achados e Perdidos) em volta da **Sétima Estrela**, branca e dourada, ligada às outras por raios finos.
- **Cores:** Tempestades `#3B82F6`, Bolhas `#2DD4BF`, Vulcões `#EF4444`, Congelada `#BAE6FD`, Gigante `#F5C76B`, Achados `#A855F7` e Sétima `#FFF4D6`.
- **Reuso:** o mesmo SVG serve para entalhes em ruínas, templos, portais, monumentos, páginas de livros e laboratórios abandonados. Os dados (posições, cores e linhas) estão no módulo `SeteEstrelas.lua`, para que enigmas futuros comparem a mesma geometria.
- **Mistério:** nada no código ou no texto explica a Sétima Estrela.

### Registro no diário

- **Prévia:** grava no navegador e não duplica.
- **Jogo (rascunho):** o cliente envia `PedirDescoberta("constelacao_sete_estrelas")`. O servidor confere o id, o ajudante equipado, se o jogador estava parado (medido no servidor), duplicidade e limite de pedidos. Só então salva pelo serviço de dados existente e responde com `DescobertaRegistrada`.
- **Sem recompensa econômica:** fica para depois de revisar o balanceamento.
- **Ainda não existe no projeto:** um diário ou sistema de exploração. Pelo que se sabe do place, não há. Isso precisa ser confirmado na auditoria antes de criar algo novo.

## 5. Despertar Celestial (cerca de 7 s, pode ser pulado)

| Tempo | O que acontece |
|---|---|
| 0–1,2 s | Estrelas giram e convergem para um ponto |
| 0,8–3,6 s | Nebulosa de cores se forma e depois dá lugar ao corpo |
| 1,6–3,4 s | O corpo se materializa com uma borda ciano luminosa; as brânquias crescem entre 2,2 e 3,6 s |
| 3,0–3,9 s | A Órbita Primordial se desenha |
| 3,5–4,4 s | A Órbita Nebular se desenha |
| 4,2–5,0 s | As constelações do corpo acendem em sequência |
| 5,0–5,4 s | Ele abre os olhos |
| 5,3 s | Pulso celestial |
| 5,5–7 s | Sobe até a altura normal de flutuação |

## 6. Transferência para o Roblox

| Parte | Situação | O que falta |
|---|---|---|
| Malha do corpo (malha única com 18 ossos) | Transfere | Tem cerca de 120 mil triângulos. **Precisa de retopologia ou decimação** (meta de até 10 mil por MeshPart) e de **UV** para receber textura. Feito no Blender |
| Nebulosa e estrelas da pele | Refazer | É shader. No Roblox vira textura pintada a partir de UV (SurfaceAppearance). O brilho emissivo depende do suporte da versão atual |
| Constelações, assinatura e estrela da testa | Transfere | Exportar como malha fina com Bones e material Neon |
| Anéis 3D | Transfere | Malhas simples (seção retangular); textura com as inscrições; giro e alinhamento no cliente |
| Animações | Refazer | Os tempos e curvas desta prévia são a especificação. Implementar em Luau mexendo nos Bones (cliente) ou gravar no Animation Editor; os IDs só existem depois de publicadas |
| Partículas, feixe, rastro e pulsos | Refazer | ParticleEmitter, Beam, Trail e Attachments, com as mesmas cores e tempos |
| Contemplação e diário | Rascunho em Luau | Integrar ao controlador de ajudantes e ao serviço de dados reais |

## 7. Otimização

- Partículas num pool central (dois sistemas para todos os ajudantes), com orçamento reduzido no modo gráfico reduzido.
- Ajudantes distantes atualizam a cada 3 quadros, sem efeitos, com anéis simplificados (40 segmentos) e sem cristais orbitais.
- A Contemplação e o Despertar só rodam no ajudante principal, perto da câmera e dentro do enquadramento.
- Só duas luzes dinâmicas ligadas ao personagem: a do núcleo (fraca) e a do recurso no Trabalho.
