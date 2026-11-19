# 07 · Complemento oficial: criaturas, montarias, voo, raças, livros, transportes e artefatos

> Expande o GDD (`01-GDD.md`) **sem substituí-lo**. Valores marcados (T) são pontos de partida, e serão balanceados com testes.
>
> Nada aqui foi testado no Roblox Studio. O que foi implementado está descrito em `08`, e o que foi verificado está em `11`.

## 0. Como tudo se encaixa (o laço)

O laço principal tem seis passos:
1. **Explorar** a Ilha das Tempestades.
2. **Encontrar** uma criatura filhote e criar vínculo com ela.
3. **Crescer** junto com ela, por meio de missões, marcos e desafios.
4. Quando adulta, ela pode virar **montaria**, se a espécie permitir.
5. Ao mesmo tempo, o jogador **aprende** voo em livros antigos e **forja** artefatos que mudam de forma.
6. Cada nova forma de locomoção **abre** lugares que antes eram inalcançáveis, onde estão os próximos segredos.

Combate, locomoção e progressão usam **o mesmo estado de personagem**. Por isso nunca conflitam (veja a seção 12).

---

## 1. Criaturas companheiras (CompanionSystem)

> **Companheiros** são criaturas individuais. **Companhias** são guildas de jogadores (CompanySystem, no GDD). São sistemas diferentes.

**Registro persistente** (`Companheiros/DadosDaCriatura.luau`). Uma criatura no perfil do jogador guarda:
- GUID, espécie e nome (passa pelo filtro de texto do Roblox antes de ser salvo);
- estágio, XP e vínculo (pontos que viram níveis de 0 a 10);
- marcos e desafios cumpridos, e objetivos dimensionais;
- pontos por afinidade e a especialização;
- habilidades, cosmético (variante e cor), estado atual e versão do esquema.

**Comandos:** Acompanhar · Permanecer (fica num ponto, como guarda ou marcador) · Retornar (volta ao jogador ou ao abrigo da base) · Montar (só adulto de espécie montável).

**Comportamento por espécie.** Nenhuma criatura é cópia de NPC genérico. A IA (CompanionAI) lê `comportamento` da espécie:

| Parâmetro | Efeito |
|---|---|
| `estilo` (Flutua, Saltita, Trota, Plana) | Locomoção e animações |
| `distanciaSeguir`, `ladoPreferido` | Onde a criatura fica em relação ao jogador |
| `curiosidade` (0 a 1) | Chance de investigar pontos de interesse: cristais, tocas, correntes |
| `coragem` (0 a 1) | Se entra em combate, se distrai o inimigo ou se esconde |
| `reacoes` | Reações a chuva, noite e combate (cada espécie tem as suas) |

**Espécies iniciais** (`Config/Especies/`):

| Espécie | Papel | Montaria | Observação |
|---|---|---|---|
| **Axolote Nebular** | Suporte e descoberta | Nunca (pequeno demais) | O modelo adulto é o **V12 aprovado** (não alterado). A Contemplação Celeste continua sendo pista do segredo. |
| **Lebre-de-Faísca** | Coleta e passagens escondidas | Nunca | Pacífica da Ilha (GDD 6.2). |
| **Cão-Trovão** | Combate | **Terrestre** (adulto, porte de cavalo) | Filhote órfão da matilha do Alfa. |
| **Raia-das-Nuvens** (nova, original) | Exploração aérea | **Voadora** (adulta, 9 studs de envergadura) | Vive nas correntes acima da tempestade. |

## 2. Evolução: Filhote → Juvenil → Adulto (CompanionGrowthSystem)

O crescimento exige **todos** os requisitos do próximo estágio (`Companheiros/Crescimento.luau`):
- **XP compartilhada:** combate, exploração e missões feitas com a criatura junto.
- **Nível de vínculo:** atividades com teto diário por tipo (120 pontos), então ficar repetindo a mesma ação não acelera.
- **Marcos da espécie:** por exemplo, "primeira constelação" ou "achar a toca".
- **Desafio próprio:** só para virar adulto. Por exemplo, "Prova da Matilha" ou "Atravessar a Tormenta".

**Garantias:**
- Esperar não basta.
- Não há compra que faça crescer.
- O crescimento é permanente: não existe função para regredir.
- O resultado é salvo pelo PlayerDataSystem (contrato em `08`).

| Estágio | Porte | Animações | Habilidades | Montaria |
|---|---|---|---|---|
| Filhote | 35 a 55% | Conjunto próprio (desajeitado, curioso) | Básica | Não |
| Juvenil | 65 a 80% | Conjunto novo (mais confiante) | Intermediária | Não (nem em uso regular) |
| Adulto | 100% | Conjunto completo, mais o de montaria | Avançada | Se a espécie permitir |

**Evolução visual.** Cada estágio tem **modelo e animações próprios**, mas preserva a identidade da espécie: silhueta, paleta e marcas. O adulto do Axolote parte do V12 aprovado.

## 3. Vínculo Dimensional (DimensionalBondSystem)

- **De onde vêm os pontos:** só de **objetivos concluídos com a criatura** (cada um conta uma vez), nunca de tempo parado numa região (`Config/AfinidadesDimensionais.luau`).
- **Quando especializar:** com a criatura **adulta** e pontos ≥ limiar, numa afinidade **possível para a espécie** e **disponível** (dimensão liberada).
- **Reversível:** trocar exige o **Ritual de Realinhamento**. Assim a escolha nunca prende o jogador para sempre.
- **Identidade preservada:** a especialização é uma **variante** (detalhe visual e habilidades extras); a criatura continua sendo da mesma espécie.
- **Afinidade nova = entrada nova na config.** O código não muda.

| Afinidade | Dimensão | Habilidades | Situação |
|---|---|---|---|
| Tempestade | Ilha das Tempestades | Impulso energético, resistência a tempestade | **Disponível** (4 objetivos definidos) |
| Bolhas | Campo das Bolhas | Escudo de bolha, flutuação temporária | Planejada: a dimensão está congelada e os arquivos dela não foram tocados |
| Vulcânica | Ilha dos Vulcões | Resistência ao calor, passo de brasa | Planejada |
| Gelo | Cidade Congelada | Resistência ao frio, sopro lento | Planejada |

## 4. Montarias (MountSystem)

**Terrestres:**
- aceleração e frenagem próprias, curvas com limite de giro e salto;
- capacidade de travessia por espécie (água rasa, encostas);
- montar e desmontar com animação.

**Voadoras:**
- decolagem, pouso, voo, subida e descida, inclinação, voo acelerado e câmera;
- usam **o mesmo núcleo de voo** do jogador, com o perfil da espécie (`montaria.perfilVoo`).

**Quem pode montar:** só espécies com bloco `montaria` e estágio ≥ `estagioMin` (`Crescimento.podeMontar`).

**Verificações no servidor:**

| Verificação | Onde |
|---|---|
| Espaço disponível | Caixa `espacoNecessario` da espécie, mais `espacoLivre` medido |
| Estado da criatura (adulta, viva, ao lado) | MountSystem: distância máxima de 12 studs (T) |
| Estado do jogador (no chão, não atordoado, sem outro modo) | `MaquinaDeLocomocao.montar` |
| Permissão (a criatura é dele) | GUID no perfil |
| Áreas proibidas | Zonas sem voo / sem montaria |
| Interrupções | Golpe forte, zona, energia: `interromper`, e depois a montaria pousa |
| Desconexão | O estado não é salvo no meio do voo; ao voltar, jogador e criatura nascem no chão |

**Nova espécie = nova config.** A locomoção não é reprogramada.

## 5. Voo cinematográfico (FlightSystem)

**Estados** (nomes do documento → código):

| Documento | Código |
|---|---|
| Grounded | `Solo` |
| Takeoff | `Decolagem` |
| Hover | `Pairar` |
| Flight | `Voo` |
| Boost | `Impulso` |
| Descent | `Descida` |
| Landing | `Pouso` |
| Interrupted | `Interrompido` |

Há também `Planando` e `Montado`. O diagrama e as regras estão em `08`, seção 3.

**Sensação** (referência de experiência: o vídeo enviado antes; nada foi copiado dele):

| Requisito | Como foi feito |
|---|---|
| Movimento 3D e aceleração gradual | `FisicaDeVoo.passo`: aproxima a velocidade do alvo com a aceleração (ou desaceleração) do perfil |
| Controle vertical | Teclas de subir e descer, **mais** a inclinação da câmera ao avançar (voar para onde se olha) |
| Inclinação corporal e nas curvas | Rolagem proporcional à velocidade de giro, com limite por perfil; arfagem pela razão vertical/horizontal; tudo suavizado |
| Transições suaves | A física começa com a velocidade atual (sem tranco); estados com duração (decolagem e pouso) |
| Campo de visão dinâmico | `CameraDeVoo`: FOV sobe com a velocidade (+12°) e com o impulso (+7°), com teto de 95° e suavização lenta |
| Câmera estabilizada | Sem rolar o horizonte, sem tomar o controle do jogador; o ponto de mira sobe um pouco no voo |
| Rastros e partículas configuráveis | `EfeitosDeVoo`: a quantidade segue a qualidade gráfica do aparelho; efeitos somem a 180 studs |
| Sons de vento e energia | Volume e tom acompanham a velocidade. O som atual é **provisório** (som padrão do Roblox); os sons próprios ficam para a produção |
| Energia e recuperação | Energia de voo separada da estamina: 100 (T), recupera 14/s no chão depois de 1,2 s |
| Regras de pouso | "Descer" rente ao chão pousa; encostar no chão em voo motorizado pousa sozinho |
| Restrições de altitude | Teto absoluto de 600 (T), por dimensão |
| Verificação no servidor | `ValidadorDeDeslocamento` a 10 Hz, com folga de latência; 2 violações seguidas devolvem o personagem à última posição válida |
| Opção de conforto | O atributo `GuardioesCameraCalma` desliga a variação de FOV |

## 6. Raças (RaceSystem) — nomes e valores provisórios

| Raça | Vantagem | Limitação | Voo |
|---|---|---|---|
| Humano | Maestria mais rápida; usa tudo sem penalidade | Não voa naturalmente | Livro, artefato, montaria ou planador |
| Alado | Voo natural desde o início | −8% de vida; não usa planador; armadura pesada deixa o voo mais lento | Asas (o impulso vem do Tomo) |
| Elemental | +15% de resistência ao elemento | −10% contra o oposto | Livro, artefato ou montaria |
| Astral | Esquiva mais longa; percebe pistas comuns | −15% de energia de voo | Livro, artefato ou montaria |

- **Nenhuma raça é obrigatória** para a história ou para os segredos: todo bloqueio de exploração tem um caminho sem a raça.
- Os valores são **(T)**.

## 7. Livros mágicos e bibliotecas antigas (MagicBookSystem)

| Livro | Ensina | Onde (plano; nenhum mapa foi alterado) | Missão / enigma |
|---|---|---|---|
| Grimório dos Céus | Voo mágico | Biblioteca do Observatório, depois da restauração | Alinhar as lentes na ordem das constelações das anotações |
| Tomo das Correntes Astrais | Impulso e curvas mais fechadas | Topo da Torre Meteorológica, com a energia religada | Atravessar os anéis de vento sem tocar o chão |
| Códice da Leveza | −20% de energia gasta | Campo das Bolhas (expansão futura) | Subir à bolha mais alta só com correntes |
| Manuscrito Sem Nome | Segredo (???) | Oculto | Anotações nas margens dos outros livros, mais a Contemplação sob chuva |

- **Requisitos no servidor.** Os requisitos de leitura ficam só no servidor (`ConfigSecreta/Livros.luau`); o cliente vê apenas o texto público.
- **Aprendizado permanente.** A habilidade aprendida é salva no perfil (`habilidades` + `livrosLidos`), então ninguém precisa achar o livro de novo.
- **Arquitetura das bibliotecas.** Cada dimensão tem sua própria identidade:
  - na Ilha, estantes de cobre com ferrugem verde, cúpulas de vidro trincado e cabos de energia;
  - no Campo das Bolhas, estantes em bolhas flutuantes.

## 8. Planadores e outros transportes (TransportSystem)

| Meio | Velocidade (T) | Requisito | Restrição | Energia | Ponto forte |
|---|---|---|---|---|---|
| A pé | 16 | — | — | — | Combate |
| Planador | 14 a 30 (perde altura) | Habilidade Planador | Altura ≥ 8; não sobe sem corrente | 0 | Grátis e cedo; aproveita correntes |
| Plataforma (Escudo do Firmamento) | 14 | Artefato no estágio 2 | No máximo 8 acima do chão | 14/s (alto) | Atravessar abismos curtos |
| Voo mágico | 32 | Grimório | Zonas sem voo | 6/s | Liberdade em 3D |
| Prancha do Horizonte | 42 | Artefato no estágio 2 | Zonas sem voo | 7/s | Velocidade em linha reta |
| Vassoura (Cajado) | 38 | Artefato no estágio 2 | Zonas sem voo | 6,5/s | Agilidade e subida |
| Asas Perdidas (???) | 46 / 70 | Segredo | Zonas sem voo | 6/s | Mergulho e arrancada |
| Cão-Trovão (montaria) | 34 | Criatura adulta | Só no chão | Estamina da criatura | Terreno, sem gastar a energia do jogador |
| Raia (montaria) | 36 / 52 | Criatura adulta | Decolagem lenta (0,8 s) | 3/s (barata) | Viagens longas |
| Viagem rápida | — | Ponto desbloqueado | Só entre lugares já visitados | — | Ligar regiões |

**Anti-"um transporte que anula os outros":**
- velocidade alta custa energia ou tem restrição;
- perfis baratos são lentos ou baixos;
- um teto global de bônus de 1,35× (`PerfilEfetivo`);
- zonas sem voo mantêm a exploração a pé e com montaria relevante;
- correntes de ar e travessias especiais pedem o meio certo.

## 9 e 10. Artefatos metamórficos e os quatro iniciais

**Um item, várias formas:**
- o artefato tem um GUID só, e trocar de forma não cria nem apaga item (`MaquinaDeArtefato`);
- durante a troca, **nenhuma** forma está ativa.

Cada artefato tem: identificador, qualidade, formas (tipo, arma ou perfil, estágio mínimo, efeito, sequência de montagem), duração e recarga da troca, custo de energia, regra de cancelamento, regra de retorno ao combate e estágios.

| Artefato | Qualidade | Forma de luta | Forma de locomoção |
|---|---|---|---|
| **Espada do Horizonte** | Arcano | Espada elétrica, mais rápida que a comum | **Prancha voadora**: a lâmina gira, a guarda abre em aletas, o cabo recolhe e a lâmina alarga sob os pés |
| **Escudo do Firmamento** | Druida | Escudo (defesa e aparar melhores, Etapa D) | **Plataforma** flutuante baixa |
| **Cajado dos Ventos Antigos** | Arcano | Cajado de vento (Arcanista, Etapa D) | **Vassoura encantada** |
| **Arco das Asas Perdidas** | **???** | Arco secreto | **Asas de luz**: a forma mais rápida, visual exclusivo e mecânica de mergulho |

**Retorno ao combate (Espada do Horizonte):**
- pedir a forma de espada em pleno voo sai da prancha **na hora**;
- o personagem cai amortecido (queda segura) enquanto a espada se monta;
- quando a espada fica pronta, ele pode atacar no chão.

**Regras do ???:**
- a configuração do Arco fica **só no servidor**;
- o perfil de voo chega ao dono apenas enquanto a forma está ativa;
- a obtenção vem só de segredos e enigmas (SecretDiscoverySystem), **nunca por compra**.

## 11. Evolução dos artefatos (ArtifactProgressionSystem)

Estágios da Espada do Horizonte:
1. Arma.
2. A missão *O Horizonte Partido* ativa a prancha.
3. Materiais (Núcleo de Tempestade, Pena de Raia, Liga Arcana) dão +4 de velocidade, −10% de custo e +4° de manobra.
4. Desafios (*Anel dos Relâmpagos*, *Guardião sem cair*) liberam o **Corte em Voo**.

**Regras da evolução:**
- **Requisitos:** só exploração, fabricação e missões; o consumo de materiais é uma transação atômica do InventorySystem.
- **Equilíbrio:** os bônus passam pelo mesmo teto global de 1,35×.
- **Relevância:** o artefato pode ganhar estágios novos em dimensões futuras, então continua útil.

## 12. Integração: estados incompatíveis que o código impede

| Conflito | Quem impede |
|---|---|
| Montar com outra montaria ativa / dois voos ao mesmo tempo | `MaquinaDeLocomocao`: um `modo` por vez; `decolar`/`montar` só a partir de estados válidos |
| Duplicar equipamento na transformação | `MaquinaDeArtefato`: mesmo GUID, só muda `forma` |
| Dano de espada no modo prancha | Guarda do CombatSystem: recusa ataque fora do estado `Solo` e em forma de locomoção |
| Transformar item inexistente | O servidor procura o GUID no inventário do jogador |
| Cliente inventar habilidade | Habilidades só por `MovementAbilitySystem.conceder` (servidor); o cliente só pede intenções |
| Velocidade arbitrária por evento remoto | O cliente nunca envia velocidade nem perfil; o perfil efetivo é calculado e enviado pelo servidor; o deslocamento é conferido |
| Ataque durante a troca de forma | Guarda do artefato (`transformando`) |
| Golpe durante voo ou troca | Dano ≥ 12 derruba do voo; acima do limiar do artefato, cancela a troca |

## 13. Arquitetura técnica

A tabela dos 20 módulos pedidos, com arquivo e situação de cada um, os contratos com os sistemas anteriores e a árvore de pastas estão em `08`.

## 14. Interface (planejamento)

**Princípios:**
- poucos botões, contextuais por estado;
- requisito sempre explicado (`Util/Mensagens.luau`), sem revelar segredos;
- a mesma tela funciona no PC e no celular (listas em grade que viram rolagem vertical).

| Tela | Conteúdo | Situação |
|---|---|---|
| Barra de energia de voo e estado | Aparece só no ar ou recuperando | **Feita** (`HudDeLocomocao`) |
| Botões contextuais de voo e planador (toque) | Voar / Planar no ar; Subir, Descer, Impulso e Pousar no voo | **Feitos** (`ControleDeLocomocao`) |
| Botão de forma do artefato | "Forma" só com artefato que tem forma de locomoção | **Feito** (`TransformacaoDeArtefato`) |
| Botões de combate somem no voo | Menos botões na tela | **Feito** |
| Lista de companheiros | Cartões com estágio, vínculo e estado; comandos de acompanhar, permanecer, retornar e montar | Planejada (Etapa 6) |
| Detalhes da criatura | Barra de XP, nível de vínculo, marcos (✓/✗), desafio, afinidades | Planejada (Etapa 7) |
| Seleção de montaria | Só adultas montáveis; motivo quando indisponível | Planejada (Etapa 8) |
| Equipamentos metamórficos | Formas (liberada ou adormecida), estágio, o que falta para o próximo | Planejada (Etapa 11) |
| Habilidades aprendidas e livros descobertos | Grimório pessoal com livros lidos e dicas públicas; os ocultos aparecem como "???" | Planejada (Etapa 9) |
| Gerenciamento de transporte | Atalho do transporte preferido | Planejada (Etapa 12) |

## 15. Desempenho e multiplayer

| Estratégia | Onde |
|---|---|
| IA de criatura a 10 Hz, dormindo a mais de 250 studs, sem física própria quando longe | EnemySystem (feito); CompanionAI segue o mesmo padrão |
| Física de voo no cliente dono; servidor só confere a 10 Hz | MovementSystem |
| Efeitos lidos de atributos replicados (sem mensagens extras); atualização a 5 Hz; corte por distância e qualidade | EfeitosDeVoo |
| Visual de transformação só no cliente (peças sem colisão nem massa) | TransformacaoDeArtefato |
| Rede: uma RemoteEvent por sistema, balde de fichas por jogador, energia enviada no máximo 5×/s | Todos |
| Sem duplicação | GUIDs, transações atômicas (Etapa D), nada de cópia na troca de forma |
| Desconexão | Nada de voo ou forma é salvo no meio; ao voltar, tudo começa no chão e na forma inicial |
| Animações reutilizáveis | Conjuntos por estilo de locomoção (Flutua, Saltita, Trota, Plana), reaproveitados entre espécies (`09`) |

## 16. Ordem de implementação e situação

| Etapa | Conteúdo | Situação |
|---|---|---|
| 1 | Documentação complementar | **Feita** (07 a 11) |
| 2 | Estados, interfaces e contratos | **Feita** (`08`) |
| 3 | Núcleo: chão, decolagem, voo, impulso, pouso | **Código escrito** (puro + servidor + cliente) |
| 4 | Planador e controles móveis | **Código escrito** |
| 5 | Espada do Horizonte: espada ↔ prancha | **Código escrito** (visual provisório) |
| 6 a 8 | Companheiros, crescimento, montarias | **Lógica pura e configs escritas**; sistemas de servidor e IA pendentes |
| 9 | Livros e desbloqueio persistente | Configs e concessão escritas; leitura no mundo e persistência pendentes (dependem do PlayerDataSystem) |
| 10 | Vínculo Dimensional | **Lógica pura escrita** |
| 11 e 12 | Expandir artefatos; integrar com inventário, fabricação, missões e progressão | Contratos definidos; dependem das Etapas D a G do plano original |
| 13 | Testes multiplayer e de desempenho | Plano em `10` |
| 14 | Integração com os mapas reais | Plano em `10`, seção 5 |
