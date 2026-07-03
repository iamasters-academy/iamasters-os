---
name: marketing-copywriting
description: Genera copy para una plataforma específica (LinkedIn post, X thread, email, landing section, ad) usando brand-voice y registers A/B/C automáticamente. Úsala cuando el usuario diga o pida "escríbeme/redacta/hazme un post de LinkedIn", "un tweet" o "un hilo de X", "un email", "un anuncio", "una sección de landing", "un headline", "copy para…", o pida cualquier texto de marketing para una plataforma. Pasa por tool-output-verifier obligatoriamente antes de entregar. Devuelve 1-3 variaciones para que el operador elija. La skill estrella del módulo marketing.
---

# marketing-copywriting

## Cuándo se invoca

- Usuario dice: "escribe un post de LinkedIn sobre X", "redacta un email para Y", "necesito copy de landing"
- Otra skill (`marketing-content-repurposing`) la llama tras procesar contenido fuente
- `marketing-email-sequence` la usa para cada email del flow

## Process

### Paso 1 · Validar inputs y detectar plataforma

Inputs requeridos:
- **Tema o brief** (qué quieres comunicar)
- **Plataforma** (LinkedIn, X, blog, email, landing, etc.)
- **Purpose** (post de awareness, lead gen, recordatorio, oferta...)

Si falta plataforma → preguntar
Si falta purpose → preguntar (cambia el tono)
Si falta tema → preguntar concreto

### Paso 2 · Cargar contexto

Leer:
1. `brand-context/voice/voice-profile.md` — voz del operador
2. Registro apropiado según plataforma:
   - email cliente premium / propuesta → `register-a-formal.md`
   - LinkedIn / blog / X / video script → `register-b-divulgativo.md`
   - WhatsApp / DM / comentario → `register-c-cercano.md`
3. `brand-context/positioning/positioning.md` — diferencial a comunicar
4. `brand-context/icp/icp.md` — quién va a leer (lenguaje, dolor, buying triggers)

Si falta brand-context → avisar al operador y proponer ejecutar `marketing-brand-voice` antes (o continuar con disclaimer "no-brand-voice mode").

### Paso 3 · Estructura por plataforma

Aplicar plantilla de plataforma:

#### LinkedIn post
```
[Hook 1-2 líneas — afirmación contundente o pregunta directa]

[Contexto personal — "Llevo X meses..." / "He visto...". Aporta credibilidad]

[Insight principal — la lección o el insight. 1-2 párrafos]

[Detalle concreto — números, ejemplos, gotchas]

[Cierre — pregunta abierta o llamada a algo concreto]
```

Longitud objetivo: 1200-1800 chars (verificable con `tool-output-verifier`).

#### X / Twitter thread
```
1/ [Hook fuerte. Promise specific outcome o reveal counterintuitive]

2/ [Setup del problema o context]

3-N/ [Cada tweet aporta UN punto, max 240 chars]

Last/ [Cierre con CTA suave: "What's your take?" / "Save for later"]
```

Cada tweet ~220-260 chars.

#### Email cliente (registro A)
```
Asunto: [Específico, no genérico]

[Saludo cálido pero formal según relación]

[Contexto inmediato — "Tras nuestra reunión del...", "Como te mencioné..."]

[Cuerpo — sin rodeos. 3 párrafos máximo]

[Cierre con próximo paso concreto]

[Firma]
```

#### Landing hero
- Headline: 7-9 palabras, claim diferencial del positioning
- Subheadline: 15-25 palabras, especificar para quién y qué
- CTA primary: 2-3 palabras, verbo de acción
- CTA secondary: 3-5 palabras, "ver demo / ver casos"

### Paso 4 · Generar 2-3 variaciones

Por defecto, generar 3 variaciones (con etiquetas de ángulo):

**Variación 1 — Storytelling**: arranca con anécdota personal/cliente
**Variación 2 — Insight contraintuitivo**: arranca con algo que el lector no espera
**Variación 3 — Problema → solución**: arranca describiendo el dolor del ICP

Cada variación:
- Aplica el voice-profile + register correcto
- Respeta longitud de plataforma
- Incluye números concretos cuando sea posible
- Tiene hook claro y cierre intencional

### Paso 5 · Pasar por gate (obligatorio)

Para CADA variación, invoca `tool-output-verifier` en pipeline-mode:

```json
{
  "text": "<variación>",
  "platform": "linkedin",
  "purpose": "post"
}
```

Si alguna variación falla el gate (`passes_gate: false`):
- Si humanizer < threshold → reintentar UNA vez con tool-humanizer en rewrite mode
- Si brand-voice < 7 → reescribir aplicando voice-profile más estrictamente
- Si length out of range → ajustar longitud
- Si tras 1 retry sigue fallando → marcar variación con ⚠️ y dejar al operador decidir

### Paso 6 · Output

```markdown
## 3 variaciones para LinkedIn post · "Tema X"

### Variación 1 · Storytelling — score 9.0/10 ✅
[Texto]

**Hook**: anécdota personal
**Estructura**: setup → revelación → lección
**CTA**: pregunta abierta sobre experiencia del lector

---

### Variación 2 · Insight contraintuitivo — score 8.5/10 ✅
[Texto]

**Hook**: afirmación que sorprende
**Estructura**: claim → evidencia → matiz
**CTA**: invitación a discrepar

---

### Variación 3 · Problema/solución — score 7.5/10 ⚠️ humanizer 6.8 (1 reintento usado)
[Texto]

**Notas**: Sigue teniendo 2 em-dashes. Sugerencia: revisarlo manualmente antes de publicar.

---

¿Cuál te quedas? ¿O quieres que mezcle 2?
```

### Paso 7 · Iteración con feedback

Si el operador pide ajustes:
- "Más corto" → reduce 30%
- "Más cercano" → cambia a registro C parcialmente
- "Cambia el hook" → genera 2 hooks alternativos
- "No me convence el cierre" → 3 cierres alternativos

Aplicar y volver a verificar (Paso 5).

### Paso 8 · Cierre

- Guardar versión final del operador en `projects/marketing-copywriting/<YYYY-MM-DD>-<slug>/post.md`
- Si el operador pidió cambios significativos → append en `context/learnings.md` bajo `## marketing-copywriting`
- Si detectaste un patrón nuevo en feedback → proponer en wrap-up actualizar voice-profile o registers

## Outputs

- `projects/marketing-copywriting/<fecha>-<slug>/`:
  - `post.md` — versión final
  - `variations.md` — todas las variaciones generadas
  - `metadata.json` — plataforma, purpose, scores

## Skills que llama

- `tool-output-verifier` (obligatorio, paso 5)
- `tool-humanizer` (transitivo via output-verifier, o directo en rewrite)

## Edge cases

- **Sin brand-voice configurado**: warning + modo "neutro divulgativo" + sugerir ejecutar `marketing-brand-voice` antes.
- **Plataforma no en lista**: usar plantilla genérica + advertir.
- **Operador pide algo contra positioning** (ej. atacar segmento que es ICP): preguntar si está seguro, si dice sí, generarlo pero flagear.
- **Tema sensible** (política, religión, etc.): generar pero advertir que las plataformas pueden afectar visibilidad.
- **Output requerido en idioma distinto al voice-profile**: marcar low-confidence; recomendar revisar manualmente.

## Examples

Ver `references/examples.md` para casos LinkedIn, X thread, email, landing hero.
