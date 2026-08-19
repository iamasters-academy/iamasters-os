---
name: meta-start-here
description: Ritual de inicio de sesión para iAmasters OS. Carga el contexto necesario (operator-state, user.md, daily summary, learnings, proyectos abiertos), recapitula al operador qué dejó pendiente, y propone tarea del día. Se invoca al primer turno de cada sesión, automáticamente o por /start-here.
---

# meta-start-here

## Cuándo se invoca

- Primer mensaje de cualquier sesión (Claude lee `CLAUDE.md` y detecta esta skill como ritual de entrada)
- Usuario invoca `/start-here` explícitamente (slash command)
- Otra skill detecta deriva (ej: `meta-onboarding-wizard` finaliza y deriva aquí)

## Process

### Paso 1 · Detectar estado del repo

Lee en orden:

1. `~/.claude/skills/_operator-state.json`
   - ¿Existe? ¿`needsOnboarding: true`? → derivar a `meta-onboarding-wizard`
   - ¿`deepDiveCompleted: false` y han pasado >12h desde `onboardingDate`? → marcar flag interno `suggestDeepDive: true` (no derivar — solo recordar en el saludo, ver Paso 4)
2. `context/me.md` (o `context/user.md` legacy)
   - ¿Está vacío o sin rellenar? → derivar a `meta-onboarding-wizard`
3. `brand-context/voice/voice-profile.md`
   - ¿No existe o vacío? → sugerir ejecutar `marketing-brand-voice`

### Paso 2 · Cargar continuidad

Lee `context/working-memory.md` (scratchpad de trabajo) **primero** — es tu foto del estado actual:
- Si no existe → créalo con la cabecera de reglas y las 3 secciones vacías (Hilos activos / Notas de entorno / Decisiones pendientes). Es el bootstrap.
- Si existe → úsalo como base del saludo: qué hilos están abiertos, qué decisiones esperan al operador.

Lee `synapsis/daily-summaries/<TODAY>.md` o `<YESTERDAY>.md`:
- Si hay → resumir el "For tomorrow" en una línea
- Si no → primera sesión del día

Lee `context/learnings.md` (si > 200 chars):
- Identificar la última lección añadida

Lee `synapsis/projects.json` (Sinapsis):
- Filtrar proyectos con `status: active`
- Listar máximo 3 más recientes

Lee `projects/briefs/*/brief.md`:
- Filtrar los que tengan YAML frontmatter `status: active` o `phase: in-progress`

### Paso 3 · Sincronizar skills detectadas

Comprueba si hay `.claude/.skills-pending.json` (creado por hook `skill-change-detector.sh`):
- Si sí → actualizar `synapsis/skills-catalog.json` con las skills nuevas
- Limpiar el flag

### Paso 4 · Saludo contextual

Construir saludo según contexto detectado:

**Si hay daily summary de ayer:**
> "Hola {{nombre}}. Ayer cerraste con: {{summary}}.
> Para hoy proponías: {{for-tomorrow}}.
> ¿Sigues con eso, o cambiamos?"

**Si hay proyecto activo pero no daily summary:**
> "Hola {{nombre}}. Tienes el proyecto **{{nombre-proyecto}}** abierto en fase {{fase}}.
> ¿Continúas con él o vamos a otra cosa?"

**Si no hay nada activo:**
> "Hola {{nombre}}. ¿En qué te ayudo hoy?
>
> [1] Crear contenido (skills marketing-*)
> [2] Trabajar con un cliente (`/add-client` o `cd clients/<x>`)
> [3] Análisis estratégico (skills strategy-*)
> [4] Tarea libre — dime qué necesitas"

### Paso 4.5 · Recordatorio de deep-dive (si aplica)

Si en Paso 1 quedó `suggestDeepDive: true`, añade al final del saludo (no antes — el saludo principal va primero):

```
PD: aún no has completado el deep-dive del onboarding. El sistema te
conoce superficialmente. Cuando tengas 25 minutos, ejecuta `/deep-dive`
y refinamos.
```

Este recordatorio se muestra **cada vez** que el operador arranca, hasta que `deepDiveCompleted: true`. No es intrusivo (solo 1 línea), pero recuerda.

Si el operador ya completó la deep-dive (`deepDiveCompleted: true`), no menciones nada.

### Paso 5 · Si hay pending tasks de Sinapsis

Sinapsis puede tener instincts en draft pendientes de promote. Si en `~/.claude/skills/_instincts-index.json` hay 5+ drafts con `occurrences >= 3`:
- Mencionar al final del saludo: "(Tienes 5 instincts listos para revisar con `/analyze-session` cuando quieras)"

### Paso 6 · No hacer más

Importante: este ritual NO ejecuta tareas. Solo carga contexto y propone.
- Si el usuario respondió a la pregunta planteada → continúa con la tarea concreta (otra skill u acción directa).
- Si no → espera input.

## Outputs

- Mensaje al usuario con resumen + propuesta
- Update interno: `synapsis/skills-catalog.json` si hubo skill changes pending

## Skills que llama

- **`meta-onboarding-wizard`** — si detecta primer arranque
- **`marketing-brand-voice`** — opcionalmente si falta voice profile

## Skills que sugiere (sin invocar automáticamente)

- **`meta-deep-dive`** — si el operador completó el wizard inicial pero no la deep-dive (mostrado como PD al final del saludo, recordatorio diario hasta que se complete)

## Edge cases

- **No hay `.claude/skills/`**: el repo está corrupto o no instalado bien. Avisa al usuario y sugiere `bash scripts/install.sh`.
- **`operator-state.json` corrupto (JSON mal formado)**: recuperar de backup en `~/.claude/_backup_*` o derivar a re-onboarding.
- **Daily summary de hace 5+ días**: mejor empezar limpio que arrastrar contexto stale. Saludar como nueva sesión.

## Examples

**Caso 1 · Continuidad cálida:**
```
Operador: (abre Claude Code en lunes)
Skill: "Hola Marta. Viernes cerraste con el blog post de Stripe billing (status: pending review).
        Para hoy proponías: 'pasarlo por output-verifier y publicar'.
        ¿Sigues con eso?"
```

**Caso 2 · Sin actividad reciente:**
```
Operador: (abre tras 5 días sin abrir)
Skill: "Hola Marta. Hace tiempo. ¿En qué te ayudo hoy?
        [1] Crear contenido
        [2] Trabajar con un cliente (tienes 3: Acme, ContoSL, NorthStar)
        [3] Análisis estratégico
        [4] Tarea libre"
```

**Caso 3 · Primer arranque tras instalación:**
```
Skill: → detecta needsOnboarding: true
       → deriva a meta-onboarding-wizard
       (no muestra saludo propio)
```
