# Axolote Nebular v10: correção facial, rig e animações

Prévia: `jogo-roblox/pilotos/axolote-nebular-v10.html` (a v9 continua em `axolote-nebular-v9.html`, sem alterações).
Base: Conceito B, Dragão das Constelações. Medições: `pilotos/verificar-geometria-v9.js` (forma) e os testes ao vivo da própria página.

> **Só prévia web (three.js).** Nada aqui roda no Roblox Studio ainda. A seção 7 diz o que se transfere e o que precisa ser refeito.

---

## 1. Diagnóstico técnico da v9

### Onde as coisas estão

| Parte | Arquivo / função | Como era construída |
|---|---|---|
| Corpo (malha única) | `axolote-nebular-v9.html` → `sdf()` → `sculpt()` (surface nets) → `bodyGeometry()` | Campo de distância esculpido, uma malha fechada com pele (`SkinnedMesh`) |
| Olhos | `buildCreature()` → grupos `eye±1` filhos do osso `head` | Esfera com textura de canvas, achatada (1,4 × 0,66) e girada −0,32 rad; órbita esculpida no `sdf` com **outra** forma (elipsoide alinhado aos eixos do mundo) |
| Pálpebras | Hemisfério escuro (`#3b1f86`) girando de −126° a +76° | Uma só pálpebra, sem a inferior |
| Boca | `TubeGeometry` escura no grupo `face` (origem em −head) | Linha de 7 mm de raio sobre a pele; em Comemoração e Descoberta, `mouth.scale.set(1−0,25m, 1+1,2m, 1)` |
| Rig | `BONES` (20 ossos), pesos `weights()` = inverso da distância⁴ até cada segmento, 4 maiores | Brânquias, olhos e boca são malhas rígidas presas ao osso `head` |
| Controlador | `updateCreature()` | Um estado por vez; cada estado define metas `tg`, suavizadas em `P`; molas na cabeça, cauda e brânquias |
| Câmera | Botões de vista com posições **fixas** | Sem seguir o personagem |

O modelo exibido é o mesmo que foi modificado: a página publicada é gerada a partir desse arquivo. A v10 é um arquivo novo com link próprio.

### Problemas confirmados (medidos, não suposições)

| # | Problema | Evidência | Causa no código |
|---|---|---|---|
| 1 | **Boca voa para fora do rosto** em Comemoração e Descoberta | Canto da boca a 33 cm da pele com `mouth=0,5` e a 83 cm com `mouth=1` | `scale` aplicada a uma malha cuja origem é a origem do corpo (y = 0), não o centro da boca |
| 2 | **Olho solto dentro de um buraco** (aparência "estranha") | 343 de 360 pontos da frente do olho com vão; até 4,4 cm entre o olho e a órbita | Olho e órbita usam formas e orientações diferentes |
| 3 | **Brânquias se descolam da base** quando a cabeça gira | Base das brânquias com peso de pele de 47–52% na cabeça e 43–46% no pescoço, mas a brânquia é 100% rígida na cabeça | Pesos por distância: a base fica a igual distância dos dois ossos |
| 4 | **Salto de giro** ao interromper a Comemoração | 34° num único quadro (Comemoração → Descoberta) | `P.spin = tg.spin` sem suavização; em qualquer outro estado o alvo é 0 |
| 5 | **Personagem sai do enquadramento** | Captura da vista Lado durante o Deslocamento: cabeça e brânquias cortadas | Câmera fixa; o trajeto vai ±1,7 m para os lados e o corpo mede 4,6 m |
| 6 | **Interpolação dependente da taxa de quadros** | `P += (alvo − P) · min(1, dt·k)` e as molas com um passo de Euler por quadro | A 20 fps e a 120 fps o resultado diverge |
| 7 | **Giro rápido ao parar ou começar a andar** | Medido na v10 antes da correção: até 600°/s em Idle 0,15 s | O alvo de rumo trocava de uma vez entre a direção da velocidade e a direção de frente, quando a velocidade cruzava 0,12 |
| 8 | **Anéis com rolagem dobrada** | `tiltG.rotation.z −= roll·0,25`, mas o anel já é filho da coluna, que herda o roll do grupo | Rotação aplicada duas vezes |
| 9 | **Pivô de giro na origem do modelo** (pés e peito) | O corpo vai até z = −3,35; no giro, a cauda varria um círculo de 3,4 m | O grupo girava em torno de (0, 0, 0) |
| 10 | **Reflexo do olho cobrindo a pupila** | Estrela de 0,75 × raio centrada a 0,38 × raio; ela cobre o centro | Posição e tamanho do reflexo |
| 11 | **Brânquias tremendo** em quedas de quadros | Mola com amortecimento 0,4 do crítico, alimentada pela derivada da guinada da cabeça sem filtro | Derivada ruidosa + mola pouco amortecida |
| 12 | Trabalho podia não voltar ao Idle | Sem limite de tempo enquanto não "chega" | Saída dependia só de `arrive` |

### Hipóteses descartadas

- **Rotações acumulando quadro a quadro:** não acontece. Todos os ossos usam `rotation.set(...)` a partir da pose-base.
- **Matrizes desatualizadas:** não encontrei. A pele usa as matrizes do mesmo quadro, e os testes leem `updateMatrixWorld`.
- **Dois estados mexendo no mesmo osso ao mesmo tempo:** não acontece. Só um estado está ativo, e cada componente tem uma única fonte. O conflito real era o item 4 (giro) e o item 8 (roll duas vezes).

## 2. O que mudou na v10

### Rosto
- **Olho e órbita compartilham o mesmo elipsoide orientado** (0,088 × 0,062 × 0,062, inclinado 0,2 rad). A órbita é esculpida com 1,1 cm de folga, e o olho é posicionado a partir da superfície real da cabeça. Resultado: simetria de 0,000 mm entre os olhos e nenhum ponto enterrado.
- **Íris procedural:** violeta profundo, fibras radiais e um anel ciano em volta da pupila. A **pupila é escura e claramente visível**, e o reflexo estelar fica fora dela. A córnea é translúcida e reflete o ambiente.
- **Duas pálpebras por olho** (superior e inferior), da mesma família de elipsoide. Elas giram em volta do eixo do olho. Há também um contorno suave esculpido em volta da órbita.
- **Expressões:** piscadas naturais (às vezes duplas, e uma a cada troca de estado), olhar com pequenas sacadas, curiosidade, concentração (pálpebras semicerradas, pupila menor, olhar para baixo), surpresa (olhos bem abertos, pupila maior), satisfação (pálpebra inferior sobe) e serenidade.
- **Boca nova:** um vinco esculpido no focinho e uma faixa escura com bordas suaves, que segue a superfície (todos os vértices são projetados nela). As expressões neutra, curiosa, surpresa e feliz são *morph targets* que nunca somam mais de 1, para a boca não sair da pele.
- **Anatomia:** focinho mais fino e alongado, ponte do focinho, bochechas que sustentam os olhos e mandíbula mais estreita. A resolução da escultura subiu de 2,1 para 1,75 cm.

### Rig
```
AxoloteNebular (grupo: posição e rotação, pivô no centro de massa)
└── BodyRig (deslocado do centro de massa)
    ├── SkinnedMesh corpo + nadadeira  ← 20 ossos
    │   root ─ spine ─ chest ─ neck ─ head ─┬─ EyeR / EyeL (olho, córnea, LidUpper, LidLower)
    │   │       │       │                   ├─ Mouth (MouthLine)
    │   │       │       │                   └─ gill×6 (haste, membrana, veios)
    │   │       │       └─ armL/foreL/pawL, armR/foreR/pawR
    │   │       └─ RingPrimary / RingSecondary (sistema orbital preso ao tronco)
    │   ├─ tail1…tail5 (cauda em S)
    │   └─ thighL/shinL, thighR/shinR
    └── SkinnedMesh constelações (mesmo esqueleto)
Efeitos: pools centrais na cena, etiquetados pelo estado que os criou
```
- **Pivô no centro de massa** (0, 0,70, −0,85): giro, inclinação, câmera e constelações partem dele.
- A cabeça começa exatamente onde o pescoço termina. O crânio, a nuca e a base das brânquias seguem a cabeça (93–100%).

### Controlador
- **Interpolação exponencial** `1 − e^(−k·dt)` em toda pose, rumo, inclinação e expressão. Molas com subpassos de 8 ms.
- **Três camadas separadas:** locomoção (posição e rumo), pose corporal (ossos) e cosméticos (materiais e partículas).
- **Rumo:** mistura contínua entre a direção de frente e a direção do movimento, com giro máximo de 1,8 rad/s.
- **Giro da Comemoração:** soma ao ângulo atual; se for interrompido, completa até o múltiplo de 360° mais próximo.
- **Prioridades:** Despertar 5, Descoberta 4, Comemoração 3, Trabalho 2, Deslocamento/Contemplação 1, Idle 0. Os botões da prévia forçam a troca.
- **Saída de estado:** as partículas do estado anterior se apagam em até 0,3 s. O feixe, a luz do recurso e a constelação somem sozinhos. O Trabalho tem limite de 12 s para chegar.

### Câmera da prévia
- Enquadra pelo **raio que o personagem ocupa**, calculado pelo campo de visão vertical e horizontal (funciona em tela de celular em pé).
- **Segue o centro de massa** com suavização, sobe para incluir as Sete Estrelas quando elas aparecem e respeita a órbita manual do usuário.
- Vista nova **Rosto** (close na cabeça, girando junto com o personagem).

## 3. Testes

Rodados no Chromium (Playwright, WebGL por software, cerca de 20 fps), com a página real. Os testes ficam ao vivo no painel da prévia. Nenhum erro de script em nenhuma rodada.

### Sequências pedidas (v10 final)

| Sequência | Voltou ao Idle | Velocidade máx. do centro de massa | Giro máx. do corpo | Folga dos anéis | Boca × pele | Efeitos soltos |
|---|---|---|---|---|---|---|
| Idle → Deslocamento → Idle | sim | 1,22 m/s | 105°/s | 14,6 cm | 1,5 mm | 0 |
| Idle → Trabalho → Idle | sim | 0,72 m/s | 110°/s | 14,6 cm | 1,4 mm | 0 |
| Idle → Comemoração → Idle | sim | 1,16 m/s | 384°/s (giro da comemoração) | 14,6 cm | 1,4 mm | 0 |
| Deslocamento → Trabalho → Idle | sim | 0,75 m/s | 110°/s | 14,6 cm | 1,4 mm | 0 |
| Idle → Contemplação → Deslocamento | sim (interrompida com suavidade) | 1,49 m/s | 106°/s | 14,6 cm | 1,4 mm | 0 |
| Despertar → Idle → Descoberta rara | sim | 2,25 m/s* | 15°/s | 14,6 cm | 2,3 mm | 0 |

\* No primeiro quadro do Despertar, quando o corpo ainda está invisível (materialização a partir de 1,6 s).

Na v9, a mesma medição achou 3,86 m/s (o círculo do idle sumindo de um quadro para o outro), um salto de giro de 34° num quadro, e a boca a até 83 cm da pele.

### Outras verificações
- **Taxa de quadros:** 22,5 s de estados simulados a 20 fps e a 120 fps terminam a no máximo **3,8 cm e 3,4°** um do outro.
- **Olhos:** simetria de 0,000 mm no espaço da cabeça, nenhum ponto do olho dentro da pele, borda com 1,7 cm de folga coberta pela pálpebra.
- **Enquadramento:** a câmera mede as extremidades reais na tela (focinho, ponta da cauda, brânquias, anéis, patas e as Sete Estrelas quando aparecem) e ajusta a distância. Nas sequências, nada saiu da tela. O pior caso encostou na borda: uma estrela da constelação, por um instante.
- **Celular (390 × 844):** os botões ficam abaixo da imagem e o personagem aparece inteiro nas vistas Três quartos e Lado, inclusive durante o Deslocamento. Não há rolagem lateral.
- **Desempenho:** não medi em celular de verdade. No navegador simulado roda a cerca de 20 fps por software, o que não representa um aparelho real.

Imagens: `referencias/axolote-v10-validacao.png`.

## 7. Roblox

| Parte | Transfere? | O que fazer |
|---|---|---|
| Malha do corpo (≈170 mil triângulos, 20 ossos) | Sim, depois de preparada | Exportar (glTF/FBX), decimar no Blender para até 10 mil triângulos por MeshPart, criar UV e assar a nebulosa numa textura (SurfaceAppearance). Importar como MeshPart com Bones |
| Olhos e pálpebras | Sim | Malhas separadas presas ao osso da cabeça. A íris procedural vira textura com a pupila num decal ou Texture separada para o olhar se mover (offset de textura no cliente) |
| Boca | Parcial | Morph targets **não** existem no Roblox. Opções: trocar texturas de boca (neutra, curiosa, surpresa, feliz) ou usar ossos faciais (2–3 bones no lábio) |
| Brânquias, nadadeira e constelações | Sim | Malhas leves com Bones. A ondulação da borda da nadadeira vira animação de osso |
| Anéis | Sim | MeshParts simples. O giro e o alinhamento ficam no cliente (RenderStepped), ancorados ao Bone do tronco |
| Animações | **Refazer** | Os tempos, curvas e prioridades desta prévia são a especificação. Implementar em Luau no cliente, mexendo nos Bones a partir da pose-base (como aqui), ou gravar no Animation Editor. Os IDs só existem depois de publicar |
| Expressões | Refazer | Mesmo controlador de expressão, mexendo em Bones das pálpebras e na textura da boca |
| Efeitos | Refazer | ParticleEmitter, Trail, Beam e Attachments, com as mesmas cores e tempos. O Neon substitui o bloom |
| Integração com ajudantes | Planejada | O controlador de estados vira um ModuleScript no cliente. O servidor só decide estados que mexem em economia (coleta, descoberta) e envia eventos; o cliente anima. Rascunhos em `luau-rascunho/` (não testados) |
