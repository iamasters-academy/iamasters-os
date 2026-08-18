---
name: tool-transcribe-social
description: Descarga el audio de un Reel de Instagram, vídeo de TikTok, Short de YouTube o cualquier URL soportada por yt-dlp y devuelve una transcripción completa con Groq Whisper. Si la URL es de Instagram, también intenta extraer caption, hashtags, menciones y comentarios públicos vía Instaloader. Úsala cuando el usuario pegue una URL social y pida transcribir, analizar o investigar el contenido.
type: tool
project: cross
---

# tool-transcribe-social — transcripción rápida de Reels/TikTok

Skill para descargar el audio de una URL social, transcribirlo con Groq Whisper y devolver markdown listo para análisis de contenido. Si es Instagram, también intenta recuperar caption, hashtags y comentarios públicos.

## Cuándo usarla

- "Investiga este reel: https://instagram.com/reel/..."
- "Saca lo que dice este TikTok: https://tiktok.com/@user/video/..."
- "Transcribe este short de YouTube"
- "Mira este vídeo y dime de qué va" (con URL)
- Cualquier URL de vídeo social que el usuario quiera analizar

## Cómo se ejecuta

Comando único:

```bash
python3 .claude/skills/tool-transcribe-social/transcribe.py "<URL>" [--lang es|en|auto] [--out <dir>]
```

- `--lang` por defecto `es`. Para vídeos en inglés u otros usar `--lang en` o `--lang auto`.
- `--out` opcional: por defecto usa `projects/transcribe-social/<YYYY-MM-DD>/`. Si se indica otro directorio, debe estar dentro del workspace del usuario.

Si el usuario te pasa varias URLs, ejecuta UNA Bash call por URL en paralelo (no en bucle secuencial).

## Qué devuelve

Markdown con esta estructura:

```
# Transcripción social — instagram|tiktok|youtube|...

- URL, autor, duración, vistas, likes
- (Si IG) owner, fecha, hashtags, menciones, comentarios totales

## Caption del post   (solo IG)
...

## Transcripción del audio
...

## Comentarios públicos (solo IG, hasta 30)
...
```

## Después de transcribir

Cuando el usuario pegue una URL para investigar, no te quedes solo en transcribir. El siguiente paso natural es analizar:

1. Resumir en 3-5 bullets de qué va el vídeo
2. Identificar la idea principal o tesis del creador
3. Conectar con el contexto del operador o cliente activo: qué se puede adaptar, mejorar o reutilizar para contenido propio.
4. Si el usuario dice que quiere añadir algo, pregunta explícitamente el destino: skill, clase, automatización, post, email o briefing.

## Requisitos

- `GROQ_API_KEY` configurada como variable de entorno o en `.env` del repo. Es opcional en `.env.example`, pero obligatoria para transcribir con Groq.
- `yt-dlp` instalado y disponible en PATH.
- `ffmpeg` instalado y disponible en PATH.
- Python package `requests`.
- `instaloader` opcional: si falta, la transcripción sigue funcionando, pero el bloque de metadata/comentarios de Instagram se omite con una nota clara.

Instalación recomendada en macOS:

```bash
brew install yt-dlp ffmpeg
python3 -m pip install --user requests instaloader
```

Degradación elegante:

- Si falta `yt-dlp`, la skill debe parar con un mensaje claro: instala `yt-dlp`.
- Si falta `ffmpeg`, la descarga puede fallar o no recomprimir audios largos: informa al usuario y pide instalarlo.
- Si falta `GROQ_API_KEY`, no intentes transcribir en silencio: explica que falta la clave y dónde ponerla.
- Si falta `instaloader`, continúa sin comentarios públicos de Instagram.

## Coste

Groq `whisper-large-v3-turbo`: ~$0.04 por hora de audio. Un Reel de 60s ≈ 0,07 céntimos. Despreciable.

## Limitaciones conocidas

- **Instagram comentarios**: Instaloader sin login devuelve comentarios públicos del post. Si el post está limitado o la cuenta es privada, puede fallar — la skill seguirá funcionando pero el bloque de comentarios saldrá vacío con nota.
- **Rate-limiting IG**: si haces muchas URLs seguidas (>20), Instagram puede empezar a bloquear. Si pasa, esperar 10-15 min.
- **Sin captions nativos**: la skill transcribe siempre con Whisper (no intenta primero subtítulos nativos). Para 30s-3min de audio es instantáneo y la calidad es muy alta.
- **Vídeos privados o de cuentas que requieren login**: yt-dlp fallará. Para esos casos el usuario tendría que aportar cookies (no implementado en v1).

## Idiomas

Por defecto `--lang es`. Groq Whisper soporta 100+ idiomas. Si el vídeo está en inglés, usar `--lang en` para evitar transcribir con sesgo español.

Skill original de Angel Aparicio (IA Masters Academy), adaptada para iamasters-os.
