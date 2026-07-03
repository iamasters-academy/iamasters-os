---
name: cognito
description: Sistema Operativo de Pensamiento de Luis Pitik. Orquesta 7 modos cognitivos (divergente, verificador, devil's advocate, consolidador, ejecutor, estratega, auditor) según 5 fases de proyecto (discovery, planning, execution, review, shipping). Esta skill vive vendoreada en `vendor/cognito/` (intacta) e instalada globalmente en `~/.claude/skills/cognito/` por el installer. ACTIVAR SIEMPRE que la conversación involucre decisiones con trade-offs, cambios de enfoque, análisis profundo, cambios de fase explícitos, o detección de ancla. Coexiste con Sinapsis sin conflicto.
version: 1.0.0
---

# cognito (vendored wrapper)

> **Origen**: [github.com/Luispitik/cognito](https://github.com/Luispitik/cognito) por Luis Pitik.
> **Vendoreada en**: `vendor/cognito/` (mantenida intacta — sin modificaciones).
> **Instalada globalmente**: `~/.claude/skills/cognito/` (la copia el `install.sh` si no existe).

## Qué es

Cognito es un sistema operativo cognitivo independiente que orquesta 7 modos de pensamiento según 5 fases de proyecto. iAmasters OS la vendorea **intacta** porque es un producto separado de Luis con su propio versionado, tests y documentación.

## Cómo se carga

La skill REAL vive en `~/.claude/skills/cognito/SKILL.md` (instalación global de Sinapsis-style). El installer la copia desde `vendor/cognito/` la primera vez.

**Cuando Claude Code activa la skill `cognito`, lee `~/.claude/skills/cognito/SKILL.md`** — no este archivo. Este wrapper solo existe para:

1. Documentar que la skill está disponible en el OS
2. Mantener el patrón de "una carpeta por skill en `.claude/skills/_meta/`"
3. Permitir que `find-skills` y `health-check` la detecten en el inventario

## Modos cognito (resumen)

Para detalle completo, ver `~/.claude/skills/cognito/SKILL.md` o `vendor/cognito/SKILL.md`.

- **Divergente** — explora alternativas, evita convergencia prematura
- **Verificador** — comprueba supuestos, valida datos
- **Devil's advocate** — ataca el plan para descubrir agujeros
- **Consolidador** — sintetiza, junta hilos
- **Ejecutor** — convierte plan en pasos accionables
- **Estratega** — visión a largo plazo, encaje en sistema mayor
- **Auditor** — revisión crítica final antes de cerrar

## Modos según fase

- **Discovery**: divergente + verificador
- **Planning**: estratega + devil's advocate
- **Execution**: ejecutor + verificador
- **Review**: auditor + consolidador
- **Shipping**: ejecutor + auditor

## Modo guiado vs completo

iAmasters OS añade UNA capa sobre cognito: durante el onboarding, `meta-onboarding-wizard` pregunta si quieres modo **guiado** (4 modos esenciales auto-elegidos por contexto) o **completo** (los 7 modos × 5 fases = 35 combinaciones disponibles para elegir manualmente).

La preferencia se guarda en `~/.claude/skills/_operator-state.json` como `cognitoMode: "guiado" | "completo"`.

Puedes cambiar en cualquier momento: `/cognito-mode <guiado|completo>` (si el comando está disponible) o editando manualmente el operator-state.

## Skills que llama

Cognito puede invocar skills que detectan modos auto-triggered. No las nombramos aquí porque viven en su propio sistema.

## Edge cases

- **Cognito no instalada globalmente**: el installer la copia desde `vendor/cognito/`. Si falla, ejecuta manualmente:
  ```bash
  cp -r vendor/cognito ~/.claude/skills/cognito
  ```
- **Conflicto con Sinapsis**: NO hay. Ambas skills coexisten con scopes distintos (Sinapsis = memoria, cognito = razonamiento).
- **Modo guiado pero usuario quiere ver opciones**: aceptar override por turno con `/modo <nombre>`.

## Crédito

Skill autoría de **Luis Pitik** ([github.com/Luispitik](https://github.com/Luispitik)). iAmasters OS la usa con respeto al patrón "vendoring intacto" + atribución completa. Ver `vendor/cognito/LICENSE` y `vendor/cognito/AUTHORS.md`.
