# spec-kit — Ejemplos

## Ejemplo 1 · Arrancar una app con rigor de spec

**Operador**: "Quiero montar una webapp de reservas, pero bien especificada antes de programar."

**Flujo**:
1. `constitution` (principios: privacidad, i18n) + `specify` (historias: reservar, cancelar, recordatorio).
2. `plan` (Next.js + Supabase) + `tasks` (backlog ordenado). Se revisa con el operador.
3. `implement` tarea a tarea, apoyándose en `react-best-practices`/`backend-development`. Deploy con `vercel-deploy`.

## Ejemplo 2 · Complemento de arnes

**Operador**: "Arranca este proyecto con arnes pero añade la disciplina de spec."

**Flujo**:
1. `arnes` hace el scaffold; spec-kit aporta `specify`/`plan`/`tasks` encima.
2. Se evita duplicar convenciones: si arnes ya fijó estructura, la constitution la respeta.

## Nota

Es para proyectos con alcance. Para un bug o un script suelto, el overhead de spec-kit no compensa.
