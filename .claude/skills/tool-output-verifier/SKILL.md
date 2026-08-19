---
name: tool-output-verifier
description: Quality gate antes de entregar outputs al cliente. Hace 4 checks (humanizer score, brand voice match, length per platform, factuality flags) y devuelve score 0-10 con sugerencias específicas. Las skills marketing-* y operations-* la invocan automáticamente como último paso. Pasa o bloquea.
---

# tool-output-verifier

## Cuándo se invoca

- Skills marketing-copywriting, marketing-blog-writer, marketing-email-sequence, etc. la invocan en su último paso (gate obligatorio)
- Usuario pega un texto y dice "verifica esto antes de mandarlo"
- Manualmente: `/verify <ruta>` (slash command si se crea en futura versión)

## Process

### Paso 1 · Recibir input + contexto

Input mínimo:
```json
{
  "text": "...",
  "platform": "linkedin|x|blog|email|whatsapp|landing|...",
  "purpose": "post|email-cliente|email-nurture|landing-section|..."
}
```

### Paso 2 · Check 1 · Humanizer

Invoca `tool-humanizer` en pipeline-mode.
- Threshold por plataforma:
  - linkedin/blog: humanizer ≥ 7
  - email cliente premium: humanizer ≥ 8
  - email nurture / WhatsApp comunidad: humanizer ≥ 6
  - landing page (copy comercial): humanizer ≥ 8

### Paso 3 · Check 2 · Brand Voice match

Lee `brand-context/voice/voice-profile.md` y los registers (`register-a-formal.md`, `register-b-divulgativo.md`, `register-c-cercano.md`).

Detecta el registro apropiado según `platform + purpose`:
- email cliente premium → A (formal)
- propuesta comercial → A (formal)
- LinkedIn → B (divulgativo)
- blog → B (divulgativo)
- X/Twitter → B (divulgativo, más corto)
- email nurture → B con un toque cercano
- WhatsApp comunidad → C (cercano)
- comentarios redes → C (cercano)

Compara el texto vs registro esperado:
- ¿Vocabulario coincide? (palabras del registro presentes vs prohibidas)
- ¿Tono coincide? (formal vs cercano)
- ¿Longitud de frases coincide? (formal frases largas, cercano cortas)

Score 0-10 sobre brand-voice match. Threshold: ≥ 7.

### Paso 4 · Check 3 · Length per platform

Revisa límites de plataforma:

| Plataforma | Mínimo | Máximo | Ideal |
|---|---:|---:|---:|
| Twitter/X (post) | 100 chars | 280 chars | 200-260 |
| Twitter/X (thread tweet) | 100 chars | 280 chars | 220-270 |
| LinkedIn (post) | 600 chars | 3000 chars | 1200-1800 |
| LinkedIn (article) | 800 words | 2000 words | 1200-1500 |
| Blog post | 800 words | 2500 words | 1200-1800 |
| Instagram caption | 100 chars | 2200 chars | 300-700 |
| Email subject | 30 chars | 60 chars | 40-50 |
| Email body | 50 words | 600 words | 150-300 |
| WhatsApp comunidad | 50 chars | 1500 chars | 200-500 |
| Landing hero | 5 words | 12 words | 7-9 |
| Landing CTA | 2 words | 5 words | 2-3 |

Score basado en si está dentro del rango ideal, aceptable o fuera.

### Paso 5 · Check 4 · Factuality flags

Detectar afirmaciones que requieren verificación humana:
- Estadísticas con números concretos ("47%", "tripled in 2025")
- Citas atribuidas a personas o empresas
- Claims de competidores o productos
- Números de teléfono, emails, URLs específicas

Por cada flag: marcar pero NO bloquear (el operador decide). Anotar en el report.

### Paso 6 · Score combinado

```
total_score = (humanizer_score * 0.4) + (brand_voice_score * 0.4) + (length_score * 0.2)
factuality_flags = [list]
```

**Decisión final:**
- `total_score ≥ 8 AND humanizer ≥ threshold AND brand_voice ≥ 7` → ✅ pasa el gate
- Si falla cualquier threshold → ❌ no pasa, sugerencias para arreglar
- `factuality_flags` siempre se reportan, no bloquean automáticamente

### Paso 7 · Output

```markdown
## Output Verification Report

**Overall**: 7.8 / 10 → ❌ NO PASA (humanizer 6.5 < 7)

### Checks
- ✅ Length: dentro del rango ideal (1450 chars en LinkedIn post, ideal 1200-1800)
- ❌ Humanizer: 6.5 / 10 (3 em-dashes, "leverage" usado 2 veces)
- ✅ Brand voice: 8.5 / 10 (registro B divulgativo correcto)
- ⚠️ Factuality: 2 flags
  - "47% de mejora en productividad" (línea 12) — verificar fuente
  - "según Gartner 2025" (línea 18) — confirmar cita

### Sugerencias para subir humanizer
1. Sustituir em-dashes por comas o puntos
2. Cambiar "leverage" por "usar" o "aplicar" en líneas 4 y 9
3. Reescribir línea 7 ("Es no solo X, sino también Y")

### ¿Reescribimos? (sí/no)
Si dices sí, invoca tool-humanizer con max-rewrites:1.
```

### Paso 8 · Pipeline-mode (cuando otra skill llama)

Si `score-only: true`, devolver solo:
```json
{
  "passes_gate": false,
  "score": 7.8,
  "humanizer": 6.5,
  "brand_voice": 8.5,
  "length": 9.0,
  "factuality_flags": [...],
  "blocking_reason": "humanizer below threshold (6.5 < 7)"
}
```

La skill caller decide:
- Reintentar con tool-humanizer
- Aceptar score si no es bloqueante
- Devolver al usuario con warning

### Paso 9 · Cierre

- Append a `context/learnings.md` si detectaste:
  - Patrón de fallo recurrente en una skill ("marketing-copywriting siempre falla humanizer en email")
  - Configuración de threshold inadecuada para una plataforma

## Outputs

**Standalone**:
- `projects/tool-output-verifier/<fecha>-<titulo>/report.md`

**Pipeline**: JSON al caller.

## Skills que llama

- `tool-humanizer` (siempre, paso 2)

## Edge cases

- **No hay brand-voice configurada**: skip Check 2, baja peso a 30% humanizer + 30% brand-voice (que devuelve 5 default) + 40% length. Marcar warning.
- **Plataforma desconocida**: usar defaults (humanizer ≥ 7, length flexible). Pedir al usuario clarificar plataforma.
- **Texto multi-idioma**: validar cada idioma por separado, dar score promedio.
- **Threshold conflicting con purpose**: ej. email "personal a un amigo" no requiere humanizer 8. Pedir al usuario que confirme purpose si humanizer falla por threshold.

## Examples

Ver `references/examples.md` para casos completos.

## Knowledge

- `references/platform-limits.md` — tabla mantenida de límites por plataforma
- `references/examples.md` — casos pase / fallo / borderline
