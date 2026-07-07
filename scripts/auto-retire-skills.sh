#!/bin/bash
# auto-retire-skills.sh — Retira skills no usadas en 7 días
# Uso: bash scripts/auto-retire-skills.sh [--dry-run]

set -e

DRY_RUN=false
if [ "$1" == "--dry-run" ]; then
  DRY_RUN=true
  echo "🔍 MODO SIMULACIÓN: No se eliminarán skills"
fi

TRACKER_FILE=".claude/skills/usage-tracker.json"
RETIRE_DAYS=7
CURRENT_DATE=$(date +%Y-%m-%d)

echo "=== Auto-Retire de Skills ==="
echo "Fecha: $CURRENT_DATE"
echo "Límite: ${RETIRE_DAYS} días sin uso"
echo ""

# Verificar que el tracker existe
if [ ! -f "$TRACKER_FILE" ]; then
  echo "❌ Tracker no encontrado: $TRACKER_FILE"
  echo "Se creará tracker vacío al primer uso."
  exit 0
fi

# Leer skills del tracker
INSTALLED_SKILLS=$(find .claude/skills -name "SKILL.md" -type f | wc -l)
echo "Skills instaladas: $INSTALLED_SKILLS"
echo ""

COUNT_RETIRED=0
COUNT_KEPT=0

# Iterar sobre skills instaladas (solo SKILL.md reales)
for skill_file in $(find .claude/skills -mindepth 3 -name "SKILL.md" -type f); do
  # Extraer nombre de skill desde la ruta: .claude/skills/<categoria>/<skill>/SKILL.md
  skill_path=$(dirname "$skill_file")
  skill_name=$(basename "$skill_path")

  # Ignorar core _meta
  [[ "$skill_name" == "_meta" ]] && continue

  # Buscar en tracker
  last_used=$(jq -r --arg skill_name "$skill_name" '.skills[skill_name].last_used // empty' "$TRACKER_FILE" 2>/dev/null || echo "")

  if [ -z "$last_used" ]; then
    # Skill sin registro, nueva instalación
    echo "⏳ $skill_name: Sin registro (se acaba de instalar)"
    continue
  fi

  # Calcular días desde último uso
  if command -v date &> /dev/null; then
    last_epoch=$(date -d "$last_used" +%s 2>/dev/null || echo "0")
    current_epoch=$(date +%s)
    days_since_use=$(( (current_epoch - last_epoch) / 86400 ))
  else
    days_since_use=999
  fi

  if [ "$days_since_use" -ge "$RETIRE_DAYS" ]; then
    echo "🗑️  $skill_name: No usada ${days_since_use} días → RETIRAR"

    if [ "$DRY_RUN" = false ]; then
      # Mover a biblioteca
      bash scripts/skills.sh remove "$skill_name" 2>/dev/null || echo "  ⚠️ Error al retirar $skill_name"

      # Actualizar tracker: marcar como retirada
      tmpfile=$(mktemp)
      jq --arg skill_name "$skill_name" '.skills[skill_name].status = "retired"' "$TRACKER_FILE" > "$tmpfile"
      mv "$tmpfile" "$TRACKER_FILE"
    fi

    COUNT_RETIRED=$((COUNT_RETIRED + 1))
  else
    echo "✓ $skill_name: Usada hace ${days_since_use} días → MANTENER"
    COUNT_KEPT=$((COUNT_KEPT + 1))
  fi
done

echo ""
echo "=== Resumen ==="
echo "Retiradas: $COUNT_RETIRED skills"
echo "Mantenidas: $COUNT_KEPT skills"
echo ""

if [ "$DRY_RUN" = true ]; then
  echo "🔍 Simulación completa. Ejecuta sin --dry-run para aplicar cambios."
else
  echo "✅ Auto-retire completo. Tracker actualizado."
fi

exit 0
