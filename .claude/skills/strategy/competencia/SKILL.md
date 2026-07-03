---
name: competencia
description: Inteligencia competitiva con NotebookLM, web intelligence y workflows comparativos estructurados para extraer insights, oportunidades y fortalezas. Úsala cuando el operador diga o pida "analiza a mi competencia", "qué hacen los competidores", "compara nuestra app con la de X", "inteligencia competitiva", "extrae insights de la competencia", "qué oportunidades hay frente a los rivales" o estudie a fondo a un competidor concreto. Encadena con competitive-ads-extractor (entrada) y startup-business-analyst (salida).
license: Complete terms in LICENSE.txt
---

# 🕵️‍♂️ Competitor Intelligence Expert Skill

## About this Skill

This skill provides a **modular, multi-step workflow** to perform advanced competitive analysis:

* Analyzes **NotebookLM notebooks** for competitor insights using [notebooklm-mcp](../notebooklm-mcp/SKILL.md)
* Performs **web intelligence** searches to capture reviews, pricing, and marketing data
* Compares competitors’ features, UX/UI, retention, gamification, integrations
* Generates structured **recommendations and opportunity reports** for your app
* Supports **subagents** and **internal debates** to refine conclusions
* Designed to integrate with existing apps or analytics pipelines

---

## Core Principles

1. **Concise Knowledge** – Only add information Claude doesn’t already have.
2. **Sequential + Conditional Workflows** – Follow clear step sequences; adjust path if creating new insight or validating existing features.
3. **Progressive Disclosure** – Load notebooks, references, or detailed web data only as needed.
4. **Expert Judgment** – Default patterns guide analysis, but the agent can adapt based on observed competitor complexity.

---

## Anatomy of this Skill

* **SKILL.md** – Procedural instructions, triggers, and output patterns
* **scripts/** – Optional scripts to parse notebooks, scrape web data, or analyze JSON/CSV exports
* **references/** – Templates, competitor lists, example outputs
* **assets/** – Optional icons, CSVs, or images for reporting

---

## Workflows

### Sequential Workflow

1. **Setup & Initialization**

   * Verify access to competitor notebooks
   * Load URLs, app modules, and screens
   * Activate all relevant skills (`Notebooklm-mcp`, `perplexity-ask`, `adversarial-specconsulta`, `startup-business-analyst`)

2. **Notebook Intelligence Extraction**

   * Summarize all sources with type, description, and 2–3 line summary
   * Extract competitor **features, UX/UI patterns, microinteractions, gamification, integrations**
   * Identify **differentiators** and **weaknesses**

3. **Web Intelligence Analysis**

   * Scrape reviews, ratings, complaints, praise, updates
   * Track pricing models, release cadence, app store metrics

4. **UX/UI Analysis**

   * Onboarding, main actions, empty states
   * Microinteractions, hierarchy, accessibility issues
   * Compare with own app to identify gaps

5. **Retention & Gamification Analysis**

   * Hooks, badges, progress tracking, social, variable rewards
   * Compare with own retention strategies to find quick wins

6. **Feature Gap & Opportunity Mapping**

   * Classify features: core / secondary / nice-to-have
   * Identify missing features or areas for differentiation
   * Detect “oceans azules” y oportunidades únicas

7. **Marketing & Positioning**

   * Analyze ads, branding, copy, value proposition
   * Extract points fuertes y oportunidades de diferenciación

8. **Reporting**

   * Generate structured Markdown or PDF with:

     * Summary of competitors
     * Strengths & weaknesses
     * Feature comparison vs app
     * UX/UI insights
     * Retention & gamification insights
     * Marketing insights
     * Recommendations & roadmap

---

### Conditional Workflow

* **Creating new competitor report** → Follow full sequential workflow
* **Updating existing report** → Only extract deltas from notebooks or web intelligence

---

## Output Patterns

### Template Pattern

```
# Competitor Analysis Report
## Summary
- Total Competitors Analyzed: X
- Key Strengths: ...
- Key Weaknesses: ...
## Features Comparison
| Feature | Competitor 1 | Competitor 2 | Our App |
|---------|--------------|--------------|---------|
...
## UX/UI Insights
- Flow Efficiency:
- Microinteractions:
- Accessibility Issues:
## Retention & Gamification
- Hooks & Rewards:
- Social Features:
## Marketing & Positioning
- Ads / Copy / Brand Differentiators
## Opportunities & Recommendations
1. Quick Wins
2. Medium-Term Projects
3. Long-Term Strategic Initiatives
```

### Examples Pattern

**Input:** NotebookLM URL + Competitor List + App Modules
**Output:** Markdown report with all sections filled, tables populated, and insights highlighted

---

## Subagents

| Subagent                | Role                                                 | Output                                 |
| ----------------------- | ---------------------------------------------------- | -------------------------------------- |
| UX-PSYCH-ENFORCER       | Detect cognitive overload & UX errors in competitors | UX alerts                              |
| VISUAL-DOMINANCE-ENGINE | Analyze hierarchy, visual focus                      | Visual recommendations                 |
| PRODUCT-TRUTH-AGENT     | Evaluate feature value vs our app                    | Strengths/Weaknesses                   |
| NOTEBOOK-CURATOR        | Maintain notebook history & insights                 | Pattern detection, historical insights |

---

## Internal Debates

| Debate                | Participants                    | Question                               | Output                         |
| --------------------- | ------------------------------- | -------------------------------------- | ------------------------------ |
| UX vs Product         | UX skill, Product-Truth         | Optimize experience or business value? | Trade-offs, recommended action |
| Design vs Performance | Visual-Dominance, Code-Surgeon  | Animation cost vs benefit              | Maintain/Simplify/Remove       |
| Innovation vs Copy    | Adversarial-Spec, Product-Truth | Real differentiation or superficial?   | Decision                       |
| Author vs Critic      | Main skill, Growth-Analysis     | Quality vs speed trade-offs            | Adjusted priority              |

---

## Deliverables

| # | Deliverable                     | Format   | Phase |
| - | ------------------------------- | -------- | ----- |
| 1 | Notebook Intelligence Report    | MD       | 1     |
| 2 | Web Intelligence Summary        | MD       | 2     |
| 3 | UX/UI Comparative Analysis      | MD       | 3     |
| 4 | Retention & Gamification Table  | MD       | 4     |
| 5 | Feature Gap Matrix              | Table MD | 5     |
| 6 | Marketing Insights              | MD       | 6     |
| 7 | Final Recommendations & Roadmap | MD/PDF   | 8     |

---

## Post-Review

* Store results in `brain/[conversation-id]/`
* Update workflow as competitors evolve
* Metrics: engagement, retention, onboarding, NPS, rating trends

---

💡 Este skill está diseñado para ser **un espía completo de la competencia**, integrando:

* Notebooklm-mcp / fuentes internas
* Web intelligence
* UX/UI comparativo
* Retención & gamificación
* Marketing & positioning
* Entregables listos para análisis estratégico

---


---

## Perfilado estructurado desde URLs — fusión de `coreyhaines31/marketingskills` (`competitor-profiling`)

> Complementa el flujo NotebookLM/subagentes de arriba con un **perfilado reproducible desde la web
> del competidor**: scraping con [[tool-firecrawl-scraper]], plantilla comparable y dos niveles de
> profundidad. Un fichero por competidor en `competitor-profiles/<nombre>.md`; al final, un
> `_summary.md` con tabla comparativa, mapa de posicionamiento y huecos.

### Principios
Hechos > opiniones · estructurado y comparable (mismas métricas para todos) · datos actuales · evaluación honesta (también las fortalezas del rival).

### Proceso
1. **Scraping (Firecrawl)** — home + pricing (+ páginas clave en deep). Guarda el crudo con fecha.
2. **SEO/mercado** — rank de dominio, keywords, tráfico estimado, backlinks (si hay fuente de datos).
3. **Síntesis** — rellena la plantilla; construye el `_summary.md` al final.

### Plantilla de perfil (comparable)
```markdown
# [Competidor] — Perfil

**URL**: [web] · **Generado**: [fecha] · **Profundidad**: [quick scan / deep profile]

## De un vistazo
| Métrica | Valor |
|---|---|
| Tagline | … | 
| Fundación / HQ / equipo / funding | … |
| Rank de dominio / tráfico orgánico est. / referring domains / keywords | … |

## Posicionamiento y mensaje
Propuesta de valor · audiencia objetivo · ángulo de posicionamiento · temas de mensaje (con página fuente).

## Producto y features
Capacidades núcleo · diferenciadores · integraciones · señales de dirección de producto (changelog).

## Precios
| Tier | Precio | Incluye |
|---|---|---|
Billing (mensual/anual) · free trial · rarezas (per-seat, uso, costes ocultos).

## Clientes y prueba social
Logos · industrias · temas de casos · ratings (G2/Capterra con nº de reseñas).

## SEO y contenido
Tráfico orgánico est. · top páginas por tráfico · frecuencia y tipos de contenido · perfil de backlinks.

## Fortalezas y debilidades
Con evidencia/fuente en cada punto.

## Implicaciones para [tu producto]
Dónde son fuertes vs. nosotros · dónde somos fuertes vs. ellos · oportunidades · amenazas.

## Fuentes de datos crudos
Fechas de scraping/pull por sección.
```

### Quick Scan vs Deep Profile
- **Quick scan** (rápido, barato): home + pricing; SEO resumen; salida abreviada (De un vistazo + Posicionamiento + Precios + SEO). **Por defecto.**
- **Deep profile**: todas las páginas clave + reseñas; backlinks + keyword intelligence + stack; plantilla completa. Úsalo si el operador lo pide o hay ≤3 competidores.

### Varios competidores
Paraleliza el scraping (todas las home a la vez, luego pricing…) · mismas métricas para todos ·
`_summary.md` al final · si hay 10+, prioriza el top 5 por solape de dominio. Perfiles = fotos:
al actualizar, revisa pricing primero, re-pull SEO, escanea changelog, y anota cambios en `## Change Log`.
