---
name: tool-scrape-router
description: Analiza un trabajo de scraping/crawling, elige la mejor herramienta open-source gratis por matriz de decisión (Firecrawl, Playwright, Crawl4AI, Scrapling, Scrapy, ScrapeGraphAI, Colly, Katana, Maxun, Browserless + Apify MCP) y ejecuta la extracción con escalada de coste cero. Úsala cuando el operador diga "scrapea/extrae datos de esta web", "crawlea este sitio", "qué herramienta uso para scrapear X", "saca estos datos a escala" o "convierte esta web en datos/API".
---

# tool-scrape-router

> **Skill del OS (router)** — el cerebro de scraping: clasifica el trabajo, elige herramienta y ejecuta.
> **No fusiona** con [[tool-firecrawl-scraper]] (queda enfocado): cuando gana Firecrawl, delega en él.
> Catálogo completo de herramientas (cuándo usar / setup / free tier / lenguaje) en `references/toolbox.md`;
> matriz de decisión en `references/decision-matrix.md`. Filosofía: **empezar por lo gratis y simple,
> escalar solo si falla** — no montar Playwright para bajar una página estática.

## Cuándo se invoca
- El operador dice "scrapea/extrae datos de esta web", "crawlea este sitio", "qué herramienta uso para X", "saca estos datos a escala", "convierte esta web en API".
- Otra skill necesita datos web que el fetch nativo no puede sacar (JS, anti-bot, escala, extracción estructurada).

## Process

### Paso 1 · Clasificar el trabajo (ejes)
Determina, preguntando lo mínimo si falta:
- **Render**: ¿HTML estático o requiere ejecutar JavaScript?
- **Escala**: ¿1 página, un puñado, o crawl masivo (cientos/miles)?
- **Extracción**: ¿texto/markdown crudo, o campos estructurados concretos?
- **Anti-bot**: ¿el sitio bloquea/tiene selectores frágiles?
- **Interacción**: ¿login, clicks, scroll, formularios, screenshots/PDF?
- **Consumo**: ¿para IA/RAG (markdown limpio), para BBDD (pipeline), o no-code (cliente)?
- **Dominio**: ¿web genérica, red social (IG/TikTok/YT), o recon/URLs?
- **Stack**: ¿preferencia Python/Go? ¿coste = 0 obligatorio?
- **Validación**: perfil del trabajo resumido en 1 línea por eje.

### Paso 2 · Elegir herramienta (matriz)
Cruza el perfil con `references/decision-matrix.md`. Resumen:
- 1 página estática → **WebFetch nativo** → si bloquea, **Firecrawl**.
- Markdown limpio para IA/RAG → **Firecrawl** (vía [[tool-firecrawl-scraper]]) o **Crawl4AI** (local, gratis).
- JS pesado / login / clicks / screenshots → **Playwright** (o **Browserless** como servicio API).
- "Describe qué quieres" (extracción por prompt) → **ScrapeGraphAI**.
- Selector frágil / anti-bot → **Scrapling** (auto-repara).
- Crawl masivo + pipelines a BBDD → **Scrapy** (Python) o **Colly** (Go, ultrarrápido).
- Recon / descubrir todas las URLs / bug bounty → **Katana**.
- No-code point-and-click (para cliente) → **Maxun**.
- Redes sociales (IG/TikTok/YT) → **Apify MCP** (ya conectado).
- **Validación**: 1 herramienta elegida (o 2 si el trabajo tiene fases) + el porqué en 1 frase.

### Paso 3 · Ejecutar (con escalada)
- Si gana **Firecrawl** → invoca [[tool-firecrawl-scraper]] (no reimplementes).
- Si gana otra → aplica su bloque de `references/toolbox.md` (setup runtime + comando) y ejecútala. Keys en `.env`, NUNCA commiteadas.
- **Escalera de escalado** (coste 0 primero): WebFetch nativo → Firecrawl free / Crawl4AI local → Playwright / Scrapling (JS/anti-bot) → Apify MCP. Sube un peldaño solo si el anterior falla; **documenta por qué subiste**.
- **Validación**: datos extraídos con la estructura pedida; si algo se bloqueó, se dice explícitamente (no inventar).

### Paso 4 · Entregar + cerrar
- Guarda en `projects/tool-scrape-router/<YYYY-MM-DD>-<sitio>/` (datos + qué herramienta se usó + por qué).
- **Respeto legal/ToS**: robots.txt, rate limits, sin datos personales sin base legal, sin sitios que lo prohíban en sus términos. Ante duda, para y pregunta.
- Append en `context/learnings.md` bajo `## tool-scrape-router` (qué herramienta rindió para qué tipo de sitio).

## Outputs
- `projects/tool-scrape-router/<YYYY-MM-DD>-<sitio>/` con los datos extraídos + nota de herramienta/escalada usada.

## Skills que llama
- **`tool-firecrawl-scraper`** — ejecución cuando Firecrawl es la mejor opción.
- **`strategy-web-research`** / **`investigacion-mercado`** — si el objetivo es investigar, no solo extraer datos crudos.
- **Apify MCP** (`apify--instagram-scraper`, `clockworks--tiktok-scraper`, etc.) — scraping de redes sociales.

## Edge cases
- Datos personales / sitio que prohíbe scraping en ToS → NO scrapear; avisa y propón fuente/API oficial.
- Sitio con login del operador → solo con sus credenciales y consentimiento; Playwright con sesión.
- Red social → casi siempre Apify MCP gana a montar Playwright a mano.
- Trabajo puntual de 1 página → no montes Scrapy/Playwright; WebFetch o Firecrawl bastan (evita over-engineering).

## Examples

Ver `references/toolbox.md` (catálogo), `references/decision-matrix.md` (matriz) y `references/examples.md` (casos).
