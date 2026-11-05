# Ferramentas do pipeline (Davi & Deus)

Rode tudo a partir de `personagem/`, com o servidor local ligado: `python3 -m http.server 8765`.
Precisa de Node + Playwright (Chromium), Python 3 com numpy, faster-whisper e ffmpeg.

| Script | Para quê | Uso |
|---|---|---|
| `transcrever.py` | Transcreve as vozes com tempo por palavra (gera os índices para o `config.json`) | `python3 ferramentas/transcrever.py <modelo-whisper> voz_davi.mp3 voz_deus.mp3` |
| `verificar_falas.py` | Confere cada trecho cortado pelo `pipeline.py` com o whisper | `cd eps101112 && python3 ../ferramentas/verificar_falas.py <modelo-whisper> ep11` |
| `colisao.js` | Checa personagem × personagem, × móveis e braço × próprio corpo em todos os planos | `node ferramentas/colisao.js ep11 0.5` |
| `render_ep.js` | Renderiza um plano (ou só alguns tempos, para teste) | `node ferramentas/render_ep.js ep11.html SH05 <saida> [30,35]` |
| `render_ep_list.sh` | Renderiza vários planos com 3 processos, pulando quadros prontos | `sh ferramentas/render_ep_list.sh ep11 "SH01 SH02 ..."` |
| `compose_eps.js` | Pós-produção (título, legendas, versículos, texto final) quadro a quadro | `EP=ep11 node ferramentas/compose_eps.js <saida> 0 <n_quadros>` |
| `capa_run.js` | Gera a capa a partir de `capa.html` | `node ferramentas/capa_run.js capa.png "img=video/frames/ep11f/02640.jpg&l1=...&l2=...&tag=...&verso=...&cor=ffd27a&zoom=1&fx=0.5&fy=0.3&luz=0.3"` |
| `trilha_base.py` | Instrumentos sintetizados (piano, cordas, pad, caixinha) para começar o `trilha.py` de um episódio | copiar e acrescentar o arranjo |
| `shot2d.js` / `shot3d.js` / `story_run.js` / `story_som.py` | Capturas de páginas avulsas (stories, avatar, artes) | `DSF=2 node ferramentas/shot3d.js ...` |
| `tune.js` | Busca de poses sem colisão (usa `tune.html`) | |

**Modelo do whisper (small, CTranslate2 int8):** não está no repositório. Baixe pelo npm (`npm pack @skillninja/shortmovie-telop-model-p0` … `p3`) e junte as partes do `model.bin`.

**Mixagem (depois do `trilha.py`):**
```
ffmpeg -i trilha.wav -af loudnorm=I=-20:TP=-2 -ar 48000 trilha_norm.wav
ffmpeg -i pista_davi.wav -i pista_deus.wav -filter_complex "[0][1]amix=inputs=2:normalize=0,loudnorm=I=-16:TP=-1.5[v]" -map "[v]" -ar 48000 vozes.wav
ffmpeg -i trilha_norm.wav -i vozes.wav -filter_complex "[1]aformat=channel_layouts=stereo,asplit[sc][vv];[0][sc]sidechaincompress=threshold=0.03:ratio=5:attack=40:release=600[m];[m][vv]amix=inputs=2:normalize=0,alimiter=limit=0.95" -ar 48000 mix.wav
```
**Vídeo final:**
```
ffmpeg -framerate 24 -i <saida_compose>/%04d.jpg -i mix.wav -af "volume=3.3dB,alimiter=limit=0.95" -c:v libx264 -preset veryfast -crf 21 -pix_fmt yuv420p -c:a aac -b:a 192k -shortest -movflags +faststart episodio.mp4
```
