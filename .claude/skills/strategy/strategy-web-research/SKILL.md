---
name: strategy-web-research
description: Investiga temas online con búsqueda ligera de 3-5 fuentes, información actual y síntesis citada. Úsala para preguntas web acotadas, comparaciones rápidas o informes breves; si el usuario pide informe completo, triangulación, scoring de fuentes o análisis exhaustivo, usa `strategy-investigacion-profunda`. English triggers: web research, search the web, quick research report.
---

# Skill de investigación web

**Diferencia con `strategy-investigacion-profunda`:** esta skill es para búsqueda ligera y rápida con 3-5 fuentes. `strategy-investigacion-profunda` es para informes completos con triangulación, scoring de fuentes, evidencias persistidas y verificación de afirmaciones.

## Proceso de investigación

### Paso 1: crear y guardar el plan de investigación

Antes de delegar en subagentes, debes:

1. **Crear una carpeta de investigación** relativa al directorio actual:

   ```bash
   mkdir research_[nombre_del_tema]
   ```

   Así los archivos quedan organizados y no ensucian el directorio de trabajo.

2. **Analizar la pregunta de investigación** y dividirla en subtemas distintos, sin solapamiento.

3. **Escribir un archivo de plan** en `research_[nombre_del_tema]/research_plan.md` con:
   - Pregunta principal.
   - 2-5 subtemas concretos.
   - Qué información se espera de cada subtema.
   - Cómo se sintetizarán los resultados.

Guía de planificación:

- **Búsqueda factual simple**: 1-2 subtemas.
- **Análisis comparativo**: 1 subtema por elemento comparado, máximo 3.
- **Investigaciones complejas**: 3-5 subtemas.

### Paso 2: delegar a subagentes de investigación

Para cada subtema del plan:

1. Usa la herramienta `task` para crear un subagente de investigación con:
   - Pregunta clara y específica, sin acrónimos ambiguos.
   - Instrucciones para guardar hallazgos en `research_[nombre_del_tema]/findings_[subtema].md`.
   - Presupuesto máximo de 3-5 búsquedas web.

2. Ejecuta hasta 3 subagentes en paralelo cuando sea eficiente.

Plantilla para subagentes:

```text
Investiga [TEMA ESPECÍFICO]. Usa web_search para recopilar información.
Cuando termines, usa write_file para guardar tus hallazgos en research_[nombre_del_tema]/findings_[subtema].md.
Incluye hechos clave, citas relevantes y URLs fuente.
Usa 3-5 búsquedas web como máximo.
```

### Paso 3: sintetizar hallazgos

Cuando terminen los subagentes:

1. **Revisa los archivos locales de hallazgos**:
   - Primero ejecuta `list_files research_[nombre_del_tema]`.
   - Después usa `read_file` con rutas locales, por ejemplo `research_[nombre_del_tema]/findings_*.md`.
   - Importante: usa `read_file` solo para archivos locales, no para URLs.

2. **Sintetiza la información**:
   - Responde directamente a la pregunta original.
   - Integra insights de todos los subtemas.
   - Cita fuentes concretas con URL.
   - Señala lagunas, límites o incertidumbre.

3. **Escribe informe final** si el usuario lo pide:

   ```text
   research_[nombre_del_tema]/research_report.md
   ```

Nota: si necesitas consultar información adicional desde una URL, usa `fetch_url`, no `read_file`.

## Buenas prácticas

- Planifica antes de delegar.
- Mantén subtemas claros y sin solapamiento.
- Haz que los subagentes guarden hallazgos en archivos.
- Lee todos los hallazgos antes de responder.
- No sobreinvestigues: 3-5 búsquedas por subtema suelen bastar.
