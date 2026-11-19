# Guardiões do Multiverso: Atlas das Dimensões — Documento de Design (GDD) v0.1

RPG multiplayer de exploração, combate, evolução, construção e mistério, para Roblox (PC e celular).
Este documento substitui o conceito de tycoon de *Magnata do Multiverso*, preservando toda a arte já feita.

**Números marcados com (T)** são pontos de partida de balanceamento, a confirmar em teste de jogo.

---

## 1. Premissa

Há milhares de anos, o **Coração do Atlas** mantinha as dimensões conectadas. A **Fratura** partiu essa energia em **fragmentos** espalhados pelos mundos.

Sem ela, civilizações foram abandonadas, criaturas surgiram e os antigos Guardiões perderam o controle dos próprios poderes.

Os jogadores são **novos Guardiões**. A missão deles é:
- explorar os mundos;
- enfrentar criaturas;
- recuperar fragmentos;
- reconstruir estruturas;
- descobrir **quem provocou a Fratura e por quê**. Esse mistério é o fio da história inteira, revelado em partes a cada expansão.

**Pontes com a arte que já existe:**
- O **Fragmento Celestial** (referência visual) é a aparência dos fragmentos do Coração.
- O símbolo das **Sete Estrelas** representa as seis dimensões mais o Coração (a Sétima Estrela). Ele já aparece no Santuário da Tempestade e na Contemplação Celestial do Axolote Nebular: é a primeira pista do mistério.

## 2. Pilares

1. **Exploração que recompensa a curiosidade.** Todo canto bonito esconde algo: baú, inscrição, atalho, criatura rara ou peça de enigma. Nenhum mapa é só decoração.
2. **Combate de ação legível.** Em terceira pessoa, com telegrafia clara, esquiva, defesa e combos, e justo no celular.
3. **Construção com propósito.**
   - **Base pessoal persistente:** fabricar, guardar, decorar e exibir.
   - **Restauração das dimensões:** estruturas do mundo ganham função.
4. **Mistério em camadas.** Segredos entre dimensões levam à raridade **???**. O desafio é descobrir; ninguém compra e quase nada depende de sorte.

## 3. Laço principal

```
explorar região → enfrentar criaturas → materiais + pistas
       ↓                                   ↓
  restaurar estrutura ← fabricar/melhorar ← receitas (drop, NPC, segredo)
       ↓
  nova área / mecanismo / missão → região mais difícil → miniboss (Druida) → Guardião (Arcano)
                                                   ↘ segredos entre dimensões → ???
```

**Sessões curtas** (10–15 min): uma missão, um território de miniboss ou um passo de restauração.

**Sessões longas:**
- caçada a segredo;
- Guardião com a companhia;
- construção na base.

## 4. Exploração

**Cada dimensão tem:**
- 4 a 6 **regiões** com identidade própria;
- uma **região segura**: o hub, com a vila e o portal;
- **cavernas e ruínas**, passagens secretas e tesouros;
- NPCs e missões;
- enigmas e minibosses;
- um ou mais **Guardiões**.

**Áreas inacessíveis no começo.** Existem três tipos de trava:
- **Trava de restauração.** A ponte quebrada é consertada pela Restauração.
- **Trava de habilidade.** Exige uma habilidade de outra dimensão. Exemplo: o **Salto de Bolha** do Campo das Bolhas alcança plataformas altas da Ilha das Tempestades. É o "metroidvania entre dimensões".
- **Trava de conhecimento.** Só abre quem leu a inscrição certa ou resolveu um enigma.

**Recompensas de exploração:**

| Achado | Densidade |
|---|---|
| Baús comuns | Muitos, em rotas naturais |
| Baús escondidos | Poucos, atrás de passagens secretas |
| Pistas do Diário do Guardião | Inscrições, livros, ecos |
| Pontos de mineração e coleta | — |
| Atalhos permanentes | Destravam por jogador |

## 5. Combate e RPG

### 5.1 Controles

| Ação | PC | Celular |
|---|---|---|
| Ataque básico (combo) | Botão esquerdo | Botão grande à direita |
| Ataque pesado | Tecla R (controle: Y) — botão próprio, para o ataque leve não esperar a leitura do "segurar" | Botão próprio "Pesado" |
| Defesa (segurar) / aparar (no instante do golpe) | Botão direito | Botão de escudo |
| Esquiva | Q ou Shift | Botão de esquiva |
| Habilidades 1 a 3 | 1, 2, 3 | Três botões em arco |
| Mira suave | Automática no inimigo mais próximo do centro da câmera, com troca manual pelo Tab ou por toque no inimigo | — |

### 5.2 Recursos do personagem

- **Vida.**
- **Estamina** (T): 100. Recupera 22 por segundo, depois de 0,8 s sem gastar.
- **Foco**: carrega acertando e defendendo, e é gasto nas habilidades especiais.

### 5.3 Ações e números iniciais (T)

**Esquiva**
- Duração 0,45 s, com invulnerabilidade de 0,05 s a 0,30 s.
- Custa 25 de estamina; tempo de recarga 0,35 s.

**Defesa**
- Reduz 70% do dano frontal (arco de 120°). Cada golpe defendido gasta estamina igual a 60% do dano bruto.
- Estamina zerada quebra a guarda: atordoamento de 1,2 s.

**Aparar (parry)**
- Defesa começada até 0,18 s antes do impacto anula o dano.
- Causa 40 de dano de postura no atacante e devolve foco.

**Postura dos inimigos**
- Encher a barra de postura derruba o inimigo (2,5 s vulnerável, +30% de dano recebido).

### 5.4 Estilos (sem classe permanente)

O estilo vem da **arma equipada** e das **habilidades encaixadas**. A troca é livre fora de combate. A **maestria** é por tipo de arma.

| Estilo | Armas | Identidade | Mecânica própria |
|---|---|---|---|
| **Espadachim** (protótipo) | Espada, espada longa | Corpo a corpo, combos, aparar | Combo de 3 golpes + pesado. O 3º golpe do combo encadeado sem errar ganha +25% de dano de postura. |
| **Arcanista** | Cajado, grimório | Distância média, área, controle | Projéteis carregáveis; runas no chão (2 por vez). |
| **Patrulheiro** | Arco, besta, adagas | Distância longa, mobilidade | Disparo carregado com ponto fraco; esquiva mais longa (+20%). |

### 5.5 Progressão

**Nível do Guardião (1 a 60 no lançamento)**
- Dá pontos de atributo: Força, Agilidade, Intelecto e Vigor.
- O retorno decresce depois de 40 pontos num mesmo atributo.

**Maestria de arma (1 a 20 por tipo)**
- Desbloqueia variações de combo e habilidades da arma, e +1% de dano por nível (teto de 20%).

**Afinidade dimensional (0 a 10 por dimensão)**
- Sobe com missões, restauração e Guardiões daquela dimensão.
- Dá resistência ao elemento do mundo e libera a **habilidade de travessia**.

**Proteção contra inflação:**
- O dano final é limitado por um **orçamento de poder** por nível de item (veja 7.2).
- O conteúdo antigo ganha **sincronização de nível** opcional em missões cooperativas: o jogador forte desce para o nível da área e ganha recompensa extra de ajuda.

## 6. Criaturas

### 6.1 Categorias e regras

| Categoria | Papel | Densidade e retorno (T) | Recompensa principal |
|---|---|---|---|
| **Pacíficas** | Vida do mundo, missões, montaria e ajudantes no futuro | Grupos de 2 a 6; fogem do combate | Coleta não letal (pelo, pólen, faísca) e missões |
| **Comuns** | Exploração | 3 a 5 por grupo; mínimo de 1 grupo a cada 60 studs nas regiões hostis; retorno em 45–90 s, fora da visão dos jogadores | Comum a Raro |
| **Elite** | Regiões avançadas | 1 por grupo, às vezes sozinho; retorno em 5 min | Épico e Lendário; peças de receita |
| **Minibosses** | Territórios marcados (arena reconhecível) | Por servidor, com retorno em 15–20 min; anúncio local 30 s antes | **Materiais Druida** garantidos; Lendário |
| **Guardiões dimensionais** | Clímax de cada mundo | Instância de arena para 1 a 6 jogadores (a companhia pode entrar junta); recompensa principal 1 vez por dia por jogador | **Materiais Arcanos** garantidos |

**Comportamento:** nenhum inimigo parado.
- Todos patrulham, reagem ao som de combate e têm **telegrafia** (brilho ou postura) antes de cada golpe.
- Cada espécie tem pelo menos **2 ataques e 1 reação especial**.
- As regiões seguras (hub, base, arredores do portal) não têm criaturas hostis.

**Servidor:**
- A IA roda a 10 Hz; criaturas longe de qualquer jogador (mais de 250 studs) **dormem**.
- No máximo 60 criaturas hostis ativas por servidor de 12 jogadores (T).

### 6.2 Ilha das Tempestades (lançamento)

Os nomes são propostas originais.

| Categoria | Criaturas |
|---|---|
| **Pacíficas** | **Axolote Nebular** (já modelado; ajudante); **Lebre-de-Faísca** (campos da vila); **Medusas-de-Nuvem** (mirante); **Corvos-Para-raios** (pousam nos para-raios da vila) |
| **Comuns** | **Faísca Errante** (elemental pequeno, investida); **Lagarto-Bobina** (cospe arco elétrico em linha); **Morcego Estático** (caverna; mergulho em bando); **Carcaça Eólica** (constructo das ruínas; giro com vento) |
| **Elite** | **Faísca Sobrecarregada** (explode ao morrer); **Sentinela de Cobre** (escudo frontal: exige flanquear ou quebrar a postura) |

**Minibosses** (fonte Druida):

| Miniboss | Território | Mecânica | Material Druida |
|---|---|---|---|
| **Rainha-Bobina** | Câmara da Caverna do Trovão | Fase de carga: os pilares de cristal acendem e o jogador precisa quebrá-los antes da descarga | Glândula de Bobina Viva |
| **Cão-Trovão Alfa** | Floresta das árvores retorcidas | Chama a matilha; fica invulnerável enquanto corre carregado, só apara | Juba Estática |
| **Colosso das Ruínas** | Ruínas tecnológicas | Pisoteio com onda; o núcleo nas costas aparece depois de 3 aparadas | Núcleo Enferrujado |
| **Espectro do Observatório** | Observatório, só à noite | Teleporte entre as lentes; vulnerável ao reflexo do telescópio restaurado | Lente Espectral |

**Guardião dimensional (fonte Arcana): o Guardião da Tormenta.**
- **Arena:** o topo da Torre Meteorológica restaurada, sob a tempestade.
- **Fase 1 (100–65%).** Golpes de lança e investidas aéreas.
- **Fase 2 (65–30%).** Os para-raios da arena carregam um a um. O jogador redireciona os raios para o Guardião ativando o para-raios certo.
- **Fase 3 (30–0%).** O olho da tempestade fecha a arena; o chão eletrificado tem padrões que pedem esquiva.
- **História:** ele foi um Guardião antigo, corrompido pela Fratura. O diário dele traz a primeira pista sobre quem a causou.
- **Material Arcano:** Coração da Tormenta e Pena do Relâmpago Antigo.

## 7. Raridades, poder e fabricação

### 7.1 Hierarquia oficial

| # | Raridade | Cor (T) | Origem principal |
|---|---|---|---|
| 1 | Comum | `#B9C6D8` | Criaturas comuns, baús |
| 2 | Incomum | `#7EDC6A` | Comuns e elites |
| 3 | Raro | `#4EA8FF` | Elites, baús escondidos |
| 4 | Épico | `#B86BFF` | Elites, missões |
| 5 | Lendário | `#FFCC33` | Minibosses, missões de capítulo |
| 6 | **Druida** | `#3FBF7F` com veios de folha e luz | **Materiais de minibosses** + receita Druida |
| 7 | **Arcano** | `#6F7BFF`→`#FF6FD8` (gradiente dimensional) | **Materiais de Guardiões** + receita Arcana |
| 8 | **???** | Sem cor fixa: escuro com padrão que muda | **Segredos**: enigmas, passagens ocultas, artefatos entre dimensões |

As cores vêm do guia antigo onde coincidem (Comum, Raro, Épico e Lendário).

### 7.2 Orçamento de poder

Para evitar inflação, o **atributo base** de um item depende do **nível do item** (iLvl, igual ao nível da região de origem) e da raridade:

`poder = base(iLvl) × multiplicador(raridade)`

| Raridade | Multiplicador (T) | O que mais ganha |
|---|---|---|
| Comum | 1,00 | — |
| Incomum | 1,08 | 1 atributo secundário |
| Raro | 1,16 | 2 secundários |
| Épico | 1,25 | 2 secundários + 1 traço |
| Lendário | 1,34 | 3 secundários + 1 traço lendário |
| Druida | 1,42 | Efeito Druida (natureza/energia do miniboss) + aparência própria |
| Arcano | 1,50 | Poder dimensional (habilidade ativa ligada ao Guardião) + efeitos avançados |
| ??? | 1,56 | **Mecânica exclusiva** (regra que não existe em outra raridade) + origem desbloqueada aos poucos |

Os saltos de multiplicador são **pequenos e não crescem** (entre 0,06 e 0,09; o último, Arcano → ???, é o menor). As raridades altas ganham **efeitos e mecânicas**, não só números. Assim um Lendário de nível 50 continua relevante diante de um Druida de nível 35.

**Melhoria:**
- Até +10 por item, com custo crescente de materiais da mesma dimensão.
- O teto do +10 cobre **metade do salto** até a raridade seguinte no mesmo iLvl (ex.: Raro 1,16 → teto 1,205; a raridade seguinte, Épico, começa em 1,25). A regra anterior ("seguinte menos 4%") deixava o teto do Arcano (1,4976) abaixo do próprio Arcano (1,50) e foi trocada.
- A ??? não tem raridade seguinte: o teto dela é o próprio poder base (as melhorias dela vêm da mecânica exclusiva, não do +10).
- Melhorar nunca torna obrigatório trocar de raridade.

### 7.3 Fabricação

Toda receita tem:
- **resultado**: tipo, iLvl e raridade;
- **materiais**;
- **estação exigida**: bancada, forja, oficina restaurada ou altar;
- **requisitos de conhecimento**: receita aprendida, restauração feita, afinidade.

| Raridade | Como se obtém a receita |
|---|---|
| Comum a Épico | Com NPCs da vila, em baús, ou já conhecida |
| Lendário | Missões de capítulo e drops raros de elite |
| **Druida** | Primeira derrota de cada miniboss → **Esboço Druida** daquele miniboss. Fabricar exige 3–5 materiais Druida do miniboss + materiais comuns da região + a **Forja** da base no nível 3. |
| **Arcano** | Derrota do Guardião → **Códice Arcano**. Fabricar exige o material Arcano do Guardião + 2 materiais Druida da mesma dimensão + a **Oficina restaurada** da dimensão. |
| **???** | Só por segredos. Uma cadeia típica: |

A cadeia típica de um segredo ???:
1. Notar uma anomalia (inscrição que só aparece com chuva, símbolo das Sete Estrelas fora do lugar).
2. Resolver o enigma (ordem de ativação, leitura do céu, combinação entre dimensões).
3. Achar um **Artefato Desconhecido**, cuja descrição começa com "???" e é revelada aos poucos.
4. Desbloquear a **receita ???**.
5. Reunir os componentes, alguns de **outras dimensões**.

**Regras dos segredos ???:**
- Nada de ??? à venda, nem por Robux.
- Sem drop de chance baixíssima como caminho principal; um pequeno componente pode ter drop garantido depois de passos de enigma.
- A interface mostra "???" e só revela nomes, efeitos e história **depois** que o jogador descobre cada parte.
- Cada jogador descobre por si. A companhia pode **ajudar** (mostrar o caminho, lutar junto), mas o desbloqueio é individual, para o mistério não acabar no primeiro tutorial do servidor.
- As soluções dos enigmas variam por **semente do servidor ou do jogador** quando fizer sentido, para dificultar copiar a resposta da internet sem tirar a lógica.

### 7.4 Tipos de equipamento

| Espaço | Itens |
|---|---|
| Arma principal | Define o estilo |
| Armadura | Cabeça, corpo, pernas |
| Acessórios | 2 espaços (anel ou amuleto) |
| Relíquia | Ativa, com recarga longa; vem de Guardiões e segredos |

## 8. Restauração das dimensões

Cada estrutura do mundo tem **estado por jogador**: Abandonada → Em restauração (etapas) → Restaurada.

**Cooperação:**
- Quem ajuda outro jogador **avança as próprias etapas** (com uma contribuição mínima), sem pular a experiência.
- Melhorias **globais do servidor** (decorativas, como a vila iluminada) aparecem quando a maioria dos presentes restaurou.

| Estrutura (Ilha das Tempestades) | Função restaurada |
|---|---|
| Portal (doca de chegada) | Viagem entre dimensões e ponto de retorno |
| Oficina dos Inventores | Fabricação de nível 2 e melhorias até +5; depois, a Arcana |
| Mina / Caverna do Trovão | Veios de minério e acesso à câmara (miniboss) |
| Observatório | Missões de investigação; o telescópio enfraquece o Espectro e revela segredos |
| Torre Meteorológica (de energia) | Liga os mecanismos da ilha: elevadores, pontes energizadas e a arena do Guardião |
| Santuário (altar) | Afinidade dimensional, habilidades e encaixe de fragmentos do Coração |
| Vila | NPCs, comerciantes, quadro de missões; serviços extras a cada etapa |
| Ponte suspensa | Atalho para a estrada do penhasco |

## 9. Base pessoal

**Primeira fase:**
- Parcela própria em um servidor de bases, ou instância.
- **Espaços predefinidos** que evoluem por níveis: Oficina, Forja, Bancadas, Depósito, Jardim mágico, Expositores e decoração.

**Segunda fase:** posicionamento livre em grade, com validação no servidor (limite de peças e colisão).

**Persistência:**
- Tudo é salvo em perfil versionado, junto do inventário.
- A base nunca é apagada por mudança de versão; há migração de esquema.

**Funções:**

| Espaço | Função |
|---|---|
| Forja | Armas e armaduras (níveis 1 a 5) |
| Bancada | Consumíveis e acessórios |
| Jardim | Plantas e materiais de dimensões visitadas |
| Expositores | Mostram troféus de minibosses e Guardiões |
| Depósito | Espaço extra de inventário |

**Origem:** os terrenos do tycoon viram as parcelas da base (veja a migração).

## 10. Companhias (guildas)

**Participação opcional.** Jogadores solo terminam a história e conseguem todos os tipos de equipamento.

**Funções:**
- criar, com nome e emblema (montado de peças pré-aprovadas, sem upload livre de imagem);
- convidar e aceitar membros;
- missões cooperativas e objetivos coletivos semanais;
- nível da companhia, com recompensas cosméticas e de conveniência equilibradas.

**Cargos e permissões:**

| Cargo | Permissões |
|---|---|
| **Líder** | Tudo |
| **Oficial** | Convida, expulsa recrutas e membros, inicia eventos, retira do cofre até um limite diário |
| **Membro** | Deposita, participa, retira itens marcados como "livres" |
| **Recruta** | Participa, deposita |

**Proteções:**
- Cada permissão é checada no servidor e cada ação vai para o registro (log) da companhia.
- **Cofre** com limite diário de retirada por cargo e itens "travados" pelo líder.
- Expulsar alguém **não** confisca nada da pessoa.
- Transferir a liderança leva 48 h, e o líder pode cancelar.
- Dissolver a companhia exige confirmação dupla e 72 h de espera; os itens do cofre voltam para quem depositou.

**Espaço de reunião:** previsto para fase posterior.

## 11. Dimensões e roteiro

| Fase | Conteúdo |
|---|---|
| **Lançamento** | **Ilha das Tempestades**: vila e NPCs, oficina, mina, portal, observatório, torre de energia, altar, criaturas (comuns, elite, 4 minibosses), Guardião da Tormenta, Ato 1 da história, primeiros segredos ???, base pessoal fase 1 e companhias básicas |
| Expansão 1 | **Campo das Bolhas** (identidade luminosa e mágica preservada); habilidade Salto de Bolha; Ato 2 |
| Expansão 2 | Ilha dos Vulcões |
| Expansão 3 | Cidade Congelada |
| Depois | Costas do Gigante, Achados e Perdidos e outras |

Cada dimensão nova entra **por configuração**: dados de regiões, criaturas, materiais, receitas, missões e segredos. O código dos sistemas não muda (veja `02-ARQUITETURA.md`).

## 12. História (Ato 1: "Ecos da Fratura")

1. **Chegada pelo portal.** O tutorial de combate é contra uma Faísca Errante perto da doca.
2. **Vila.** O NPC inventor pede ajuda para restaurar a Oficina (fabricação básica).
3. **Mina.** A Rainha-Bobina bloqueia os veios: primeiro miniboss e primeiro esboço Druida.
4. **Observatório.** As anotações falam de "uma mão que partiu o Coração por dentro".
5. **Torre.** Religar a energia abre a arena e acontece a luta contra o Guardião da Tormenta.
6. **Revelação parcial.** O Guardião não causou a Fratura; ele a **tentou impedir**. O diário dele aponta o Campo das Bolhas e cita as Sete Estrelas.

**Segredo ??? do Ato 1 (interno, não divulgar):**
1. Com o Axolote Nebular ativo (Juvenil ou Adulto), contemplar o céu no Santuário sob chuva. É uma ação do jogador, não a habilidade Contemplação Celestial do Axolote adulto: a habilidade exige o marco "Sete Estrelas", que só existe depois desta cadeia (ver `22-RELATORIO-SEGREDOS.md`).
2. Isso revela a constelação.
3. A ordem de ativação dos 6 pilares segue as cores das Sete Estrelas.
4. Abre-se a câmara sob o altar, com o **Artefato Desconhecido nº 1**.
5. Para completar, faltam componentes do Campo das Bolhas: um ??? **entre dimensões**.
