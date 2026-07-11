# Config — tool-last30days

> Setup del upstream `mvanhorn/last30days-skill` y consideraciones de coste/peso.

## Instalación del upstream (fuera del repo del OS)

```bash
# Opción A — como plugin de Claude Code
/plugin marketplace add mvanhorn/last30days-skill

# Opción B — clonar y correr el motor Python directamente
git clone https://github.com/mvanhorn/last30days-skill
cd last30days-skill
uv sync            # o: python -m venv .venv && source .venv/bin/activate && pip install -r requirements.txt
```

El upstream expone un asistente de ~30 s para desbloquear las fuentes que requieren key.

## Consideraciones

- **Motor Python pesado**: usa `yt-dlp` para descargar y transcribir vídeos enteros de YouTube. En temas con mucho contenido YouTube, la ejecución puede tardar minutos.
- **ScrapeCreators** (TikTok/IG/Threads/Pinterest/LinkedIn) es un servicio de **pago**. Sin cuenta, esas redes se omiten.
- **Perplexity Deep Research / Sonar** consume créditos de la API de Perplexity si se activa.
- **Degradación limpia**: sin ninguna key, Reddit + HN + Polymarket + GitHub + web funcionan y devuelven señal útil, solo con menos superficie social.

## Coste

| Fuente | Coste | Requiere key |
|---|---|---|
| Reddit, HN, Polymarket, GitHub, web (Brave/SerpAPI) | Gratis | No (PAT recomendado para GitHub rate limit) |
| YouTube (yt-dlp) | Gratis (cómputo local) | No |
| X/Twitter | Gratis | Cookies de navegador exportadas **o** API key |
| Perplexity (Sonar / Deep Research) | Por uso | `PERPLEXITY_API_KEY` |
| ScrapeCreators (TikTok/IG/Threads/Pinterest/LinkedIn) | Suscripción | `SCRAPECREATORS_KEY` |
| StockTwits | Gratis | No (auto-activa para tickers/crypto) |
| Bluesky | Gratis | No |

**Regla del operador**: empezar por lo gratis (Reddit/HN/Polymarket/GitHub/web) y escalar a fuentes de pago solo si la señal lo justifica y el operador confirma el coste.
