---
name: decisions-log
description: Mantiene un diario append-only de decisiones importantes del operador, con formato fijo (fecha · decisión · razonamiento · contexto). Úsalo cuando el usuario tome una decisión estratégica que querrá recordar más adelante, o cuando otra skill (seis-sombreros, marketing-positioning, pricing-strategy) cierre con una conclusión decidida. El log vive en `context/decisions-log.md` y Claude lo lee al arrancar cada sesión para no contradecirse con decisiones anteriores.
---

# decisions-log

> **Crédito**: este patrón está inspirado directamente en [`Luispitik/claude-code-second-brain`](https://github.com/Luispitik/claude-code-second-brain) de Luis Pitik (mismo autor de Sinapsis). El concepto de "decision journal append-only que Claude lee para mantener coherencia entre sesiones" es suyo. Mantenemos el formato exacto y referenciamos el repo original.

## Cuándo se invoca

- Usuario dice: "registra esta decisión", "quiero recordar esto", "anota que hemos decidido X"
- Otra skill cierra con una decisión clara y propone grabarla (seis-sombreros, pricing-strategy, marketing-positioning, etc.)
- Cierre de sesión (`/wrap-up`) detecta una decisión tomada que no se ha registrado y propone grabarla
- Usuario pregunta: "¿qué decidimos sobre Y?" → la skill busca en el log

## Por qué importa

Claude Code (incluso con Sinapsis) puede contradecirse entre sesiones si una decisión vieja no se le recuerda. El operador también lo olvida — y peor, *cambia de opinión sin darse cuenta*. Un log append-only fuerza a:
1. Hacer las decisiones explícitas en el momento que se toman
2. Tener el "porqué" registrado (no solo el "qué")
3. Comparar la versión actual con lo decidido antes (cuando alguien sugiere cambiar)
4. Generar un track record honesto del operador a lo largo del tiempo

## Formato canónico

Cada entrada en `context/decisions-log.md` sigue exactamente esta estructura:

```markdown
## YYYY-MM-DD · <título corto, ≤60 chars>

**Decisión**: <1 frase clara con el qué>

**Razonamiento**: <2-4 frases con el porqué — incluye los datos o
señales que llevaron a la decisión, no solo "porque sí">

**Contexto**: <1-2 frases con la situación más amplia que explica
por qué esta decisión tenía sentido en este momento. Crucial para
re-evaluar el día de mañana.>

**Cuándo reconsiderar**: <criterio concreto que haría revisar la
decisión — evento, métrica, fecha. NO "si va mal".>

---
```

## Process

### Paso 1 · Detectar que hay decisión

Una decisión cualifica para el log si cumple AL MENOS 2 de:
- **Es no trivial** — afecta al negocio, a un cliente, al posicionamiento, al equipo, o al tiempo del operador en >2h/semana
- **Tiene reversibilidad limitada** — costaría tiempo/dinero/relaciones revertirla
- **Va a influir futuras conversaciones con Claude** — el sistema debería mantenerla coherente

Si la "decisión" es operativa pequeña (qué color usar, qué hora reunión, qué archivo nombrar), NO va al log. Para eso hay tareas y notas, no decisions journal.

### Paso 2 · Leer el log existente

Antes de añadir, lee `context/decisions-log.md` completo (o si es muy largo, las últimas 20 entradas) para:
- Detectar si esta decisión **contradice** una anterior — entonces hay que registrar la inversión, no solo añadir
- Detectar si esta decisión **complementa** una anterior — referenciar la entrada anterior con `(refina <YYYY-MM-DD · título>)`
- Verificar el formato canónico se mantiene consistente

### Paso 3 · Confirmar con el usuario los 4 campos

Pregunta en orden:

```
1. Título corto (≤60 chars):
2. Decisión en 1 frase:
3. Razonamiento (los datos/señales que te llevaron aquí):
4. Cuándo deberíamos reconsiderar esta decisión (qué evento o métrica):
```

Si el usuario es lacónico o no quiere escribir, propón tú un draft basado en la conversación que acabáis de tener. Pídele "ok" o ajustes.

El **Contexto** lo redactas tú a partir del estado del operador-state + lo que hayas observado en la conversación. NO lo preguntes — sería pedirle al usuario explicar lo obvio.

### Paso 4 · Append en el log

Edita `context/decisions-log.md` añadiendo la nueva entrada AL FINAL del archivo, siguiendo el formato canónico exacto.

**Nunca edites entradas existentes.** Si una decisión se invierte, escribe nueva entrada con título tipo "Invertimos decisión de YYYY-MM-DD: ahora hacemos X" y referencia explícita.

### Paso 5 · Confirmar y proponer siguiente

Tras append, muestra al usuario:

```
✅ Registrada: <título de la decisión>

Total decisiones grabadas: <N>
Tiempo desde la última decisión: <X días>

¿Hay otra decisión de hoy que deberíamos grabar?
```

### Paso 6 · Cierre

- Si la decisión grabada **invierte** una anterior, propón en wrap-up actualizar `~/.claude/skills/_operator-state.json` para que la operación diaria refleje la nueva dirección
- Si esta es la 5ª, 10ª o 25ª decisión grabada, celebra brevemente — el log se vuelve útil exponencialmente con cada nueva entrada

## Lectura del log al arrancar sesión

`meta-start-here` y `meta-onboarding-wizard` deben leer las últimas 5 entradas del log al arrancar y mencionarlas si son relevantes a la conversación que comienza.

Ejemplo de mensaje al arrancar:

```
Recordatorios del decisions-log:
- (hace 3 días) Decidiste pausar lanzamientos en julio y centrarte en producto.
  ¿Sigue siendo el plan o cambiamos?
- (hace 12 días) Decidiste subir precios anuales a €497.
  ¿Lo aplicaste ya o queda pendiente?
```

## Outputs

- Append en `context/decisions-log.md`
- Opcional: update en `~/.claude/skills/_operator-state.json` si la decisión cambia el estado actual del operador

## Skills que llama

Ninguna directamente. Esta skill es invocada **por** otras (seis-sombreros, pricing-strategy, marketing-positioning, etc.) cuando esas cierran con decisión.

## Edge cases

- **Log vacío (primera vez)**: añade un header al archivo:
  ```markdown
  # Decisions log

  Diario append-only de decisiones del operador.
  Patrón inspirado en [claude-code-second-brain](https://github.com/Luispitik/claude-code-second-brain) de Luis Pitik.

  ---
  ```
  Después añade la primera entrada normal.

- **Decisión muy emocional / impulsiva**: pregunta al usuario "¿quieres dormir 24h sobre esto antes de grabarla? Las decisiones impulsivas en el log te van a confundir más adelante." Si insiste, regístrala con tag `[impulsiva]` en el título.

- **Decisiones contradictorias dentro de la misma sesión**: si el usuario decide A, luego dice B, regístralo como entrada única "Cambio de opinión durante sesión: primero A, ahora B" con razonamiento de por qué cambió.

- **Decisión sobre cliente concreto vs decisión personal**: si es de cliente, va al log del cliente (`clients/<nombre>/context/decisions-log.md`). Si es personal/operador, al raíz. Si dudas, raíz.

- **Decisión que requiere comunicación a equipo**: tras grabarla, propón al usuario redactar el comunicado al equipo (vía `marketing-copywriting` o draft directo).

## Examples

### Ejemplo de entrada bien formada

```markdown
## 2026-05-08 · Pausar sprint v0.5.0 hasta validar v0.4.3

**Decisión**: pausar el sprint planeado de añadir 7 skills nuevas a iamasters-os (v0.5.0) hasta haber lanzado v0.4.3 con los fixes de plug-and-play y validado en uso real.

**Razonamiento**: la sesión de planning aplicando 6 sombreros mostró que el problema central no es catálogo (12 → 19 skills) sino fricción de onboarding. Añadir más skills sobre un onboarding roto multiplica fricción. Además, la lección de anoche con el cockpit (RUBRIC) refuerza: validar contra uso real antes de seguir construyendo.

**Contexto**: iamasters-os v0.4.2 publicado en GitHub con 12 skills + atribución completa pero sin haber sido instalado todavía por ningún miembro de iAmasters Academy. Sprint v0.5.0 estaba previsto inmediatamente. v0.4.3 introduce: refactor README+AGENTS para auto-instalación URL conversacional, /doctor, welcome-quick-win, six-hats, decisions-log, sectorización context/, vídeos Loom 60s.

**Cuándo reconsiderar**: si tras release v0.4.3 + envío a Luis para feedback, validación con 5+ miembros muestra que el catálogo de 18 skills está bien pero faltan skills específicas concretas. Entonces v0.5.0 con esas, no las 7 originalmente planeadas a ciegas.

---
```

### Ejemplo de inversión de decisión

```markdown
## 2026-06-10 · Invertimos decisión 2026-04-15: vuelve el Free Trial 7 días

**Decisión**: reactivar el Free Trial de 7 días para iAmasters, eliminado el 6-abril-2026.

**Razonamiento**: tras 2 meses sin trial, los datos muestran que el funnel "lanzamiento cada 6 semanas" tiene gap entre lanzamientos donde no entra nadie. Trial 7 días llenaba ese gap. CAC trial €54 con conversion 32.6% sigue siendo el mejor modelo numérico que tenemos.

**Contexto**: decisión 2026-04-15 eliminó trial pensando que el modelo "comunidad cerrada + lanzamientos" era suficiente. Tras 60 días: MRR ha bajado de €45K a €42K. La predicción de "trial canibaliza lanzamientos" no se confirma con datos.

**Cuándo reconsiderar**: si tras 60 días con trial reactivado, MRR no recupera trayectoria a €50K, entonces el problema no era el trial — investigar otra hipótesis.

---
```

## Notas operativas

- **Nunca borres entradas del log**, ni las edites a posteriori. El log es histórico inmutable. Si cambia algo, NUEVA entrada.
- **Una sesión NO debe generar más de 3 entradas**. Si más, probablemente estás registrando ruido. Pregúntate cuáles son no triviales.
- **Las entradas más útiles son las que duelen registrar** — las que admites un error, cambias de opinión, o decides algo que va contra tu instinto. Esas son las que el log ayuda a respetar.
- **El log es solo del operador**, no de cada cliente. Para clientes hay un decisions-log dentro de `clients/<nombre>/context/`.
