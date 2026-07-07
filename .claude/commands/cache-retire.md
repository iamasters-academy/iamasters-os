---
name: cache-retire
description: Ejecuta manualmente el auto-retiro de skills. Revisa skills instaladas (no core), calcula días desde último uso y retira las no usadas en 7+ días. Úsalo cuando el operador diga "retir skills", "limpiar el caché", "retir skills no usadas" o quiera forzar la limpieza de skills cacheadas. Alias de bash: '/skills cache-retire'.
---

# cache-retire — Ejecutar Auto-Retire de Skills Manual

## Cuándo se invoca

- Usuario dice: "retir skills", "limpiar el caché", "retir skills no usadas"
- Usuario quiere ejecutar auto-retire manualmente (sin esperar meta-wrap-up)

## Ejecución

```bash
bash scripts/auto-retire-skills.sh
```

## Qué hace

- Revisa skills instaladas (excluyendo core `_meta/`)
- Lee `usage-tracker.json` para ver última vez usada
- Calcula días desde último uso
- Si > 7 días sin uso → retira (mueve a biblioteca)
- Actualiza tracker con status: "retired"

## Output

```
=== Auto-Retire de Skills ===
Fecha: 2025-01-15
Límite: 7 días sin uso

🗑️  automation-n8n-builder: No usada 8 días → RETIRAR
✓ marketing-copywriting: Usada ayer → MANTENER
✓ theme-factory: Usada hace 3 días → MANTENER

=== Resumen ===
Retiradas: 1 skills
Mantenidas: 2 skills
✅ Auto-retire completo. Tracker actualizado.
```
