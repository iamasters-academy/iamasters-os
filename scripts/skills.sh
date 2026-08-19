#!/bin/bash
# ============================================================
#  iAmasters OS — skills.sh
#  Gestión de la biblioteca de skills (modelo Core + Biblioteca)
#
#  - Core (.claude/skills/): siempre instaladas, el OS las necesita
#
#  ⚠️  ESTRUCTURA DE INSTALACION: PLANA, .claude/skills/<nombre>/SKILL.md
#      Claude Code SOLO indexa un nivel bajo skills/ (verificado en el loader
#      del CLI y en la doc oficial). Una carpeta de categoria intermedia hace
#      que la skill NO exista para el tool Skill ("Unknown skill").
#      La categoria vive en la BIBLIOTECA (skills-library/<categoria>/) y en el
#      prefijo del nombre (marketing-, tool-, strategy-, automation-). NO la
#      reintroduzcas en el destino: scripts/ci/check-skills-depth.sh lo bloquea.
#  - Biblioteca (skills-library/): catálogo curado, se instalan a demanda
#    (cada skill instalada ocupa contexto; Anthropic recomienda <50 cargadas)
#
#  Uso:
#    bash scripts/skills.sh list              # catálogo: instaladas + disponibles
#    bash scripts/skills.sh add <nombre>      # instala desde la biblioteca (+ deps)
#    bash scripts/skills.sh remove <nombre>   # desinstala (las core no se pueden)
#    bash scripts/skills.sh sync [--quiet]    # refresca instaladas tras /actualiza
#
#  Las personalizaciones del operador (SKILL.local.md) se preservan
#  SIEMPRE: al instalar, desinstalar, reinstalar y sincronizar.
# ============================================================

set -e

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
DIM='\033[2m'
NC='\033[0m'
BOLD='\033[1m'

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LIB_DIR="$REPO_ROOT/skills-library"
INST_DIR="$REPO_ROOT/.claude/skills"

# Dependencias entre skills de la biblioteca: "skill:dep1 dep2"
# (las deps que ya son core se ignoran solas porque siempre están)
DEPS="
metodo-ias:strategy-web-research
strategy-investigacion-profunda:strategy-web-research
"

QUIET=false

lib_path() {
    # $1 = nombre de skill; echoes ruta en biblioteca (vacío si no existe)
    find "$LIB_DIR" -mindepth 2 -maxdepth 2 -type d -name "$1" 2>/dev/null | head -1
}

inst_path() {
    # $1 = nombre de skill; echoes ruta instalada (vacío si no)
    find "$INST_DIR" -mindepth 1 -maxdepth 1 -type d -name "$1" ! -path "*_archived*" 2>/dev/null | head -1
}

skill_desc() {
    # $1 = ruta de skill; primera línea de description del frontmatter, truncada
    grep -m1 '^description:' "$1/SKILL.md" 2>/dev/null \
        | sed 's/^description:[[:space:]]*//' | cut -c1-90
}

deps_for() {
    # $1 = nombre; echoes deps declaradas (separadas por espacio)
    echo "$DEPS" | grep "^$1:" | cut -d: -f2
}

say() { $QUIET || printf "%b\n" "$1"; }

do_add() {
    local name="$1" as_dep="${2:-}"
    local src dst

    if [ -n "$(inst_path "$name")" ]; then
        [ -z "$as_dep" ] && say "${GREEN}  ✓ $name ya está instalada${NC}"
        return 0
    fi

    src="$(lib_path "$name")"
    if [ -z "$src" ]; then
        printf "%b\n" "${RED}  ✗ No existe '$name' en la biblioteca.${NC}"
        printf "%b\n" "  Mira el catálogo: ${CYAN}bash scripts/skills.sh list${NC}"
        return 1
    fi

    # Dependencias primero
    local dep
    for dep in $(deps_for "$name"); do
        do_add "$dep" "dep"
    done

    # destino PLANO: la categoria de la biblioteca no se replica aqui (ver header)
    dst="$INST_DIR/$name"
    mkdir -p "$INST_DIR"
    cp -R "$src" "$dst"

    if [ -n "$as_dep" ]; then
        say "${GREEN}  ✓ $name instalada${NC} ${DIM}(dependencia)${NC}"
    else
        say "${GREEN}  ✓ $name instalada${NC}"
    fi
}

do_remove() {
    local name="$1"
    local installed src

    installed="$(inst_path "$name")"
    if [ -z "$installed" ]; then
        printf "%b\n" "${YELLOW}  ! $name no está instalada${NC}"
        return 0
    fi

    src="$(lib_path "$name")"
    if [ -z "$src" ]; then
        printf "%b\n" "${RED}  ✗ $name es una skill CORE — el OS la necesita, no se desinstala.${NC}"
        return 1
    fi

    # Preservar personalización del operador dentro de la biblioteca
    # (gitignored, sobrevive a updates; se restaura al reinstalar)
    if [ -f "$installed/SKILL.local.md" ]; then
        cp "$installed/SKILL.local.md" "$src/SKILL.local.md"
        say "${CYAN}  -> SKILL.local.md guardado (se restaurará si la reinstalas)${NC}"
    fi

    rm -rf "$installed"
    say "${GREEN}  ✓ $name desinstalada${NC}"
}

do_sync() {
    # Refresca cada skill instalada que provenga de la biblioteca.
    # Las personalizaciones viven en SKILL.local.md → se preservan.
    local refreshed=0
    local dir name src local_md
    for dir in "$INST_DIR"/*/; do
        [ -d "$dir" ] || continue
        case "$dir" in *_archived*) continue ;; esac
        name="$(basename "$dir")"
        src="$(lib_path "$name")"
        [ -z "$src" ] && continue  # core: la actualiza git, no nosotros

        if ! diff -rq "$src" "${dir%/}" --exclude=SKILL.local.md >/dev/null 2>&1; then
            local_md=""
            if [ -f "${dir%/}/SKILL.local.md" ]; then
                local_md="$(mktemp)"
                cp "${dir%/}/SKILL.local.md" "$local_md"
            fi
            rm -rf "${dir%/}"
            cp -R "$src" "${dir%/}"
            if [ -n "$local_md" ]; then
                cp "$local_md" "${dir%/}/SKILL.local.md"
                rm -f "$local_md"
            fi
            refreshed=$((refreshed+1))
            say "${GREEN}  ✓ $name refrescada desde la biblioteca${NC}"
        fi
    done
    if [ "$refreshed" -eq 0 ]; then
        say "${GREEN}  ✓ Skills instaladas al día con la biblioteca${NC}"
    else
        say ""
        say "  Reinicia Claude Code para cargar los cambios."
    fi
}

do_list() {
    local count_inst=0 count_avail=0
    local dir name

    printf "%b\n" ""
    printf "%b\n" "${BOLD}INSTALADAS${NC} ${DIM}(cargadas en Claude Code)${NC}"
    for dir in "$INST_DIR"/*/; do
        [ -d "$dir" ] || continue
        case "$dir" in *_archived*) continue ;; esac
        name="$(basename "$dir")"
        if [ -n "$(lib_path "$name")" ]; then
            printf "%b\n" "  ${GREEN}✓${NC} ${BOLD}$name${NC} ${DIM}— $(skill_desc "${dir%/}")${NC}"
        else
            printf "%b\n" "  ${GREEN}✓${NC} $name ${DIM}(core) — $(skill_desc "${dir%/}")${NC}"
        fi
        count_inst=$((count_inst+1))
    done

    printf "%b\n" ""
    printf "%b\n" "${BOLD}DISPONIBLES${NC} ${DIM}(en la biblioteca, sin coste hasta que las instalas)${NC}"
    for dir in "$LIB_DIR"/*/*/; do
        [ -d "$dir" ] || continue
        name="$(basename "$dir")"
        [ -n "$(inst_path "$name")" ] && continue
        printf "%b\n" "  ○ ${BOLD}$name${NC} ${DIM}— $(skill_desc "${dir%/}")${NC}"
        count_avail=$((count_avail+1))
    done

    printf "%b\n" ""
    printf "%b\n" "  $count_inst instaladas · $count_avail disponibles"
    printf "%b\n" "  Instalar:    ${CYAN}bash scripts/skills.sh add <nombre>${NC}  (o dile a Claude: \"instala <nombre>\")"
    printf "%b\n" "  Desinstalar: ${CYAN}bash scripts/skills.sh remove <nombre>${NC}"
    printf "%b\n" ""
}

CMD="${1:-list}"
shift || true
[ "${1:-}" = "--quiet" ] && QUIET=true

case "$CMD" in
    list)   do_list ;;
    add)
        if [ -z "${1:-}" ] || [ "${1:-}" = "--quiet" ]; then
            printf "%b\n" "${RED}Falta el nombre. Uso: bash scripts/skills.sh add <nombre>${NC}"
            exit 1
        fi
        do_add "$1"
        say ""
        say "  Reinicia Claude Code para que cargue la skill."
        ;;
    remove)
        if [ -z "${1:-}" ]; then
            printf "%b\n" "${RED}Falta el nombre. Uso: bash scripts/skills.sh remove <nombre>${NC}"
            exit 1
        fi
        do_remove "$1"
        ;;
    sync)   do_sync ;;
    -h|--help|help) grep '^#' "$0" | sed 's/^# \{0,2\}//' | head -18 ;;
    *)
        printf "%b\n" "${RED}Comando desconocido: $CMD${NC} (usa list, add, remove o sync)"
        exit 1
        ;;
esac
