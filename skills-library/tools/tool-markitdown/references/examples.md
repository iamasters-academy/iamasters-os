# Examples — tool-markitdown

> Casos completos de invocación + output esperado. Placeholder genéricos, sin info privada.

## Ejemplo 1 · PDF de cliente → Markdown (pipeline de research)

**Input del operador:** "Convierte este PDF a Markdown: `~/Downloads/informe-competidor.pdf`. Lo quiero para meterlo en NotebookLM."

**Flujo:**
1. Detectar: PDF → extra `[pdf]`. Verificar: `pip show markitdown` (si falta el extra, `pip install 'markitdown[pdf]'`).
2. Convertir: `markitdown ~/Downloads/informe-competidor.pdf -o projects/tool-markitdown/2026-07-11-informe-competidor/output.md`.
3. Revisar: títulos jerárquicos OK, tablas como MD, enlaces preservados. Si el PDF es escaneado (sin texto seleccionable) → avisa y ofrece OCR.
4. Cierre: dejar `output.md` listo; ofrecer encadenar con `notebooklm-mcp` ("¿lo subo como fuente al notebook de competencia?").

**Output esperado:**
```
projects/tool-markitdown/2026-07-11-informe-competidor/
└── output.md   # Markdown limpio, tablas y títulos preservados
```

## Ejemplo 2 · DOCX con imágenes embebidas (deck de cliente)

**Input:** "Pásame este Word a MD: `propuesta-cliente.docx`. Tiene gráficos."

**Flujo:**
1. Detectar: DOCX → extra `[docx]`.
2. Sin backend LLM configurado → las imágenes embebidas se **omiten** (avisa: "los gráficos no se describen; si los necesitas, configuro un backend LLM o uso Azure DI").
3. Convertir: `markitdown propuesta-cliente.docx -o propuesta.md`.
4. Revisar: texto y tablas OK; huecos donde había imágenes (marcados como `[Image]` o referencias).

**Nota:** si el operador quiere las imágenes descritas → `MarkItDown(llm_client=OpenAI(), llm_model="gpt-4o").convert(...)` (requiere `OPENAI_API_KEY` en `.env.local`, nunca commiteada).

## Ejemplo 3 · URL de YouTube → Markdown (transcripción + metadatos)

**Input:** "¿Qué dice este vídeo? `https://youtube.com/watch?v=XXXX` — pásalo a MD."

**Flujo:**
1. Detectar: YouTube → requiere `yt-dlp` + extra `[youtube-transcription]`.
   - Si falta yt-dlp: `pip install yt-dlp`.
2. Convertir: `markitdown "https://youtube.com/watch?v=XXXX" -o video.md`.
3. Revisar: el MD contiene metadatos (título, canal) + transcripción.
4. Cierre: ofrecer encadenar con `tool-transcribe-social` (si además hace falta análisis social) o `marketing-content-repurposing` (si se va a trocear en piezas).

**Anti-disparador recordatorio:** si la URL es un Reel/TikTok/Short de redes → eso es `tool-transcribe-social`, no este. MarkItDown cubre YouTube y ficheros locales; `tool-transcribe-social` cubre redes sociales con contexto (caption, hashtags, comentarios).
