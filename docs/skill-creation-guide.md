# Guía para crear skills en iAmasters OS

Esta guía explica cómo crear una skill nueva sin romper el patrón del OS. Está pensada para usuarios no técnicos: copia la estructura, cambia lo mínimo y valida antes de usarla.

## Estructura canónica

Una skill instalada vive siempre a **un solo nivel**:

```bash
.claude/skills/<nombre>/SKILL.md
```

⚠️ **Sin carpeta de categoría.** Claude Code solo indexa un nivel bajo `skills/`. Si metes una
carpeta intermedia (`.claude/skills/marketing/marketing-icp/SKILL.md`), la skill **no existe** para
el tool Skill: al invocarla responde `Unknown skill: marketing-icp`, aunque el archivo esté ahí y el
frontmatter sea correcto. No es un fallo que se arregle reiniciando: es el contrato de descubrimiento.

La categoría no se pierde, vive en dos sitios:

- **El prefijo del nombre** — `marketing-`, `tool-`, `strategy-`, `automation-`.
- **La biblioteca** — `skills-library/<categoria>/<nombre>/`, que es un catálogo y **no** se indexa.
  De ahí `bash scripts/skills.sh add <nombre>` la copia plana a `.claude/skills/<nombre>/`.

Puede añadir dos carpetas opcionales, y **estas sí** van dentro de la skill:

```bash
.claude/skills/<nombre>/references/
.claude/skills/<nombre>/scripts/
```

Las subcarpetas de una skill son sus recursos. Nunca son skills anidadas.

El nombre de invocación lo da el **nombre de la carpeta**, no el `name:` del frontmatter. Mantén los
dos iguales para no confundir a nadie. `bash scripts/ci/check-skills-depth.sh` valida ambas reglas.

Patrón real observado en `marketing-copywriting`:

```text
.claude/skills/marketing-copywriting/
├── SKILL.md
└── references/
    └── examples.md
```

Ese tipo de skill orquesta contexto, plantillas, otras skills y gates de calidad. Por ejemplo, carga `brand-context/voice/voice-profile.md`, elige un registro A/B/C y pasa el resultado por `tool-output-verifier`.

Patrón real observado en `tool-humanizer`:

```text
.claude/skills/tool-humanizer/
├── SKILL.md
└── references/
    ├── ai-tells.md
    └── examples.md
```

Ese tipo de skill es una herramienta primitiva: recibe input, aplica reglas internas y devuelve un resultado o JSON a otra skill. No necesita orquestar todo el OS.

Usa `scripts/` solo cuando la skill necesite ejecutar lógica repetible: parsear archivos, validar estructura, convertir formatos o llamar una API.

## Frontmatter

El `SKILL.md` empieza con YAML frontmatter. En este repo se usan sobre todo:

```yaml
---
name: resumen-reuniones
description: Resume reuniones, extrae decisiones y genera próximos pasos. Usar cuando el usuario diga "resume esta reunión", "saca acta", "meeting summary" o "action items".
---
```

Campos habituales:

- `name`: nombre estable de la skill. Usa kebab-case y no lo cambies después.
- `description`: qué hace y cuándo debe activarse. Incluye triggers en español y, si tiene sentido, 2-3 triggers en inglés.
- `metadata`: opcional. Algunas skills lo usan para versión u origen.
- `triggers` y `alwaysActive`: opcionales. Aparecen en algunas tools cuando conviene declarar activadores explícitos.

## Description que se autodispara bien

Una buena `description` no solo explica. También contiene frases parecidas a lo que dirá el usuario.

Mal:

```yaml
description: Ayuda con reuniones.
```

Mejor:

```yaml
description: Resume reuniones, convierte transcripciones en actas y extrae decisiones, responsables y próximos pasos. Usar cuando el usuario diga "resume esta reunión", "hazme el acta", "saca action items", "meeting summary" o "next steps".
```

Frases útiles:

- "Usar cuando el usuario pida..."
- "También usar si menciona..."
- "No usar para..."
- "Para X, usar otra skill..."

## Estructura recomendada del SKILL.md

```markdown
# resumen-reuniones

## Cuándo se invoca

- Usuario pega una transcripción y pide resumen
- Usuario pide acta, decisiones o próximos pasos

## Process

### Paso 1 · Validar inputs

Comprueba que existe transcripción, fecha y tipo de reunión.

### Paso 2 · Cargar contexto

Lee `context/work.md` y, si aplica, `clients/<cliente>/context/`.

### Paso 3 · Generar output

Entrega resumen, decisiones, riesgos y próximos pasos.

### Paso 4 · Verificar

Comprueba que cada acción tiene responsable o marca "sin responsable".

## Outputs

- `projects/resumen-reuniones/<fecha>-<slug>/acta.md`

## Edge cases

- Si falta transcripción, pedirla.
- Si hay varios clientes posibles, preguntar.
```

## Validación

El repo incluye validador para skills externas alojadas en GitHub:

```bash
bash scripts/validate-skill.sh https://github.com/<owner>/<repo>/tree/main/<ruta-a-la-skill>
```

Úsalo antes de instalar una skill externa con `/install-skill`. Comprueba estructura básica, `SKILL.md`, frontmatter y descripción suficiente.

Para una skill local nueva, haz la misma comprobación manual:

- Existe `SKILL.md` en la raíz de la skill.
- El archivo empieza con `---`.
- `name:` está en kebab-case.
- `description:` explica qué hace y cuándo debe activarse.
- Las referencias apuntan a archivos reales.

Para auditar cambios en varias skills:

```bash
bash scripts/skill-change-detector.sh
```

## Registro en CLAUDE.md

Cuando añadas una skill core, anótala en el registry de `CLAUDE.md`:

```markdown
### `marketing/` (7)

| Skill | Descripción |
|---|---|
| `resumen-reuniones` | Actas, decisiones y próximos pasos desde transcripciones |
```

Si es opcional, colócala en `_meta/_optional/` o en el catálogo de `docs/skills-recommended.md`, según corresponda. Ajusta el conteo solo si la skill entra en Capa 1.

## Ejemplo mínimo: resumen-reuniones

Crear carpeta:

```bash
mkdir -p .claude/skills/resumen-reuniones/references
```

Crear `.claude/skills/resumen-reuniones/SKILL.md`:

```markdown
---
name: resumen-reuniones
description: Resume reuniones, convierte transcripciones en actas y extrae decisiones, responsables y próximos pasos. Usar cuando el usuario diga "resume esta reunión", "hazme el acta", "saca action items", "meeting summary" o "next steps".
---

# resumen-reuniones

## Cuándo se invoca

- El usuario pega una transcripción de reunión.
- El usuario pide un acta, resumen ejecutivo o lista de acciones.

## Process

### Paso 1 · Validar input

Confirmar que hay transcripción y fecha. Si falta cliente o proyecto, preguntar.

### Paso 2 · Extraer estructura

Separar:
- Temas tratados
- Decisiones
- Próximos pasos
- Riesgos o bloqueos

### Paso 3 · Generar acta

Usar formato claro:
- Resumen ejecutivo
- Decisiones
- Próximas acciones con responsable y fecha
- Dudas abiertas

### Paso 4 · Guardar

Guardar en `projects/resumen-reuniones/<fecha>-<slug>/acta.md`.

## Edge cases

- Si una acción no tiene responsable, marcar `Responsable: pendiente`.
- Si la transcripción es confusa, listar dudas antes de inventar.
```

Validar manualmente la estructura local. Si publicas esa skill en GitHub, entonces usa `scripts/validate-skill.sh` contra la URL pública antes de instalarla en otro OS.

Registrar en `CLAUDE.md` solo cuando la skill pase revisión y vaya a formar parte del catálogo core.
