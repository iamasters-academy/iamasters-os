---
name: tool-voicebox
description: Genera voz en off, clona voces y transcribe/dicta en local (sin API keys) usando Voicebox — TTS multi-motor (23 idiomas), clonación de voz y dictado Whisper. Úsala cuando el operador diga "hazme la voz en off de este guion", "clona esta voz", "genera audio de este texto", "dicta/transcribe esto en local" o necesite narración para un vídeo sin depender de ElevenLabs.
---

# tool-voicebox

> **Adaptación iAmasters OS** — Wrapper de `jamiepine/voicebox` (MIT, autor Jamie Pine). No vendoriza su
> código: documenta el setup y orquesta su backend. **Local-first, sin API keys** (alternativa a
> ElevenLabs/Whispr). Puente al OS: la voz que produce alimenta [[tool-video-generator]] /
> [[tool-video-montage]] (montaje) y encaja con guiones de [[marketing-video]]. Para transcribir una URL
> de red social usa [[tool-transcribe-social]]; Voicebox es para dictado/STT local y TTS.

## Cuándo se invoca
- El operador dice "hazme la voz en off de este guion", "genera audio de este texto", "clona esta voz", "dicta/transcribe esto en local".
- Como paso de voz dentro de una producción de vídeo (tras el guion, antes del montaje).
- Cuando quiere evitar costes/keys de TTS en la nube.

## Setup (una vez, runtime — no se versiona en el repo)
- **Clonar** fuera del OS: `git clone https://github.com/jamiepine/voicebox`.
- **Entorno**: seguir su README. Backend FastAPI/CLI. GPU opcional (CUDA / ROCm / Apple Metal-MLX / Intel Arc / DirectML); funciona en CPU.
- **Sin API keys** — todo local.
- **Validación**: el backend arranca y lista los motores TTS disponibles.

## Process

### Paso 1 · Definir la petición de audio
- Recoge: modo (TTS / clonación / dictado-STT), texto o guion, idioma/voz, y muestra de voz si es clonación.
- Si el guion viene de [[marketing-video]], reúsalo.
- **Validación**: modo + input completos; voz/idioma elegidos existen en la instancia.

### Paso 2 · Generar
- Lanza el motor por CLI/API. TTS → wav/mp3; clonación → voz a partir de la muestra; dictado → transcripción.
- **Validación**: fichero de audio (o transcripción) generado y reproducible/legible.

### Paso 3 · Revisar y entregar
- Escucha una muestra: pronunciación, ritmo, artefactos. Si falla → ajusta voz/velocidad/texto y repite.
- Copia el audio a `projects/tool-voicebox/<YYYY-MM-DD>-<titulo>/`.
- Append en `context/learnings.md` bajo `## tool-voicebox` si aprendiste algo (qué voz rinde para qué).

## Outputs
- `projects/tool-voicebox/<YYYY-MM-DD>-<titulo>/audio.(wav|mp3)` (o `transcripcion.txt`).

## Skills que llama
- **`marketing-video`** — guion de partida para la voz en off.
- **`tool-video-generator`** / **`tool-video-montage`** — consumen la voz en el montaje.

## Edge cases
- Sin GPU → funciona en CPU pero más lento; avisa del tiempo en textos largos.
- Clonación de voz de terceros → recuerda consentimiento/derechos antes de usarla comercialmente.
- Idioma/voz no disponible en la instancia → lista las que hay y propón la más cercana.
- Transcribir una URL de Reel/TikTok → usa [[tool-transcribe-social]], no esta.

## Examples

Ver `references/examples.md` para casos completos.
