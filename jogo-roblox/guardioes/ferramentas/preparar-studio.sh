#!/usr/bin/env bash
# Guardiões do Multiverso — prepara o teste no Roblox Studio (macOS).
# Faz o mesmo que preparar-studio.ps1: baixa o código do branch, baixa o Rojo 7.4.4 para dentro da pasta
# (sem instalar no sistema), instala o plugin do Studio e inicia o "rojo serve". Não mexe em nenhum place.
# Uso:  bash preparar-studio.sh
set -euo pipefail
REPO="https://github.com/souzzack/jarvis-mobile.git"
BRANCH="claude/intelligent-cerf-lfd2d7"
BASE="$HOME/GuardioesTeste"
VERSAO="7.4.4"

command -v git >/dev/null || { echo "Falta o Git (no Mac: xcode-select --install)"; exit 1; }
if [ -d "$BASE/.git" ]; then
  git -C "$BASE" fetch origin "$BRANCH"; git -C "$BASE" checkout "$BRANCH"; git -C "$BASE" pull --ff-only origin "$BRANCH"
else
  git clone --branch "$BRANCH" --single-branch "$REPO" "$BASE"
fi
PROJETO="$BASE/jogo-roblox/guardioes"
FERR="$PROJETO/ferramentas/bin"
ROJO="$FERR/rojo"
if [ ! -x "$ROJO" ]; then
  mkdir -p "$FERR"
  ARQ=$(uname -m); [ "$ARQ" = "arm64" ] && ARQ="aarch64"
  curl -fL "https://github.com/rojo-rbx/rojo/releases/download/v$VERSAO/rojo-$VERSAO-macos-$ARQ.zip" -o "$FERR/rojo.zip"
  unzip -o "$FERR/rojo.zip" -d "$FERR" && rm "$FERR/rojo.zip" && chmod +x "$ROJO"
fi
"$ROJO" plugin install
echo
echo "PRONTO. No Studio: abra uma CÓPIA do place > Plugins > Rojo > Connect;"
echo "barra de comandos: require(game.ServerStorage.GuardioesTestes.Studio)()  ; depois Play (F5)."
echo "Sincronizando (deixe aberto; Ctrl+C para parar)..."
cd "$PROJETO" && "$ROJO" serve
