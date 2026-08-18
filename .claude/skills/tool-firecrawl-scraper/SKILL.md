---
name: tool-firecrawl-scraper
description: Wrapper de Firecrawl API para scrapear páginas web sin bot blockers. Usado por marketing-brand-voice (extraer voice samples + assets), strategy-competitor-monitor (analizar competidores), y otras skills que necesiten contenido público de URLs. Degradación graceful si no hay API key.
---

# tool-firecrawl-scraper

## Cuándo se invoca

- `marketing-brand-voice` la llama para scrapear web/LinkedIn/YouTube del operador
- `strategy-competitor-monitor` la llama para analizar competidores
- Usuario explícitamente: "scrapea esta URL", "saca el texto de esta web"

## Process

### Paso 1 · Verificar API key

Lee `.env` (variable `FIRECRAWL_API_KEY`).

- **Si existe** → usar Firecrawl API (https://api.firecrawl.dev/v1/scrape)
- **Si no existe** → degradar a fetch nativo (built-in WebFetch tool de Claude Code) y avisar:
  > "Sin Firecrawl API key. Algunas webs con bot-blockers no se podrán scrapear. Para activarlo, regístrate en https://www.firecrawl.dev (500 créditos gratis) y añade FIRECRAWL_API_KEY en .env"

### Paso 2 · Validar input

Input:
```json
{
  "urls": ["https://...", "https://..."],
  "format": "markdown|text|html",
  "extract_assets": true|false,
  "max_depth": 1
}
```

Validaciones:
- URLs son válidas (regex http(s))
- No son URLs de archivo grande (.zip, .pdf > 50MB)
- No son URLs de servicios bloqueados por TOS (linkedin.com requiere session, etc.)

### Paso 3 · Scrapear con Firecrawl

Para cada URL:

```bash
curl -X POST https://api.firecrawl.dev/v1/scrape \
  -H "Authorization: Bearer $FIRECRAWL_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "url": "<URL>",
    "formats": ["markdown", "html"],
    "onlyMainContent": true
  }'
```

Capturar:
- `data.markdown` — texto principal limpio
- `data.html` — HTML completo (si extract_assets: true)
- `data.metadata` — title, description, og:image, etc.

### Paso 4 · Extracción de assets visuales (si extract_assets: true)

Del HTML, extraer:
- Logos: `<img>` con classes/alt que contengan "logo", "brand", o `<link rel="icon">`
- Colores primarios: parse CSS o extraer de imágenes hero (proximidad a brand)
- Fuentes: parse CSS `font-family`
- Imágenes hero: primer `<img>` grande en `<header>` o `<section class="hero">`

### Paso 5 · Output

**Modo standalone**:
```
projects/tool-firecrawl-scraper/<fecha>-<dominio>/
├── content.md          # markdown principal
├── metadata.json       # title, description, OG
├── assets/             # si extract_assets
│   ├── logo.<ext>
│   └── hero.<ext>
└── colors.json         # paleta detectada
```

**Modo pipeline**: JSON con todo lo anterior.

### Paso 6 · Cierre

- Si Firecrawl devuelve error 402 (sin créditos) → avisar al usuario
- Si error 429 (rate limit) → reintentar tras delay 5s, max 3 veces
- Si error 500+ → fallback a WebFetch nativo
- Append en `context/learnings.md` si descubres URL pattern que falla consistentemente

## Outputs

**Standalone**: archivos descritos en Paso 5
**Pipeline**: JSON al caller

## Skills que llama

Ninguna. Es tool primitiva.

## Edge cases

- **URL devuelve 401/403 (login required)**: marcar como no-scrapeable. Avisar al usuario que copie/pegue contenido manualmente.
- **JS-heavy SPA con poco contenido server-side**: Firecrawl maneja esto, pero si falla, fallback no funciona. Avisar.
- **YouTube URL**: Firecrawl no extrae transcripts. Derivar a `tool-youtube-transcript` (futura skill).
- **PDF URL**: pasar a `tool-pdf-extractor` (futura skill).
- **Páginas con paywall**: detectar (HTTP 200 pero contenido < 100 chars del expected). Marcar y reportar.

## Configuración Firecrawl recomendada

En `.env`:
```
FIRECRAWL_API_KEY=fc-xxxxx
FIRECRAWL_TIMEOUT=30000      # ms (30s)
FIRECRAWL_MAX_RETRIES=3
```

Plan recomendado: **Free tier (500 créditos one-time)** o **Hobby ($16/mo, 3000 créditos/mo)**. Para uso intensivo, **Standard ($83/mo)**.

## Examples

```bash
# Operador quiere scrapear su web para brand voice
Input: { "urls": ["https://miempresa.com"], "format": "markdown", "extract_assets": true }

# Output:
# projects/tool-firecrawl-scraper/2026-05-07-miempresa-com/
#   content.md (4500 words extracted)
#   metadata.json (title, og:image)
#   assets/logo.svg, hero.jpg
#   colors.json ({primary: "#ff6b35", secondary: "#2c3e50"})
```
