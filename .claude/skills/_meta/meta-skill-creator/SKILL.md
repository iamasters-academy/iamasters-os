---
name: meta-skill-creator
description: Crea skills nuevas para iAmasters OS siguiendo el patrón canónico. Úsalo cuando el usuario pida "crea una skill que...", "necesito una skill para...", o cuando detectes en wrap-up que un patrón repetido debe convertirse en skill. Genera SKILL.md con YAML frontmatter, references/ con knowledge separado, scripts/ si requiere ejecución, y registra la skill en el catálogo. Inspirado en anthropic-skills:skill-creator pero adaptado al patrón iAmasters OS.
---

# meta-skill-creator

## Cuándo se invoca

- Usuario dice: "crea una skill", "necesito una skill para X", "haz una skill que..."
- Wrap-up detecta un patrón que se ha repetido 3+ sesiones y propone graduar a skill
- Otro skill detecta un sub-proceso reutilizable y sugiere extraerlo

## Contrato de calidad

Una skill iAmasters OS BIEN hecha cumple SIEMPRE:

1. **YAML frontmatter completo y específico** — `name` (kebab-case con prefijo de categoría), `description` que contiene cuándo se invoca y qué hace en una frase ≥50 chars
2. **Progressive disclosure** — el SKILL.md NO contiene todo el conocimiento; references/ guarda lo extenso
3. **Steps numerados y testables** — cada paso debe ser verificable
4. **Skill collaboration explícita** — si invoca otras skills, las nombra y explica cuándo
5. **Output verifier gate** si genera contenido entregable al usuario/cliente
6. **Learnings hook** — al final del proceso, registra lo aprendido en `context/learnings.md`
7. **Idioma**: SKILL.md en castellano, code/JSON en inglés
8. **Referencias externas** — si la skill se basa en repo/URL/fuente externa, incluir sección `## Referencias` al final con enlace y licencia

## Process — pasos para crear una skill

### Paso 1 · Recopilar requisitos

Pregunta al usuario (usa AskUserQuestion si Claude Code está disponible):

1. **Nombre y categoría**: ¿en qué categoría va? (`marketing`, `operations`, `strategy`, `tools`, `visualization`, `_meta`). Genera nombre kebab-case con prefijo: `marketing-blog-writer`, `tool-pdf-extractor`, `_meta/meta-X`.
2. **Cuándo se invoca**: 1-2 frases. ¿Qué dirá el usuario para activarla? ¿Hay otra skill que la llame?
3. **Qué hace exactamente**: 3-5 puntos del proceso paso a paso.
4. **Inputs**: ¿qué necesita? Argumentos, archivos, MCPs, brand-context, otras skills.
5. **Outputs**: ¿qué produce? Archivo en `projects/<skill>/<fecha>-<titulo>/`, edit en archivos existentes, mensaje al usuario.
6. **Skills que llama**: ¿se apoya en otras? (`tool-humanizer`, `tool-output-verifier`, etc.)
7. **¿Necesita scripts?**: ¿Python o bash para tareas pesadas? Si sí, ¿qué hace cada script?
8. **¿Fuente externa?**: ¿Se basa en repo, URL, o fuente externa? Si sí, ¿cuál? (para incluir en sección `## Referencias`)

### Paso 2 · Validar el nombre y descripción

La descripción debe pasar 3 tests:

- **Test de activación**: ¿un Claude Code que solo lee la descripción sabría cuándo usarla? Debe contener verbos de intención del usuario ("crea", "analiza", "extrae", "genera").
- **Test de longitud**: 50–500 chars. Si menos, es ambigua. Si más, está inflando.
- **Test de unicidad**: lee `synapsis/skills-catalog.json`. Si hay otra skill con descripción parecida, riesgo de canibalización (Claude no sabrá cuál elegir). Diferéncialas o fusiónalas.

Si falla algún test, refina con el usuario antes de continuar.

### Paso 3 · Generar la estructura de carpetas

```
.claude/skills/<categoria>/<nombre>/
├── SKILL.md                    # Proceso principal (este patrón)
├── references/                 # Knowledge separado
│   ├── examples.md             # 2-3 ejemplos de uso real
│   ├── checklist.md            # (opcional) Validaciones
│   └── (otros docs según skill)
└── scripts/                    # (opcional) Si requiere ejecutables
    └── <nombre>.py             # o .sh
```

NO crees `references/` ni `scripts/` si la skill no los necesita. Mantén lo mínimo.

### Paso 4 · Escribir el SKILL.md siguiendo plantilla

Lee `references/skill-template.md` (incluido en esta skill) y úsalo de base. Estructura obligatoria:

```markdown
---
name: <prefijo-categoria>-<nombre>
description: <cuando se invoca + que hace, 50-500 chars>
---

# <nombre humano de la skill>

## Cuándo se invoca
- (3-5 bullets de patrones de invocación del usuario o de otras skills)

## Process
### Paso 1 · <verbo>
(qué hacer, herramientas a usar, archivos a tocar)

### Paso 2 · <verbo>
...

### Paso N · Cierre y aprendizaje
- Si generaste output: invoca `tool-output-verifier` antes de entregar
- Append en `context/learnings.md` bajo `## <skill-name>` con la lección si la sesión enseñó algo
- Si la skill modifica algún archivo del repo, propón commit en wrap-up

## Outputs
- Archivos generados en `projects/<skill>/<YYYY-MM-DD>-<titulo>/`
- Lista exacta de qué genera (file_a.md, file_b.json, etc)

## Skills que llama
- (lista de skills invocadas con cuándo y por qué)

## Edge cases
- Qué hacer si X falla
- Qué hacer si el usuario no da Y

## Examples
Ver `references/examples.md` para 2-3 ejemplos completos.
```

### Paso 5 · Generar references/

**`references/examples.md`** (siempre): 2-3 ejemplos completos de invocación + output esperado. Sin estos ejemplos la skill no sabe distinguir bien casos.

**`references/checklist.md`** (si hay validación QA): pasos de checklist para validar el output antes de cerrar.

**`references/<otros>.md`** (si hay knowledge extenso): templates, marcos, listas. Solo se cargan cuando el SKILL.md los referencia desde un paso concreto.

### Paso 6 · Generar scripts/ si aplica

Solo si la skill tiene tareas que NO debería resolver Claude (web scraping pesado, OCR, transcripción, formato batch, etc.).

Cada script:
- Documentación en cabecera (qué hace, args, ejemplo de uso)
- `set -e` para bash, `try/except` para python
- Outputs predecibles (stdout JSON o archivo en path conocido)
- Sin secrets hardcoded (lee de `.env`)

### Paso 7 · Registrar la skill

1. Añade entrada en `synapsis/skills-catalog.json` (estructura: `{id, name, category, description, status:"active", tokens_estimate, created}`).
2. Mide `tokens_estimate` aproximadamente: `chars(SKILL.md) / 4`.
3. Si la skill colabora con otras, añade en `references` de las otras la mención cruzada.
4. Append en `CLAUDE.md` raíz, sección "Skills registry", entrada nueva.

### Paso 8 · Test mínimo

Antes de declarar la skill terminada:

1. Cierra Claude Code (Ctrl+C × 2) y vuelve a abrir.
2. Pregunta algo que debería activar la skill ("crea X" según invocation patterns).
3. Verifica que Claude la elige y la sigue paso a paso sin saltarse fases.
4. Si no se activa: refina la descripción (Paso 2).
5. Si se activa pero hace cosas mal: refina los pasos del proceso.

### Paso 9 · Cierre y aprendizaje

- Append en `context/learnings.md` bajo `## meta-skill-creator`:
  - Fecha + resumen 1-line: "creada skill X — próxima vez recordar que Y"
- Si esta es la 3ª+ vez que creas una skill similar, propón al usuario crear una **meta-skill** o **template** para acelerar (graduar el patrón).

## Outputs

- Carpeta `.claude/skills/<categoria>/<nombre>/` con SKILL.md + references/ (+ scripts/ opcional)
- Entrada en `synapsis/skills-catalog.json`
- Entrada en `CLAUDE.md` raíz (skills registry)
- Append en `context/learnings.md`

## Skills que llama

- **`tool-output-verifier`** — al validar el SKILL.md generado antes de declararlo final (chequea formato YAML, longitud descripción, presencia de Process, etc.)

## Edge cases

- **Si el usuario describe una skill demasiado genérica** ("una skill que escriba bien"): pide concreción. ¿Para qué plataforma? ¿Qué tono? ¿Output dónde?
- **Si ya existe una skill parecida**: muestra ambas descripciones, ofrece (a) ampliar la existente, (b) diferenciar la nueva, (c) cancelar.
- **Si la skill propuesta es demasiado pequeña** (1 paso): puede que sea mejor un slash command. Sugiere comando en `.claude/commands/<nombre>.md`.
- **Si no hay categoría obvia**: propón crear nueva categoría solo si va a tener 3+ skills. Si es solo 1, encájala donde mejor calce.

## Examples

Ver `references/examples.md` para 3 ejemplos:
1. Crear `marketing-blog-writer` (skill compleja con references)
2. Crear `tool-pdf-summarizer` (skill que usa script Python)
3. Crear `_meta/meta-changelog-bumper` (skill simple sin references)

## Plantilla canónica

Ver `references/skill-template.md` para copiar-pegar el esqueleto base.
