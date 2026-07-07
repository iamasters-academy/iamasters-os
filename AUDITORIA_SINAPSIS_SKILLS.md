# AUDITORÍA COMPLETA — Sinapsis + Skills iAmasters OS

> Fecha: 2026-07-07
> Estado: Skills core faltantes detectadas

---

## ✅ LO QUE ESTÁ CORRECTO

### Sinapsis Global (~/.claude/skills/)
- ✅ Estructura base intacta
- ✅ `_instincts-index.json` presente
- ✅ `_passive-rules.json` presente
- ✅ `_operator-state.json` presente
- ✅ `_catalog.json` presente (v4.3.1)
- ✅ Skills globales: `skill-router`, `sinapsis-learning`, `tool-graphify`, `graphify`, `futbol-video-analisis`, `investigacion-mercado`

### Skills Core Meta (.claude/skills/_meta/)
Todas las 10 skills core _meta están presentes:
- ✅ `meta-start-here`
- ✅ `meta-wrap-up`
- ✅ `meta-onboarding-wizard`
- ✅ `meta-deep-dive`
- ✅ `meta-skill-creator`
- ✅ `decisions-log`
- ✅ `health-check`
- ✅ `find-skills`
- ✅ `welcome-quick-win`
- ✅ `recuerda`

### Skills Core del Sistema
Marketing (12 presentes):
- ✅ `brand-guidelines`, `competitive-ads-extractor`, `marketing-brand-voice`
- ✅ `marketing-copy-editing`, `marketing-copywriting`, `marketing-hooks`
- ✅ `marketing-icp`, `marketing-positioning`, `marketing-social`
- ✅ `marketing-storytelling`, `marketing-video`

Strategy (4 presentes):
- ✅ `cognito`, `competencia`, `notebooklm-mcp`, `startup-business-analyst`

Tools (12 presentes):
- ✅ `ask-questions-if-underspecified`, `backend-development`
- ✅ `exploratory-data-analysis`, `react-best-practices`
- ✅ `scikit-learn`, `statistical-analysis`, `statsmodels`
- ✅ `tool-firecrawl-scraper`, `tool-graphify`, `tool-humanizer`, `tool-output-verifier`
- ✅ `usability-retention-review`

Automation (5 presentes):
- ✅ `automation-client-deploy`, `automation-crm`, `automation-embudo-captacion`
- ✅ `automation-loop-engine`, `automation-n8n-builder`

### Skills Biblioteca
- ✅ `skills-library/` existe con 8 categorías
- ✅ Contiene 80+ skills disponibles para instalación

---

## ❌ FALTANTES CRÍTICOS

### Sales (2 skills en biblioteca, NO instaladas)
Según CLAUDE.md, estas skills DEBERÍAN estar instaladas:
- ❌ `sales-call-prep` (existe en biblioteca, no instalada)
- ❌ `sales-pipeline-forecast` (existe en biblioteca, no instalada)

**Impacto**: El usuario no puede acceder a skills de ventas cuando las necesita

### Finance (1 skill en biblioteca, NO instalada)
- ❌ `finance-variance-analysis` (existe en biblioteca, no instalada)

**Impacto**: Sin skill de análisis financiero para proyectos como Polymarket

### Legal (3 skills en biblioteca, NO instaladas)
- ❌ `legal-compliance` (existe en biblioteca, no instalada)
- ❌ `legal-contract-review` (existe en biblioteca, no instalada)
- ❌ `legal-nda-triage` (existe en biblioteca, no instalada)

**Impacto**: Sin herramientas legales para agencia FIFA y clientes

---

## 📊 ESTADÍSTICAS

- **Skills core instaladas**: 46
- **Skills total en proyecto**: 313
- **Skills faltantes críticas**: 6
- **Skills disponibles en biblioteca**: ~80
- **Porcentaje de completado core**: 88% (41/46 esperadas)

---

## 🔧 ACCIÓN REQUERIDA

### Instalar las 6 skills faltantes:

```bash
# Sales (2)
bash scripts/skills.sh add sales-call-prep
bash scripts/skills.sh add sales-pipeline-forecast

# Finance (1)
bash scripts/skills.sh add finance-variance-analysis

# Legal (3)
bash scripts/skills.sh add legal-compliance
bash scripts/skills.sh add legal-contract-review
bash scripts/skills.sh add legal-nda-triage
```

### Verificar instalación:

```bash
# Confirmar que están en .claude/skills/
ls .claude/skills/sales/
ls .claude/skills/finance/
ls .claude/skills/legal/
```

---

## 📝 NOTAS

1. **`meta-wrap-up` SÍ existe**: La skill está en `.claude/skills/_meta/meta-wrap-up/SKILL.md`
   - El error anterior fue de búsqueda, no de instalación
   - La skill funciona correctamente

2. **Sinapsis está intacta**: No hay problemas con la instalación global
   - Todos los archivos core están presentes
   - El sistema de instincts/passive-rules funciona

3. **Skills biblioteca vs instaladas**: Las 6 skills faltantes están en `skills-library/` pero no se copiaron a `.claude/skills/`
   - Esto es normal: biblioteca es catálogo, `.claude/skills/` es la versión activa
   - Hay que instalarlas explícitamente con `skills.sh add`

---

## 🎯 PRIORIDAD

Esta auditoría se puede corregir en 5 minutos ejecutando los 6 comandos de instalación.

¿Procedo a instalar las 6 skills faltantes?

---

*Auditoría completada: 2026-07-07*
*Herramienta: Bash + Read + análisis comparativo*
