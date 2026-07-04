# tool-voicebox — Ejemplos

## Ejemplo 1 · Voz en off para un guion

**Operador**: "Hazme la voz en off en español de este guion de 40s."

**Flujo**:
1. Modo TTS, español, voz neutra. Guion pegado (o reutilizado de `marketing-video`).
2. Se genera `audio.mp3` con el motor por defecto. Revisión: una cifra se lee raro → se reescribe
   "2-0" como "dos a cero" y se regenera.
3. Audio en `projects/tool-voicebox/2026-07-04-guion-padel/audio.mp3`, listo para
   `tool-video-generator`/`tool-video-montage`.

## Ejemplo 2 · Dictado local (STT)

**Operador**: "Transcribe esta nota de voz que grabé."

**Flujo**:
1. Modo dictado (Whisper local). Se pasa el fichero de audio.
2. Salida `transcripcion.txt`. Sin coste ni subida a la nube (privacidad).

## Nota de setup

Local-first: la primera vez hay que clonar el repo y arrancar el backend. Sin GPU funciona en CPU
(más lento en textos largos). Para clonar una voz de un tercero, confirma consentimiento antes de
usarla en material comercial.
