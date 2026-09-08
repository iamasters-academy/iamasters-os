#!/bin/bash
# ============================================================
#  iAmasters OS — backup.sh
#  Copia de seguridad de TODO lo irreemplazable del operador:
#  - Datos del repo que NUNCA van a git (context/, brand-context/,
#    projects/, clients/, loops/, .env, skills propias)
#  - Memoria Sinapsis global (~/.claude/skills/: operator-state,
#    instincts, daily summaries, catalog, passive rules)
#
#  Destino (en este orden):
#    1. IAMASTERS_BACKUP_DIR del .env (elección del operador, se fija
#       la primera vez via /backup) o flag --dest <ruta>
#    2. Auto-detección: iCloud → Google Drive → Dropbox → OneDrive
#    3. $HOME/iAmasters-Backup/ (sin nube: solo copia local)
#
#  Uso:
#    bash scripts/backup.sh             # crea backup fechado
#    bash scripts/backup.sh --list      # lista backups existentes
#    bash scripts/backup.sh --where     # nubes detectadas en esta máquina
#    bash scripts/backup.sh --dest <p>  # destino explícito (una vez)
#  Rotación: conserva los últimos 7 backups, borra los más antiguos.
# ============================================================

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
NC='\033[0m'
BOLD='\033[1m'

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILLS_GLOBAL="$HOME/.claude/skills"
KEEP_LAST=7

# ── Detección de nubes en esta máquina (Mac y Windows/Git Bash) ──
detect_cloud() {
    # $1 = icloud|gdrive|dropbox|onedrive; echoes la ruta base si existe
    local d
    case "$1" in
        icloud)
            d="$HOME/Library/Mobile Documents/com~apple~CloudDocs"
            [ -d "$d" ] && echo "$d"
            ;;
        gdrive)
            for d in "$HOME/Library/CloudStorage/GoogleDrive-"*"/My Drive" \
                     "$HOME/Library/CloudStorage/GoogleDrive-"*"/Mi unidad" \
                     "$HOME/Google Drive/My Drive" \
                     "$HOME/Google Drive/Mi unidad" \
                     "$HOME/Google Drive"; do
                [ -d "$d" ] && { echo "$d"; return 0; }
            done
            ;;
        dropbox)
            for d in "$HOME/Dropbox" "$HOME/Library/CloudStorage/Dropbox"; do
                [ -d "$d" ] && { echo "$d"; return 0; }
            done
            ;;
        onedrive)
            for d in "$HOME/OneDrive" "$HOME/Library/CloudStorage/OneDrive-"*; do
                [ -d "$d" ] && { echo "$d"; return 0; }
            done
            ;;
    esac
    return 0
}

# ── ¿Esta carpeta de nube sincroniza DE VERDAD? ──
# Que exista una carpeta llamada "OneDrive" no prueba nada: puede ser el resto
# de una cuenta desconectada, y entonces el backup no sale nunca de la máquina.
# Devuelve: live | dead | unknown  (unknown = no lo puedo verificar, aviso y sigo)
cloud_status() {
    local dir="$1"
    [ -d "$dir" ] || { echo "dead"; return 0; }

    # Mac: lo que cuelga de CloudStorage/Mobile Documents es un montaje real
    case "$dir" in
        "$HOME/Library/CloudStorage/"*|"$HOME/Library/Mobile Documents/"*)
            echo "live"; return 0 ;;
    esac

    # Windows + OneDrive: el registro lista las carpetas realmente montadas
    case "$(printf '%s' "$dir" | tr 'A-Z' 'a-z')" in
        *onedrive*)
            if command -v reg >/dev/null 2>&1 && command -v cygpath >/dev/null 2>&1; then
                local win norm mounted m
                win="$(cygpath -w "$dir" 2>/dev/null)" || win=""
                if [ -n "$win" ]; then
                    norm="$(printf '%s' "$win" | tr 'A-Z\\' 'a-z/' | sed 's:/*$::')"
                    # MSYS_NO_PATHCONV: sin esto Git Bash convierte /s y /v en rutas
                    # de Windows y reg contesta "sintaxis incorrecta"
                    mounted="$(MSYS_NO_PATHCONV=1 reg query 'HKCU\Software\Microsoft\OneDrive\Accounts' \
                               /s /v UserFolder 2>/dev/null \
                               | tr -d '\r' | sed -n 's/.*REG_SZ[[:space:]]*//p' \
                               | tr 'A-Z\\' 'a-z/' | sed 's:/*$::')"
                    if [ -n "$mounted" ]; then
                        while IFS= read -r m; do
                            [ -z "$m" ] && continue
                            case "$norm" in
                                "$m"|"$m"/*) echo "live"; return 0 ;;
                            esac
                        done <<< "$mounted"
                        echo "dead"; return 0
                    fi
                fi
            fi
            ;;
    esac

    echo "unknown"
}

# ── Resolver destino ──
# Prioridad: --dest > IAMASTERS_BACKUP_DIR (.env) > iCloud > Google Drive
#            > Dropbox > OneDrive > $HOME (local)
ARG_DEST=""
if [ "${1:-}" = "--dest" ]; then
    ARG_DEST="${2:-}"
    if [ -z "$ARG_DEST" ]; then
        printf "%b\n" "Falta la ruta. Uso: bash scripts/backup.sh --dest <ruta>"
        exit 1
    fi
    shift 2
fi

if [ -f "$REPO_ROOT/.env" ]; then
    ENV_DEST=$(grep -E '^IAMASTERS_BACKUP_DIR=' "$REPO_ROOT/.env" 2>/dev/null | cut -d= -f2- | tr -d '"' || true)
fi

if [ -n "$ARG_DEST" ]; then
    DEST_ROOT="$ARG_DEST"
elif [ -n "${ENV_DEST:-}" ]; then
    DEST_ROOT="$ENV_DEST"
else
    DEST_ROOT=""
    for cloud in icloud gdrive dropbox onedrive; do
        base="$(detect_cloud "$cloud")"
        # Una nube desconectada no es un destino: se salta
        if [ -n "$base" ] && [ "$(cloud_status "$base")" != "dead" ]; then
            DEST_ROOT="$base/iAmasters-Backup"
            break
        fi
    done
    [ -z "$DEST_ROOT" ] && DEST_ROOT="$HOME/iAmasters-Backup"
fi

if [ "${1:-}" = "--where" ]; then
    echo ""
    echo -e "${BOLD}Nubes detectadas en esta máquina:${NC}"
    found=0
    for cloud in icloud gdrive dropbox onedrive; do
        base="$(detect_cloud "$cloud")"
        if [ -n "$base" ]; then
            case "$cloud" in
                icloud)   label="iCloud Drive " ;;
                gdrive)   label="Google Drive " ;;
                dropbox)  label="Dropbox      " ;;
                onedrive) label="OneDrive     " ;;
            esac
            case "$(cloud_status "$base")" in
                live)    mark="${GREEN}sincroniza${NC}" ;;
                dead)    mark="${RED}DESCONECTADA — no sale de esta máquina${NC}" ;;
                *)       mark="${YELLOW}no he podido comprobar si sincroniza${NC}" ;;
            esac
            echo -e "  $label → $base  [$mark]"
            found=1
        fi
    done
    [ "$found" -eq 0 ] && echo "  (ninguna — el backup iría a $HOME/iAmasters-Backup)"
    echo ""
    echo -e "Destino actual: ${CYAN}$DEST_ROOT${NC}"
    echo "Para fijar otro: añade IAMASTERS_BACKUP_DIR=<ruta> al .env (o dile a Claude dónde lo quieres)."
    exit 0
fi

if [ "${1:-}" = "--list" ]; then
    echo ""
    echo -e "${BOLD}Backups en: $DEST_ROOT${NC}"
    if [ -d "$DEST_ROOT" ]; then
        ls -1 "$DEST_ROOT" | grep -E '^[0-9]{4}-[0-9]{2}-[0-9]{2}_' | sort -r | sed 's/^/  /' || echo "  (ninguno)"
    else
        echo "  (ninguno todavía)"
    fi
    echo ""
    exit 0
fi

STAMP="$(date +%Y-%m-%d_%H%M%S)"
DEST="$DEST_ROOT/$STAMP"

echo ""
echo -e "${PURPLE}${BOLD}============================================================${NC}"
echo -e "${PURPLE}${BOLD}  iAmasters OS — Backup${NC}"
echo -e "${PURPLE}${BOLD}============================================================${NC}"
echo ""
echo -e "  Destino: ${CYAN}$DEST${NC}"
echo ""

mkdir -p "$DEST/repo" "$DEST/sinapsis"

# ── 1. Datos del operador en el repo (lo que git NO guarda) ──
echo -e "${BLUE}[1/3]${NC} Datos del operador (repo)..."
COPIED=0
for d in "context" "brand-context" "projects" "clients" "loops" ".env" ".claude/skills" ".claude/settings.json"; do
    if [ -e "$REPO_ROOT/$d" ]; then
        mkdir -p "$(dirname "$DEST/repo/$d")"
        cp -R "$REPO_ROOT/$d" "$DEST/repo/$d" 2>/dev/null || true
        COPIED=$((COPIED+1))
    fi
done
echo -e "${GREEN}  OK${NC} $COPIED rutas copiadas"

# ── 2. Memoria Sinapsis global (~/.claude/skills) ──
echo -e "${BLUE}[2/3]${NC} Memoria Sinapsis global..."
SINAPSIS_COPIED=0
for f in "_operator-state.json" "_catalog.json" "_passive-rules.json" "_projects.json" \
         "_instincts-index.json" "_instinct-proposals.json" "_install-state.json" \
         "_daily-summaries"; do
    if [ -e "$SKILLS_GLOBAL/$f" ]; then
        cp -R "$SKILLS_GLOBAL/$f" "$DEST/sinapsis/$f" 2>/dev/null || true
        SINAPSIS_COPIED=$((SINAPSIS_COPIED+1))
    fi
done
echo -e "${GREEN}  OK${NC} $SINAPSIS_COPIED elementos copiados"

# Metadatos para saber de dónde salió
{
    echo "CREATED_AT=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "REPO_ROOT=$REPO_ROOT"
    echo "REPO_COMMIT=$(git -C "$REPO_ROOT" rev-parse HEAD 2>/dev/null || echo unknown)"
    echo "HOSTNAME=$(hostname)"
} > "$DEST/META.txt"

# ── 3. Rotación: conservar últimos N ──
echo -e "${BLUE}[3/3]${NC} Rotación (conservo los últimos $KEEP_LAST)..."
PRUNED=0
while IFS= read -r old; do
    [ -z "$old" ] && continue
    rm -rf "${DEST_ROOT:?}/$old"
    PRUNED=$((PRUNED+1))
done <<< "$(ls -1 "$DEST_ROOT" | grep -E '^[0-9]{4}-[0-9]{2}-[0-9]{2}_' | sort -r | tail -n +$((KEEP_LAST+1)))"
if [ "$PRUNED" -gt 0 ]; then
    echo -e "${GREEN}  OK${NC} $PRUNED backups antiguos eliminados"
else
    echo -e "${GREEN}  OK${NC} Nada que rotar"
fi

SIZE=$(du -sh "$DEST" 2>/dev/null | cut -f1)

echo ""
echo -e "${GREEN}${BOLD}============================================================${NC}"
echo -e "${GREEN}${BOLD}  Backup completado ($SIZE)${NC}"
echo -e "${GREEN}${BOLD}============================================================${NC}"
echo ""
echo -e "  Guardado en: ${CYAN}$DEST${NC}"

# ── ¿Ha salido de esta máquina? Decirlo SIEMPRE, aunque el destino venga del .env ──
case "$(cloud_status "$DEST_ROOT")" in
    live)
        echo -e "  Copia fuera de la máquina: ${GREEN}sí${NC} (la nube lo está sincronizando)"
        ;;
    dead)
        echo ""
        echo -e "  ${RED}${BOLD}AVISO: esta copia NO ha salido del ordenador.${NC}"
        echo -e "  ${RED}$DEST_ROOT parece una nube, pero la cuenta está desconectada.${NC}"
        echo -e "  ${RED}Si se rompe este disco, se pierde también el backup.${NC}"
        echo -e "  Reconecta la cuenta o elige otro destino: ${CYAN}bash scripts/backup.sh --where${NC}"
        ;;
    *)
        echo -e "  Copia fuera de la máquina: ${YELLOW}no he podido verificarlo${NC} — compruébalo en la web de tu nube"
        ;;
esac

echo ""
echo -e "  Para restaurar en una máquina nueva: clona el repo, instala el OS"
echo -e "  y dile a Claude: ${CYAN}\"restaura mis datos desde el backup de $STAMP\"${NC}"
echo ""
