# tool-video-montage — Ejemplos

## Ejemplo 1 · Documental corto con footage de archivo libre

**Operador**: "Móntame un documental de 60s sobre la historia del Mundial, con imágenes de archivo."

**Flujo**:
1. Pipeline = **documental**. Brief: 60s, español, tono épico-sobrio.
2. OpenMontage: research → guion → obtiene clips de Archive.org/Wikimedia (sin key) → voz Piper
   local → ensamblado FFmpeg. Ruta 100% gratis.
3. Revisión: coherencia OK; 2 clips exigen atribución CC → se anotan en las notas. Vídeo final a
   `projects/tool-video-montage/2026-07-04-historia-mundial/video.mp4` + `atribuciones.md`.

## Ejemplo 2 · Explainer animado (Remotion) con guion propio

**Operador**: "Convierte este guion en un explainer animado de 40s."

**Flujo**:
1. Pipeline = **explainer**. Se reutiliza el guion (no se regenera).
2. Composición animada vía Remotion + voz (Piper local por defecto; el operador pide ElevenLabs →
   se activa la key `.env`). Ensamblado y render webm.
3. Caption asociado pasa por `tool-output-verifier`. Se ofrece repurposing por plataforma.

## Nota de licencia (AGPLv3)

Mientras se **use** OpenMontage como herramienta externa (desplegada aparte), el copyleft recae en
OpenMontage y no contamina iAmasters OS. Si el operador quisiera **integrar o redistribuir su código**,
avisar del AGPLv3 y parar hasta decisión explícita. Preferir siempre la ruta gratis (Piper + archivos
libres) salvo petición expresa de generadores de pago.
