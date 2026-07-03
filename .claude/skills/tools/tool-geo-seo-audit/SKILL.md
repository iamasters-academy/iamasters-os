---
name: tool-geo-seo-audit
description: >
  Auditoría y optimización GEO + SEO de una web: visibilidad y citabilidad ante buscadores de IA
  (ChatGPT, Claude, Perplexity, Gemini, Google AI Overviews) además del SEO clásico. Da un score
  GEO 0-100 con acciones priorizadas, revisa acceso de crawlers de IA (robots.txt/llms.txt),
  audita/genera schema JSON-LD, reescribe contenido preservando la voz de marca y prioriza el
  "competitive framing" (la palanca de mayor lift). Úsala cuando el operador diga "audita el SEO de
  mi web", "optimiza para IA / para que me cite ChatGPT", "GEO", "generative engine optimization",
  "llms.txt", "schema markup", "structured data", "¿por qué no aparezco en Google/IA?", "mejora la
  visibilidad de esta landing", o vaya a lanzar una web pública y quiera posicionarla. Encaja con la
  consultora IA para PYMEs y con webs propias (furgones, landings de servicio). NO la uses para:
  investigación de mercado/competidores como negocio (eso es investigacion-mercado/competencia);
  copywriting puro sin objetivo de ranking (marketing-copywriting); ni auditoría de SEGURIDAD web
  (tool-web-security-audit).
version: 0.1.0
---

# tool-geo-seo-audit — Auditoría GEO + SEO

Adaptación para iAmasters OS que fusiona lo mejor de dos fuentes:
- **`zubair-trabzada/geo-seo-claude`** — orquestador de comandos + score GEO 0-100 + plantillas schema.
- **`mverab/eGEOagents`** — sistema de 4 agentes, competitive framing como señal prioritaria
  (fundamentado en arXiv:2511.20867 + KDD 2024, Princeton), salida estandarizada, mock-mode y
  rewriter que preserva la voz.

Además **absorbe** las skills de SEO del pack de marketing: `ai-seo`, `seo-audit` y `schema`
(auditoría SEO clásica + optimización para IA + structured data en una sola skill).

## Filosofía (honestidad como producto)

El ranking real de un motor de IA **no se puede medir** desde aquí sin sus APIs de producción. Este
skill produce un **proxy razonado por LLM**, no una medición. Todo score y toda predicción de
posición llevan esa etiqueta. Nunca se vende una cifra como si fuera un ranking medido de ChatGPT.

## Diseño LLM-native (sin Python obligatorio)

Este entorno **no tiene Python de sistema**. Por eso el flujo base corre **solo con Claude + curl**:
análisis, citabilidad, schema, competitive framing y recomendaciones no requieren venv. El scoring
cuantitativo pesado y el PDF son un **add-on opcional** (ver §Add-on Python) que solo se monta si el
operador lo pide y hay Python/Docker. Por defecto, mock-mode = razonamiento del LLM.

## Los 4 agentes (pipeline)

Ejecutables en paralelo con subagentes cuando el alcance lo justifique:

| Agente | Función | Salida |
|---|---|---|
| **Analyzer** | Extrae el contenido, puntúa señales GEO/SEO, detecta gaps | `analysis.json` |
| **Ranker** | Simula posicionamiento en motores de IA (proxy LLM, no medición) | score baseline + disclaimer |
| **Rewriter** | Optimiza el contenido **preservando la voz de marca** | `optimized/*.md` |
| **Indexer** | Genera el schema JSON-LD | `schema/*.json` |

## Comandos

- `/geo audit <url>` — auditoría completa GEO + SEO (los 4 agentes).
- `/geo quick <url>` — snapshot de visibilidad en ~60s (sin Python).
- `/geo citability <url>` — puntúa cómo de citable es el contenido para las IAs.
- `/geo crawlers <url>` — acceso de crawlers de IA vía `robots.txt`.
- `/geo llmstxt <url>` — analiza o genera el fichero `llms.txt`.
- `/geo schema <url>` — audita/genera structured data JSON-LD.
- `/geo compete <query|competidor>` — **competitive framing** (señal de mayor lift).
- `/geo seo <url>` — auditoría SEO clásica (títulos, metas, headings, enlaces, Core Web Vitals, sitemap).
- `/geo report <url>` — informe (Markdown por defecto; PDF si hay add-on Python).

## Score GEO (0-100)

Compuesto ponderado. Cada categoría se puntúa 0-100 y se pondera:

| Categoría | Peso | Qué mira |
|---|---|---|
| Citabilidad y visibilidad IA | 25% | fragmentos citables, respuestas directas, datos/cifras, formato Q&A |
| Señales de autoridad de marca | 20% | menciones, backlinks, E-E-A-T, presencia en fuentes que las IAs citan |
| Calidad de contenido / E-E-A-T | 20% | experiencia, expertise, autoría, frescura, profundidad |
| Fundamentos técnicos | 15% | crawlability, velocidad, mobile, sitemap, canonical |
| Structured data | 10% | cobertura y validez de JSON-LD |
| Optimización por plataforma | 10% | llms.txt, robots para GPTBot/ClaudeBot/PerplexityBot, formato por motor |

Semáforo: 🟢 80-100 fuerte · 🟡 55-79 mejorable · 🔴 0-54 débil. El total va con su etiqueta de
proxy. Cada acción del plan lleva su impacto estimado (p. ej. "+15 pts: añadir schema Article").

## Competitive framing (prioridad nº1)

La investigación (arXiv:2511.20867, KDD 2024) valida que **enmarcar competitivamente** el contenido
—posicionarlo explícitamente como la mejor opción para una intención, con comparativas y ventajas
articuladas— produce el **mayor lift inmediato** en cómo las IAs citan y rankean. No es opcional ni
un extra: `/geo compete` se ejecuta dentro de `audit`, no bolt-on. El Rewriter aplica framing
competitivo **sin perder la voz de marca** del operador (lee `brand-context/voice/` si existe).

## Las 10 features GEO (checklist del Analyzer)

1. Énfasis de ranking (posicionarse como la opción top) · 2. Match de intención de usuario ·
3. Ventaja competitiva articulada · 4. Prueba social · 5. Señales de autoridad · 6. Escaneabilidad/
estructura · 7. Densidad de citas/datos · 8. Structured data · 9. Lenguaje factual · 10. Frescura.

## Flujo de `audit`

1. **Fetch** — `curl -s <url>` (y páginas clave del sitemap si aplica).
2. **Analyzer** — puntúa las 10 features + SEO clásico (título, metas, headings H1-H3, alt, enlaces
   internos/externos, canonical, sitemap, robots, velocidad aproximada).
3. **Ranker** — proxy de posicionamiento por intención, **con disclaimer**.
4. **compete** — competitive framing frente a 1-3 competidores/intención.
5. **Indexer** — genera/valida JSON-LD (plantillas en `assets/schema/`).
6. **Rewriter** — reescribe las piezas de mayor impacto preservando voz.
7. **Salida estandarizada** (ver abajo) + plan de acción priorizado con quick wins.

## Salida estandarizada

```
geo-output/<YYYY-MM-DD>-<dominio>/
├── report.md        # resumen ejecutivo + score + plan priorizado (+ quick wins)
├── analysis.json    # señales crudas extraídas por el Analyzer
├── optimized/       # contenido reescrito, listo para pegar
├── schema/          # JSON-LD copy-paste
└── checklist.md     # pasos de implementación
```

Guardar por defecto en `projects/geo-seo-audit/<YYYY-MM-DD>-<dominio>/`.

## Schema JSON-LD (Indexer)

Plantillas en `assets/schema/`: Organization, LocalBusiness, Article, Product, FAQPage, BreadcrumbList.
Elegir por tipo de página, rellenar con datos reales del sitio, validar estructura antes de entregar.
Un JSON-LD correcto sube la precisión de extracción de las IAs de forma notable — es de los fixes de
mejor ratio impacto/esfuerzo.

## llms.txt (Platform)

`/geo llmstxt` comprueba si existe `/<dominio>/llms.txt` y, si no, lo genera: índice curado en
Markdown de las URLs y recursos que quieres que las IAs prioricen. Verifica también que `robots.txt`
no bloquee `GPTBot`, `ClaudeBot`, `PerplexityBot`, `Google-Extended` si el objetivo es ser citado.

## Add-on Python (opcional — scoring cuantitativo + PDF)

Solo si el operador lo pide y hay Python/Docker. Reproduce el harness de eGEOagents: scoring
determinista, evaluación con dataset JSONL y **mock mode offline** (`GEO_EVAL_MOCK=1`) para CI, y
generación de PDF con gauges/barras. **No es necesario** para el uso base — sin él, el score lo razona
Claude (mock-mode) y el informe sale en Markdown/HTML. Documentar el venv aislado si se instala; nunca
asumir que Python está disponible.

## Reglas

- Toda cifra de ranking/visibilidad = **proxy LLM etiquetado**, nunca "medición real".
- El Rewriter **preserva la voz** (`brand-context/voice/` manda si existe).
- Competitive framing va **dentro** de `audit`, no como extra opcional.
- Si el objetivo es SEGURIDAD, no esta skill → [[tool-web-security-audit]].
- Si es cumplimiento legal (RGPD/cookies) → [[tool-web-legal-audit]].
