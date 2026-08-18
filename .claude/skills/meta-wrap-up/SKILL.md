---
name: meta-wrap-up
description: Cierre de sesión iAmasters OS. Genera daily summary con qué se hizo, qué quedó pendiente y propuesta para mañana. Sincroniza skills-catalog si hubo cambios. Actualiza CLAUDE.md skills registry. Hace commit Git si el usuario lo aprueba. Se invoca por /wrap-up al final de cualquier sesión productiva.
---

# meta-wrap-up

## Cuándo se invoca

- Usuario dice: "wrap up", "cierra sesión", "resumen del día", "/wrap-up"
- Skill detecta que la sesión va a terminar (token usage > 80% sostenido)

NO se invoca automáticamente al cerrar Claude Code (Ctrl+C) — el usuario debe pedirlo explícitamente o el comando `/wrap-up` debe correrlo.

## Process

### Paso 1 · Recap de la sesión

Resumir mentalmente:
- ¿Qué se completó? (deliverables generados, archivos modificados)
- ¿Qué quedó a medias? (proyectos en briefs/ con status: active)
- ¿Qué se aprendió? (skills que fallaron, decisiones que se tomaron, gotchas)

### Paso 2 · Sync de skills

Comprobar `.claude/.skills-pending.json`:
- Si hay flag de cambios → leer `.claude/skills/` recursivamente
- Detectar skills nuevas (en filesystem pero no en `synapsis/skills-catalog.json`)
- Detectar skills retiradas (en catálogo pero no en filesystem)
- Update `synapsis/skills-catalog.json` con cambios
- Limpiar `.skills-pending.json`

### Paso 3 · Update CLAUDE.md skills registry

Localizar bloque entre `<!-- skills-registry-start -->` y `<!-- skills-registry-end -->`.

Generar tabla:
```markdown
| Categoría | Skill | Estado | Tokens |
|---|---|---|---|
| _meta | meta-skill-creator | active | ~700 |
| _meta | meta-onboarding-wizard | active | ~400 |
| ... | ... | ... | ... |
```

Reemplazar contenido entre marcadores.

### Paso 4 · Append learnings (si los hay)

Si durante la sesión:
- Una skill falló y se descubrió por qué → append en `context/learnings.md` bajo `## <skill-name>`:
  ```
  - YYYY-MM-DD: <skill> falló porque <razón>. Fix aplicado: <qué>. Próxima vez recordar: <lección>.
  ```
- Se descubrió un patrón repetible → proponer al usuario crear skill o pasive rule
- Se cambió alguna decisión estratégica → escribir en `~/.claude/skills/_operator-state.json` `strategicDecisions[]`

### Paso 5 · Generar daily summary

Crear/actualizar `synapsis/daily-summaries/<TODAY>.md`:

```markdown
# EOD — YYYY-MM-DD

## Sessions today: N

### Session N - <título-corto>
**Goal**: <qué iba a hacer>
**Done**:
- <bullet 1>
- <bullet 2>

**Pending**:
- <pendiente 1 con ubicación: projects/.../X.md>

**Learnings**:
- <si los hubo>

**Decisions**:
- <decisiones de fondo>

---

## For tomorrow
1. <prioridad 1>
2. <prioridad 2>
3. <prioridad 3>

## Quick resume
> "Una frase para mañana: 'Ayer X. Pendiente Y. Empezar por Z.'"
```

Si ya hay sessions previas hoy → append la sesión nueva, regenerar "For tomorrow" y "Quick resume" combinando.

### Paso 5.5 · Mantener working-memory

Revisa `context/working-memory.md` y déjalo limpio para mañana:
- **Hilos cerrados hoy** → quítalos de "Hilos activos" (ya quedan registrados en el daily summary).
- **Decisiones tomadas** → quítalas de "Decisiones pendientes" y, si son de fondo, regístralas en `context/decisions-log.md`.
- **Tope ~2.500 car / máx. 5 ítems por sección**: si se excedió, consolida.
- Deja solo lo VIGENTE: el scratchpad debe reflejar el estado real al arrancar mañana.

### Paso 6 · Detectar proyectos a archivar

Si algún `projects/briefs/<X>/brief.md` tiene `status: done` y han pasado 7+ días:
- Proponer al usuario mover a `projects/_archived/` (no borrar)

### Paso 7 · Commit Git (con aprobación)

Si hay cambios en el repo:
- `git status` para listar
- Mostrar al usuario los cambios resumidos
- Proponer mensaje commit (conventional, en inglés):
  - `feat(skills): add <skill-name>` si añadió skill
  - `docs(brand-context): update voice profile` si modificó brand
  - `chore(wrap-up): EOD <fecha>` para sync general
- **Esperar aprobación explícita** ("sí", "commit") — NO commitear sin OK
- Tras commit, mostrar hash y status final

NO push automático. Push lo decide el usuario.

### Paso 8 · Trigger Sinapsis EOD (si aplica)

Si hay `/eod` command de Sinapsis instalado y es la última sesión del día (>17:00 hora local):
- Sugerir al usuario invocar `/eod` para que Sinapsis haga su gather multi-proyecto

NO ejecutar `/eod` automáticamente — es una invitación.

### Paso 9 · Despedida

> "Sesión cerrada. Daily summary guardado en `synapsis/daily-summaries/{{TODAY}}.md`.
> Mañana al abrir Claude Code aquí, te recordaré: '{{quick-resume}}'.
>
> {{si commit hecho}}: Commit {{hash}} creado.
> {{si proyectos abiertos}}: Tienes {{N}} proyectos activos esperando.
>
> Hasta mañana. 👋"

## Outputs

- `synapsis/daily-summaries/<TODAY>.md` — actualizado/creado
- `context/working-memory.md` — consolidado/podado (solo lo vigente)
- `synapsis/skills-catalog.json` — sincronizado si hubo skill changes
- `CLAUDE.md` — skills registry actualizado
- `context/learnings.md` — append si aplica
- Git commit (con aprobación)

## Skills que llama

Ninguna directamente. Es ritual de cierre puro.

Excepción: si detecta patrón repetido sin skill creada (3+ sesiones haciendo X manualmente), sugiere invocar `meta-skill-creator` en próxima sesión. No la lanza.

## Edge cases

- **Usuario hace `/wrap-up` a media tarea sin nada productivo**: aceptable, daily summary registra la sesión incluso si fue exploratoria.
- **Repo está dirty pero el usuario no quiere commit**: respetarlo, anotar en daily summary que hay cambios sin commitear.
- **Conflicto al actualizar CLAUDE.md skills registry** (usuario lo modificó manualmente entre medias): mostrar diff, preguntar qué versión mantener.
- **Sesión muy corta (<5 min)**: omitir daily summary entry, solo limpiar pending flags. No vale la pena bloat.

## Examples

```
Usuario: /wrap-up

Skill: "Recapitulo: hoy hiciste 2 sesiones.
        - Sesión 1 (mañana): brand voice de 'Marta Fitness Coach' → completado
        - Sesión 2 (ahora): primer blog post sobre 'rutinas mañana' → status: in review

        Pendiente: pasar el blog por output-verifier antes de publicar.

        Cambios en repo: 4 archivos modificados (brand-context/voice/*, projects/marketing-blog-writer/...).

        Propongo commit: 'feat(brand): add Marta Fitness brand voice + first blog draft'.
        ¿Procedo?"

Usuario: "sí"

Skill: → git add . && git commit -m "..."
       → escribe daily-summaries/2026-05-07.md
       "Sesión cerrada. Mañana te recordaré: 'Pasaste el blog post a review. Empieza con output-verifier'.
        Commit a3f2e1b creado.
        Hasta mañana. 👋"
```
