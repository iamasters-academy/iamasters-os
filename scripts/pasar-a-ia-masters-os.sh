#!/usr/bin/env bash
# =====================================================================
#  iAmasters OS -> IA Masters OS · pasar-a-ia-masters-os.sh
#
#  Pasa ESTA carpeta (una instalación de la versión antigua, iAmasters OS
#  0.x con Sinapsis) a IA Masters OS, la versión nueva de la comunidad,
#  en la misma carpeta, sin reinstalar y sin borrar nada:
#
#   1. Comprueba el token y descarga la versión nueva ANTES de tocar nada.
#   2. Aparta la carpeta antigua ENTERA (con su .git) a
#      .backup/version-antigua-<fecha>/ y deja listo, en ese momento,
#      .backup/volver-a-la-version-antigua-<fecha>.sh para deshacerlo.
#   3. Instala la versión nueva limpia (lo mismo que el bloque de Skool).
#   4. Trae de vuelta lo de la persona: todo lo que no venía tal cual en el
#      repo público (misma ruta y mismo contenido). Las carpetas de datos
#      (marca, contexto, cada proyecto y cada cliente) se copian enteras;
#      node_modules y similares se mueven; los entornos de Python no se traen.
#   5. Vuelve a activar las skills de la caja que había instalado.
#
#  Uso, desde la carpeta antigua y con el token en .claude/acceso-token:
#      bash scripts/pasar-a-ia-masters-os.sh
#
#  La última línea lleva una etiqueta:
#   [MIGRADO] [YA_ES_NUEVA] [A_MEDIAS] [HAY_UNA_NUEVA_DENTRO] [EN_WORKTREE]
#   [NO_ES_VERSION_ANTIGUA] [SIN_GIT] [SIN_TOKEN] [TOKEN_NO_VALE]
#   [SIN_ESPACIO] [ERROR_RED] [ERROR_MOVER] [ERROR]
#  Justo antes va una línea «PARA CLAUDE:» con lo que hay que decirle a la persona.
#  Mientras trabaja existe .backup/pasando-a-ia-masters-os-<fecha>/EN_CURSO: si
#  se corta, la siguiente ejecución lo detecta ([A_MEDIAS]) y explica cómo volver.
#
#  Solo para pruebas: IAM_URL_NUEVA, IAM_URL_VIEJA e IAM_RAMA.
#
#  Todo lo de arriba son comentarios a propósito, y la línea de abajo acaba en
#  comentario: si Windows trajo este fichero con saltos CRLF, se copia sin \r a
#  una carpeta temporal y se relanza desde ahí (así, además, no se ejecuta desde
#  dentro de la carpeta que vamos a apartar).
# =====================================================================
if [ -z "${IAM_PUENTE_COPIA:-}" ]; then IAM_PUENTE_COPIA="$(mktemp "${TMPDIR:-/tmp}/iam-puente.XXXXXX")" && tr -d '\r' < "$0" > "$IAM_PUENTE_COPIA" && export IAM_PUENTE_COPIA && exec bash "$IAM_PUENTE_COPIA" "$@"; echo "PARA CLAUDE: no pude preparar el script. No se ha tocado nada."; echo "[ERROR] preparación"; exit 9; fi #

trap 'rm -f "$IAM_PUENTE_COPIA"' EXIT
set -u

URL_NUEVA="${IAM_URL_NUEVA:-https://github.com/iamasters-academy/ia-masters-os.git}"
URL_VIEJA="${IAM_URL_VIEJA:-https://github.com/iamasters-academy/iamasters-os.git}"
RAMA="${IAM_RAMA:-main}"
TOKEN_FILE=".claude/acceso-token"
NADA="No se ha tocado nada."
# Dependencias regenerables. Las de MOVER no se copian: se mueven con su proyecto
# (solo usan rutas relativas) y el script de vuelta las devuelve. Las de DEJAR no se
# traen: los entornos de Python llevan rutas absolutas y se romperían al moverlos.
MOVER="node_modules .next .turbo .parcel-cache"
DEJAR=".venv venv __pycache__ .pytest_cache .mypy_cache .memory-index"
PESADAS="$MOVER $DEJAR"
nombres() { local x="" p; for p in "$@"; do x="$x${x:+ -o} -name $p"; done; printf '%s' "$x"; }
NOMBRES_PESADAS=$(nombres $PESADAS)
NOMBRES_MOVER=$(nombres $MOVER)

fin() {
  # fin <etiqueta> <qué decirle a la persona> [código de salida]
  echo "PARA CLAUDE: $2"
  echo "$1"
  exit "${3:-0}"
}

entradas() {
  # Lo que hay en la raíz de la carpeta, menos .backup (que nunca se mueve).
  local e
  for e in * .[!.]* ..?*; do
    { [ -e "$e" ] || [ -L "$e" ]; } || continue
    [ "$e" = ".backup" ] && continue
    printf '%s\n' "$e"
  done
}

raiz="$(pwd)"

# ── 0 · Comprobaciones (no cambian nada) ─────────────────────────────

command -v git >/dev/null 2>&1 || fin "[SIN_GIT]" "no encuentro git. En Mac: acepta el aviso de «herramientas de línea de comandos», espera a que termine y vuelve a escribir /actualiza. En Windows: instala Git for Windows (https://git-scm.com/download/win), reinicia Claude y vuelve a escribir /actualiza. $NADA" 2

case "$raiz" in
  */.claude/worktrees/*)
    fin "[EN_WORKTREE]" "esta conversación está abierta en una copia de trabajo de la app (.claude/worktrees), no en su carpeta. Pídele que abra una conversación nueva directamente en su carpeta de iAmasters OS (sin worktree) y escriba /actualiza allí. $NADA" 2 ;;
esac
[ -f .git ] && fin "[EN_WORKTREE]" "esta carpeta es una copia de trabajo de git, no la carpeta principal. Pídele que abra una conversación nueva en su carpeta de iAmasters OS y escriba /actualiza allí. $NADA" 2

# ¿Un intento anterior se cortó a medias?
for m in .backup/pasando-a-ia-masters-os-*/EN_CURSO; do
  [ -f "$m" ] || continue
  s="${m#.backup/pasando-a-ia-masters-os-}"; s="${s%/EN_CURSO}"
  if [ -f ".backup/volver-a-la-version-antigua-$s.sh" ]; then
    fin "[A_MEDIAS]" "un intento anterior de pasar a IA Masters OS se cortó a medias, así que esta carpeta está a medio camino. No toques nada a mano. Ejecuta  bash .backup/volver-a-la-version-antigua-$s.sh  : la deja exactamente como estaba antes. Cuando diga [VUELTA_A_LA_ANTIGUA], repite el paso como la primera vez (/actualiza, o el bloque de rescate de Skool si lo usó), con el tiempo máximo (10 minutos)." 6
  fi
  # Se cortó mientras apartaba (paso 2): todo lo apartado vuelve a su sitio.
  mal=0
  for e in ".backup/version-antigua-$s"/* ".backup/version-antigua-$s"/.[!.]* ".backup/version-antigua-$s"/..?*; do
    { [ -e "$e" ] || [ -L "$e" ]; } || continue
    if [ -e "./${e##*/}" ] || ! mv -- "$e" . 2>/dev/null; then mal=1; fi
  done
  if [ "$mal" -eq 0 ]; then
    rmdir ".backup/version-antigua-$s" 2>/dev/null; rm -rf ".backup/pasando-a-ia-masters-os-$s"
    fin "[ERROR]" "un intento anterior se había cortado mientras apartaba la carpeta antigua. Ya lo he dejado todo como estaba: vuelve a ejecutar este mismo paso, con el tiempo máximo (10 minutos)." 7
  fi
  fin "[A_MEDIAS]" "un intento anterior se cortó mientras apartaba la carpeta antigua y no he podido devolverlo todo: lo que falta sigue en .backup/version-antigua-$s/. No toques nada: dile que lo comente en la comunidad." 6
done

if [ -f .claude/skills/actualiza/SKILL.md ] && [ -f mi-negocio/README.md ]; then
  fin "[YA_ES_NUEVA]" "esta carpeta ya tiene IA Masters OS, la versión nueva. Para traer lo último, /actualiza." 0
fi

if [ "$raiz" = "$HOME" ] || [ "$raiz" = "/" ] || ! grep -qs "iAmasters OS" CLAUDE.md \
   || { [ ! -d vendor/sinapsis ] && [ ! -f scripts/update.sh ]; }; then
  fin "[NO_ES_VERSION_ANTIGUA]" "esta carpeta no es una instalación de la versión antigua (iAmasters OS), así que no la toco. Pregúntale dónde la tenía (suele ser una carpeta «iamasters-os» dentro de su carpeta de usuario) y que abra Claude allí. Si nunca la tuvo, que instale IA Masters OS en una carpeta nueva y vacía con el bloque de la clase «Instala IA Masters OS» de Skool. $NADA" 2
fi

# ¿Ya instaló IA Masters OS en una carpeta DENTRO de esta? (lo apartaríamos con todo lo demás)
for d in */; do
  { [ -f "${d}mi-negocio/README.md" ] && [ -f "${d}.claude/skills/actualiza/SKILL.md" ]; } || continue
  fin "[HAY_UNA_NUEVA_DENTRO]" "ya tiene IA Masters OS instalado en «${d%/}», dentro de esta carpeta. No hace falta pasar nada: que abra Claude en «${d%/}» y siga allí. Lo suyo de la versión antigua (brand-context/, context/, projects/, clients/) sigue en esta carpeta: si quiere aprovecharlo, que se lo pida a Claude desde «${d%/}». Si prefiere pasar esta carpeta entera, primero tiene que sacar «${d%/}» de aquí (por ejemplo, al Escritorio). $NADA" 2
done

[ -s "$TOKEN_FILE" ] || fin "[SIN_TOKEN]" "falta el token. Pídele que copie el «Token del mes» de debajo de la clase «Instala IA Masters OS» en Skool. Cuando lo pegue, guárdalo con  printf '%s' 'EL_TOKEN' > .claude/acceso-token  (sin repetirlo en tus mensajes) y vuelve a ejecutar este script. $NADA" 3
token=$(tr -d ' \r\n\t' < "$TOKEN_FILE")
auth=$(printf 'x-access-token:%s' "$token" | base64 | tr -d '\r\n')
# Que git no lo suba nunca si la persona se queda en la versión antigua.
if [ -d .git ] && ! grep -qxF "$TOKEN_FILE" .git/info/exclude 2>/dev/null; then
  mkdir -p .git/info && printf '\n%s\n' "$TOKEN_FILE" >> .git/info/exclude
fi

sello=$(date +%Y-%m-%d-%H%M%S)
mkdir -p .backup 2>/dev/null || fin "[ERROR]" "no puedo crear la carpeta .backup aquí (¿permisos?). $NADA" 7
trabajo=".backup/pasando-a-ia-masters-os-$sello"
descarga="$trabajo/descarga.git"
err="$trabajo/error.txt"
mkdir -p "$trabajo" && git init -q --bare "$descarga" 2>/dev/null || { rm -rf "$trabajo"; fin "[ERROR]" "no puedo preparar la descarga en .backup/ (¿permisos o disco lleno?). $NADA" 7; }

# ── 1 · Descargar la versión nueva (con el token) y la historia pública ──

if ! GIT_TERMINAL_PROMPT=0 git -C "$descarga" -c credential.helper= \
     -c http.extraHeader="Authorization: Basic $auth" \
     fetch -q "$URL_NUEVA" "+refs/heads/$RAMA:refs/heads/$RAMA" 2>"$err"; then
  if grep -qiE '401|403|authentication|could not read|denied|repository .*not found' "$err"; then
    rm -rf "$trabajo"
    fin "[TOKEN_NO_VALE]" "el token no vale: mal copiado, caducado o de otro mes. Pídele que copie otra vez el «Token del mes» de debajo de la clase «Instala IA Masters OS», guárdalo igual y vuelve a ejecutar. Si vuelve a fallar, explícale esas causas y para. $NADA" 4
  fi
  sed -n '1,3p' "$err" >&2
  rm -rf "$trabajo"
  fin "[ERROR_RED]" "no consigo llegar a GitHub. Que revise su conexión y lo intentamos otra vez. $NADA" 5
fi

# La historia del repo público dice qué venía con la versión antigua (ruta y
# contenido): lo que no esté ahí tal cual es de la persona. Por eso el repo
# público NO se puede borrar ni hacer privado (archivarlo en GitHub sí vale).
# Plan B: la copia de esa historia que ya tiene el .git de la persona.
if ! GIT_TERMINAL_PROMPT=0 git -C "$descarga" fetch -q "$URL_VIEJA" "+refs/heads/main:refs/publico/main" 2>"$err" \
   && ! git -C "$descarga" fetch -q "$raiz/.git" "+refs/remotes/origin/main:refs/publico/main" 2>/dev/null; then
  sed -n '1,3p' "$err" >&2
  rm -rf "$trabajo"
  fin "[ERROR]" "no puedo descargar la versión antigua para saber qué ficheros son suyos, así que no toco nada. Dile que lo comente en la comunidad para que lo revisen. $NADA" 7
fi

g() { git -C "$descarga" -c core.quotePath=false "$@"; }
g rev-list refs/publico/main > "$trabajo/publico-commits.txt"
while IFS= read -r c; do g ls-tree -r --full-tree "$c"; done < "$trabajo/publico-commits.txt" \
  | awk -F'\t' '{ n = split($1, a, " "); print a[3] "\t" $2 }' | sort -u > "$trabajo/publico-pares.txt"
cut -f2 "$trabajo/publico-pares.txt" | sort -u > "$trabajo/publico-rutas.txt"
# Las skills se copiaban de un sitio a otro (de skills-library/<cat>/<n>/ a
# .claude/skills/<n>/), así que para ellas cuenta la ruta DENTRO de la skill:
# huella + «<n>/<ruta dentro>», esté donde esté la skill en el repo público.
grep '/SKILL\.md$' "$trabajo/publico-rutas.txt" | sed 's|/SKILL\.md$||' | sort -u > "$trabajo/publico-skilldirs.txt"
awk -F'\t' 'NR==FNR { sd[$0] = 1; next }
  { d = $2
    while ((i = match(d, /\/[^\/]*$/)) > 0) {
      d = substr(d, 1, i - 1)
      if (d in sd) { n = split(d, c, "/"); print $1 "\t" c[n] "/" substr($2, length(d) + 2) }
    } }' "$trabajo/publico-skilldirs.txt" "$trabajo/publico-pares.txt" | sort -u > "$trabajo/publico-pares-skill.txt"
g ls-tree -d --name-only "$RAMA:.claude/skills" > "$trabajo/nueva-base.txt" 2>/dev/null
g ls-tree -d --name-only "$RAMA:skills-disponibles" > "$trabajo/nueva-caja.txt" 2>/dev/null
version=$(g show "$RAMA:VERSION" 2>/dev/null | tr -d ' \r\n')

if [ ! -s "$trabajo/publico-pares.txt" ] || [ ! -s "$trabajo/nueva-base.txt" ]; then
  rm -rf "$trabajo"
  fin "[ERROR]" "la descarga llegó incompleta. Volvamos a intentarlo en un rato. $NADA" 7
fi

# ¿Cabe la copia? Se copian los datos de la persona (sin las dependencias).
datos=""
for d in brand-context context loops projects clients .claude/skills; do [ -d "$d" ] && datos="$datos $d"; done
necesita=0
if [ -n "$datos" ]; then
  total=$(du -sk $datos 2>/dev/null | awk '{ s += $1 } END { print s + 0 }')
  deps=$(find $datos -type d \( $NOMBRES_PESADAS \) -prune -exec du -sk {} + 2>/dev/null | awk '{ s += $1 } END { print s + 0 }')
  necesita=$(( total - deps ))
fi
libre_kb=$(df -Pk . 2>/dev/null | awk 'NR == 2 { print $4 }')
case "$libre_kb" in ''|*[!0-9]*) libre_kb="" ;; esac
if [ -n "$libre_kb" ] && [ "$libre_kb" -lt $(( necesita + 204800 )) ]; then
  rm -rf "$trabajo"
  fin "[SIN_ESPACIO]" "no hay espacio en el disco para hacer la copia: hacen falta unos $(( necesita / 1024 + 200 )) MB libres y hay $(( libre_kb / 1024 )) MB. Que libere espacio (papelera, descargas, vídeos que ya no use) y vuelva a escribir /actualiza. $NADA" 7
fi

# ── 2 · Apartar la carpeta antigua entera ────────────────────────────

antigua=".backup/version-antigua-$sello"
volver=".backup/volver-a-la-version-antigua-$sello.sh"
pesadas_movidas=".backup/volver-a-la-version-antigua-$sello.pesadas"
movidos="$trabajo/movidos.txt"
: > "$movidos"
mkdir -p "$antigua"
date > "$trabajo/EN_CURSO"

devolver() {
  # Deshace el paso 2. Devuelve 0 solo si todo volvió a su sitio.
  local e mal=0
  while IFS= read -r e; do
    [ -n "$e" ] || continue
    if ! mv -- "$antigua/$e" . 2>/dev/null; then
      echo "  ! no pude devolver «$e»: está en $antigua/" >&2
      mal=1
    fi
  done < "$movidos"
  [ "$mal" -eq 0 ] && rmdir "$antigua" 2>/dev/null
  return "$mal"
}

entradas > "$trabajo/raiz.txt"
while IFS= read -r e; do
  if mv -- "$e" "$antigua/$e" 2>"$err"; then
    printf '%s\n' "$e" >> "$movidos"
  else
    sed -n '1,2p' "$err" >&2
    if devolver; then
      rm -rf "$trabajo"
      fin "[ERROR_MOVER]" "no pude apartar «$e»: seguramente otro programa lo tiene abierto (un editor, una sincronización de la nube, un antivirus...). Lo he dejado todo como estaba. Que cierre los programas que usen esta carpeta y vuelva a escribir /actualiza. $NADA" 7
    fi
    fin "[A_MEDIAS]" "no pude apartar «$e» y, al deshacerlo, algo no volvió a su sitio (está en $antigua/, ver los avisos de arriba). No toques nada más: enséñale qué no volvió y dile que lo comente en la comunidad." 6
  fi
done < "$trabajo/raiz.txt"

# El script de vuelta existe desde ya: si algo se corta a partir de aquí, deshace.
cat > "$trabajo/volver.plantilla" <<'VOLVER'
#!/usr/bin/env bash
# Vuelve a dejar esta carpeta como estaba antes de pasar a IA Masters OS (__SELLO__).
# Lo de la versión nueva no se borra: se aparta a .backup/version-nueva-<fecha>/.
set -u
cd "$(dirname "$0")/.." || exit 1
sello="__SELLO__"
antigua=".backup/version-antigua-$sello"
pesadas=".backup/volver-a-la-version-antigua-$sello.pesadas"
marca=".backup/volver-a-la-version-antigua-$sello.en-curso"
[ -d "$antigua" ] || { echo "[NO_ENCUENTRO_LA_COPIA] $antigua"; exit 1; }
REPETIR="No lo arregles a mano: pídele que cierre los programas que usen esta carpeta (editores, sincronización de la nube, antivirus) y vuelve a ejecutar este mismo script, que sigue donde se quedó."
if [ -s "$marca" ]; then
  # Una ejecución anterior ya apartó lo nuevo: se sigue desde ahí.
  nueva=$(cat "$marca")
else
  # 1 · Lo de ahora se aparta entero.
  nueva=".backup/version-nueva-$(date +%Y-%m-%d-%H%M%S)"
  while [ -e "$nueva" ]; do nueva="$nueva-b"; done
  mkdir -p "$nueva"
  for e in * .[!.]* ..?*; do
    { [ -e "$e" ] || [ -L "$e" ]; } || continue
    [ "$e" = ".backup" ] && continue
    if ! mv -- "$e" "$nueva/$e"; then
      for v in "$nueva"/* "$nueva"/.[!.]* "$nueva"/..?*; do
        { [ -e "$v" ] || [ -L "$v" ]; } && mv -- "$v" .
      done
      rmdir "$nueva" 2>/dev/null
      echo "PARA CLAUDE: no pude apartar «$e» (¿lo tiene abierto otro programa?). Está todo como antes de ejecutarlo. $REPETIR"
      echo "[ERROR_MOVER]"; exit 7
    fi
  done
  printf '%s' "$nueva" > "$marca"
fi
# 2 · Las dependencias que se movieron (node_modules...) vuelven a su sitio en la copia.
if [ -f "$pesadas" ]; then
  while IFS="$(printf '\t')" read -r origen destino; do
    [ -n "$origen" ] && [ -e "$nueva/$destino" ] && [ ! -e "$antigua/$origen" ] && mv -- "$nueva/$destino" "$antigua/$origen"
  done < "$pesadas"
fi
# 3 · La carpeta antigua vuelve a su sitio (nunca encima de algo que ya esté).
for e in "$antigua"/* "$antigua"/.[!.]* "$antigua"/..?*; do
  { [ -e "$e" ] || [ -L "$e" ]; } || continue
  if [ -e "./${e##*/}" ] || [ -L "./${e##*/}" ] || ! mv -- "$e" .; then
    echo "PARA CLAUDE: no pude devolver «${e##*/}» a su sitio. La versión antigua está en $antigua y la nueva en $nueva. $REPETIR"
    echo "[ERROR]"; exit 7
  fi
done
rmdir "$antigua" 2>/dev/null
rm -rf ".backup/pasando-a-ia-masters-os-$sello"
rm -f "$marca"
mv -- "$pesadas" "$nueva/" 2>/dev/null
# Este script ya no sirve: se guarda con lo de la versión nueva.
mv -- "$0" "$nueva/" 2>/dev/null
echo "[VUELTA_A_LA_ANTIGUA] La carpeta está como antes del cambio. Lo de la versión nueva está en $nueva/. Abre una conversación nueva."
VOLVER
sed "s/__SELLO__/$sello/g" "$trabajo/volver.plantilla" > "$volver"

# ── 3 · Instalar la versión nueva limpia ─────────────────────────────

instalar() {
  git init -q &&
  git config core.autocrlf false &&
  git remote add origin "$URL_NUEVA" &&
  git fetch -q "$descarga" "+refs/heads/$RAMA:refs/remotes/origin/$RAMA" &&
  git checkout -q -B "$RAMA" "origin/$RAMA" &&
  git branch -q -u "origin/$RAMA" "$RAMA" &&
  # checkout puede acabar bien aunque no haya podido escribir algún fichero
  [ -z "$(git ls-files -d -m 2>/dev/null)" ]
}

if ! instalar 2>"$err"; then
  sed -n '1,3p' "$err" >&2
  r=$(bash "$volver" 2>&1 | tail -1)
  case "$r" in
    "[VUELTA_A_LA_ANTIGUA]"*)
      fin "[ERROR]" "no pude instalar la versión nueva y lo he dejado todo como estaba. Enséñale el error de arriba en una línea y no arregles nada a mano." 7 ;;
  esac
  fin "[A_MEDIAS]" "no pude instalar la versión nueva ni deshacerlo del todo ($r). No toques nada a mano: pídele que cierre los programas que usen esta carpeta y ejecuta  bash $volver  para dejarla como estaba." 6
fi
mkdir -p .claude
printf '%s' "$token" > "$TOKEN_FILE"

# ── 4 · Traer lo de la persona ───────────────────────────────────────

lista="$trabajo/ficheros.txt"
fallos="$trabajo/fallos.txt"; : > "$fallos"
hechos="$trabajo/hechos.txt"; : > "$hechos"
: > "$pesadas_movidas"

listar() {
  # listar <-type f|-type l>: lo que hay en la copia antigua, sin git, sin worktrees
  # de la app, sin dependencias y sin ficheros de sistema.
  ( cd "$antigua" && find . \( -path ./.git -o -path ./.claude/worktrees -o -path ./.codegraph \
      -o -path ./tests/output -o -path ./tests/.cache -o $NOMBRES_PESADAS \) -prune -o "$@" -print ) \
      2>>"$trabajo/find-errores.txt" \
    | sed 's|^\./||' \
    | grep -v -e '\.DS_Store$' -e 'Thumbs\.db$' -e 'desktop\.ini$' -e '\.pyc$' \
              -e '^\.claude/\.upstream-state$' -e '^\.claude/\.skills-pending\.json$'
}
: > "$trabajo/find-errores.txt"
listar -type f > "$lista"
listar -type l > "$trabajo/enlaces.txt"

# Solo hace falta mirar el contenido de lo que tiene una ruta que existió en el
# repo público, y de las skills: lo demás es de la persona seguro.
awk 'NR==FNR { r[$0]=1; next } ($0 in r) || index($0, ".claude/skills/") == 1' "$trabajo/publico-rutas.txt" "$lista" > "$trabajo/candidatos.txt"
huellas() {
  # huellas <salida> [opciones de hash-object]: huella git de cada candidato, tal
  # cual o con los saltos de línea normalizados (Windows).
  local salida="$1"; shift
  if ! ( cd "$antigua" && git -c core.autocrlf=true -c core.safecrlf=false hash-object "$@" --stdin-paths < "$raiz/$trabajo/candidatos.txt" ) > "$salida" 2>/dev/null \
     || [ "$(wc -l < "$salida")" -ne "$(wc -l < "$trabajo/candidatos.txt")" ]; then
    : > "$salida"
    while IFS= read -r f; do
      ( cd "$antigua" && git -c core.autocrlf=true -c core.safecrlf=false hash-object "$@" -- "$f" 2>/dev/null ) \
        || echo "0000000000000000000000000000000000000000"
    done < "$trabajo/candidatos.txt" > "$salida"
  fi
}
huellas "$trabajo/huellas-crudas.txt" --no-filters
huellas "$trabajo/huellas-normalizadas.txt"
paste "$trabajo/huellas-crudas.txt" "$trabajo/huellas-normalizadas.txt" "$trabajo/candidatos.txt" \
  | awk -F'\t' 'FILENAME == ARGV[1] { p[$0] = 1; next }
                FILENAME == ARGV[2] { q[$0] = 1; next }
                { k = $3
                  if ((($1 "\t" k) in p) || (($2 "\t" k) in p)) { print k; next }
                  if (index(k, ".claude/skills/") == 1) {
                    r = substr(k, 16)
                    if ((($1 "\t" r) in q) || (($2 "\t" r) in q)) { print k; next }
                    # instalada anidada: .claude/skills/<categoría>/<n>/...
                    r = substr(r, index(r, "/") + 1)
                    if ((($1 "\t" r) in q) || (($2 "\t" r) in q)) print k
                  } }' "$trabajo/publico-pares.txt" "$trabajo/publico-pares-skill.txt" - \
  > "$trabajo/pristinos.txt"
awk 'NR==FNR { x[$0]=1; next } !($0 in x)' "$trabajo/pristinos.txt" "$lista" > "$trabajo/tuyos.txt"
cat "$trabajo/enlaces.txt" >> "$trabajo/tuyos.txt"

con_prefijo() { awk -v p="$1/" 'index($0, p) == 1 { f = 1; exit } END { exit !f }' "$2"; }
esta() { grep -qxF -- "$1" "$2" 2>/dev/null; }
# sin distinguir mayúsculas: en Mac y Windows «Revisa» y «revisa» son la misma carpeta
esta_i() { grep -qixF -- "$1" "$2" 2>/dev/null; }

skill_dirs() {
  # Carpetas de skills de la copia antigua: .claude/skills/<n> y, en las instalaciones
  # anidadas (hasta la v0.10), .claude/skills/<categoría>/<n>.
  local s c
  for s in "$antigua"/.claude/skills/*/SKILL.md; do
    [ -f "$s" ] || continue
    case "$(basename "$(dirname "$s")")" in _*) continue ;; esac
    s="${s%/SKILL.md}"; printf '%s\n' "${s#"$antigua"/}"
  done
  for s in "$antigua"/.claude/skills/*/*/SKILL.md; do
    [ -f "$s" ] || continue
    c=$(dirname "$(dirname "$s")")
    [ -f "$c/SKILL.md" ] && continue   # subcarpeta de una skill, no una categoría
    case "$(basename "$c")" in _*) continue ;; esac
    s="${s%/SKILL.md}"; printf '%s\n' "${s#"$antigua"/}"
  done
}

libre() {
  # libre <destino> [sufijo]: si el destino ya existe, devuelve un nombre libre al
  # lado (x-antiguo.md, x-antiguo-2.md...).
  local d="$1" suf="${2:-antiguo}" base ext n=1 cand
  [ -e "$d" ] || [ -L "$d" ] || { printf '%s' "$d"; return; }
  case "$(basename "$d")" in
    ?*.*) base="${d%.*}"; ext=".${d##*.}" ;;
    *)    base="$d"; ext="" ;;
  esac
  cand="$base-$suf$ext"
  while [ -e "$cand" ] || [ -L "$cand" ]; do n=$((n+1)); cand="$base-$suf-$n$ext"; done
  printf '%s' "$cand"
}

traer() {
  # traer <ruta en la copia antigua> <destino>: un fichero suelto.
  local d="$2"
  { [ -e "$d" ] || [ -L "$d" ]; } && d=$(libre "$d")
  mkdir -p "$(dirname "$d")" && cp -p "$antigua/$1" "$d" 2>/dev/null || echo "$1" >> "$fallos"
}

copiar_carpeta() {
  # copiar_carpeta <carpeta en la copia antigua> <destino>: la copia entera, quita
  # lo que venía tal cual en el repo público y MUEVE las dependencias regenerables.
  local src="$1" dst="$2" ex="" p rel d
  for p in $PESADAS; do ex="$ex --exclude=$p"; done
  mkdir -p "$dst" || { echo "$src" >> "$fallos"; return 1; }
  ( cd "$antigua/$src" && tar cf - $ex . ) | ( cd "$dst" && tar xpf - )
  [ "${PIPESTATUS[0]}${PIPESTATUS[1]}" = "00" ] || echo "$src (incompleta)" >> "$fallos"
  awk -v p="$src/" 'index($0, p) == 1 { print substr($0, length(p) + 1) }' "$trabajo/pristinos.txt" \
    | while IFS= read -r rel; do
        rm -f -- "$dst/$rel"
        d=$(dirname "$dst/$rel")
        while [ "$d" != "$dst" ] && rmdir "$d" 2>/dev/null; do d=$(dirname "$d"); done
      done
  ( cd "$antigua/$src" && find . -type d \( $NOMBRES_MOVER \) -prune -print ) 2>/dev/null \
    | sed 's|^\./||' | while IFS= read -r rel; do
        [ -e "$dst/$rel" ] && continue
        # Se anota ANTES de mover: si se corta justo aquí, el script de vuelta la encuentra.
        printf '%s\t%s\n' "$src/$rel" "$dst/$rel" >> "$pesadas_movidas"
        mkdir -p "$(dirname "$dst/$rel")" && mv -- "$antigua/$src/$rel" "$dst/$rel" 2>/dev/null
      done
  ( cd "$antigua/$src" && find . -type d \( -name .venv -o -name venv \) -prune -print ) 2>/dev/null \
    | sed "s|^\\./|$dst/|" >> "$trabajo/entornos.txt"
  printf '%s\n' "$src" >> "$hechos"
}

# Proyectos y clientes: cada carpeta pasa entera a proyectos/<nombre>/ (los
# proyectos primero: si un cliente se llama igual, el cliente pasa a <nombre>-cliente).
asignados="$trabajo/proyectos-asignados.txt"; : > "$asignados"
mkdir -p proyectos/version-antigua   # nombre reservado para «lo demás»
carpeta_proyecto() {
  # carpeta_proyecto <projects|clients> <nombre> -> nombre de la carpeta en proyectos/
  local clave="$1/$2" ya d suf=antiguo
  [ "$1" = clients ] && suf=cliente
  ya=$(awk -F'\t' -v k="$clave" '$1 == k { print $2; exit }' "$asignados")
  if [ -n "$ya" ]; then printf '%s' "$ya"; return; fi
  d=$(libre "proyectos/$2" "$suf")
  d="${d#proyectos/}"
  printf '%s\t%s\n' "$clave" "$d" >> "$asignados"
  printf '%s' "$d"
}

# Lo primero, lo que más importa: claves y la información de su negocio.
for c in brand-context context; do
  con_prefijo "$c" "$trabajo/tuyos.txt" && copiar_carpeta "$c" "mi-negocio/version-antigua/$c"
done
n_negocio=$(awk 'index($0, "brand-context/") == 1 || index($0, "context/") == 1' "$trabajo/tuyos.txt" | wc -l | tr -d ' ')

# Skills propias: una carpeta .claude/skills/<n>/ sin nada que viniera tal cual en
# el repo público. Siguen activas, salvo si se llaman como una de la versión nueva.
propias="$trabajo/skills-propias.txt"; : > "$propias"
propias_apartadas="$trabajo/skills-propias-apartadas.txt"; : > "$propias_apartadas"
skill_dirs > "$trabajo/skill-dirs.txt"
while IFS= read -r rel; do
  n=$(basename "$rel")
  con_prefijo "$rel" "$trabajo/pristinos.txt" && continue
  if [ -L "$antigua/$rel" ]; then
    # Una skill enlazada (por ejemplo, una en desarrollo en otra carpeta): se vuelve a enlazar.
    if [ ! -e ".claude/skills/$n" ] && ! esta_i "$n" "$trabajo/nueva-base.txt" && ! esta_i "$n" "$trabajo/nueva-caja.txt" \
       && ln -s "$(readlink "$antigua/$rel")" ".claude/skills/$n" 2>/dev/null; then
      printf '%s\n' "$n" >> "$propias"
    else
      printf '%s\n' "$n" >> "$propias_apartadas"
    fi
    printf '%s\n' "$rel" >> "$hechos"
  elif [ -e ".claude/skills/$n" ] || esta_i "$n" "$trabajo/nueva-base.txt" || esta_i "$n" "$trabajo/nueva-caja.txt"; then
    copiar_carpeta "$rel" "$(libre "proyectos/version-antigua/skills/$n")"
    printf '%s\n' "$n" >> "$propias_apartadas"
  else
    copiar_carpeta "$rel" ".claude/skills/$n"
    printf '%s\n' "$n" >> "$propias"
  fi
done < "$trabajo/skill-dirs.txt"

for origen in projects clients; do
  for dir in "$antigua/$origen"/*/ "$antigua/$origen"/.[!.]*/; do
    [ -d "$dir" ] && [ ! -L "${dir%/}" ] || continue
    x=$(basename "$dir")
    con_prefijo "$origen/$x" "$trabajo/tuyos.txt" || continue
    # Las carpetas que venían en el repo (plantillas, ejemplos) van fichero a fichero, más abajo.
    con_prefijo "$origen/$x" "$trabajo/publico-rutas.txt" && continue
    copiar_carpeta "$origen/$x" "proyectos/$(carpeta_proyecto "$origen" "$x")"
  done
done

con_prefijo loops "$trabajo/tuyos.txt" && copiar_carpeta loops proyectos/version-antigua/loops

# Lo que queda, fichero a fichero (suele ser poco).
awk 'NR==FNR { e[$0] = 1; h[++n] = $0 "/"; next } ($0 in e) { next } { for (i = 1; i <= n; i++) if (index($0, h[i]) == 1) next; print }' \
  "$hechos" "$trabajo/tuyos.txt" > "$trabajo/resto.txt"
while IFS= read -r p; do
  [ -n "$p" ] || continue
  case "$p" in
    "$TOKEN_FILE") ;;
    .env|.env.*|.mcp.json)
      if [ "$p" = ".env.example" ]; then
        traer "$p" "proyectos/version-antigua/otros/$p"
      else
        traer "$p" "$p"
      fi ;;
    .claude/settings.local.json)
      if grep -q '"hooks"' "$antigua/$p" 2>/dev/null; then
        traer "$p" "proyectos/version-antigua/otros/$p"
      else
        traer "$p" "$p"
      fi ;;
    brand-context/*|context/*)
      traer "$p" "mi-negocio/version-antigua/$p" ;;
    projects/*/*|clients/*/*)
      origen="${p%%/*}"; resto="${p#*/}"; x="${resto%%/*}"; dentro="${resto#*/}"
      case "$x" in
        _*) traer "$p" "proyectos/version-antigua/otros/$p" ;;
        *)  traer "$p" "proyectos/$(carpeta_proyecto "$origen" "$x")/$dentro" ;;
      esac ;;
    loops/*)
      traer "$p" "proyectos/version-antigua/$p" ;;
    .claude/skills/*)
      traer "$p" "proyectos/version-antigua/skills/${p#.claude/skills/}" ;;
    .claude/commands/*.md)
      c=$(basename "$p" .md)
      case "$p" in .claude/commands/*/*) c="" ;; esac
      # propio = esa ruta nunca existió en el repo público
      if [ -n "$c" ] && ! esta ".claude/commands/$c.md" "$trabajo/publico-rutas.txt" \
         && ! esta "$c" "$trabajo/nueva-base.txt" && ! esta "$c" "$trabajo/nueva-caja.txt"; then
        traer "$p" "$p"; printf '%s\n' "$c" >> "$trabajo/comandos-propios.txt"
      else
        traer "$p" "proyectos/version-antigua/comandos/${p#.claude/commands/}"
      fi ;;
    .claude/agents/*)
      traer "$p" "$p"; printf '%s\n' "${p#.claude/agents/}" >> "$trabajo/agentes-propios.txt" ;;
    *)
      # Un CLAUDE.md o AGENTS.md antiguo no puede seguir llamándose así: Claude lo
      # cargaría al leer esa carpeta y volvería a dar las instrucciones antiguas.
      case "$(basename "$p")" in
        CLAUDE.md|CLAUDE.local.md|AGENTS.md) traer "$p" "proyectos/version-antigua/otros/$p.antiguo" ;;
        *) traer "$p" "proyectos/version-antigua/otros/$p" ;;
      esac ;;
  esac
done < "$trabajo/resto.txt"

# ── 5 · Volver a activar las skills de la caja que había instalado ───
# «Instalada por la persona» = estaba en .claude/skills/ sin venir de base en su
# versión (git no la seguía). Las que venían de base solo se sugieren.
reactivadas=""; sugeridas=""
while IFS= read -r rel; do
  n=$(basename "$rel")
  con_prefijo "$rel" "$trabajo/pristinos.txt" || continue
  m="$n"
  case "$n" in tool-web-legal-audit) m="web-legal-audit" ;; esac
  esta "$m" "$trabajo/nueva-caja.txt" || continue
  [ -e ".claude/skills/$m" ] && continue
  # Sin .git no se sabe si venía de base: mejor sugerir que activar de más.
  if [ ! -d "$antigua/.git" ] || git -C "$antigua" ls-files --error-unmatch "$rel/SKILL.md" >/dev/null 2>&1; then
    sugeridas="$sugeridas $m"
  else
    # Se lee la salida entera (no con grep -q): así el script termina de activar su pack.
    salida=$(bash scripts/activar.sh "$m" 2>/dev/null)
    for a in $(printf '%s\n' "$salida" | sed -n 's/^\[ACTIVADA\] //p'); do
      reactivadas="$reactivadas $a"
    done
  fi
done < "$trabajo/skill-dirs.txt"

# ── 6 · Notas para la persona (y para Claude) ────────────────────────

hoy=$(date +%Y-%m-%d)
mkdir -p mi-negocio/version-antigua
{
  echo "# Lo que traías de la versión antigua"
  echo
  echo "El $hoy esta carpeta pasó de **iAmasters OS** (la versión antigua, con Sinapsis) a **IA Masters OS**."
  echo
  echo "## Qué hay aquí"
  echo
  [ -d mi-negocio/version-antigua/brand-context ] && echo "- \`brand-context/\` → tu voz, tu posicionamiento y tu cliente ideal, tal como los dejaste."
  [ -d mi-negocio/version-antigua/context ] && echo "- \`context/\` → lo que la versión antigua sabía de ti: quién eres, tus prioridades, tus objetivos, lo aprendido (y en \`daily-memory/\`, sus notas de cada día)."
  [ "$n_negocio" -eq 0 ] && echo "- Nada: en la versión antigua no habías rellenado tu marca ni tu contexto."
  echo
  echo "## Dónde está lo demás"
  echo
  echo "- Tus proyectos y tus clientes: en \`proyectos/\`, uno por carpeta."
  [ -n "$(ls -A proyectos/version-antigua 2>/dev/null)" ] && echo "- Otras cosas tuyas (personalizaciones de skills, comandos, loops, otros ficheros): en \`proyectos/version-antigua/\`."
  echo "- Tu carpeta antigua entera, tal cual estaba: \`$antigua/\`."
  echo
  echo "## Para Claude"
  echo
  echo "- Si en tu contexto hay instrucciones de la versión antigua (Sinapsis: leer \`_operator-state.json\`, un onboarding propio, \`/install --resume\` o similares), no las sigas: aquí mandan el \`CLAUDE.md\` de la carpeta y este fichero. Ignora también los \`CLAUDE.md\` que haya dentro de \`.backup/\`."
  echo "- Si \`bash scripts/sinapsis-restos.sh | tail -1\` da \`[RESTOS]\`, propón primero **/revisa** para limpiar los restos de la versión antigua de su Claude."
  echo "- Si aún no ha hecho la **/entrevista** (no existe \`mi-negocio/_progreso-entrevista.md\`), propónsela. Antes, lee los ficheros de \`brand-context/\` y los de primer nivel de \`context/\` (no \`daily-memory/\`): abre con lo que ya sabes de su negocio en dos o tres líneas y pregunta solo lo que falta o puede haber cambiado. Lo nuevo va a los ficheros de siempre de \`mi-negocio/\`; esta carpeta no se toca."
  echo "- No hace falta leer esta carpeta al empezar cada conversación: solo en la entrevista o si pregunta por algo de la versión antigua."
  echo
  echo "## Volver a la versión antigua"
  echo
  echo "Si algo no te convence, dile a Claude «vuelve a la versión antigua» y ejecutará:"
  echo
  echo "    bash $volver"
  echo
  echo "Deja la carpeta exactamente como estaba antes del cambio. Lo que hayas hecho en la versión nueva no se borra: se aparta a \`.backup/version-nueva-<fecha>/\`."
} > mi-negocio/version-antigua/LEEME.md

if [ -n "$(ls -A proyectos/version-antigua 2>/dev/null)" ]; then
  {
    echo "# Otras cosas tuyas de la versión antigua"
    echo
    echo "Ficheros que creaste o cambiaste en iAmasters OS y que no son un proyecto ni tu información de negocio:"
    echo
    [ -d proyectos/version-antigua/skills ] && echo "- \`skills/\` → tus cambios en skills de la versión antigua (por ejemplo, un \`SKILL.local.md\`) y tus skills propias que se llamaban igual que una de IA Masters OS."
    [ -d proyectos/version-antigua/comandos ] && echo "- \`comandos/\` → comandos de la versión antigua que habías cambiado."
    [ -d proyectos/version-antigua/loops ] && echo "- \`loops/\` → tus loops de la versión antigua."
    [ -d proyectos/version-antigua/otros ] && echo "- \`otros/\` → todo lo demás, con la ruta que tenía en la carpeta antigua (los \`CLAUDE.md\` llevan \`.antiguo\` al final para que no se carguen solos)."
    echo
    echo "Nada de esto está activo en IA Masters OS. Si quieres recuperar algo (una skill, un loop, unas reglas), pídeselo a Claude y lo adaptáis con **/automatiza**."
  } > proyectos/version-antigua/LEEME.md
else
  rmdir proyectos/version-antigua 2>/dev/null
fi

# ── 7 · Resumen ──────────────────────────────────────────────────────

restos=$(bash scripts/sinapsis-restos.sh 2>/dev/null | tail -1)
lista_de() { [ -s "$1" ] && sort -u "$1" | tr '\n' ' ' | sed 's/ *$//'; }
proyectos_traidos=$(cut -f2 "$asignados" | sort -u | tr '\n' ' ' | sed 's/ *$//')
n_otros=0
[ -d proyectos/version-antigua ] && n_otros=$(find proyectos/version-antigua -type f ! -name LEEME.md | wc -l | tr -d ' ')
n_worktrees=$(ls -A "$antigua/.claude/worktrees" 2>/dev/null | wc -l | tr -d ' ')

echo "Hecho: esta carpeta ya es IA Masters OS v$version."
echo "Copia completa de la carpeta antigua: $antigua/"
echo "Para volver atrás: bash $volver"
[ "$n_negocio" -gt 0 ] && echo "Tu marca y tu contexto ($n_negocio ficheros): en mi-negocio/version-antigua/"
[ -n "$proyectos_traidos" ] && echo "Proyectos y clientes en proyectos/: $proyectos_traidos"
[ -s "$pesadas_movidas" ] && echo "Dependencias movidas con sus proyectos, sin copiar (node_modules, .venv...): $(wc -l < "$pesadas_movidas" | tr -d ' ')"
[ -s "$propias" ] && echo "Skills propias que siguen activas: $(lista_de "$propias")"
[ -s "$propias_apartadas" ] && echo "Skills propias que se llaman igual que una de IA Masters OS (guardadas en proyectos/version-antigua/skills/, sin activar): $(lista_de "$propias_apartadas")"
[ -s "$trabajo/comandos-propios.txt" ] && echo "Comandos propios que siguen funcionando: $(lista_de "$trabajo/comandos-propios.txt")"
[ -s "$trabajo/agentes-propios.txt" ] && echo "Agentes propios en .claude/agents/: $(lista_de "$trabajo/agentes-propios.txt")"
[ -n "$reactivadas" ] && echo "Skills de la caja que tenías instaladas, activadas otra vez:$reactivadas"
[ -n "$sugeridas" ] && echo "Skills que venían de base en la antigua y están en la caja nueva (si las usabas, /activa <nombre>):$sugeridas"
[ "$n_otros" -gt 0 ] && echo "Otras cosas tuyas ($n_otros ficheros): en proyectos/version-antigua/"
[ -s "$trabajo/entornos.txt" ] && echo "Entornos de Python que no se han traído (llevan rutas de la carpeta antigua; recréalos si los usas): $(lista_de "$trabajo/entornos.txt")"
# Solo lectura: ¿hay configuraciones fuera de esta carpeta que apunten a rutas que han cambiado?
fuera=""
for r in projects clients loops brand-context context scripts vendor skills-library .claude/skills .claude/commands; do
  for c in "$HOME/.claude.json" "$HOME/.claude/scheduled-tasks"; do
    [ -e "$c" ] && grep -rlF -- "$raiz/$r/" "$c" >/dev/null 2>&1 && fuera="$fuera ${c#"$HOME"/}"
  done
  crontab -l 2>/dev/null | grep -qF -- "$raiz/$r/" && fuera="$fuera crontab"
done
fuera=$(printf '%s\n' $fuera | sort -u | tr '\n' ' ' | sed 's/ *$//')
[ -n "$fuera" ] && echo "Configuraciones fuera de esta carpeta que apuntan a rutas antiguas (proyectos, loops, scripts...): $fuera. Revísalas con la persona: ahora sus proyectos están en proyectos/."
[ "$n_worktrees" -gt 0 ] && echo "Copias de trabajo de la app (.claude/worktrees): $n_worktrees. No se han traído; lo que tuvieran sigue en la copia antigua."
[ -s "$trabajo/find-errores.txt" ] && echo "Carpetas que no pude leer (siguen en la copia antigua): $(sed -n '1,3p' "$trabajo/find-errores.txt" | tr '\n' ' ')"
[ -s "$fallos" ] && echo "No pude traer (siguen en la copia antigua): $(lista_de "$fallos")"
echo "Restos de la versión antigua en su Claude: ${restos:-sin comprobar}"

# El token ya está en la carpeta nueva: no se queda copiado en la antigua.
rm -f "$antigua/$TOKEN_FILE"
rm -rf "$trabajo"

if [ "$restos" = "[RESTOS]" ]; then
  siguiente="En la conversación nueva, que escriba /revisa para limpiar los restos de la versión antigua de su Claude; después, la /entrevista aprovechando lo que ya tenía."
else
  siguiente="En la conversación nueva le propondrás la /entrevista aprovechando lo que ya tenía."
fi
fin "[MIGRADO] v$version" "resúmele en 4-6 viñetas cortas qué se ha traído y dónde (usa las líneas de arriba, sin rutas largas salvo la de volver atrás) y dile que su carpeta antigua está entera en .backup/ por si quiere volver. Luego: «Cierra esta conversación y abre una nueva en esta misma carpeta para estrenar IA Masters OS». $siguiente No sigas trabajando en esta conversación: tiene cargadas las instrucciones de la versión antigua." 0
