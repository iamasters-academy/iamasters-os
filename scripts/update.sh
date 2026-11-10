#!/usr/bin/env bash
# =====================================================================
#  iAmasters OS · update.sh (puente a IA Masters OS)
#
#  Desde noviembre de 2026 esta versión está retirada y no recibe cambios.
#  /actualiza ya no actualiza esta carpeta: la pasa a IA Masters OS, la
#  versión nueva de la comunidad, con scripts/pasar-a-ia-masters-os.sh.
#  Este script solo avisa: no toca nada.
#
#  Las líneas que ejecutan algo acaban en comentario para que funcionen
#  también si Windows trajo el fichero con saltos CRLF.
# =====================================================================
cd "$(dirname "$0")/.." || exit 1 #
tr -d '\r' < scripts/_aviso-version-nueva.txt #
exit 0 #
