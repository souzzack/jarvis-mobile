#!/usr/bin/env bash
# Monta o vídeo final: 5 shots de 6 s (24 fps) + legendas + trilha e efeitos.
# Uso: ./montar.sh <pasta_com_frames1..frames5> <saida.mp4>
set -euo pipefail
FR="$1"; OUT="$2"
cd "$(dirname "$0")"
ffmpeg -v error -y \
  -framerate 24 -i "$FR/frames1/%04d.jpg" \
  -framerate 24 -i "$FR/frames2/%04d.jpg" \
  -framerate 24 -i "$FR/frames3/%04d.jpg" \
  -framerate 24 -i "$FR/frames4/%04d.jpg" \
  -framerate 24 -i "$FR/frames5/%04d.jpg" \
  -i trilha_norm.wav \
  -filter_complex "[0][1][2][3][4]concat=n=5:v=1:a=0,fade=t=in:st=0:d=0.5,subtitles=legendas.ass,format=yuv420p[v]" \
  -map "[v]" -map 5:a -c:v libx264 -preset slow -crf 18 -r 24 \
  -c:a aac -b:a 192k -shortest -movflags +faststart "$OUT"
ffprobe -v error -show_entries format=duration:stream=codec_name,width,height,r_frame_rate -of compact "$OUT"
