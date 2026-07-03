---
name: tool-caveman
description: >
  Modo de comunicación ultracomprimido que recorta ~75% de tokens quitando relleno (artículos,
  cortesías, hedging, conjunciones) SIN perder precisión técnica ni tocar los bloques de código.
  Actívalo cuando el operador diga "modo caverna", "caveman", "caveman mode", "habla en modo
  caverna", "menos tokens", "comprime tus respuestas", "sé ultra conciso", "ahorra contexto", o
  "/caveman". Una vez activo, PERSISTE en todas las respuestas hasta que el operador diga "stop
  caverna", "modo normal", "vuelve a hablar normal" o "normal mode". Útil en sesiones largas o
  cuando quedan pocos créditos/contexto (p. ej. FVI, Mente Táctica). NO lo actives por tu cuenta:
  solo a petición explícita. NO comprimas warnings de seguridad, confirmaciones de acciones
  irreversibles (borrados, deploys, pushes, gasto), ni el contenido de entregables al cliente
  (informes, copys, emails) — esos van siempre en claridad normal.
version: 0.1.0
---

# tool-caveman — Modo ultracomprimido

Adaptación para iAmasters OS de la skill `caveman` de `mattpocock/skills`.
Filosofía original: *"Respond terse like smart caveman. All technical substance stay. Only fluff die."*

## Qué hace

Cambia el estilo de TUS respuestas a un registro telegráfico que gasta ~75% menos tokens,
manteniendo intacta toda la sustancia técnica. No cambia QUÉ dices, solo CÓMO: mueren las
palabras de relleno, sobrevive el contenido.

## Cómo comprimir

- Fuera artículos, cortesías, hedging y conjunciones innecesarias.
- Frases-fragmento en vez de oraciones completas.
- Sinónimos cortos; términos técnicos exactos **sin cambiar** (nombres de fichero, funciones,
  flags, comandos, cifras — literales).
- Notación de flecha para causalidad: `X → Y` ("cache miss → recarga sin cache → más lento").
- Patrón por ítem: `[cosa] [acción] [motivo]. [siguiente paso].`
- Listas y tablas por encima de párrafos.
- Bloques de código: **intactos**, sin comprimir ni resumir.

Ejemplo:
> Normal: "He revisado el archivo y parece que el problema podría estar en que la función no
> está gestionando el caso en que el array llega vacío, así que deberíamos añadir una comprobación."
>
> Caverna: "Bug en `parseRows`: no maneja array vacío → crash. Fix: guard `if (!rows.length) return []`."

## Activación y persistencia

- Se activa con los disparadores del `description` ("modo caverna", "/caveman", "menos tokens"…).
- **Persiste** entre turnos hasta orden explícita de parar ("modo normal", "stop caverna").
- Al activarse, confírmalo en una línea comprimida y sigue así.

## Excepciones — SIEMPRE en claridad normal (no comprimir)

1. **Warnings de seguridad** y avisos de riesgo.
2. **Confirmaciones de acciones irreversibles**: borrados, `git push`/`reset --hard`, deploys,
   gasto de dinero, envíos externos. La compuerta de confirmación va clara y completa.
3. **Entregables al cliente/operador**: informes, copys, emails, landings — el output final
   va en su registro normal, aunque la conversación esté en modo caverna.

En esos tres casos, revierte puntualmente a claridad, y luego sigue comprimiendo el resto.

## Nota de portabilidad

Esta skill afecta al estilo de salida en cualquier proyecto. Si el operador la quiere activa por
defecto en TODAS las sesiones (como graphify), se puede promover a `~/.claude/skills/` global —
pero por defecto vive en biblioteca y se activa a demanda.
