---
name: marketing-viral-radar
description: Monitoriza qué se está viralizando en el nicho (TikTok/Instagram vía Apify, Reddit, Google Trends), lo cruza con la marca y el ICP, y devuelve "qué publicar esta semana" con ángulos y formatos. Úsala cuando el operador diga "qué se está viralizando en mi nicho", "qué publico esta semana", "dame tendencias para contenido", "radar viral" o quiera ideas basadas en lo que funciona ahora, no en intuición.
---

# marketing-viral-radar

> **Skill del OS** — consolida piezas sueltas en un radar de tendencias (idea núcleo de sistemas tipo
> Claura). Puente al OS: usa **Apify MCP** (IG/TikTok), [[tool-scrape-router]] (Reddit/Google Trends) y
> `brand-context/`+ICP; su salida alimenta [[marketing-content-strategy]] → cadena de contenido. NO es
> estrategia editorial completa (eso es content-strategy) ni escribe el contenido — señala **qué** decir ahora.

## Cuándo se invoca
- El operador dice "qué se está viralizando en mi nicho", "qué publico esta semana", "dame tendencias para contenido", "radar viral".
- Arranque semanal del motor de contenido (antes de `marketing-content-strategy`).

## Process

### Paso 1 · Definir nicho y fuentes
- Recoge nicho/tema, plataformas objetivo y cuentas/hashtags/subreddits de referencia (usa `brand-context/`+ICP si existen).
- **Validación**: nicho + fuentes concretas listadas.

### Paso 2 · Recoger señales (multi-fuente)
- **IG/TikTok** → Apify MCP (`apify--instagram-scraper`, `clockworks--tiktok-scraper`): posts/reels con más engagement reciente.
- **Reddit / Google Trends** → [[tool-scrape-router]] (respetando robots/ToS): temas al alza, preguntas frecuentes.
- **Validación**: set de señales con métricas (engagement, recencia) por fuente.

### Paso 3 · Cruzar y priorizar
- Detecta patrones (formatos, hooks, ángulos, audios) que se repiten y **encajan con la marca/ICP** (descarta lo viral irrelevante).
- Prioriza por: relevancia al nicho · momentum · encaje de marca · facilidad de producir.
- **Validación**: top de tendencias accionables, no un volcado de datos.

### Paso 4 · Entregar "qué publicar esta semana"
- Salida: 5-10 recomendaciones con **ángulo + formato + gancho + plataforma**, y por qué ahora.
- Pasa el testigo a [[marketing-content-strategy]] (calendario) → producción. Guarda en `projects/marketing-viral-radar/<YYYY-MM-DD>/`.
- Append en `context/learnings.md` bajo `## marketing-viral-radar` (qué tendencia funcionó al publicar).

## Outputs
- `projects/marketing-viral-radar/<YYYY-MM-DD>/radar.md`: top de tendencias + "qué publicar esta semana" (ángulo/formato/gancho/plataforma).

## Skills que llama
- **`tool-scrape-router`** — Reddit/Google Trends/webs (con Apify MCP para redes sociales).
- **`marketing-content-strategy`** — convierte el radar en calendario editorial.
- **`competitive-ads-extractor`** — si el interés es qué anuncios/ángulos usan los rivales.

## Edge cases
- Sin fuentes/nicho claro → pídelos; un radar sin nicho es ruido.
- Viral ≠ relevante: descarta tendencias que no encajan con la marca aunque tengan mucho engagement (honestidad > vanity).
- Redes sociales → Apify MCP, no montar scrapers a mano; respeta ToS/rate limits.
- No inventes métricas: si una fuente no da datos, dilo; no rellenes.

## Examples

Ver `references/examples.md`.
