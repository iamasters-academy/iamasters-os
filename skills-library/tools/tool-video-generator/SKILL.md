---
name: tool-video-generator
description: Genera un vídeo corto vertical (Reels/Shorts/TikTok) end-to-end a partir de un tema o guion — guion LLM, footage de stock, narración TTS, subtítulos y ensamblado FFmpeg — usando MoneyPrinterTurbo. Úsala cuando el operador diga "hazme un vídeo corto de X", "genera un reel/short", "monta un vídeo con voz en off automática" o "vídeo AI para redes". NO para bajar una URL ([[video-downloader]]) ni para transcribir ([[tool-transcribe-social]]).
---

# tool-video-generator

> **Adaptación iAmasters OS** — Wrapper de `harry0703/MoneyPrinterTurbo` (MIT). No vendoriza su código:
> documenta el setup (Docker o Python) y orquesta su pipeline (API/CLI/WebUI). Puente al OS: el guion
> puede venir de [[marketing-video]] (ideas/guion) y el resultado alimenta [[marketing-content-repurposing]]
> → [[marketing-social]]. Es la pieza de **render** del clúster vídeo; `marketing-video` NO renderiza.

## Cuándo se invoca
- El operador dice "hazme un vídeo corto de X", "genera un reel/short", "vídeo AI para redes", "monta un vídeo con voz en off".
- Tras [[marketing-video]] (guion listo) cuando hay que producir el mp4 real.
- Cierre de un embudo de contenido que necesita clips verticales.

## Setup (una vez, runtime — no se versiona en el repo)
- **Clonar** fuera del OS: `git clone https://github.com/harry0703/MoneyPrinterTurbo`.
- **Opción A (recomendada)**: Docker → `docker compose -f docker-compose.release.yml up` (WebUI `:8501`, API `:8080`).
- **Opción B**: Python 3.11+ → `uv sync --frozen` (o `venv` + `pip install -r requirements.txt`). Requiere **FFmpeg** en PATH.
- **Keys en `config.toml`** (NUNCA commitear): 1 LLM (`[llm_provider]` provider+api_key: OpenAI/Gemini/DeepSeek/Ollama…), 1 fuente de stock (`[pexels] pexels_api_keys` o Pixabay — free tier basta), TTS por defecto **Edge-TTS (gratis)**; Azure/ElevenLabs opcionales.
- **Validación**: `ffmpeg -version` OK + WebUI/API arranca + `config.toml` con LLM y stock key → setup OK.

## Process

### Paso 1 · Definir brief del vídeo
- Recoge: tema/guion, idioma, duración objetivo, tono, aspecto (9:16 vertical por defecto), fuente de vídeo (stock vs `local`).
- Si el guion viene de [[marketing-video]], reúsalo (no re-generes). Si no, deja que el LLM lo genere desde el tema.
- **Validación**: brief completo (tema o guion + idioma + duración + fuente).

### Paso 2 · Configurar y lanzar el pipeline
- Rellena `config.toml` con provider LLM, stock key, voz TTS. Elige método:
  - **CLI**: `uv run python cli.py --video-subject "<tema>"` (+ `--video-source local --video-materials "a.mp4,b.mp4"` si material propio).
  - **API**: POST al servicio (`:8080/docs`) con el brief.
  - **WebUI**: `:8501` para ajuste manual fino.
- **Validación**: el pipeline arranca sin error de key/FFmpeg; genera guion → descarga stock → TTS → subtítulos.

### Paso 3 · Recoger, revisar y entregar
- Localiza el mp4 de salida (raíz del proyecto de la herramienta; revisa logs). Cópialo a `projects/tool-video-generator/<YYYY-MM-DD>-<tema>/`.
- **Revisión honesta**: comprueba sync voz/subtítulos, relevancia del stock, cortes bruscos. Si falla → reajusta guion/voz/fuente y repite Paso 2.
- Si es entregable a cliente → pásalo por [[tool-output-verifier]] (calidad del guion/caption asociado).
- Si la sesión enseñó algo → append en `context/learnings.md` bajo `## tool-video-generator`.

## Outputs
- `projects/tool-video-generator/<YYYY-MM-DD>-<tema>/video.mp4` (vertical, con voz + subtítulos).
- Guion + caption asociados (para repurposing/publicación).

## Skills que llama
- **`marketing-video`** — origen del guion/ángulo (antes del render).
- **`tool-output-verifier`** — gate de calidad si el clip es entregable.
- **`marketing-content-repurposing`** / **`marketing-social`** — distribución posterior.

## Edge cases
- FFmpeg no instalado o fuera de PATH → el ensamblado falla; instala FFmpeg antes.
- Sin key de stock → sin footage; usa `--video-source local` con material propio.
- Rate limit de Pexels/Pixabay (free) → baja el nº de clips o rota key.
- Contenido de fútbol/análisis táctico → NO es esto; deriva al proyecto FVI (dominio aparte).
- Windows: preferir Docker; si Python nativo, cuidar rutas y FFmpeg en PATH.

## Examples

Ver `references/examples.md` para casos completos.
