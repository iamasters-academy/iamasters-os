---
name: tool-last30days
description: >
  Motor de investigación multi-fuente con ventana fija de 30 días (Reddit, X, YouTube,
  TikTok, Hacker News, GitHub, Polymarket, Bluesky, arXiv, StockTwits…) que rastrea en
  paralelo y sintetiza qué ha pasado sobre un tema, persona, empresa o tecnología en el
  último mes, ordenado por engagement real de gente (upvotes, views, odds con dinero),
  no por lo que decide un editor. Úsala cuando el operador diga "qué ha pasado en los
  últimos 30 días sobre X", "tendencias del último mes en Reddit/HN/GitHub sobre Y",
  "radar 30 días multi-fuente", "actividad reciente en Polymarket sobre Z" o prepare una
  sales call / comparativa y necesite señales frescas. Diferente de
  [[marketing-viral-radar]] (ángulos de contenido semanal cruzados con marca) y de
  [[strategy-web-research]] (3-5 fuentes, sin ventana fija). Basada en
  mvanhorn/last30days-skill.
version: 0.1.0
---

# tool-last30days — Radar de investigación de los últimos 30 días

> **Adaptación iAmasters OS** — Wrapper de `mvanhorn/last30days-skill` (MIT). No vendoriza
> su motor Python: documenta el setup (clonar upstream + deps + keys por fuente) y orquesta
> su ejecución. Puente al OS: sus síntesis **alimentan** a [[competencia]],
> [[startup-business-analyst]], [[investigacion-mercado]] y [[marketing-viral-radar]] como
> input de tendencias frescas. Es el **motor de investigación temporal** del catálogo; no es
> analítica propia ([[marketing-analytics]]) ni research web ligero ([[strategy-web-research]]).

## Cuándo se invoca
- El operador pregunta "qué está pasando con X" / "qué se mueve en Y este mes" sobre una persona, empresa, producto, tecnología o "X vs Y".
- Preparación de una sales call / reunión: señal fresca de los últimos 30 días sobre la cuenta o el interlocutor.
- Comparativa de herramientas/repos con datos vivos (stars, PR velocity, release notes, odds de Polymarket).
- Input de tendencias para contenido (alimenta a [[marketing-viral-radar]]) o para due diligence.

## Desambiguación (lee esto antes de elegir skill)
- **vs [[marketing-viral-radar]]**: viral-radar devuelve *"qué publicar esta semana"* cruzado con marca/ICP (output = ángulos + formatos + ganchos de contenido). last30days devuelve *"qué pasó"* (output = síntesis de actividad multi-fuente). viral-radar puede **consumir** last30days como input.
- **vs [[strategy-web-research]]**: 3-5 fuentes, research ligero, sin ventana temporal fija. last30days = 10+ fuentes motorizadas, ventana 30 días, engagement real.
- **vs [[investigacion-mercado]]**: competitivo/comercial (TAM, precios, proveedores). last30days = actividad/tendencias temporales.
- **vs [[strategy-investigacion-profunda]]**: informe exhaustivo triangulado con scoring de credibilidad. last30days = más rápido, acotado a 30 días, orientado a señal fresca.

## Setup (una vez, runtime — no se versiona en el repo)
- **Clonar** fuera del OS: `git clone https://github.com/mvanhorn/last30days-skill` (o instalar como plugin: `/plugin marketplace add mvanhorn/last30days-skill`).
- **Deps**: `uv sync` (o `venv` + `pip install -r requirements.txt`). Motor Python pesado (yt-dlp para transcripciones, ScrapeCreators opcional).
- **API keys por fuente** (ver `references/sources.md` para la matriz completa). Resumen:
  - **Sin config (gratis, funcionan ya)**: Reddit, Hacker News, Polymarket (público), GitHub (PAT recomendado para rate limit), web genérica vía Brave/SerpAPI (o Perplexity).
  - **Requiere key**: X/Twitter (cookies de navegador o API key), YouTube (yt-dlp sin key estricta), Perplexity (Sonar/Deep Research).
  - **De pago (ScrapeCreators)**: TikTok, Instagram Reels, Threads, Pinterest, LinkedIn.
  - **Auto-activa**: StockTwits para tickers/crypto.
- **Degradación**: sin keys → baja a fuentes gratis (Reddit/HN/Polymarket/GitHub/web). Funciona, pero con menos superficie.
- **Validación**: el upstream arranca y responde a un topic de prueba con al menos las fuentes gratis.

## Process

### Paso 1 · Definir tema, ventana y fuentes
- Recoge: tema (persona / empresa / producto / tecnología / "X vs Y"), ventana (30 días por defecto; configurable), fuentes relevantes según el tema.
- Decide qué fuentes activar según keys disponibles (avisa de las que se omiten por falta de key).
- **Validación**: tema acotado + ventana definida + lista de fuentes activas/omitidas.

### Paso 2 · Verificar keys de las fuentes elegidas
- Comprueba que las keys de las fuentes elegidas están en el entorno del upstream (ver `references/sources.md`).
- Avisa al operador de cuáles degradan (p. ej. "sin cookies de X, se omite Twitter; sin ScrapeCreators, se omiten TikTok/IG").
- **Validación**: las fuentes críticas para este tema tienen key; las opcionales se aceptan como omisión consciente.

### Paso 3 · Lanzar el motor
- Ejecuta el upstream (CLI/Python según su interfaz) con el tema + ventana + fuentes.
- El motor: resuelve handles/subreddits/hashtags relevantes → busca en paralelo → clusteriza la misma historia repetida en varias plataformas → puntúa por engagement real.
- **Validación**: el motor corre sin error de key/dep; devuelve resultados estructurados (no vacío).

### Paso 4 · Recoger, revisar y entregar
- Recoge la síntesis: narrativa de qué pasó, secciones "Best Takes" (citas/reacciones más virales), citations por fuente/plataforma.
- **Revisión honesta**: ¿la señal es real o ruido de un cluster? ¿hay sesgo de plataforma? Si una fuente clave faltaba, anótalo como caveat.
- Output compartible: Markdown y/o HTML autocontenido (para Slack/WhatsApp/email).
- Si el tema es competitivo → encadena con [[competencia]] / [[investigacion-mercado]]. Si alimenta contenido → [[marketing-viral-radar]].
- Si la sesión enseñó algo → append en `context/learnings.md` bajo `## tool-last30days`.

## Outputs
- `projects/tool-last30days/<YYYY-MM-DD>-<tema>/brief.md` (síntesis narrativa + Best Takes).
- `projects/tool-last30days/<YYYY-MM-DD>-<tema>/citations.json` (fuentes, plataforma, engagement, URL, fecha).
- (Opcional) `brief.html` autocontenido para compartir por Slack/WhatsApp/email.

## Skills que llama
- **`competencia`** / **`investigacion-mercado`** — intel competitiva con señal fresca.
- **`startup-business-analyst`** — señales de mercado/competidores para business case.
- **`marketing-viral-radar`** — last30days alimenta como input de tendencias.
- **`sales-call-prep`** — señal fresca de los últimos 30 días sobre la cuenta/interlocutor.

## Edge cases
- **Sin keys** → degrada a fuentes gratis (Reddit/HN/Polymarket/GitHub/web). Avísalo; no falles en silencio.
- **ScrapeCreators no configurado** (TikTok/IG/Threads/LinkedIn) → esas redes se omiten; avisa.
- **X/Twitter** → requiere cookies de navegador exportadas o API key; sin eso, X se omite.
- **Motor pesado** (yt-dlp transcribe vídeos enteros) → puede tardar minutos; avisa en temas con mucho contenido YouTube.
- **Polymarket/StockTwits** auto-activan cuando el tema es financiero/ticker (señal de dinero real).
- **Tema muy nicho** → pocas menciones en 30 días; el cluster puede ser débil; reporta el caveat.
- **Coste**: las fuentes de pago (ScrapeCreators, Perplexity Deep Research) consumen créditos; confirma antes de activarlas.

## Examples

Ver `references/examples.md` para casos completos: tendencias 30 días en Reddit/HN sobre un tema, actividad Polymarket/GitHub sobre un proyecto, y prep de sales call con señal fresca.

## Referencias

- [mvanhorn/last30days-skill](https://github.com/mvanhorn/last30days-skill) — Motor de investigación multi-fuente con ventana de 30 días.
- Licencia: MIT.
- Notas: wrapper sin vendorizar; documenta setup del upstream y orquesta su ejecución. Matriz de fuentes y keys en `references/sources.md`.
