---
name: tool-avatar-video
description: Genera un vídeo de avatar hablando (audio-driven) a partir de una imagen + audio/texto reenviando el trabajo al Space de LongCat-Video-Avatar en HuggingFace. Úsala cuando el operador diga "hazme un avatar hablando", "vídeo de portavoz IA", "cara que narra este texto", "talking head desde esta foto" o quiera un presentador sintético para un explainer/producto.
---

# tool-avatar-video

> **Adaptación iAmasters OS** — Wrapper fino de `meituan-longcat/LongCat-Video-Avatar-1.5` (modelo MIT).
> **No self-host por defecto**: reenvía el trabajo al **Gradio Space** de HuggingFace
> `victor/LongCat-Video-Avatar-1.5` vía `gradio_client`. El self-host (13.6B, multi-GPU, PyTorch/CUDA)
> se documenta como opción "pesada". Puente al OS: el audio puede venir de [[tool-voicebox]]; la salida
> va a [[marketing-content-repurposing]] / [[marketing-social]]. Para short con stock (no avatar) usa
> [[tool-video-generator]].

## Cuándo se invoca
- El operador dice "hazme un avatar hablando", "vídeo de portavoz IA", "talking head desde esta foto", "cara que narra este texto".
- Explainer/demo de producto con presentador sintético (marketing, IA-PYMEs).

## Setup (una vez, runtime)
- **Python** + `pip install gradio_client`. Opcional: token de HuggingFace (`HF_TOKEN` en `.env`, NUNCA commitear) si el Space lo exige.
- **Inputs**: imagen del avatar (retrato) + audio (de [[tool-voicebox]]) o texto.
- **Validación**: `gradio_client` conecta con el Space y lista sus endpoints (`/predict` / api_name).

## Process

### Paso 1 · Preparar inputs
- Recoge retrato + audio/texto + parámetros (idioma, duración). Si hay que generar la voz primero, llama a [[tool-voicebox]].
- **Validación**: imagen y audio/texto listos; el Space está online.

### Paso 2 · Reenviar al Space y recoger
- Conecta con `gradio_client.Client("victor/LongCat-Video-Avatar-1.5")` y llama al endpoint con los inputs. **Inspecciona `client.view_api()`** — los nombres de endpoint/fn pueden cambiar.
- Descarga el vídeo resultante a `projects/tool-avatar-video/<YYYY-MM-DD>-<titulo>/`.
- **Validación**: mp4 descargado; lip-sync coherente con el audio.

### Paso 3 · Revisar y entregar
- Revisa lip-sync, naturalidad, artefactos. Si falla → ajusta retrato/audio y repite.
- Append en `context/learnings.md` bajo `## tool-avatar-video`.

## Outputs
- `projects/tool-avatar-video/<YYYY-MM-DD>-<titulo>/avatar.mp4`.

## Skills que llama
- **`tool-voicebox`** — generar la voz que dirige el avatar.
- **`marketing-content-repurposing`** / **`marketing-social`** — distribución.

## Edge cases
- **Space gated/caído / cola larga** → fallback: (a) reintentar más tarde, (b) endpoint de pago tipo Replicate, (c) self-host (multi-GPU, pesado). Documenta cuál se usó.
- Retrato de una persona real sin permiso → NO hacer deepfakes de terceros; solo avatares propios o con consentimiento.
- Quieres vídeo con footage/stock (no una cara hablando) → usa [[tool-video-generator]] / [[tool-video-montage]].

## Examples

Ver `references/examples.md` para casos completos.
