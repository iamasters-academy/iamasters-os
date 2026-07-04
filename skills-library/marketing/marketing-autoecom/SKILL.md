---
name: marketing-autoecom
description: Genera y auto-publica carruseles de producto para Instagram/TikTok a partir de la URL de una tienda e-commerce, extrayendo identidad de marca, eligiendo bestseller por round-robin, componiendo slides con IA y publicando con aprobación. Úsala cuando el operador diga "genera un carrusel de producto", "posts diarios de mi tienda", "publica catálogo en IG/TikTok" o "automatiza contenido de e-commerce".
---

# marketing-autoecom

> **Adaptación iAmasters OS** — Wrapper de `Upload-Post/skill-autoecom` (MIT, autor `@mutonby`, homepage
> https://github.com/mutonby/skill-autoecom). El repo original ya es una skill de agente con sus propios
> scripts Python; esta skill del OS **no vendoriza su código**: documenta el setup (clonar + keys) y
> orquesta su pipeline. Puente al OS: el "brand kit" que la skill extrae de la home mapea a tu
> `brand-context/` (voz, colores, tipografía) — si ya existe, úsalo como fuente y sáltate la inferencia.
> El entregable pasa por [[tool-output-verifier]] + [[marketing-brand-voice]] ANTES de publicar (regla OS).

## Cuándo se invoca
- El operador dice "genera un carrusel de producto", "posts diarios de mi tienda", "publica catálogo en IG/TikTok", "automatiza contenido de e-commerce".
- Como paso de producción dentro de un embudo e-commerce (tras definir catálogo/oferta).
- Rutina diaria/semanal si el operador la programa (ver Setup → routines).

## Setup (una vez, runtime — no se versiona en el repo)
- **Clonar** la herramienta fuera del OS: `git clone https://github.com/mutonby/skill-autoecom`.
- **Entorno**: Python 3.11+, `venv`, deps `google-genai`, `Pillow`, `beautifulsoup4`, `lxml`, `requests`.
- **Env vars** (en `.env` de la herramienta, NUNCA commiteadas): `UPLOAD_POST_API_KEY`, `UPLOAD_POST_PROFILE`, `GEMINI_API_KEY`, `STORE_URL`.
- **Validación**: `python -c "import google.genai, PIL"` sin error y las 4 vars presentes → setup OK.

## Process

### Paso 1 · Preflight + brand kit
- Verifica venv y las 4 env vars (Setup). Si falta una → para y pídela al operador.
- **Si existe `brand-context/`** → úsalo como brand kit (logo, colores, voz). Si no, deja que la
  herramienta extraiga identidad de `STORE_URL` (cachea 7 días).
- **Validación**: brand kit resuelto (colores + logo + voz) desde `brand-context/` o extracción.

### Paso 2 · Elegir producto + planificar
- Selecciona el siguiente bestseller por round-robin (evita repetir; estado en `state/processed.json`).
- Planifica el carrusel (3-8 slides, texto ≤8 palabras/slide, prompts de imagen, caption, hashtags) → `plan.json`.
- **Validación**: `plan.json` con estructura de slides + caption; formato 1080×1350 (4:5), 2-10 slides.

### Paso 3 · Generar + componer + QA
- Genera cada slide con el modelo de imagen (referencia de producto) y compón texto/logo/gradiente con Pillow.
- **QA visual propio** (no lo delegues al regex): revisa cada slide — legibilidad del texto, producto reconocible, render limpio.
- **Validación**: N slides compuestos, todos pasan QA visual (marca los dudosos).

### Paso 4 · Gate de marca + aprobación
- Pasa caption + textos por [[marketing-brand-voice]] (registro correcto) y [[tool-output-verifier]] (`score-only: true`).
- Presenta tabla markdown (slides + estado QA + rutas absolutas) y **pide aprobación explícita**.
- **Validación**: verifier ≥ umbral y operador aprueba. Sin aprobación NO se publica.

### Paso 5 · Publicar + cerrar
- Dry-run primero; luego sube el carrusel. **TikTok SIEMPRE como borrador** (`post_mode=MEDIA_UPLOAD`) para que el operador añada sonido viral en la app.
- Marca el producto como procesado (`state/processed.json`); reporta carpeta y detalles.
- Si la sesión enseñó algo → append en `context/learnings.md` bajo `## marketing-autoecom`.

## Outputs
- Carrusel (slides 1080×1350 + caption + hashtags) en la carpeta de salida de la herramienta.
- Publicación (IG live / TikTok borrador) vía Upload-Post; `state/processed.json` actualizado.
- Copia del entregable en `projects/marketing-autoecom/<YYYY-MM-DD>-<tienda>/` para trazabilidad.

## Skills que llama
- **`marketing-brand-voice`** — validar voz/registro del caption (Paso 4).
- **`tool-output-verifier`** — gate de calidad antes de publicar (Paso 4).
- **`marketing-product-context`** — si no hay `brand-context/`, crear contexto de producto primero.

## Edge cases
- Falta una env var → para y pídela; no publiques a medias.
- Home sin identidad clara (regex confunde logo de marca destacada con el de la tienda) → decide tú el logo/colores, no automatices ese paso.
- Sin `brand-context/` ni `STORE_URL` accesible → deriva a [[marketing-product-context]].
- Cuenta Upload-Post/IG Business/TikTok sin conectar → bloquea en publicación; entrega los slides para subida manual.

## Examples

Ver `references/examples.md` para casos completos.
