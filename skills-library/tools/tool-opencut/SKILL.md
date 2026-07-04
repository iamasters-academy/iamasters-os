---
name: tool-opencut
description: Edita vídeo de forma programática (recorte, concatenación, subtítulos, normalización de formato, batch) usando el modo headless/API de OpenCut, sin GUI. Úsala cuando el operador diga "recorta/une estos clips", "añade subtítulos a este vídeo", "normaliza estos vídeos a 9:16", "procesa este lote de vídeos" o necesite editar vídeo por script en vez de a mano.
---

# tool-opencut

> **Adaptación iAmasters OS** — Wrapper de `OpenCut-app/OpenCut` (MIT). No vendoriza su código:
> documenta el setup y orquesta su **API headless / modo scripting** (rewrite TypeScript). Puente al OS:
> es **edición** (post), distinta de la generación ([[tool-video-generator]]) y del montaje agéntico
> ([[tool-video-montage]]). Salida hacia [[marketing-content-repurposing]] / [[marketing-social]].

## Cuándo se invoca
- El operador dice "recorta/une estos clips", "añade subtítulos", "normaliza a 9:16", "procesa este lote de vídeos".
- Tras generar/grabar clips que hay que ensamblar o adaptar por plataforma.
- Automatización de edición repetitiva (batch) sin abrir un editor.

## Setup (una vez, runtime — no se versiona en el repo)
- **Clonar** fuera del OS: `git clone https://github.com/OpenCut-app/OpenCut`.
- **Entorno**: Node.js + Bun (monorepo con Moon/Proto). Usar el **modo headless / Editor API** (no la GUI).
- **FFmpeg** disponible (render). Sin APIs externas.
- **Validación**: el modo headless arranca y ejecuta una operación de prueba (p. ej. recorte) sin GUI.

## Process

### Paso 1 · Definir la operación de edición
- Recoge: inputs (clips), operación (recorte/concatenación/subtítulos/normalización), parámetros (aspecto, resolución, tiempos), formato de salida.
- **Validación**: inputs existen; operación + params completos.

### Paso 2 · Ejecutar (headless / API)
- Lanza la operación por la Editor API o script headless. Para lotes, itera sobre la lista de inputs.
- **Validación**: render sin error; nº de outputs = nº esperado.

### Paso 3 · Revisar y entregar
- Revisa un output: cortes limpios, sync de subtítulos, aspecto correcto. Si falla → ajusta params y repite.
- Copia a `projects/tool-opencut/<YYYY-MM-DD>-<titulo>/`. Append en `context/learnings.md` bajo `## tool-opencut`.

## Outputs
- `projects/tool-opencut/<YYYY-MM-DD>-<titulo>/` con el/los vídeo(s) editado(s).

## Skills que llama
- **`tool-video-generator`** / **`tool-video-montage`** — origen de clips generados a editar.
- **`marketing-content-repurposing`** / **`marketing-social`** — adaptación por plataforma y distribución.

## Edge cases
- Node/Bun o FFmpeg no instalados → resuelve setup antes.
- Necesitas GENERAR vídeo (no editar) → usa [[tool-video-generator]].
- Proyecto en rewrite: si la Editor API/headless aún no cubre una operación, documenta la limitación y hazla puntualmente en la GUI.
- Fútbol/análisis táctico → dominio FVI.

## Examples

Ver `references/examples.md` para casos completos.
