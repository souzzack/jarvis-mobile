# Magnata do Multiverso: direção artística

Este é o padrão visual de todo o jogo. Ele **substitui** o guia antigo de voxel neon (`jogo-roblox/guia-de-estilo.md`, na branch `claude/fervent-wright-sq1pub`). As tabelas de raridade, chances e valores daquele guia continuam valendo até o dono do jogo decidir outra coisa.

A arte do **Fragmento Celestial** (`jogo-roblox/referencias/fragmento-celestial.png`) é a referência de **qualidade**, não de forma. Nenhum outro objeto deve parecer um cristal com anéis dourados.

> **Realismo de expectativa.** A referência é uma ilustração. No Roblox, em tempo real e rodando em celular, ela não sai igual. O objetivo é chegar ao mesmo **nível de cuidado**: silhueta, camadas de detalhe, contraste de materiais e luz. Pintura de conceito é a meta de direção, e o critério de aprovação é sempre o modelo dentro do jogo, em Play.

---

## 0. Situação atual (auditoria parcial)

A auditoria completa precisa do Roblox Studio aberto. Esta parte foi montada a partir do histórico da sessão que ficou conectada ao Studio em 15/11. **Confirme tudo dentro do Studio antes de mexer.**

**O que existe (versão 20 do place):**
| Onde | O quê |
|---|---|
| `Workspace.Galpao.Terrenos.Terreno1` a `Terreno6` | Os 6 terrenos dos jogadores, com barracão de zinco 3D (frente aberta) |
| `ReplicatedStorage.Magnata.Assets.Cenario` | `GalpaoVelho` (aprovado) e `GalpaoTech` (frente fechada, **não aprovado**) |
| `ReplicatedStorage.Magnata.Modelos` | Módulo que monta prédios (`M.predio(...)`) |
| `ReplicatedStorage.Magnata.Ativos` | Módulo de importação de assets (`A.importar(...)`) |
| `ServerScriptService.Magnata.Servicos.Galpao` | Serviço dos galpões |
| `PlayerGui.MagnataHUD` | Interface principal |
| `ServerStorage.Vitrine` e `ServerStorage.GalpaoTech_frenteFechada` | Área de testes e a sede rejeitada, fora do jogo |

**Aprovado e funcionando (preservar):** funcionários 3D (faísca de macacão, geleia rosa, robô de latão), esteira em trilho de mina com carrinho, placa em arco de latão, barracão dos terrenos e todos os scripts de economia, dados e HUD.

**Pendente:** sede tecnológica com a frente aberta, Campo das Bolhas em 3D, cientistas (Dra. Nova, Dr. Magma, Prof. Chronos), ajudantes das Bolhas e do Portal, 14 raridades, catálogo, missões e eventos.

**Ferramentas que a sessão do Studio tinha:** `execute_luau`, `screen_capture`, `start_stop_play`, `save_place`, `generate_mesh` (malha gerada por IA dentro do Studio) e `generate_texture` (textura PBR por IA). As duas últimas são o caminho mais realista para chegar perto da referência sem Blender.

**Problema já visto:** retexturizar uma malha com `generate_texture` refez a geometria e fechou a frente da sede. Retextura só em malha que pode mudar de forma, ou revise a forma depois de toda retextura.

### Checklist da auditoria no Studio
1. Listar tudo em `Workspace`, `ReplicatedStorage`, `ServerStorage` e `ServerScriptService` (nome, classe e número de peças).
2. Medir cada modelo: Parts, MeshParts, triângulos, peças Neon, luzes e emissores.
3. Capturar cada área em Play: de perto, na altura do jogador e de longe.
4. Dar uma nota de 1 a 3 a cada modelo: **manter**, **refinar** (geometria boa, acabamento fraco) ou **reconstruir** (forma genérica, caixa empilhada, só recolorido).
5. Marcar quais modelos são lidos por scripts (nomes, atributos, tags, `PrimaryPart`). Esses são reconstruídos **com o mesmo nome, pivô e atributos**, para não quebrar nada.
6. Salvar o resultado em `jogo-roblox/auditoria.md` antes de mudar qualquer modelo.

---

## 1. Os pilares

1. **Silhueta antes de tudo.** O modelo é reconhecível em preto chapado, sem partículas e sem brilho.
2. **Três camadas de detalhe.** Forma principal (70% da leitura), formas secundárias (20%: bordas, reforços, apoios, ornamentos) e detalhe fino (10%: rebites, runas, rachaduras, musgo). Nenhuma camada pode faltar.
3. **Três famílias de material em cada modelo importante:** natural (pedra, madeira, gelo, osso, planta), trabalhado (metal, latão, ouro, cerâmica) e energia (cristal, plasma, luz). O contraste entre elas é o que dá riqueza.
4. **A energia é rara.** Brilho e Neon cobrem no máximo **10% da área visível** de um modelo. Brilho sempre tem fonte, seja um cristal, uma runa ou um núcleo, e nunca pinta uma peça inteira sem motivo.
5. **Tudo conta uma história.** Desgaste onde se pega, musgo onde bate pouca luz, fuligem perto do calor, gelo nas quinas viradas para o vento.
6. **Grande, médio e pequeno.** Cada região tem um monumento visível de longe, pontos de interesse no meio do caminho e detalhes que premiam quem chega perto.
7. **Bonito com tudo no mínimo.** O jogo continua legível e agradável sem Bloom, sem partículas e na qualidade gráfica mais baixa.

## 2. Linguagem de forma

- **Nada de caixa empilhada.** Toda peça grande ganha chanfro, inclinação, afunilamento ou quebra de simetria. Paredes têm base mais larga, faixa de remate e topo trabalhado.
- **Proporção heroica:** bases largas e pesadas, topos leves e elaborados, com o olhar subindo.
- **Repetição com variação:** blocos, telhas e pedras se repetem, mas com tamanho, rotação ou desgaste diferentes (±5 a 10%).
- **Formas de cada dimensão.** Cada mundo tem um vocabulário de forma, não só uma paleta (veja a seção 5).
- **Escala do jogador:** o avatar padrão tem cerca de 5 studs. Portas com pelo menos 8 studs, corredores com pelo menos 6 studs de largura, degraus de 1 stud. Monumentos de 60 studs ou mais, para serem vistos de longe.

## 3. Materiais no Roblox

| Família | Como fazer | Evitar |
|---|---|---|
| Pedra e rocha | MeshPart com `SurfaceAppearance` (PBR) ou `MaterialVariant` próprio de Slate, Basalt ou Limestone | `Plastic` liso em rocha |
| Madeira, osso e planta | `MaterialVariant` de Wood ou `SurfaceAppearance`; folhagem em MeshPart com `Leafy Grass` ou textura própria | Esfera verde como copa |
| Metal e ouro | `Metal` ou `Foil` com cor envelhecida, ou `SurfaceAppearance` com metalness | Ouro amarelo puro chapado |
| Cristal | `Glass` com `Transparency` 0,3 a 0,5, mais um núcleo `Neon` menor dentro (é o que dá o efeito "translúcido com luz interna") | Cristal 100% Neon |
| Energia | `Neon` em peças finas, mais `Beam`, `Trail` ou `ParticleEmitter`; `ForceField` para campos | Neon em superfícies grandes |

- **MaterialVariant** por dimensão, em `MaterialService`: cada mundo tem a sua pedra, o seu metal e o seu chão.
- **Cor nunca 100% saturada nem 100% preta.** Escuros com um pouco da cor do mundo.

## 4. Luz e atmosfera

A configuração fica num módulo `ReplicatedStorage.Magnata.Ambiente`, que aplica o preset da dimensão quando o jogador entra nela (com transição `SUAVE` de 0,6 s). **Os valores abaixo são pontos de partida para testar em Play, não valores finais.**

**Base global**
- `Lighting.Technology = Future` (com fallback automático em aparelhos fracos)
- `Lighting.EnvironmentDiffuseScale = 0.6` e `EnvironmentSpecularScale = 0.8`, para o PBR reagir à luz
- **Bloom** contido: `Intensity 0.35`, `Size 20`, `Threshold 1.2`. O Neon brilha e o resto não estoura.
- `ColorCorrection` com `Contrast 0.08` e `Saturation 0.1` na base; o `TintColor` vem da dimensão.
- `DepthOfField` **só em cenas** (descoberta de raridade alta, câmera de abertura de mundo), nunca na exploração.

| Dimensão | Hora e céu | Atmosphere (Density / Haze / cor) | Tint | Luz de destaque |
|---|---|---|---|---|
| Ilha das Tempestades | Noite com nuvens carregadas | 0,38 / 1,5 / azul-ardósia | azul-frio leve | Relâmpagos com flash de `Brightness` por 0,1 s |
| Campo das Bolhas | Fim de tarde, céu pastel | 0,30 / 2,0 / rosa-lilás | quente rosado | Bolhas com reflexo e `PointLight` turquesa fraca |
| Ilha dos Vulcões | Crepúsculo de fumaça | 0,45 / 2,5 / cinza-laranja | âmbar | Rios de lava com `SurfaceLight` alaranjada |
| Cidade Congelada | Manhã clara e fria | 0,32 / 1,0 / branco-azulado | ciano frio | Sol baixo, sombras longas, cristais com luz interna |
| Costas do Gigante | Dia nublado com raios de sol | 0,35 / 1,8 / verde-acinzentado | verde-musgo | Fachos de luz (`Beam`) entre as árvores gigantes |
| Achados e Perdidos | Céu impossível, sem hora | 0,25 / 0,5 / violeta | magenta leve | Luzes vindas de baixo e de lados "errados" |

## 5. As seis dimensões

A regra principal é que **nenhuma dimensão reaproveita a mesma construção trocando a cor**. Cada uma tem forma, material e vegetação próprios.

| Dimensão | Vocabulário de forma | Arquitetura | Natureza | Monumento visível de longe | Partículas ambiente | Paleta |
|---|---|---|---|---|---|---|
| **Ilha das Tempestades** | Vertical, pontiagudo, em ziguezague | Torres meteorológicas de metal rebitado com para-raios e bobinas | Rochas suspensas por campos elétricos, cristais em leque | Torre-Para-Raios gigante que atrai os relâmpagos | Faíscas soltas, chuva fina | azul elétrico `#2F7BFF`, ciano `#43D9FF`, prata `#B8C2D6`, violeta `#7A4DFF`, escuro `#10142B` |
| **Campo das Bolhas** | Redondo, inflado, orgânico | Casas em flores e cascas, cúpulas de bolha | Flores gigantes, cogumelos, lagos que flutuam | Flor-Mãe com uma bolha-lago no topo | Bolhas subindo, pólen | turquesa `#3FE0C8`, rosa `#FF8FCB`, lilás `#B9A2FF`, verde `#7EDC6A`, azul-claro `#9FD8FF` |
| **Ilha dos Vulcões** | Maciço, quebrado, em cunha | Fortalezas esculpidas em basalto, fornalhas, pontes de obsidiana | Rochas com veios de magma, árvores carbonizadas | Grande Fornalha com chaminés que cospem brasa | Brasas e cinza subindo | laranja `#FF7A1A`, vermelho `#D6321E`, dourado `#FFC24A`, preto `#1A1214`, cinza `#4A4448` |
| **Cidade Congelada** | Facetado, simétrico, em agulha | Torres cristalinas, relógios e engrenagens congelados | Árvores de gelo, estalactites, neve acumulada nas quinas | Relógio-Torre parado no meio do tique-taque | Neve leve, cristais de gelo cintilando | azul glacial `#7FD8FF`, branco `#F2F7FF`, prata `#C4CCDA`, violeta `#9C8CFF` |
| **Costas do Gigante** | Colossal, curvo, envelhecido | Ruínas sobre as costas de um gigante adormecido, escadarias, arcos quebrados | Árvores gigantes com raízes sobre as pedras, musgo, fósseis | O próprio gigante: um ombro e uma mão de pedra saindo da terra | Folhas caindo, poeira dourada nos fachos de luz | verde profundo `#2E5B3A`, pedra `#8A8578`, dourado antigo `#C9A24A`, azul `#4A7FA8` |
| **Achados e Perdidos** | Impossível, invertido, fragmentado | Construções de cabeça para baixo, escadas que dão voltas, portas no ar | Objetos de outras dimensões soltos (um pedaço de cada mundo) | Ilha invertida com um portal quebrado pendurado | Fragmentos flutuando ao contrário (descem para cima) | violeta `#7A3DFF`, magenta `#E040C8`, azul cósmico `#1E2A78`, dourado `#E8B54A`, preto `#0B0814` |

## 6. Categorias

### Minérios e recursos
- Cada raridade muda **forma, material e efeito**, e não só a cor. Exemplo: comum é um cristal único fosco; raro, um cacho com núcleo; épico, um cacho com runas na base; lendário, um cristal flutuante com anel mecânico; o mais raro tem geometria "errada", que gira por partes.
- Cada dimensão tem o seu **formato de cristal**: em leque (Tempestades), bolha cristalizada (Bolhas), lasca de obsidiana com veio (Vulcões), agulha hexagonal (Congelada), âmbar com fóssil dentro (Gigante) e fragmento com pedaço de outro mundo preso (Achados e Perdidos).
- A lista final de raridades (o guia antigo tem 5; o pedido é de 14) está **a confirmar** com o dono do jogo.

### Criaturas e ajudantes
- A anatomia tem lógica: onde dobra, como anda, o que come.
- Cada uma traz um traço material da dimensão de origem (casca de bolha, couraça de basalto, pelagem com geada).
- Animações mínimas: parado (respirando), andando, trabalhando e reagindo a uma raridade alta.

### Máquinas
- As peças mostram a função: entrada de minério, mecanismo, saída e fonte de energia.
- Sempre há **uma parte móvel principal** (broca, pistão, engrenagem, roda) e duas ou três secundárias.
- Tubos, cabos e suportes ligam a máquina ao chão e ao cenário. Nada fica flutuando sem motivo.
- Cada nível de upgrade ganha **peças novas**, e não só cor.

### Equipamentos
- Escala certa na mão do avatar, com a empunhadura clara.
- A progressão aparece na forma: cabo de madeira, depois metal e depois cristal com mecanismo.

### Portais
- Um por dimensão, cada um com mecanismo próprio: anéis que giram (Tempestades), pétalas que abrem (Bolhas), comporta de fornalha (Vulcões), engrenagem de relógio (Congelada), arco de pedra que acende runa por runa (Gigante) e moldura quebrada que se monta no ar (Achados e Perdidos).

## 7. Animação

- **Um controlador só.** Um `LocalScript` em `StarterPlayerScripts` anima tudo o que tem a tag `Anim_*` (CollectionService): flutuar, girar, pulsar e balançar. Ele só anima o que está a menos de 150 studs da câmera e respeita o orçamento de qualidade (seção 8).
- Animação ambiente roda **só no cliente**, nunca no servidor.
- Princípios: antecipação antes do golpe, impacto com achatamento rápido, movimento secundário (cabos, folhas, chapéus atrasados) e nada parado por completo (respiração, brilho pulsando).
- Vocabulário de tempo (valem para o jogo todo):

| Nome | Duração | Estilo | Uso |
|---|---|---|---|
| `RAPIDO` | 0,15 s | Quad Out | Cliques, piscadas |
| `SALTO` | 0,3 s | Back Out | Itens surgindo, painéis abrindo |
| `SUAVE` | 0,6 s | Cubic InOut | Câmera, troca de luz |
| `LENTO` | 1,2 s | Sine InOut | Flutuação, entrada de personagens |

## 8. Desempenho

- `Workspace.StreamingEnabled = true`. Cada dimensão é um `Model` com `ModelStreamingMode = Atomic` nos monumentos e `LevelOfDetail = StreamingMesh`, para aparecerem como silhueta de longe.
- MeshParts com `RenderFidelity = Automatic` e `CollisionFidelity = Box` ou `Hull` (nunca `PreciseConvexDecomposition` em decoração).
- Decoração: `CanCollide`, `CanQuery` e `CanTouch` desligados e `Anchored` ligado. O jogador colide com peças invisíveis simples.
- **Orçamento por área visível:** até 12 luzes com `Shadows = false` (só 1 ou 2 com sombra) e até 6 emissores ativos (com `Rate` reduzido pela qualidade). Evite transparências sobrepostas em grandes áreas.
- **Qualidade gráfica:** o controlador lê `UserSettings().GameSettings.SavedQualityLevel` e, abaixo de 4, corta partículas pela metade, desliga Bloom e DepthOfField e para as animações a mais de 60 studs.
- **Reaproveitamento:** a mesma malha com `SurfaceAppearance` diferente, por exemplo uma rocha base para três mundos, só com **geometria de topo** (musgo, gelo, magma) trocada.
- **Limite de triângulos:** confira o limite atual de importação do Roblox antes de modelar. Mire em até 6 mil triângulos nos modelos de destaque e até 1,5 mil em decoração repetida.

## 9. Fluxo de produção

Há três caminhos, escolhidos por modelo:

1. **Parts e MeshParts nativos** (montados por script no Studio): arquitetura modular, máquinas e estruturas com peças repetidas. Rápido de ajustar e não depende de nada externo.
2. **`generate_mesh` e `generate_texture` do Studio:** formas orgânicas (árvores, criaturas, rochas esculpidas). Toda malha gerada passa por revisão em captura de tela de três ângulos e é **descartada se a forma não servir**. Nada gerado entra no jogo sem aprovação do dono.
3. **Blender → FBX → importador do Studio:** modelos de destaque que exigem topologia controlada (o Fragmento Celestial e personagens com rig). Precisa de alguém com Blender no PC. Arquivos-fonte em `jogo-roblox/fontes/`, exportação em FBX, escala em metros (1 stud ≈ 0,28 m), pivô na base.

**Nunca inventar IDs de asset.** Todo `rbxassetid://` vem de um upload feito e conferido no Studio.

## 10. Plano por etapas

1. **Auditoria** no Studio (seção 0), salva em `jogo-roblox/auditoria.md`.
2. **Guia aprovado:** este documento, revisado pelo dono.
3. **Seis modelos-piloto** (seção 11), num lugar de testes (`ServerStorage.Vitrine`) e fora do jogo.
4. **Avaliação conjunta:** os seis lado a lado, em Play, com fundo de cada dimensão. Eles parecem do mesmo jogo?
5. **Ambiente** (seção 4) aplicado a uma dimensão só, a Ilha das Tempestades, que já existe.
6. **Expansão**, uma dimensão por vez, trocando os modelos marcados como "reconstruir" na auditoria. Cada troca é testada em Play antes de salvar o place.

## 11. Modelos-piloto

Os seis são de dimensões diferentes, para testar se o estilo se mantém. **Os nomes são propostas.**

| Piloto | Dimensão | O que testa |
|---|---|---|
| **Fragmento Celestial** | Achados e Perdidos | Cristal translúcido com núcleo, anel mecânico com runas, base de pedra rachada e 4 animações: parado, extração, quebra e reaparecimento |
| **Árvore-Raiz do Gigante** | Costas do Gigante | Formação orgânica: tronco torcido, raízes abraçando ruínas, copa em camadas, musgo e fachos de luz |
| **Sede da Empresa** (a sede pendente, com a frente aberta) | Ilha das Tempestades | Arquitetura com três camadas de detalhe, materiais combinados e escala do jogador |
| **Perfuratriz de Fornalha** | Ilha dos Vulcões | Máquina com função legível, broca, pistões, tubos e upgrade por peças |
| **Ajudante-Bolha** | Campo das Bolhas | Criatura com anatomia coerente, material translúcido e animações de trabalho |
| **Portal-Relógio** | Cidade Congelada | Portal com mecanismo de engrenagens animado e identidade da dimensão |

## 12. Critérios de aprovação

Um modelo só está pronto quando responde **sim** a tudo:

- [ ] É reconhecível sem partículas e sem brilho?
- [ ] A silhueta é interessante em preto chapado?
- [ ] Tem as três camadas de detalhe?
- [ ] Combina pelo menos duas famílias de material, com a energia em no máximo 10% da área?
- [ ] Tem o vocabulário de forma da sua dimensão, e não só a paleta?
- [ ] A escala funciona ao lado do avatar?
- [ ] Está dentro do orçamento de peças, triângulos, luzes e partículas?
- [ ] Colisões e propriedades de decoração estão certas?
- [ ] Os scripts que dependem dele continuam funcionando (mesmo nome, pivô e atributos)?
- [ ] **Foi testado em Play**, no celular e no computador, e não só planejado?
