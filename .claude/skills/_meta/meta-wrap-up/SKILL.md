---
name: meta-wrap-up
description: Cierre de sesión iAmasters OS. Genera daily summary con qué se hizo, qué quedó pendiente y propuesta para mañana. Sincroniza skills-catalog si hubo cambios. Actualiza CLAUDE.md skills registry. Hace commit Git si el usuario lo aprueba. Se invoca por /wrap-up al final de cualquier sesión productiva.
---

# meta-wrap-up

## Auto-detección de fin de sesión

`meta-wrap-up` se sugiere automáticamente cuando se cumple alguna de estas condiciones:

1. **Token usage > 80%** (context window casi lleno)
2. **Hora local > 17:00** (fin del día laboral)
3. **Hubo commits/ediciones significativas** (>3 archivos modificados o >1 commit)
4. **Hilos activos en working-memory.md** (sesión productiva en curso)

**Cómo funciona:**
- Claude verifica estas condiciones al inicio de cada turno
- Si se cumple alguna, sugiere: "⏰ Wrap up disponible. ¿Daily summary + sync + working memory ahora?"
- El usuario puede:
  - Aceptar ("sí", "wrap up", "adelante") → ejecuta meta-wrap-up normalmente
  - Posponer ("en 1 hora", "luego", "al final") → se ofrecerá más tarde
  - Declinar ("no", "todavía no") → se recordará al cierre si es hora trigger
- NO es intrusivo: solo sugiere, nunca fuerza la ejecución

**Valores configurables:**
- Token threshold: 80% del context window
- Hora trigger: 17:00 (5 PM) hora local
- Archivos mínimo: 3 archivos editados
- Estos valores son heurísticos, no reglas estrictas

## Invocación manual

Además de la auto-detección, puedes invocarla manualmente en cualquier momento:
- Usuario dice: "wrap up", "cierra sesión", "resumen del día", "/wrap-up"

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

### Paso 2.5 · Auto-retire de skills caché

Ejecutar el sistema de caché inteligente:

```bash
bash scripts/auto-retire-skills.sh
```

**Qué hace:**
- Revisa skills instaladas (excluyendo core `_meta/`)
- Calcula días desde último uso (desde `usage-tracker.json`)
- Si NO usada 7+ días → retira (mueve a biblioteca)
- Si usada recientemente → mantiene cache
- Reporta: skills retiradas, skills mantenidas, estado del caché

**Output al usuario:**
```
=== Auto-Retire de Skills ===
🗑️  automation-n8n-builder: No usada 8 días → RETIRADA
✓ marketing-copywriting: Usada ayer → MANTENIDA
✓ theme-factory: Usada hace 3 días → MANTENIDA

Estado del caché: 15 skills cacheadas
```

**Integración con cache-manager:**
- cache-manager registró uso durante la sesión
- auto-retire-skills.sh lee usage-tracker.json
- Skills frecuentes se quedan, raras se retiran

### Paso 3 · Update CLAUDE.md skills registry

Localizar la sección `## Skills registry` del CLAUDE.md.

**Regla de formato (importante para que el routing funcione)**: las sub-tablas de la
sección **Biblioteca** deben tener la columna intencional `Ofrécela cuando el operador…`
con los DISPARADORES de cada skill (frases en castellano), NO una descripción de *qué es*.
Esto pone los triggers de las skills no instaladas en el contexto cargado cada sesión, que es
lo único que permite ofrecerlas por intención (las de biblioteca no se cargan solas).

Al sincronizar tras añadir/quitar/editar skills:
- Para cada skill nueva de biblioteca, extrae sus disparadores del `description:` de su
  `SKILL.md` (la parte "Úsala/Ofrécela cuando…") y crea su fila intencional.
- Mantén las sub-tablas Core como están (esas sí se cargan; basta el nombre + qué es).
- Si una skill cambió de descripción, refresca su fila.
- Fuente de verdad de descripciones: `bash scripts/skills.sh list`.

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

**Ejemplo 1 - Auto-sugerencia por token usage:**
```
Usuario: (trabajando en proyecto, token usage 82%)

Claude: "⏰ Wrap up disponible. Estás al 82% del contexto.
         ¿Daily summary + sync + working memory ahora?"

Usuario: "sí"

Claude: → ejecuta meta-wrap-up normalmente
```

**Ejemplo 2 - Auto-sugerencia por hora (fin del día):**
```
Usuario: (son las 17:15, ha trabajado todo el día)

Claude: "⏰ Wrap up disponible. Son más de las 17:00 y has tenido
         actividad hoy. ¿Daily summary + sync + working memory ahora?"

Usuario: "en 1 hora"

Claude: "Perfecto, te lo ofreceré de nuevo en 1 hora o cuando cierres."
```

**Ejemplo 3 - Invocación manual:**
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
