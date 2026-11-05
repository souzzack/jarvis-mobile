# Série "Davi & Deus" — notas para continuar a produção

## O que é
Animação 3D (blocos arredondados, three.js) de conversas sinceras do Davi (menino, cabelo cacheado, camiseta marrom) com Deus (luz quente da janela). Público: adolescentes. ~1min40 por episódio, vertical 1080×1920, legendas com etiqueta DAVI/DEUS, versículos na tela, texto final + "Manda pra alguém que...".
Vozes do usuário no ElevenLabs: Davi = "Davi Andrei"; Deus = "Spuds Oxley - Grandpa". Marcações de voz em inglês entre colchetes ([sad], [warm]...). Usuário grava uma voz por arquivo, falas em ordem com pausas.

## Episódios entregues (mascote-claude/davi/epNN/)
1 Deus cansa de mim? · 2 Ninguém gosta de mim? · 3 Por que o Senhor não respondeu? (luto) · 4 Por que eu não sou como eles? (comparação) · 5 É culpa minha? (pais brigando) · 6 E se ela for embora? (história de seguidor, anonimizada) · 7 Por que eu não sinto nada quando oro? · 8 Meu coração não para (ansiedade) · 9 Eu não consigo perdoar ele · 10 Tenho vergonha de ser cristão.
Capas: mascote-claude/capas/ (estilo novo, SEM número do episódio). Página com as capas: https://claude.ai/artifact/7WR88cvaFSfzrZexTZYsA2
Story caixa de perguntas: mascote-claude/perfil/story-caixa-de-perguntas.png

## Pendente
EP 11 "Eu não sou bom em nada" entregue. EP 12 "Eu tenho raiva de mim": cenas prontas (ep12.html), em produção. Legendas de post dos dois: mascote-claude/davi/legendas-ep11-ep12.md.
Legendas de post: entregar Instagram + TikTok + comentário fixado (+ aviso CVV 188 em temas sensíveis).

## Como produzir um episódio novo (ex.: ep11)
1. Pasta eps101112/ep11/: copiar voz_davi.mp3 e voz_deus.mp3; transcrever com `ferramentas/transcrever.py` (faster-whisper; modelo baixado via npm @skillninja/shortmovie-telop-model-p0..p3) → transcricao.json.
2. config.json: S_davi / S_deus (índice da 1ª palavra de cada fala), order ("D1:1.0 G1 D2:.6 ..."), fixs (correções de legenda). Rodar `python3 eps101112/pipeline.py ep11` → falas.json, pistas, envelopes.json (boca/luz), legendas.json. Conferir cada trecho com `ferramentas/verificar_falas.py`. Se os tempos do whisper vierem deslocados, use `cuts_davi`/`cuts_deus` (tempos de corte nos silêncios) no config.
3. Página epNN.html usando serie.js (quartoRig, poses seguras pray/chestHand, setupRenderer/finish). Definir SHOTS em tempo do vídeo e expressões (makeExpr). Cenários extras em cenarios.js (escola, cidade, igreja).
4. Verificação de colisões: `node ferramentas/colisao.js ep11 0.5` (personagem×personagem, ×móveis, braço×corpo). Corrigir até ficar limpo (contato da cabeça no travesseiro deitado é aceitável).
5. Quadros de teste: `node ferramentas/render_ep.js ep11.html SH05 <saida> 30,35`.
6. Render: `sh ferramentas/render_ep_list.sh ep11 "SH.. SH.."` em segundo plano (continua pulando quadros prontos). Quadros em video/frames/ep11f.
7. Trilha: eps101112/epNN/trilha.py (sintetizada em numpy) → trilha_norm.wav; mix com vozes (sidechain) → mix.wav.
8. Pós: eps101112/epNN/compose.json (título 2 linhas, flash/sépia, hideTitle, versículos, dips, end) + compose_ep.html; `EP=ep11 node ferramentas/compose_eps.js <saida> 0 N`.
9. Encode: ffmpeg -preset veryfast -crf 21 (evita estourar tempo) → mascote-claude/davi/ep11/<nome>.mp4.
10. Capa: capa.html via ferramentas/capa_run.js (img=quadro forte, l1, l2, tag, verso, cor, zoom, fx, fy, luz). Mandar vídeo + capa no chat (SendUserFile).

Comandos de mixagem e do vídeo final: `ferramentas/README.md`.

## Cuidados
- Personagens nunca podem se atravessar (usuário reclamou duas vezes). Sempre rodar colisao.js.
- Histórias de seguidores: anonimizar e pedir permissão.
- Servidor local: `cd /home/user/personagem && python3 -m http.server 8765`.
- pkill/pgrep com padrões que aparecem no próprio comando matam o shell: usar scripts em arquivo.
