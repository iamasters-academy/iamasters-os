---
name: sales-pipeline-forecast
description: Analiza la salud del pipeline de ventas (deals estancados, sin fecha de cierre, single-threaded) y genera una previsión ponderada (best/likely/worst, commit vs upside, gap a objetivo). Úsala cuando el operador diga "revisa mi pipeline", "haz una previsión de ventas", "qué deals priorizo", "cuánto voy a cerrar este mes" o gestione su cartera de oportunidades de consultoría.
---

# sales-pipeline-forecast

> **Adaptación iAmasters OS** — Portada de `anthropics/knowledge-work-plugins` (plugin sales, Apache-2.0).
> Standalone con CSV (rinde más con un CRM MCP, futuro). Puente al OS: encaja con el frente
> **consultoría IA-PYMEs**; se alimenta de las llamadas de [[sales-call-prep]]. Complementa
> [[marketing-revops]] (procesos de lead lifecycle) con la foto de previsión y priorización.

## Cuándo se invoca
- El operador dice "revisa mi pipeline", "haz una previsión", "qué deals priorizo", "cuánto cierro este mes".
- Revisión periódica de la cartera de oportunidades.

## Process

### Paso 1 · Cargar el pipeline
- Recoge los deals (CSV, tabla pegada, o export de CRM): nombre, importe, etapa, probabilidad, fecha de cierre, última actividad, nº de contactos.
- **Validación**: lista de deals con los campos mínimos (importe + etapa + fecha).

### Paso 2 · Diagnóstico de salud
- Marca riesgos por deal: 🔴 estancado (sin actividad reciente), 🔴 fecha de cierre pasada, 🟠 single-threaded (un solo contacto), 🟠 sin siguiente paso.
- Prioriza dónde actuar.
- **Validación**: cada deal con estado + riesgos + acción sugerida.

### Paso 3 · Previsión ponderada
- Calcula best / likely / worst y commit vs upside (ponderando por etapa/probabilidad). Compara contra el objetivo → **gap**.
- **Validación**: número de previsión con rango + gap explícito.

### Paso 4 · Cierre
- Guarda en `projects/sales-pipeline-forecast/<YYYY-MM-DD>/`. Recomienda las 3 acciones de mayor impacto. Append en `context/learnings.md` bajo `## sales-pipeline-forecast`.

## Outputs
- Diagnóstico por deal (🔴🟠🟡) + previsión best/likely/worst + gap a objetivo + top 3 acciones.

## Skills que llama
- **`sales-call-prep`** — para mover los deals estancados (preparar la próxima llamada).
- **`marketing-revops`** — si el problema es de proceso/lifecycle, no de deals sueltos.

## Edge cases
- Pipeline vacío / 1-2 deals → la previsión estadística no aporta; enfócate en llenar el funnel ([[marketing-prospecting]]).
- Datos sin fecha/probabilidad → pídelos antes de forzar una previsión (sería inventada).
- No confundir upside con commit → sé honesto con el rango; no maquilles el gap.

## Examples

Ver `references/examples.md`.
