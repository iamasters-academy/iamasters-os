---
description: Genera el informe semanal "¿Cómo se está usando la IA en medicina?" (deep-research + HTML + PDF) y lo envía a WhatsApp por CallMeBot. Pensado para correr cada lunes (manual o programado).
---

# Informe semanal — IA en medicina

Eres un agente de investigación. Hoy generas el informe semanal **"¿Cómo se está usando la inteligencia artificial en medicina?"** de forma autónoma, de punta a punta.

## Paso 1 · Investigar (strategy-deep-research)

Invoca la skill **`strategy-deep-research`** en **modo mixto (médico + web)** con esta pregunta:

> Novedades de las **últimas 1-2 semanas** sobre aplicaciones reales de la inteligencia artificial en medicina: herramientas clínicas nuevas, estudios y ensayos publicados, aprobaciones o pronunciamientos regulatorios (FDA, EMA, OMS), IA en diagnóstico/imagen/oncología/atención primaria/administración clínica, y debates o riesgos relevantes.

Reglas:
- **Prioriza fuentes primarias/oficiales**: PubMed para estudios (filtra por fecha reciente), webs de FDA/EMA/OMS, papers, comunicados oficiales. Los blogs solo como pista hacia la fuente primaria.
- Profundidad **estándar (2 rondas)**. Idioma **español**.
- Caracteriza conflictos y marca lo no verificado.

Output: `report.md` citado (Vancouver para lo científico, tabla web para lo demás) en:
`projects/strategy-deep-research/<YYYY-MM-DD>-ia-medicina-semanal/`

## Paso 2 · HTML (tool-visual-explainer)

Invoca **`tool-visual-explainer`** para generar `report.html` en la misma carpeta, con la **plantilla de marca** (hero con degradado, secciones numeradas, footer "Generado por Dr. Juan Camilo Paris"). Estructura de secciones: Resumen ejecutivo (KPIs + bullets), Hallazgos por tema, Conflictos/confianza, Vacíos, Referencias.

## Paso 3 · Publicar y entregar por WhatsApp

**3a. Publicar** — ejecuta el script (genera PDF con Chrome, sube HTML + PDF a GitHub Pages `reportes-ia-medicina`, imprime los enlaces):

```bash
bash scripts/enviar-informe-whatsapp.sh "projects/strategy-deep-research/<YYYY-MM-DD>-ia-medicina-semanal/report.html"
```

El script imprime `PUBLISHED_HTML=...` y (si Chrome estaba disponible) `PUBLISHED_PDF=...`. Si no hay PDF, sigue solo con el enlace web.

**3b. Enviar WhatsApp** — con los enlaces que imprimió el script, envía vía CallMeBot. Dentro de Claude Code `curl` está bloqueado, así que usa **WebFetch** a:

```
https://api.callmebot.com/whatsapp.php?phone=<CALLMEBOT_PHONE>&text=<mensaje-urlencoded>&apikey=<CALLMEBOT_APIKEY>
```

Credenciales en `.env.local` (`CALLMEBOT_PHONE`, `CALLMEBOT_APIKEY`). Mensaje sugerido (URL-encoded): título + "Leer en web: <PUBLISHED_HTML>" + "Descargar PDF: <PUBLISHED_PDF>".

Fuera de Claude (Tarea Programada de Windows), el mismo envío se hace con `curl` al mismo endpoint.

Si algo falla, NO inventes el envío: reporta el error y deja el HTML/PDF en la carpeta para envío manual.

## Paso 4 · Cierre

Termina con un **resumen de 3 líneas** de lo más relevante de la semana, y la ruta de los archivos generados.

## Notas para corridas automáticas (headless)

- Si el MCP de PubMed o las herramientas web NO están disponibles en la corrida programada, haz lo que puedas con lo disponible, **dilo explícitamente** en el informe y no inventes fuentes.
- No publiques datos de pacientes ni información sensible: este informe usa solo literatura y fuentes públicas.
