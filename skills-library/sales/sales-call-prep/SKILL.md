---
name: sales-call-prep
description: Prepara llamadas de ventas/descubrimiento (contexto de la cuenta, investigación del asistente, agenda sugerida, preguntas de descubrimiento) y, tras la llamada, extrae action items, siguiente paso y borrador de follow-up. Úsala cuando el operador diga "prepárame esta llamada", "voy a hablar con un cliente potencial", "resume esta call y sácame los siguientes pasos" o gestione su pipeline de captación IA-PYMEs.
---

# sales-call-prep

> **Adaptación iAmasters OS** — Portada de `anthropics/knowledge-work-plugins` (plugin sales, Apache-2.0).
> Self-contained (mejora con CRM/Calendar MCP, opcional). Puente al OS: cubre un hueco real (no había
> skill de call-prep) del frente **consultoría IA-PYMEs** (cerrar los 2 clientes en validación). No
> solapa con [[marketing-prospecting]]/[[marketing-cold-email]] (esas son outreach en frío); esta es la
> preparación y el post de la conversación. Se apoya en [[strategy-web-research]] para investigar la cuenta.

## Cuándo se invoca
- El operador dice "prepárame esta llamada", "voy a hablar con un cliente potencial", "resume esta call y sácame los siguientes pasos".
- Antes de una reunión de descubrimiento/venta, y justo después para capturar acuerdos.

## Process

### Paso 1 (PRE) · Preparar la llamada
- Reúne: contexto de la cuenta (web/sector/tamaño — usa [[strategy-web-research]] si falta), asistentes y su rol, objetivo de la llamada.
- Genera: agenda sugerida + preguntas de descubrimiento (dolor, presupuesto, decisor, plazo) + hipótesis de valor.
- **Validación**: brief de 1 pantalla con agenda + preguntas listo antes de la reunión.

### Paso 2 (POST) · Resumir y extraer
- A partir de notas/transcripción: extrae action items (con responsable), siguiente paso acordado, objeciones surgidas, y redacta un borrador de follow-up.
- **Validación**: lista de action items + siguiente paso claro + email de follow-up en borrador.

### Paso 3 · Cierre
- Guarda en `projects/sales-call-prep/<YYYY-MM-DD>-<cuenta>/`. Si hay pipeline que actualizar, enlaza con [[sales-pipeline-forecast]]. Append en `context/learnings.md` bajo `## sales-call-prep`.

## Outputs
- PRE: brief de preparación (agenda + preguntas). POST: action items + siguiente paso + borrador de follow-up. En la carpeta del proyecto.

## Skills que llama
- **`strategy-web-research`** — investigar la cuenta/asistentes si falta contexto.
- **`marketing-sales-enablement`** — material de apoyo (one-pager, respuestas a objeciones).
- **`sales-pipeline-forecast`** — actualizar el pipeline tras la llamada.

## Edge cases
- Sin contexto de la cuenta → investiga primero ([[strategy-web-research]]); no improvises la agenda.
- Es outreach en frío a desconocidos → eso es [[marketing-cold-email]]/[[marketing-prospecting]], no esta.
- Follow-up a cliente → pásalo por voz de marca antes de enviar.

## Examples

Ver `references/examples.md`.
