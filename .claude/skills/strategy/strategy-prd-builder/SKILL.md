---
name: strategy-prd-builder
description: Crea PRDs (Documentos de Requisitos de Producto) para productos de cualquier categoría — app de software, SaaS, no-code/automatización, o producto de marca/contenido. Usar cuando el usuario quiere arrancar un proyecto nuevo, "hazme un PRD", "documento de requisitos", "especificación de producto", "definir el producto antes de construir", o necesita pasar de una idea a un plan ejecutable. Genera SIEMPRE dos archivos .md revisables en bloc de notas: PRD.md (documento de decisión — problema, usuarios, requisitos, métricas) y, aparte, PASO-A-PASO.md (playbook de construcción con prompts numerados estilo "paso a paso" listos para pegar en Claude Code). El paso a paso NUNCA va embebido en el PRD. HTML opcional.
version: 1.0.0
category: strategy
---

# Strategy PRD Builder

Convierte una idea de producto en **dos archivos `.md` que se revisan en bloc de notas**:

1. **`PRD.md`** — documento de decisión (problema, usuarios, requisitos, métricas, alcance). El *qué* y el *porqué*.
2. **`PASO-A-PASO.md`** — playbook de construcción con prompts numerados listos para ejecutar. El *cómo*. **Regla fija: siempre archivo aparte, NUNCA embebido en el PRD.**

El paso a paso está anclado al formato del documento `PASO A PASO Windows.md` de ARC-Whisper: claro, ordenado, replicable.

## Cuándo usar esta skill

- El usuario arranca un proyecto nuevo y dice "hazme un PRD", "documento de requisitos", "especificación"
- Quiere definir un producto **antes** de construirlo
- Necesita pasar de una idea difusa a un plan ejecutable por Claude Code
- Quiere un documento que cualquiera pueda leer en un bloc de notas y entender qué se construye y por qué

## Qué la hace distinta

| Skill | Cuándo |
|---|---|
| `strategy-prd-builder` | Definir un **producto** y dejar el plan listo para construir |
| `strategy-deep-research` | Investigar a fondo un tema con fuentes citadas |
| `arnes` (opcional) | Scaffolding de archivos del proyecto software ya decidido |
| `seis-sombreros` | Decisión estratégica con perspectivas múltiples |

Un PRD **no** es un playbook de construcción puro ni una investigación. Es el puente: el `PRD.md` decide qué construir y el `PASO-A-PASO.md` (archivo aparte) deja los prompts para construirlo.

## Categorías de producto soportadas

La skill adapta el PRD según la categoría. Si el usuario no la dice, **pregúntala** (una sola pregunta):

1. **App de software** — app instalable o web (ej. ARC-Whisper, historias-clínicas). Énfasis en arquitectura, stack, estructura de archivos, prompts de build.
2. **SaaS** — producto multi-usuario con cuentas, planes, deploy. Añade modelo de datos, auth, pricing/planes, métricas de retención.
3. **No-code / automatización** — Forms + Excel, n8n, Zapier (ej. qr-demanda-no-atendida). El "playbook" son pasos de configuración, no prompts de código.
4. **Marca / contenido** — pipeline de contenido, producto informativo (ej. pipeline-video-sin-cara). El "playbook" son pasos de producción/distribución.

El esqueleto del PRD es el mismo; cambian el énfasis y el contenido del `PASO-A-PASO.md`.

## Proceso

### 1. Recolectar lo mínimo (entrevista corta)

No interrogues. Pregunta solo lo que falte para llenar el PRD. Prioriza:

- **Qué es** el producto en una frase
- **Para quién** (usuario/ICP) y **qué dolor** resuelve
- **Categoría** (de la lista de arriba)
- **Stack/herramientas** previstas (si las hay)
- **Qué NO hace** (alcance) — pregunta clave que casi nadie da gratis
- **Cómo se mide el éxito**

Si el usuario ya dio un documento de referencia (como `PASO A PASO Windows.md`), extráelo de ahí en vez de preguntar.

### 2. Aplicar buenas prácticas

Lee `references/prd-best-practices.md` y aplícalo. Reglas no negociables:

- **Problema antes que solución.** La parte 1 abre con el problema, no con la feature.
- **El "qué" y el "porqué", no el "cómo"** en la parte de requisitos. El "cómo" vive en el playbook (parte 2).
- **Métricas medibles.** Nada de "mejorar la experiencia". Sí "el 80% de los dictados se insertan sin editar".
- **Alcance explícito.** Siempre una sección "Lo que NO hacemos".
- **User stories** en formato `Como [usuario], quiero [acción] para [beneficio]`.
- **Requisitos funcionales vs no funcionales** separados.
- **Documento vivo, conciso.** Si una sección no aplica a la categoría, omítela en vez de rellenarla con paja. Respeta `[[feedback_no_inventar_en_perfiles]]`: campo sin dato → se deja explícito como "Pendiente", no se inventa.

### 3. Generar dos archivos separados (regla fija)

Genera **siempre dos `.md`**, nunca uno solo:

**a) `PRD.md`** — el documento de decisión. Usa `templates/prd-template.md`. Contiene las secciones de decisión (objetivo, usuarios, métricas, supuestos, user stories, requisitos funcionales/no funcionales, alcance, riesgos, preguntas abiertas) + un **puntero** al paso a paso.

**b) `PASO-A-PASO.md`** — el playbook de construcción, **archivo aparte**. Regla no negociable: el paso a paso **nunca** se embebe dentro del PRD; vive como `.md` independiente para abrirlo solo en un bloc de notas mientras se construye. Usa `templates/paso-a-paso-template.md` e imita el estilo de `PASO A PASO Windows.md`:

- Prompts **numerados** ("Prompt 1 — …") en bloques de código, listos para copiar/pegar
- Cada prompt autocontenido: que Claude Code pueda ejecutarlo sin contexto extra
- Sección "Lo que hace el usuario (no Claude Code)" para pasos manuales (pegar API keys, permisos, etc.)
- Estructura de archivos esperada cuando sea app de software

### 4. Guardar el output

Los **dos** archivos van juntos en la carpeta del proyecto:

- `projects/briefs/<nombre>/PRD.md`
- `projects/briefs/<nombre>/PASO-A-PASO.md`

(o, si es single-task, ambos bajo `projects/strategy-prd-builder/<YYYY-MM-DD>-<titulo>/`).

- Ambos `.md` son la fuente de verdad — se revisan en bloc de notas sin renderizar.
- El `PRD.md` enlaza al `PASO-A-PASO.md` y viceversa, para no perder la conexión.
- **HTML opcional**: si el usuario lo pide, invoca `tool-visual-explainer` para una versión presentable.

## Output

Tras generar, confirma:
- Rutas de **ambos** archivos: `PRD.md` y `PASO-A-PASO.md`
- Categoría detectada
- Secciones incluidas / omitidas (y por qué)
- Siguiente paso sugerido (ej. "`/install-skill arnes` para scaffolding" o "ejecuta el Prompt 1")

## Referencias

- `references/prd-best-practices.md` — buenas prácticas destiladas de fuentes reales (Atlassian, Maze, Lenny's, Figma). Léelo antes de escribir.
- `templates/prd-template.md` — esqueleto del PRD (documento de decisión).
- `templates/paso-a-paso-template.md` — esqueleto del paso a paso (playbook, archivo aparte).
- Ejemplo canónico de la parte 2 (playbook): `projects/arc-whisper/PASO A PASO Windows.md`.
