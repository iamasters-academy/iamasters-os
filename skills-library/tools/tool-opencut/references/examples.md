# tool-opencut — Ejemplos

## Ejemplo 1 · Recorte + subtítulos

**Operador**: "Recorta este vídeo a los primeros 30s y ponle subtítulos."

**Flujo**:
1. Input = vídeo, operación = recorte 0-30s + subtítulos automáticos, salida mp4.
2. Se ejecuta por la Editor API headless. Revisión: sync de subtítulos OK.
3. Salida en `projects/tool-opencut/2026-07-04-recorte-demo/video.mp4`.

## Ejemplo 2 · Batch de normalización a 9:16

**Operador**: "Pásame estos 5 vídeos horizontales a vertical 9:16 para Reels."

**Flujo**:
1. Lista de 5 inputs, operación = normalizar a 9:16 (con relleno/recorte inteligente), batch.
2. Itera headless sobre los 5 → 5 mp4 verticales. Se revisa uno y se aplica al resto.
3. Salidas en la carpeta del proyecto; se ofrece `marketing-content-repurposing` para el copy por red.

## Nota de setup

OpenCut está en rewrite hacia automation-first. Usar SIEMPRE el modo headless / Editor API (no la
GUI). Si una operación concreta aún no está expuesta por la API, documenta la limitación en vez de
prometerla. Es EDICIÓN: para generar un vídeo desde un tema usa `tool-video-generator`.
