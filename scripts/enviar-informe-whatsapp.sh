#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# enviar-informe-whatsapp.sh <ruta-al-report.html>
#
# 1) Copia el HTML al repo de GitHub Pages con nombre fechado.
# 2) Genera un PDF del HTML con Chrome headless (si Chrome está disponible).
# 3) Regenera index.html apuntando al informe más reciente.
# 4) Publica (commit + push) en el repo de Pages.
# 5) Imprime los enlaces públicos (PUBLISHED_HTML / PUBLISHED_PDF).
#
# El ENVÍO por WhatsApp lo hace quien llama al script:
#   - El agente Claude / la routine: WebFetch a https://api.callmebot.com/whatsapp.php
#   - Automatización fuera de Claude: curl al mismo endpoint.
# (No se hace aquí para respetar el bloqueo de curl dentro de Claude Code.)
#
# Config por entorno (con defaults):
#   PAGES_DIR  (default ~/reportes-ia-medicina)
#   PAGES_URL  (default https://juanparisma.github.io/reportes-ia-medicina)
# ---------------------------------------------------------------------------
set -euo pipefail

HTML_IN="${1:?Uso: enviar-informe-whatsapp.sh <ruta-al-report.html>}"
[ -f "$HTML_IN" ] || { echo "ERROR: no existe el HTML: $HTML_IN"; exit 1; }

PAGES_DIR="${PAGES_DIR:-$HOME/reportes-ia-medicina}"
PAGES_URL="${PAGES_URL:-https://juanparisma.github.io/reportes-ia-medicina}"
STAMP="$(date +%Y-%m-%d)"
SLUG="$STAMP-ia-medicina"

[ -d "$PAGES_DIR/.git" ] || { echo "ERROR: no encuentro el repo de Pages en $PAGES_DIR"; exit 1; }

# 1) Copiar HTML fechado
cp -f "$HTML_IN" "$PAGES_DIR/$SLUG.html"

# 2) PDF con Chrome headless (best-effort)
CHROME=""
for c in \
  "/c/Program Files/Google/Chrome/Application/chrome.exe" \
  "/c/Program Files (x86)/Google/Chrome/Application/chrome.exe" \
  "${LOCALAPPDATA:-}/Google/Chrome/Application/chrome.exe" \
  "$(command -v google-chrome 2>/dev/null || true)" \
  "$(command -v chromium 2>/dev/null || true)"; do
  if [ -n "$c" ] && [ -x "$c" ]; then CHROME="$c"; break; fi
done

PDF_OK=0
if [ -n "$CHROME" ]; then
  if command -v cygpath >/dev/null 2>&1; then
    FILEURL="file:///$(cygpath -m "$HTML_IN")"
    OUTPDF="$(cygpath -m "$PAGES_DIR/$SLUG.pdf")"
  else
    FILEURL="file://$HTML_IN"; OUTPDF="$PAGES_DIR/$SLUG.pdf"
  fi
  if "$CHROME" --headless=new --disable-gpu --no-pdf-header-footer \
       --print-to-pdf="$OUTPDF" "$FILEURL" >/dev/null 2>&1; then
    PDF_OK=1
  fi
fi
[ "$PDF_OK" = 1 ] || echo "AVISO: no se generó PDF (Chrome no disponible o falló). Sigo solo con HTML."

# 3) index.html -> redirige al más reciente
cat > "$PAGES_DIR/index.html" <<HTML
<!DOCTYPE html><html lang="es"><head><meta charset="UTF-8">
<meta http-equiv="refresh" content="0; url=$SLUG.html">
<title>Informes — IA en medicina</title></head>
<body>Abriendo el informe más reciente… <a href="$SLUG.html">$SLUG.html</a></body></html>
HTML

# 4) Publicar
cd "$PAGES_DIR"
git add -A
if git commit -m "report: $SLUG" >/dev/null 2>&1; then
  git push origin main >/dev/null 2>&1 || { echo "ERROR: falló el push a Pages"; exit 1; }
else
  echo "Sin cambios que publicar (¿ya estaba el informe de hoy?)."
fi

# 5) Emitir enlaces
echo "PUBLISHED_HTML=$PAGES_URL/$SLUG.html"
[ "$PDF_OK" = 1 ] && echo "PUBLISHED_PDF=$PAGES_URL/$SLUG.pdf"
echo "OK"
