# Anti-detección con opciones gratis

> Para sitios que bloquean. Todo esto es **gratis** y de "buen ciudadano". Antes de pelear con
> anti-bot: pregúntate si hay **API oficial** o si los ToS lo prohíben (entonces, no scrapear).

## Medidas gratis (por orden de esfuerzo)
1. **User-Agent realista** — el runner ya manda uno de Chrome. Rota entre 3-4 UAs si un sitio filtra por UA.
2. **Delays con jitter** — no dispares en ráfaga; 1-5 s aleatorios entre requests. Evita bloqueos por rate y no tumbas el servidor.
3. **Retry con backoff** — ante 429/503, reintenta 2-3 veces doblando la espera. No martillees.
4. **Sesión/cookies** — reusar cookies de la primera respuesta (httpx `Client` persistente) pasa muchos muros ligeros.
5. **Headers completos** — `Accept-Language`, `Referer` coherente, `Accept` como un navegador real.

## Cuándo NO montar proxies caseros
- **Proxies gratis = poco fiables** (lentos, caídos, a veces maliciosos). Para trabajo serio, los residenciales de calidad son **de pago** — sé honesto con esto, no prometas magia gratis.
- Antes que un pool de proxies casero, **escala a herramienta con anti-bot incluido**:
  - **Firecrawl** (API, anti-bot gestionado) — vía [[tool-firecrawl-scraper]].
  - **Scrapling** (evasión + auto-reparación de selectores).
  - **Apify MCP** (infra gestionada; casi siempre gana para redes sociales y sitios duros).

## Escalera anti-bot
```
UA + delays + retry (runner/manual)  →  Scrapling  →  Firecrawl  →  Apify MCP
```
Sube solo si el anterior sigue bloqueado. Documenta en el `manifest.json` qué se probó.

## Límite ético/legal (no negociable)
- Respeta `robots.txt` y los ToS. Si el sitio prohíbe scraping, **no** lo hagas: busca API/dataset oficial.
- Nada de resolver CAPTCHAs de pago, ni suplantar login de terceros, ni saltarte paywalls.
- Datos personales → base legal (RGPD). Ante duda, para y pregunta.
