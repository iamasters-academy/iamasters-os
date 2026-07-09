---
name: arnes
description: Skill opt-in para arrancar proyectos de software paso a paso, pensada para vibe-coders no tecnicos de IA Masters Academy. Tres niveles segun lo serio que sea el proyecto (Express 5 min / Estandar 20-30 min / PRO 1-2 h) mas dos modos para proyectos existentes (Adoptar / Mantener). SIEMPRE pregunta primero que nivel quieres porque la mayoria de veces basta con Express. ACTIVAR cuando el usuario diga «nuevo proyecto», «crear una app», «monta una web», «landing», «arrancar proyecto», «adopta este proyecto», «renueva este proyecto», o describa la idea de un software/web/app que quiere construir. Esta skill vive vendoreada en `vendor/arnes/` y se activa con `/install-skill arnes`.
version: 0.2.4
---

# arnes (vendored wrapper)

> **Origen del concepto**: `fs-scaffold` por Fernando Montero, presentado en el Cafe Camaleonico del 18 de mayo de 2026 en la comunidad iAmasters Academy.
> **Adaptacion a vibe-coders**: Angel Aparicio (IA Masters Academy).
> **Repo upstream**: [github.com/iamasters-academy/arnes](https://github.com/iamasters-academy/arnes) (publico, MIT).
> **Vendoreada en**: `vendor/arnes/` (intacta — sin modificaciones).
> **Tras activacion**: `~/.claude/skills/arnes/` (la copia `/install-skill arnes` al activarla).

## Que es

Una skill que ayuda a montar proyectos software sin que la IA se descontrole y sin que tu tengas que entender tecnicismos. Mantiene el rigor en Modo PRO (SDD + TDD completo, revision adversarial) pero ofrece niveles mas ligeros (Express, Estandar) para el 80% de casos donde no hace falta tanto ceremonial.

## Como se carga

La skill real vive en `vendor/arnes/` mientras esta sin activar. Cuando ejecutas `/install-skill arnes`:

1. La carpeta `_meta/_optional/arnes/` se mueve a `_meta/arnes/`.
2. La skill se copia a `~/.claude/skills/arnes/` (instalacion global Sinapsis-style).
3. Claude Code la carga la proxima vez que arranques.

A partir de ahi, Claude Code lee `~/.claude/skills/arnes/SKILL.md` cuando detecta intent que la activa — no este archivo. Este wrapper solo existe para:

1. Documentar que la skill esta disponible en el OS.
2. Mantener el patron «una carpeta por skill en `.claude/skills/_meta/_optional/`».
3. Permitir que `find-skills` y `health-check` la detecten en el inventario.

## Los 5 modos (resumen)

| Modo | Cuando | Tiempo | Artefactos |
|---|---|---|---|
| ⚡ Express | Landing, MVP, prueba | 5 min | Cero (solo codigo) |
| 🛠️ Estandar | App con usuarios/datos | 20-30 min | 2 (spec + tests) |
| 🎯 PRO | Cliente que paga, alta calidad | 1-2 h | 6 (spec, plan, tasks, tests, review, adversarial) |
| Adoptar | Proyecto existente sin armazon | variable | Anrnade armazon sin tocar tu codigo |
| Mantener | Proyecto Arnes con version vieja | variable | Solo actualiza armazon |

Detalle completo en `vendor/arnes/README.md` y `vendor/arnes/modos/`.

## Como activar

```
/install-skill arnes
```

Tras la activacion, reinicia Claude Code. Triggea con frases como «nueva web», «monta una landing», «crea una app», «arrancar proyecto».

## Como desactivar

Mover `.claude/skills/_meta/arnes/` de vuelta a `.claude/skills/_meta/_optional/arnes/` y borrar `~/.claude/skills/arnes/`. La skill no volvera a triggear hasta que la actives de nuevo.

## Por que es opt-in

Para alguien que abre iAmasters OS por primera vez, arrancar proyectos software puede no ser su prioridad inmediata. Quien quiere arnes lo sabe; quien no lo necesita no se topa con ruido conceptual. Mismo criterio que `cognito`.

## Creditos

Skill creada por **Angel Aparicio** (IA Masters Academy) basada en el concepto original **fs-scaffold** de **Fernando Montero** (Fersora Solutions SL), presentado en el Cafe Camaleonico del 18 de mayo de 2026. La skill arnes adapta ese concepto para vibe-coders no tecnicos manteniendo el rigor donde importa.

## Edge cases

- **Conflicto con instalacion previa**: si ya existe `~/.claude/skills/arnes/`, `/install-skill arnes` te pregunta si reemplazar (con backup automatico).
- **Sin red**: la skill vive vendoreada, no requiere red para activarse.
- **Variable `ARNES_SKILL_DIR`**: si quieres la skill en otra ruta (instalacion compartida o portatil), define la env var antes de activar. Los modos y scripts de arnes la leen.

## Mantenimiento

La skill se mantiene en su repo upstream [`iamasters-academy/arnes`](https://github.com/iamasters-academy/arnes). Cuando saca nueva version, se actualiza `vendor/arnes/` mediante el flujo de "Mantener" de arnes o un PR a iamasters-os. Reportar bugs en: https://github.com/iamasters-academy/arnes/issues
