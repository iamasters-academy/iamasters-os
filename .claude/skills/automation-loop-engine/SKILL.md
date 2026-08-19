---
name: automation-loop-engine
description: >
  Motor de Loop Engineering. Convierte trabajo repetitivo en sistemas: se diseñan UNA vez y se ejecutan N veces con verificación, compuertas humanas y aprendizaje acumulado (REGLAS.md). Tres funciones: (1) INSTALACIÓN — en el primer uso, entrevista de 5 preguntas para personalizar la skill al negocio, herramientas y límites de cada usuario; (2) RADAR — detectar cuándo una tarea se está convirtiendo en loop y preguntar «¿Lo diseñamos o lo disparo?»; (3) FÁBRICA — diseñar el loop (canvas de 9 campos), dispararlo, operarlo y evaluarlo. Usar siempre que el usuario diga "loop", "sistematiza esto", "automatiza este proceso", "línea de producción", "todas las semanas", "para cada cliente", "hazlo en lote", "diseña el sistema", "diseña el loop", "monta el sistema de", "deja de hacerlo a mano", "loop engineering", "convierte esto en un sistema", "configura la skill de loops", o pida repetir una tarea ya hecha 2+ veces en la conversación. Activar proactivamente (modo RADAR) a la 3ª repetición de una misma tarea con estructura similar, aunque el usuario no lo pida.
author: Angel Aparicio (IA Masters Academy)
version: 1.0.0
tags: [loop-engineering, automatizacion, sistemas, operaciones, maker-checker, aprendizaje]
tokens_estimate: 5000
---

# Loop Engine — De promptear a diseñar loops

> «El punto de apalancamiento se ha movido: ya no está en escribir el prompt perfecto,
> está en diseñar el sistema que promptea por ti.»
> — Síntesis de Steinberger / Cherny / Osmani (junio 2026).

## Identidad

Esta skill convierte CUALQUIER tarea repetitiva (comercial, contenido, informes, soporte,
código, administración) en una **línea de producción** con seis estaciones:

```text
COLA → DESPACHO → EJECUCIÓN → VERIFICACIÓN → COMPUERTA → REGISTRO
  ▲                                                          │
  └────────────── el aprendizaje vuelve a la cola ───────────┘
```

**Definición operativa:** un loop es un objetivo recursivo: se define el propósito y los
criterios de "hecho", y el sistema itera, con verificación y estado persistente, hasta
cumplirlos o hasta entregar el control al humano.

**Principio rector, no negociable:** *Diseña el loop como quien piensa seguir siendo el
ingeniero, no como quien solo pulsa el botón.* El loop amplifica el criterio del diseñador:
el bueno y el malo. El usuario no sale del sistema: sube de planta.

---

## MODO INSTALACIÓN — primer uso y personalización

Al activarse esta skill, lo primero SIEMPRE es buscar `context/loops-config.md`.

- **Si existe** → leerlo, aplicar esos valores en todos los modos y no preguntar nada de configuración.
- **Si NO existe** → antes de diseñar o disparar nada, ofrecer la instalación:

> Es la primera vez que usamos loop-engine juntos (o no veo tu configuración). Puedo hacerte
> **5 preguntas rápidas** para adaptarla a tu negocio, tus herramientas y tus límites, o
> empezar ya con valores genéricos y configurarla más adelante. ¿Qué prefieres?

Si acepta, hacer la entrevista de `references/config-guide.md` (las 5 preguntas, en una sola
tanda si es posible, máximo dos). Con las respuestas:

1. Generar el bloque `# CONFIG · loop-engine` relleno (plantilla en la referencia).
2. Escribirlo en `context/loops-config.md`.
3. Añadir una línea en `context/working-memory.md`, sección de hilos activos:
   `loop-engine configurado · ver context/loops-config.md`.
4. Si nombró un primer loop candidato, ofrecer diseñarlo o dispararlo en ese momento.

Si rechaza la entrevista → usar los **defaults genéricos** del MODO DISPARO y recordar,
solo una vez al final, que puede configurarla cuando quiera con "configura loop-engine".

**Actualizar configuración:** si el usuario pide "actualiza mi config de loops", regenerar
`context/loops-config.md` completo con los cambios y la fecha nueva. Nunca parchear líneas
sueltas ni guardar secretos.

---

## Dónde viven los loops

Cada loop recurrente vive en `loops/<nombre-kebab>/`:

- `loop-spec.md` — fuente de verdad operativa del loop.
- `REGLAS.md` — aprendizaje validado por correcciones del usuario.
- `loop-state.md` — estado de items procesados, pendiente y volátil.

Registro central:

- `loops/_index.md` — tabla con nombre, objetivo, disparador, nivel A actual, fecha de creación
  y última revisión. La skill lo crea en el primer uso real y lo actualiza al crear o evaluar loops.
- Si el radar detecta candidatos y el usuario elige **SEGUIR**, anotarlos bajo la sección
  `## Candidatos detectados`, con fecha y evidencia.

Plantillas:

- `loops/_templates/` — antes de diseñar de cero, mira si existe una plantilla parecida.
  Incluye 5 plantillas iniciales: `loop-contenido-semanal.md`, `loop-propuestas.md`,
  `loop-triaje-leads.md`, `loop-informe-cliente.md` y `loop-revision-semanal.md`.

El contenido de `loops/` es privado del operador y no se versiona salvo `README.md` y `_templates/`.

---

## Los 5 modos operativos

| Modo | Qué hace | Cuándo |
|---|---|---|
| **RADAR** | Detecta que una tarea se está volviendo loop y pregunta | Siempre activo en background, salvo configuración en contra |
| **DISEÑO** | Entrevista Loop Canvas (9 campos) → `loop-spec.md` | "Diseñemos el loop de X" |
| **DISPARO** | Rellena el canvas con la CONFIG (o defaults) → aprueba → construye | "Dispara el loop de X" |
| **OPERACIÓN** | Ejecuta un lote dentro de Claude o define dónde vive solo | "Corre el loop", "procesa la cola" |
| **EVALUACIÓN** | Scorecard de 5 métricas + decisiones de autonomía | "Evalúa el loop", revisión semanal |

---

## MODO RADAR — detección proactiva

El radar corre en segundo plano en TODA conversación si la CONFIG dice `proactivo`. Si dice
`bajo demanda`, solo se activa cuando el usuario lo pide. Busca 6 señales:

| # | Señal | Qué observar |
|---|---|---|
| S1 | **Repetición** | El usuario pide por 3ª vez una tarea con la misma estructura |
| S2 | **Pasos nombrables** | El proceso se puede describir en 3–7 pasos con nombre |
| S3 | **Entrada/salida estables** | El input siempre tiene la misma forma y el output también |
| S4 | **Calidad verificable** | Existe o puede existir un checklist objetivo de "esto está bien" |
| S5 | **Recurrencia futura** | Lenguaje tipo "cada semana", "cada cliente", "siempre que llegue..." |
| S6 | **Copy-paste entre herramientas** | El usuario mueve a mano resultados entre chat, email, CRM, hojas o docs |

**Puntuación:** S1, S4 y S5 valen 2 puntos; S2, S3 y S6 valen 1 punto (máx. 9).

- **Score ≥ 5** → interrumpir con la pregunta estándar.
- **Score 3–4** → terminar la tarea actual y mencionar en una línea: "esto es candidato a loop, lo apunto en tu lista".
- **Score < 3** → no decir nada.

### Radar entre sesiones

Además de las 6 señales en la conversación, si el OS tiene Sinapsis activo:

1. Consultar daily summaries recientes en `~/.claude/skills/_daily-summaries/`.
2. Leer `context/working-memory.md`.
3. Buscar tareas repetidas entre sesiones con misma estructura o misma cola.

Una repetición detectada ENTRE sesiones cuenta como señal **S1** con **2 puntos**.

Los candidatos descartados con **SEGUIR** se anotan en `loops/_index.md`, sección
`## Candidatos detectados`, con fecha, evidencia y score. Así el radar no parte de cero
la próxima vez.

### Pregunta estándar del radar

Cuando el score ≥ 5, Claude interrumpe UNA sola vez por conversación con exactamente esta estructura:

> 🔁 **Esto huele a loop.** [Una frase con la evidencia: "Es la tercera vez que haces X con
> la misma estructura: A → B → C."]
>
> ¿Cómo seguimos?
> 1. **DISEÑAR** — Loop Canvas en 10 min: te hago las preguntas y lo dejamos especificado.
> 2. **DISPARAR** — lo monto yo ahora con tu configuración (o defaults sensatos) y me apruebas la spec.
> 3. **SEGUIR** — terminamos la tarea a mano y lo apuntamos para luego.

**Reglas anti-ruido:**

- Máximo UNA interrupción de radar por conversación. Si elige SEGUIR, no volver a preguntar
  en esa conversación.
- Si el usuario dice "modo directo" o "sin radar", el radar queda mudo toda la conversación.
- El radar NUNCA interrumpe en mitad de una entrega urgente o una reunión en directo: espera
  al final del turno de trabajo.

---

## MODO DISEÑO — el Loop Canvas

Antes de construir nada: leer `references/loop-canvas.md` (plantilla completa de los 9 campos
+ ejemplo rellenado universal) y `references/patrones.md` si hay que elegir forma dominante.

Protocolo de entrevista:

1. Pre-rellenar TODO lo deducible del contexto y de la CONFIG. Nunca llegar con el canvas vacío.
2. Preguntar solo los huecos, en máximo 2 tandas de preguntas.
3. Presentar el canvas completo para aprobación.
4. Con el canvas aprobado, generar entregables en `loops/<nombre-kebab>/`:
   - `loop-spec.md` — especificación operativa y fuente de verdad.
   - `REGLAS.md` — inicializado vacío con secciones por estación.
   - `loop-state.md` — estado volátil de items.
   - Actualizar `loops/_index.md`.
5. Ofrecer una versión visual en HTML del loop solo si el usuario la quiere o la CONFIG lo pide.

Los 9 campos del canvas:

1. **Objetivo y "hecho"** — qué produce el loop y el criterio verificable de terminado.
2. **Disparador** — manual por lote / programado / por evento. En Claude Code/Desktop los loops
   programados se materializan como tarea programada de la app (Routines/Scheduled tasks) o con
   `/loop <intervalo>` para polling dentro de una sesión. El `loop-spec.md` debe decir cuál.
3. **Cola de entrada** — dónde viven los items pendientes y qué hace a un item "listo".
4. **Estaciones** — los 3–7 pasos, en orden, con su input/output.
5. **Operario por estación** — qué skill, agente, herramienta o persona ejecuta cada paso.
6. **Verificación automática** — checklist objetivo que se pasa ANTES de molestar al humano.
7. **Compuertas humanas** — dónde interviene el usuario y con qué nivel A0–A3.
8. **Condiciones de parada** — presupuesto de iteraciones/tiempo, errores que escalan, kill switch.
9. **Métricas y aprendizaje** — qué se mide y dónde se anotan las reglas aprendidas.

---

## MODO DISPARO — construcción directa

Cuando el usuario elige DISPARAR o dice "dispara el loop de X", "móntalo directamente":

1. Rellenar el Loop Canvas completo usando `context/loops-config.md` y el contexto disponible.
2. Presentar la spec compacta (los 9 campos en una tabla) y pedir una aprobación.
3. Aprobado → generar los mismos entregables del modo DISEÑO.
4. Si hay items reales disponibles, ofrecer correr un **lote piloto de 3 items** en modo A1
   para calibrar antes de subir autonomía.

**Defaults genéricos** cuando un valor no esté en CONFIG ni contexto:

- Cola: la herramienta donde el usuario ya gestione pendientes, o una lista en el propio chat si es puntual.
- Estado persistente: `loops/<nombre-kebab>/loop-state.md`, salvo que el usuario ya tenga hoja/base de datos.
- Verificación: checklist de 5 criterios máximo, binarios, sin ambigüedad.
- Compuerta inicial: **A1 siempre**. La autonomía se gana, no se regala.
- Parada: máx. 3 iteraciones de autocorrección por item; al 3er fallo, escala.
- Herramientas: solo las que el usuario ya usa o apruebe. Respetar siempre herramientas vetadas.

---

## MODO OPERACIÓN — correr el loop

### Dentro de Claude (lotes manuales o demo)

Protocolo de lote, item a item:

```text
PARA CADA item de la cola:
  1. TOMAR     — leer el item y su contexto
  2. EJECUTAR  — correr las estaciones con sus operarios
  3. VERIFICAR — pasar el checklist; si falla, autocorregir (máx. 3 intentos)
  4. COMPUERTA — según nivel A: presentar para aprobación / ejecutar y registrar
  5. REGISTRAR — estado del item (aceptado / corregido / escalado) + tiempo
  6. APRENDER  — si el usuario corrigió algo, convertir la corrección en regla
SIGUIENTE item, aplicando ya las reglas nuevas
```

Presentación durante el lote: una línea por item con su estado, no paredes de texto.
Al final del lote: mini-scorecard (items, aceptados a la primera, reglas aprendidas).

### Loops que viven solos

El `loop-spec.md` debe indicar dónde vive cada pieza, usando el stack del usuario:

- **Disparador programado** → tarea programada de la app (Routines/Scheduled tasks), `/loop <intervalo>`,
  cron, automatización nativa de su herramienta, webhook, email o formulario.
- **Cola** → gestor de tareas, CRM, hoja de cálculo, bandeja etiquetada de email o base de datos.
- **Operarios** → skills de Claude, subagentes, plantillas, herramientas externas o pasos humanos.
- **Maker/Checker** → separar SIEMPRE quien produce de quien verifica. Para loops críticos en Claude
  Code, ejecutar la VERIFICACIÓN en un **subagente** con instrucciones independientes de las del productor.
- **Estado** → fuera del contexto de conversación, siempre: `loop-state.md`, hoja o base de datos.
  *El agente olvida entre sesiones; el registro no.*

---

## Niveles de autonomía A0–A3 (human-in-the-loop)

| Nivel | Quién hace qué | Cuándo usarlo |
|---|---|---|
| **A0** | El usuario ejecuta, la IA asiste | Tarea nueva, criterio aún no explicitado |
| **A1** | La IA propone, el usuario aprueba ANTES de que salga nada | Default de todo loop nuevo |
| **A2** | La IA ejecuta, el usuario revisa DESPUÉS (cola de revisión asíncrona) | ≥10 items seguidos aceptados sin tocar en A1 |
| **A3** | La IA ejecuta y registra; el usuario audita por muestreo (1 de cada 5–10) | ≥20 items en A2 con first-pass ≥90% y riesgo bajo |

**Promoción:** se propone subir de nivel cuando se cumplen los umbrales; la decisión es siempre del usuario.
**Democión:** 2 fallos graves seguidos, o 1 fallo que llegue a un cliente → bajar un nivel inmediatamente.

**Compuertas SIEMPRE humanas (nunca A3), sin excepción:**

- Todo lo que sale a un cliente o se publica con la marca del usuario.
- Dinero: precios, cobros, presupuestos, pagos.
- Acciones irreversibles: borrar datos, enviar emails masivos, desplegar a producción.
- Compromisos: fechas, alcance, contratos.
- Más las compuertas propias que el usuario haya definido en su CONFIG.

---

## Aprendizaje — toda corrección se convierte en regla

Cada loop tiene un `REGLAS.md`. Formato:

```text
R-007 · [fecha] · Origen: corrección del usuario en item #23
ANTES: tono formal por defecto en los textos.
AHORA: tono cercano, tuteo, máx. 1 emoji por pieza.
APLICA A: estación 2 (redacción).
```

Reglas del juego:

- Una corrección repetida 2 veces = regla obligatoria.
- Las reglas se inyectan en las instrucciones del operario de su estación.
- Revisión mensual: reglas contradictorias o muertas se podan.
- Si un loop acumula 15+ reglas en una estación, esa estación necesita rediseño, no más parches.
- Los `loop-spec.md` y `REGLAS.md` quedan indexados por `/recuerda`: preguntas como
  "¿qué reglas aprendimos del loop de propuestas?" deben responderse citando fuente.

### Aprendizaje ↔ Sinapsis

Cuando un loop acumule 3+ reglas validadas en `REGLAS.md`, ofrecer al usuario consolidarlas
como aprendizaje del sistema vía `/aprende`, que escribe en `context/learnings.md`. Así
Sinapsis puede promoverlas a instintos.

NUNCA escribir directamente en archivos internos de Sinapsis como `_instincts*.json`.

---

## MODO EVALUACIÓN — el scorecard

Se evalúa **el loop, no cada output**. Cinco métricas, revisión semanal de 15 minutos:

| Métrica | Qué mide | Lectura |
|---|---|---|
| **First-Pass Yield** | % de items aceptados sin tocar | <60% → revisar verificación · >90% sostenido → proponer subir nivel A |
| **Tasa de retrabajo** | % de items con ≥2 ciclos de corrección | Alta → el checklist no captura el criterio real |
| **Tiempo de ciclo** | De entrar en cola a aceptado | Si no baja vs. hacerlo a mano, el loop no se justifica todavía |
| **Tasa de escalación** | % de items que escalan al usuario por parada | >20% → la cola admite items que no están "listos" |
| **Reglas/semana** | Aprendizaje capturado | 0 durante semanas en un loop joven → nadie está anotando |

Decisiones posibles tras cada revisión:

- Subir o bajar autonomía.
- Ajustar checklist.
- Endurecer el criterio de "item listo".
- Partir una estación en dos.
- Matar el loop si no rinde. El canvas queda archivado.

Al evaluar, actualizar `loops/_index.md` con la última revisión y el nivel A actual.

---

## Los 3 peajes (anti-patrones)

Leer en voz alta antes de cada loop nuevo:

1. **La verificación sigue siendo tuya.** Un loop desatendido también comete errores
   desatendidos. "Hecho" es una afirmación del agente, no una prueba.
2. **Deuda de comprensión.** Cuanto mejor el loop, más rápido crece el hueco entre lo que
   existe y lo que entiendes. Antídoto: auditoría por muestreo de A3 obligatoria.
3. **Rendición cognitiva.** Dos personas con el mismo loop obtienen resultados opuestos:
   una lo usa para ir más rápido en lo que domina; la otra para dejar de pensar.

---

## Referencias de esta skill

- `references/config-guide.md` — entrevista de instalación, plantilla CONFIG y persistencia OS-nativa. Leer SIEMPRE en modo INSTALACIÓN.
- `references/loop-canvas.md` — plantilla de los 9 campos + ejemplo rellenado universal. Leer SIEMPRE en modo DISEÑO/DISPARO.
- `references/patrones.md` — los 7 patrones de diseño de loops. Leer al elegir la forma del loop.
- `references/demo-playbook.md` — guion de la demo en directo "El mismo trabajo, dos veces". Leer cuando el usuario prepare una formación o demo.
