---
name: marketing-content-repurposing
description: Convierte una pieza fuente (video YouTube, podcast, transcript reunión, blog largo) en 5-8 piezas multiplataforma respetando brand voice. Output paquete con LinkedIn post + X thread + email newsletter + Instagram caption + clips ideas + headlines blog. Invoca marketing-copywriting por cada pieza y tool-output-verifier como gate.
---

# marketing-content-repurposing

## Cuándo se invoca

- Usuario dice: "repurpose este video", "saca contenido de este podcast", "del último Café Camaleónico, sácame X piezas"
- Tras una clase / talk / video largo, automatizar la distribución
- Cuando el operador detecta un tema propio que merece amplificarse

## Process

### Paso 1 · Identificar fuente

Tipos soportados v0.2:
- **Video YouTube** (URL) → invoca `tool-youtube-transcript` (futura skill) o pide al usuario el transcript
- **Audio local** (MP3/WAV) → no soportado v0.2, pedir transcript manual
- **Transcript pegado en chat** (texto)
- **Blog post extenso** (URL o pegado) → invoca `tool-firecrawl-scraper`
- **Reunión / call** (transcript Zoom/Fathom)

Pregunta al operador:
- ¿Qué fuente?
- ¿Qué plataformas quieres priorizar?
- ¿Qué frecuencia? (1 paquete completo / spread en 2 semanas)

### Paso 2 · Análisis de la fuente

Leer transcript completo (si > 50K tokens, usar subagent para leer en chunks).

Extraer:
- **3-5 ideas core** (las que tienen más sustancia)
- **Citas memorables** (frases que se sostienen solas)
- **Stats / números** (datos concretos mencionados)
- **Story hooks** (anécdotas que se pueden extraer)
- **Counterintuitive points** (puntos que contradicen consenso)
- **Action items** (consejos accionables)

Salida intermedia (no se entrega):
```markdown
## Análisis de fuente

### Ideas core
1. ...
2. ...

### Citas memorables
- "..." (timecode si video)

### Stats
- "47% de empresas..." (timecode)

### Story hooks
- "Cuando estaba con el cliente X..."

### Counterintuitive points
- "Lo opuesto a lo que dice el consenso es: ..."

### Action items
- ...
```

### Paso 3 · Mapear a plataformas

Cada idea → plataforma(s) que mejor encajan:

| Idea | LinkedIn | X thread | Newsletter | Instagram | Reel/Short | Blog post |
|---|:-:|:-:|:-:|:-:|:-:|:-:|
| Idea 1 (insight contraintuitivo) | ✅ | ✅ | ✅ | | ✅ | |
| Idea 2 (story personal) | ✅ | | ✅ | ✅ | ✅ | |
| Idea 3 (stats) | ✅ | ✅ | | ✅ | | |
| Idea 4 (action item) | | | ✅ | ✅ | | ✅ |
| Idea 5 (cita) | ✅ | ✅ | | ✅ | ✅ | |

### Paso 4 · Generar piezas

Para cada plataforma, invocar `marketing-copywriting`:

```
marketing-copywriting:
  brief: "[Idea core mapeada]"
  platform: "linkedin"
  purpose: "thought-leadership"
  source-context: "[Resumen 1-line de la fuente]"
```

Repetir para LinkedIn post, X thread, Newsletter, Instagram caption, Reel hook + script breve, Blog headline + outline.

### Paso 5 · Validar coherencia entre piezas

Las piezas no deben ser idénticas (es repurposing, no duplicación):
- LinkedIn: storytelling completo, 1500 chars
- X thread: stats + counter-intuitive, 5-7 tweets
- Newsletter: action items + insight, 300 words
- Instagram: cita + visual, 200 chars caption
- Reel: hook 5s + payoff visual, 30s script
- Blog: deep-dive de 1 idea, headline + outline 5 H2

Comprobar que cada pieza:
- Pasa el gate (`tool-output-verifier`)
- No repite estructura idéntica de las otras
- Aporta UN ángulo distinto del mismo tema

### Paso 6 · Generar paquete entregable

```
projects/marketing-content-repurposing/<YYYY-MM-DD>-<slug-fuente>/
├── source-analysis.md          # análisis paso 2
├── platform-map.md             # mapeo paso 3
├── linkedin-post.md            # variación final + 2 alternativas
├── x-thread.md                 # tweets numerados
├── newsletter-section.md       # sección lista para insertar
├── instagram-caption.md        # con sugerencias de visual
├── reel-script.md              # hook 5s + script 30s
├── blog-outline.md             # headline + 5 H2 + intro
├── content-calendar.md         # propuesta de qué publicar cuándo
└── metadata.json               # source, scores, fechas
```

`content-calendar.md` propuesta:
- Día 1: LinkedIn post (engagement primer impulso)
- Día 2: X thread (refuerza)
- Día 3: Instagram caption (visual del tema)
- Día 4: Reel (cierra ciclo redes)
- Día 5: Newsletter (consolidación + email list)
- Día 7+: Blog post completo

### Paso 7 · Cierre

- Mostrar paquete al operador con preview
- Pedir confirmación de cuáles publicar (o ajustes)
- Append en `context/learnings.md` bajo `## marketing-content-repurposing`
- Si la fuente fue particularmente rica → sugerir guardar referencia para reusar más adelante

## Outputs

Paquete completo en `projects/marketing-content-repurposing/<fecha>-<slug>/` con 8-10 archivos.

## Skills que llama

- `tool-firecrawl-scraper` (si fuente es URL)
- `tool-youtube-transcript` (si fuente es YouTube — skill futura, manual mientras tanto)
- `marketing-copywriting` (una invocación por plataforma)
- `tool-output-verifier` (transitivo via copywriting)

## Edge cases

- **Fuente muy corta** (<500 words): repurpose tiene poco material. Generar 2-3 piezas máximo, no forzar 8.
- **Fuente sin sustancia** (charla genérica sin insights): avisar al operador "esta fuente no da para repurpose, sugerencia: graba algo más concreto".
- **Idioma de fuente ≠ idioma de outputs**: traducir + adaptar al voice profile en idioma destino. Avisar de coste calidad.
- **Fuente con info confidencial** (cliente, datos sensibles): hacer pasada de sanitización antes de generar piezas. Pedir confirmación al operador.
- **Operador pide solo 1 plataforma**: no es repurposing, derivar a `marketing-copywriting` directamente.

## Examples

Dos casos de referencia:
1. Repurpose video YouTube de 25 min sobre Claude Code → 8 piezas
2. Repurpose transcript reunión cliente sobre case study → 5 piezas con sanitización
