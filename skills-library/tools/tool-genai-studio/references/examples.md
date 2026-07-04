# tool-genai-studio — Ejemplos

## Ejemplo 1 · Vídeo con un modelo específico (Kling)

**Operador**: "Genérame un clip de 5s con Kling de un balón entrando en la escuadra, cámara lenta."

**Flujo**:
1. Modalidad = vídeo, modelo = Kling, prompt + params (5s, 9:16, cámara lenta). Se comprueba que
   la instancia/gateway expone Kling.
2. Generación vía gateway `muapi.ai` (key en `.env`). Render recogido en
   `projects/tool-genai-studio/2026-07-04-balon-escuadra/clip.mp4`.
3. Revisión de fidelidad: 1er intento con movimiento raro → se ajusta el prompt (seed nueva) y se
   repite. Entregado.

## Ejemplo 2 · Comparar modelos de imagen

**Operador**: "Quiero ver cómo queda el mismo prompt en Flux vs otro modelo."

**Flujo**:
1. Mismo prompt, dos modelos. Self-host levantado (Node 18+) para no gastar en gateway.
2. Se generan las dos imágenes, se guardan lado a lado en el proyecto con nota de qué modelo es cuál.
3. Se anota en `learnings` qué modelo rindió mejor para ese tipo de prompt.

## Nota honesta

Si lo que hace falta es UNA imagen de marketing normal, `marketing-image` es más rápido y ya integra
marca. Esta skill solo compensa cuando el operador quiere un modelo concreto (Kling/Sora/Veo…) o
comparar varios. Si la app no arranca (monorepo pesado), plan B = gateway `muapi.ai`.
