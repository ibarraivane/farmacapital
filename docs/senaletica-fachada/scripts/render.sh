#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/render"
mkdir -p "$OUT"

render_png() {
  local html="$1" png="$2" w="$3" h="$4"
  local tmp
  tmp="$(mktemp -d)"
  echo "PNG $png"
  timeout 35 google-chrome \
    --headless=new \
    --disable-gpu \
    --no-sandbox \
    --disable-dev-shm-usage \
    --hide-scrollbars \
    --allow-file-access-from-files \
    --user-data-dir="$tmp" \
    --virtual-time-budget=8000 \
    --window-size="$w,$h" \
    --screenshot="$png" \
    "file://$html" || true
  rm -rf "$tmp"
}

render_pdf() {
  local html="$1" pdf="$2"
  local tmp
  tmp="$(mktemp -d)"
  echo "PDF $pdf"
  timeout 35 google-chrome \
    --headless=new \
    --disable-gpu \
    --no-sandbox \
    --disable-dev-shm-usage \
    --allow-file-access-from-files \
    --user-data-dir="$tmp" \
    --no-pdf-header-footer \
    --print-to-pdf="$pdf" \
    "file://$html" || true
  rm -rf "$tmp"
}

render_png "$ROOT/print/01-tarjetas-20x25.html" "$OUT/01-tarjetas-20x25.png" 1181 1476
render_pdf "$ROOT/print/01-tarjetas-20x25.html" "$OUT/01-tarjetas-20x25.pdf"
render_png "$ROOT/print/01b-tarjetas-tira-20x8.html" "$OUT/01b-tarjetas-tira-20x8.png" 1181 472
render_pdf "$ROOT/print/01b-tarjetas-tira-20x8.html" "$OUT/01b-tarjetas-tira-20x8.pdf"
render_png "$ROOT/print/02-mercadopago-28x35.html" "$OUT/02-mercadopago-28x35.png" 1654 2067
render_pdf "$ROOT/print/02-mercadopago-28x35.html" "$OUT/02-mercadopago-28x35.pdf"
render_png "$ROOT/print/03-rappi-circular-28.html" "$OUT/03-rappi-circular-28.png" 1654 2067
render_pdf "$ROOT/print/03-rappi-circular-28.html" "$OUT/03-rappi-circular-28.pdf"
render_png "$ROOT/print/04-pedidos-20x25.html" "$OUT/04-pedidos-20x25.png" 1181 1476
render_pdf "$ROOT/print/04-pedidos-20x25.html" "$OUT/04-pedidos-20x25.pdf"

echo "OK"
ls -la "$OUT"
