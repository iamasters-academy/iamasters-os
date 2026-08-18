#!/bin/bash
# ============================================================
#  iAmasters OS — validate-skill.sh
#  Descarga y valida una skill desde GitHub antes de instalarla
#  Uso: bash scripts/validate-skill.sh <github-url>
# ============================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'
BOLD='\033[1m'

# Paths
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

URL="${1:-}"

if [ -z "$URL" ]; then
    echo -e "${RED}ERROR${NC} Falta URL de GitHub"
    echo "Uso: bash scripts/validate-skill.sh <github-url>"
    echo "Ejemplo: bash scripts/validate-skill.sh https://github.com/user/repo/tree/main/skills/my-skill"
    exit 1
fi

# Generate temp dir
HASH=$(echo "$URL" | shasum | cut -c1-12)
TMP_DIR="/tmp/iamasters-os-skill-validate-$HASH"
rm -rf "$TMP_DIR"
mkdir -p "$TMP_DIR"

echo ""
echo -e "${BLUE}[1/5]${NC} Descargando skill desde GitHub..."

# Parse GitHub URL: https://github.com/user/repo/tree/branch/path/to/skill
# Or: https://github.com/user/repo
# Strategy: git clone + cd al subpath
GH_REGEX='https://github.com/([^/]+)/([^/]+)(/tree/([^/]+)(/(.*))?)?'
if [[ "$URL" =~ $GH_REGEX ]]; then
    OWNER="${BASH_REMATCH[1]}"
    REPO_NAME="${BASH_REMATCH[2]}"
    BRANCH="${BASH_REMATCH[4]:-main}"
    SUBPATH="${BASH_REMATCH[6]:-}"
    GIT_URL="https://github.com/$OWNER/$REPO_NAME.git"
    echo -e "${CYAN}  Repo:${NC} $OWNER/$REPO_NAME @ $BRANCH"
    [ -n "$SUBPATH" ] && echo -e "${CYAN}  Subpath:${NC} $SUBPATH"
else
    echo -e "${RED}  ERROR${NC} URL no parece de GitHub válida"
    exit 1
fi

# Shallow clone
git clone --depth 1 --branch "$BRANCH" "$GIT_URL" "$TMP_DIR/repo" 2>&1 | tail -3

# Resolve skill path
if [ -n "$SUBPATH" ]; then
    SKILL_PATH="$TMP_DIR/repo/$SUBPATH"
else
    SKILL_PATH="$TMP_DIR/repo"
fi

if [ ! -d "$SKILL_PATH" ]; then
    echo -e "${RED}  ERROR${NC} Subpath no existe: $SUBPATH"
    rm -rf "$TMP_DIR"
    exit 1
fi

echo -e "${GREEN}  OK${NC} Skill descargada en $SKILL_PATH"

# ── Step 2: Check structure ──
echo -e "${BLUE}[2/5]${NC} Validando estructura..."

ERRORS=()
WARNINGS=()
OK_CHECKS=()

# Find SKILL.md
SKILL_MD=""
if [ -f "$SKILL_PATH/SKILL.md" ]; then
    SKILL_MD="$SKILL_PATH/SKILL.md"
elif [ -f "$SKILL_PATH/skill.md" ]; then
    SKILL_MD="$SKILL_PATH/skill.md"
else
    ERRORS+=("No se encontró SKILL.md en la raíz de la skill")
fi

if [ -n "$SKILL_MD" ]; then
    OK_CHECKS+=("SKILL.md presente")

    # Check YAML frontmatter
    if head -n 1 "$SKILL_MD" | grep -q '^---$'; then
        OK_CHECKS+=("YAML frontmatter inicia correctamente")
    else
        ERRORS+=("YAML frontmatter no inicia con --- en línea 1")
    fi

    # Extract name and description from frontmatter
    SKILL_NAME=$(awk '/^name:/{print $2}' "$SKILL_MD" | head -n 1)
    SKILL_DESC=$(awk '/^description:/{ $1=""; print substr($0,2) }' "$SKILL_MD" | head -n 1)

    # Validate name
    if [ -z "$SKILL_NAME" ]; then
        ERRORS+=("Campo 'name' ausente o vacío")
    elif [[ ! "$SKILL_NAME" =~ ^[a-z][a-z0-9-]*$ ]]; then
        ERRORS+=("Campo 'name' debe ser kebab-case ([a-z][a-z0-9-]*): '$SKILL_NAME'")
    else
        OK_CHECKS+=("name='$SKILL_NAME' es kebab-case válido")
    fi

    # Validate description
    DESC_LEN=${#SKILL_DESC}
    if [ "$DESC_LEN" -lt 30 ]; then
        ERRORS+=("'description' demasiado corta ($DESC_LEN chars, mínimo 30)")
    elif [ "$DESC_LEN" -lt 50 ]; then
        WARNINGS+=("'description' corta ($DESC_LEN chars). Recomendado 50-500. Puede afectar activación.")
    elif [ "$DESC_LEN" -gt 500 ]; then
        WARNINGS+=("'description' larga ($DESC_LEN chars). Recomendado 50-500. Puede inflar contexto del system prompt.")
    else
        OK_CHECKS+=("description $DESC_LEN chars (en rango)")
    fi

    # Check verbs of intention
    if echo "$SKILL_DESC" | grep -qiE '\b(crea|genera|analiza|extrae|escribe|audita|valida|detecta|resume|traduce|busca|investiga|monitoriza|construye|formatea|create|generate|analyze|extract|write|validate|detect|build)\b'; then
        OK_CHECKS+=("description contiene verbo de intención")
    else
        WARNINGS+=("description no parece tener verbo de intención claro. Puede afectar activación.")
    fi

    # Check skill size
    SKILL_MD_SIZE=$(wc -c < "$SKILL_MD")
    if [ "$SKILL_MD_SIZE" -gt 10000 ]; then
        WARNINGS+=("SKILL.md grande ($SKILL_MD_SIZE chars > 10000). Considera mover knowledge a references/")
    fi

    # Check references/ exists if SKILL.md large
    if [ "$SKILL_MD_SIZE" -gt 5000 ] && [ ! -d "$SKILL_PATH/references" ]; then
        WARNINGS+=("SKILL.md medio-grande sin references/ folder. Buen patrón es separar knowledge")
    fi
fi

# Check scripts for safety
DANGEROUS_PATTERNS=()
if find "$SKILL_PATH" -name "*.sh" -o -name "*.py" 2>/dev/null | grep -q .; then
    while IFS= read -r script; do
        if grep -qE 'rm -rf /|rm -rf ~|sudo rm|>\s*/dev/sda|dd if=|mkfs\.|wget [^|]*\| sh|curl [^|]*\| sh|eval\s*\(\s*\$' "$script"; then
            DANGEROUS_PATTERNS+=("$(basename "$script")")
        fi
    done < <(find "$SKILL_PATH" -name "*.sh" -o -name "*.py" 2>/dev/null)
fi

if [ ${#DANGEROUS_PATTERNS[@]} -gt 0 ]; then
    ERRORS+=("Scripts con patrones peligrosos: ${DANGEROUS_PATTERNS[*]}")
else
    OK_CHECKS+=("No hay scripts con patrones destructivos obvios")
fi

# Check for hardcoded secrets
SECRET_FILES=()
while IFS= read -r f; do
    if grep -qE '(api[_-]?key|secret|token|password)\s*=\s*["'"'"'][a-zA-Z0-9_-]{20,}' "$f" 2>/dev/null; then
        SECRET_FILES+=("$(basename "$f")")
    fi
done < <(find "$SKILL_PATH" -type f \( -name "*.md" -o -name "*.sh" -o -name "*.py" -o -name "*.json" \))

if [ ${#SECRET_FILES[@]} -gt 0 ]; then
    WARNINGS+=("Posibles credenciales hardcoded en: ${SECRET_FILES[*]}")
else
    OK_CHECKS+=("Sin credenciales hardcoded detectadas")
fi

# ── Step 3: Check conflict with local skills ──
echo -e "${BLUE}[3/5]${NC} Comprobando conflictos con skills locales..."

CONFLICT=false
if [ -n "$SKILL_NAME" ]; then
    # Search recursively in .claude/skills/
    EXISTING=$(find "$REPO_ROOT/.claude/skills" -type d -name "$SKILL_NAME" 2>/dev/null | head -n 1)
    if [ -n "$EXISTING" ]; then
        CONFLICT=true
        WARNINGS+=("Ya existe skill local con nombre '$SKILL_NAME' en: ${EXISTING/$REPO_ROOT/}")
    else
        OK_CHECKS+=("Sin conflicto de nombre con skills locales")
    fi
fi

# ── Step 4: Report ──
echo -e "${BLUE}[4/5]${NC} Reporte de validación..."
echo

echo -e "${BOLD}Skill:${NC} ${SKILL_NAME:-?}"
echo -e "${BOLD}Description:${NC} ${SKILL_DESC:-?}"
echo
echo -e "${BOLD}URL:${NC} $URL"
echo -e "${BOLD}Tamaño SKILL.md:${NC} ${SKILL_MD_SIZE:-?} chars"
echo

if [ ${#OK_CHECKS[@]} -gt 0 ]; then
    echo -e "${GREEN}${BOLD}✓ OK ($((${#OK_CHECKS[@]})))${NC}"
    for c in "${OK_CHECKS[@]}"; do
        echo -e "  ${GREEN}✓${NC} $c"
    done
    echo
fi

if [ ${#WARNINGS[@]} -gt 0 ]; then
    echo -e "${YELLOW}${BOLD}⚠ WARNINGS ($((${#WARNINGS[@]})))${NC}"
    for w in "${WARNINGS[@]}"; do
        echo -e "  ${YELLOW}⚠${NC} $w"
    done
    echo
fi

if [ ${#ERRORS[@]} -gt 0 ]; then
    echo -e "${RED}${BOLD}✗ ERRORS ($((${#ERRORS[@]})))${NC}"
    for e in "${ERRORS[@]}"; do
        echo -e "  ${RED}✗${NC} $e"
    done
    echo
fi

# ── Step 5: Verdict + next steps ──
echo -e "${BLUE}[5/5]${NC} Veredicto"

if [ ${#ERRORS[@]} -gt 0 ]; then
    echo -e "${RED}${BOLD}NO PASA${NC} - Errores bloqueantes detectados."
    echo "  La skill NO debe instalarse hasta corregir los errores."
    echo
    echo -e "Skill descargada en: ${CYAN}$SKILL_PATH${NC}"
    echo "  Inspecciónala manualmente si quieres."
    rm -rf "$TMP_DIR" 2>/dev/null || true
    exit 1
elif [ ${#WARNINGS[@]} -gt 0 ]; then
    echo -e "${YELLOW}${BOLD}PASA CON WARNINGS${NC}"
    echo "  La skill puede instalarse pero revisa los warnings."
else
    echo -e "${GREEN}${BOLD}PASA LIMPIO${NC}"
    echo "  La skill cumple todos los checks."
fi

echo
echo -e "${BOLD}Para instalar (si decides hacerlo):${NC}"
if $CONFLICT; then
    echo -e "  ${YELLOW}Hay conflicto de nombre. Decide:${NC}"
    echo -e "  1) Reemplazar local: ${CYAN}cp -r $SKILL_PATH .claude/skills/$SKILL_NAME/${NC}"
    echo -e "     (haz backup primero!)"
    echo -e "  2) Instalar con nombre distinto: edita SKILL.md frontmatter 'name:' y luego copia"
else
    echo -e "  ${CYAN}cp -r $SKILL_PATH .claude/skills/$SKILL_NAME/${NC}"
    echo -e "  Donde <categoria> es: _meta, marketing, operations, strategy, tools, visualization"
fi
echo
echo -e "${BOLD}Tras instalar:${NC}"
echo -e "  1) Update synapsis/skills-catalog.json con nueva entrada"
echo -e "  2) Reinicia Claude Code (Ctrl+C × 2 + claude)"
echo -e "  3) Prueba activación con prompt típico de la skill"
echo -e "  4) Ejecuta /wrap-up para registrar el cambio"
echo
echo "Skill descargada en: $SKILL_PATH (no se elimina automáticamente)"
