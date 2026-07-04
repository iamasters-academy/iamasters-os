---
name: legal-contract-review
description: Revisa un contrato contra un playbook de posiciones, marca desviaciones, genera redlines y explica el impacto de negocio de cada cláusula. Úsala cuando el operador diga "revisa este contrato", "analiza este acuerdo de jugador/sponsor", "márcame las cláusulas problemáticas", "genera redlines" o reciba un contrato antes de firmar. NO sustituye a un abogado colegiado — es análisis de apoyo.
---

# legal-contract-review

> **Adaptación iAmasters OS** — Portada de `anthropics/knowledge-work-plugins` (plugin legal, Apache-2.0).
> Self-contained (sin MCP obligatorio). Puente al OS: el "playbook" de posiciones estándar vive en
> `references/playbook.md` (edítalo con tus defaults como agencia FIFA). **Aviso legal**: es análisis de
> apoyo para negociar mejor informado, **no asesoría jurídica** — un contrato relevante lo valida un
> abogado colegiado. Encaja con el frente **agencia de representación** (contratos jugador/sponsor/agente).

## Cuándo se invoca
- El operador dice "revisa este contrato", "analiza este acuerdo de jugador/sponsor", "márcame cláusulas problemáticas", "genera redlines".
- Recibe un contrato (representación, patrocinio, servicios, MSA de cliente) antes de firmar.

## Process

### Paso 1 · Cargar contrato y playbook
- Lee el contrato y `references/playbook.md` (posiciones por defecto: fees, exclusividad, duración, rescisión, cláusulas de salida, responsabilidad, jurisdicción).
- **Validación**: contrato leído; playbook cargado (o creado si no existe, preguntando defaults al operador).

### Paso 2 · Detectar desviaciones + clasificar
- Compara cláusula a cláusula contra el playbook. Clasifica cada desviación: 🔴 inaceptable · 🟠 negociar · 🟡 aceptable con nota.
- Para cada una, explica el **impacto de negocio** en lenguaje llano (qué te cuesta / a qué te obliga).
- **Validación**: lista de desviaciones con clasificación + impacto.

### Paso 3 · Redlines + resumen ejecutivo
- Propón redline (texto alternativo) para las 🔴/🟠. Genera resumen: riesgos top, qué pedir, qué ceder.
- **Validación**: redlines accionables + resumen de 1 página.

### Paso 4 · Cierre
- Guarda en `projects/legal-contract-review/<YYYY-MM-DD>-<contraparte>/`. Recuerda el disclaimer (validar con abogado). Append en `context/learnings.md` bajo `## legal-contract-review`.

## Outputs
- `projects/legal-contract-review/<YYYY-MM-DD>-<contraparte>/` con: tabla de desviaciones 🔴🟠🟡, redlines, resumen ejecutivo.

## Skills que llama
- **`legal-nda-triage`** — si el documento es un NDA, deriva (triaje rápido).
- **`legal-compliance`** — si hay tratamiento de datos personales (DPA/RGPD).

## Edge cases
- Sin playbook → créalo con el operador (defaults de agencia) antes de revisar; sin criterio no hay desviación.
- Contrato de alto riesgo/valor → recomienda explícitamente revisión de abogado colegiado; no lo firmes por él.
- Idioma/jurisdicción extranjera → marca lo que dependa de derecho local como "verificar con abogado local".

## Examples

Ver `references/examples.md`. Playbook editable en `references/playbook.md`.
