---
name: working-style-preferences
description: Preferencias de trabajo del operador Olaf Valldeperez
metadata:
  type: feedback
---

# Working Style — Preferencias del Operador

## Regla principal
**Cadencia: un paso + espera** — Lotes INDEPENDIENTES = completa uno, para, pide OK. Skills/pasos de una CADENA coherente SÍ se encadenan seguidos. Ofrecer agrupar y dejar que él elija el alcance.

**Por qué:** El operador prefiere validar cada paso antes de continuar. Evitar sorpresas. Siempre ofrecer "¿Procedo?" o "Continúo?" después de cada hito importante.

## Tono y estilo
- **Directo pero con el porqué** — No omitir la justificación
- **Conciso** — Máx 2-3 opciones con recomendación clara
- **Sin relleno** — Nada de "encantado de ayudar" ni emojis en contextos formales
- **Corregirme si me equivoco** — El operador corrige activamente; aceptar feedback inmediatamente

## Commits y Git
- **Conventional commits en inglés** — feat/fix/chore/docs/refactor/test
- **Subject under 72 chars** — Keep subject line corto
- **Co-authorship** — Siempre incluir `Co-Authored-By: Claude Sonnet 3.5 <noreply@anthropic.com>`
- **NUNCA push sin aprobación** — Poner siempre "¿Procedo con el commit?" antes
- **Respetar .gitignore** — Si archivos están ignorados, NO forzar add

## Planes y tareas
- **Plan mode primero** — Antes de implementar, ofrecer plan con opciones SÍ/NO
- **Tasks con TaskCreate** — Crear tasks solo para trabajo multi-step (>3 pasos)
- **One-liner NO** — Tarea trivial (1-2 líneas) → hacer directo, sin TaskCreate

## Skills y routing
- **Revisar CLAUDE.md registry** — Antes de ofrecer skill no instalada, verificar si está en biblioteca
- **Ofrécela cuando…** — Usar columna de disparadores (intención) para ofrecer skills
- **Skills instaladas** — Invocar directamente sin preguntar
- **Mix completo** — Cuando haya opciones, ofrecer 2 fáciles + 2 medios + 1 difícil (Fase 6 MIX pattern)

## Decisiones pendientes
- **Documentar en working-memory** — Si el operador toma decisión que afecta futuro, anotar
- **Clean up** — Decisiones tomadas → quitar de pendientes, añadir a decisions-log.md si es de fondo

## Visualización
- **Preview tools para verificar** — Antes de reportar "éxito", verificar en preview
- **No asumir** — Si cambio es observable en browser, comprobar primero

---
*Last updated: 2026-07-08*
