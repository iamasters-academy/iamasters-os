#!/bin/bash
# ============================================================
#  iAmasters OS — rollback.sh
#  Deshace la última actualización (update.sh) sin perder nada
#  - Restaura el código del OS al commit previo al update
#  - Restaura los datos del operador desde el backup automático
#  - Antes de tocar nada, guarda el estado actual en .backup/pre-rollback-*
#
#  Uso:
#    bash scripts/rollback.sh            # restaura el último backup
#    bash scripts/rollback.sh --list     # lista backups disponibles
#    bash scripts/rollback.sh --from 20260612_091500   # backup concreto
#    bash scripts/rollback.sh --yes      # sin confirmación (uso por agente)
# ============================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
NC='\033[0m'
BOLD='\033[1m'

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BACKUP_ROOT="$REPO_ROOT/.backup"

# Carpetas que update.sh respalda y que aquí restauramos
USER_DATA_PATHS=(".claude/skills" "brand-context" "context" "projects" "clients" ".env" ".claude/settings.json")

LIST_ONLY=false
ASSUME_YES=false
FROM_BACKUP=""

while [ $# -gt 0 ]; do
    case "$1" in
        --list) LIST_ONLY=true ;;
        --yes|-y) ASSUME_YES=true ;;
        --from)
            shift
            FROM_BACKUP="${1:-}"
            ;;
        -h|--help)
            grep '^#' "$0" | head -16
            exit 0
            ;;
        *)
            echo -e "${RED}Argumento desconocido: $1${NC}"
            exit 1
            ;;
    esac
    shift
done

# Sin TTY (lo lanza un agente) → no podemos preguntar, asumimos --yes
if [ ! -t 0 ]; then
    ASSUME_YES=true
fi

cd "$REPO_ROOT"

echo ""
echo -e "${PURPLE}${BOLD}============================================================${NC}"
echo -e "${PURPLE}${BOLD}  iAmasters OS — Rollback${NC}"
echo -e "${PURPLE}${BOLD}============================================================${NC}"
echo ""

# ── Localizar backups ──
if [ ! -d "$BACKUP_ROOT" ] || [ -z "$(ls -A "$BACKUP_ROOT" 2>/dev/null)" ]; then
    echo -e "${YELLOW}No hay backups en .backup/ — nada que restaurar.${NC}"
    echo "Los backups se crean automáticamente cada vez que corres update.sh o /actualiza."
    exit 0
fi

# Solo backups de update (formato YYYYMMDD_HHMMSS), no los pre-rollback
BACKUPS=$(ls -1 "$BACKUP_ROOT" | grep -E '^[0-9]{8}_[0-9]{6}$' | sort -r)

if [ -z "$BACKUPS" ]; then
    echo -e "${YELLOW}No hay backups de update en .backup/ — nada que restaurar.${NC}"
    exit 0
fi

if $LIST_ONLY; then
    echo -e "${BOLD}Backups disponibles (más reciente primero):${NC}"
    while IFS= read -r b; do
        meta=""
        if [ -f "$BACKUP_ROOT/$b/META.txt" ]; then
            commit=$(grep '^PRE_UPDATE_COMMIT=' "$BACKUP_ROOT/$b/META.txt" | cut -d= -f2 | cut -c1-7)
            meta=" · commit previo: $commit"
        fi
        echo "  $b$meta"
    done <<< "$BACKUPS"
    echo ""
    echo "Restaurar uno: bash scripts/rollback.sh --from <nombre>"
    exit 0
fi

# ── Elegir backup ──
if [ -n "$FROM_BACKUP" ]; then
    TARGET="$FROM_BACKUP"
    if [ ! -d "$BACKUP_ROOT/$TARGET" ]; then
        echo -e "${RED}ERROR${NC} No existe el backup: $TARGET"
        echo "Disponibles:"
        echo "$BACKUPS" | sed 's/^/  /'
        exit 1
    fi
else
    TARGET=$(echo "$BACKUPS" | head -1)
fi

TARGET_DIR="$BACKUP_ROOT/$TARGET"
echo -e "${BLUE}[1/4]${NC} Backup a restaurar: ${BOLD}$TARGET${NC}"

PRE_COMMIT=""
if [ -f "$TARGET_DIR/META.txt" ]; then
    PRE_COMMIT=$(grep '^PRE_UPDATE_COMMIT=' "$TARGET_DIR/META.txt" | cut -d= -f2)
    echo -e "  Código del OS volverá al commit: ${CYAN}${PRE_COMMIT:0:7}${NC}"
else
    echo -e "  ${YELLOW}! Backup antiguo sin META.txt — solo se restauran datos, no el código${NC}"
fi

if ! $ASSUME_YES; then
    read -p "  ¿Continuar con el rollback? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Rollback cancelado."
        exit 0
    fi
fi

# ── Red de seguridad: snapshot del estado ACTUAL antes de tocar nada ──
echo -e "${BLUE}[2/4]${NC} Guardando estado actual (por si te arrepientes)..."
SAFETY_DIR="$BACKUP_ROOT/pre-rollback-$(date +%Y%m%d_%H%M%S)"
mkdir -p "$SAFETY_DIR"
for d in "${USER_DATA_PATHS[@]}"; do
    if [ -e "$REPO_ROOT/$d" ]; then
        mkdir -p "$(dirname "$SAFETY_DIR/$d")"
        cp -R "$REPO_ROOT/$d" "$SAFETY_DIR/$d" 2>/dev/null || true
    fi
done
{
    echo "PRE_UPDATE_COMMIT=$(git rev-parse HEAD)"
    echo "PRE_UPDATE_BRANCH=$(git branch --show-current)"
    echo "CREATED_AT=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
} > "$SAFETY_DIR/META.txt"
echo -e "${GREEN}  OK${NC} Snapshot en: ${SAFETY_DIR/$REPO_ROOT/.}/"

# ── Revertir código del OS ──
echo -e "${BLUE}[3/4]${NC} Restaurando código del OS..."
if [ -n "$PRE_COMMIT" ] && git cat-file -e "$PRE_COMMIT" 2>/dev/null; then
    # reset --hard solo toca archivos TRACKED; los datos del operador
    # (gitignored/untracked) no se ven afectados
    git reset --hard "$PRE_COMMIT" >/dev/null
    echo -e "${GREEN}  OK${NC} Código en commit ${PRE_COMMIT:0:7}"
else
    echo -e "${YELLOW}  ! Sin commit de referencia — código sin cambios${NC}"
fi

# ── Restaurar datos del operador desde el backup ──
echo -e "${BLUE}[4/4]${NC} Restaurando datos del operador..."
RESTORED=0
for d in "${USER_DATA_PATHS[@]}"; do
    if [ -e "$TARGET_DIR/$d" ]; then
        rm -rf "${REPO_ROOT:?}/$d"
        mkdir -p "$(dirname "$REPO_ROOT/$d")"
        cp -R "$TARGET_DIR/$d" "$REPO_ROOT/$d"
        RESTORED=$((RESTORED+1))
    fi
done
echo -e "${GREEN}  OK${NC} $RESTORED rutas restauradas desde el backup"

# El rollback deja el árbol en un estado anterior, así que el commit upstream que
# update.sh tenía registrado como aplicado ya no describe lo que hay en disco.
# Se invalida: el siguiente /actualiza vuelve a medir contra HEAD (comportamiento
# de un primer update) en vez de fiarse de una base que ya no es cierta.
if [ -f "$REPO_ROOT/.claude/.upstream-state" ]; then
    rm -f "$REPO_ROOT/.claude/.upstream-state"
    echo -e "${GREEN}  OK${NC} Estado de upstream invalidado (lo recalcula el próximo /actualiza)"
fi

echo ""
echo -e "${GREEN}${BOLD}============================================================${NC}"
echo -e "${GREEN}${BOLD}  Rollback completado${NC}"
echo -e "${GREEN}${BOLD}============================================================${NC}"
echo ""
echo -e "  El OS está como antes de la última actualización."
echo -e "  Si era esto un error, tu estado previo quedó en:"
echo -e "  ${CYAN}${SAFETY_DIR/$REPO_ROOT/.}/${NC}"
echo ""
echo -e "  Recomendado: ejecuta ${CYAN}/doctor${NC} en Claude Code para verificar salud."
echo ""
