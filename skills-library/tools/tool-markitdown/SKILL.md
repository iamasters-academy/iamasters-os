---
name: tool-markitdown
description: >
  Wrapper de microsoft/markitdown (MIT) que convierte PDF, Word, PowerPoint, Excel,
  HTML, CSV/JSON/XML, imágenes, audio, YouTube y más a Markdown limpio pensado para
  que lo lea un LLM, conservando títulos, listas, tablas y enlaces. Úsala cuando el
  operador diga "convierte este PDF/DOCX/PPTX/XLSX a Markdown", "extrae el texto de
  este Excel/PowerPoint", "pásame este documento a MD", "qué dice este audio/imagen",
  "mete este fichero en contexto para el modelo". NO para transcribir un Reel/TikTok
  de redes ([[tool-transcribe-social]]), scrapear una web ([[tool-scrape-router]] /
  [[tool-firecrawl-scraper]]) ni research web ligero ([[strategy-web-research]]).
version: 0.1.0
---

# tool-markitdown — Conversión de documentos a Markdown

> **Adaptación iAmasters OS** — Wrapper de `microsoft/markitdown` (MIT). No vendoriza su
> código: documenta el install (pip/uv) y orquesta su CLI y lib Python. Puente al OS:
> normaliza documentos fuente a Markdown **antes** de alimentar a [[notebooklm-mcp]],
> [[competencia]], [[investigacion-mercado]], [[legal-contract-review]] o
> [[exploratory-data-analysis]]. Es la pieza de **conversión documental** del catálogo;
> no analiza contenido (eso [[exploratory-data-analysis]]) ni extrae de la web viva.

## Cuándo se invoca
- El operador pasa un PDF/DOCX/PPTX/XLSX/HTML/CSV/imagen/audio y quiere su contenido en Markdown legible para el modelo.
- Otra skill necesita ingerir un documento ofimático como fuente (p. ej. un contrato PDF para [[legal-contract-review]], un deck de cliente para [[competencia]]).
- "¿Qué dice este PDF?", "sácale el texto a este Excel", "convierte este Word a MD".
- Un cliente manda un documento y hay que trocearlo/limpiarlo antes de procesarlo.

## Setup (una vez, runtime — no se versiona en el repo)
- **Instalar** (elige vía):
  - Todo en uno: `pip install 'markitdown[all]'` (o `uv tool install 'markitdown[all]'`).
  - Extras selectivos (más ligero): `pip install 'markitdown[pdf,docx,pptx,xlsx,audio-transcription,youtube-transcription]'`.
- **CLI**: `markitdown fichero.pdf > salida.md` (o `-o salida.md`). Acepta pipe.
- **Python lib**: `from markitdown import MarkItDown; MarkItDown().convert("fichero.pdf").text_content`.
- **Opcional de pago/calidad**: Azure Document Intelligence (`-d -e <endpoint>`) para layout/OCR cloud; o el plugin `markitdown-ocr` para OCR local de PDFs/DOCX/PPTX escaneados.
- **Opcional**: backend LLM (`llm_client` + `llm_model`, p. ej. OpenAI gpt-4o) para **describir imágenes embebidas** en PPTX/DOCX. Sin él, las imágenes se omiten.
- **No requiere** GPU ni FFmpeg. Requiere `yt-dlp` para el extra de YouTube.
- **Validación**: `markitdown --help` responde → setup OK.

Ver `references/config.md` para la matriz de formatos, extras y limitaciones.

## Process

### Paso 1 · Detectar formato y extras necesarios
- Identifica el tipo de entrada (PDF/DOCX/PPTX/XLSX/HTML/CSV/JSON/XML/imagen/audio/URL YouTube/ZIP/Outlook/ePub).
- Mapea al extra requerido (ver `references/config.md`). Si el extra no está instalado → instala solo ese.
- **Validación**: el extra del formato está presente (`pip show markitdown-...` o prueba de conversión).

### Paso 2 · Convertir
- **Un fichero**: CLI `markitdown <input> -o <output>.md`.
- **Lote / lógica**: lib Python (`convert()` por archivo; itera un directorio si hace falta).
- Si hay imágenes embebidas que describir y existe backend LLM configúralo; si no, avisa de que se omiten.
- **Validación**: el `.md` de salida existe y tiene contenido (>0 chars;结构与 tablas/listas preservadas si el original las tenía).

### Paso 3 · Revisar el Markdown
- Comprueba: títulos jerárquicos intactos, tablas renderizadas como MD, enlaces preservados, sin basura de marcadores.
- **PDF escaneado** (imagen, no texto) → markitdown base NO hace OCR; usa plugin `markitdown-ocr` o Azure DI. Si no hay, avisa: "este PDF es escaneado, necesito OCR".
- Si el contenido va a copy/publicación → puede encadenarse con [[tool-humanizer]] / [[tool-output-verifier]].
- **Validación**: el MD es legible y fiel al original; sin truncados ni tablas rotas.

### Paso 4 · Cierre
- Guarda el `.md` en `projects/tool-markitdown/<YYYY-MM-DD>-<src>/output.md` (+ `meta.json` con formato origen y extras usados si aporta).
- Si generaste output entregable → [[tool-output-verifier]] con `score-only: true`.
- Si la sesión enseñó algo → append en `context/learnings.md` bajo `## tool-markitdown`.

## Outputs
- `projects/tool-markitdown/<YYYY-MM-DD>-<src>/output.md` (contenido convertido).
- (Opcional) `meta.json` con formato origen, extras y flags (OCR/LLM-img usados).

## Skills que llama
- **`notebooklm-mcp`** / **`competencia`** / **`investigacion-mercado`** — el `.md` alimenta research grounded.
- **`legal-contract-review`** / **`legal-nda-triage`** — contrato/NDA en PDF → MD → revisión.
- **`exploratory-data-analysis`** — si el MD contiene datos tabulares para analizar.
- **`tool-humanizer`** / **`tool-output-verifier`** — si el MD se publica como copy.

## Edge cases
- **PDF escaneado** (sin capa de texto) → requiere OCR (plugin `markitdown-ocr` o Azure DI); markitdown base no lo hace.
- **Imágenes embebidas** en PPTX/DOCX → se omiten salvo backend LLM configurado.
- **Audio** → requiere extra `audio-transcription` (usa Whisper/proveedor; pesado).
- **YouTube** → requiere `yt-dlp` + extra `youtube-transcription`.
- **ZIP** → itera su contenido y convierte cada fichero.
- **Seguridad**: markitdown hace I/O con los privilegios del proceso; sanitiza inputs en entornos no fiables y usa `convert_local()` / `convert_stream()` cuando aplique. No lo apuntes a rutas no fiables sin validar.
- Documento protegido por contraseña → marcará error; pide el pass o desbloquea antes.

## Examples

Ver `references/examples.md` para 3 casos completos: PDF→MD, DOCX→MD (con imágenes) y URL YouTube→MD.

## Referencias

- [microsoft/markitdown](https://github.com/microsoft/markitdown) — Utilidad de Microsoft (equipo AutoGen) para convertir documentos a Markdown orientado a LLMs.
- Licencia: MIT.
- Notas: wrapper sin vendorizar; documenta install/uso del upstream tal cual. Formatos y extras en `references/config.md`.
