---
name: spec-kit
description: Aplica desarrollo dirigido por especificación (Constitution → Specify → Plan → Tasks → Implement) usando Spec Kit de GitHub para construir software con requisitos claros antes de picar código. Úsala cuando el operador diga "hazlo con spec-kit", "desarrollo dirigido por spec", "especifica antes de programar", "quiero requisitos y plan antes del código" o arranque un proyecto de software que merezca rigor de especificación.
---

# spec-kit

> **Adaptación iAmasters OS** — Wrapper de `github/spec-kit` (MIT, oficial). No vendoriza su código:
> instala su CLI y orquesta el flujo. Puente al OS: complementa [[arnes]] (arranque de proyecto) — Spec
> Kit aporta la disciplina de especificación; la cadena de build (`ui-ux-pro-max` → `theme-factory` →
> `react-best-practices`/`backend-development` → `vercel-deploy`) ejecuta después. Encaja con proyectos
> Estándar/PRO, no para un fix puntual.

## Cuándo se invoca
- El operador dice "hazlo con spec-kit", "especifica antes de programar", "requisitos y plan antes del código".
- Arranque de un proyecto de software con suficiente alcance para justificar spec formal.
- Como capa de rigor sobre [[arnes]] cuando el proyecto lo merece.

## Setup (una vez, runtime)
- **Instalar** Spec Kit: `uv`/pipx (`uvx --from git+https://github.com/github/spec-kit specify …`) o `pip install spec-kit`. Requiere Python 3.11+ y git.
- Provee slash commands `/speckit.constitution`, `/speckit.specify`, `/speckit.plan`, `/speckit.tasks`, `/speckit.implement`.
- **Validación**: `specify` responde y el proyecto tiene la estructura de Spec Kit inicializada.

## Process

### Paso 1 · Constitution + Specify
- Establece principios del proyecto (`constitution`) y escribe la especificación (requisitos/historias de usuario) con `specify`. Recoge el "qué" y el "por qué", no el "cómo".
- **Validación**: existe el doc de spec con historias de usuario claras.

### Paso 2 · Plan + Tasks
- Genera el plan (arquitectura + stack) con `plan` y la lista ordenada de tareas con `tasks`.
- **Validación**: plan con decisiones técnicas + backlog de tareas ejecutable.

### Paso 3 · Implement
- Ejecuta las tareas en orden con `implement`, verificando cada una. Enlaza con las skills de build del OS para el código real.
- Append en `context/learnings.md` bajo `## spec-kit`.

## Outputs
- Artefactos de Spec Kit en el repo del proyecto (spec, plan, tasks) + código implementado.

## Skills que llama
- **`arnes`** — arranque/scaffold del proyecto (complementario).
- **`ui-ux-pro-max`** / **`react-best-practices`** / **`backend-development`** — implementación.
- **`vercel-deploy`** / **`automation-client-deploy`** — despliegue al cerrar.

## Edge cases
- Fix puntual / script pequeño → no uses spec-kit (overhead); ve directo.
- Sin Python 3.11+/git → resuelve setup antes.
- Proyecto ya en marcha → aplica desde `specify` sobre lo existente, no reinicies la constitution si ya hay convenciones.

## Examples

Ver `references/examples.md` para casos completos.
