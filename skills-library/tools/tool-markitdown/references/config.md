# Config — tool-markitdown

> Matriz de formatos, extras y limitaciones. Referencia para el Setup y el Paso 1.

## Instalación

```bash
# Todo en uno (recomendado para empezar)
pip install 'markitdown[all]'
# o con uv
uv tool install 'markitdown[all]'

# Extras selectivos (más ligero)
pip install 'markitdown[pdf,docx,pptx,xlsx,audio-transcription,youtube-transcription]'
```

## Uso

```bash
# CLI — un fichero
markitdown fichero.pdf > salida.md
markitdown fichero.docx -o salida.md
markitdown "https://youtube.com/watch?v=XXXX" -o video.md

# Pipe
cat algo.html | markitdown > algo.md
```

```python
# Python lib — lote / lógica
from markitdown import MarkItDown
md = MarkItDown()
result = md.convert("fichero.pdf")
print(result.text_content)

# Con backend LLM para describir imágenes embebidas
from openai import OpenAI
md = MarkItDown(llm_client=OpenAI(), llm_model="gpt-4o")
```

## Matriz de formatos

| Formato | Extra | ¿Requiere key/dep extra? | Notas |
|---|---|---|---|
| PDF | `[pdf]` | No | Texto seleccionable. **Escaneado → OCR aparte** |
| Word (DOCX) | `[docx]` | No | Imágenes embebidas se omiten sin backend LLM |
| PowerPoint (PPTX) | `[pptx]` | No | Igual que DOCX con imágenes |
| Excel (XLSX/XLS) | `[xlsx]` / `[xls]` | No | Hojas → tablas MD |
| HTML | core | No | Limpia tags, conserva estructura |
| CSV/JSON/XML | core | No | Salida estructurada |
| Imagen (PNG/JPG) | core + OCR | Plugin `markitdown-ocr` o backend LLM para describir | EXIF siempre; contenido vía OCR/LLM |
| Audio | `[audio-transcription]` | Proveedor Whisper/LLM | Pesado; transcribe |
| YouTube URL | `[youtube-transcription]` | `yt-dlp` | Metadatos + transcripción |
| ZIP | core | No | Itera contenido, convierte cada fichero |
| Outlook (.msg) | `[outlook]` | No | Cuerpo + adjuntos referenciados |
| ePub | core | No | Libros digitales |

## Limitaciones y seguridad

- **PDFs escaneados** (sin capa de texto) → markitdown base **no hace OCR**. Usar:
  - `pip install markitdown-ocr` (plugin OCR local), o
  - Azure Document Intelligence (`markitdown ... -d -e <endpoint>`, cloud de pago, mayor calidad).
- **Imágenes embebidas** en DOCX/PPTX → se omiten salvo backend LLM (`llm_client` + `llm_model`).
- **Sin GPU, sin FFmpeg** necesarios para los formatos ofimáticos. El extra de audio usa su propio motor.
- **Seguridad**: markitdown hace I/O con los privilegios del proceso. En entornos no fiables:
  - Sanitiza rutas/inputs antes de convertir.
  - Prefiere `convert_local()` / `convert_stream()` sobre `convert()` con URLs arbitrarias.
  - No apuntes a directorios no fiables sin validación.
- **Documentos protegidos** por contraseña → error; desbloquea antes o pide el pass.

## Azure Document Intelligence (opcional, de pago)

Mayor calidad de layout/OCR, campos estructurados y soporte de vídeo (Content Understanding):

```bash
markitdown fichero.pdf -d -e https://<resource>.cognitiveservices.azure.com \
  -k <API_KEY>   # key en env var, nunca commiteada
```
