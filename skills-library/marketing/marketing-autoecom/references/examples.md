# marketing-autoecom — Ejemplos

## Ejemplo 1 · Carrusel diario con brand-context existente

**Operador**: "Genera el carrusel de hoy para mi tienda."

**Flujo**:
1. Preflight OK (4 env vars presentes). Existe `brand-context/` → se usa como brand kit
   (paleta `#0F172A`/`#F59E0B`, voz registro C cercano). No se re-extrae de la home.
2. Round-robin elige "Mochila Urban 24L" (no procesada en 12 días). `plan.json`: 5 slides
   (hook → 3 beneficios → CTA), caption + 8 hashtags.
3. Se generan y componen 5 slides 1080×1350. QA visual: slide 3 con texto sobre zona clara →
   se añade gradiente inferior. Resto OK.
4. Caption pasa por `marketing-brand-voice` (ajusta 2 frases al registro C) y `tool-output-verifier`
   (score 86/100 ≥ 80). Se muestra tabla con rutas y se pide OK.
5. Operador aprueba → IG publicado, TikTok en borrador (para añadir sonido). `processed.json`
   marca la mochila. Copia en `projects/marketing-autoecom/2026-07-04-tienda-demo/`.

## Ejemplo 2 · Sin brand-context (tienda nueva)

**Operador**: "Empieza a sacar posts de producto de https://tienda-demo.example."

**Flujo**:
1. No hay `brand-context/`. Se ofrece crear contexto con `marketing-product-context`; el operador
   dice "hazlo rápido con lo que saques de la web".
2. La herramienta extrae identidad de `STORE_URL` (logo, 2 colores, tipografía) y cachea 7 días.
   **Aviso honesto**: la home tenía un logo de "Visa" en el footer; se descarta manualmente y se
   toma el logo real de la cabecera.
3-5. Igual que el Ejemplo 1. En el cierre se sugiere formalizar `brand-context/` para no depender
   de la extracción automática.

## Nota de edge case

Si `UPLOAD_POST_API_KEY`/`UPLOAD_POST_PROFILE` no están conectadas, la skill compone los slides y los
deja en la carpeta de salida + `projects/…`, y avisa: "Listos para subida manual; conecta Upload-Post
para automatizar la publicación."
