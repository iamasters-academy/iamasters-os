---
name: marketing-autopublish
description: Genera contenido con IA y lo publica en 13+ plataformas (TikTok/YouTube/Instagram/LinkedIn…) de una vez, con seguimiento de engagement, usando AiToEarn. Úsala cuando el operador diga "publica esto en todas mis redes", "distribución multiplataforma", "sube este vídeo/post a TikTok+YT+IG+LinkedIn a la vez" o quiera un pipeline de gen+publicación cross-platform. NO para carrusel de e-commerce ([[marketing-autoecom]]) ni para estrategia de posts ([[marketing-social]]).
---

# marketing-autopublish

> **Adaptación iAmasters OS** — Wrapper de `yikart/AiToEarn` (MIT). No vendoriza su código: documenta el
> setup y orquesta su pipeline. **Caveats importantes**: es **pesada** (Node 20 + MongoDB + Redis +
> Electron + OAuth de cada red) y su documentación primaria está en **chino**. Puente al OS: el
> contenido puede venir de [[marketing-copywriting]]/[[marketing-video]]; pasa el gate
> [[tool-output-verifier]] + [[marketing-brand-voice]] antes de publicar. Solapa parcial con
> [[marketing-autoecom]] (carrusel e-commerce) y [[marketing-social]] (estrategia) — ver desambiguación.

## Cuándo se invoca
- El operador dice "publica esto en todas mis redes", "distribución multiplataforma", "sube esto a TikTok+YT+IG+LinkedIn a la vez".
- Cierre de una producción de contenido que hay que distribuir en muchas plataformas de golpe.

## Setup (una vez, runtime — no se versiona en el repo)
- **Clonar** fuera del OS: `git clone https://github.com/yikart/AiToEarn`. App Electron + backend Node 20 + MongoDB + Redis (docs en chino → traducir pasos clave).
- **Keys/OAuth** (en `.env`, NUNCA commitear): 1 LLM (OpenAI/Gemini/Anthropic), generadores de vídeo opcionales (Grok/Veo/Seedance), y **OAuth de cada red** a conectar.
- **Validación**: la app arranca, Mongo/Redis conectan, y al menos 1 red autenticada por OAuth.

## Process

### Paso 1 · Preparar el contenido y las plataformas
- Recoge la pieza (o genérala) + lista de plataformas destino + caption/hashtags por red.
- **Validación**: pieza lista; plataformas destino autenticadas.

### Paso 2 · Gate de marca + calidad
- Pasa captions/copy por [[marketing-brand-voice]] y [[tool-output-verifier]] (`score-only: true`).
- **Validación**: verifier ≥ umbral; operador aprueba.

### Paso 3 · Publicar multiplataforma + seguir
- Lanza la publicación 1-click a las plataformas elegidas. Recoge IDs/URLs de cada publicación y el engagement inicial.
- **Validación**: cada plataforma devuelve OK (o error explícito por red). TikTok como borrador si aplica (sonido en app).
- Append en `context/learnings.md` bajo `## marketing-autopublish`.

## Outputs
- Publicaciones en N plataformas + registro de URLs/estado en `projects/marketing-autopublish/<YYYY-MM-DD>-<titulo>/`.

## Skills que llama
- **`marketing-copywriting`** / **`marketing-video`** — origen del contenido.
- **`marketing-brand-voice`** / **`tool-output-verifier`** — gate antes de publicar.

## Edge cases
- Setup pesado (Mongo/Redis/Electron) no montado → resuelve antes; para distribución simple valora hacerlo a mano.
- OAuth de una red caduca/falla → publica en las que sí y reporta las que no; no des todo por hecho.
- Carrusel de producto e-commerce → usa [[marketing-autoecom]]. Solo estrategia/posts → [[marketing-social]].
- Docs en chino → traduce y documenta los pasos que uses para no repetir la fricción.

## Examples

Ver `references/examples.md` para casos completos.
