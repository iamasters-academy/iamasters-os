# Ejemplos completos de skill creation

## Ejemplo 1 · Skill compleja con references — `marketing-blog-writer`

**Situación**: el usuario quiere una skill que genere posts de blog SEO-optimizados desde una idea + el brand context.

### Conversación

**Usuario**: "Crea una skill que escriba blogs SEO desde un título"

**Claude (meta-skill-creator)**:
- Categoría sugerida: `marketing` → nombre `marketing-blog-writer`
- Descripción candidata: "Genera posts de blog SEO-optimizados de 1200-1800 palabras desde un título o idea, usando brand-voice del operador, con keywords detectados, hook narrativo, CTA al final, y meta description. Invoca tool-output-verifier antes de entregar."
- Pasa los 3 tests (activación / longitud 240 chars / única).
- ¿Skills colabora con? `tool-output-verifier` (gate), opcional `tool-firecrawl-scraper` (si pide investigar competidores).
- ¿Scripts? No. Todo Claude.

### Estructura generada

```
.claude/skills/marketing-blog-writer/
├── SKILL.md
└── references/
    ├── examples.md           (2-3 blog posts de ejemplo)
    ├── seo-checklist.md      (H1/H2 jerarquía, density, alt-text)
    └── hook-frameworks.md    (5 patrones de hook narrativo)
```

### SKILL.md resultante (resumen)

```markdown
---
name: marketing-blog-writer
description: Genera posts de blog SEO-optimizados de 1200-1800 palabras desde título o idea. Usa brand-voice del operador, detecta keywords, aplica hook narrativo, CTA al final, meta description. Invoca tool-output-verifier antes de entregar.
---

# Marketing Blog Writer

## Cuándo se invoca
- Usuario dice: "escribe un blog sobre X", "necesito un post de blog SEO"
- Skill marketing-content-repurposing la llama tras procesar transcript de YouTube

## Process
### Paso 1 · Validar inputs
- Título o idea: obligatorio
- Audiencia: leer brand-context/icp/icp.md si no se especifica
- Tono: leer brand-context/voice/voice-profile.md

### Paso 2 · Investigar keywords
- Si firecrawl disponible → invoca tool-firecrawl-scraper en 3 competidores top
- Si no → keywords manuales basados en brand-context/positioning

### Paso 3 · Generar outline
- Hook (ver references/hook-frameworks.md)
- 3-5 H2 con H3 anidados según jerarquía SEO
- CTA contextual al ICP

### Paso 4 · Redactar
- Aplicar voice-profile (registro B divulgativo por defecto, ajustable)
- 1200-1800 words
- Insertar keywords naturalmente

### Paso 5 · Verificar
- invoca tool-output-verifier con focus: blog-seo
- Si score < 7/10, revisar y reintentar paso 4

### Paso 6 · Cierre
- Output a projects/marketing-blog-writer/YYYY-MM-DD-<slug>/
- Genera: post.md + meta.md (title-tag, meta-description, OG image suggestion)
- Append learnings si hay aprendizaje

## Outputs
- projects/marketing-blog-writer/<fecha>-<slug>/post.md
- projects/marketing-blog-writer/<fecha>-<slug>/meta.md

## Skills que llama
- tool-output-verifier (gate obligatorio)
- tool-firecrawl-scraper (opcional, en paso 2)

## Edge cases
- Si no hay brand-voice → usar registro B "neutro divulgativo" + warning al usuario
- Si firecrawl no responde → continuar sin investigación competitiva, marcar en meta.md

## Examples
Ver references/examples.md
```

---

## Ejemplo 2 · Skill con script Python — `tool-pdf-summarizer`

**Situación**: necesitas resumir PDFs largos (200+ páginas) sin gastar contexto.

**Decisión clave**: extracción del PDF con script (rápido, no consume tokens), resumen con Claude (calidad).

### Estructura

```
.claude/skills/tool-pdf-summarizer/
├── SKILL.md
├── scripts/
│   └── extract.py            # PyPDF2: PDF → texto plano
└── references/
    └── examples.md
```

### Flujo

1. Usuario pide resumir PDF
2. SKILL.md ejecuta `bash` → `python3 scripts/extract.py <pdf-path>` → devuelve texto en stdout o archivo temporal
3. Claude lee el texto extraído (en bloques si es largo, usando subagent si supera 50K tokens)
4. Genera resumen estructurado
5. Cleanup del temporal
6. Output a `projects/tool-pdf-summarizer/YYYY-MM-DD-<nombre>/resumen.md`

### Por qué script y no todo Claude

- PDFs de 200 páginas = ~50K tokens solo para leer
- Script Python con PyPDF2 hace lo mismo en <2 segundos sin tokens
- Claude solo procesa el texto extraído (puede usar subagent para chunks)

---

## Ejemplo 3 · Skill simple sin references — `meta-changelog-bumper`

**Situación**: cada vez que cierras release, hay que actualizar CHANGELOG.md con los commits desde la versión anterior. Es repetitivo y mecánico.

### Decisión

- ¿Skill o slash command? → Slash command (`/bump-changelog`) sería más rápido si solo hace 1 cosa.
- Pero queremos que se invoque desde otras skills (release flow), así que **skill simple sin references**.

### Estructura

```
.claude/skills/meta-changelog-bumper/
└── SKILL.md
```

Sin references/ porque no hay knowledge a separar. SKILL.md ~600 chars total.

### SKILL.md

```markdown
---
name: meta-changelog-bumper
description: Actualiza CHANGELOG.md con los commits desde la última tag de versión. Detecta cambios por categoría (Added/Changed/Fixed/Removed) usando keywords de conventional commits. Invocada por release skill o manualmente.
---

# meta-changelog-bumper

## Cuándo se invoca
- Usuario dice: "actualiza el changelog"
- Skill de release la llama tras crear nueva tag

## Process
### Paso 1 · Detectar última versión
- bash: git describe --tags --abbrev=0
- Si no hay tags: empezar desde primer commit

### Paso 2 · Listar commits desde esa tag
- bash: git log <last-tag>..HEAD --oneline

### Paso 3 · Clasificar
- feat: → Added
- fix: → Fixed
- refactor:/style:/perf: → Changed
- BREAKING CHANGE: o !: → marcar como ⚠️
- removed:/deprecated: → Removed

### Paso 4 · Generar entrada
- Insertar al inicio de CHANGELOG.md después de la sección [Unreleased]
- Formato Keep a Changelog 1.1.0
- Fecha del día

### Paso 5 · Cierre
- Mostrar diff al usuario antes de guardar
- Pedir aprobación
- No commit automático (lo hace release skill)

## Outputs
- Edit a CHANGELOG.md

## Edge cases
- Si no hay commits desde última tag: avisar y no editar
- Si hay BREAKING CHANGE: añadir warning visible

## Examples
- Llamada: "actualiza el changelog"
- Output esperado: ## v0.2.0 - 2026-05-07 con secciones Added/Changed/Fixed
```

---

## Lecciones de estos 3 ejemplos

| Aspecto | marketing-blog-writer | tool-pdf-summarizer | meta-changelog-bumper |
|---|---|---|---|
| Tamaño SKILL.md | 1500 tokens | 700 tokens | 400 tokens |
| references/ | Sí (3 archivos) | Sí (1 archivo) | No |
| scripts/ | No | Sí (Python) | No |
| Llama otras skills | 2 | 0 | 0 |
| Tipo | Compleja | Híbrida (script+LLM) | Simple |
| ¿Mejor como slash command? | No, requiere proceso largo | No | Posiblemente sí, pero queremos invocarlo desde otras |

**Conclusión**: la complejidad de la skill se ajusta a la tarea. No infles ni reduzcas — escala con el problema.
