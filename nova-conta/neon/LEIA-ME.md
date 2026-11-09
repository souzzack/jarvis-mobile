# Entrega 23:47 — produção (estilo neon)

Roteiro: `../roteiros/G-micronovela-entrega-2347-cap01-cap02.md`

## Arquivos

| Arquivo | O que é |
|---|---|
| `pessoa.js` | Kai e Luna: silhueta escura, olhos de traço de luz, mochila com faixa (Kai ciano, Luna rosa), função `pose()` para andar, sentar na moto e arregalar os olhos |
| `cap01.html` | Capítulo 1 inteiro: 4 locações (avenida, Edifício Aurora, escada, apto 304), 13 planos, legendas e textos. `window.frame(t)` desenha o instante `t`. `?w=540` gera prévia |
| `render.js` | Renderiza quadros (`node render.js cap01.html <saida> <largura> <t0> <t1> 30`), pulando os que já existem |

Servidor local na raiz do repositório: `python3 -m http.server 8766`. O three.js vem de `personagem/node_modules` (rodar `npm install` em `personagem/` uma vez).

## Gravar as vozes (ElevenLabs)

Dois arquivos, cada um com as falas **na ordem do roteiro** e cerca de 1 segundo de silêncio entre elas:
- `voz_kai.mp3`: as 12 falas do Kai (bloco "Voz do Kai" do roteiro, com as marcações entre colchetes)
- `voz_luna.mp3`: só o "Kai?"

Sugestão de voz (escolha final do usuário):
- **Kai:** rapaz de ~19 anos, grave, cansado, narrando baixo, quase sussurrando. Na biblioteca do ElevenLabs, filtre por "Portuguese", "young", "deep" ou "narration".
- **Luna:** moça jovem, voz limpa. Basta um sussurro com eco leve.

Quando os arquivos chegarem:
1. Transcrever com tempo por palavra (`personagem/ferramentas/transcrever.py`).
2. Trocar os tempos provisórios da lista `FALAS` em `cap01.html` pelos reais e esticar ou encurtar os planos (`SHOTS`) para acompanhar.
3. Fazer a trilha sintetizada (pulso grave, chuva, sintetizador de fundo) e mixar com as vozes.
4. Renderizar em 1080×1920 e entregar com a capa.

## Tempos provisórios (estimados até chegarem as vozes)

Título 0–3,4s · falas do Kai 3,6–65,5s · "Kai?" 66,3s · tela preta e "PARTE 2" 67,4–72s. **Total: 72s**, acima de 1 minuto.
