---
name: cache-clean
description: Limpia el tracker de uso de skills (usage-tracker.json). Elimina registros de skills retiradas y resetea contadores. Úsalo cuando el operador diga "limpiar tracker", "reset del caché", "cache clean" o quiera empezar de cero con el tracking de skills. CUIDADO: Esta acción no elimina skills instaladas, solo limpia el registro histórico.
---

# cache-clean — Limpia Tracker de Uso de Skills

## Cuándo se invoca

- Usuario dice: "limpiar tracker", "reset del caché", "cache clean"
- Usuario quiere limpiar el registro histórico de uso
- Usuario quiere empezar de cero con tracking de skills

## Qué hace

- Backup de `usage-tracker.json` → `usage-tracker.json.backup`
- Elimina registros de skills con status "retired"
- Resetea contadores
- Mantiene core skills y skills cacheadas activas

## Ejecución

```bash
# Backup
cp .claude/skills/usage-tracker.json .claude/skills/usage-tracker.json.backup

# Limpiar retiradas
tmpfile=$(mktemp)
jq 'del(.skills[] | select(.status == "retired"))' .claude/skills/usage-tracker.json > "$tmpfile"
mv "$tmpfile" .claude/skills/usage-tracker.json

echo "✅ Tracker limpiado. Registros retiradas eliminadas."
```

## Output

```
✅ cache-clean completado
Backup creado: usage-tracker.json.backup
Registros retiradas eliminadas: 5 skills
Skills activas: 45 (core + cacheadas)
```

## CUIDADO

- Esta acción NO elimina skills instaladas
- Solo limpia el registro histórico
- Si quieres reinstalar una skill retirada: `/skills install <nombre>`
