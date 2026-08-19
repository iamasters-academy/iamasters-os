---
description: Ritual de inicio de sesión iAmasters OS. Carga contexto, recapitula pendientes, propone tarea del día.
---

# /start-here

Invoca la skill `meta-start-here` que vive en `.claude/skills/meta-start-here/SKILL.md`.

## Qué hace

1. Lee operator-state global (Sinapsis) y user.md (repo)
2. Comprueba si hay daily summary de ayer en `synapsis/daily-summaries/`
3. Lista proyectos abiertos en `projects/briefs/`
4. Saluda con resumen + propuesta de tarea para hoy

Si es primer arranque (no hay operator-state o user.md vacío), automáticamente deriva a `meta-onboarding-wizard`.

## Comando

Carga e invoca la skill `meta-start-here`. Sigue el proceso de su SKILL.md paso a paso.
