# Mapa de Skills de Scraping — iAmasters OS

**Fecha**: 2026-07-09  
**Skills con funcionalidad de scraping/extracción**: 6 identificadas

---

## 🔍 Skills de Scraping Identificadas

### 1. `tool-firecrawl-scraper` ✅ PRINCIPAL

**Ubicación**: `.claude/skills/tools/tool-firecrawl-scraper/`

**Función**: Wrapper de Firecrawl API para scraping de URLs públicas

**Tecnología**: Firecrawl API (con fallback a WebFetch nativo)

**Triggers**:
- "scrapea esta URL", "saca el texto de esta página"
- "extrae el contenido de esta web", "dame los links de…"
- "léete esta web y dime…"

**Invocada por**:
- `marketing-brand-voice` (scraping web/LinkedIn/YouTube)
- `marketing-positioning` (análisis de competidores)
- `competencia` (análisis de competidores)

**Características**:
- Degrada graceful si no hay API key
- Formatos: markdown, text, HTML
- Extract assets option
- Anti-bot-blockers

---

### 2. `competitive-ads-extractor` ✅

**Ubicación**: `.claude/skills/marketing/competitive-ads-extractor/`

**Función**: Extrae y analiza anuncios de la competencia desde ad libraries

**Plataformas**: Facebook/Meta, LinkedIn, etc.

**Triggers**:
- "qué anuncios pone mi competencia"
- "saca los ads de X", "qué mensajes usan los rivales"
- "analiza la publicidad de la competencia"
- "qué creatividades funcionan en mi sector"

**Características**:
- Extrae ads de ad libraries
- Analiza messaging, pain points, creative patterns
- Competitor comparison
- Platform differences (LinkedIn B2B vs Facebook B2C)

---

### 3. `competencia` ✅

**Ubicación**: `.claude/skills/strategy/competencia/`

**Función**: Inteligencia competitiva con web intelligence

**Triggers**:
- "analiza a mi competencia"
- "qué hacen los competidores"
- "compara nuestra app con la de X"
- "inteligencia competitiva"

**Características**:
- Web intelligence (reviews, pricing, marketing data)
- Usa NotebookLM + web scraping
- Feature comparison
- UX/UI analysis

**Skills que invoca**:
- `competitive-ads-extractor` (entrada)
- `tool-firecrawl-scraper` (scraping webs)
- `startup-business-analyst` (salida)

---

### 4. `marketing-brand-voice` ✅

**Ubicación**: `.claude/skills/marketing/marketing-brand-voice/`

**Función**: Genera voice profile con scraping de URLs públicas

**Triggers**:
- "trabaja mi voz de marca"
- "define mi tono", "brand voice"
- "cómo sueno", "mi estilo de escritura"

**Scraping que hace**:
- Web propia / blog
- LinkedIn personal
- YouTube canal

**Invoca**:
- `tool-firecrawl-scraper` (para scrapear URLs)

---

### 5. `marketing-positioning` ✅

**Ubicación**: `.claude/skills/marketing/marketing-positioning/`

**Función**: Construye posicionamiento analizando competidores

**Triggers**:
- "posicionamiento", "cómo me diferencio"
- "qué me hace distinto", "mi mensaje no diferencia"
- "ángulo de posicionamiento"

**Scraping que hace**:
- Analiza competidores (con `tool-firecrawl-scraper`)
- Extrae positioning de webs de competencia

**Invoca**:
- `tool-firecrawl-scraper` (opcional, paso 2)

---

### 6. `automation-n8n-builder` ⚠️ PARCIAL

**Ubicación**: `.claude/skills/automation/automation-n8n-builder/`

**Función**: Crea workflows n8n (puede incluir scraping)

**Triggers**:
- "crea un workflow en n8n"
- "monta un n8n que haga X"
- "convierte esta idea en automatización"

**Scraping que puede hacer**:
- Si el workflow requiere scraping → combinar con `tool-firecrawl-scraper`

**Nota**: Esta skill es más de orquestación que scraping per se.

---

## 🔗 Mapa de Sinergias

```
                    ┌─────────────────────────┐
                    │ tool-firecrawl-scraper │ ← CORE ENGINE
                    │   (Firecrawl API)       │
                    └───────────▲─────────────┘
                                │
        ┌───────────────────────┼───────────────────────┐
        │                       │                       │
        │                       │                       │
┌───────▼────────┐    ┌────────▼──────┐    ┌───────▼────────┐
│  brand-voice   │    │  positioning  │    │  competencia   │
│  (scraping     │    │  (scraping    │    │  (scraping     │
│   URLs propias) │    │   competidores)│    │   competidores)│
└────────────────┘    └───────────────┘    └───────▲────────┘
                                              │
                                   ┌──────────┴──────────┐
                                   │ competitive-ads    │
                                   │   (ad libraries)   │
                                   └─────────────────────┘
```

---

## 🎯 Análisis de Activación

### ✅ Skills con BUENA activación

1. **`tool-firecrawl-scraper`** ✅
   - Triggers muy específicos y claros
   - Integración bien documentada con otras skills
   - Degradación graceful (fallback a WebFetch)

2. **`competitive-ads-extractor`** ✅
   - Triggers específicos ("qué anuncios pone mi competencia")
   - Casos de uso bien definidos
   - Outputs claros

### ⚠️ Skills con ACTIVACIÓN PROBLEMÁTICA

1. **`competencia`** ⚠️
   - Triggers aceptables pero quizás muy genéricos
   - Probablemente NO se activa cuando debería
   - **Problema**: "analiza a mi competencia" puede no activarse si el usuario usa sinónimos

2. **`marketing-positioning`** ⚠️
   - Triggers demasiado específicos ("ángulo de posicionamiento")
   - Probablemente NO se activa con lenguaje natural
   - **Problema**: Usuario dice "todos dicen lo mismo" → skill NO activa

3. **`marketing-brand-voice`** ⚠️
   - Triggers aceptables pero formato muy técnico
   - Probablemente NO se activa con lenguaje conversacional
   - **Problema**: Usuario dice "quiero definir mi estilo" → skill NO activa

---

## 💡 Recomendaciones de Mejora

### 1. Crear Skill `web-scraping-router` (Opcional)

Si necesitas UNIFICAR scraping con router de tecnologías:

**Propósito**: Evaluar caso de uso → elegir tecnología óptima

**Tecnologías a routear**:
- **Firecrawl API** (anti-bot-blockers, sites con JS)
- **Playwright/Selenium** (interacción compleja, forms, auth)
- **WebFetch nativo** (sites estáticos simples, fallback)
- **MCP tools** (n8n workflows, orquestación)
- **Requests/BeautifulSoup** (scraping simple, HTML parsing)

**Triggers mejorados**:
- "scrapear web", "extraer contenido de página", "analizar sitio online"
- "automatizar navegador", "controlar browser", "interactuar con sitio web"
- "sacar datos de web", "scraping", "web extraction"

**Beneficio**: Unificar múltiples approaches en decision tree inteligente.

### 2. Estandarizar Triggers de Scraping

**Nuevo formato propuesto** para skills de scraping:

```yaml
---
triggers:
  explicit:
    - "scrapea esta URL"
    - "saca el contenido de esta web"
  semantic:
    - "extracción de contenido online"
    - "análisis de páginas web"
    - "recopilación de datos de sitios"
  synonyms:
    - "scraping", "web scraping", "data extraction"
    - "análisis de competencia online"
    - "monitoreo de sitios"
  context:
    - "Cuando se necesita contenido de webs públicas"
    - "Para análisis de competencia"
    - "Para extracción de datos online"
---
```

### 3. Mejorar Sinergias

**Crear invocaciones automáticas**:

- `competencia` → `tool-firecrawl-scraper` (automático si hay URLs)
- `marketing-positioning` → `competitive-ads-extractor` (opcional)
- `marketing-brand-voice` → `tool-firecrawl-scraper` (automático si hay URLs)

### 4. Testing de Activación

**Verificar que skills se activan con**:
- Lenguaje natural ("mi competencia hace X")
- Sinónimos ("extraer datos", "sacar info")
- Variantes conversacionales ("¿cómo se comparan con...?")

---

## 📋 Conclusión

**EXISTEN 6 skills de scraping** en iAmasters OS:

1. ✅ `tool-firecrawl-scraper` — CORE ENGINE
2. ✅ `competitive-ads-extractor` — ad libraries
3. ⚠️ `competencia` — inteligencia competitiva
4. ⚠️ `marketing-brand-voice` — voice profiles
5. ⚠️ `marketing-positioning` — positioning analysis
6. ⚠️ `automation-n8n-builder` — workflows (parcial)

**PROBLEMA PRINCIPAL**: Triggers muy específicos → NO se activan con lenguaje natural.

**SOLUCIÓN**: 
1. Crear `web-scraping-router` (opcional, unifica tecnologías)
2. Estandarizar triggers con formato semantic/synonyms
3. Mejorar sinergias entre skills
4. Testing de activación con lenguaje natural

**¿Quieres que cree la skill `web-scraping-router` o prefieres mejorar los triggers de las skills existentes?**
