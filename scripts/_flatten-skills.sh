#!/usr/bin/env bash
# ============================================================
#  iAmasters OS — _flatten-skills.sh
#
#  Migración v0.11.0: aplana .claude/skills/<categoria>/<nombre>/
#  a .claude/skills/<nombre>/, que es la ÚNICA ruta que Claude Code
#  indexa (solo mira un nivel bajo skills/). Hasta v0.10.2 el OS
#  instalaba anidado y NINGUNA skill cargaba: "Unknown skill".
#
#  Vive en su propio archivo (y no dentro de update.sh) por dos razones:
#    1. update.sh se actualiza a sí mismo durante /actualiza; bash sigue
#       ejecutando la versión ANTIGUA que ya tenía cargada, así que una
#       migración escrita ahí dentro no corre hasta el update siguiente.
#       Invocada con `bash scripts/_flatten-skills.sh` corre siempre la
#       versión recién descargada.
#    2. Se puede ejecutar suelta, que es lo que necesita quien ya tenía
#       el OS instalado antes de la v0.11.0:
#           bash scripts/_flatten-skills.sh
#
#  Es idempotente y NO borra nada: si el destino plano ya existe, la copia
#  anidada se archiva en .claude/skills/_archived/ (y se rescata antes su
#  SKILL.local.md si el destino no tiene personalización propia).
# ============================================================

set -uo pipefail

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; DIM='\033[2m'; NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILLS_DIR="$REPO_ROOT/.claude/skills"
ARCHIVE_DIR="$SKILLS_DIR/_archived"

QUIET=false
[ "${1:-}" = "--quiet" ] && QUIET=true
say() { $QUIET || printf "%b\n" "$1"; }

[ -d "$SKILLS_DIR" ] || { say "${DIM}  (no hay .claude/skills/ — nada que migrar)${NC}"; exit 0; }

STAMP="$(date +%Y%m%d%H%M%S)"
MIGRATED=0; ARCHIVED=0; RESCUED=0

# Carpetas a DOS niveles que contienen un SKILL.md = skills anidadas.
# _archived/ está anidado a propósito (así no carga): se excluye.
while IFS= read -r nested; do
    [ -n "$nested" ] || continue
    case "$nested" in *"/_archived/"*) continue ;; esac

    name="$(basename "$nested")"
    category="$(basename "$(dirname "$nested")")"
    dest="$SKILLS_DIR/$name"

    if [ -e "$dest" ]; then
        # El destino plano ya existe (normalmente lo acaba de traer el update).
        # Rescatar la personalización del operador antes de archivar la anidada.
        if [ -f "$nested/SKILL.local.md" ] && [ ! -f "$dest/SKILL.local.md" ]; then
            cp "$nested/SKILL.local.md" "$dest/SKILL.local.md"
            RESCUED=$((RESCUED+1))
            say "${CYAN}  -> $name: SKILL.local.md rescatado a la ruta nueva${NC}"
        fi
        mkdir -p "$ARCHIVE_DIR"
        mv "$nested" "$ARCHIVE_DIR/${name}-anidada-$STAMP"
        ARCHIVED=$((ARCHIVED+1))
        say "${DIM}  · $category/$name ya existía plana → copia anidada archivada${NC}"
    else
        mv "$nested" "$dest"
        MIGRATED=$((MIGRATED+1))
        say "${GREEN}  ✓ $category/$name → $name${NC} ${DIM}(ahora sí la indexa Claude Code)${NC}"
    fi

    rmdir "$SKILLS_DIR/$category" 2>/dev/null || true
done <<EOF
$(find "$SKILLS_DIR" -mindepth 2 -maxdepth 2 -type d -exec test -f '{}/SKILL.md' \; -print 2>/dev/null)
EOF

# Archivos archivados que colgaban de una categoría (<categoria>/_archived/...):
# se consolidan en .claude/skills/_archived/ para no dejar la carpeta de categoría
# como fantasma. Siguen anidados respecto a skills/, así que no se indexan.
for cat_archived in "$SKILLS_DIR"/*/_archived; do
    [ -d "$cat_archived" ] || continue
    mkdir -p "$ARCHIVE_DIR"
    for item in "$cat_archived"/*; do
        [ -e "$item" ] || continue
        target="$ARCHIVE_DIR/$(basename "$item")"
        [ -e "$target" ] && target="${target}-$STAMP"
        mv "$item" "$target"
        say "${DIM}  · archivado consolidado: $(basename "$item")${NC}"
    done
    rmdir "$cat_archived" 2>/dev/null || true
done

# Carpetas de categoría que quedaron vacías (o solo con .gitkeep)
for dir in "$SKILLS_DIR"/*/; do
    [ -d "$dir" ] || continue
    base="$(basename "$dir")"
    case "$base" in _archived) continue ;; esac
    [ -f "$dir/SKILL.md" ] && continue
    if [ -z "$(ls -A "$dir" | grep -v '^\.gitkeep$')" ]; then
        rm -f "$dir/.gitkeep"
        rmdir "$dir" 2>/dev/null || true
    fi
done

TOTAL=$((MIGRATED + ARCHIVED))
if [ "$TOTAL" -eq 0 ]; then
    say "${GREEN}  ✓ Estructura de skills correcta (un nivel) — nada que migrar${NC}"
else
    say ""
    say "${GREEN}  ✓ $MIGRATED movida(s), $ARCHIVED archivada(s), $RESCUED personalización(es) rescatada(s)${NC}"
    say "${YELLOW}  → Reinicia Claude Code para que cargue las skills${NC}"
fi

# Verificación final: si queda algo anidado, decirlo en voz alta
LEFT="$(find "$SKILLS_DIR" -mindepth 3 -name SKILL.md -not -path "*_archived*" 2>/dev/null | head -3)"
if [ -n "$LEFT" ]; then
    printf "%b\n" "${YELLOW}  ! Siguen anidadas (revísalas a mano):${NC}"
    printf "%b\n" "$LEFT"
    exit 1
fi
exit 0
