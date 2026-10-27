#!/bin/zsh
# Compila MouseScroll y publica ~/Applications/MouseScroll.app (ruta limpia para TCC).
# No usa sudo ni /Applications del sistema.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WORKDIR="${TMPDIR:-/tmp}/MouseScroll-compile-$$"
USER_APP_DIR="$HOME/Applications"
USER_APP="$USER_APP_DIR/MouseScroll.app"

cleanup() { rm -rf "$WORKDIR"; }
trap cleanup EXIT

sign_app() {
  local target="$1"
  dot_clean -m "$target" 2>/dev/null || true
  xattr -cr "$target" 2>/dev/null || true
  find "$target" -name '._*' -delete 2>/dev/null || true
  codesign --force --sign - --timestamp=none "$target/Contents/MacOS/MouseScroll"
  codesign --force --sign - --timestamp=none "$target"
}

echo "→ Preparando copia de compilación en $WORKDIR …"
mkdir -p "$WORKDIR"
rsync -a \
  --exclude '.build' \
  --exclude 'build' \
  --exclude '.git' \
  --exclude 'Logs' \
  "$ROOT/" "$WORKDIR/"

cd "$WORKDIR"
echo "→ Compilando (release)…"
swift build -c release --product MouseScroll

BIN="$WORKDIR/.build/release/MouseScroll"

assemble() {
  local dest="$1"
  rm -rf "$dest"
  mkdir -p "$dest/Contents/MacOS" "$dest/Contents/Resources"
  cp "$BIN" "$dest/Contents/MacOS/MouseScroll"
  cp "$ROOT/AppBundle/Info.plist" "$dest/Contents/Info.plist"
  cp "$ROOT/AppBundle/AppIcon.icns" "$dest/Contents/Resources/AppIcon.icns"
  cp "$ROOT/AppBundle/IconUI.png" "$dest/Contents/Resources/IconUI.png"
  sign_app "$dest"
}

mkdir -p "$ROOT/build/Logs"
mkdir -p "$USER_APP_DIR"

# Primero la copia limpia (la que se usa). Luego la del proyecto (puede fallar por ":").
assemble "$USER_APP"
assemble "$ROOT/build/MouseScroll.app" || echo "Aviso: no se pudo firmar la copia del proyecto (ruta con ':'). Usa ~/Applications."

echo "→ App a usar:   $USER_APP"
echo "→ App proyecto: $ROOT/build/MouseScroll.app"
echo ""
echo "Ejecutar: open \"$USER_APP\""
