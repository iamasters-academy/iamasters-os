---
name: cache-status
description: Muestra el estado del sistema de caché de skills. Lista skills instaladas, cuándo se usaron por última vez, cuáles están cacheadas, cuáles pueden retirarse y el ahorro de tokens. Úsalo cuando el operador diga "estado del caché", "qué skills tengo instaladas", "skills status", "diagnóstico de skills" o quiera ver qué skills están ocupando contexto.
---

# cache-status — Estado del Caché de Skills

## Cuándo se invoca

- Usuario dice: "estado del caché", "¿qué skills tengo?", "skills status", "diagnóstico de skills"
- Usuario quiere ver qué skills están ocupando contexto
- Usuario pregunta por el sistema de caché

## Output

Genera un reporte con:

1. **Resumen ejecutivo**
   - Skills instaladas (total)
   - Skills cacheadas (no-core)
   - Skills que pueden retirarse (no usadas 7+ días)
   - Ahorro de tokens si se retiran

2. **Detalle por skill**
   - Nombre
   - Categoría (marketing, tools, etc.)
   - Último uso
   - Días sin uso
   - Estado (core, cached, retire-pending)
   - Tamaño (tokens)

3. **Recomendaciones**
   - Skills que considerar retirar manualmente
   - Skills frecuentes que deberían quedarse
   - Oportunidades de optimización

## Ejecución

```bash
#!/bin/bash
echo "=== Estado del Caché de Skills ==="
echo ""

TRACKER_FILE=".claude/skills/usage-tracker.json"
CURRENT_DATE=$(date +%Y-%m-%d)
RETIRE_DAYS=7

# Verificar tracker
if [ ! -f "$TRACKER_FILE" ]; then
  echo "❌ Tracker no encontrado: $TRACKER_FILE"
  echo "El tracker se creará al usar skills por primera vez."
  echo ""
  echo "Skills instaladas:"
  find .claude/skills -name "SKILL.md" -type f | wc -l
  exit 0
fi

echo "📊 Skills instaladas: $(find .claude/skills -name "SKILL.md' -type f | wc -l)"
echo ""

# Contar por categoría
echo "📂 Por categoría:"
for cat in _meta automation marketing strategy tools visualization; do
  count=$(find ".claude/skills/$cat" -name "SKILL.md" -type f 2>/dev/null | wc -l)
  if [ "$count" -gt 0 ]; then
    echo "  $cat: $count skills"
  fi
done
echo ""

# Skills cacheadas (no core)
echo "💾 Skills cacheadas (no core):"
cached_count=0
retire_pending_count=0
total_cached_tokens=0

for skill_dir in .claude/skills/*/.; do
  [ -d "$skill_dir" ] || continue

  skill_name=$(basename "$skill_dir")

  # Ignorar core
  [ "$skill_name" == "_meta" ] && continue

  # Buscar en tracker
  skill_data=$(jq -r --arg skill "$skill_name" '.skills[skill_name]' "$TRACKER_FILE" 2>/dev/null || echo "{}")

  if [ -n "$skill_data" ] && [ "$skill_data" != "null" ]; then
    status=$(echo "$skill_data" | jq -r '.status // "unknown"')
    last_used=$(echo "$skill_data" | jq -r '.last_used // "Nunca"')

    if [ "$status" = "cached" ]; then
      cached_count=$((cached_count + 1))

      # Calcular días desde último uso
      if [ "$last_used" != "Nunca" ]; then
        last_epoch=$(date -d "$last_used" +%s 2>/dev/null || echo "0")
        current_epoch=$(date +%s)
        days_since_use=$(( (current_epoch - last_epoch) / 86400 ))
        time_ago="hace $days_since_use días"
      else
        time_ago="Sin datos"
      fi

      # Calcular tamaño
      skill_file="$skill_dir/SKILL.md"
      if [ -f "$skill_file" ]; then
        size_bytes=$(wc -c < "$skill_file" 2>/dev/null || echo "0")
        tokens=$((size_bytes / 4))
        total_cached_tokens=$((total_cached_tokens + tokens))
      else
        tokens=0
      fi

      echo "  📦 $skill_name"
      echo "     Último uso: $last_used ($time_ago)"
      echo "     Tokens: ~$tokens"

      # Marcar para retirar si aplica
      if [ "$days_since_use" -ge "$RETIRE_DAYS" ]; then
        echo "     ⚠️  Puede retirarse (no usada $days_since_use días)"
        retire_pending_count=$((retire_pending_count + 1))
      fi
      echo ""
    fi
  fi
done

echo "---"
echo "📈 Resumen:"
echo "  Skills cacheadas: $cached_count"
echo "  Pendientes de retirar: $retire_pending_count"
echo "  Tokens ocupados por caché: ~$total_cached_tokens"
echo ""

if [ "$retire_pending_count" -gt 0 ]; then
  echo "💡 Recomendación:"
  echo "  Ejecuta '/skills cache-retire' para retirar skills no usadas"
  echo "  Ahorro esperado: ~$((retire_pending_count * 2000)) tokens (est.)"
fi

echo ""
echo "✅ Estado del caché reportado."
```
