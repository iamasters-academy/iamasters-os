# Examples — tool-last30days

> Casos completos de invocación + output esperado. Placeholder genéricos, sin info privada.

## Ejemplo 1 · Tendencias 30 días en Reddit/HN sobre un tema

**Input del operador:** "¿Qué se está moviendo en los últimos 30 días sobre 'agents SDK' en Reddit y Hacker News?"

**Flujo:**
1. Definir: tema = "agents SDK" (tecnología), ventana = 30 días, fuentes = Reddit + HN (+ GitHub opcional).
2. Verificar keys: Reddit y HN son gratis, sin key → OK. GitHub: PAT recomendado para rate limit (si hay, se activa modo repo velocity).
3. Lanzar motor: clusteriza threads de r/LocalLLaMA, r/ClaudeAI, HN front page sobre el tema; puntúa por upvotes + comentarios.
4. Revisar: ¿señal real (varios clusters independientes) o un único hilo viral? Best Takes = las 3 citas más upvotedadas.
5. Cierre: `brief.md` + `citations.json`; ofrecer encadenar con `marketing-viral-radar` ("¿qué publico esta semana basado en esta señal?").

**Output esperado:**
```
projects/tool-last30days/2026-07-11-agents-sdk/
├── brief.md       # Narrativa + Best Takes + clusters por plataforma
└── citations.json # [{plataforma, url, upvotes, fecha}, ...]
```

## Ejemplo 2 · Actividad Polymarket + GitHub sobre un proyecto

**Input:** "¿Qué pasa con 'proyecto X' en los últimos 30 días? Mira Polymarket y GitHub."

**Flujo:**
1. Definir: tema = "proyecto X", fuentes = Polymarket (odds con dinero real) + GitHub (stars live, PR velocity, release notes).
2. Verificar: Polymarket público (sin key), GitHub PAT (recomendado). Ambos gratis.
3. Lanzar: Polymarket → mercados/odds relacionados; GitHub → star delta 30d, releases, PRs merged, issues trend.
4. Revisar: ¿los odds suben/bajan? ¿hay release importante que correlacione?
5. Cierre: brief con señal cuantitativa (odds + star delta); encadena con `startup-business-analyst` si es business case.

**Nota anti-disparador:** si lo que quiere es TAM/precios del mercado → `investigacion-mercado`, no esto. last30days da señal temporal (qué se mueve), no dimensionamiento.

## Ejemplo 3 · Prep de sales call con señal fresca

**Input:** "Mañana hablo con [empresa]. ¿Qué ha pasado con ellos en los últimos 30 días que pueda sacar en la call?"

**Flujo:**
1. Definir: tema = "[empresa]" (persona jurídica + interlocutor si se conoce), fuentes = todas las gratis (Reddit, HN, web, GitHub si tienen repo público, LinkedIn vía ScrapeCreators si hay key).
2. Verificar keys; activar ScrapeCreators si está configurado para LinkedIn/contenido social.
3. Lanzar: clusteriza menciones, noticias, actividad de producto, señales de contratación (vía web/LinkedIn).
4. Revisar: filtra a lo **accionable** para una call (producto nuevo, ronda de financiación, queja recurrente, contratación de un rol relevante).
5. Cierre: brief conciso → encadena con `sales-call-prep` ("¿lo meto en el prep de la llamada de mañana?").

**Output esperado:** brief con 3-5 señales accionables + citations, listo para integrar en el deck de la call.
