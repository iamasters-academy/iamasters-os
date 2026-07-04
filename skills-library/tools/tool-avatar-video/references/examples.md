# tool-avatar-video — Ejemplos

## Ejemplo 1 · Portavoz para un explainer

**Operador**: "Con esta foto mía, que narre este guion de 30s."

**Flujo**:
1. Retrato + guion. Se genera la voz con `tool-voicebox` (español). El Space está online.
2. `gradio_client` → se envía retrato + audio al Space LongCat; se descarga `avatar.mp4`.
   Revisión: lip-sync coherente. Guardado en `projects/tool-avatar-video/2026-07-04-explainer/`.

## Ejemplo 2 · Space saturado → fallback

**Operador**: "Hazme el avatar del anuncio."

**Flujo**:
1. El Space devuelve cola larga / error 503. Se documenta.
2. Fallback ofrecido: reintentar en frío, endpoint de pago (Replicate), o self-host (multi-GPU,
   pesado). El operador elige reintentar más tarde. No se inventa un resultado.

## Nota de derechos y setup

Solo avatares propios o con consentimiento explícito — nada de deepfakes de terceros. La API del
Space puede cambiar: inspecciona `client.view_api()` antes de llamar. Si necesitas vídeo con stock
en vez de una cara hablando, es `tool-video-generator`.
