# Oficina dos Inventores V2.3.4: reconstrução

Só a oficina foi reconstruída. Nenhuma outra estrutura, região ou mecânica nova.

- Backup da versão anterior: `../v232-backup/`.
- Imagens (render do visualizador three.js, não do Roblox):
  - `../../referencias/v234-oficina-10-vistas.jpg`: as 10 vistas obrigatórias, com o boneco de 5,2 studs.
  - `../../referencias/v234-oficina-antes-depois.jpg`: V2.3.2 × V2.3.4, mesma câmera relativa ao edifício, mesma escala, efeitos desligados, modelo isolado.
  - `../../referencias/v234-oficina-modos.jpg`: sem telhado, sem fachada, Diagnóstico Estrutural, modo neutro, modo cinematográfico e a oficina na vila.

## 1. Auditoria da oficina anterior

| Item | Resultado |
|---|---|
| Código | bloco dentro de `vila.js` |
| Nome no código | "Oficina dos Para-raios" (id `STORM.ARCH.WORKSHOP`, NPC 02) |
| Geometria | 18 primitivas, todas protótipo: 3 paredes-caixa lisas sem aberturas, sem fachada, 3 postes, "bigorna" de 2 caixas, bobina de 5 anéis |
| Telhado | placa de 0,9 stud sem estrutura, **girada 90° em relação às paredes**: cobria 16 × 22 numa planta de 22 × 16, deixando 3 studs de cada parede lateral para fora |
| Assentamento, colisores e rotas | corretos desde a V2.3.2 |
| Exibição | aparecia e atualizava no visualizador |

## 2. Edifício novo (`Architecture/oficina.js`)

Planta de 26 × 20 studs. O piso fica em 1,6 sobre o plinto, e as paredes sobem até 12,6. A cumeeira fica em cerca de 18,5.

**Fundação e drenagem:**
- plinto de cantaria lavrada com chanfro;
- pingadeira saliente;
- canaletas de ferro na frente e no fundo;
- gárgulas de pedra nos cantos, recebendo os condutores pluviais;
- alicerce até o chão real com `MM.seat` (variação de terreno de 3 studs no local);
- patamar de entrada e 3 degraus de 0,75 stud.

**Paredes:**
- embasamento de cantaria até 4 studs;
- acima, enxaimel com pilares, frechais, travessas e mãos-francesas, salientes por dentro e por fora;
- reboco entre as peças;
- **aberturas reais** recortadas na parede: porta em arco, 8 janelas e uma rosácea no fundo;
- cunhais de pedra alternados nos quatro cantos;
- chapas de ferro aparafusadas nas juntas;
- empenas com óculo de ventilação.

**Telhado:**
- duas águas a cerca de 29°;
- 15 caibros por água, ripas e tabuado;
- chapas de junta em pé (frisos a cada 1,6) e testeira;
- cumeeira de cobre;
- 2 tesouras internas visíveis de dentro (linha, pendural e escoras);
- calhas, condutores pluviais com braçadeiras e chaminé de pedra da forja;
- 3 para-raios com bobinas e isoladores;
- 2 condutores de descida até a estaca;
- 1 condutor central que atravessa o telhado por uma bucha e termina sobre o Condensador.

**Entrada:**
- arco de aduelas sobre ombreiras de pedra, soleira e bandeira de vidro em leque;
- porta dupla de tábuas com cintas, dobradiças, rebites e argolas, aberta para dentro (vão livre de cerca de 5 studs);
- 2 lanternas de parede;
- placa em bandeira "Oficina dos Inventores" com emblema de engrenagem e raio.

**Interior:**

| Área | Conteúdo |
|---|---|
| Bancadas (frente e parede esquerda) | tampo grosso, gavetas com puxadores, gaveteiro, painel de ferramentas (martelo, chaves, serrote), morsa, engrenagens, parafusos, cristais, folha de projeto, luminária articulada; banquinho |
| Laboratório atmosférico (direita) | bobina de alta tensão (secundário enrolado e toroide), gerador com volante animado, painel de controle (3 mostradores, 4 alavancas, botões), tubulação de cobre, calha de cabos até o Condensador |
| Depósito (fundo esquerdo) | 2 estantes de 4 prateleiras organizadas (caixotes embaixo; frascos, carretéis de fio, engrenagens e livros em cima), 2 barris com aros, pilha de caixotes |
| Canto do inventor (fundo direito) | prancheta inclinada com projeto, banco, mesa lateral com planetário mecânico animado e protótipo de máquina voadora, luminária própria, notas presas na parede |

O canto do inventor tem o objeto `PontoNPC`, lugar reservado para o NPC `STORM.NPC.02`, que não foi implementado.

**Condensador Atmosférico (centro, ≈ 7 × 7 × 12 studs):**
- **Base:** plinto octogonal de pedra; degrau de bronze com faixa de runas e rebites.
- **Corpo:** carcaça de ferro com flange e respiros; câmara de vidro com quadro de ferro e cintas de cobre; núcleo cristalino com 3 cristais satélites e núcleo de energia.
- **Partes animadas:**
  - 3 anéis de contenção inclinados que giram;
  - par de engrenagens;
  - pistões;
  - ponteiro do manômetro.
- **Ao redor:** 2 colunas de bobinas e escoras de bronze.
- **Topo:** tampa abobadada com aletas e faiscador de dois eletrodos.
- **Ligações:** tubulações com registros. No modo cinematográfico, faíscas saltam do faiscador ao condutor do telhado.
- **Sem efeitos:** o Condensador continua legível como máquina.

## 3. Materiais

Todos são procedurais ou de canvas. Nenhum arquivo de textura externo foi usado.

| Material | Mapas |
|---|---|
| Cantaria e pedra lavrada | triplanar com `blocos`/`rocha` (cor + normal), musgo no topo |
| Madeira e madeira estrutural | **novo** conjunto procedural `madeira` 256² (cor, normal, rugosidade: veio, juntas, emendas, nós) |
| Ferro escovado e ferro escuro | `metal` (cor, normal, rugosidade); metalicidade fixa |
| Bronze e cobre oxidado | `cobre` (cor, normal, rugosidade) |
| Chapa do telhado | `metal` tingido |
| Reboco | `terra` em escala grande (só cor) |
| Vidro e cristal | físico, com transmissão |
| Runas | mapa emissivo `runas` |
| Placa, projeto e mostrador | canvas (texto e desenho) |
| Condutor | cobre com pulso emissivo (shader) |

**Não é PBR completo:** não há mapa de oclusão, e a metalicidade é um valor por material.

## 4. Iluminação

- **Neutro:** botão "Iluminação neutra" (luz branca, sem névoa nem céu), com efeitos e chuva desligados.
- **Cinematográfico:** padrão da ilha, mais **1 luz pontual quente interna**. A intensidade vai a 0 longe da oficina, sem recompilar shaders. Completam o modo:
  - brilho do Condensador e das lâmpadas;
  - faíscas entre o faiscador e o condutor e na bobina do laboratório;
  - chuva, relâmpagos e névoa da ilha.

## 5. Inspecionar Oficina (visualizador)

Seção "Oficina dos Inventores" no painel:
- **Inspecionar Oficina:** isola a oficina só por visibilidade (nada é removido da ilha), enquadra e coloca o boneco de escala na entrada.
- **Ocultar telhado** e **Ocultar parede da frente.**
- **Atalhos para as 10 vistas.**
- **Seleção de componentes:** o clique mostra o nome do componente com uma caixa amarela. São 12 componentes.
- **Câmera:** rotação e zoom pela câmera livre.
- **Efeitos e modo neutro:** continuam em Camadas.

Testado em 1250 × 900 e num celular emulado de 390 × 844, sem rolagem horizontal.

## 6. Orçamento e desempenho (navegador de teste sem GPU)

| | Orçamento estimado | Medido |
|---|---|---|
| Triângulos da geometria | ≤ 45 mil | **35 810** |
| Triângulos renderizados (com sombra, vista Vila) | — | **≈ 53 mil** |
| Chamadas de desenho (com sombra, vista Vila) | ≤ 50 | **64**, acima do previsto |
| Malhas após a fusão | — | 44 (20 projetam sombra) |
| Texturas novas | 1 conjunto procedural + canvas pequenos | madeira 256² (3 mapas) + 3 canvas (512×128, 256², 128²) |
| Luzes dinâmicas | 1 | 1 (desligada pela distância) |
| Grupos animados | ≤ 6 | 8 (3 anéis, engrenagens, pistões, ponteiro, volante, planetário) |

**Por que passou de 50 chamadas:** 19 materiais, mais o telhado e a fachada fundidos à parte (necessário para ocultá-los na inspeção), mais as peças animadas.

**Otimizações feitas:**
- **Peças animadas:** cada grupo foi fundido por material.
- **Materiais:** cada grupo passou a usar menos materiais.
- **Condutores:** fundidos numa malha só.
- **Sombras:** o interior não projeta sombra (pior: 90 chamadas → 64).

**Compensação na cena:** os tubos das árvores passaram de 12 × 6 para 8 × 5 segmentos, a maior fonte de triângulos com sombra.

**Cena inteira** (mesmas vistas, efeitos e chuva desligados):

| Vista | V2.3.2: chamadas / triângulos | V2.3.4: chamadas / triângulos |
|---|---|---|
| Três quartos | 898 / 1,528 mi | 946 / 1,379 mi |
| Vila | 717 / 1,712 mi | 765 / 1,562 mi |
| Torre | 654 / 1,682 mi | 666 / 1,503 mi |
| Aérea | 914 / 1,530 mi | 962 / 1,381 mi |
| Nível do jogador | 590 / 1,648 mi | 602 / 1,469 mi |

- **Triângulos:** caíram cerca de 150 mil (−9%), mesmo com a oficina.
- **Chamadas:** subiram de 12 a 48 (+2% a +7%).
- **FPS:** fica em cerca de 20 nas duas versões, que é o limite do ambiente de teste. Não serve para comparar, nem vale como medida do Roblox.

## 7. Testes executados

| Teste | Resultado |
|---|---|
| Diagnóstico Estrutural da ilha | 0 vermelhos, 0 interseções, 0 instâncias de superfície dentro de construções |
| Apoio da oficina | verde |
| Rotas ao nível do jogador | 24/24, inclusive "oficina: frente → interior" |
| Lanterna da trilha dentro da oficina nova | encontrada e corrigida (lanternas a ≥ 19 studs da oficina) |
| Posição | a primeira tentativa (borda do platô) deixava um alicerce de 10 studs e a escada no ar. A busca agora exige terreno plano (variação ≤ 2,5 studs) dentro da vila: a oficina ficou em (−84, 98), alicerce ≤ 3 studs |
| Interior | as sobreposições de bancada × estante, painel × mesa, barris × Condensador e notas × janela foram corrigidas antes do primeiro render; as colisões internas estão nos colisores |
| Visual | 10 vistas, antes/depois, modos neutro/cinematográfico, sem telhado/fachada, diagnóstico e celular |

## 8. Exportação GLB (verificada no arquivo gerado)

O `Architecture.glb` do pacote contém a oficina completa:
- **44 malhas e 35 810 triângulos**, iguais à cena;
- os nós dos grupos animados (anéis, engrenagens, pistões, ponteiro, volante, planetário), `Telhado` e `FachadaFrontal`;
- **16 materiais `Oficina*`**, mais o material do condutor.

**Erro corrigido na exportação:** os condutores com pulso (da oficina e da torre `CondutorCobre`) saíam com o material genérico "Rocha". O exportador confundia qualquer material com uniforms próprios com o triplanar; agora usa uma marca explícita.

**O que não vai para o GLB:**
- **Cantaria triplanar:** sai como material simples "Rocha". No Roblox vira MaterialVariant com as texturas exportadas em PNG.
- **Pulso, faíscas, brilho animado, luz pontual e chuva:** são efeitos do navegador. No Roblox:
  - pulso: Beam com textura animada;
  - faíscas: ParticleEmitter/Beam;
  - luz: PointLight;
  - animações: TweenService ou HingeConstraint no cliente.

**Nada foi testado no Roblox Studio.**

**Colisores planejados:** plinto, 3 paredes com vão de porta, Condensador (2 caixas), bancadas, estantes, bobina, gerador, painel, prancheta, mesa e caixotes. Estão no `manifest.json`.

## 9. Arquivos modificados

| Arquivo | O que mudou |
|---|---|
| `StormIsland/Architecture/oficina.js` | novo |
| `StormIsland/Architecture/vila.js` | posição, orientação, assentamento, fusões; lanternas fora da oficina |
| `nucleo/texturas.js` | textura de madeira |
| `nucleo/base.js` | opção `bakeCast` (testada e não usada) |
| `nucleo/triplanar.js` | marca de exportação |
| `nucleo/visualizador.js` | Inspecionar Oficina; exportação dos condutores |
| `visualizador.html` | botões e script |
| `StormIsland/Effects/efeitos.js` | animação, luz e faíscas |
| `StormIsland/ilha.js` | luz para os efeitos |
| `StormIsland/Vegetation/floresta.js` | segmentos das árvores |

## 10. O que ainda permanece

- **Chamadas de desenho:** 64 contra os 50 estimados. A próxima redução seria um atlas para placa, projeto e mostrador, e unificar alguns metais.
- **Posição:** a oficina ficou cerca de 25 studs a oeste do lugar original, ainda dentro da vila, por falta de terreno plano livre no lugar antigo.
- **Telhado:** a vista superior do telhado de metal fica clara pelo reflexo do céu.
- **NPC:** não implementado, só o lugar reservado.
