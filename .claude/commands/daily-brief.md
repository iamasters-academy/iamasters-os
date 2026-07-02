---
description: Genera el brief matutino de correo + agenda (Gmail + Google Calendar), cruzado con pendientes internos.
---

# /daily-brief

Invoca la skill `daily-brief` que vive en `skills-library/tools/daily-brief/SKILL.md`
(si no está instalada en `.claude/skills/tools/daily-brief/`, instálala primero
con `bash scripts/skills.sh add daily-brief`).

## Qué hace

1. Carga las tools MCP de Gmail y Google Calendar por capacidad (no por ID fijo)
2. Lista la agenda de hoy y marca solapes
3. Resume el correo prioritario de las últimas 24h (o desde el último brief)
4. Deja constancia explícita de que Drive no está conectado todavía
5. Cruza con `context/working-memory.md` y proyectos `status: active`
6. Guarda en `synapsis/daily-briefs/<fecha>.md` y responde con un resumen corto

## Comando

Carga e invoca la skill `daily-brief`. Sigue el proceso de su SKILL.md paso a paso.
