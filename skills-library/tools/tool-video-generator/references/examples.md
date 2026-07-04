# tool-video-generator — Ejemplos

## Ejemplo 1 · Reel desde un tema (stock automático)

**Operador**: "Hazme un short de 30s sobre 3 beneficios del pádel para empresas."

**Flujo**:
1. Brief: tema dado, español, 30s, tono divulgativo, 9:16, fuente = stock Pexels.
2. `config.toml`: LLM = Gemini, `pexels_api_keys` free, TTS Edge-TTS (voz es-ES).
   `uv run python cli.py --video-subject "3 beneficios del pádel para empresas"`.
   Pipeline: guion 3 puntos → clips Pexels → narración → subtítulos → mp4.
3. Salida copiada a `projects/tool-video-generator/2026-07-04-padel-empresas/video.mp4`.
   Revisión: sync OK; un clip poco relevante → se regenera solo ese con otra keyword. Entregado.

## Ejemplo 2 · Encadenado desde marketing-video (guion propio)

**Operador**: "Ya tengo el guion que hicimos con marketing-video, móntame el vídeo."

**Flujo**:
1. Se reutiliza el guion existente (no se regenera con LLM). Idioma/duración heredados del guion.
2. Se pasa el guion al pipeline (WebUI para control fino de tiempos por línea) + material `local`
   del operador con `--video-source local --video-materials "intro.mp4,demo.mp4"`.
3. mp4 recogido y revisado; caption asociado pasa por `tool-output-verifier`. Se ofrece
   `marketing-content-repurposing` para sacar variantes por plataforma.

## Nota de setup

Primera vez: si no hay FFmpeg (`ffmpeg -version` falla) o no arranca la WebUI `:8501`, resolver el
setup ANTES de prometer un vídeo. En Windows, Docker (`docker-compose.release.yml`) evita líos de PATH.
