# Frontmatter avanzado y patrones técnicos

Referencia técnica para skills de iAmasters OS. Se carga solo cuando el SKILL.md la necesita (progressive disclosure). El SKILL.md manda; esto es el detalle.

## Campos de frontmatter

| Campo | Cuándo ponerlo | Efecto |
|---|---|---|
| `name` | Siempre | kebab-case con prefijo de categoría; debe coincidir con el nombre de la carpeta. |
| `description` | Siempre | 50-500 chars, con verbos de intención del usuario. Es lo ÚNICO que Claude lee para decidir si carga la skill. |
| `disable-model-invocation: true` | Si tiene side-effects (genera archivos, llama APIs, envía mensajes, cuesta dinero) | Quita la auto-invocación por Claude. Solo se dispara con `/slash-command` explícito. |
| `argument-hint` | Si acepta argumentos vía `/name` | Texto que se ve en el autocompletado del menú `/`. Ej: `[topic o path]`. |
| `context: fork` | Si es autocontenida y NO necesita el historial de la conversación | Ejecuta la skill en un contexto aislado; el output verboso no ensucia la conversación principal. Suele ir con `agent`. |
| `agent` | Junto a `context: fork` | Define el subagente que ejecuta la skill forkeada. |
| `model` | Solo si requiere una capacidad de modelo concreta | Fuerza un modelo específico para esa skill. No lo pongas "por si acaso": encarece y resta portabilidad. |
| `allowed-tools` | Si la skill NO debe tener acceso a todas las tools | Restringe la superficie de tools (p. ej. solo `Read`, `Grep`). Reduce riesgo en skills sensibles. |

**Regla de oro**: pon solo los campos que necesitas. Cada campo de más es ruido que confunde al mantenedor y a Claude.

## Matriz de invocación

| Quiero que… | Config |
|---|---|
| Se dispare por lenguaje natural Y por `/comando` | Solo `name` + `description` (defecto). |
| Solo `/comando` (nunca auto) | `disable-model-invocation: true`. |
| Corra aislada sin contaminar el chat | `context: fork` + `agent`. |
| Reciba un argumento del usuario | `argument-hint` + usar `$ARGUMENTS`/`$N` en el cuerpo. |
| Tenga acceso limitado a tools | `allowed-tools: [Read, Grep, ...]`. |

## Sustituciones dinámicas

- `$ARGUMENTS` — todo lo que el usuario pasa tras `/skill-name`. Ej: `/resumen-pdf informe.pdf` → `$ARGUMENTS` = `informe.pdf`.
- `$1`, `$2`, … — argumentos posicionales individuales.
- `` !`comando` `` — **inyección de contexto dinámico**: el comando se ejecuta ANTES de cargar la skill y su stdout se inserta en el prompt. Útil para inyectar estado en vivo (fecha, rama git, contenido de un archivo). Ej: `` Rama actual: !`git branch --show-current` ``.

Cuidado con `` !`comando` ``: se ejecuta cada vez que se carga la skill. No lo uses para comandos lentos o con side-effects.

## Subagentes y delegación

Cuando un paso deba correr en un subagente (para no ensuciar el contexto o para paralelizar):

- Incluye el **prompt exacto** que se envía al subagente, no una descripción vaga.
- Especifica qué devuelve (texto, JSON con schema, archivo en path conocido).
- Para fan-out de varias tareas independientes, considera el patrón `Workflow`/`Agent` del OS (ver skill `conclave` para el gate adversarial en código).

## Secrets y seguridad

- Nunca hardcodees claves/tokens en el SKILL.md ni en scripts. Léelos de `.env.local` (nunca commiteado).
- Si la skill toca un VPS/servidor de producción, pide permiso nombrando host + acción explícitos antes de ejecutar.
- Si genera entregable a cliente/usuario, pásalo por `tool-output-verifier` (y `tool-humanizer` si es copy) antes de entregar.

## Troubleshooting

| Síntoma | Causa probable | Fix |
|---|---|---|
| Claude no carga la skill por lenguaje natural | `description` sin las keywords que usó el usuario | Añade esas keywords/verbos de intención a `description`. |
| Se dispara cuando no toca | `description` demasiado amplia o canibaliza a otra skill | Acota la `description`; revisa el test de unicidad contra el catálogo. |
| El `/comando` no autocompleta argumentos | Falta `argument-hint` | Añádelo. |
| `$ARGUMENTS` no sustituye | El cuerpo no usa la sintaxis exacta | Verifica `$ARGUMENTS`/`$N` literal. |
| La skill infla el contexto en cada sesión | SKILL.md demasiado largo | Mueve knowledge a `references/`; deja el SKILL.md < 500 líneas. |
| La descripción no aparece cargada (muchas skills) | Presupuesto de caracteres de descripciones excedido | Reduce skills activas (swap); recomendación Anthropic < 50 cargadas. |
