# Prévias visuais (reconstruídas a partir do código)

As imagens desta pasta **não são capturas do Roblox Studio**. A cena foi reconstruída em three.js com os números exatos do código Luau: tamanhos, cores, materiais aproximados e posições da arena de teste. É uma prévia do visual **provisório** (blocos e esferas) que o jogo cria hoje.

## Imagens

| Arquivo | O que mostra |
|---|---|
| `previa-ui.png` | Interface: nível, barra do chefe, missões, abas, painel de criaturas, energia/vida/estamina e botões de toque no voo |
| `previa-criaturas.png` | As 4 espécies nos 3 estágios, ao lado de um jogador para comparar a escala |
| `previa-artefatos.png` | As 8 formas: Espada, Prancha, Escudo, Plataforma, Cajado, Vassoura, Arco e Asas |
| `previa-chefes.png` | Rainha-Bobina com pilares e Cão-Trovão Alfa com a matilha |
| `previa-base.png` | Base pessoal com Forja nível 3, Jardim nível 2, Expositor com 2 troféus e placas |
| `previa-geral.png` / `previa-arena.png` | Visão geral e detalhe da arena de teste com todos os marcadores |

## Como gerar de novo

1. Copie `cena.html`, `ui.html` e `render.js` para uma pasta.
2. Rode `npm install three@0.160.0`.
3. Rode `node render.js geral arena criaturas artefatos chefes base ui`. É preciso ter o Playwright e o Chromium.

Os modelos, materiais e animações definitivos virão do Blender e do Studio (veja `../09-PLANO-ANIMACOES-EFEITOS.md`).
