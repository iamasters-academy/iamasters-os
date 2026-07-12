---
name: tool-meta-ai-scraper
description: Exporta el historial COMPLETO de un chat de Meta AI (meta.ai/prompt/<uuid>) a Markdown limpio usando la sesión Facebook del operador. Úsala cuando el operador diga "scrapea/exporta/extrae este chat de Meta AI", "descarga el historial de meta.ai", "convierte un chat de Meta AI a Markdown", "saca toda la conversación de meta.ai", o pegue una URL meta.ai/prompt/<id> y quiera su contenido. La invoca [[tool-scrape-router]] cuando el objetivo es un chat de Meta AI con login. NO la uses para webs genéricas (eso es tool-scrape-router/Firecrawl), ni para redes sociales (Apify MCP), ni para transcripts de YouTube (tool-transcribe-social).
---

# tool-meta-ai-scraper

> Skill delegada de **[[tool-scrape-router]]** para el caso específico **chat de Meta AI con login**.
> Captura el DOM del scroller en una pasada y parsea offline — **sin scroll** (meta.ai no pagina;
> el DOM multi-MB saturaría el renderer) y **sin `innerText` por paso** (fuerza reflow).

## Cuándo se invoca

- **[[tool-scrape-router]]** la delega cuando el objetivo es `https://www.meta.ai/prompt/<uuid>`.
- El operador pega una URL `meta.ai/prompt/...` y quiere su contenido.
- El operador dice "exporta/scrapea el historial de este chat de Meta AI".

## Prerrequisitos

- **Node ≥ 20**.
- `playwright` + `cheerio` instalados en el proyecto desde donde se ejecuta:
  ```bash
  npm i -D playwright cheerio && npx playwright install chromium
  ```
- La cuenta **Facebook del operador** (login one-shot; la sesión se guarda en `~/.meta-ai-profile` y se reutiliza en todos los proyectos).

## Process

### Paso 1 · Scrape (captura del DOM)

```bash
# Desde la raíz del proyecto. --out es opcional (default: ./meta-ai-scrape).
node .claude/skills/tools/tool-meta-ai-scraper/run.mjs https://www.meta.ai/prompt/<uuid> [--out <dir>]
```

- Abre un Chromium. **Primera vez**: muestra el login de Facebook — el operador entra (email + password); el script detecta la sesión solo y sigue (timeout 5 min).
- **Siguientes veces**: reutiliza `~/.meta-ai-profile` (un login para todos los proyectos, nunca commiteado).
- Captura el HTML del scroller (`<id>.debug.html`) + texto plano (`<id>.full-text.txt`) + network captures.

### Paso 2 · Parse (HTML → Markdown limpio)

Lo hace `run.mjs` automáticamente tras el scrape. Para **re-parsear sin navegador** (rápido):

```bash
node .claude/skills/tools/tool-meta-ai-scraper/parse.mjs <dir>/<id>.debug.html <id>
```

Selectores: usuario = `div[data-message-type="user"]`, asistente = `[data-testid="assistant-message"]`. Se parsea con `cheerio` (server-side).

## Output

```
<dir>/
├── <id>.clean.md      ← entregable: turnos ## 👤 Usuario #N / ## 🤖 Meta AI #N + ## 📎 Fuentes citadas
├── <id>.debug.html    ← DOM crudo (multi-MB; guárdalo para re-parsear)
└── <id>.full-text.txt ← textContent plano
```

`.clean.md` lleva frontmatter (`source`, `prompt_id`, `title`, `scraped`, `turns`, `type: meta-ai-chat-export`) — listo para el knowledge base del proyecto.

## Skills que la llama

- **[[tool-scrape-router]]** — cuando el trabajo es un chat de Meta AI.

## Edge cases (todos probados)

- **Login no redirige a `/login`**: meta.ai renderiza el `/prompt` con overlay "Iniciar sesión" y luego salta a `auth.meta.com`. Detectar logout por **URL en auth.meta.com o `input[type=password]`**, NO por texto "Iniciar sesión" (ese link persiste en el footer tras el login).
- **Matar el proceso pierde la sesión**: Chromium flushea cookies al cerrar limpio. Si matas el scrape a la brava, `~/.meta-ai-profile` queda "crashed" y el siguiente arranque muestra "Restore pages?" que bloquea la navegación. Los flags `--disable-session-crashed-bubble --disable-features=InfiniteSessionRestore --no-first-run` lo suprimen; deja que el script salga solo (`ctx.close()`).
- **`console.log` se bufferiza** al redirigir stdout a fichero → progreso invisible hasta el exit. Los scripts loguean con `writeSync(1,…)` (unbuffered). Mantenlo.
- **No scrolles**: el DOM del chat es multi-MB; scrollear satura el renderer y congela `page.evaluate`. meta.ai manda toda la conversación en el HTML inicial (RSC) — no pagina.
- **No leas `innerText` por paso**: fuerza un reflow completo. Usa `textContent` (la captura final sí puede leer `outerHTML`/`textContent` una sola vez).

## Configuración

- **Perfil de sesión**: `~/.meta-ai-profile/` (global, compartido entre proyectos, no commiteado).
- **Output dir**: `--out <dir>` o default `./meta-ai-scrape`. El router suele pasar `projects/tool-scrape-router/<YYYY-MM-DD>-meta-ai-<id>/`.

## Examples

```bash
# Exportar un chat al knowledge base de un proyecto
node .claude/skills/tools/tool-meta-ai-scraper/run.mjs https://www.meta.ai/prompt/fc79800e-... \
  --out conocimiento/meta-ai-scrape

# Re-parsear una captura existente (sin navegador)
node .claude/skills/tools/tool-meta-ai-scraper/parse.mjs conocimiento/meta-ai-scrape/fc79800e-....debug.html fc79800e-...
```
