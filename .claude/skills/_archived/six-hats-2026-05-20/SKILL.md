---
name: six-hats
description: Aplica el método de los 6 sombreros de Edward de Bono para analizar una decisión, problema o estrategia desde 6 perspectivas separadas (proceso, datos, riesgos, oportunidades, creatividad, intuición). Úsalo cuando el usuario pida "analiza X desde varios ángulos", "ayúdame a decidir Y", "qué piensas de Z", o cuando la pregunta requiera estructurar pensamiento sin caer en sesgos. Output: análisis estructurado por sombrero + síntesis con recomendación.
---

# six-hats

## Cuándo se invoca

- Usuario pide: "analiza desde varios ángulos", "qué piensas de", "ayúdame a decidir", "pros y contras de"
- Usuario tiene una decisión grande pendiente (lanzar producto, cerrar contrato, contratar persona, abandonar proyecto)
- Otra skill detecta que la pregunta requiere análisis multi-perspectiva y no resolución directa
- Usuario menciona explícitamente "6 sombreros" o "De Bono"

## Por qué importa

La mayoría de decisiones empresariales se toman mezclando datos + emociones + miedos + creatividad en el mismo párrafo, y se queda en la perspectiva favorita del que decide. Los 6 sombreros **separan los modos de pensamiento** para que cada uno reciba atención completa antes de mezclar. Aplicado bien, evita decisiones unilaterales y descubre ángulos invisibles.

## Process

### Paso 1 · Confirmar el problema/decisión a analizar

Antes de empezar, asegúrate de tener claro QUÉ se está analizando. Si el usuario es ambiguo:

```
Vamos a aplicar los 6 sombreros. Para que funcione, necesito que la
pregunta esté lo más concreta posible. Confirma:

  • ¿Qué decisión o problema vas a analizar?
  • ¿Qué cambia si la respuesta es A vs B?
  • ¿Hay restricciones duras (presupuesto, fecha, personas)?

Resume en 2-3 frases.
```

Espera respuesta clara antes de continuar.

### Paso 2 · Preguntar profundidad deseada

```
Dos modos:

  [1] Rápido — escribo los 6 sombreros yo mismo (5 min, ~1500 palabras)
  [2] Profundo — recorremos los 6 juntos, tú aportas en cada uno
       (15-20 min, mucho más customizado)

¿Cuál prefieres?
```

Por defecto, si no responde, usa modo [1].

### Paso 3 · Recorrer los 6 sombreros EN ORDEN

**No mezcles sombreros.** Cada uno tiene su sección, vacíalo antes de pasar al siguiente. El orden es deliberado: empezar por proceso (azul) ancla, terminar por intuición (rojo) cierra con la sensación gut.

#### 🔵 Azul · Control del proceso

- ¿Cuál es el alcance correcto del análisis? (no abarcar lo no decidible)
- ¿Cuál es la métrica de éxito? (1-3 KPIs concretos)
- ¿Qué decisiones quedan fuera de scope?
- ¿Qué experimento confirmaría la respuesta sin necesidad de pensar más?

#### ⚪ Blanco · Hechos y datos objetivos

- Datos verificables: números, fechas, evidencia
- Lo que se sabe vs lo que se cree saber
- Los datos que faltan (y cómo conseguirlos rápido)
- Análogos o casos similares (no opiniones, hechos)

#### ⚫ Negro · Crítica y riesgos

- Qué puede salir mal y con qué probabilidad
- Costes ocultos (tiempo, oportunidad, energía, reputación)
- Worst case scenario (no para asustar, para dimensionar)
- Asunciones que están dando por sentadas y podrían no ser ciertas

#### 🟡 Amarillo · Optimismo y oportunidades

- Mejor caso si todo va bien
- Quién/qué se beneficia y cómo
- Efectos de segundo orden positivos (más allá del primer beneficio obvio)
- Cómo amplifica esto otras áreas del negocio/vida

#### 🟢 Verde · Creatividad e ideas nuevas

- Lluvia de alternativas (mínimo 5, idealmente 10+)
- Combinaciones de las dos opciones binarias en una tercera vía
- Qué haría alguien fuera del sector ante este problema
- Lo absurdo o lateral (a veces el insight viene de ahí)

#### 🔴 Rojo · Intuición y emociones

- Sin justificar: ¿qué te dice el cuerpo?
- ¿Qué opción ENTUSIASMA y cuál DRENA?
- Si tuvieras que decidir AHORA con 5 segundos, ¿qué dices?
- Si la respuesta evidente fuese "no" pero algo te empuja a "sí", ¿qué es ese algo?

### Paso 4 · Síntesis con recomendación

Tras los 6 sombreros, escribe una sección final con:

1. **Decisión recomendada** en 1 frase clara
2. **Razón principal** (1-2 frases, generalmente combina amarillo + blanco)
3. **Riesgos a vigilar** (los 2-3 más probables del sombrero negro)
4. **Plan de acción inmediato** (próximos 3 pasos en orden)
5. **Cuándo cambiar de opinión** (qué señal nueva haría reconsiderar)

### Paso 5 · Output empaquetado

Si el análisis es relevante para guardar:
- Generar archivo en `projects/six-hats/<YYYY-MM-DD>-<tema-corto>.md` con todo el análisis
- Si el usuario lo va a compartir (con socio, equipo, asesor), invocar `tool-visual-explainer` para empaquetar en HTML compartible
- Append en `context/decisions-log.md` con la decisión final si efectivamente se toma una

### Paso 6 · Cierre y aprendizaje

- Si la sesión enseñó algo no obvio sobre cómo el usuario piensa (preferencias, sesgos, valores), append en `context/learnings.md` bajo `## six-hats`
- Si se identificó una decisión, propón en wrap-up grabarla en `context/decisions-log.md`

## Outputs

- Análisis en chat estructurado por sombrero + síntesis
- Opcional: archivo `projects/six-hats/<YYYY-MM-DD>-<tema>.md`
- Opcional: HTML compartible vía `tool-visual-explainer`
- Opcional: entrada en `context/decisions-log.md` si se toma decisión

## Skills que llama

- **`tool-visual-explainer`** (opcional) — para empaquetar análisis en HTML compartible
- **`decisions-log`** (opcional) — si la sesión cierra con una decisión, registrarla append-only

## Edge cases

- **Pregunta demasiado vaga** ("¿qué hago con mi vida?"): aplica primero el sombrero azul para acotar. Si no se acota, sugiere usar otra skill (mentoría, no análisis).
- **Pregunta puramente operativa** ("¿qué color de botón uso?"): los 6 sombreros son overkill. Sugiere decidir directamente o usar A/B test.
- **Usuario está emocionalmente cargado** (acaba de perder cliente, contrato roto): NO aplicar inmediatamente, pedir 24h de cooldown — el sombrero rojo en caliente sesga el resto.
- **Decisión ya tomada**: el usuario quiere validación, no análisis. Aplica solo sombrero negro (riesgos) para hacer "premortem". No simules análisis abierto si no lo es.
- **Tiempo limitado** (<5 min disponibles): usa la versión "Rápido" y escribe los 6 sombreros directo, sin esperar input por sombrero.

## Examples

Ver `references/examples.md` para 2 ejemplos completos:
1. "¿Lanzo el curso ahora o espero al Q4?" (decisión binaria con datos)
2. "¿Contrato a esta persona o sigo solo 3 meses más?" (decisión emocional con datos blandos)

## Notas operativas

- **NO uses los 6 sombreros para todo.** Es overkill para decisiones <30 min de impacto. Reserva para decisiones que importan.
- **El sombrero rojo va al final, no al principio.** Si lo metes al inicio, los datos posteriores se sesgan a justificar la intuición. Al final, contrasta con lo aprendido.
- **Sombrero verde con mínimo 5 ideas siempre.** Si solo se te ocurren 2, no estás en modo verde de verdad — sigues evaluando, no creando.
- **No mezcles sombreros en la misma frase.** Si una idea es "esto es buena oportunidad PERO con riesgo de X", separa: amarillo dice oportunidad, negro dice riesgo. Cada uno en su sitio.
