#!/bin/bash
# ============================================================
#  iAmasters OS — Installer v0.6 (state-machine, reentrant)
#  Sistema operativo agéntico para operadores de IA
#  https://github.com/iamasters-academy/iamasters-os
# ============================================================
#
# Cambios vs v0.5:
#   • State machine persistente en ~/.claude/skills/_install-state.json
#   • Validación profunda de Sinapsis (no solo "el archivo existe")
#   • Detección Python multi-plataforma (python3 / py -3 / python)
#   • Modo --resume: continúa desde la última fase exitosa
#   • Modo --force-reinstall: backup del state y arranque limpio
#   • Si una fase falla, queda `failed` en el state (no aborto silencioso)
#
# Flags:
#   --resume            Continúa desde la última fase no completada
#   --force-reinstall   Backup del state actual y arranque desde cero
#   --skip-sinapsis     (debug) Salta la instalación de Sinapsis
#
# Salida estructurada (parseable):
#   [OK]    <fase>            — completada
#   [SKIP]  <fase> · <motivo> — ya estaba o no aplica
#   [WARN]  <fase> · <motivo> — sigue con limitación
#   [ERROR] <fase> · <motivo> — bloqueante, queda en state como failed
#
# Idempotente y reentrante.
# ============================================================

set -e

# ── Output helpers ──
ok()    { echo "[OK]    $*"; }
skip()  { echo "[SKIP]  $*"; }
warn()  { echo "[WARN]  $*"; }
err()   { echo "[ERROR] $*" >&2; }
info()  { echo ">>      $*"; }
title() { echo ""; echo "── $* ──"; }

# ── Paths ──
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SINAPSIS_VENDOR="$REPO_ROOT/vendor/sinapsis"
CLAUDE_HOME="$HOME/.claude"
SKILLS_DIR="$CLAUDE_HOME/skills"
STATE_FILE="$SKILLS_DIR/_install-state.json"
STATE_TEMPLATE="$SCRIPT_DIR/_install-state.template.json"

# ── Windows / Git Bash (MSYS) path compatibility ──
# Bash MSYS define $HOME=/c/Users/<user>. Al interpolar esa ruta POSIX dentro
# de un string JS/Python (node -e / python -c), el runtime la interpreta como
# C:\c\Users\... (inexistente). cygpath -m la traduce a C:/Users/... (mixed),
# que tanto Node como Python entienden en argumentos y dentro de strings.
if [[ -n "$MSYSTEM" ]] && command -v cygpath >/dev/null 2>&1; then
    _win_path() { cygpath -m "$1"; }
    WIN_STATE_FILE="$(cygpath -m "$STATE_FILE")"
else
    _win_path() { echo "$1"; }
    WIN_STATE_FILE="$STATE_FILE"
fi

# ── Flags ──
RESUME=false
FORCE_REINSTALL=false
SKIP_SINAPSIS=false
for arg in "$@"; do
    case "$arg" in
        --resume)          RESUME=true ;;
        --force-reinstall) FORCE_REINSTALL=true ;;
        --skip-sinapsis)   SKIP_SINAPSIS=true ;;
        *) ;;
    esac
done

echo ""
echo "============================================================"
echo "  iAmasters OS — Installer v0.6.0"
echo "  Repo: $REPO_ROOT"
echo "============================================================"
echo ""

# ── JSON helpers (usamos node, que Sinapsis ya requiere) ──
# Si node no está, los reemplazos usan python3 (que casi todo el mundo tiene).

JSON_RUNTIME=""
detect_json_runtime() {
    # En MSYS/Git Bash (Windows), node malinterpreta rutas POSIX — preferimos Python.
    if [[ -n "$MSYSTEM" ]]; then
        if command -v python3 >/dev/null 2>&1; then
            JSON_RUNTIME="python3"
        elif command -v python >/dev/null 2>&1 && python --version 2>&1 | grep -q "Python 3"; then
            JSON_RUNTIME="python"
        elif command -v node >/dev/null 2>&1; then
            JSON_RUNTIME="node"
        else
            return 1
        fi
    elif command -v node >/dev/null 2>&1; then
        JSON_RUNTIME="node"
    elif command -v python3 >/dev/null 2>&1; then
        JSON_RUNTIME="python3"
    elif command -v python >/dev/null 2>&1 && python --version 2>&1 | grep -q "Python 3"; then
        JSON_RUNTIME="python"
    else
        return 1
    fi
}

json_validate() {
    # $1 = path to JSON file
    local _p; _p="$(_win_path "$1")"
    case "$JSON_RUNTIME" in
        node)
            node -e "JSON.parse(require('fs').readFileSync('$_p','utf8'))" 2>/dev/null
            ;;
        python3|python)
            "$JSON_RUNTIME" -c "import json; json.load(open('$_p'))" 2>/dev/null
            ;;
    esac
}

json_set_phase() {
    # $1 = phase name, $2 = field (status|validatedAt|...), $3 = value (must be valid JSON literal)
    local phase="$1"
    local field="$2"
    local value="$3"

    case "$JSON_RUNTIME" in
        node)
            node -e "
                const fs = require('fs');
                const f = '$WIN_STATE_FILE';
                const s = JSON.parse(fs.readFileSync(f, 'utf8'));
                if (!s.phases['$phase']) s.phases['$phase'] = {};
                s.phases['$phase']['$field'] = $value;
                s.lastUpdatedAt = new Date().toISOString();
                fs.writeFileSync(f, JSON.stringify(s, null, 2));
            "
            ;;
        python3|python)
            IAMASTERS_VAL="$value" "$JSON_RUNTIME" -c "
import json, os, datetime
f = '$WIN_STATE_FILE'
s = json.load(open(f))
s['phases'].setdefault('$phase', {})
s['phases']['$phase']['$field'] = json.loads(os.environ['IAMASTERS_VAL'])
s['lastUpdatedAt'] = datetime.datetime.now(datetime.timezone.utc).isoformat()
json.dump(s, open(f, 'w'), indent=2)
"
            ;;
    esac
}

json_set_root() {
    # $1 = field, $2 = JSON value
    case "$JSON_RUNTIME" in
        node)
            node -e "
                const fs = require('fs');
                const f = '$WIN_STATE_FILE';
                const s = JSON.parse(fs.readFileSync(f, 'utf8'));
                s['$1'] = $2;
                s.lastUpdatedAt = new Date().toISOString();
                fs.writeFileSync(f, JSON.stringify(s, null, 2));
            "
            ;;
        python3|python)
            IAMASTERS_VAL="$2" "$JSON_RUNTIME" -c "
import json, os, datetime
f = '$WIN_STATE_FILE'
s = json.load(open(f))
s['$1'] = json.loads(os.environ['IAMASTERS_VAL'])
s['lastUpdatedAt'] = datetime.datetime.now(datetime.timezone.utc).isoformat()
json.dump(s, open(f, 'w'), indent=2)
"
            ;;
    esac
}

json_get_phase_status() {
    # $1 = phase name; echoes "pending" / "in-progress" / "done" / "failed" / "skipped"
    case "$JSON_RUNTIME" in
        node)
            node -e "
                const s = JSON.parse(require('fs').readFileSync('$WIN_STATE_FILE','utf8'));
                console.log(s.phases['$1'] && s.phases['$1'].status || 'pending');
            "
            ;;
        python3|python)
            "$JSON_RUNTIME" -c "
import json
s = json.load(open('$WIN_STATE_FILE'))
print(s['phases'].get('$1', {}).get('status', 'pending'))
"
            ;;
    esac
}

json_push_error() {
    # $1 = phase, $2 = message
    case "$JSON_RUNTIME" in
        node)
            node -e "
                const fs = require('fs');
                const f = '$WIN_STATE_FILE';
                const s = JSON.parse(fs.readFileSync(f, 'utf8'));
                s.errors.push({ phase: '$1', message: \`$2\`, at: new Date().toISOString() });
                s.lastUpdatedAt = new Date().toISOString();
                fs.writeFileSync(f, JSON.stringify(s, null, 2));
            "
            ;;
        python3|python)
            "$JSON_RUNTIME" -c "
import json, datetime
f = '$WIN_STATE_FILE'
s = json.load(open(f))
s['errors'].append({'phase': '$1', 'message': '''$2''', 'at': datetime.datetime.now(datetime.timezone.utc).isoformat()})
s['lastUpdatedAt'] = datetime.datetime.now(datetime.timezone.utc).isoformat()
json.dump(s, open(f, 'w'), indent=2)
"
            ;;
    esac
}

clear_phase_errors() {
    # $1 = phase — elimina del array global s.errors las entradas de esa fase.
    # Sin esto, un error de un intento previo persiste para siempre y sigue
    # apareciendo en /install-status aunque el reintento acabe en 'done'.
    case "$JSON_RUNTIME" in
        node)
            node -e "
                const fs = require('fs');
                const f = '$WIN_STATE_FILE';
                const s = JSON.parse(fs.readFileSync(f, 'utf8'));
                s.errors = (s.errors || []).filter(e => e.phase !== '$1');
                s.lastUpdatedAt = new Date().toISOString();
                fs.writeFileSync(f, JSON.stringify(s, null, 2));
            "
            ;;
        python3|python)
            "$JSON_RUNTIME" -c "
import json, datetime
f = '$WIN_STATE_FILE'
s = json.load(open(f))
s['errors'] = [e for e in s.get('errors', []) if e.get('phase') != '$1']
s['lastUpdatedAt'] = datetime.datetime.now(datetime.timezone.utc).isoformat()
json.dump(s, open(f, 'w'), indent=2)
"
            ;;
    esac
}

mark_phase_done() {
    # $1 = phase name
    json_set_phase "$1" "status" '"done"'
    json_set_phase "$1" "validatedAt" "\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\""
    # Purga los errores de esta fase: si un intento previo falló y ahora pasa,
    # el error viejo NO debe seguir mostrándose (era un fantasma que asustaba).
    clear_phase_errors "$1"

    # Append to completedPhases array
    case "$JSON_RUNTIME" in
        node)
            node -e "
                const fs = require('fs');
                const f = '$WIN_STATE_FILE';
                const s = JSON.parse(fs.readFileSync(f, 'utf8'));
                if (!s.completedPhases.includes('$1')) s.completedPhases.push('$1');
                fs.writeFileSync(f, JSON.stringify(s, null, 2));
            "
            ;;
        python3|python)
            "$JSON_RUNTIME" -c "
import json
f = '$WIN_STATE_FILE'
s = json.load(open(f))
if '$1' not in s['completedPhases']:
    s['completedPhases'].append('$1')
json.dump(s, open(f, 'w'), indent=2)
"
            ;;
    esac
}

mark_phase_failed() {
    # $1 = phase, $2 = reason
    json_set_phase "$1" "status" '"failed"'
    json_push_error "$1" "$2"
    err "$1 · $2"
    err "Estado registrado en $STATE_FILE — ejecuta 'bash scripts/install.sh --resume' tras arreglar"
    exit 1
}

# ── State machine init ──
init_state() {
    mkdir -p "$SKILLS_DIR"

    if $FORCE_REINSTALL && [ -f "$STATE_FILE" ]; then
        local backup="$STATE_FILE.$(date -u +%Y%m%dT%H%M%SZ).bak"
        cp "$STATE_FILE" "$backup"
        warn "State anterior respaldado en $backup"
        rm -f "$STATE_FILE"
    fi

    if [ ! -f "$STATE_FILE" ]; then
        if [ ! -f "$STATE_TEMPLATE" ]; then
            err "Template $STATE_TEMPLATE no encontrado · repo corrupto, vuelve a clonar"
            exit 1
        fi
        cp "$STATE_TEMPLATE" "$STATE_FILE"
        json_set_root "repoPath" "\"$REPO_ROOT\""
        json_set_root "startedAt" "\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\""
        ok "State machine inicializado: $STATE_FILE"
    else
        # Validar que sea JSON parseable
        if ! json_validate "$STATE_FILE"; then
            err "State file corrupto · ejecuta con --force-reinstall para reiniciar"
            exit 1
        fi
        if $RESUME; then
            ok "State machine cargado (modo --resume)"
        else
            skip "State machine ya existe (idempotente — usa --resume para continuar o --force-reinstall para reiniciar)"
        fi
    fi
}

# ── Phase 1: prereqs ──
phase_prereqs() {
    local current_status
    current_status=$(json_get_phase_status "prereqs")
    if [ "$current_status" = "done" ] && ! $FORCE_REINSTALL; then
        skip "prereqs · ya validados (status=done)"
        return 0
    fi

    title "[1/2] Validando prerequisitos"
    json_set_phase "prereqs" "status" '"in-progress"'

    local checks="{}"
    local has_blocker=false

    # OS detection
    local os_type="unknown"
    case "$(uname -s)" in
        Darwin*)  os_type="macos" ;;
        Linux*)   os_type="linux" ;;
        MINGW*|MSYS*|CYGWIN*) os_type="windows-bash" ;;
    esac
    ok "OS: $os_type ($(uname -m))"
    if [ "$os_type" = "windows-bash" ]; then
        warn "Windows + Git Bash detectado — WSL recomendado para mejor experiencia"
    fi

    # Git (required)
    if ! command -v git >/dev/null 2>&1; then
        mark_phase_failed "prereqs" "Git no encontrado · instalalo en https://git-scm.com"
    fi
    local git_ver
    git_ver=$(git --version | awk '{print $3}')
    ok "git: $git_ver"

    # Node.js (required for Sinapsis hooks + JSON helpers)
    if ! command -v node >/dev/null 2>&1; then
        mark_phase_failed "prereqs" "Node.js no encontrado · es obligatorio (Sinapsis hooks lo requieren). Instala desde https://nodejs.org (≥18)"
    fi
    local node_ver
    node_ver=$(node --version | sed 's/v//')
    local node_major
    node_major=$(echo "$node_ver" | cut -d. -f1)
    if [ "$node_major" -lt 18 ]; then
        mark_phase_failed "prereqs" "Node.js v$node_ver es viejo · se requiere ≥18"
    fi
    ok "node: v$node_ver"

    # Python 3 (optional but recommended) — detección multi-plataforma
    local python_cmd=""
    for candidate in python3 python python3.12 python3.11 python3.10; do
        if command -v "$candidate" >/dev/null 2>&1; then
            if "$candidate" --version 2>&1 | grep -qE "Python 3\.(9|[1-9][0-9])"; then
                python_cmd="$candidate"
                break
            fi
        fi
    done
    if [ -z "$python_cmd" ] && [ "$os_type" = "windows-bash" ] && command -v py >/dev/null 2>&1; then
        if py -3 --version 2>&1 | grep -qE "Python 3\.(9|[1-9][0-9])"; then
            python_cmd="py -3"
        fi
    fi
    # Casos especiales Windows (rutas absolutas comunes)
    if [ -z "$python_cmd" ] && [ "$os_type" = "windows-bash" ]; then
        for win_path in "/c/Python311/python.exe" "/c/Python312/python.exe" "/c/Python310/python.exe"; do
            if [ -x "$win_path" ]; then
                python_cmd="$win_path"
                break
            fi
        done
    fi
    if [ -z "$python_cmd" ]; then
        warn "Python 3 no encontrado · los hooks de observación de Sinapsis estarán deshabilitados"
        warn "  Para habilitarlos: instala Python ≥3.9 desde https://python.org (NO Microsoft Store)"
    else
        local py_ver
        py_ver=$($python_cmd --version 2>&1 | awk '{print $2}')
        ok "python: $python_cmd ($py_ver)"
    fi

    # Claude Code detection (no bloquea, solo informa)
    if command -v claude >/dev/null 2>&1; then
        ok "Claude CLI en PATH"
    elif [ -d "/Applications/Claude.app" ] || [ -d "$HOME/Applications/Claude.app" ]; then
        ok "Claude Desktop (macOS app)"
    elif [ -n "$CLAUDE_DESKTOP" ] || [ -n "$CLAUDECODE" ]; then
        ok "Variables Claude Code detectadas"
    else
        warn "Claude Code/Desktop no detectado en PATH · si lo tienes instalado, ignora"
    fi

    # Persistir checks en el state
    local checks_json
    checks_json=$(cat <<EOF
{
  "os": "$os_type",
  "git": "$git_ver",
  "node": "v$node_ver",
  "python": "${python_cmd:-not-found}"
}
EOF
)
    json_set_phase "prereqs" "checks" "$checks_json"
    mark_phase_done "prereqs"
}

# ── Phase 2: sinapsis-engine ──
validate_sinapsis_deep() {
    # Validación PROFUNDA: no solo "existe el archivo", sino que sea funcional.
    # Devuelve 0 si todo OK, 1 si falta algo. Imprime detalle.
    local issues=0

    [ -f "$SKILLS_DIR/_operator-state.json" ] || { warn "  validación: falta _operator-state.json"; issues=$((issues+1)); }
    [ -f "$SKILLS_DIR/_catalog.json" ] || { warn "  validación: falta _catalog.json"; issues=$((issues+1)); }

    if [ -f "$SKILLS_DIR/_operator-state.json" ]; then
        if ! json_validate "$SKILLS_DIR/_operator-state.json"; then
            warn "  validación: _operator-state.json no es JSON parseable"
            issues=$((issues+1))
        fi
    fi
    if [ -f "$SKILLS_DIR/_catalog.json" ]; then
        if ! json_validate "$SKILLS_DIR/_catalog.json"; then
            warn "  validación: _catalog.json no es JSON parseable"
            issues=$((issues+1))
        fi
    fi

    # Hooks ejecutables — los 7 que Sinapsis instala (antes solo se validaban 3,
    # así que una instalación con hooks a medias pasaba como buena).
    for hook in _passive-activator.sh _instinct-activator.sh _session-learner.sh \
                _project-context.sh _eod-gather.sh _dream.sh _precompact-guard.sh; do
        if [ ! -f "$SKILLS_DIR/$hook" ]; then
            warn "  validación: falta hook $hook"
            issues=$((issues+1))
        elif [ ! -x "$SKILLS_DIR/$hook" ]; then
            warn "  validación: hook $hook no es ejecutable"
            issues=$((issues+1))
        fi
    done

    # ≥1 skill real instalada (SKILL.md, no archivos vacíos)
    local skill_count
    skill_count=$(find -L "$SKILLS_DIR" -maxdepth 3 -name "SKILL.md" 2>/dev/null | wc -l | tr -d ' ')
    if [ "$skill_count" -lt 1 ]; then
        warn "  validación: no se encontró ninguna SKILL.md en $SKILLS_DIR"
        issues=$((issues+1))
    fi

    # settings.json debe existir Y tener los hooks de Sinapsis REALMENTE cableados.
    # No basta con que aparezca la palabra "hooks": eso daba falso OK cuando el
    # usuario ya tenía settings.json con hooks de otra cosa y los de Sinapsis
    # nunca se registraron → motor de aprendizaje muerto en silencio.
    if [ ! -f "$CLAUDE_HOME/settings.json" ]; then
        warn "  validación: ~/.claude/settings.json no existe"
        issues=$((issues+1))
    elif ! json_validate "$CLAUDE_HOME/settings.json"; then
        warn "  validación: ~/.claude/settings.json no es JSON parseable"
        issues=$((issues+1))
    else
        local missing_wired=0 h
        for h in _passive-activator.sh _instinct-activator.sh _session-learner.sh; do
            grep -q "$h" "$CLAUDE_HOME/settings.json" || missing_wired=$((missing_wired+1))
        done
        if [ "$missing_wired" -gt 0 ]; then
            warn "  validación: settings.json no cablea los hooks de Sinapsis ($missing_wired/3 activadores ausentes) · ejecuta el instalador para arreglarlo"
            issues=$((issues+1))
        fi
    fi

    return $issues
}

record_sinapsis_validation() {
    # Escribe los resultados REALES de cada check en el state, para que
    # /install-status y el gate muestren la verdad (no los defaults del
    # template, que son false y confunden al usuario).
    local op_valid=false cat_valid=false hooks_ok=true
    if [ -f "$SKILLS_DIR/_operator-state.json" ] && json_validate "$SKILLS_DIR/_operator-state.json"; then
        op_valid=true
    fi
    if [ -f "$SKILLS_DIR/_catalog.json" ] && json_validate "$SKILLS_DIR/_catalog.json"; then
        cat_valid=true
    fi
    local hook
    for hook in _passive-activator.sh _instinct-activator.sh _session-learner.sh; do
        [ -x "$SKILLS_DIR/$hook" ] || hooks_ok=false
    done
    local skill_count
    skill_count=$(find -L "$SKILLS_DIR" -maxdepth 3 -name "SKILL.md" 2>/dev/null | wc -l | tr -d ' ')
    json_set_phase "sinapsis-engine" "validation" \
        "{\"operator_state_json_valid\": $op_valid, \"catalog_json_valid\": $cat_valid, \"hooks_executable\": $hooks_ok, \"skills_count\": ${skill_count:-0}}"
}

ensure_sinapsis_hooks() {
    # FIX capa OS: el instalador vendored de Sinapsis NO registra sus hooks si
    # ~/.claude/settings.json YA existe (solo imprime "merge manually"). Como casi
    # todos los usuarios ya tienen settings.json, sus hooks nunca se cableaban y el
    # motor de aprendizaje quedaba inerte (y en el peor caso la validación abortaba
    # toda la instalación). Aquí hacemos un DEEP-MERGE IDEMPOTENTE de los hooks de
    # la plantilla de Sinapsis dentro del settings.json del usuario, preservando
    # cualquier hook/permiso/config previo. Re-ejecutar = no-op.
    # Delega en el script compartido (mismo merge que usa update.sh, DRY).
    local template="$SINAPSIS_VENDOR/core/settings.template.json"
    if [ ! -f "$template" ]; then
        warn "  no encontrado $template · no se pueden cablear los hooks de Sinapsis"
        return 1
    fi
    bash "$SCRIPT_DIR/_ensure-sinapsis-hooks.sh" "$template" "$CLAUDE_HOME/settings.json"
}

phase_sinapsis_engine() {
    local current_status
    current_status=$(json_get_phase_status "sinapsis-engine")
    if [ "$current_status" = "done" ] && ! $FORCE_REINSTALL; then
        # Aún así re-validamos para detectar drift (alguien borró archivos manualmente)
        if validate_sinapsis_deep >/dev/null 2>&1; then
            record_sinapsis_validation
            clear_phase_errors "sinapsis-engine"  # purga fantasmas de intentos viejos ya resueltos
            skip "sinapsis-engine · ya instalado y validado (status=done)"
            return 0
        else
            warn "sinapsis-engine · marcado done pero validación profunda falla · re-instalando"
            json_set_phase "sinapsis-engine" "status" '"in-progress"'
        fi
    fi

    title "[2/2] Instalando Sinapsis engine"
    json_set_phase "sinapsis-engine" "status" '"in-progress"'

    if $SKIP_SINAPSIS; then
        warn "sinapsis-engine · saltado por --skip-sinapsis (solo debug)"
        return 0
    fi

    if [ ! -d "$SINAPSIS_VENDOR" ]; then
        mark_phase_failed "sinapsis-engine" "vendor/sinapsis/ no encontrado · repo incompleto, vuelve a clonar"
    fi
    if [ ! -f "$SINAPSIS_VENDOR/install.sh" ]; then
        mark_phase_failed "sinapsis-engine" "vendor/sinapsis/install.sh no encontrado · vuelve a clonar el repo"
    fi

    # Comprobar si ya está instalado de verdad (validación profunda, no solo existencia)
    info "Comprobando si Sinapsis ya está operativo..."
    if validate_sinapsis_deep >/dev/null 2>&1; then
        ok "Sinapsis ya está operativo (validación profunda pasa)"
        record_sinapsis_validation
        compute_and_store_checksum
        mark_phase_done "sinapsis-engine"
        return 0
    fi

    # No está, o está incompleto. Ejecutar el installer vendored.
    info "Ejecutando vendor/sinapsis/install.sh..."
    local prev_dir="$PWD"
    cd "$SINAPSIS_VENDOR"
    if ! bash install.sh; then
        cd "$prev_dir"
        mark_phase_failed "sinapsis-engine" "vendor/sinapsis/install.sh devolvió error · revisa el output anterior"
    fi
    cd "$prev_dir"

    # FIX capa OS: cablear los hooks de Sinapsis en settings.json (idempotente).
    # El instalador vendored NO lo hace si settings.json ya existía.
    info "Cableando hooks de Sinapsis en ~/.claude/settings.json..."
    if ensure_sinapsis_hooks; then
        ok "Hooks de Sinapsis cableados en settings.json"
    else
        warn "No se pudieron cablear los hooks automáticamente · revisa ~/.claude/settings.json"
    fi

    # Validación POST-instalación (esto es lo que evita "instalaciones fantasma")
    info "Validando instalación de Sinapsis (validación profunda)..."
    if ! validate_sinapsis_deep; then
        record_sinapsis_validation
        mark_phase_failed "sinapsis-engine" "Sinapsis se ejecutó pero la validación profunda falla · ver warnings arriba"
    fi

    record_sinapsis_validation
    compute_and_store_checksum
    mark_phase_done "sinapsis-engine"
    ok "Sinapsis instalado y validado"
}

compute_and_store_checksum() {
    # Hash de los archivos clave de Sinapsis para detectar drift posterior
    local files_hash
    if command -v shasum >/dev/null 2>&1; then
        files_hash=$(find -L "$SKILLS_DIR" -maxdepth 1 -type f -name "_*.json" -o -name "_*.sh" 2>/dev/null | sort | xargs shasum -a 256 2>/dev/null | shasum -a 256 | awk '{print $1}')
    elif command -v sha256sum >/dev/null 2>&1; then
        files_hash=$(find -L "$SKILLS_DIR" -maxdepth 1 -type f -name "_*.json" -o -name "_*.sh" 2>/dev/null | sort | xargs sha256sum 2>/dev/null | sha256sum | awk '{print $1}')
    else
        files_hash="sha-tool-not-found"
    fi
    local validation_json
    validation_json=$(cat <<EOF
{
  "operator_state_json_valid": true,
  "catalog_json_valid": true,
  "hooks_executable": true,
  "skills_count": $(find -L "$SKILLS_DIR" -maxdepth 3 -name "SKILL.md" 2>/dev/null | wc -l | tr -d ' ')
}
EOF
)
    json_set_phase "sinapsis-engine" "validation" "$validation_json"
    json_set_phase "sinapsis-engine" "checksum" "\"sha256:$files_hash\""
}

# ── OS layer setup (no es una fase del state, son archivos del repo) ──
setup_os_layer() {
    title "Configurando capa OS del repo (archivos locales)"

    mkdir -p "$REPO_ROOT/projects" "$REPO_ROOT/projects/briefs" "$REPO_ROOT/projects/welcome"
    mkdir -p "$REPO_ROOT/context"
    mkdir -p "$REPO_ROOT/brand-context/voice" "$REPO_ROOT/brand-context/positioning" "$REPO_ROOT/brand-context/icp" "$REPO_ROOT/brand-context/assets"

    for empty_dir in "projects/briefs" "projects/welcome" "brand-context/voice" "brand-context/positioning" "brand-context/icp" "brand-context/assets"; do
        [ ! -f "$REPO_ROOT/$empty_dir/.gitkeep" ] && touch "$REPO_ROOT/$empty_dir/.gitkeep" || true
    done
    ok "Directorios proyecto creados"

    # Soul.md
    if [ ! -f "$REPO_ROOT/context/soul.md" ]; then
        cat > "$REPO_ROOT/context/soul.md" <<'EOF'
# Soul · personalidad del agente

> Cómo respondes al usuario. Esto es estático (cambia poco).

## Tono
- Directo, sin rodeos
- Cálido pero no efusivo
- 2-3 opciones máx con recomendación, no listas exhaustivas

## Idioma
- Castellano siempre con el operador
- Outputs cliente en el idioma configurado en `me.md`

## Lo que NO haces
- Vender humo
- Inflar palabras vacías
- Ejecutar acciones destructivas sin confirmar

---
*Última actualización: instalación inicial · este archivo lo modificas tú a tu gusto*
EOF
        ok "context/soul.md creado"
    fi

    if [ ! -f "$REPO_ROOT/context/decisions-log.md" ]; then
        cat > "$REPO_ROOT/context/decisions-log.md" <<'EOF'
# Decisions log

Diario append-only de decisiones del operador.
Patrón inspirado en [claude-code-second-brain](https://github.com/Luispitik/claude-code-second-brain) de Luis Pitik.

---
EOF
        ok "context/decisions-log.md creado"
    fi

    if [ ! -f "$REPO_ROOT/context/learnings.md" ]; then
        cat > "$REPO_ROOT/context/learnings.md" <<'EOF'
# Learnings

Feedback consolidado de skills, append-only.

---
EOF
        ok "context/learnings.md creado"
    fi

    if [ ! -f "$REPO_ROOT/.env" ] && [ -f "$REPO_ROOT/.env.example" ]; then
        cp "$REPO_ROOT/.env.example" "$REPO_ROOT/.env"
        ok ".env creado desde .env.example"
    fi

    # Instalar hook _install-gate.sh en SKILLS_DIR (es el gate de SessionStart)
    if [ -f "$SCRIPT_DIR/_install-gate.sh" ]; then
        cp "$SCRIPT_DIR/_install-gate.sh" "$SKILLS_DIR/_install-gate.sh"
        chmod +x "$SKILLS_DIR/_install-gate.sh"
        ok "_install-gate.sh instalado en $SKILLS_DIR (hook SessionStart)"
        register_session_start_hook
    else
        warn "_install-gate.sh no encontrado en scripts/ · el gate de bloqueo no funcionará"
    fi
}

# Registra el hook SessionStart en ~/.claude/settings.json sin pisar lo que Sinapsis u
# otros plugins hayan registrado. Idempotente: si ya está, no lo duplica.
register_session_start_hook() {
    local settings="$CLAUDE_HOME/settings.json"
    if [ ! -f "$settings" ]; then
        warn "  ~/.claude/settings.json no existe todavía · Sinapsis debería haberlo creado"
        return 0
    fi

    node <<NODE_EOF
const fs = require('fs');
const settingsPath = '$settings';
try {
  const s = JSON.parse(fs.readFileSync(settingsPath, 'utf8'));
  if (!s.hooks) s.hooks = {};
  if (!Array.isArray(s.hooks.SessionStart)) s.hooks.SessionStart = [];

  // Detectar si ya está registrado el install-gate (idempotencia)
  const alreadyRegistered = s.hooks.SessionStart.some(group =>
    Array.isArray(group.hooks) && group.hooks.some(h =>
      typeof h.command === 'string' && h.command.includes('_install-gate.sh')
    )
  );

  if (alreadyRegistered) {
    console.log('[SKIP] SessionStart hook ya registrado en settings.json');
    process.exit(0);
  }

  s.hooks.SessionStart.push({
    hooks: [
      {
        _comment: 'iAmasters OS install gate: bloquea sesiones si _install-state.json no completo',
        type: 'command',
        command: 'bash ~/.claude/skills/_install-gate.sh',
        timeout: 5
      }
    ]
  });

  fs.writeFileSync(settingsPath, JSON.stringify(s, null, 2));
  console.log('[OK] SessionStart hook registrado en ~/.claude/settings.json');
} catch (e) {
  console.error('[WARN] No pude modificar settings.json: ' + e.message);
  process.exit(0);
}
NODE_EOF
}

# ── Migration helper: detecta instalación v0.5.x existente y rellena state retroactivamente ──
migrate_v05_existing() {
    # Si los archivos de context/ ya existen y tienen contenido real, marca context-files done.
    # Útil para usuarios que actualizan de v0.5.x a v0.6 sin tener que rehacer el onboarding.

    local migrated_files="[]"
    for f in "context/me.md" "context/work.md" "context/current-priorities.md" "context/goals.md"; do
        if [ -f "$REPO_ROOT/$f" ]; then
            local size
            size=$(wc -c < "$REPO_ROOT/$f" | tr -d ' ')
            if [ "$size" -gt 100 ]; then
                case "$JSON_RUNTIME" in
                    node)
                        migrated_files=$(node -e "
                            const arr = $migrated_files;
                            arr.push('$f');
                            process.stdout.write(JSON.stringify(arr));
                        ")
                        ;;
                    python3|python)
                        migrated_files=$("$JSON_RUNTIME" -c "
import json
arr = $migrated_files
arr.append('$f')
print(json.dumps(arr))
")
                        ;;
                esac
            fi
        fi
    done

    # Si tenemos los 4 archivos → marcamos context-files done
    local count
    case "$JSON_RUNTIME" in
        node)    count=$(node -e "process.stdout.write(String($migrated_files.length))") ;;
        python3|python) count=$("$JSON_RUNTIME" -c "print(len($migrated_files))") ;;
    esac

    if [ "$count" = "4" ]; then
        local current_cf_status
        current_cf_status=$(json_get_phase_status "context-files")
        if [ "$current_cf_status" != "done" ]; then
            json_set_phase "context-files" "filesCreated" "$migrated_files"
            json_set_phase "context-files" "filesPending" "[]"
            mark_phase_done "context-files"
            ok "Migrado v0.5→v0.6: context-files marcado como done (4 archivos preexistentes con contenido real)"
        fi
    fi

    # Si _operator-state.json tiene needsOnboarding: false, marcamos operator-state done
    if [ -f "$SKILLS_DIR/_operator-state.json" ]; then
        local needs_onboarding
        case "$JSON_RUNTIME" in
            node)
                needs_onboarding=$(node -e "
                    try {
                        const s = JSON.parse(require('fs').readFileSync('$SKILLS_DIR/_operator-state.json','utf8'));
                        process.stdout.write(String(s.needsOnboarding === false));
                    } catch (e) { process.stdout.write('false'); }
                ")
                ;;
            python3|python)
                needs_onboarding=$("$JSON_RUNTIME" -c "
import json
try:
    s = json.load(open('$SKILLS_DIR/_operator-state.json'))
    print(str(s.get('needsOnboarding') == False).lower())
except: print('false')
")
                ;;
        esac
        if [ "$needs_onboarding" = "true" ]; then
            local current_os_status
            current_os_status=$(json_get_phase_status "operator-state")
            if [ "$current_os_status" != "done" ]; then
                mark_phase_done "operator-state"
                ok "Migrado v0.5→v0.6: operator-state marcado como done (needsOnboarding: false detectado)"
            fi
        fi
    fi

    # Si projects/welcome/ tiene algo, asumimos welcome-quick-win se hizo en una sesión anterior
    if [ -d "$REPO_ROOT/projects/welcome" ] && [ -n "$(find "$REPO_ROOT/projects/welcome" -type f ! -name '.gitkeep' 2>/dev/null | head -1)" ]; then
        local current_wc_status
        current_wc_status=$(json_get_phase_status "welcome-completed")
        if [ "$current_wc_status" != "done" ]; then
            mark_phase_done "welcome-completed"
            ok "Migrado v0.5→v0.6: welcome-completed marcado como done (deliverable preexistente)"
        fi
    fi
}

# ── Main flow ──
main() {
    if ! detect_json_runtime; then
        err "Necesito node, python3 o python (Python 3) para gestionar el state machine"
        err "Instala uno: https://nodejs.org o https://python.org"
        exit 1
    fi
    info "JSON runtime: $JSON_RUNTIME"

    init_state

    phase_prereqs
    phase_sinapsis_engine
    setup_os_layer

    # Migración automática para usuarios v0.5.x con instalación previa
    migrate_v05_existing

    # Las fases 3-5 (context-files, operator-state, welcome-completed) las hace
    # el wizard DENTRO de Claude Code, no este script. El gate las verificará.

    echo ""
    echo "============================================================"
    echo "  ✓ Fases técnicas completadas (prereqs + sinapsis-engine + capa OS)"
    echo "============================================================"
    echo ""
    echo "  Estado actual:"
    case "$JSON_RUNTIME" in
        node)
            node -e "
const s = JSON.parse(require('fs').readFileSync('$WIN_STATE_FILE','utf8'));
for (const [k, v] of Object.entries(s.phases)) {
  const icon = v.status === 'done' ? '✅' : v.status === 'failed' ? '❌' : v.status === 'in-progress' ? '🟡' : '⏳';
  console.log('   ' + icon + ' ' + k + ' · ' + v.status);
}
" 2>/dev/null || true
            ;;
        python3|python)
            "$JSON_RUNTIME" -c "
import json
s = json.load(open('$WIN_STATE_FILE'))
icons = {'done':'OK','failed':'ERR','in-progress':'WIP','pending':'...','skipped':'SKIP'}
for k, v in s['phases'].items():
    print('   [' + icons.get(v.get('status','pending'),'?') + '] ' + k + ' . ' + v.get('status','pending'))
" 2>/dev/null || true
            ;;
    esac
    echo ""
    echo "  Siguiente paso:"
    echo "    1. Abre Claude Code en este repo: $REPO_ROOT"
    echo "    2. El hook SessionStart detectará que faltan fases 3-5 (onboarding)"
    echo "    3. Sigue las instrucciones del agente — ejecuta /install si te lo pide"
    echo ""
    echo "  Si algo falla, ejecuta:    bash scripts/install.sh --resume"
    echo "  Para reinstalar desde 0:   bash scripts/install.sh --force-reinstall"
    echo ""
    echo "  State machine en:   $STATE_FILE"
    echo "  Inspecciónalo con:  cat $STATE_FILE"
    echo ""
    exit 0
}

main "$@"
