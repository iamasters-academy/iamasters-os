# tool-scrape-router — Ejemplos

## Ejemplo 1 · Página estática simple (empieza barato)

**Operador**: "Sácame el texto de este artículo de blog."

**Flujo**:
1. Clasificación: estático · 1 página · texto crudo · sin anti-bot.
2. Matriz → **WebFetch nativo** (peldaño 1). Extrae el markdown. FIN sin montar nada.
3. Si hubiera devuelto vacío/bloqueo → escala a Firecrawl (delegando en `tool-firecrawl-scraper`).

## Ejemplo 2 · SPA con login (JS + interacción)

**Operador**: "Extrae la tabla de precios de este panel que requiere iniciar sesión."

**Flujo**:
1. Clasificación: JS/SPA · login · datos estructurados (tabla).
2. Matriz → **Playwright** (con la sesión del operador y su consentimiento). Navega, hace login,
   espera el render, extrae la tabla.
3. Datos a `projects/tool-scrape-router/2026-07-04-panel-precios/` + nota "Playwright: requería login+JS".

## Ejemplo 3 · Extracción por prompt (estructurada)

**Operador**: "De estas 20 fichas de producto quiero nombre, precio y stock, sin pelearme con selectores."

**Flujo**:
1. Clasificación: pocas páginas · extracción estructurada compleja · "describe qué quieres".
2. Matriz → **ScrapeGraphAI** (LLM key en `.env`). Prompt: "extrae {nombre, precio, stock}". Devuelve JSON.
3. 20 páginas = coste LLM asumible. Si fueran 100k → se reevaluaría a Scrapy con selectores fijos.

## Ejemplo 4 · Red social

**Operador**: "Bájame los últimos posts de esta cuenta de Instagram."

**Flujo**:
1. Clasificación: red social.
2. Matriz → **Apify MCP** (`apify--instagram-scraper`), NO Playwright a mano. Free tier.

## Ejemplo 5 · Crawl masivo

**Operador**: "Crawlea las 5.000 fichas de este directorio a una BBDD."

**Flujo**:
1. Clasificación: masivo · estático · pipeline a BBDD.
2. Matriz → **Scrapy** (pipelines, throttling, reintentos). Si necesitara velocidad extrema y stack Go → Colly.
3. Respeto: robots.txt + rate limit para no tumbar el directorio.

## Nota

Siempre la mínima herramienta que resuelve el trabajo, empezando por lo gratis. Y respeto legal/ToS:
si el sitio prohíbe scraping o hay datos personales sin base legal, parar y avisar.
