#!/bin/sh
# uso: ferramentas/render_ep_list.sh <epNN> "<planos>"  — renderiza com 3 processos (pula quadros prontos)
# quadros saem em personagem/video/frames/<epNN>f (é de lá que compose_ep.html e capa.html leem)
S=$(cd "$(dirname "$0")" && pwd); P=$(dirname "$S"); OUT="$P/video/frames/${1}f"
cd "$P"; mkdir -p "$OUT"
(curl -s -o /dev/null localhost:8765 || (nohup python3 -m http.server 8765 >/dev/null 2>&1 &)); sleep 1
echo $2 | tr ' ' '\n' | xargs -P 3 -I{} sh -c "node $S/render_ep.js $1.html {} $OUT > $OUT/../log_$1_{}.txt 2>&1"
echo "$1: $(ls "$OUT" | wc -l) quadros"
