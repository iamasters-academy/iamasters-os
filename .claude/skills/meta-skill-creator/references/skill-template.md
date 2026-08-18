# Plantilla canónica para SKILL.md

> Copia este archivo como punto de partida cuando crees una nueva skill.
> Reemplaza los `{{placeholders}}` y borra las secciones que no apliquen.

```markdown
---
name: {{prefijo-categoria}}-{{nombre-kebab}}
description: {{Cuándo se invoca, qué hace. 50-500 chars. Verbos de intención: crea, genera, analiza, extrae, audita...}}
---

# {{Nombre humano de la skill}}

## Cuándo se invoca
- {{Patrón 1: lo que dice el usuario}}
- {{Patrón 2: skill X la llama tras hacer Y}}
- {{Patrón 3: hook detecta Z y propone esta skill}}

## Process

### Paso 1 · {{Verbo}}
{{Qué hacer, qué tools/archivos tocar, qué validar}}

- **Tool**: Read / Edit / Write / Bash / Skill (si invoca otra)
- **Inputs esperados**: {{lo que necesita}}
- **Validación**: {{cómo saber que el paso salió bien}}

### Paso 2 · {{Verbo}}
{{...}}

### Paso N · Cierre

- Si generaste output entregable → invoca `tool-output-verifier` con `score-only: true`
- Si la sesión enseñó algo nuevo → append en `context/learnings.md`:
  ```
  ## {{nombre-skill}}
  - YYYY-MM-DD: {{lección 1-line}}
  ```
- Si modificaste skills/ del repo → propón commit en próximo `/wrap-up`

## Outputs

- {{Archivo 1 en projects/.../...}}
- {{Edit en archivo existente}}
- {{Mensaje al usuario con resumen}}

## Skills que llama (si aplica)

- **`{{otra-skill}}`** — para {{qué}}, en el paso {{N}}

## Edge cases

- {{Si X falta → qué}}
- {{Si Y falla → fallback a Z}}

## Examples

Ver `references/examples.md` para casos completos.
```

## Reglas no-negociables

1. **YAML frontmatter al principio**, sin línea en blanco antes de `---`.
2. **Description en una sola línea** dentro del YAML (no multi-línea con `>`).
3. **Steps numerados y verbos en imperativo** ("Crear...", "Validar...", no "Crearás...").
4. **Sin código pesado en SKILL.md** — los snippets largos van a `references/` o `scripts/`.
5. **Idioma castellano** en SKILL.md, **inglés en code/JSON/commits**.
6. **Sin info privada** del operador — los ejemplos usan placeholders genéricos ("Empresa Demo SL", "cliente@ejemplo.com").

## Antipatrones que NO debes repetir

| Antipatrón | Por qué es malo | Cómo arreglarlo |
|---|---|---|
| Description vaga ("Crea contenido") | No se activa correctamente, canibalismo entre skills | Verbo + qué + cuándo: "Crea posts de LinkedIn de 200 chars con hook + CTA usando brand voice" |
| Todo el conocimiento en SKILL.md | Bloat de contexto cuando se carga | Mover knowledge a `references/<topic>.md` y referenciarlos desde steps |
| Sin examples | Claude alucina casos | Mínimo 2 ejemplos completos en `references/examples.md` |
| Pasos sin verificación | Rompe en silencio | Cada paso con criterio "cómo sé que salió bien" |
| Skill que hace 5 cosas distintas | Ambigua, difícil de mantener | Trocear en 5 skills + 1 orquestadora si necesario |
| Sin learnings hook | Skills no aprenden | Append a `context/learnings.md` al cierre |

## Token budget recomendado

- SKILL.md: 800-2500 tokens (~3000-10000 chars)
- references/ por archivo: 300-1500 tokens
- Si superas 2500 tokens en SKILL.md, mueve secciones a references/.
