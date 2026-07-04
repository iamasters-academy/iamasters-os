---
name: tool-genai-studio
description: Genera imágenes o vídeos desde un prompt eligiendo entre 200+ modelos (Flux, Kling, Sora, Veo…) desplegando o llamando al studio Open-Generative-AI. Úsala cuando el operador diga "genera imagen/vídeo con el modelo X", "studio de generación multi-modelo", "quiero probar varios modelos de imagen/vídeo" o necesite un modelo concreto no cubierto por [[marketing-image]] / [[tool-video-generator]].
---

# tool-genai-studio

> **Adaptación iAmasters OS** — Wrapper de `Anil-matcha/Open-Generative-AI` (MIT). **Honestidad**: el
> original es una **app** (Next.js/Electron, monorepo), no un procedimiento — es la candidata más
> floja del lote. Esta skill es un wrapper fino "deploy + call": documenta cómo levantarla (self-host)
> o llamar al gateway `muapi.ai`, y la usa para generación puntual. **Para generación normal,
> [[marketing-image]] (imagen) o [[tool-video-generator]] (vídeo corto) suelen bastar** — usa esta
> solo cuando el operador quiera un modelo específico (Kling, Sora, Veo…) o comparar muchos modelos.

## Cuándo se invoca
- El operador dice "genera imagen/vídeo con el modelo X", "studio multi-modelo", "quiero probar varios modelos".
- Necesita un modelo concreto (Flux/Kling/Sora/Veo…) que las skills de imagen/vídeo del OS no exponen.
- NO para generación rutinaria de imagen (→ [[marketing-image]]) ni de short estándar (→ [[tool-video-generator]]).

## Setup (una vez, runtime — no se versiona en el repo)
- **Opción A · Self-host**: `git clone https://github.com/Anil-matcha/Open-Generative-AI`, Node.js v18+, seguir su README (monorepo npm; frontend Next.js 14 / Electron). Inferencia local opcional (sd.cpp, Wan2GP) sin key.
- **Opción B · Gateway**: usar `muapi.ai` como pasarela de modelos (requiere su API key en `.env`, NUNCA commitear).
- **Validación**: la app arranca en local (o el gateway responde) y lista modelos disponibles.

## Process

### Paso 1 · Definir petición de generación
- Recoge: modalidad (imagen/vídeo), modelo objetivo, prompt, parámetros (resolución, duración, seed), y referencias si aplica.
- **Validación**: modelo elegido está disponible en la instancia/gateway; prompt + params completos.

### Paso 2 · Generar y recoger
- Lanza la generación (UI del studio o API/gateway). Espera el render (vídeo puede tardar).
- Copia el output a `projects/tool-genai-studio/<YYYY-MM-DD>-<titulo>/`.
- **Validación**: fichero generado presente y abre correctamente.

### Paso 3 · Revisar y entregar
- Revisa fidelidad al prompt y calidad. Si falla → ajusta prompt/params/modelo y repite Paso 2.
- Si es entregable a cliente → pásalo por [[brand-guidelines]] (consistencia visual) y [[tool-output-verifier]] si lleva copy.
- Append en `context/learnings.md` bajo `## tool-genai-studio` si aprendiste algo (p. ej. qué modelo rinde para qué).

## Outputs
- `projects/tool-genai-studio/<YYYY-MM-DD>-<titulo>/` con la imagen/vídeo generado + prompt/params usados.

## Skills que llama
- **`marketing-image`** — alternativa más simple para imagen de marketing rutinaria.
- **`tool-video-generator`** — alternativa para short estándar con voz/subtítulos.
- **`brand-guidelines`** / **`tool-output-verifier`** — gates si el output es entregable.

## Edge cases
- Solo hace falta una imagen puntual → usa [[marketing-image]]; no montes el studio entero.
- Sin GPU local y sin key de gateway → generación inviable; avisa y ofrece alternativa.
- Modelo pedido no disponible en la instancia → lista los que sí hay y propón el más cercano.
- App no arranca (monorepo pesado) → documenta el fallo y usa el gateway `muapi.ai` como plan B.

## Examples

Ver `references/examples.md` para casos completos.
