# sales-pipeline-forecast — Ejemplos

## Ejemplo 1 · Revisión mensual

**Operador**: "Aquí está mi pipeline en CSV, ¿cuánto cierro este mes?"

**Flujo**:
1. 8 deals cargados. Diagnóstico: 2 🔴 con fecha de cierre pasada, 3 🟠 single-threaded.
2. Previsión: worst 4k / likely 9k / best 15k; commit 6k. Objetivo 12k → **gap de 3k** al likely.
3. Top 3 acciones: reactivar los 2 estancados (con `sales-call-prep`), multi-threading en los 3 🟠.

## Ejemplo 2 · Pipeline flaco

**Operador**: "Tengo 2 deals, hazme la previsión."

**Flujo**:
1. Con 2 deals la previsión ponderada no es fiable. Se dice claro y se redirige a llenar el funnel
   (`marketing-prospecting`) en vez de fabricar un número.

## Nota

Standalone con CSV; con un CRM conectado se automatiza la carga. Honestidad con el rango: no maquillar
el gap ni confundir upside (posible) con commit (comprometido).
