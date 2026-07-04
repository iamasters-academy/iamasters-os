---
name: tool-video-montage
description: Produce un vídeo completo eligiendo una pipeline de producción (explainer animado, documental con footage de archivo libre, o trailer cinematográfico) — investigación, guion, assets, voz y ensamblado FFmpeg/Remotion — usando OpenMontage. Úsala cuando el operador diga "monta un vídeo tipo documental/explainer", "produce un vídeo con footage de archivo" o "pipeline de vídeo completo". Alternativa "pro" y más pesada a [[tool-video-generator]].
---

# tool-video-montage

> **Adaptación iAmasters OS** — Wrapper de `calesthio/OpenMontage`. **Licencia AGPLv3 (copyleft)**: esta
> skill **no copia su código al repo** — orquesta una herramienta externa que el operador despliega
> aparte, así que el copyleft recae sobre OpenMontage, no sobre iAmasters OS. Si algún día se vendoriza
> su código, reevaluar la licencia. Es **pesada** (FFmpeg + Remotion + varias pipelines). Puente al OS:
> guion desde [[marketing-video]]; salida hacia [[marketing-content-repurposing]] / [[marketing-social]].

## Cuándo se invoca
- El operador dice "monta un vídeo tipo documental/explainer", "produce un vídeo con footage de archivo", "pipeline de vídeo completo", "vídeo con narración y research".
- Cuando [[tool-video-generator]] se queda corto (necesita research, composición animada Remotion o assets de archivo).
- Producción de una pieza larga/cuidada, no un short rápido.

## Setup (una vez, runtime — no se versiona en el repo)
- **Clonar** fuera del OS: `git clone https://github.com/calesthio/OpenMontage` (AGPLv3 — lee la licencia).
- **Deps**: Python (orquestación), **FFmpeg** (obligatorio), Node/Remotion (composición React), opcional WhisperX (transcripción), Real-ESRGAN (upscale), Piper TTS (voz local gratis).
- **APIs opcionales** (en `.env`, NUNCA commitear): generadores de vídeo/imagen (FLUX, Veo, Runway…), voz (ElevenLabs, Suno). Archivos libres SIN key: Archive.org, NASA, Wikimedia, Pexels, Unsplash.
- **Validación**: `ffmpeg -version` OK + Remotion instalado + al menos la ruta gratis (Piper + archivos libres) operativa.

## Process

### Paso 1 · Elegir pipeline + brief
- Pregunta el objetivo y elige pipeline: **explainer** (animado), **documental** (footage de archivo libre), **trailer** (cinematográfico). Recoge tema/guion, duración, idioma, tono.
- Si el guion viene de [[marketing-video]], reúsalo.
- **Validación**: pipeline elegida + brief completo.

### Paso 2 · Ejecutar la producción
- Lanza la pipeline de OpenMontage con el brief: research → guion → generación/obtención de assets (según pipeline) → voz (Piper local o API) → ensamblado FFmpeg/Remotion.
- Prefiere la **ruta gratis** (Piper + archivos libres) salvo que el operador pida generadores de pago.
- **Validación**: la pipeline completa sin error; produce un render intermedio revisable.

### Paso 3 · Revisar, aprobar, entregar
- Revisa el render: coherencia narrativa, calidad de assets, sync voz/subtítulos, derechos del footage (los archivos libres exigen atribución en algunos casos → anótala).
- Copia el vídeo final a `projects/tool-video-montage/<YYYY-MM-DD>-<tema>/`.
- Si es entregable → [[tool-output-verifier]] sobre guion/caption. Append en `context/learnings.md` bajo `## tool-video-montage`.

## Outputs
- `projects/tool-video-montage/<YYYY-MM-DD>-<tema>/video.(mp4|webm)` (pieza terminada).
- Guion + notas de atribución de footage + caption.

## Skills que llama
- **`marketing-video`** — guion/ángulo de partida.
- **`tool-output-verifier`** — gate de calidad si es entregable.
- **`marketing-content-repurposing`** / **`marketing-social`** — distribución.

## Edge cases
- FFmpeg/Remotion no instalados → la producción falla; resuelve setup antes.
- Pieza corta y rápida sin research → usa [[tool-video-generator]] (más ligera).
- Footage de archivo con licencia que exige atribución → inclúyela; no la omitas.
- AGPLv3: si el operador quiere integrar/redistribuir el CÓDIGO de OpenMontage (no solo usarlo) → avísale del copyleft y para hasta decisión.
- Fútbol/análisis táctico → dominio FVI, no esta skill.

## Examples

Ver `references/examples.md` para casos completos.
