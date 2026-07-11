---
name: web-scraping-router
description: Router de tecnologías de scraping que evalúa el caso de uso y elige automáticamente la mejor opción entre: Playwright (interacción compleja), Selenium (legacy), Puppeteer (Chrome-only), Firecrawl API (anti-bot-blockers), MCP tools (n8n, chrome-devtools), WebFetch nativo (sites simples), Requests/BeautifulSoup (HTML parsing). Úsala cuando el operador diga "scrapear web", "automatizar navegador", "extraer datos de sitio", "controla browser", "análisis de páginas online", o cuando necesites interactuar con sitios web complejos. Evalúa: tipo de sitio, requisitos de autenticación, complejidad JavaScript, anti-bot measures, volumen de datos, y devuelve la tecnología óptima con instrucciones de implementación.
version: 1.0.0
category: tools
tags: [scraping, browser-automation, router, technology-selection, web-intelligence, competitive-analysis]
author: iAmasters OS
---

# Web Scraping Router — Selector Inteligente de Tecnologías

> **El punto de apalancamiento se ha movido: ya no está en elegir la herramienta perfecta,  
> está en diseñar el sistema que elija la herramienta por ti.**  
> — Adaptación de Steinberger/Cherny/Osmani al contexto de scraping

## Propósito

Evalúa el caso de uso de scraping/web automation y **elige automáticamente la tecnología óptima**, evitando la parálisis por análisis excesivo. Como un arquitecto que evalúa requisitos y prescribe la solución correcta.

## Cuándo se invoca

- Usuario dice: "scrapear web", "extraer datos de sitio", "automatizar navegador", "controlar browser"
- Usuario pregunta: "¿cómo extraigo datos de esta web?", "qué uso para scrapear X"
- Skills de análisis (`competencia`, `marketing-positioning`, `marketing-brand-voice`) necesitan scraping
- Se detecta intento de scraping/automatización web en lenguaje natural

## Tecnología vs Caso de Uso

### 1. Playwright (Patchright) — Interacción Compleja
**Mejor para**: Navegación compleja, multi-browser, JavaScript heavy, interacción real

**Casos ideales**:
- Llenar formularios multi-paso
- Navegar SPAs complejas con rutas dinámicas
- Automatización que requiere esperar eventos, timers
- Multi-browser testing (Chrome, Firefox, Safari, Edge)
- Interacción con drag-and-drop, uploads complejos

**Ventajas**:
- Soporta todos los navegadores modernos
- Excelente para SPAs con JavaScript complejo
- Network intercept para mocking
- Grabación de vídeo/trazas
- Soporte móvil real

**Desventajas**:
- Curva de aprendizaje más alta
- Overkill para scraping simple
- Requiere setup más complejo

### 2. Selenium — Legacy/Stable
**Mejor para**: Proyectos legacy, ecosistema Java, compatibilidad con herramientas existentes

**Casos ideales**:
- Integración con stacks Java/Spring existentes
- Proyectos que ya usan Selenium
- Requisitos de compatibilidad con sistemas antiguos
- Scripts de automatización probados en producción

**Ventajas**:
- Muy estable y documentado
- Inmensa comunidad y recursos
- Compatible con prácticamente todo

**Desventajas**:
- Más lento que Playwright
- Setup complejo (drivers por navegador)
- Menos confiable para SPAs modernas
- Requiere más mantenimiento

### 3. Puppeteer — Chrome-Optimized
**Mejor para**: Chrome-only, headless rápido, screenshots/GIFs

**Casos ideales**:
- Generación de PDFs
- Screenshots automatizados
- Testing Chrome-only
- Scraping rápido de sitios Chrome
- Generación de GIFs animados

**Ventajas**:
- Muy rápido para Chrome
- Excelente para PDFs/screenshots
- API simple y limpia
- Soporte oficial de Chrome

**Desventajas**:
- Solo Chrome (no multi-browser)
- Menos features que Playwright
- Proyecto menos activo que Playwright

### 4. Firecrawl API — Anti-Bot
**Mejor para**: Sites con bot-blockers, crawling sin mantenimiento, producción

**Casos ideales**:
- Sitios con Cloudflare, Akamai, u otras protecciones
- Crawling masivo sin mantener infraestructura
- Sites con JavaScript heavy pero sin interacción compleja
- Producción donde necesitas reliability

**Ventajas**:
- Maneja bot-blockers automáticamente
- Rotación de proxies/User-Agents
- Escalado horizontal sin esfuerzo
- Soporta crawling profundo

**Desventajas**:
- Costo ($16/mo hobby, $83/mo standard)
- Dependencia de servicio externo
- Menos control que solución self-hosted

### 5. MCP Tools (chrome-devtools, playwright) — Claude-Native
**Mejor para**: Integración con Claude Code, debugging interactivo, prototyping rápido

**Casos ideales**:
- Debugging interactivo de páginas
- Prototyping de scraping dentro de Claude
- Análisis ad-hoc de sitios
- Testing manual de hipótesis

**Ventajas**:
- Integración nativa con Claude
- No requiere código externo
- Interacción conversacional
- Excelente para exploración

**Desventajas**:
- No escalable para batch processing
- Requiere Claude Desktop abierto
- Menos control programático

### 6. WebFetch Nativo — Fallback Simple
**Mejor para**: Sites estáticos simples, fallback cuando todo falla

**Casos ideales**:
- Sites estáticos HTML sin JS
- Blogs simples, documentación
- Fallback cuando APIs no están disponibles
- Prototyping rápido

**Ventajas**:
- Built-in, sin dependencias
- Gratuito
- Funciona para páginas simples

**Desventajas**:
- No ejecuta JavaScript
- Falla en SPAs
- No hay interacción posible

### 7. Requests/BeautifulSoup — Scraping Clásico
**Mejor para**: HTML parsing simple, APIs sin browser, datasets pequeños

**Casos ideales**:
- APIs REST no documentadas
- Sites estáticos con HTML complejo
- Data extraction de HTML tables
- Proyectos Python existentes

**Ventajas**:
- Muy ligero, rápido
- Amplio ecosistema Python
- Control total sobre el parsing

**Desventajas**:
- No ejecuta JavaScript
- Manejo manual de cookies/auth
- No suitable para crawling complejo

---

## Árbol de Decisión

### Paso 1 · Evaluar Tipo de Sitio

```yaml
Site Type:
  Pregunta: "¿El sitio es SPA con JavaScript complejo o HTML estático?"
  
  SPA JavaScript:
    Pregunta: "¿Necesitas interactuar (forms, navigation, clicks)?"
    
    Sí → Ir a Paso 2A (Interacción Compleja)
    No → Ir a Paso 2B (SPA Simple)
    
  HTML Estático:
    Pregunta: "¿Es un sitio simple (blog, docs) o tiene HTML complejo (tables, forms)?"
    
    Simple → WebFetch nativo
    Complejo → Requests/BeautifulSoup
```

### Paso 2A · Interacción Compleja

```yaml
Requisitos:
  Pregunta: "¿Necesitas multi-browser soporte?"
  
  Sí:
    Pregunta: "¿Tu stack es JavaScript/TypeScript o prefieres solución todo-en-uno?"
    
    JavaScript/TypeScript → Playwright (recomendado)
    Java/Legacy → Selenium
    Python → Selenium o Playwright-Python
    
  No (Chrome-only):
    Pregunta: "¿Prioridad: velocidad/features?"
    
    Features → Playwright
    Velocidad/Screenshots → Puppeteer
```

### Paso 2B · SPA Simple

```yaml
Protecciones:
  Pregunta: "¿El sitio tiene bot-blockers (Cloudflare, Akamai)?"
  
  Sí:
    Pregunta: "¿Tienes presupuesto para API o prefieres self-hosted?"
    
    API → Firecrawl
    Self-hosted → Playwright con técnicas anti-detección
    
  No:
    Pregunta: "¿Necesitas crawling profundo (multi-página)?"
    
    Sí → Playwright simple
    No → WebFetch nativo + Requests/BeautifulSoup
```

### Paso 3 · Integración Claude

```yaml
Contexto:
  Pregunta: "¿Estás trabajando dentro de Claude Code vs CLI?"
  
  Claude Code:
    Pregunta: "¿Es prototyping rápido o producción?"
    
    Prototyping → chrome-devtools MCP o playwright MCP
    Producción → Playwright directo
    
  CLI:
    Pregunta: "¿Qué lenguaje prefieres?"
    
    Python → Playwright-Python o Selenium
    JavaScript/TypeScript → Playwright o Puppeteer
    Otro → Selenium
```

---

## Proceso de Recomendación

### Paso 1 · Entender el Caso de Uso (3-5 preguntas)

Antes de recomendar tecnología, hacer estas preguntas:

1. **Tipo de sitio**: "¿Es SPA con JavaScript complejo o HTML estático?"
2. **Interacción requerida**: "¿Necesitas llenar forms, navegar rutas, hacer click, esperar elementos?"
3. **Protecciones**: "¿El sitio tiene Cloudflare, Akamai u otras protecciones anti-bot?"
4. **Volumen**: "¿Es scraping one-time o batch continuo? ¿Cuántas páginas?"
5. **Skills**: "¿Qué lenguajes conoces? ¿Hay restricciones de stack?"
6. **Contexto**: "¿Es para prototyping en Claude o para producción?"

### Paso 2 · Evaluar y Seleccionar

Basado en respuestas, elegir tecnología siguiendo el árbol de decisión.

**Si el caso es ambiguo**, recomendar TOP 2 opciones con pros/contras.

### Paso 3 · Propuesta de Implementación

Entregar:

```
## Recomendación

**Tecnología**: [Playwright / Firecrawl / etc.]

**Por qué**: [justificación basada en respuestas]

**Complejidad estimada**: [Alta / Media / Baja]
- Tiempo estimado: [X horas setup]
- Curva de aprendizaje: [Alta / Media / Baja]
- Costo: [Free / $X/mo]

**Próximos pasos**:
1. [Paso 1 concreto]
2. [Paso 2 concreto]
3. [Paso 3 concreto]

**Alternativas consideradas**:
- [Opción 2]: [por qué no se eligió]
- [Opción 3]: [por qué no se eligió]
```

---

## Matriz de Decisión Rápida

| Caso de Uso | Tecnología Recomendada | Fallback |
|------------|------------------------|----------|
| SPA con JS complejo + interacción | Playwright | Puppeteer (Chrome-only) |
| HTML estático simple | WebFetch nativo | Requests/BS4 |
| Site con bot-blockers | Firecrawl API | Playwright + anti-detection |
| Legacy Java stack | Selenium | Playwright (si posible migrar) |
| Chrome-only + velocidad | Puppeteer | Playwright |
| Prototyping en Claude | chrome-devtools MCP | playwright MCP |
| Production crawling | Firecrawl API | Playwright (self-hosted) |
| APIs no documentadas | Requests + BS4 | Selenium + urllib3 |

---

## Integración con Skills del OS

Esta skill **reemplaza la lógica de decisión** que estaba dispersa:

### Skills que DEBEN invocar esta nueva skill:

- ✅ `competencia` → `web-scraping-router` (antes de asumir Firecrawl)
- ✅ `marketing-positioning` → `web-scraping-router` (evaluar caso de competidor)
- ✅ `marketing-brand-voice` → `web-scraping-router` (evaluar tipo de URLs)
- ✅ `competitive-ads-extractor` → `web-scraping-router` (ad libraries routing)

### Flujo Mejorado:

**ANTES** (sin router):
```
competencia → siempre usa Firecrawl (subóptimo para casos simples)
```

**DESPUÉS** (con router):
```
competencia → web-scraping-router → evalúa caso del competidor
                ↓
                [Playwright | Firecrawl | WebFetch | Selenium]
                ↓
                Solución óptima + instrucciones
```

---

## Casos de Ejemplo

### Ejemplo 1: Competencia con Site Simple

**Input**: "Analiza a mi competencia X"

**Router evalúa**:
- Tipo: HTML estático simple ✅
- Interacción: No necesaria ✅  
- Protecciones: Ninguna ✅
- Volumen: One-time ✅

**Recomendación**:
```
## WebFetch Nativo

**Por qué**: El sitio de competencia es HTML estático simple.

**Costo**: Gratis, instantáneo.

**Instrucciones**:
1. WebFetch nativo de Claude Code
2. Extraer contenido principal
3. Parsear secciones clave
```

### Ejemplo 2: Scraping de Site con Protecciones

**Input**: "Extrae datos de Y (tiene Cloudflare)"

**Router evalúa**:
- Tipo: SPA con JS moderado ✅
- Protecciones: Cloudflare detectado ✅
- Volumen: Batch continuo ✅

**Recomendación**:
```
## Firecrawl API

**Por qué**: Site tiene protecciones anti-bot que requieren rotación de proxies/User-Agents.

**Costo**: $16/mo (hobby) o $83/mo (standard) si uso intensivo.

**Instrucciones**:
1. Configurar FIRECRAWL_API_KEY
2. Usar tool-firecrawl-scraper con modo crawling
3. Configurar depth y patrones de extracción
```

### Ejemplo 3: Automatización de Formulario Complejo

**Input**: "Necesito automatizar el login y extracción de datos"

**Router evalúa**:
- Tipo: SPA con JS complejo ✅
- Interacción: Forms multi-paso ✅
- Volumen: Continuo ✅
- Stack: JavaScript ✅

**Recomendación**:
```
## Playwright

**Por qué**: Interacción compleja con forms, JavaScript dinámico, multi-step.

**Complejidad**: Media (2-4h setup inicial)

**Instrucciones**:
1. Instalar: npm install playwright
2. Crear script de automatización
3. Implementar lógica de navegación y extracción
4. Manejar errors y retries
```

---

## Salida Estándar

Todo análisis termina con estructura:

```markdown
# Análisis de Caso de Scraping

## Requisitos Identificados
- Tipo de sitio: [SPA/HTML/ híbrido]
- Nivel de interacción: [None / Forms / Navigation / Complex]
- Protecciones: [None / Cloudflare / Akamai / Custom]
- Volumen: [One-time / Batch / Continuous]
- Stack: [Python / JS / Java / Mixed]
- Contexto: [Claude Code / CLI / Production]

## Recomendación
**Tecnología**: [Nombre]

## Justificación
[Por qué es la mejor opción para este caso específico]

## Complejidad
- Nivel: [Basic / Medium / High / Expert]
- Tiempo setup: [X horas]
- Curva aprendizaje: [Baja / Media / Alta]

## Costo
- Setup: [Free / One-time / Monthly]
- Infraestructura: [None / Basic / Advanced]

## Instrucciones de Implementación
1. [Paso 1]
2. [Paso 2]
3. [Paso 3]

## Alternativas Consideradas
- [Opción 2]: [Por qué no se eligió]
- [Opción 3]: [Por qué no se eligió]
```

---

## Anti-Patrones

Evitar estas trampas comunes:

### ❌ Anti-Patrón 1: "Siempre Firecrawl"
**Problema**: Usar Firecrawl incluso para sites estáticos simples
**Solución**: Router evalúa caso — WebFetch para sites simples

### ❌ Anti-Patrón 2: "Siempre Playwright"  
**Problema**: Overengineering para scraping simple de HTML
**Solución**: Router evalúa complejidad — WebFetch/Requests para casos simples

### ❌ Anti-Patrón 3: "Asumir Stack"
**Problema**: Asumir que el usuario usa Python/JavaScript sin preguntar
**Solución**: Siempre preguntar stack y skills del equipo

### ❌ Anti-Patrón 4: "Ignorar Costos"
**Problema**: Recomendar Firecrawl sin mencionar precio
**Solución**: Siempre incluir costos y alternativas self-hosted

---

## Próximos Pasos Tras Recomendación

Si el usuario acepta la recomendación:

1. **Verificar prerequisitos** (Python, Node.js, etc.)
2. **Propuesta de implementación** (snippet de código si aplica)
3. **Testing del enfoque** (validar que funciona para el caso)
4. **Alternativa si falla** (plan B)

---

## Metadatos

- **Versión**: 1.0.0
- **Categoría**: tools / scraping
- **Tokens estimados**: ~4,200
- **Skills que invoca**: `tool-firecrawl-scraper` (como fallback), skills de análisis competitivo
- **Skills que la invocan**: `competencia`, `marketing-positioning`, `marketing-brand-voice`, `competitive-ads-extractor`

---

**Notas para la IA**:
- **Paciencia**: No recomendar tecnología sin entender primero el caso
- **Claridad**: Explic POR QUÉ una tecnología es mejor para un caso específico
- **Honestidad**: Si el caso es ambiguo, ofrecer TOP 2 opciones con pros/contras
- **Pragmatismo**: Recomendar la solución más simple que funcione, no la más perfecta teóricamente