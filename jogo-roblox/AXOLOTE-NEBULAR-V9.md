# Axolote Nebular v9: Dragão das Constelações (Conceito B)

Prévia: `jogo-roblox/pilotos/axolote-nebular-v9.html`
Conceito de origem: `jogo-roblox/pilotos/axolote-v8-conceitos.html`, função `sdfB`.
Versões anteriores preservadas sem alteração: v7 (`axolote-nebular.html`) e v6.

> **Só prévia web (three.js).** Este arquivo serve para aprovar forma, materiais, tempos de animação e efeitos. **Nada aqui foi importado nem testado no Roblox Studio**, e ainda não existe um fluxo de exportação para o Roblox (ver seção 6).

---

## 1. De onde vem a geometria

A v9 usa um motor de animação e efeitos já existente, mas **a malha não é a da v7**. A anatomia `A` e a função `sdf` da v7 foram apagadas e trocadas pelo `sdfB` do Conceito B, com os refinamentos abaixo. O esqueleto também é novo.

| Parte | Conceito B (aprovado) | v9 |
|---|---|---|
| Crânio, focinho e mandíbula | elipsoide + cápsula + mandíbula | iguais, com focinho um pouco mais firme (raio de 0,13 para 0,125) e **ponta do focinho definida** (elipsoide nova em z = 1,08) |
| Olhos | órbita esculpida inclinada | mesma órbita; olho amendoado (escala 1,4 × 0,66, inclinação de -0,32 rad), reflexo em estrela e **pálpebra própria** dentro da órbita |
| Cristas | sobrancelha + cristais das têmporas | iguais |
| Pescoço em S | duas cápsulas | iguais, com fusão mais suave (0,10 para 0,11) |
| Peito e tronco | peito + tronco + quadril | iguais, com **peitorais** discretos e fusões mais largas (transição cabeça → tronco → cauda) |
| Placas dorsais | 4 placas, vão no meio | iguais; o vão recebe a **assinatura das Sete Estrelas** |
| Cauda em S | cadeia de 6 pontos | mesma cadeia, fusão 0,10 para 0,13 |
| Patas | 4 patas, 4 dedos | iguais |
| Brânquias | chama, 3 por lado | **mais baixas** (comprimento de 0,62/0,74/0,50 para 0,52/0,62/0,45; direção superior menos vertical), haste que afina, membrana translúcida com veios e 3 pontos de luz cada |
| Nadadeira | leque reto | leque **arredondado** que segue o S, com **borda ondulando** no shader (atributo `aEdge`) |
| Anéis | ouro (rot 1,2 / 0,3 / 0,55) e azul (rot 1,5 / -0,45 / -0,5) | mesmos tamanhos e inclinações, agora **3D com ornamentos**: 12 bossas de ouro, 18 lâminas no anel azul, gravações e 6 cristais / 12 fragmentos orbitando |

**Esqueleto novo (20 ossos):** root, spine, chest, **neck**, head, **tail1 a tail5** (seguindo o S), braços, antebraços, coxas, canelas e mãos.

## 2. Prova de que a malha é a do Conceito B

Medida feita em `pilotos/verificar-geometria-v9.js` (rode com `node verificar-geometria-v9.js axolote-v8-conceitos.html axolote-nebular-v9.html`), que roda as próprias funções `sdf` dos arquivos e compara as silhuetas (150 × 150) e o volume:

| Comparação (corpo esculpido, sem brânquias, anéis nem nadadeira) | Silhueta de lado | Silhueta de frente | Volume |
|---|---|---|---|
| **v9 × Conceito B** | **99,0%** | **94,3%** | **95,8%** |
| v9 × v7 reprovada | 43,7% | 49,8% | — |
| Conceito B × v7 (referência) | 43,6% | 50,9% | — |

A v9 coincide com o Conceito B. A pequena diferença vem só dos refinamentos (ponta do focinho, peitorais, base das brânquias e fusões mais suaves). Com a v7, a v9 se parece tão pouco quanto o próprio Conceito B.

## 3. Estados (mesmo controlador, ajustado à anatomia B)

| Estado | O que muda no corpo B |
|---|---|
| Idle | Flutuação, respiração, cauda em onda nos 5 segmentos com inércia (molas), brânquias independentes, comportamentos ocasionais (olhar para os lados, inclinar, olhar a câmera, seguir um fragmento, pequeno círculo) |
| Deslocamento | Steering sem teleporte; a cauda aumenta amplitude e frequência; as patas recolhem; os anéis inclinam na curva |
| Trabalho | Os anéis se aproximam do alinhamento; energia celestial sai da base das brânquias até o recurso |
| Comemoração | Pequena subida, giro elegante e mini-constelação |
| Descoberta rara | Ergue a cabeça, as constelações acendem em sequência, os anéis se alinham e um pulso cósmico percorre o corpo |
| Despertar Celestial | Cerca de 7 s, com opção de pular. Estrelas convergem, a nebulosa se forma, o corpo se materializa com borda ciano, as brânquias crescem, os anéis se desenham e ele abre os olhos |
| Contemplação Celestial | 12 s sem input, 60 s entre execuções concluídas. Ergue a cabeça, os anéis param quase por completo e se alinham, e as Sete Estrelas se formam acima |

O pescoço e a cabeça dividem a rotação (35–40% e 60–65%), e isso dá um atraso natural entre os dois. Ao alinhar, o anel azul cresce 24% para ficar concêntrico ao de ouro sem se tocarem.

## 4. Validação rodada

Testado no Chromium (Playwright, WebGL por software a cerca de 20 fps), percorrendo todos os estados em sequência. Não houve erro no console.

| Teste | Resultado |
|---|---|
| Folga mínima entre anéis e corpo/brânquias | 14,6 cm parado; **10,6 cm no pior momento** (deslocamento, descoberta e Despertar). Nunca se tocam |
| Folga mínima da cauda até o chão | 57 cm |
| Giro máximo da cabeça | cerca de 306°/s (limite do teste: 540°/s), sem estalos |
| Contemplação | Disparou, formou as Sete Estrelas, pulsou e concluiu (`done: 1`), com 60 s de intervalo ativo depois |
| Efeitos soltos no Idle | 0 |
| Partículas ativas | de 2 a 37 (pico na Descoberta rara) |

Imagens: `referencias/axolote-v9-validacao.png` (frente, lado, três quartos, silhuetas, Contemplação, Comemoração, Deslocamento, Trabalho, Descoberta rara e Despertar).

## 5. Efeitos

Poeira estelar sutil, constelações luminosas na pele (flancos, cauda e assinatura), rastro de nebulosa saindo da ponta da cauda durante o deslocamento, energia celestial na coleta, pulsos cósmicos na descoberta e efeitos exclusivos do Despertar. Os efeitos usam dois pools centrais de partículas, com o bloom moderado.

## 6. Roblox: situação real

- **Hoje o modelo só existe no visualizador web.** Não há arquivo `.fbx`, `.obj` nem `.glb` no repositório, e não existe um fluxo de exportação.
- Caminho proposto (**não testado**): exportar a malha esculpida + esqueleto em glTF/FBX, abrir no Blender, fazer retopologia ou decimação (cerca de 120 mil triângulos hoje; meta de até 10 mil por MeshPart), UV e bake da nebulosa em textura (SurfaceAppearance). Depois, importar como MeshPart com Bones.
- Animações: os tempos e curvas desta prévia são a especificação. Precisam ser refeitos em Luau (Bones no cliente) ou no Animation Editor. Os IDs só existem depois de publicar.
- Partículas, rastro e feixe: refazer com ParticleEmitter, Trail e Beam.
- Contemplação e diário: rascunhos em `luau-rascunho/` (o servidor valida, não duplica e não dá recompensa econômica), também **não testados**.
