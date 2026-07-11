# Matriz de decisión — qué herramienta para qué trabajo

> **Capability-aware**: primero `py -3 scripts/scrape.py --probe`. Elige entre lo **instalado**; si la
> mejor opción no está, o la instalas o bajas de peldaño. La matriz de abajo es el ideal; el probe manda.

## Árbol de decisión (rápido)

```
¿Es una red social (IG/TikTok/YT)?
  └─ Sí → Apify MCP (actor específico). FIN.
  └─ No ↓

¿Necesitas ejecutar JavaScript / login / clicks / screenshots?
  └─ Sí → Playwright (local)  |  Browserless (si quieres API/servicio)  ↓ (extracción tras render)
  └─ No ↓

¿Extracción estructurada compleja "describe qué quieres"?
  └─ Sí → ScrapeGraphAI (pocas páginas; cuesta LLM)
  └─ No ↓

¿Escala? 
  ├─ 1 página        → WebFetch nativo → (si bloquea) Firecrawl
  ├─ Markdown p/ IA  → Firecrawl (skill) | Crawl4AI (local gratis)
  └─ Crawl masivo    → Scrapy (Python, pipelines) | Colly (Go, velocidad)

¿El sitio bloquea / los selectores se rompen?  → Scrapling (auto-repara)
¿Solo mapear URLs / recon?                     → Katana
¿Que lo maneje un no-programador (cliente)?    → Maxun (no-code)
¿Stack Java existente o Chrome-only en Node?   → Selenium (Java) / Puppeteer (Node). Si no, Playwright.
¿Prototyping interactivo dentro de Claude?     → chrome-devtools MCP / playwright MCP (sin código)
```

## Matriz por ejes

| Eje del trabajo | Valor | Herramienta preferida | Alternativa |
|---|---|---|---|
| Render | Estático | WebFetch → Firecrawl | Crawl4AI |
| Render | JS/SPA | Playwright | Browserless |
| Escala | 1 página | WebFetch | Firecrawl |
| Escala | Crawl masivo | Scrapy | Colly (Go) |
| Extracción | Markdown/IA | Firecrawl | Crawl4AI |
| Extracción | Campos estructurados por prompt | ScrapeGraphAI | Playwright+parse |
| Anti-bot | Bloqueo/selector frágil | Scrapling | Firecrawl (anti-bot) → Apify |
| Interacción | Login/clicks/PDF/screenshot | Playwright | Browserless |
| Dominio | Red social | Apify MCP | — |
| Objetivo | Recon/URLs | Katana | — |
| Usuario | No-code/cliente | Maxun | — |
| Stack | Go / máxima velocidad | Colly | Katana |
| Stack | Java/legacy existente | Selenium | Playwright (si migras) |
| Stack | Node/Chrome-only | Puppeteer | Playwright (multi-browser) |
| Contexto | Prototyping en Claude | chrome-devtools/playwright MCP | Playwright (producción) |

## Forma del dato → formato de salida (`--format`)
| Lo que sacas | Formato | Nota |
|---|---|---|
| Artículo / texto principal | `markdown` | rung 1 trafilatura; por defecto |
| Campos concretos (nombre/precio/stock) | `json` | ScrapeGraphAI o parse propio |
| Tabla | `json` (o CSV al post-procesar) | tras render si es JS |
| Fichero ya descargado (PDF/DOCX) | `markdown` | MarkItDown, no es scraping web |

## Escalera de escalado (coste 0 primero)

1. **WebFetch nativo** (0 setup, 0 coste) — página estática.
2. **Firecrawl free** (skill) / **Crawl4AI local** — markdown limpio, anti-bot ligero.
3. **Playwright / Scrapling** — JS pesado / anti-bot fuerte / interacción.
4. **Apify MCP** — redes sociales u otros que sigan bloqueando.

Sube un peldaño **solo si el anterior falla**, y **documenta por qué** (bloqueo, JS, escala). No
arranques en el peldaño 3 para un trabajo del peldaño 1.

## Límites y legalidad (siempre)
- Respeta `robots.txt` y los ToS del sitio. Algunos prohíben scraping explícitamente → no hacerlo.
- Rate limits / throttling para no tumbar el servidor.
- Datos personales → base legal (RGPD). Ante duda, para y pregunta; propón API oficial si existe.
