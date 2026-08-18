---
description: Cierre de sesión iAmasters OS. Genera daily summary, sincroniza skills, propone commit.
---

# /wrap-up

Invoca la skill `meta-wrap-up` que vive en `.claude/skills/meta-wrap-up/SKILL.md`.

## Qué hace

1. Recapitula la sesión (qué se hizo, qué quedó)
2. Sincroniza `synapsis/skills-catalog.json` si hubo cambios en `.claude/skills/`
3. Actualiza el skills registry de `CLAUDE.md`
4. Append a `context/learnings.md` si hubo aprendizajes
5. Genera/actualiza `synapsis/daily-summaries/<TODAY>.md`
6. Detecta proyectos a archivar (status: done > 7 días)
7. Propone Git commit (espera aprobación)
8. Sugiere `/eod` Sinapsis si es final del día
9. Si el último backup tiene >7 días o no existe ninguno (`bash scripts/backup.sh --list`), sugiere en una línea lanzar `/backup` (30 segundos). No insistir si dice que no.

## Comando

Carga e invoca la skill `meta-wrap-up`. Sigue el proceso de su SKILL.md paso a paso.

NO hace push automático ni commit sin aprobación explícita.
