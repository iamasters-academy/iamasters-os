# investigacion-profunda

Skill de **investigación profunda en español** para Claude.ai, adaptada de [199-biotechnologies/claude-deep-research-skill](https://github.com/199-biotechnologies/claude-deep-research-skill).

Genera informes con pipeline de 8 fases, triangulación multi-fuente, scoring de credibilidad y validación automática. Salida en **Markdown + HTML estilo McKinsey**.

---

## Instalación

### En Claude.ai (web/app)

1. Descarga el archivo `investigacion-profunda.skill` (zip empaquetado)
2. Ve a Settings → Skills → Upload skill
3. Sube el `.skill` y actívalo

### En Claude Code (terminal)

```bash
cd .claude/skills/strategy-investigacion-profunda
pip install -r requirements.txt
```

---

## Uso

Cualquiera de estas frases activa la skill:

- "Hazme una investigación profunda sobre X"
- "Quiero un informe sobre el estado del arte en X"
- "Compara X vs Y exhaustivamente"
- "Analiza a fondo la situación de X"

La skill te preguntará el **modo** al inicio:

| Modo | Fases | Duración | Palabras | Para qué |
|------|-------|----------|----------|----------|
| Quick | 3 | 2-5 min | 2.000-4.000 | Exploración inicial |
| Standard | 6 | 5-10 min | 4.000-8.000 | Mayoría de casos |
| Deep | 8 | 10-20 min | 8.000-15.000 | Decisiones críticas |
| UltraDeep | 8+ | 20-45 min | 15.000-20.000+ | Máximo rigor |

---

## Pipeline

```
Scope → Plan → Retrieve → Triangulate → Outline Refinement
       → Synthesize → Critique (con loop-back) → Refine → Package
```

Características clave:

- **Paso 0**: obtiene la fecha actual antes de buscar (evita asumir año del entrenamiento)
- **5-10 ángulos de búsqueda** descompuestos a partir de la pregunta
- **First Finish Search**: umbrales adaptativos de calidad por modo
- **Critique loop-back**: si la crítica detecta una laguna crítica, vuelve a buscar
- **Red teaming multi-persona** en modo Deep (Profesional escéptico, Revisor adversarial, Ingeniero de implementación)
- **Persistencia de evidencia** en `sources.json` + `evidence.json` + `claims.json`

---

## Salida

Informes guardados en `projects/investigacion/<YYYY-MM-DD>/<tema-slug>/`:

- `informe_*.md` — fuente de verdad
- `informe_*.html` — estilo McKinsey (tipografía editorial, TOC, citas enlazadas)
- `sources.json` — registro de fuentes con IDs estables
- `evidence.json` — citas literales con localizadores
- `claims.json` — afirmaciones atómicas con estado de soporte
- `run_manifest.json` — configuración del run

---

## Estándares de calidad

- 10+ fuentes, 3+ por afirmación importante (independientes, no solo número)
- Resumen ejecutivo 200-400 palabras
- Hallazgos 600-2.000 palabras cada uno, prosa primero (≥80%)
- Bibliografía completa con URLs, sin marcadores
- Validación automática: `validate_report.py` (9 checks) + `verify_citations.py`
- Bucle de validación: validar → corregir → reintentar (máx. 3 ciclos)

---

## Scripts

| Script | Función |
|--------|---------|
| `citation_manager.py` | Gestión de fuentes, evidencia, claims con IDs estables |
| `validate_report.py` | 9 checks de estructura (resumen, secciones, citas, bibliografía...) |
| `verify_citations.py` | Verificación de citas y bibliografía |
| `source_evaluator.py` | Scoring de credibilidad 0-100 (heurístico) |
| `md_to_html.py` | Conversión a HTML estilo McKinsey |

---

## Arquitectura

```
investigacion-profunda/
├── SKILL.md                              # Entry point (~140 líneas)
├── README.md                             # Este archivo
├── requirements.txt                      # markdown
├── reference/                            # Cargado bajo demanda
│   ├── methodology.md                    # 8 fases en detalle
│   ├── report-assembly.md                # Estrategia de generación progresiva
│   ├── quality-gates.md                  # Estándares de validación
│   └── html-generation.md                # Conversión a McKinsey HTML
├── templates/
│   ├── report_template.md                # Plantilla del informe
│   └── mckinsey_report_template.html     # Plantilla HTML editable
├── scripts/
│   ├── citation_manager.py
│   ├── validate_report.py
│   ├── verify_citations.py
│   ├── source_evaluator.py
│   └── md_to_html.py
└── schemas/
    ├── source.schema.json
    ├── evidence.schema.json
    ├── claim.schema.json
    └── run_manifest.schema.json
```

---

## Diferencias con el original

| Aspecto | Original (Claude Code) | Esta réplica (Claude.ai) |
|---------|------------------------|--------------------------|
| Idioma | Inglés | **Español** |
| Búsqueda | `search-cli` (brew) + Task subagents | `web_search` + `web_fetch` |
| Salida final | MD + HTML + PDF (WeasyPrint) | **MD + HTML** |
| Almacenamiento | `projects/investigacion/<YYYY-MM-DD>/<tema-slug>/` | `projects/investigacion/<YYYY-MM-DD>/<tema-slug>/` |
| Paralelismo | Subagentes Task reales | Múltiples `web_search` en un turno |
| Validación | Igual (scripts Python) | Igual |
| Pipeline 8 fases | Igual | Igual |

---

## Versión

v1.0 — Mayo 2026 — Réplica adaptada para Claude.ai, en español

---

## Licencia

MIT, igual que el original.
