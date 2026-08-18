---
name: health-check
description: Diagnóstico de iAmasters OS con VALIDACIÓN PROFUNDA. v0.6 - no solo comprueba que existan archivos, sino que sean válidos y funcionales (JSON parseable, hooks ejecutables, contenido real >100 chars, etc.). Cruza con ~/.claude/skills/_install-state.json para detectar drift (state dice done pero archivos faltan, o al revés). Devuelve reporte 🟢🟡🔴 con acciones concretas. Soporta auto-fix limitado. Se invoca vía /doctor o cuando otra skill detecta inconsistencia.
---

# health-check

> **Cambio crítico v0.6**: ya no validas "el archivo existe". Validas que el archivo sea **funcionalmente correcto**: JSON parseable, contenido real, hooks ejecutables, contadores razonables.
>
> La fuente de verdad sobre qué debería estar instalado es `~/.claude/skills/_install-state.json`. Si dice que `sinapsis-engine` está `done` pero la validación profunda falla, eso es **drift** y hay que reportarlo (y opcionalmente arreglarlo).

## Cuándo se invoca

- Usuario ejecuta `/doctor`
- `meta-start-here` detecta inconsistencia al arrancar sesión
- Tras `update.sh` para verificar la actualización
- Usuario reporta "algo no funciona" sin saber qué
- (NUEVA) `/install` post-fase invoca para validar antes de marcar `done`

## Process

### Paso 0 · Leer fuente de verdad

Lee `~/.claude/skills/_install-state.json` con la tool `Read`. Si NO existe:
- Reporta 🔴 instalación no iniciada
- Indica al usuario ejecutar `bash scripts/install.sh`
- Para.

Guarda en memoria mental:
- Qué fases dice el state que están `done`
- Lista de `completedPhases`
- Errores recientes en `errors[]`

### Paso 1 · Verificación entorno (validación profunda)

| Check | Validación REAL | Severidad si falla |
|---|---|---|
| Claude Code CLI / app | `which claude` o env var `CLAUDECODE` / `CLAUDE_DESKTOP` o `~/Applications/Claude.app` | 🔴 si nada detectado |
| Repo raíz correcto | `CLAUDE.md` + `.claude/` + `vendor/sinapsis/` en `pwd` | 🔴 si falta alguno |
| Git inicializado | `.git/` existe | 🟡 |
| `.env` válido | Existe Y no tiene líneas obviamente rotas (no sintaxis tipo `KEY:value`) | 🟡 |
| Node.js ≥18 | `node --version` parseable, mayor ≥18 | 🔴 (Sinapsis hooks lo requieren) |
| Python 3 disponible | `python3 --version` o `py -3 --version` o `python --version` con Python 3 | 🟡 |

Usa la tool `Bash` para los `which`/`--version`.

### Paso 2 · Verificación Sinapsis (validación PROFUNDA)

Esta sección es la que evita "instalaciones fantasma". No te fíes de que el archivo exista — valídalo:

| Check | Validación real | Severidad |
|---|---|---|
| `_operator-state.json` parseable | `node -e "JSON.parse(require('fs').readFileSync('~/.claude/skills/_operator-state.json'))"` no falla | 🔴 |
| `_operator-state.json` tiene campos mínimos | `.operator.name` y `.operator.language` no son null/empty | 🟡 (sin esto el wizard no ha terminado) |
| `_catalog.json` parseable | mismo | 🟡 |
| Hooks ejecutables (7 hooks) | `_passive-activator.sh`, `_instinct-activator.sh`, `_session-learner.sh`, `_project-context.sh`, `_eod-gather.sh`, `_dream.sh`, `_precompact-guard.sh` existen Y tienen permiso `+x` | 🔴 si falla ≥2, 🟡 si falla 1 |
| ≥1 SKILL.md instalada | `find ~/.claude/skills -maxdepth 3 -name SKILL.md` devuelve ≥1 resultado | 🔴 |
| Hooks REALMENTE cableados en settings.json | `~/.claude/settings.json` parseable Y `hooks` referencia `_passive-activator.sh`, `_instinct-activator.sh` (PreToolUse) y `_session-learner.sh` (Stop). **Este es el check funcional real**: si faltan, Sinapsis está instalado pero el motor de aprendizaje NO se dispara (muerte silenciosa). Ojo: que exista la palabra `"hooks"` NO basta. | 🔴 |
| Install-gate registrado | `~/.claude/settings.json` contiene `hooks.SessionStart` con referencia a `_install-gate.sh` | 🟡 |
| **DRIFT check** | Si `_install-state.json.phases.sinapsis-engine.status == "done"` Y alguno de los anteriores falla → **DRIFT** | 🔴 con flag "STATE DRIFT" |

Para los checks de hooks ejecutables, usa Bash:
```bash
for h in _passive-activator.sh _instinct-activator.sh _session-learner.sh _project-context.sh _eod-gather.sh _dream.sh _precompact-guard.sh; do
  [ -x "$HOME/.claude/skills/$h" ] && echo "OK $h" || echo "FAIL $h"
done

# Check funcional real: ¿están los hooks de Sinapsis cableados en settings.json?
for h in _passive-activator.sh _instinct-activator.sh _session-learner.sh; do
  grep -q "$h" "$HOME/.claude/settings.json" 2>/dev/null && echo "WIRED $h" || echo "NOT-WIRED $h"
done
```

### Paso 3 · Verificación capa OS — brand-context

| Check | Validación | Severidad |
|---|---|---|
| `brand-context/` existe | sí | 🔴 |
| `voice/voice-profile.md` | Existe + >100 chars | 🟡 (skill: `marketing-brand-voice`) |
| `voice/samples.md` | Existe + >100 chars | 🟡 |
| Registros A/B/C | Los 3 archivos existen | 🟡 |
| `positioning/positioning.md` | Existe + >100 chars | 🟡 |
| `icp/icp.md` | Existe + >100 chars | 🟡 |

### Paso 4 · Verificación capa OS — context sectorizado (con drift check)

Para CADA uno de los 4 archivos críticos:

| Check | Validación | Severidad |
|---|---|---|
| `context/me.md` | Existe + >100 chars + contiene `## Nombre` con valor real | 🟡 si vacío (skill: `meta-onboarding-wizard`) |
| `context/work.md` | Existe + >100 chars + contiene `## Qué hago` | 🟡 |
| `context/current-priorities.md` | Existe + >100 chars + tiene al menos una prioridad listada | 🟡 |
| `context/goals.md` | Existe + >100 chars | 🟡 |
| `context/team.md` | Existe (puede estar vacío si trabaja solo) | 🟢 |
| `context/decisions-log.md` | Existe con header canónico | 🟡 auto-fix |
| `context/learnings.md` | Existe | 🟢 auto-fix |
| `context/soul.md` | Existe + >100 chars | 🟡 |

**DRIFT check para context-files**:
- Si `state.phases.context-files.status == "done"` PERO alguno de los 4 archivos críticos no existe o tiene <100 chars → reporta 🔴 **STATE DRIFT** + propone fix:
  > "El state dice que `context-files` está done pero `<archivo>` está vacío/inexistente. Esto indica una marca falsa. Voy a revertir el state a `in-progress` y reactivar el wizard. ¿Continúo?"

### Paso 4.5 · Verificación Loop Engine

Skip silencioso si no existe `loops/` o no hay carpetas de loop en `loops/<nombre>/` (excluye `_templates/`).

Si hay ≥1 loop creado:

| Check | Validación | Severidad |
|---|---|---|
| `context/loops-config.md` | Existe | 🟡 |
| `loops/_index.md` | Existe | 🟡 |
| Cada loop tiene `loop-spec.md` | Existe | 🔴 |
| Cada loop tiene `REGLAS.md` | Existe | 🔴 |
| `loops/_index.md` lista todos los loops | Cada carpeta `loops/<nombre>/` aparece en el índice | 🟡 |
| Reglas por estación | Si una estación tiene >12 reglas en un `REGLAS.md` → ⚠️ "esa estación necesita rediseño" | 🟡 |

Reporte sugerido:

```
### Loop Engine
🟢 3 loops detectados
🟢 propuestas: loop-spec.md + REGLAS.md
🟡 onboarding-clientes no aparece en loops/_index.md
🟡 propuestas · estación redacción tiene 14 reglas → esa estación necesita rediseño
```

### Paso 5 · Verificación skills curadas

Lista skills CORE (siempre instaladas — 17):

```
.claude/skills/meta-skill-creator/SKILL.md
.claude/skills/meta-onboarding-wizard/SKILL.md
.claude/skills/meta-deep-dive/SKILL.md
.claude/skills/meta-start-here/SKILL.md
.claude/skills/meta-wrap-up/SKILL.md
.claude/skills/welcome-quick-win/SKILL.md
.claude/skills/decisions-log/SKILL.md
.claude/skills/health-check/SKILL.md
.claude/skills/find-skills/SKILL.md
.claude/skills/recuerda/SKILL.md
.claude/skills/marketing-brand-voice/SKILL.md
.claude/skills/marketing-positioning/SKILL.md
.claude/skills/marketing-icp/SKILL.md
.claude/skills/automation-loop-engine/SKILL.md
.claude/skills/tool-firecrawl-scraper/SKILL.md
.claude/skills/tool-humanizer/SKILL.md
.claude/skills/tool-output-verifier/SKILL.md
```

Las de `skills-library/` NO van en esta lista: son opt-in y su ausencia es normal, no un fallo.
Para verlas: `bash scripts/skills.sh list`.

**Estructura (🔴 crítico):** toda skill debe estar a UN nivel — `.claude/skills/<nombre>/SKILL.md`.
Claude Code solo indexa un nivel: una carpeta de categoría intermedia deja la skill invisible para
el tool Skill (`Unknown skill: <nombre>`) aunque el archivo exista y el frontmatter sea válido.

```bash
find .claude/skills -mindepth 3 -name SKILL.md -not -path "*_archived*"
```

Cualquier resultado → 🔴 "skill anidada, no la carga nadie" · acción: mover a `.claude/skills/<nombre>/`
(o reinstalar con `bash scripts/skills.sh add <nombre>`). `_archived/` está anidado A PROPÓSITO para
que no cargue: es la excepción esperada.

**Nombre = carpeta (🟡):** para las skills de proyecto el nombre de invocación lo da el NOMBRE DE LA
CARPETA, no el frontmatter. Si `name:` y la carpeta no coinciden, avisa: se invoca por la carpeta.

Por cada faltante: 🟡 con sugerencia "ejecuta `bash scripts/update.sh` para sincronizar".

### Paso 6 · Verificación settings

| Check | Validación | Severidad |
|---|---|---|
| `.claude/settings.json` del repo parseable | JSON válido | 🔴 |
| `~/.claude/settings.json` global parseable | JSON válido | 🔴 |
| Permissions seguras (repo) | No `Bash(*)` ni similares peligrosos en `permissions.allow` | 🟡 |
| No secrets en settings | No hay strings que parezcan API keys (busca `sk-`, `fc-`, `pk_`) | 🔴 |

### Paso 7 · Verificación API keys (opcionales, en `.env`)

| Check | Validación | Severidad |
|---|---|---|
| `FIRECRAWL_API_KEY` | Set + empieza por `fc-` + ≥20 chars | 🟡 (sin esto, scraping manual) |
| Otras keys mencionadas en `.env.example` | Set si están documentadas | 🟢 (informativo) |

### Paso 8 · Compilar reporte

Genera reporte estructurado:

```
# 🩺 iAmasters OS · Health Check v0.6

📅 <fecha y hora>
📂 Repo: <ruta absoluta>
👤 Operador: <nombre desde operator-state o "(sin nombre)">
🎯 Versión OS: <leer de CHANGELOG.md primera línea>

## Resumen

🟢 OK: <N> componentes
🟡 AVISO: <N> componentes
🔴 ERROR: <N> componentes

State machine: <X>/5 required phases done · <currentPhase>

## State Drift detectado
<si hay drift, listarlo aquí. Si no, omitir esta sección>

## Detalle

### Entorno
🟢 Claude Code detectado
🟢 Node v20.10.0
🟡 Python no detectado

### Sinapsis (validación profunda)
🟢 _operator-state.json parseable + campos mínimos
🟢 _catalog.json parseable
🟢 5/5 hooks ejecutables
🟢 27 SKILL.md instaladas
🟢 Hooks Sinapsis registrados en settings.json
🟢 Install-gate registrado en settings.json
🟢 No hay drift

### Capa OS — Brand Context
🟡 voice-profile.md vacío
   → Acción: ejecuta `marketing-brand-voice` (10 min)

### Capa OS — Context sectorizado
🟢 me.md (456 chars · nombre: Angel)
🟢 work.md (812 chars)
🟢 current-priorities.md (234 chars · 3 prioridades)
🟢 goals.md (180 chars)

### Skills curadas
🟢 27/27 skills core presentes

### Settings
🟢 Repo settings.json válido
🟢 Global settings.json válido
🟢 Sin secretos hardcoded

### API keys
🟡 FIRECRAWL_API_KEY no encontrada

## Próximas acciones (orden por impacto)

1. <acción 1>
2. <acción 2>
3. <acción 3>
```

### Paso 9 · Auto-fix limitado

Solo ofrece auto-fix para problemas reversibles y seguros:

```
Detecté <N> problemas con fix automático:
  • Crear context/decisions-log.md con header (si falta)
  • Crear context/learnings.md con header (si falta)
  • Re-aplicar chmod +x a hooks Sinapsis (si no son ejecutables)
  • Re-registrar _install-gate.sh en ~/.claude/settings.json (si fue removido)

¿Aplico los fixes? (s/n)
```

Si dice "s", aplícalos uno a uno mostrando qué hace cada uno.

**Fix de DRIFT** es ESPECIAL — requiere confirmación explícita extra:
```
🚨 STATE DRIFT detectado en fase "<X>".
El state dice "done" pero la validación profunda falla.

Quiero revertir el state a "in-progress" para que el sistema fuerce
re-ejecutar la fase. Esto NO borra archivos — solo cambia el flag.

¿Confirmas? (escribe "sí, revertir")
```

Si responde literal "sí, revertir": revierte el state. Si dice cualquier otra cosa: NO toques nada.

### Paso 10 · Cierre

- Si todo 🟢: muestra proyectos abiertos (`projects/briefs/*/brief.md` con `status: active`) y propón continuar
- Si hay 🟡: plan de acción priorizado
- Si hay 🔴 o DRIFT: bloqueante, sugiere fix antes de seguir
- Append a `context/learnings.md` SOLO si descubriste algo recurrente (no por cada ejecución)

## Outputs

- Reporte en chat (Paso 8)
- Opcional: HTML compartible vía `tool-visual-explainer` si >5 🟡
- (Si auto-fix aplicado) archivos creados/permisos modificados

## Edge cases

- **Repo abierto pero no es iamasters-os**: detecta ausencia de `vendor/sinapsis/` → "no estás en un repo iamasters-os, este check no aplica"
- **State file no existe**: reporta como 🔴 fundamental, sugiere `bash scripts/install.sh`
- **State file corrupto** (JSON inválido): reporta 🔴, sugiere `bash scripts/install.sh --force-reinstall`
- **Drift en múltiples fases simultáneamente**: lista cada una con su detalle, ofrece revertir todas con UN solo confirmador
- **Cliente activo en `clients/<X>/`**: validar también su sub-context

## Auto-fixes disponibles (resumen)

| Fix | Sin preguntar | Requiere "sí" | Requiere "sí, revertir" |
|---|---|---|---|
| Crear decisions-log.md / learnings.md vacío | — | ✓ | — |
| chmod +x a hooks | — | ✓ | — |
| Re-registrar install-gate hook | — | ✓ | — |
| Revertir state drift | — | — | ✓ |
| Crear `.env` desde `.env.example` | — | ✓ | — |
| Cualquier fix de Sinapsis instalación | (delegar a `bash scripts/install.sh --resume`) | | |

## Notas operativas

- NO recolectas datos personales ni cambias configuración de comportamiento
- Output **rápido de leer** — usuario debe entender en 30s el estado general
- 🟡 NO bloquea uso, 🔴 SÍ bloquea uso, **DRIFT** es 🔴 con tratamiento especial
- Si reporta >8 🟡 considera generar HTML compartible
