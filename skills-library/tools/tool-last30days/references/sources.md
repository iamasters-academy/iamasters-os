# Sources — tool-last30days

> Matriz de fuentes del upstream `mvanhorn/last30days-skill`, qué aportan y qué requieren.
> Ver `references/config.md` para coste y `references/examples.md` para uso.

## Matriz de fuentes

| Fuente | Señal que aporta | ¿Key? | Gratis |
|---|---|---|---|
| **Reddit** | Upvotes + comentarios de threads (r/subreddit) | No | Sí |
| **Hacker News** | Puntos + comentarios (señal tech early) | No | Sí |
| **Polymarket** | Odds con dinero real (señal de creencias apostadas) | No | Sí |
| **GitHub** | Star count live, PR velocity, release notes (modo persona y modo topic) | PAT recomendado | Sí (con rate limit sin PAT) |
| **YouTube** | Transcripciones completas (vía yt-dlp) | No | Sí (cómputo local, pesado) |
| **X / Twitter** | Likes, threads, reacciones | Cookies navegador o API key | Sí (con cookies) |
| **TikTok** | Views/engagement de vídeos | ScrapeCreators (pago) | No |
| **Instagram Reels** | Views/engagement | ScrapeCreators (pago) | No |
| **Threads** | Posts y engagement | ScrapeCreators (pago) | No |
| **Pinterest** | Pins/saves | ScrapeCreators (pago) | No |
| **LinkedIn** | Posts (personal + company) | ScrapeCreators (pago) | No |
| **Bluesky** | Posts y engagement | No | Sí |
| **arXiv** | Papers recientes por tema | No | Sí |
| **StockTwits** | Sentimiento de tickers/crypto | No | Sí (auto-activa para tickers) |
| **Digg** | Clusters AI-1000 | No | Sí |
| **Techmeme** | Capa editorial de tech | No | Sí |
| **Perplexity (Sonar/Deep Research)** | Síntesis con fuentes web | `PERPLEXITY_API_KEY` | No (por uso) |
| **Web genérica (Brave)** | Búsqueda web de respaldo | Brave/SerpAPI key | Depende |

## Resolución inteligente (previa a la búsqueda)

Antes de buscar, el motor detecta handles de usuario, subreddits y hashtags relevantes al tema y los resuelve. Esto reduce ruido (no busca "tema" a ciegas; busca las cuentas/foros donde de verdad se habla).

## Clustering por entidad

La misma historia suele repetirse en varias plataformas. El motor **clusteriza** por entidad (fusiona el thread de Reddit + el tweet + el post de HN que hablan de lo mismo) y puntúa el cluster por el engagement agregado, no por mención individual. Evita que un tema parezca enorme solo porque se viralizó una vez.

## "Best Takes"

Sección del output con las **citas y reacciones más virales** (mayor engagement real) del periodo. Útil para «qué dijo la gente» en vez de solo «qué pasó».

## Degradación sin keys

Sin ninguna key configurada, el motor corre con: **Reddit + HN + Polymarket + GitHub + YouTube + web + arXiv + Bluesky + StockTwits + Techmeme + Digg**. Se omiten X (sin cookies/key), TikTok/IG/Threads/Pinterest/LinkedIn (sin ScrapeCreators) y Perplexity (sin key). Suficiente para señal de tech/comunidad; menos para cobertura social amplia.
