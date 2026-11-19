# 09 · Plano de animações e efeitos

> **Nenhuma ID de animação foi inventada.** As chaves (`HorizonteCorte1`, `CaoMontaria`…) ficam nas configs. As IDs entram depois do upload no Studio. Todas as animações serão **originais**: feitas no Blender (já instalado no ambiente) ou no Animation Editor do Studio. Nada vem de terceiros.

## 1. Personagem em voo (rig R15)

| Chave | Estado | Duração | Ideia |
|---|---|---|---|
| `VooDecolagem` | Decolagem | 0,3 a 0,8 s (segue `perfil.decolagem`) | Agacha, impulsiona e os braços abrem; corta para Pairar |
| `VooPairar` (loop) | Pairar | 2 s | Flutuação leve (a respiração sobe e desce 0,2 stud) e as pernas balançam |
| `VooFrente` (loop) | Voo | 1,2 s | Corpo a 60° na horizontal, braços para trás; a **inclinação nas curvas vem da física** (AlignOrientation), não da animação |
| `VooImpulso` (loop) | Impulso | 0,8 s | Corpo esticado, um braço à frente |
| `VooDescida` (loop) | Descida | 1 s | Pernas à frente, preparando o pouso |
| `VooPouso` | Pouso | 0,3 a 0,7 s | Flexiona os joelhos e se recupera |
| `VooInterrompido` | Interrompido | 0,6 s | Tropeço no ar, depois queda controlada |
| `PlanadorAbrir` / `PlanadorLoop` / `PlanadorFechar` | Planando | 0,35 s / loop / 0,3 s | O tecido desdobra das costas; o corpo fica pendurado |

**Prancha, vassoura e plataforma:** a pose em pé sobre a prancha (`PranchaPe`) inclina com a curva e agacha no impulso; a vassoura usa a pose sentada.

**Reaproveitamento:** os loops de voo servem para Voo mágico, Asas (com as asas animadas à parte) e montarias voadoras (pose de cavaleiro).

## 2. Transformações de artefato (sincronizadas com `transformacao.duracao`)

| Artefato | Sequência (`montagem` na config) | Efeito |
|---|---|---|
| Espada → Prancha (0,6 s) | GirarLamina → AbrirGuarda → RecolherCabo → AlargarLamina → AcenderVeios | Faíscas nas juntas; os veios azuis acendem de trás para frente |
| Prancha → Espada (retorno ao combate) | Inverso, em 0,6 s, durante a queda amortecida | Arco elétrico curto na mão quando fica pronta |
| Escudo → Plataforma (0,7 s) | DeitarEscudo → BrotarRaizes → AbrirFolhas → Flutuar | Folhas giram, pó verde |
| Cajado → Vassoura (0,5 s) | GirarCajado → DeitarHorizontal → AbrirCerdasDeVento → Assento | Redemoinho |
| Arco → Asas (0,45 s, ???) | PartirArco → CordaViraEixo → PenasDeLuzBrotam → AsasAbrem | Exclusivo: penas de luz dourada que deixam rastro de constelação |

**Produção:**
- **Modelagem e rigging:** um modelo por artefato com ossos (lâmina, guarda, cabo) e animação de montagem no Blender, exportados em FBX para o Studio.
- **Animação no jogo:** o controlador toca a animação do **objeto** e a do **personagem** juntas.
- **Hoje:** existem apenas peças provisórias (Parts que encolhem e crescem).

## 3. Criaturas (por estilo, reaproveitáveis)

| Estilo | Espécies | Conjunto por estágio |
|---|---|---|
| Flutua | Axolote Nebular | ocioso, seguir, curioso, cura, reação à chuva |
| Saltita | Lebre-de-Faísca | ocioso, pulo, cavar, farejar, susto |
| Trota | Cão-Trovão | ocioso, trote, corrida, mordida, latido, **montaria** (galope, salto, frear) |
| Plana | Raia-das-Nuvens | ocioso, planar, bater asas, mergulho, **montaria** (decolar, voar, pousar) |

- **Por estágio:** cada um tem um conjunto próprio. O filhote é mais desajeitado, com cabeça grande e passos curtos; o juvenil é ágil; o adulto é estável e poderoso.
- **O que se mantém:** a identidade da espécie (silhueta, paleta e marcas).
- **Variantes de afinidade:** apenas material e partículas extras (veios elétricos, bolhas, fissuras, cristais). Elas não exigem novas animações.

## 4. Efeitos e qualidade gráfica

| Efeito | Baixo | Médio | Alto |
|---|---|---|---|
| Rastro (Trail) | 0,18 s | 0,35 s | 0,55 s |
| Partículas de voo | desligadas | 10/s | 26/s |
| Efeitos de outros jogadores | até 180 studs | até 180 studs | até 180 studs |
| Faíscas da transformação (futuro) | 0 | poucas | completas |

As paletas por perfil estão em `EfeitosDeVoo` (Arcano, Raio, Penas, Folhas, Vento, Tecido, Asas de Luz, Raia).

**Sons (a produzir):** todos sintetizados ou gravados para o jogo, sem bibliotecas de terceiros com restrição.
- vento em camadas pela velocidade;
- zumbido elétrico da prancha;
- folhas da plataforma;
- "whoosh" no impulso;
- estalo da transformação.
