---
name: meta-skill-creator
description: Crea skills nuevas para iAmasters OS siguiendo el patrón canónico. Úsalo cuando el usuario pida "crea una skill que...", "necesito una skill para...", o cuando detectes en wrap-up que un patrón repetido debe convertirse en skill. Genera SKILL.md con YAML frontmatter, references/ con knowledge separado, scripts/ si requiere ejecución, y registra la skill en el catálogo. Inspirado en anthropic-skills:skill-creator pero adaptado al patrón iAmasters OS.
---

# meta-skill-creator

## Cuándo se invoca

- Usuario dice: "crea una skill", "necesito una skill para X", "haz una skill que..."
- Usuario dice: "audita esta skill", "revisa/optimiza esta skill", "¿está bien hecha esta skill?"
- Wrap-up detecta un patrón que se ha repetido 3+ sesiones y propone graduar a skill
- Otro skill detecta un sub-proceso reutilizable y sugiere extraerlo

## Dos modos

- **Modo Crear** (por defecto) → sigue el "Process" completo (Pasos 1-9).
- **Modo Auditar** → cuando el usuario pide revisar una skill ya existente, salta al "Modo Auditoría" del final. Lee SIEMPRE el SKILL.md antes de proponer cambios.

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

### Paso 1 · Discovery interview (por rondas)

Usa `AskUserQuestion` (una ronda cada vez, avanza solo cuando responda) hasta tener ~95% de confianza para construir sin más dudas. Si el usuario ya dio contexto suficiente en su primer mensaje, **salta las rondas ya respondidas** — no repreguntes lo que ya sabes.

**Ronda 1 · Objetivo y nombre** — *Por qué importa: un objetivo claro evita el scope creep; el nombre se vuelve el `/slash-command`.*
- ¿Qué hace la skill? ¿Qué problema resuelve o qué workflow automatiza?
- Categoría (`marketing`, `strategy`, `tools`, `automation`, `visualization`, `_meta`…) → propón nombre kebab-case con prefijo: `marketing-blog-writer`, `tool-pdf-extractor`, `_meta/meta-X`.

**Ronda 2 · Disparador (trigger)** — *Por qué importa: la `description` es cómo Claude decide cargarla; malos triggers = nunca se usa; demasiado amplios = se dispara cuando no toca.*
- 2-3 frases naturales que la activarían.
- ¿Solo usuario (`/slash-command`), auto-invocable por Claude, o ambos? → si tiene side-effects, marcar `disable-model-invocation: true`.
- ¿Acepta argumentos? ¿Cuáles? (topic, URL, path)

**Ronda 3 · Proceso paso a paso** — *Por qué importa: Claude sigue literalmente; pasos vagos = resultados vagos.*
- Recorrido exacto de trigger → output, paso a paso.
- Por paso: ¿lo hace Claude directo o delega en subagente/script?
- ¿Conversacional (ida y vuelta) o fire-and-forget?

**Ronda 4 · Inputs, outputs y dependencias** — *Por qué importa: sin especificar de dónde salen inputs y dónde van outputs, la skill es inconsistente.*
- Inputs: archivos, MCPs, `brand-context/`, `context/`, argumentos, datos en vivo.
- Outputs: archivo en `projects/<skill>/<fecha>-<titulo>/`, edición de archivos, mensaje al usuario.
- Dependencias: APIs, scripts, otras skills (`tool-humanizer`, `tool-output-verifier`…), templates/references.

**Ronda 5 · Guardrails y edge cases** — *Por qué importa: sin guardrails hay outputs erróneos, costes de API inesperados o acciones no deseadas.*
- ¿Qué puede salir mal? Fallos comunes.
- ¿Qué NO debe hacer? Límites duros.
- ¿Costes? (llamadas API, generación de imagen/vídeo).
- ¿Restricciones de orden/dependencia? ("comprobar X antes de Y").

**Ronda 6 · Confirmación** — *Por qué importa: malentendidos cazados aquí evitan reconstruir la skill.*
Resume tu comprensión (objetivo · trigger · argumentos · proceso · inputs · outputs · dependencias · guardrails) y pregunta "¿lo capta? ¿algo que cambiar?". Solo avanza al Paso 2 con confirmación.

**¿Fuente externa?** — si la skill se basa en repo/URL/fuente externa, anótalo para la sección `## Referencias`.

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

**Frontmatter — campos avanzados (pon SOLO los que necesites, no infles):**

- `name` — kebab-case con prefijo de categoría, coincide con la carpeta.
- `description` — cuándo se invoca + qué hace (50-500 chars), con verbos de intención del usuario.
- `disable-model-invocation: true` — **si la skill tiene side-effects** (genera archivos, llama APIs, envía mensajes, cuesta dinero). Evita que Claude la auto-dispare; queda solo como `/slash-command`.
- `argument-hint: [topic o path]` — si acepta argumentos vía `/name` (se ve en el autocompletado del menú `/`).
- `context: fork` (+ `agent`) — si la skill es autocontenida y NO necesita el historial de la conversación (output verboso, tarea aislada).
- `model` — solo si requiere una capacidad de modelo concreta.
- `allowed-tools` — si la skill NO debe tener acceso a todas las tools (restringe la superficie).

Dentro del cuerpo puedes usar `$ARGUMENTS` / `$N` para input dinámico de argumentos, y `` !`comando` `` para inyección de contexto dinámico (preprocesado).

Detalle completo (matriz de invocación, subagentes, troubleshooting): ver `references/frontmatter-avanzado.md`.

```markdown
---
name: <prefijo-categoria>-<nombre>
description: <cuando se invoca + que hace, 50-500 chars>
# disable-model-invocation: true   # si tiene side-effects
# argument-hint: [topic o path]    # si acepta argumentos
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

## Modo Auditoría — revisar/optimizar una skill existente

Cuando el usuario diga "audita esta skill", "revisa/optimiza esta skill" o "¿está bien hecha?": **lee SIEMPRE el SKILL.md primero**, nunca propongas cambios sobre una skill que no has leído. Recorre este checklist y corrige lo que falle antes de cerrar.

### Frontmatter
- [ ] `name` coincide con el nombre de la carpeta y lleva prefijo de categoría.
- [ ] `description` usa keywords naturales que el usuario diría de verdad; específica para no dispararse en falso pero amplia para cazar peticiones reales; 50-500 chars.
- [ ] `disable-model-invocation: true` si tiene side-effects (genera archivos, llama APIs, envía mensajes, cuesta dinero).
- [ ] `argument-hint` si acepta argumentos vía `/name`.
- [ ] `allowed-tools` si NO debe tener acceso a todas las tools.
- [ ] `context: fork` si es autocontenida y produce output verboso.
- [ ] Sin campos innecesarios (no añadir frontmatter porque sí).

### Contenido
- [ ] SKILL.md < 500 líneas (lo extenso vive en `references/`).
- [ ] Workflow numerado y testable; cada paso dice exactamente qué hacer (nada vago).
- [ ] Formato de output especificado con template/ejemplo.
- [ ] Todos los paths (inputs, outputs, scripts, references) documentados.
- [ ] Si delega en subagentes, incluye el prompt exacto a enviar.
- [ ] Sección de edge cases / qué NO hacer.
- [ ] Usa `$ARGUMENTS`/`$N` donde recibe input.

### Integración OS (específico iAmasters)
- [ ] Registrada en `synapsis/skills-catalog.json` (fuente de verdad) — el registry se regenera solo.
- [ ] Referenciada en `CLAUDE.md` si corresponde (routing/cadenas/desambiguación).
- [ ] Si genera entregable a cliente/usuario: pasa por `tool-output-verifier` (y `tool-humanizer` si es copy).
- [ ] `references/`/`scripts/` referenciados desde el SKILL.md, no huérfanos; secrets en `.env`, nunca hardcoded.
- [ ] No canibaliza a otra skill del catálogo (Paso 2, test de unicidad); no duplica lo que ya vive en `CLAUDE.md` u otra skill.

### Calidad
- [ ] Un principiante podría seguirla sin contexto previo; instrucciones accionables, no abstractas.
- [ ] Outputs en ruta predecible (`projects/<skill>/<YYYY-MM-DD>-<titulo>/`).
- [ ] Delega en subagentes cuando conviene para no ensuciar el contexto principal.

Al cerrar la auditoría, si tocaste el SKILL.md o el catálogo, propón commit en wrap-up y registra la lección en `context/learnings.md`.

## Plantilla canónica

Ver `references/skill-template.md` para copiar-pegar el esqueleto base.
