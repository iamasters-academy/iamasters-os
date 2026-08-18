---
description: Tour interactivo de 5 días que te enseña a usar iAmasters OS desde cero. Idempotente — retoma donde lo dejaste.
---

# /aprende — Tour de 5 días por iAmasters OS

Tutorial paso-a-paso para alumnos que empiezan desde cero. Cada día son 5-10 minutos. Idempotente: si saltas un día, retoma donde quedaste.

## Process

### Paso 1 · Detectar progreso

Leer `context/learn-progress.json`. Si no existe:

```json
{
  "started_at": "<fecha hoy>",
  "current_day": 1,
  "completed_days": [],
  "last_seen": "<fecha hoy>"
}
```

Si existe, mostrar:
```
Tour de 5 días — iAmasters OS

Día 1 ✅ completado
Día 2 ✅ completado
Día 3 ◀ siguiente (estás aquí)
Día 4 ⏳ pendiente
Día 5 ⏳ pendiente

¿Continuamos con Día 3?
```

### Paso 2 · Ejecutar el día correspondiente

Cada día sigue el patrón:
1. **Concepto** (2-3 min lectura)
2. **Demo en vivo** (Claude lo hace, el alumno mira)
3. **Tu turno** (el alumno hace algo guiado)
4. **Cierre** del día + previa del siguiente

Al cerrar el día, marcar en `learn-progress.json` y proponer:
- *"¿Continuamos con el día siguiente ahora o lo dejamos para mañana?"*

---

## Día 1 — Qué es una skill y cómo Claude las activa sola

### Concepto

Una **skill** es una carpeta `.claude/skills/<nombre>/` con un `SKILL.md` que tiene un `description:`. Claude lee TODOS los `description:` al iniciar la sesión y, según lo que tú escribas, activa automáticamente la skill que encaja. Tú no la llamas — ella te encuentra.

**Ejemplo real**: en este repo tienes `marketing-copywriting`. Si escribes *"escríbeme un email frío para un CTO de fintech"*, Claude activa esa skill solo. No necesitas decir "usa la skill de copywriting".

### Demo en vivo

Claude muestra:
1. Lista de todas las skills actuales por categoría (lee `.claude/skills/`)
2. Para una skill (ej. `marketing-copywriting`), abre su SKILL.md y enseña el `description:` que Claude usa para decidir cuándo activarla
3. Hace una demo: genera 3 versiones de post LinkedIn sobre un tema cualquiera, **señalando en qué momento se activó la skill y por qué**

### Tu turno

Pide al alumno: *"Pídeme algo concreto. Yo te diré qué skill activé y por qué."* Tres rondas. Si la skill no activó la correcta, el alumno aprende a refinar su pregunta.

### Cierre día 1

> Hoy aprendiste: skills viven en `.claude/skills/`, Claude las activa solas leyendo el `description:`. Mañana: brand context — la pieza que hace que el sistema escriba en TU voz, no en una genérica.

---

## Día 2 — Brand context: voz, ICP, posicionamiento

### Concepto

**Brand context** es la información que hace que tus outputs suenen a TI, no a IA genérica. Tres piezas:

- `voice/voice-profile.md` — Tu voz: cómo escribes, qué palabras usas, qué evitas, 3 registros (A formal / B divulgativo / C cercano)
- `icp/icp.md` — Tu cliente ideal: dolores, lenguaje que usa, triggers de compra
- `positioning/positioning.md` — Tu ángulo: por qué te eligen a ti y no a otro

Todas las skills `marketing-*` leen estos archivos antes de generar. Sin esto, el output es genérico.

### Demo en vivo

Claude:
1. Abre `brand-context/voice/voice-profile.md` (si existe — si no, sugiere generarlo)
2. Genera un post LinkedIn primero **sin** voice profile, luego **con** voice profile
3. El alumno ve la diferencia lado a lado

### Tu turno

Si el alumno aún no tiene voice profile:
- Lanzar la skill `marketing-brand-voice` para generar el suyo (15-20 min)
- O, si tiene prisa: rellenar manualmente un mini-template con 5 frases típicas suyas

### Cierre día 2

> Hoy aprendiste: el sistema escribe en tu voz porque lee brand-context. Mañana: multi-cliente — cómo el mismo OS sirve a varios clientes sin mezclar contextos.

---

## Día 3 — Multi-cliente: añadir tu primer cliente

### Concepto

Si trabajas con varios clientes (o eres operador para varios negocios), cada uno tiene su brand context propio. `clients/<nombre>/` es una copia ligera del OS dedicada a ese cliente.

Comando: `/add-client`. Pregunta nombre, vertical (freelance, agencia, formador, consultoría B2B…) y clona la plantilla correspondiente.

### Demo en vivo

Claude:
1. Lista las 4 plantillas de cliente en `clients/_templates/`
2. Ejecuta `/add-client` con un cliente ficticio ("Acme Marketing, agencia")
3. Muestra la estructura que se creó

### Tu turno

Si el alumno tiene clientes reales:
- Crear uno real con `/add-client`
- Configurar su brand-context (puede saltarse si lo hará luego)

Si no tiene clientes:
- Crear uno ficticio para practicar y luego borrarlo

### Cierre día 3

> Hoy aprendiste: cada cliente vive en su propia carpeta sin mezclarse. Mañana: cómo añadir skills y MCPs nuevos al sistema.

---

## Día 4 — Catálogo: añadir skills y MCPs nuevos

### Concepto

iAmasters OS viene con **27 skills core** preinstaladas, pero el ecosistema Claude tiene cientos más. Hay tres formas de añadir cosas:

1. **Plugins oficiales de Anthropic** (docx, xlsx, pdf, pptx, etc.) — se instalan vía marketplace, NO se copian al repo (su licencia es source-available).
2. **Skills de terceros con MIT/Apache** — `/install-skill <github-url>` las vendorea aquí.
3. **MCP servers** — `/install-mcp <nombre>` los conecta (n8n-mcp, github, notion, supabase…).

### Demo en vivo

Claude:
1. **Plugins Anthropic**: enseña cómo ejecutar `/plugin install anthropic-skills` desde Claude Code para añadir `docx`, `xlsx`, `pdf`, `pptx`. Resultado: el alumno puede pedir *"léeme este PDF"* y funciona.
2. **Skill de terceros**: ejemplo con `/install-skill https://github.com/<owner>/<skill>` desde `docs/skills-recommended.md`.
3. **MCP**: ejemplo con `/install-mcp n8n-mcp` para activar la skill `automation-n8n-builder` que ya tienes en el repo.

### Tu turno

Pide al alumno que instale al menos:
- Los plugins Anthropic (docx, xlsx, pdf, pptx) — son universales, todo el mundo los necesita
- Un MCP que tenga sentido para su stack (sugerir en función de lo que vimos en día 2-3)

### Cierre día 4

> Hoy aprendiste: el OS crece contigo. Mañana, el día final: flujo end-to-end real, de reunión a propuesta enviada.

---

## Día 5 — Flujo end-to-end: de reunión a propuesta

### Concepto

Hoy juntas todo lo aprendido. Caso real: tuviste una reunión con un cliente nuevo, tienes la transcripción, y necesitas entregar una propuesta esa misma tarde.

Flujo:
1. **Notas de reunión** → skill `marketing-content-repurposing` o equivalente lee transcript y extrae acuerdos, pendientes y dolores del cliente
2. **Investigación del cliente** → `strategy-web-research` enriquece con datos públicos (web, LinkedIn, BORME si España…)
3. **Propuesta** → composición con brand context + voice profile + ICP del cliente
4. **Email follow-up** → `marketing-email-sequence` redacta el envío inicial
5. **Visualización compartible** → `tool-visual-explainer` genera el HTML que puedes enviar por WhatsApp

### Demo en vivo

Claude ejecuta el flujo con un caso ficticio (transcripción de reunión sintética, cliente B2B) y genera los 5 artefactos.

### Tu turno

El alumno trae **un caso suyo real** (transcripción de reunión, brief de un cliente, lo que sea) y reproduce el flujo. Claude le ayuda a identificar qué skill aplica en cada paso.

### Cierre día 5

> Completado el tour. Ahora sabes:
> - Cómo viven las skills y cómo se activan solas
> - Cómo el brand context te da output en tu voz
> - Cómo servir a varios clientes sin mezclar
> - Cómo crecer el sistema con plugins, skills y MCPs
> - Cómo encadenar skills en un flujo real
>
> Próximo paso: úsalo en producción esta semana con un cliente real. Si algo no encaja, ejecuta `/doctor` o pregunta en la comunidad. Si construyes una skill que te funcione, propónsela al catálogo (ver `docs/skills-recommended.md`).

---

## Edge cases

- **El alumno salta de día 1 a día 3 directamente**: avisar de que se está saltando piezas, dejarle decidir si seguir.
- **El alumno ya tiene voice profile generado**: saltar día 2 demo, ir directo a día 3.
- **El alumno trabaja solo y no tiene clientes**: día 3 puede saltarse o ejecutarse con cliente ficticio.
- **El alumno no quiere instalar plugins Anthropic**: respetar, indicar qué pierde (skills office), seguir.

## Cierre

Cuando se completa día 5, marcar `learn-progress.json`:
```json
{
  "completed_days": [1,2,3,4,5],
  "completed_at": "<fecha>"
}
```

Y avisar al alumno: *"Tour completado. `/aprende` vuelve a estar disponible cuando quieras repasar un día concreto: `/aprende dia-2`."*
