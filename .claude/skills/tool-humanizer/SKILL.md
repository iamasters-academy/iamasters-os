---
name: tool-humanizer
description: Detecta y elimina patrones de escritura AI en cualquier texto. Devuelve score 0-10 (10 = totalmente humano) y reescritura con sugerencias específicas. Usado como gate por skills marketing-* antes de entregar contenido. Invocable solo o en pipeline-mode dentro de otra skill.
---

# tool-humanizer

## Cuándo se invoca

- Cualquier skill marketing-* la llama al final como quality gate
- Usuario pega un texto y dice "humaniza esto", "quita el tono AI", "suena demasiado a ChatGPT"
- `tool-output-verifier` la incluye como uno de sus checks

## Process

### Paso 1 · Recibir input

**Modo standalone**:
- Texto pegado en chat o ruta a archivo `.md` / `.txt`

**Modo pipeline** (invocada desde otra skill):
```
{
  "text": "...",
  "context": "linkedin-post|blog|email|whatsapp|...",
  "score-only": true|false,
  "max-rewrites": 1
}
```

### Paso 2 · Análisis de patrones AI

Lee `references/ai-tells.md` y aplica los detectores:

**Detectores estructurales** (-1 cada uno):
- Em-dashes (—) en lugar de coma o paréntesis
- Listas de 3 elementos cada vez (regla de 3 abusada)
- "It's not just X, it's Y" (estructura típica GPT)
- Triple emoji al inicio o final
- Cierres con "in conclusion", "to summarize", "moving forward"

**Detectores léxicos** (-0.5 cada uno):
- "Leverage", "delve into", "navigate", "tapestry", "robust", "seamless", "synergy"
- "In today's fast-paced world", "in the realm of", "at the end of the day"
- "It's worth noting that", "it's important to note", "needless to say"
- Adverbios excesivos ("incredibly", "remarkably", "surprisingly")

**Detectores de patrón** (-1.5 cada uno):
- 3+ frases consecutivas empezando igual
- Párrafo monotemático con frases todas de longitud parecida (>20 palabras cada una)
- Negación-afirmación encadenada: "no es X, es Y. No es Z, es W"
- Bullet point con misma estructura sintáctica todo el bloque

### Paso 3 · Score

```
score = 10 - sum(penalties)
score = max(0, score)
```

Interpretación:
- 9-10 → suena humano, OK entregar
- 7-8 → aceptable pero hay tells; sugerir 2-3 cambios
- 5-6 → claramente AI; reescribir parcialmente
- 0-4 → AI slop completo; reescribir desde cero

### Paso 4 · Reescritura (si score < 7)

Aplicar reglas en orden:

1. **Eliminar muletillas léxicas** — sustituir por sinónimos específicos del contexto
2. **Romper la regla de 3** — si hay 3 elementos paralelos, dejar 2 o 4
3. **Variar arranques de frase** — alternar pronombre, verbo, conector
4. **Sustituir em-dashes** por puntos, comas o paréntesis según fluidez
5. **Aterrizar abstracciones** — frases tipo "navigate complexity" → "tomar decisiones cuando hay 5 opciones contradictorias"
6. **Romper monotonía rítmica** — alternar frases cortas (5-10 palabras) con largas (20+)
7. **Preservar la voz del operador** — leer `brand-context/voice/voice-profile.md` si existe; usar registro apropiado según `context` del input

### Paso 5 · Validación post-rewrite

Re-pasar el detector. Si tras 1 rewrite sigue < 7:
- Devolver con flag `needs_human_pass: true`
- No volver a reescribir automáticamente (riesgo de empeorar / alucinar)

### Paso 6 · Output

**Modo standalone**:
```markdown
## Score: 6.5/10

### Patrones AI detectados
- 3 em-dashes en 4 frases (-3)
- "leverage" usado 2 veces (-1)
- Lista de 3 abusada en 2 párrafos (-2)

### Versión humanizada
<texto reescrito>

### Cambios principales
- "Leverage AI" → "Usar IA"
- Em-dashes → comas y puntos
- Lista de 3 → 2 puntos directos
```

**Modo pipeline** (devuelto a la skill que llamó):
```json
{
  "score": 6.5,
  "passes_gate": false,
  "rewritten_text": "...",
  "issues": ["em-dash overuse", "leverage twice", "rule-of-three abuse"],
  "needs_human_pass": false
}
```

### Paso 7 · Cierre

- Si fue invocación standalone: mostrar comparativa al usuario
- Si fue pipeline: devolver al caller, no escribir nada más
- Append a `context/learnings.md` si detectaste un patrón AI nuevo no documentado en `ai-tells.md` (proponer expandir el detector)

## Outputs

**Standalone**: archivo en `projects/tool-humanizer/<fecha>-<titulo>/{original.md, humanized.md, report.md}`

**Pipeline**: JSON al caller, sin archivos físicos.

## Skills que llama

Ninguna. Es una tool primitiva (no orquesta nada).

## Edge cases

- **Texto muy corto (<20 palabras)**: score automático 8 (no hay suficiente para juzgar). No reescribir.
- **Idioma no castellano o inglés**: degradar a checks estructurales solo (em-dashes, longitud, listas). El léxico AI es language-specific.
- **Operador no tiene brand-voice configurada**: usar registro neutro divulgativo (B genérico). Marcar en output: "Sin voice profile cargado, resultado puede no encajar 100% con tu voz".
- **Texto poético o creativo**: las reglas de "AI slop" no aplican igual; preguntar al usuario si quiere skip humanizer.

## Examples

Ver `references/examples.md` para 3 casos: LinkedIn post, email cliente, blog post.

## Knowledge

- `references/ai-tells.md` — listado completo de patrones AI detectables (mantenido)
- `references/examples.md` — 3 casos completos antes/después con scoring
