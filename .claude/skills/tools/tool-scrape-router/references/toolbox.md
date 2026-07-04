# Toolbox de scraping — fichas por herramienta

> Todas open-source y con opción gratis. Keys/servicios en `.env`, NUNCA commitear. El router elige
> por `decision-matrix.md`; aquí está el "cómo" de cada una.

## Ya en el OS (usar primero)
- **WebFetch nativo** — built-in de Claude Code. HTML→markdown de 1 URL pública. **0 setup, 0 coste.**
  Primer peldaño SIEMPRE para páginas estáticas simples. Falla con JS pesado / anti-bot.
- **`tool-firecrawl-scraper`** (skill core) — wrapper de **Firecrawl**. Markdown limpio, `onlyMainContent`,
  crawl. Degrada a WebFetch si no hay `FIRECRAWL_API_KEY` (500 créditos free). El router **delega aquí**
  cuando gana Firecrawl.
- **Apify MCP** (ya conectado) — actores listos: `apify--instagram-scraper`, `clockworks--tiktok-scraper`,
  `streamers--youtube-scraper`, `apify--website-content-crawler`, `apify--rag-web-browser`. **Redes
  sociales → esto** (no montar Playwright a mano). Free tier mensual.

## Las 10 del reel

### 1. Firecrawl — API unificada, markdown para IA
- **Cuándo**: contexto web limpio para IA/RAG, crawl a escala, 1 llamada→web entera. Anti-bot incluido.
- **Setup**: usar la skill `tool-firecrawl-scraper` (API) o self-host (`firecrawl` repo, Docker).
- **Free**: 500 créditos; self-host gratis. **Gana** para markdown-para-IA salvo que quieras 100% local → Crawl4AI.

### 2. Playwright (Microsoft) — navegador real
- **Cuándo**: JS pesado, login, clicks, scroll infinito, formularios, screenshots/PDF, HTML renderizado. Chromium/Firefox/WebKit.
- **Setup**: `pip install playwright` / `npm i playwright` + `playwright install`. Local, gratis.
- **Gotcha**: más pesado; no lo uses para 1 página estática.

### 3. Crawl4AI (unclecode/crawl4ai) — crawler LLM-friendly
- **Cuándo**: crawl que devuelve **markdown listo para RAG**, 100% local y gratis. Alternativa a Firecrawl sin key.
- **Setup**: `pip install crawl4ai` + `crawl4ai-setup` (instala navegador). Python.

### 4. Scrapling (D4Vinci/Scrapling) — adaptativo / anti-bot
- **Cuándo**: el sitio bloquea o los **selectores se rompen** al cambiar el HTML ("se arregla solo"). De request simple a crawl completo.
- **Setup**: `pip install scrapling`. Python. Bueno como escalón anti-bot antes de Apify.

### 5. Scrapy — crawling clásico a escala
- **Cuándo**: crawl **masivo** de sitios estáticos con **pipelines** a BBDD, throttling, reintentos. Robusto y probado.
- **Setup**: `pip install scrapy` → `scrapy startproject`. Python. No ejecuta JS por sí solo (combinar con Playwright si hace falta).

### 6. ScrapeGraphAI — extracción por prompt (LLM+grafos)
- **Cuándo**: "**describe qué quieres** y que la IA encuentre los selectores". Extracción estructurada sin escribir XPath.
- **Setup**: `pip install scrapegraphai`. Necesita **LLM key** (o modelo local Ollama). Python.
- **Gotcha**: coste de LLM por página; ideal para pocas páginas con extracción compleja, no para millones.

### 7. Colly (gocolly/colly) — Go, ligero y concurrente
- **Cuándo**: scrapers **rápidos** de sitios estáticos, alta concurrencia, binario ligero. Si el stack es Go o quieres velocidad máxima.
- **Setup**: `go get github.com/gocolly/colly/v2`. Go.

### 8. Katana (projectdiscovery/katana) — recon / URLs
- **Cuándo**: **descubrir todas las URLs/endpoints** de un sitio (recon, bug bounty, mapear superficie). Headless y no-headless.
- **Setup**: `go install .../katana` o binario. Go. **No** es para extraer datos de negocio, sino para mapear.

### 9. Maxun (getmaxun/maxun) — no-code, web→API
- **Cuándo**: **no-code** point-and-click; que un cliente o no-programador defina el scraper; convertir web en API estructurada.
- **Setup**: self-host (Docker). Plataforma con UI.

### 10. Browserless — Chrome headless como servicio
- **Cuándo**: **screenshots/PDF/HTML a escala** vía API sin montar tu granja de navegadores. Sobre Puppeteer.
- **Setup**: self-host (Docker) o su cloud. Alternativa "servicio" a Playwright local.

## Regla de oro
Elige la MÍNIMA herramienta que resuelve el trabajo. Estático→WebFetch/Firecrawl. JS→Playwright.
Estructurado→ScrapeGraphAI. Masivo→Scrapy/Colly. Social→Apify. No sobre-ingenierices.
