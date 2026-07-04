---
name: legal-compliance
description: Evalúa cumplimiento de privacidad (RGPD/CCPA) — revisa DPAs, mapea tratamientos de datos, responde derechos de acceso (DSR) y marca riesgos de protección de datos. Úsala cuando el operador diga "¿cumplo RGPD?", "revisa este DPA", "un usuario pide sus datos", "mapea qué datos trato" o gestione datos personales de jugadores o clientes. Es análisis de apoyo, no dictamen legal.
---

# legal-compliance

> **Adaptación iAmasters OS** — Portada de `anthropics/knowledge-work-plugins` (plugin legal, Apache-2.0).
> Self-contained. **Distinta de [[tool-web-legal-audit]]**: aquella audita una web (cookies/trackers);
> esta cubre **RGPD/CCPA a nivel de tratamiento de datos** (DPAs, DSR, mapeo). Encaja con agencia
> (datos de jugadores UE) y clientes (p. ej. clínica Jesús: datos de salud, categoría especial). **No es
> dictamen legal.**

## Cuándo se invoca
- El operador dice "¿cumplo RGPD?", "revisa este DPA", "un usuario pide sus datos", "mapea qué datos trato".
- Gestiona datos personales de jugadores o clientes, o va a firmar un encargo de tratamiento.

## Process

### Paso 1 · Encuadrar el caso
- Determina rol (responsable/encargado), datos tratados (¿categoría especial, p. ej. salud?), base legal, finalidad, y si hay transferencias/subencargados.
- **Validación**: mapa mínimo del tratamiento (qué datos, por qué, con quién).

### Paso 2 · Evaluar / responder según el trigger
- **Revisar DPA**: comprueba cláusulas clave (objeto, medidas de seguridad, subencargados, borrado, auditoría). Marca lo que falte 🔴.
- **DSR (derecho de acceso/borrado)**: verifica identidad, plazos (1 mes RGPD), y prepara la respuesta.
- **Mapeo**: lista tratamientos + base legal + riesgos.
- **Validación**: salida concreta según el caso (DPA anotado / respuesta DSR / mapa de tratamientos).

### Paso 3 · Riesgos + recomendaciones
- Prioriza 🔴🟠🟡 (falta base legal, categoría especial sin salvaguardas, transferencia internacional sin garantías). Recomienda acciones.
- Guarda en `projects/legal-compliance/<YYYY-MM-DD>-<caso>/`. Recuerda disclaimer. Append en `context/learnings.md` bajo `## legal-compliance`.

## Outputs
- DPA anotado / respuesta DSR / mapa de tratamientos con riesgos 🔴🟠🟡, en la carpeta del proyecto.

## Skills que llama
- **`legal-contract-review`** — si el DPA va dentro de un contrato mayor.
- **`tool-web-legal-audit`** — si además hay una web pública (cookies/trackers).

## Edge cases
- **Datos de salud u otra categoría especial** (cliente clínica) → salvaguardas reforzadas; recomienda revisión profesional.
- Transferencia fuera de la UE → exige garantías (SCC/adecuación); márcalo 🔴 si faltan.
- Caso de alto riesgo / sanción potencial → deriva a asesoría legal; no cierres tú el dictamen.

## Examples

Ver `references/examples.md`.
