# marketing-autopublish — Ejemplos

## Ejemplo 1 · Distribuir un reel a 4 redes

**Operador**: "Sube este reel a TikTok, YouTube, Instagram y LinkedIn."

**Flujo**:
1. Pieza lista + captions por red. Las 4 redes están autenticadas (OAuth).
2. Captions pasan por `marketing-brand-voice` + `tool-output-verifier` (score OK). Operador aprueba.
3. Publicación 1-click; TikTok como borrador (sonido en app). Se registran las 4 URLs en el proyecto.
   LinkedIn falla por token caducado → se reporta y se reintenta tras renovar OAuth.

## Ejemplo 2 · Gen + publicación

**Operador**: "Genera un post sobre X y publícalo en todas."

**Flujo**:
1. El copy se genera con `marketing-copywriting`; se pasa el gate.
2. AiToEarn genera visual y publica multiplataforma. Se recoge engagement inicial.

## Nota (caveats)

Setup pesado (Node 20 + MongoDB + Redis + Electron) y docs en chino. Para distribuir 1-2 piezas
puntuales, a veces sale más a cuenta hacerlo a mano. Para carrusel de producto → `marketing-autoecom`.
