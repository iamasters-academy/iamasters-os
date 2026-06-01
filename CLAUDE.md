# iAmasters OS — CLAUDE.md (project root)

> Sistema operativo agéntico para operadores de IA.
> Sinapsis v4.5 (engine) + capa OS (brand context, agent context, skills curadas, multi-cliente).

---

## ⛔ INSTALLATION GATE — LEER ANTES QUE NADA

Antes de responder al primer mensaje del usuario en este repo, **debes** comprobar si la instalación está completa.

**Fuente de verdad**: `~/.claude/skills/_install-state.json` (state machine persistente, v0.6+).

**Comprobación obligatoria** (en este orden):

1. **¿Existe el state file?**
   - Si NO existe → la instalación técnica nunca corrió. Indica al usuario:
     > "iAmasters OS no está instalado. Necesito que ejecutes desde terminal: `bash scripts/install.sh`. Cuando termine, vuelve aquí."
   - NO crees archivos manualmente para simular instalación. NO marques nada como instalado.

2. **Si existe, ¿todas las fases `required: true` están en `status: "done"`?**
   - Si NO → la instalación está incompleta. Invoca el comando `/install` (o el wizard directamente, según la fase pendiente).
   - **NO respondas a otras peticiones del usuario hasta cerrar la instalación.**

3. **El hook SessionStart (`_install-gate.sh`) ya inyecta este aviso automáticamente cuando aplica.** Esta sección es tu *backup* por si el hook falla, no la fuente principal.

**Lo que NUNCA haces durante una instalación incompleta**:
- ❌ Reportar "todo instalado" cuando el state dice lo contrario
- ❌ Crear archivos `.json` o `.md` manualmente para "completar" fases
- ❌ Marcar fases como `done` sin que la validación profunda lo confirme
- ❌ Avanzar a tareas del usuario si quedan fases `required` sin completar

**Si el usuario dice "para" / "ya no quiero seguir":**
- Marca `pausedBy: "user"` en el state con la fase actual
- Despídete: "Cuando vuelvas, `/install --resume` retoma desde aquí. Lo guardado está guardado."
- NO insistas. NO reportes la instalación como completa.

**Si dudas del estado**: ejecuta `/install-status` para ver el dashboard sin tocar nada.

---

## Session Entry — EXECUTE ON FIRST MESSAGE OF EVERY SESSION

(Una vez que el INSTALLATION GATE de arriba ha pasado.)

### Paths absolutos (relativos a este repo)
- **Skills del OS**: `.claude/skills/`
- **Commands del OS**: `.claude/commands/`
- **Brand context**: `brand-context/` (voice, positioning, ICP, assets)
- **Agent context sectorizado**: `context/` (me.md, work.md, team.md, current-priorities.md, goals.md, decisions-log.md, learnings.md, soul.md)
- **Proyectos**: `projects/` (`projects/briefs/<nombre>/`, `projects/welcome/`, `projects/seis-sombreros/`, `projects/metodo-ias/`, `projects/visual/`)
- **Clientes**: `clients/<nombre>/` (con `clients/_templates/` para nuevos)
- **Docs operativos**: `docs/`
- **Scripts del installer**: `scripts/install.sh`, `scripts/_install-gate.sh`, `scripts/_install-state.template.json`
- **Vendored**: `vendor/sinapsis/` (engine), `vendor/cognito/` (Sistema Operativo de Pensamiento de Luis Pitik), `vendor/arnes/` (skill opt-in para arrancar proyectos software, concepto fs-scaffold de Fernando Montero)

### Paths Sinapsis (engine global del operador)
- **Skills root global**: `~/.claude/skills/` (Sinapsis instalado por install.sh)
- **Operator state**: `~/.claude/skills/_operator-state.json`
- **Install state (v0.6+)**: `~/.claude/skills/_install-state.json` ← fuente de verdad de la instalación
- **Install gate hook**: `~/.claude/skills/_install-gate.sh` (SessionStart hook)
- **Instincts**: `~/.claude/skills/_instincts-index.json`
- **Daily summaries**: `~/.claude/skills/_daily-summaries/`
- **Catalog**: `~/.claude/skills/_catalog.json`

### MANDATORY first action (post-gate)

Una vez confirmado que la instalación está completa, antes de responder al primer mensaje del usuario:

1. Lee `~/.claude/skills/_operator-state.json` (Sinapsis: perfil del operador, decisiones, lecciones).
2. Lee los 5 archivos sectorizados de `context/` si existen: `me.md`, `work.md`, `team.md`, `current-priorities.md`, `goals.md`.
3. Lee `context/decisions-log.md` (últimas 5 entradas) para mantener coherencia.
4. Lee cualquier plan activo en `.claude/plans/` si la carpeta existe (planes en progreso de sesiones anteriores).
5. Lee `synapsis/daily-summaries/<TODAY>.md` o `<YESTERDAY>.md` (continuidad diaria).

### Session continuity (operativa diaria)

Cuando todo está configurado y la instalación está completa:
1. Daily summary de ayer (Sinapsis)
2. `context/learnings.md` (feedback consolidado de skills)
3. Proyectos abiertos en `projects/briefs/*/brief.md` con `status: active`
4. Saluda con: "Ayer dejaste X. Sigues con Y o cambias?"

---

## Sobre el sistema

### Sinapsis (engine de memoria)
Sinapsis es el sistema que hace que Claude Code aprenda de ti. Vive instalado en `~/.claude/` (no en este repo). El repo lo trae vendored en `vendor/sinapsis/` para instalación.

Sinapsis te da:
- **Operator state**: tu identidad, stack, decisiones — persiste en TODOS los proyectos
- **Instincts**: patrones aprendidos que se inyectan automáticamente cuando aplican
- **Passive rules**: guardrails técnicos (seguridad, calidad, workflow)
- **Skills on-demand**: solo carga las relevantes (~2.800 tokens vs ~25.000)
- **Dream cycle**: limpieza periódica de memoria
- **Dashboard** (`/dashboard-sinapsis`): métricas reales

Comandos Sinapsis instalados global:
- `/system-status` · `/evolve` · `/instinct-status` · `/passive-status` · `/eod` · `/dream` · `/analyze-session`

### Capa OS (este repo)
Lo que aporta este repo encima de Sinapsis:

**Brand Context (`brand-context/`)** — estática:
- Voice profile + 3 registros (A formal / B divulgativo / C cercano)
- Positioning, ICP, brand assets

**Agent Context (`context/`)** — dinámica:
- `soul.md` — personalidad del agente (cómo respondes)
- `me.md`, `work.md`, `team.md`, `current-priorities.md`, `goals.md`
- `learnings.md`, `decisions-log.md`

**Skills curadas (`.claude/skills/`)** — 26 skills core (ver registry abajo).

**Niveles de proyecto**:
1. **Single task** — pregunta directa. Output a `projects/<skill-name>/<fecha>-<titulo>/`.
2. **Planned project** — scoping conversation. Output a `projects/briefs/<nombre>/`.
3. **GSD project** — multi-fase. `.planning/` en cliente o raíz.

**Multi-cliente**:
- `clients/<nombre>/` con su propio brand-context, context, projects
- Templates en `clients/_templates/` para 4 verticales

---

## Skills registry (v0.8.0)

Capa 1 = 26 skills core + 2 opcionales (cognito, arnes).

### `_meta/` — sistema (10)

| Skill | Descripción corta |
|---|---|
| `meta-skill-creator` | Crea skills nuevas |
| `meta-onboarding-wizard` | Entrevista express por **4 sub-fases con commits incrementales** (v0.6) |
| `meta-deep-dive` | Entrevista profunda (22-25 dimensiones) — opcional |
| `meta-start-here` | Ritual diario de inicio |
| `meta-wrap-up` | Ritual diario de cierre |
| `welcome-quick-win` | Primer entregable en 5 min |
| `seis-sombreros` | Seis sombreros de De Bono con **anti-ancla, 7 variantes, marcos divergentes y matriz de decisión** (v0.7) |
| `decisions-log` | Diario append-only de decisiones |
| `health-check` | Diagnóstico del OS con **validación profunda y detección de drift** (v0.6) |
| `find-skills` | Descoverabilidad por intent |

### `_meta/_optional/` (2)

| Skill | Cómo activar |
|---|---|
| `cognito` | `/install-skill cognito` |
| `arnes` | `/install-skill arnes` (🆕 v0.8.0) — arrancar proyectos software por niveles. Concepto fs-scaffold de Fernando Montero. Vendoreada en `vendor/arnes/` |

### `marketing/` (6)

| Skill | Descripción |
|---|---|
| `marketing-brand-voice` | Voice profile + 3 registros |
| `marketing-positioning` | Posicionamiento competitivo |
| `marketing-icp` | Cliente ideal |
| `marketing-copywriting` | Copy con humanizer gate |
| `marketing-content-repurposing` | Distribución multiplataforma |
| `marketing-email-sequence` | Secuencias de email |

### `automation/` (2)

| Skill | Descripción |
|---|---|
| `automation-n8n-to-claude` | Migra workflows n8n al ecosistema Claude |
| `automation-n8n-builder` | Crea workflows n8n vía MCP `n8n-mcp` |

### `strategy/` (4)

| Skill | Descripción |
|---|---|
| `metodo-ias` | Método I.A.S. (Intención · Acción · Síntesis) anti-AI-brain-fry — diario + semanal (v0.7) |
| `strategy-web-research` | Research ligero con subagentes (lookups rápidos) |
| `strategy-deep-research` | 🆕 Deep research iterativo: prioriza fuentes primarias/oficiales sobre blogs, modo médico con MCP PubMed + proxy universitario, citas verificables, reporte MD + HTML |
| `strategy-prd-builder` | 🆕 Crea PRDs híbridos (documento de decisión + playbook de construcción estilo "paso a paso") para apps, SaaS, no-code o contenido. Buenas prácticas empotradas (Atlassian/Maze/Lenny's). Output MD revisable en bloc de notas + HTML opcional |

### `tools/` (4)

| Skill | Descripción |
|---|---|
| `tool-firecrawl-scraper` | Wrapper Firecrawl |
| `tool-humanizer` | Quita patrones AI-tell |
| `tool-output-verifier` | Gate de calidad |
| `tool-zoom-summary` | Resumen HTML interactivo de reuniones Zoom (transcripción + chat + topics + recursos) (v0.7) |

### `visualization/` (1)

| Skill | Descripción |
|---|---|
| `tool-visual-explainer` | HTML autocontenido compartible |

### Plugins Anthropic (instalación vía marketplace)

| Skill | Cómo activar |
|---|---|
| `docx`, `xlsx`, `pdf`, `pptx` | `/plugin install anthropic-skills` |

### Slash commands

`/install` · `/install-status` · `/start-here` · `/wrap-up` · `/doctor` · `/add-client` · `/install-skill` · `/install-mcp` · `/aprende` · `/deep-dive`

Los dos primeros (`/install`, `/install-status`) son nuevos en v0.6 y son la **única vía oficial** para gestionar la instalación desde dentro de Claude Code.

### Capa 2 — on-demand library

Ver [`docs/skills-recommended.md`](docs/skills-recommended.md) para skills opcionales instalables vía `/install-skill <github-url>`.

---

## Niveles de proyecto — heartbeat

Al iniciar cada sesión (post-gate), comprueba `projects/briefs/*/brief.md`:
- Si hay `status: active`, recuérdale qué dejó abierto.
- Si hay un `.planning/` en raíz o cliente, indica que hay un GSD en marcha.
- Si terminó algo (`status: done`), pregunta si archivamos.

---

## Cómo registrar skills nuevas (auto)

Cuando se añade una skill nueva en `.claude/skills/<categoria>/<nombre>/`:
- `/start-here` la detecta y registra en catalog
- `/wrap-up` actualiza el registry de este CLAUDE.md
- El comando `/install-skill <github-url>` la valida antes de añadirla

---

## Permisos (recordatorio)

`.claude/settings.json` viene con permisos seguros por defecto:
- ✅ Read files, dev server, git operations, edit files dentro del repo
- ❌ Install packages globalmente, delete files, leer `.env`

Si necesitas más permisos: `claude --dangerously-skip-permissions` (puntual) o edita `settings.json`.

---

## Idioma

- **Operativa con el usuario**: castellano por defecto
- **Comentarios técnicos en código**: inglés
- **Commits**: conventional commits en inglés
- **Outputs entregables al cliente**: idioma del cliente (detectar en brand-context)

---

## Convenciones del repo

- Carpetas en kebab-case (`brand-context`, `clients`, `projects`)
- Archivos markdown en kebab-case
- Skills en kebab-case con prefijo de categoría: `marketing-brand-voice`, `tool-humanizer`, etc.
- Outputs por fecha: `YYYY-MM-DD-titulo-corto/`
- Variables de entorno en `.env`

---

## Cuándo NO usar el OS

Casos donde mejor abre Claude Code en otro lado:
- Editar el código de tu propia app
- Bug puntual sin necesidad de brand context
- Sesión exploratoria que no quieres que ensucie tu memory

Para casos donde sí:
- Crear contenido (LinkedIn, X, blog, email, video script)
- Trabajar con un cliente (entras en `clients/<nombre>/`)
- Análisis estratégico
- Generar deliverables con voice consistente

---

## Soporte y comunidad

- Issues: https://github.com/iamasters-academy/iamasters-os/issues
- Sinapsis upstream: https://github.com/Luispitik/sinapsis
- Schema doc del install gate: [`docs/install-state-schema.md`](docs/install-state-schema.md)
