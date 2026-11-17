# Identidade visual — série de versículos, frases e reflexões

Três direções para escolher. Todas no formato 1080 × 1350 (4:5), com margem fixa de 96 px, rótulo de categoria no topo, mensagem como protagonista e referência pequena no rodapé, sempre no mesmo lugar. Essa repetição é o que dá cara de série no feed, mesmo com fundos diferentes.

Demos em `demos/`, editáveis em `templates/` (HTML: troque o texto e renderize de novo).

> **Sobre as fotos dos demos:** neste ambiente não tenho acesso a bancos de imagem, então o fundo do conceito A é uma simulação (degradê com desfoque e granulação) só para mostrar a luz e a composição. Na produção, ele recebe uma fotografia real: da própria igreja ou de bancos gratuitos com licença comercial (Unsplash, Pexels). Os conceitos B e C funcionam como estão.

---

## A — AURORA · cinematográfico

**1. Conceito.** "Renovam-se cada manhã." A fé como luz que chega devagar. Fotografia de grande formato na hora dourada, com o texto em serifa clássica, como o pôster de um filme sério. Transmite esperança sem euforia. É a direção mais emocional e a que mais rende compartilhamento nos stories.

**2. Paleta.**
| Cor | Hex | Uso |
|---|---|---|
| Carvão | `#1C1A17` | véu sobre a foto, fundos |
| Marfim | `#F4EDE3` | texto principal |
| Âmbar | `#E8B27A` | fio da referência, palavra em destaque |
| Névoa | `#8C8478` | textos secundários |

**3. Tipografia.** *Cormorant Garamond* Medium (frase, 64–80 px) com itálico para destacar uma única expressão por arte. *Inter* Medium em caixa alta, com espaçamento de 0,18–0,32 em (rótulos e referência, 18–24 px). As duas são gratuitas (Google Fonts).

**4. Fotografia.** Luz natural rasante: amanhecer, contraluz, janela, neblina. Paisagens amplas, mãos, silhuetas de costas, estrada, mar calmo. Nada de rosto em close nem de céu com raios artificiais. Tratamento: tons quentes desaturados, sombras densas, grão leve de filme. A foto sempre deixa o terço superior escuro ou limpo para o texto.

**5. Composição.**
```
┌────────────────────────────┐
│ CATEGORIA            Nº 00 │  ← rótulos, 96 px da borda
│                            │
│ “Frase em serifa grande,   │  ← terço superior, alinhada à esquerda
│  com uma expressão em      │
│  itálico âmbar.”           │
│                            │
│         ☼  (luz da foto)   │  ← ponto de luz no terço inferior direito
│ ▁▁▁▂▃▂▁▁▂▃▂▁▁▁ horizonte   │
│ ── REFERÊNCIA  ARA  IGREJA │  ← rodapé fixo
└────────────────────────────┘
```

**6. Demonstrativo:** `demos/a-aurora.png` — **Versículo:** Lamentações 3:22-23 (ARA).

Legenda sugerida:
> Tem dia em que a gente acorda sem força nenhuma. E é justamente nesse dia que a promessa vale: as misericórdias de Deus não acabaram ontem. Elas se renovam hoje de manhã.
>
> Salve para ler amanhã cedo e envie para alguém que precisa recomeçar. 🌅
>
> Lamentações 3:22-23 (Almeida Revista e Atualizada)

---

## B — SILÊNCIO · editorial minimalista

**1. Conceito.** Uma página de livro bem diagramada. Papel, tinta e uma única cor de acento. Sem foto, sem ornamento: a frase sustenta a arte sozinha. Passa maturidade, calma e inteligência. É o formato mais "salvável" e o mais rápido de produzir toda semana.

**2. Paleta.**
| Cor | Hex | Uso |
|---|---|---|
| Papel | `#EFE9DF` | fundo, com textura sutil |
| Tinta | `#1F1D1A` | texto e fios |
| Terracota | `#B4532A` | itálico de destaque e o ponto final |
| Pedra | `#9A9187` | notas e textos de apoio |

Variação para alternar no feed: fundo Tinta com texto Papel (versão noturna).

**3. Tipografia.** *Fraunces* Regular em corpo grande (90–110 px), com espaçamento negativo, e itálico na cor terracota. *Inter* para rótulos e notas. A assinatura da série é o ponto terracota no fim da frase.

**4. Fotografia.** Na maior parte das peças, não há foto. Quando houver (1 em cada 4), use natureza-morta em luz de janela: Bíblia aberta, xícara, papel, sombra de cortina. Sempre em uma faixa ou recorte, nunca de fundo inteiro, e em tons quentes e foscos.

**5. Composição.**
```
┌────────────────────────────┐
│ ────────────────────────── │  ← fio superior
│ ● CATEGORIA     NOME SÉRIE │
│                            │
│ Frase enorme em serifa,    │  ← centro óptico
│ com final em               │
│ itálico terracota●         │
│                            │
│ INSPIRADA EM               │
│ Referência do contexto     │                SUA IGREJA
│ ────────────────────────── │  ← fio inferior
└────────────────────────────┘
```

**6. Demonstrativo:** `demos/b-silencio.png` — **Frase autoral** (não é versículo), identificada como "Inspirada em Marcos 4:35-41".

Legenda sugerida:
> Os discípulos acharam que iam afundar. Jesus estava no mesmo barco, dormindo. A tempestade não parou porque eles tiveram fé; ela parou porque Ele se levantou.
>
> Às vezes a fé não muda o vento. Muda para onde você olha.
>
> Leia a passagem completa em Marcos 4:35-41. Envie para quem está no meio da tempestade. ⛵

---

## C — VIGÍLIA · conceitual noturno

**1. Conceito.** Um quarto escuro e uma porta entreaberta. A única luz do quadro aponta para onde ir. Cada arte tem **um** símbolo de luz desenhado com propósito (porta, janela, lamparina, fresta, estrada), nunca um clichê decorativo. A tipografia é forte e contemporânea, com cara de campanha de igreja jovem. É a direção ideal para as reflexões, que pedem mais texto.

**2. Paleta.**
| Cor | Hex | Uso |
|---|---|---|
| Noite | `#0E1116` | fundo |
| Ardósia | `#1E2633` | planos e profundidade |
| Luz | `#F2C77B` | a fonte de luz, o itálico e o rótulo |
| Cinza-claro | `#A7ADB7` | rodapé e texto de apoio |

**3. Tipografia.** *Inter Tight* ExtraBold em caixa alta (título, 80–90 px), *Instrument Serif* Itálico na cor Luz (a virada da frase) e *Inter Tight* Regular (corpo, 30–34 px). O contraste entre o bloco pesado e o itálico leve é a assinatura da série.

**4. Fotografia.** Fotos de baixa luz com uma fonte única: fresta de porta, vela, janela à noite, poste na estrada, luz de celular num quarto. Exposição para as altas luzes, sombras quase pretas, grão visível. Quando não houver foto, a luz é desenhada em vetor (como no demo).

**5. Composição.**
```
┌────────────────────────────┐
│ REFLEXÃO · 00              │
│ TÍTULO EM BLOCO            │        ▌ ← fonte de luz,
│ PESADO.                    │        ▌   terço direito
│ E a virada em itálico.     │        ▌
│                            │        ▌
│ Corpo curto, 3 ou 4 linhas,│        ▌
│ com uma frase em negrito.  │  ──────▌────── chão
│                            │      ╱   ╲  feixe
│ ── PARA MEDITAR · REF      │ SUA IGREJA
└────────────────────────────┘
```

**6. Demonstrativo:** `demos/c-vigilia.png` — **Reflexão** com texto autoral e indicação de leitura (Provérbios 3:5-6).

Legenda sugerida:
> "Confia no Senhor de todo o teu coração e não te estribes no teu próprio entendimento." (Provérbios 3:5, ARA)
>
> Confiar não é ter o mapa inteiro. É conhecer quem está guiando. Qual parte da sua vida você está tentando entender antes de entregar? Responda aqui, nós vamos orar por você. 🕯️

---

## Comparativo rápido

| | A · Aurora | B · Silêncio | C · Vigília |
|---|---|---|---|
| Sensação | esperança, emoção | calma, maturidade | intimidade, decisão |
| Melhor para | versículos | frases curtas | reflexões |
| Depende de foto | sim, sempre | não | opcional |
| Produção semanal | média (curadoria de foto) | rápida | rápida |
| Força no feed | compartilhar nos stories | salvar | comentar e enviar |

**Recomendação:** use **C (Vigília)** como identidade principal, porque é a mais diferente do que as igrejas costumam postar e aceita as três categorias. Leve dela a lógica de "uma luz por arte". Se preferir algo mais clássico e acolhedor, use **A**. Também dá para combinar: A para versículos e C para reflexões, desde que se mantenham a mesma margem, o mesmo rodapé e o mesmo âmbar.

## Conferência de textos

- Lamentações 3:22-23 e Provérbios 3:5 estão na redação da **Almeida Revista e Atualizada (ARA)**. Não tive acesso a uma Bíblia online neste ambiente para conferir letra por letra. **Confira com a ARA impressa antes de postar** (pontuação e "cada manhã" × "a cada manhã" variam entre edições).
- As frases dos conceitos B e C são autorais e estão identificadas como tal ("Frase", "Inspirada em", "Para meditar"). Em nenhum lugar aparecem como versículo.
