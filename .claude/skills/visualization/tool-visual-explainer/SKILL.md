---
name: tool-visual-explainer
description: Genera páginas HTML autocontenidas y bonitas que explican visualmente sistemas, código, planes, datos o análisis. Úsalo cuando el operador diga "hazme un HTML de esto", "ponlo bonito para compartir", "explícalo visual", "móntame una página que explique X", "pásalo a algo compartible/visual", cuando necesites compartir un output complejo (diagrama, comparativa, recap de proyecto, plan review, tabla larga), o cuando otra skill (welcome-quick-win, seis-sombreros, marketing-positioning) cierre con material que el usuario querrá compartir por WhatsApp/Skool/email. Output: HTML5 sin dependencias externas, móvil-first, paleta sobria con acento naranja iAmasters.
---

# tool-visual-explainer

> Inspirado en la skill `visual-explainer` de la suite Anthropic + comunidad. Adaptada al patrón iAmasters OS con paleta y branding del repo.

## Cuándo se invoca

- Otra skill cierra con un análisis o entregable que el usuario querrá compartir
- Usuario pide "hazme un HTML de esto", "ponlo bonito para compartir", "exporta esto"
- Usuario va a presentar el output a otra persona (cliente, socio, asesor, comunidad)
- Tablas largas (4+ filas, 3+ columnas) — mejor en HTML que ASCII

NO se invoca:
- Para outputs internos que solo lee Claude (sería gasto inútil)
- Cuando el usuario ya está en una herramienta visual (Notion, Figma, etc.)
- Para outputs <200 palabras donde markdown plano basta

## Process

### Paso 1 · Recibir input

La skill recibe (de otra skill o del usuario directamente):

- **Título** del documento
- **Bloques de contenido**: cada bloque tiene tipo (`hero`, `text`, `table`, `list`, `quote`, `metric-card`, `image`, `code`, `cta`)
- **Metadatos opcionales**: fecha, autor, versión, branding sí/no
- **Destino del archivo**: ruta relativa al repo (default `projects/visual/<YYYY-MM-DD>-<titulo>.html`)

Si la skill se invoca desde otra (ej. `welcome-quick-win`), esos campos vienen pre-poblados.

Si la invoca el usuario directamente, pregunta lo mínimo:

```
¿Qué quieres convertir en HTML compartible?
  • Pega el contenido (markdown vale)
  • O dime qué archivo/conversación procesamos
```

### Paso 2 · Validar contenido

Antes de generar:

- Sin código JS embebido — el HTML debe funcionar en cualquier viewer (WhatsApp, email, Telegram que NO ejecutan JS)
- Sin dependencias CDN externas — todo inline (CSS embebido, fuentes system)
- Sin imágenes hosteadas en URL externa salvo si el usuario lo pide explícitamente — preferir SVG inline o emojis Unicode
- Verificar que ningún bloque tiene contenido > 5KB (si hay un texto enorme, sugerir resumirlo)

### Paso 3 · Generar HTML

Usa este esqueleto base. Es deliberadamente simple — no compitas con sitios webs, **prioriza legibilidad y portabilidad**.

```html
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{{ title }}</title>
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
      line-height: 1.6;
      color: #1a1a1a;
      background: #fafafa;
      padding: 24px 16px;
    }
    .container {
      max-width: 720px;
      margin: 0 auto;
      background: white;
      border-radius: 12px;
      padding: 32px 24px;
      box-shadow: 0 1px 3px rgba(0,0,0,0.06);
    }
    .hero {
      border-bottom: 2px solid #ff8c42;
      padding-bottom: 16px;
      margin-bottom: 24px;
    }
    .hero h1 { font-size: 28px; color: #1a1a1a; margin-bottom: 8px; }
    .hero .meta { color: #666; font-size: 14px; }
    h2 {
      font-size: 20px;
      color: #1a1a1a;
      margin-top: 32px;
      margin-bottom: 12px;
      border-left: 4px solid #ff8c42;
      padding-left: 12px;
    }
    h3 { font-size: 16px; margin-top: 20px; margin-bottom: 8px; color: #333; }
    p { margin-bottom: 12px; }
    ul, ol { padding-left: 24px; margin-bottom: 16px; }
    li { margin-bottom: 6px; }
    blockquote {
      border-left: 4px solid #b794f4;
      background: #faf5ff;
      padding: 12px 16px;
      margin: 16px 0;
      border-radius: 4px;
      color: #4a4a4a;
      font-style: italic;
    }
    table {
      width: 100%;
      border-collapse: collapse;
      margin: 16px 0;
      font-size: 14px;
    }
    th, td { padding: 10px 12px; text-align: left; border-bottom: 1px solid #e0e0e0; }
    th { background: #f5f5f5; font-weight: 600; color: #333; }
    tr:hover { background: #fafafa; }
    .metric-card {
      background: #fff7ed;
      border: 1px solid #fed7aa;
      border-radius: 8px;
      padding: 16px;
      margin: 12px 0;
    }
    .metric-card .label { font-size: 13px; color: #666; }
    .metric-card .value { font-size: 24px; font-weight: bold; color: #ff8c42; }
    pre, code {
      font-family: "SF Mono", Monaco, Consolas, monospace;
      background: #f5f5f5;
      padding: 2px 6px;
      border-radius: 3px;
      font-size: 13px;
    }
    pre { padding: 12px; overflow-x: auto; }
    .cta {
      background: linear-gradient(135deg, #ff8c42, #ffa66f);
      color: white;
      padding: 16px 20px;
      border-radius: 8px;
      margin: 20px 0;
      text-align: center;
      font-weight: 600;
    }
    .cta a { color: white; text-decoration: underline; }
    footer {
      margin-top: 32px;
      padding-top: 16px;
      border-top: 1px solid #e0e0e0;
      color: #888;
      font-size: 12px;
      text-align: center;
    }
    @media (max-width: 640px) {
      body { padding: 12px 8px; }
      .container { padding: 20px 16px; border-radius: 8px; }
      .hero h1 { font-size: 22px; }
    }
  </style>
</head>
<body>
  <div class="container">
    <header class="hero">
      <h1>{{ title }}</h1>
      <div class="meta">{{ subtitle }} · {{ date }}</div>
    </header>

    <!-- Renderiza cada bloque según su tipo -->
    {{ blocks }}

    <footer>
      Generado por iAmasters OS · <a href="https://iamastersacademy.com">iamastersacademy.com</a>
    </footer>
  </div>
</body>
</html>
```

### Paso 4 · Renderizar bloques

Para cada bloque del input, usa estos templates:

| Tipo | HTML |
|---|---|
| `text` | `<h2>{title}</h2><p>{body}</p>` |
| `list` | `<h2>{title}</h2><ul>{items as <li>}</ul>` (o `<ol>` si numerada) |
| `table` | `<h2>{title}</h2><table>{thead + tbody}</table>` |
| `quote` | `<blockquote>{body}</blockquote>` |
| `metric-card` | `<div class="metric-card"><div class="label">{label}</div><div class="value">{value}</div></div>` |
| `code` | `<h2>{title}</h2><pre><code>{body}</code></pre>` |
| `cta` | `<div class="cta">{body}</div>` |
| `image` | `<img src="{src}" alt="{alt}" style="max-width:100%;border-radius:6px;">` (preferir SVG inline) |

### Paso 5 · Guardar y reportar

Guarda en la ruta indicada (default `projects/visual/<YYYY-MM-DD>-<titulo>.html`).

Mensaje al usuario:

```
✓ HTML generado: projects/visual/<archivo>.html

Tamaño: <X KB>

Para compartir:
  • Doble-click para abrir en navegador y verificar
  • Adjuntar a WhatsApp/Telegram/email funciona directo
  • Si lo subes a un servidor web, va sin tocar (HTML+CSS inline)
```

### Paso 6 · Cierre y aprendizaje

Si el usuario reporta que el HTML quedó mal (colores, layout, elementos rotos), append en `context/learnings.md` bajo `## tool-visual-explainer`:

```
- <fecha>: feedback del usuario sobre [aspecto]. Próxima vez: [ajuste].
```

## Outputs

- Archivo HTML autocontenido en `projects/visual/<YYYY-MM-DD>-<titulo>.html` (o ruta indicada)
- Mensaje al usuario con tamaño + instrucciones de compartir

## Skills que llama

Ninguna directamente. Esta skill es **invocada por** otras (`welcome-quick-win`, `seis-sombreros`, `marketing-positioning`, `marketing-content-repurposing`, etc.) cuando esas necesitan un output compartible.

## Edge cases

- **Contenido > 100KB**: dividir en múltiples HTMLs (uno por sección) o sugerir resumen.
- **Tabla con >20 filas**: añadir scroll horizontal + considerar paginación visual.
- **Idioma del contenido distinto a castellano**: respeta el idioma de input. El framework HTML (footer, meta) se mantiene en castellano salvo override.
- **Usuario quiere paleta distinta a la naranja iAmasters**: aceptar override en input (`brand_color: "#XYZ"`). Default mantiene paleta del OS.
- **HTML para email**: muchos clientes email rompen estilos. Si destino es email, simplificar (pocos colores, sin gradient en CTA, tipografía estándar) y avisar al usuario.

## Notas de diseño

- **Móvil-first**: el HTML se ve más en móviles (compartido por WhatsApp) que en desktop. Probar legibilidad en pantalla 360px ancho.
- **Sin JS**: aplicaciones de mensajería NO ejecutan JS. Si necesitas interactividad (toggle, accordion), usa `<details>` y `<summary>` (HTML semántico, funciona sin JS).
- **Paleta iAmasters**: naranja `#ff8c42` (acento principal), morado `#b794f4` (citas/secundario), gris `#fafafa` (fondo). Coherente con README badges.
- **Sin tracking**: no embebas Google Analytics ni similares. El HTML es del usuario.
