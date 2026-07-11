# tool-scrape-router — Ejemplos

## Ejemplo 0 · Preflight (probe)

```
$ py -3 scripts/scrape.py --probe
{ "python": "3.14.2", "httpx": true, "trafilatura": true,
  "crawl4ai": false, "playwright": true, "firecrawl_key": false, ... }
```
→ Hay rung 1 (httpx+trafilatura) y Playwright; no hay Crawl4AI ni key de Firecrawl. El router
enruta entre esas.

## Ejemplo 1 · Página estática (runner, empieza barato)

**Operador**: "Sácame el texto de este artículo de blog."

**Flujo**:
1. Clasificación: estático · 1 página · texto · sin anti-bot.
2. `py -3 scripts/scrape.py --url <URL> --out ./out`. Rung 1 (httpx+trafilatura) resuelve.
3. `out/manifest.json` deja la traza:
```json
{ "url": "...", "tool_used": "httpx+trafilatura",
  "ladder_tried": [{"rung": "httpx+trafilatura", "ok": true}],
  "robots_allowed": true, "chars": 4210, "http_status": 200 }
```
Si hubiera fallado, el runner escala solo (Firecrawl→Crawl4AI→Playwright) y lo anota en `ladder_tried`.

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

## Ejemplo 6 · Caso del operador — ficha de jugador (FVI)

**Operador**: "Sácame los datos de esta ficha de Transfermarkt de un jugador."

**Flujo**:
1. Preflight + robots. Clasificación: web pública · datos semi-estructurados.
2. `py -3 scripts/scrape.py --url <ficha> --out ./out --format markdown`. Rung 1 suele bastar; si
   Transfermarkt bloquea (anti-bot) → el runner escala a Firecrawl (si hay key) o se aplica
   `anti-detection.md` (UA/delays) → si sigue duro, Apify.
3. Datos + `manifest.json` a `projects/tool-scrape-router/2026-07-04-tm-jugador/`. Se encadena con
   `investigacion-mercado`/análisis FVI. **Nada de datos de pago o contra ToS.**

## Nota

Siempre la mínima herramienta que resuelve el trabajo, empezando por lo gratis. Y respeto legal/ToS:
si el sitio prohíbe scraping o hay datos personales sin base legal, parar y avisar.
