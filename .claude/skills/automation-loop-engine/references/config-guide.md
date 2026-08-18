# Guía de instalación y configuración · loop-engine

Esta referencia se lee en **MODO INSTALACIÓN**: primer uso de la skill, o cuando el usuario
pide "configura loop-engine" / "actualiza mi config de loops".

---

## La entrevista (5 preguntas, 1 tanda si es posible — máximo 2)

Antes de preguntar, deducir todo lo posible del contexto visible (proyecto, archivos,
conversación) y presentar las preguntas YA pre-rellenadas con la mejor hipótesis, para que
el usuario solo confirme o corrija. Tono: cercano, cero burocracia.

**P1 · Tu contexto.**
¿A qué te dedicas y qué tipo de trabajo repites más a menudo?
*(Ej.: "soy diseñadora freelance y repito presupuestos, onboarding de clientes y publicación
de portfolio".)* → alimenta los ejemplos, el radar y el primer loop.

**P2 · Tus herramientas.**
¿Dónde viven hoy tus pendientes (tareas, solicitudes, leads) y dónde guardas resultados?
¿Hay alguna herramienta que NO quieras usar bajo ningún concepto?
*(Ej.: pendientes en Trello y email; resultados en Google Drive; vetado: nada / X.)*
→ define cola y estado por defecto + lista de vetos que el loop debe respetar siempre.

**P3 · Tus compuertas.**
Hay cuatro cosas que NUNCA salen sin aprobación humana: lo que llega a un cliente, el dinero,
las acciones irreversibles y los compromisos (fechas, alcance, contratos). ¿Quieres añadir
alguna compuerta propia de tu negocio?
*(Ej.: "nada con mi logo sin verlo yo", "ningún mensaje a proveedores".)*

**P4 · El radar.**
Cuando detecte que estás repitiendo una tarea que podría ser un loop, ¿quieres que te avise
proactivamente (recomendado: una sola vez por conversación) o que me calle hasta que tú lo pidas?

**P5 · Tu primer loop.**
¿Cuál es la tarea repetitiva que más te duele ahora mismo? La usamos para estrenar la skill
hoy mismo. *(Si no tiene ninguna clara, no insistir: dejar el campo vacío.)*

---

## Plantilla del bloque CONFIG

Con las respuestas, generar este bloque EXACTO (es lo que la skill buscará en el futuro)
y guardarlo en `context/loops-config.md`:

```markdown
# CONFIG · loop-engine
- Usuario / rol: [respuesta P1 — quién es y a qué se dedica]
- Trabajo repetitivo típico: [P1 — las 2-4 tareas que más repite]
- Cola por defecto: [P2 — dónde viven sus pendientes]
- Estado por defecto: [P2 — dónde se registra lo hecho; si no dijo nada: archivo markdown]
- Herramientas preferidas: [P2]
- Herramientas vetadas: [P2 — respetar SIEMPRE; "ninguna" si no hay]
- Compuertas propias (además de cliente/dinero/irreversible/compromisos): [P3 o "ninguna"]
- Radar: [proactivo | bajo demanda] (P4)
- Loop candidato #1: [P5 o vacío]
- Última actualización: [fecha]
```

Reglas:

- Campos siempre completos: si el usuario no respondió algo, escribir el default genérico,
  nunca dejar huecos tipo "[...]".
- Al actualizar la config, regenerar el bloque ENTERO con la fecha nueva (no parchear líneas sueltas).
- No guardar en el CONFIG datos sensibles: ni credenciales, ni datos de clientes finales,
  ni información financiera concreta. Si el usuario los ofrece, declinarlos con una frase
  y explicar que el loop los manejará en su herramienta, no en la configuración.

---

## Persistencia OS-nativa

La vía única del OS es `context/loops-config.md`.

La skill escribe ese archivo automáticamente después de la entrevista. En usos futuros:

1. Primero busca `context/loops-config.md`.
2. Si existe, aplica esa configuración sin preguntar.
3. Si no existe, ofrece esta entrevista de 5 preguntas.

El usuario puede editar `context/loops-config.md` a mano o pedir "actualiza mi config de loops".
En ese caso, regenerar el bloque completo, nunca parchear a medias.

Después de crear la config, añadir en `context/working-memory.md`, sección de hilos activos:

```markdown
- loop-engine configurado · ver context/loops-config.md
```

Cerrar la instalación con valor: si hay "Loop candidato #1", ofrecer diseñarlo o dispararlo
en ese mismo momento.

---

## Comportamiento sin CONFIG

Si el usuario rechaza la entrevista o no hay CONFIG en contexto:

- Usar los defaults genéricos del MODO DISPARO del SKILL.md.
- No volver a ofrecer la instalación en esa conversación.
- Mencionarla solo una vez al final: "cuando quieras, dime «configura loop-engine» y la adapto a tu negocio en 3 minutos".
