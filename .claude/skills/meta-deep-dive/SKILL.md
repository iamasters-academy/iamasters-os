---
name: meta-deep-dive
description: Segunda fase del onboarding tras `meta-onboarding-wizard`. NO es un formulario — es una entrevista conversacional adaptativa que profundiza 22-25 dimensiones residuales sobre la persona (ritmos, motivadores, comunicación), el negocio (salud financiera, diferencial, fricciones), el equipo (dinámica, delegación, clientes top/tóxicos) y el foco (decisiones pendientes, metas 3 años, miedos, métricas, definición de éxito). Aplica reglas de profundización y técnicas conversacionales — nunca lista plana de preguntas. Cubre con branching condicional (si trabaja solo, salta bloque equipo). Termina cuando todas las dimensiones aplicables tienen dato sólido. Idempotente — retoma donde quedó.
---

# meta-deep-dive

> Segunda fase del onboarding. Profundiza al operador. El sistema ya funciona tras el wizard inicial, pero te conoce superficialmente. Esto es lo que convierte outputs "decentes" en outputs que parecen tuyos de verdad.

## Cuándo se invoca

- Usuario ejecuta `/deep-dive` explícitamente
- `meta-start-here` sugiere ejecutarla si `operator-state.deepDiveCompleted === false` y han pasado >12h desde el wizard inicial
- Usuario retoma una deep-dive a medias (`operator-state.deepDiveProgress` indica dimensiones cubiertas)

NO se invoca:
- Si `operator-state.needsOnboarding === true` → primero lanzar `meta-onboarding-wizard`
- Si `operator-state.deepDiveCompleted === true` y no hay petición explícita

## Filosofía

Misma que el wizard inicial: **no es un formulario, es conversación adaptativa**. Las preguntas las decides en cada turno según la respuesta anterior. Lo que está fijo son las **dimensiones a cubrir** y las **reglas de profundización**.

La diferencia con el wizard inicial: aquí profundizas en áreas que requieren **honestidad y reflexión**, no solo factuales. El operador puede sentirse expuesto. Tu tono es de **entrevistador profesional**, no de coach motivacional.

## Las 22-25 dimensiones a cubrir

Lee [`references/dimensiones-deep.md`](references/dimensiones-deep.md) para el detalle completo de cada una con qué información debe quedar capturada.

| # | Dimensión | Bloque | Archivo destino |
|:--|---|---|---|
| 1 | Horario productivo | A · Persona | `context/me.md` |
| 2 | Interrupciones principales | A · Persona | `context/me.md` |
| 3 | Contexto vital relevante | A · Persona | `context/me.md` |
| 4 | Motivadores profundos | A · Persona | `context/me.md` |
| 5 | Drenadores | A · Persona | `context/me.md` |
| 6 | Estilo preferido de comunicación con IA | A · Persona | `context/soul.md` |
| 7 | Palabras/tonos prohibidos | A · Persona | `context/soul.md` |
| 8 | Salud financiera (rango facturación) | B · Negocio | `context/work.md` |
| 9 | Margen aproximado | B · Negocio | `context/work.md` |
| 10 | Ticket medio | B · Negocio | `context/work.md` |
| 11 | Diferencial real (no genérico) | B · Negocio | `context/work.md` |
| 12 | Side projects / negocios paralelos | B · Negocio | `context/work.md` |
| 13 | Fricciones del modelo | B · Negocio | `context/work.md` |
| 14 | Tamaño equipo (gate condicional) | C · Equipo | `context/team.md` |
| 15 | Roles + dinámica del equipo | C · Equipo · si aplica | `context/team.md` |
| 16 | Comunicación interna | C · Equipo · si aplica | `context/team.md` |
| 17 | Delegación (qué sí/qué no) | C · Equipo · si aplica | `context/team.md` |
| 18 | Clientes top (3-5 nombres + facturación aprox) | C · Equipo · siempre | `context/team.md` |
| 19 | Clientes problemáticos | C · Equipo · siempre | `context/team.md` |
| 20 | Decisión pendiente | D · Foco | `context/current-priorities.md` |
| 21 | Meta 3 años profesional | D · Foco | `context/goals.md` |
| 22 | Meta 3 años vital (no profesional) | D · Foco | `context/goals.md` |
| 23 | Miedo profesional | D · Foco | `context/goals.md` |
| 24 | Métrica semanal de seguimiento | D · Foco | `context/goals.md` |
| 25 | Definición personal de éxito | D · Foco | `context/goals.md` |

**Definición de "done"**: cada dimensión aplicable tiene al menos 1 dato sólido (no genérico, no "no sé" sin justificación, no respuesta evasiva).

**Tiempo objetivo**: 25-30 minutos. Si tarda más, algo va mal con la profundización.

## Reglas de profundización (mismas que el wizard)

Lee [`references/tecnicas-conversacionales.md`](references/tecnicas-conversacionales.md) para el repertorio completo.

Resumen:
- Respuesta corta/abstracta → 1 follow-up con técnica (ejemplo concreto, 5 whys ligero, inversión, espejo, anclaje temporal).
- Máximo 2 niveles de profundidad por dimensión.
- Respuesta rica → salta a siguiente dimensión.
- Usuario muestra fatiga → acelera o propone parar.

## Anti-formulario (prohibido)

Las mismas reglas que el wizard inicial. Lee [`references/tecnicas-conversacionales.md`](references/tecnicas-conversacionales.md) sección "Lo que NO es técnica conversacional".

Especialmente importante en deep-dive (porque hay dimensiones emocionales):
- ❌ "Qué interesante", "buena respuesta" → suena a coach malo.
- ❌ Tono terapéutico ("¿cómo te hace sentir?") — no eres su terapeuta.
- ❌ Juicio implícito si el usuario admite algo (cliente tóxico, miedo, contradicción).
- ❌ Anunciar bloques o numerar dimensiones al usuario.

## Process

### Paso 1 · Apertura

Comprueba `operator-state.deepDiveProgress`:
- Si NO existe (primera vez): apertura completa.
- Si EXISTE: retoma con apertura corta indicando dónde se quedó.

**Apertura completa** (primera vez):

```
Vamos al deep-dive.

Lo de la otra vez fue lo mínimo para arrancar. Esto profundiza
otras 20-25 áreas que cambian mucho los outputs del sistema:
cómo trabajas, cómo te ganas la vida, tu equipo si lo tienes,
tus metas a 3 años, tus miedos profesionales.

Tarda ~25 minutos. Es honesto — algunas preguntas son
incómodas. Si no quieres contestar alguna, dilo y paso. Si
quieres parar a la mitad, también — la próxima vez retomamos
donde estés.

¿Listo? Empezamos por cómo trabajas tú, antes de meternos en
el negocio.
```

**Apertura retomando** (segunda+ sesión):

```
Volvemos al deep-dive. La última vez nos quedamos en
<dimensión última cubierta>. Quedan ~<N> dimensiones (~<min> min).

Si quieres pausar de nuevo, dilo cuando quieras. ¿Continuamos?
```

### Paso 2 · Entrevista adaptativa

Recorre las dimensiones aplicables en este orden (NO lo anuncies):

**Bloque A · Persona profunda** (dimensiones 1-7)
- 1 Horario productivo → "¿En qué horario del día rindes mejor? ¿Mañana, tarde, noche, mix?"
- 2 Interrupciones → "¿Qué te interrumpe más en tu día a día? ¿Clientes, equipo, familia, distracciones propias?"
- 3 Contexto vital → "¿Hay algo de tu contexto vital ahora mismo que el sistema deba tener en cuenta? Hijos pequeños, salud, mudanza, viajes... lo que afecte tu energía. Si no quieres, también vale 'no aplica'."
- 4 Motivadores → "Más allá del dinero, ¿qué te motiva profesionalmente? Sé concreto si puedes."
- 5 Drenadores → "¿Qué tipo de tareas te drenan al punto de evitarlas?"
- 6 Estilo IA → "¿Cómo prefieres que te hable la IA? Directa sin rodeos, conversacional, formal, con humor..."
- 7 Palabras prohibidas → "¿3-5 palabras, frases o tonos que NUNCA debería usar en outputs tuyos? Corporate-speak, modismos que odias, lo que sea."

**Bloque B · Negocio profundo** (dimensiones 8-13)
- 8 Salud financiera → "¿Cuánto facturas aproximadamente al mes? Rango está bien. Esto cambia mucho qué te puede recomendar el sistema, por eso pregunto."
- 9 Margen → "¿Margen bruto aproximado? Bajo, medio, alto."
- 10 Ticket medio → "¿Cuál es tu ticket medio por cliente o por venta?"
- 11 Diferencial real → "¿En qué eres realmente diferente de tu competencia? No genérico — algo concreto que te llevarías al pitch comercial."
- 12 Side projects → "¿Tienes negocios secundarios o proyectos paralelos? Aunque sean side projects sin revenue."
- 13 Fricciones → "¿Qué parte de tu modelo te gustaría cambiar pero no has cambiado todavía? ¿Por qué no?"

**Bloque C · Equipo y clientes** (dimensiones 14-19)
- 14 Tamaño equipo → "¿Cuántas personas hay en tu día a día? Tú solo / 1-3 / 4-10 / más de 10."
- **Si "solo"**: salta dimensiones 15-17. Pasa directo a 18-19.
- **Si tiene equipo**: dimensiones 15-17.
  - 15 Roles → "Pásame a las personas clave. Para cada una: nombre, qué hace, en qué es fuerte, dónde flojea. Sin filtros."
  - 16 Comunicación → "¿Cómo os comunicáis? Slack, WhatsApp, reuniones semanales, async..."
  - 17 Delegación → "¿Qué partes del negocio están delegadas hoy y qué te niegas a delegar? ¿Por qué te cuesta?"
- 18 Clientes top → "¿Tus 3-5 clientes/proyectos más importantes ahora mismo? Nombre + facturación aproximada."
- 19 Clientes problemáticos → "¿Hay clientes tóxicos o problemáticos a los que aguantas por dinero? Honestidad."

**Bloque D · Foco profundo** (dimensiones 20-25)
- 20 Decisión pendiente → "¿Qué decisión importante tienes pendiente de tomar ahora mismo?"
- 21 Meta 3 años pro → "Mírate dentro de 3 años. ¿Qué te imaginas profesionalmente? Sin presión."
- 22 Meta 3 años vital → "Misma pregunta pero personal/vital. Familia, salud, lifestyle, lo que no es trabajo."
- 23 Miedo profesional → "¿Cuál es tu mayor miedo profesional ahora mismo?"
- 24 Métrica semanal → "¿Qué métrica miras semanalmente para saber si vas bien?"
- 25 Definición de éxito → "¿Cómo defines éxito personal en los próximos 12 meses, más allá de los KPIs?"

Para cada respuesta, aplica las **reglas de profundización** y las **técnicas conversacionales**. Respeta los **anti-patrones**.

### Paso 3 · Checkpoints cada 7 dimensiones

Tras dimensiones 7, 13, 19 — checkpoint corto:

```
Has hecho <bloque>. Quedan <N> dimensiones más, ~<min> min.

¿Continuamos o lo dejamos aquí y mañana retomamos?
```

Si dice "seguimos" → continúa.
Si dice "para" → guarda progreso, cierra con apertura retomable.

### Paso 4 · Escritura de archivos

Solo cuando termina (o cuando para a mitad), escribe los archivos sectorizados.

**Importante**: el deep-dive **completa** los archivos sectorizados existentes, **no los reemplaza**. Lee el archivo actual, añade las secciones nuevas según `references/dimensiones-deep.md`, conserva lo que el wizard inicial dejó.

Archivos afectados:
- `context/me.md` — secciones de horario, interrupciones, contexto vital, motivadores, drenadores
- `context/soul.md` — sección "Cómo me hablas tú" + "Palabras prohibidas"
- `context/work.md` — secciones financieras, diferencial, side projects, fricciones
- `context/team.md` — estructura, roles, comunicación, delegación, clientes top/tóxicos
- `context/current-priorities.md` — sección "Decisiones abiertas"
- `context/goals.md` — meta 3 años pro/vital, miedo, métrica, definición éxito

### Paso 5 · Cierre

Si completó el 100%:

```
Deep-dive completo.

El sistema ahora te conoce profundamente. Los outputs van a salir
con tu voz, tu criterio y tu contexto real — no genéricos.

He actualizado:
  ✓ context/me.md — ritmos, motivadores, contexto vital
  ✓ context/soul.md — cómo te hablo y palabras que evito
  ✓ context/work.md — salud financiera, diferencial, fricciones
  <si aplica> ✓ context/team.md — equipo, comunicación, delegación
  ✓ context/team.md — clientes top y problemáticos
  ✓ context/current-priorities.md — decisión pendiente
  ✓ context/goals.md — metas 3 años, miedo, métricas, éxito

A partir de aquí: úsalo. Si en algún momento las respuestas no
te suenan a ti, ejecuta `/deep-dive refine` y refinamos lo que
chirríe.
```

Marca `operator-state.deepDiveCompleted: true`.

Si se quedó a medias:

```
Pausa registrada. Llevas <N> de 25 dimensiones cubiertas.

Cuando quieras retomar:  /deep-dive

Te lo sugeriré también desde /start-here hasta que lo cierres.
```

Guarda `operator-state.deepDiveProgress: <N>` y `deepDiveLastDimension: <id>`.

### Paso 6 · Append al daily summary

En `~/.claude/skills/_daily-summaries/<TODAY>.md`:

```
## Deep-dive · sesión <N>
- Dimensiones cubiertas hoy: <lista>
- Estado: <completo | parcial>
- Archivos actualizados: <lista>
```

NO appends en `context/learnings.md` (esto no es feedback de skill).

## Outputs

- `context/me.md` ampliado
- `context/soul.md` con estilo personal del operador
- `context/work.md` ampliado con datos financieros y diferencial
- `context/team.md` rellenado (o consolidado si trabaja solo)
- `context/current-priorities.md` con decisión pendiente
- `context/goals.md` ampliado con metas 3 años, miedo, métricas, éxito
- `operator-state.deepDiveCompleted: true` (si completo)
- `operator-state.deepDiveProgress: <N>` (si parcial)

## Edge cases

- **Usuario abandona en medio de un follow-up**: guarda hasta la última dimensión cerrada. NO marca la dimensión en curso como capturada si solo tiene el primer intento débil.
- **Usuario nivel técnico cero, asustado por dimensiones financieras (8-10)**: ofrécele rangos en vez de cifras exactas: "Si te incomoda el número exacto, dame un rango: bajo / medio / alto, te vale igual."
- **Usuario no tiene equipo pero menciona colaboradores externos** (freelances, contratistas): captúralos en `team.md` con nota "Equipo externo / colaboradores".
- **Usuario admite cliente tóxico pero pide no anotarlo por nombre**: respeta. Anota "<Cliente tipo X — tóxico por motivo Y>" sin nombre concreto.
- **Usuario contradicción entre dimensiones** (ej. dice motivador = libertad, drenador = cliente que da libertad): no debates. Apunta ambas y deja al usuario que reflexione después leyendo `me.md`.
- **Usuario completa deep-dive demasiado rápido (<10 min)**: probablemente respondió por encima. Cierra el wizard, pero anota en daily summary "deep-dive express — refinar en sesión futura".

## Skills relacionadas que llamar después

Si el operador menciona en el deep-dive un problema concreto, sugiere skill al cerrar:

- Confusión con ICP → `marketing-icp`
- Falta de claridad en voice profile → `marketing-brand-voice`
- Decisión pendiente compleja → `seis-sombreros`
- Cuello de botella operacional → `marketing-content-repurposing` o automation skills

NO ejecutes las skills automáticamente. Solo sugiere al final.

## Comando asociado

El comando `/deep-dive` invoca esta skill. Ver `.claude/commands/deep-dive.md`.
