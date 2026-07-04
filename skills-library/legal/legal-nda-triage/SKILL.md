---
name: legal-nda-triage
description: Clasifica un NDA en VERDE/AMARILLO/ROJO en minutos según criterios estándar (unilateral/mutuo, duración, alcance, no-competencia encubierta, jurisdicción) y recomienda firmar/negociar/escalar. Úsala cuando el operador diga "revisa este NDA", "¿puedo firmar este acuerdo de confidencialidad?", "triaje de NDA" o reciba un NDA de un club/sponsor/cliente. Es pre-cribado, no asesoría legal.
---

# legal-nda-triage

> **Adaptación iAmasters OS** — Portada de `anthropics/knowledge-work-plugins` (plugin legal, Apache-2.0).
> Self-contained. Puente al OS: pre-cribado rápido; si el NDA es complejo o de alto valor, escala a
> [[legal-contract-review]] (análisis a fondo) y/o a abogado. Encaja con agencia FIFA (NDAs de clubes/
> sponsors) y consultoría (NDAs de cliente). **No es asesoría jurídica.**

## Cuándo se invoca
- El operador dice "revisa este NDA", "¿puedo firmar este acuerdo de confidencialidad?", "triaje de NDA".
- Recibe un NDA de club, sponsor, cliente o partner y necesita decidir rápido.

## Process

### Paso 1 · Extraer los criterios clave
- Identifica: unilateral vs mutuo, duración de la obligación, definición de "información confidencial" (¿demasiado amplia?), no-competencia/no-solicitación encubierta, jurisdicción/ley aplicable, penalizaciones.
- **Validación**: los 6 criterios localizados en el texto (o marcados como ausentes).

### Paso 2 · Clasificar 🟢🟡🔴
- **🟢 VERDE** (firmar): mutuo o unilateral razonable, duración acotada, alcance normal, jurisdicción OK.
- **🟡 AMARILLO** (negociar): 1-2 puntos a ajustar (duración larga, alcance amplio).
- **🔴 ROJO** (escalar): no-competencia encubierta, cesión de derechos, penalizaciones desproporcionadas, jurisdicción hostil.
- **Validación**: veredicto único + los motivos que lo justifican.

### Paso 3 · Recomendación
- 🟢 → firmar. 🟡 → los 1-2 cambios a pedir. 🔴 → escalar a [[legal-contract-review]] o abogado; no firmar tal cual.
- Guarda en `projects/legal-nda-triage/<YYYY-MM-DD>-<contraparte>/`. Append en `context/learnings.md` bajo `## legal-nda-triage`.

## Outputs
- Veredicto 🟢🟡🔴 + motivos + recomendación (1 pantalla) en la carpeta del proyecto.

## Skills que llama
- **`legal-contract-review`** — para los 🔴 o NDAs complejos (análisis a fondo).
- **`legal-compliance`** — si el NDA cubre tratamiento de datos personales.

## Edge cases
- NDA mezclado con otras cláusulas (es en realidad un contrato) → deriva a [[legal-contract-review]].
- Alto valor / contraparte grande → aunque salga 🟢, sugiere una lectura de abogado.
- Jurisdicción/idioma extranjero → marca "verificar con abogado local".

## Examples

Ver `references/examples.md`.
