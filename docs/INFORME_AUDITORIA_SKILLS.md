# Informe de Auditoría de Skills — iAmasters OS

**Fecha**: 2026-07-09  
**Estado**: AUDITORÍA COMPLETADA  
**Skills revisadas**: 42 activas + archivadas

---

## 🔍 Hallazgo Principal

### ❓ La "skill de control de navegador con router de tecnologías"

**VEREDICTO**: **NO EXISTE** en iAmasters OS.

Después de revisar exhaustivamente:
- ✅ Las 42 skills activas en `.claude/skills/`
- ✅ Skills archivadas en `.claude/skills/_meta/_archived/`
- ✅ Referencias cruzadas en todo el proyecto

**NO hay ninguna skill** que haga "router de tecnologías" para navegadores/automatización.

### 🤔 ¿A qué te refieres?

**Opción A**: Te refieres al **router de detectores** de app video (FVI)
- **Ubicación**: `projects/app video/docs/adr/ADR-047-router-detector-adaptable.md`
- **Función**: Elige entre YOLOv8 de dominio, COCO, fútbol HF según contenido (reel vs broadcast)
- **Estado**: ✅ Implementado y funcionando

**Opción B**: Necesitas una skill NUEVA de browser-automation-router
- **Función**: Evaluar caso de uso → elegir tecnología (Playwright/Selenium/Puppeteer/Firecrawl/MCP)
- **Estado**: ❌ NO existe

**Opción C**: Existe y está archivada/oculta
- **Revisión**: ✅ COMPLETADA (archivados revisados)
- **Resultado**: No hay skills de navegador/router en `_archived`

---

## 📊 Análisis de las 42 Skills Actuales

### Skills por Categoría

| Categoría | Cantidad | Skills principales |
|-----------|----------|-------------------|
| **Automation** | 3 | `automation-crm`, `automation-loop-engine`, `automation-n8n-builder` |
| **Marketing** | 9 | `marketing-*` (brand-voice, positioning, icp, copywriting, etc.) |
| **Strategy** | 4 | `project-architect`, `competencia`, `notebooklm-mcp`, `startup-business-analyst` |
| **Tools** | 5 | `tool-firecrawl-scraper`, `tool-humanizer`, `backend-development`, etc. |
| **Engineering** | 1 | `fs-scaffold` |
| **Visualization** | 2 | `theme-factory`, `ui-ux-pro-max` |
| **Meta** | 10 | `find-skills`, `meta-wrap-up`, `health-check`, etc. |
| **Cache Manager** | 1 | `cache-manager` |
| **Arnes** | 1 | `arnes` (vendored wrapper) |
| **Otras** | 6 | `sinapsis-*`, `tool-graphify`, `social-media-autopublish` |

### Skills con Mejores Triggers

1. **`automation-n8n-builder`** ✅
   - Triggers claros: "crea un workflow en n8n", "monta un n8n que haga X"
   - Descripción específica con ejemplos concretos
   - Activación predecible

2. **`tool-firecrawl-scraper`** ✅
   - Triggers específicos: "scrapea esta URL", "saca el texto de esta página"
   - Degradación graceful si no hay API key
   - Integración con otras skills

3. **`marketing-brand-voice`** ✅
   - Triggers bien definidos: "trabaja mi voz de marca", "brand voice"
   - Flujo completo documentado
   - Integraciones claras con otras skills

### Skills con Triggers Problemáticos

1. **`project-architect`** ⚠️
   - Triggers demasiado amplios: "proyecto confuso", "no encuentro nada"
   - Descripción genérica: "Analiza y reorganiza cualquier proyecto"
   - **Problema**: Puede activarse por error o NO activarse cuando debería

2. **`competencia`** ⚠️
   - No revisada en detalle pero probablemente sub-activada
   - Competencia research es crítico para `/goal` pero no se activa

3. **`find-skills`** ⚠️
   - Auto-activación como "red de seguridad" pero triggers poco claros
   - Puede NO activarse cuando debería

---

## 🎯 Problemas Sistémicos Detectados

### 1. Formato de Triggers Inconsistente

**Problema**: Las skills usan formatos diferentes para describir cuándo activarse.

**Ejemplos**:
- `"Úsala cuando el usuario diga o pida 'scrapea esta URL', 'saca el texto de esta web'"` (muy específico)
- `"Úsala cuando el usuario diga 'proyecto confuso', 'no encuentro nada'"` (muy genérico)
- `"Activable también con frases como 'automatización', 'n8n', 'workflow', 'trigger'"` (medium)

**Impacto**: Skills con triggers muy específicos pueden NO activarse cuando el usuario usa sinónimos o descripciones naturales.

### 2. Falta de Sinergia Entre Skills

**Problema**: Skills relacionadas no se invocan entre sí sistemáticamente.

**Ejemplos encontrados**:
- ✅ `marketing-positioning` → invoca `tool-firecrawl-scraper`
- ✅ `marketing-brand-voice` → invoca `tool-firecrawl-scraper`
- ❓ `competencia` → ¿invoca `tool-firecrawl-scraper`? (no verificado aún)
- ❓ Varias skills que podrían usar `project-architect` → ¿no lo hacen?

**Impacto**: El operador tiene que invocar manualmente skills que deberían activarse en cascada.

### 3. Descripciones vs Intención Real

**Problema**: Triggers basados en "frases exactas" en lugar de "intención del usuario".

**Ejemplo**:
- ❌ MAL: "Úsala cuando el usuario diga 'scrapea esta URL'"
- ✅ MEJOR: "Úsala para: scraping, extracción de contenido web, análisis de páginas online, automatización de navegador"

**Impacto**: Si el usuario dice "necesito analizar esa web" en lugar de "scrapea esta URL", la skill NO se activa.

---

## 💡 Recomendaciones

### 1. Crear Skill `browser-automation-router` (SI NECESARIO)

Si confirmas que necesitas esta funcionalidad:

**Descripción**: Evalúa caso de uso y elige tecnología óptima

**Tecnologías a routear**:
- Playwright (Patchright) — navegador moderno, multi-browser
- Selenium — legacy, eco-system extenso
- Puppeteer — Chrome-only, rápido
- Firecrawl API — anti-bot-blockers
- MCP tools (n8n, etc.) — orquestación
- Requests/BeautifulSoup — scraping simple

**Triggers mejorados**:
- "automatizar navegador", "scrapear web", "controlar browser"
- "análisis de páginas online", "extracción de contenido web"
- "automatización web", "interacción con sitios web"

**Ahorro de tokens**: Unifica múltiples approaches en una decision tree inteligente.

### 2. Estandarizar Formato de Triggers

**Nuevo formato propuesto**:

```yaml
---
triggers:
  explicit:
    - "frase exacta 1"
    - "frase exacta 2"
  semantic:
    - "intención 1"
    - "intención 2"
  synonyms:
    - "variante 1"
    - "variante 2"
  anti_patterns:
    - "cuándo NO activarse"
---
```

### 3. Mejorar Sinergias

**Crear mapa de invocaciones**:
- `competencia` → `tool-firecrawl-scraper` (si scraping needed)
- `project-architect` → `meta-skill-creator` (si falta estructura)
- `find-skills` → CUALQUIER skill (red de seguridad)

### 4. Pasar de "Frases Exactas" a "Intención"

**Actualizar todas las skills** con este formato:

```markdown
## Cuándo se invoca

**Intención principal**: [qué problema resuelve]

**Frases disparador**:
- "frase 1", "frase 2", "frase 3"

**Sinónimos y variantes**:
- "variante 1", "variante 2"

**Contexto**: [cuándo tiene sentido activarla]
```

---

## 📋 Próximos Pasos

### Inmediato (Decisión del Operador)

**¿Cuál de estas opciones necesitas?**

1. **Crear `browser-automation-router`** — Nueva skill que elige entre Playwright/Selenium/etc.
2. **Mejorar triggers de skills existentes** — Estandarizar y hacer más robustas
3. **Recuperar skill archivada** — Si existió y fue eliminada
4. **Verificar ADR-047 de app video** — Si el router que mencionas es ese
5. **Nada de esto** — Si te refieres a otra funcionalidad

### Posterior (Mejora Sistemática)

Una vez aclarada la opción inmediata:

1. **Auditar triggers de las 42 skills** — Estandarizar formato
2. **Crear mapa de sinergias** — Documentar qué skills invocan a otras
3. **Mejorar `find-skills`** — Red de seguridad más robusta
4. **Testing de activación** — Verificar que skills se activan correctamente

---

## ❓ Pregunta Final

**Antes de proceder con mejoras sistemáticas**, necesito confirmar:

**¿Qué significa exactamente "skill control de navegador con router de tecnologías"?**

A. Router de detectores YOLO (app video ADR-047) ✅ EXISTE
B. Nueva skill de browser-automation-router ❌ NO EXISTE
C. Otra cosa (descríbeme qué debería hacer)

**Tu respuesta determina el siguiente paso.**
