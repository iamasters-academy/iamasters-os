---
name: daily-brief
description: Genera un resumen de correo prioritario y agenda del día (Gmail + Google Calendar), cruzado con los pendientes internos de working-memory.md y los proyectos activos. Úsala cuando el operador diga "brief de hoy", "resúmeme el correo y la agenda", "qué tengo hoy", "daily brief", o acepte la oferta matutina de `meta-start-here`.
tags: [daily-brief, gmail, calendar, mcp, rutina-matutina]
alwaysActive: false
---

# daily-brief

## Overview

Ritual matutino, independiente de `meta-start-here`. Mientras `meta-start-here`
carga contexto 100% local (rápido, obligatorio, corre en cada sesión),
`daily-brief` cruza fuentes **externas** (Gmail, Google Calendar) — solo se
ejecuta cuando el operador lo pide o acepta la oferta puntual de
`meta-start-here`, nunca de forma automática ni bloqueante.

Cierra el ciclo del día junto a `synapsis/daily-summaries/<fecha>.md` (que
genera `meta-wrap-up`/`/eod` al cerrar): el brief abre el día, el summary lo
cierra. Viven en el mismo directorio padre (`synapsis/`) pero sin dependencia
dura entre ambos.

## Pre-requisitos

- Conector MCP de Gmail conectado a la cuenta del operador (tools tipo
  `search_threads`, `get_thread`).
- Conector MCP de Google Calendar conectado (tools tipo `list_events`).
- Ninguno de los dos está declarado en `.mcp.json` del repo — son conectores
  de cliente/cuenta, no de proyecto. Si no están conectados esta sesión, la
  skill degrada esa sección explícitamente (ver Paso 1).
- **Drive no está soportado todavía** (ver Paso 4) — no hay conector
  disponible en este entorno.

## Process

### Paso 1 · Cargar tools MCP por capacidad, no por ID

Los IDs de conector (`mcp__<uuid>__...`) pueden variar entre sesiones y
cuentas — nunca los hardcodees. Usa `ToolSearch` para localizarlos por lo que
hacen:

```
ToolSearch("gmail search threads")
ToolSearch("calendar list events")
```

- Si `ToolSearch` no devuelve un tool de Gmail → la sección "Correo
  prioritario" del brief se marca como `No conectado esta sesión.` y se
  continúa con el resto.
- Si no devuelve uno de Calendar → igual con "Agenda de hoy".
- Nunca falles en seco por un conector ausente — el brief se genera siempre,
  con lo que haya disponible.

### Paso 2 · Agenda de hoy

Con la tool de `list_events` (calendario primario), rango hoy 00:00–23:59 en
la timezone del operador (lee `context/me.md`, campo Timezone; si no está,
`Europe/Madrid`).

Para cada evento: hora, título, asistentes. Si dos eventos se solapan,
márcalo con `⚠️ solape con <evento>`.

### Paso 3 · Correo prioritario

Con la tool de `search_threads`, acota la ventana temporal a las últimas 24h
**o** desde la fecha del último `synapsis/daily-briefs/<fecha-anterior>.md`
si existe uno más reciente que 24h — lo que sea más amplio, para no perder
hilos si el operador lleva días sin pedir el brief. No proceses todo el
inbox histórico.

Por cada hilo relevante: una línea con remitente + resumen de una frase +
si pide acción (`[acción requerida]`) o es solo informativo (`[FYI]`).
Prioriza remitentes desconocidos con asunto urgente y threads con múltiples
respuestas recientes por encima de newsletters/notificaciones automáticas.

### Paso 4 · Drive (hueco explícito, no implementado)

No hay conector de Google Drive disponible en este entorno. La sección se
genera siempre con este texto fijo — no lo omitas ni lo inventes:

```
## Drive
No conectado en este entorno. Pendiente: conectar el MCP de Google Drive y
añadir aquí la llamada equivalente a list_files/search.
```

### Paso 5 · Cruce con contexto interno

Reutiliza lo que ya existe, no lo recalcules desde cero:

- `context/working-memory.md` → sección "Decisiones pendientes"
- `projects/briefs/*/brief.md` con `status: active` en el frontmatter

Lístalos tal cual, sin repetir el saludo completo de `meta-start-here` (esta
skill no saluda ni pregunta "¿en qué te ayudo hoy?" — eso es trabajo de
`meta-start-here`).

### Paso 6 · Guardar el brief

Escribe en `synapsis/daily-briefs/<YYYY-MM-DD>.md` (crea el directorio si no
existe):

```markdown
# Daily Brief — YYYY-MM-DD

## Agenda de hoy
- HH:MM — <evento> (<asistentes>) [⚠️ solape con ...]

## Correo prioritario
- <remitente> — <resumen 1 línea> [acción requerida / FYI]

## Drive
No conectado en este entorno. Pendiente: conectar el MCP de Google Drive y
añadir aquí la llamada equivalente a list_files/search.

## Pendientes internos
- <ítem de working-memory o proyecto activo>
```

### Paso 7 · Responder al operador

No repitas el archivo entero en el chat — un resumen corto (5-8 líneas:
lo más urgente de agenda + correo + 1-2 pendientes internos destacados) y
cierra con algo como "¿seguimos con esto o cambiamos de tema?".

## Outputs

- `synapsis/daily-briefs/<fecha>.md`
- Mensaje al operador con el resumen corto

## Edge cases

- **Ni Gmail ni Calendar conectados**: genera igualmente el brief con ambas
  secciones marcadas como "no conectado" + Drive + pendientes internos. No
  es un error, es un brief parcial.
- **Ya existe un brief de hoy**: pregunta si quiere regenerarlo (por ejemplo
  si ha pasado el mediodía y quiere refrescar correo) en vez de sobreescribir
  en silencio.
- **`context/me.md` sin timezone**: usa `Europe/Madrid` por defecto y dilo
  explícitamente en la respuesta, no en silencio.
