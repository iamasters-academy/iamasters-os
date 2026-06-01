---
name: tool-visual-explainer
description: Genera páginas HTML autocontenidas y bonitas que explican visualmente sistemas, código, planes, datos o análisis. Úsalo cuando necesites compartir un output complejo (diagrama, comparativa, recap de proyecto, plan review, tabla larga) o cuando otra skill (welcome-quick-win, seis-sombreros, marketing-positioning) cierre con material que el usuario querrá compartir por WhatsApp/Skool/email. Output: HTML5 sin dependencias externas, móvil-first, modo claro por defecto, paleta clínica sobria (azul confianza) con firma de Juan Camilo Paris.
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

Usa este esqueleto base. Es la **forma fija de marca**: hero con degradado, secciones numeradas secuenciales y tarjetas. Prioriza legibilidad, portabilidad (sin JS) y que **todos los HTML salgan con la misma estructura**. Para cambiar la identidad visual, edita solo el bloque `:root`.

```html
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>{{ title }}</title>
<style>
  /* Paleta de marca — Juan Camilo Paris (azul confianza, modo claro). */
  :root{
    --primary:#1D4E89; --primary-2:#2E6FA8; --accent:#4FB0C6; --warm:#F2A65A;
    --ink:#16202B; --muted:#5A6675; --bg:#EAF0F8; --panel:#FFFFFF; --panel2:#F1F5FB; --line:#DDE6F0;
    --hi:#1E7A52; --hi-bg:#E3F3EA; --med:#B26A00; --med-bg:#FBEFD9; --lo:#B3261E; --lo-bg:#FBE6E4;
    --shadow:0 6px 24px rgba(16,32,43,.08);
  }
  *{box-sizing:border-box}
  body{margin:0;background:var(--bg);color:var(--ink);font:16px/1.65 -apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,Helvetica,Arial,sans-serif;-webkit-font-smoothing:antialiased}
  .wrap{max-width:880px;margin:0 auto;padding:28px 18px 70px}
  /* Hero con degradado */
  .hero{position:relative;overflow:hidden;border-radius:18px;padding:34px 30px 30px;background:linear-gradient(135deg,#173F70 0%,var(--primary) 45%,var(--accent) 130%);color:#fff;box-shadow:var(--shadow)}
  .hero::after{content:"";position:absolute;right:-60px;top:-60px;width:220px;height:220px;background:radial-gradient(circle,rgba(255,255,255,.14),transparent 70%);border-radius:50%}
  .kicker{display:inline-block;font-size:12px;font-weight:700;letter-spacing:.12em;text-transform:uppercase;color:#0c2746;background:var(--warm);padding:4px 11px;border-radius:999px;margin-bottom:14px}
  .hero h1{font-size:29px;line-height:1.22;margin:0 0 16px;font-weight:800;max-width:42ch}
  .meta{display:flex;gap:8px;flex-wrap:wrap}
  .meta .pill{font-size:12px;background:rgba(255,255,255,.16);border:1px solid rgba(255,255,255,.28);color:#fff;border-radius:999px;padding:4px 11px}
  /* Secciones numeradas (secuenciales) */
  section{background:var(--panel);border:1px solid var(--line);border-radius:16px;padding:22px 22px 6px;margin:18px 0;box-shadow:var(--shadow)}
  .sec-head{display:flex;align-items:center;gap:12px;margin:2px 0 14px}
  .sec-num{flex:none;width:34px;height:34px;border-radius:10px;display:grid;place-items:center;background:linear-gradient(135deg,var(--primary),var(--primary-2));color:#fff;font-weight:800;font-size:15px;box-shadow:0 2px 8px rgba(29,78,137,.35)}
  .sec-head h2{margin:0;font-size:19px;color:var(--ink);font-weight:750}
  h3{font-size:15px;color:var(--primary);margin:20px 0 8px;font-weight:700}
  p{margin:10px 0} a{color:var(--primary)}
  section ul,section ol{margin:8px 0 16px;padding-left:20px} section li{margin:7px 0}
  sup a{color:var(--primary);text-decoration:none;font-weight:700}
  /* Chips (definiciones / abreviaturas) */
  .chips{display:grid;grid-template-columns:repeat(auto-fill,minmax(220px,1fr));gap:10px;margin:6px 0 16px}
  .chips .item{display:flex;gap:10px;align-items:flex-start;background:var(--panel2);border:1px solid var(--line);border-radius:10px;padding:9px 11px}
  .chips .sig{flex:none;font-size:12px;font-weight:800;color:#fff;background:var(--primary);border-radius:7px;padding:3px 8px;min-width:46px;text-align:center}
  .chips .term{font-size:13px;color:var(--muted);line-height:1.4}
  /* KPIs / métricas */
  .kpi{display:grid;grid-template-columns:repeat(auto-fit,minmax(160px,1fr));gap:12px;margin:6px 0 18px}
  .kpi .k{background:var(--panel2);border:1px solid var(--line);border-top:3px solid var(--warm);border-radius:12px;padding:14px}
  .kpi .v{font-size:23px;font-weight:800;color:var(--primary);letter-spacing:-.01em} .kpi .l{font-size:12px;color:var(--muted);margin-top:3px}
  /* Tablas */
  .tablewrap{border:1px solid var(--line);border-radius:12px;overflow:hidden;margin:14px 0}
  table{width:100%;border-collapse:collapse;font-size:14px}
  th,td{padding:10px 12px;text-align:left;vertical-align:top;border-bottom:1px solid var(--line)}
  thead th{background:var(--primary);color:#fff;font-weight:650;border-bottom:none}
  tbody tr:nth-child(even){background:var(--panel2)} tbody tr:last-child td{border-bottom:none}
  td code{color:var(--primary);font-weight:600}
  /* Badges / callout / vacíos */
  .badge{display:inline-block;border-radius:999px;padding:2px 10px;font-size:12px;font-weight:700}
  .b-hi{background:var(--hi-bg);color:var(--hi);border:1px solid var(--hi)}
  .b-med{background:var(--med-bg);color:var(--med);border:1px solid var(--med)}
  .b-lo{background:var(--lo-bg);color:var(--lo);border:1px solid var(--lo)}
  .callout{background:var(--panel2);border-left:4px solid var(--accent);border-radius:8px;padding:12px 14px;margin:14px 0;color:#27323c}
  .gap{background:#FFF8EF;border:1px solid #F6E0C2;border-left:4px solid var(--warm);border-radius:12px;padding:6px 18px;margin:8px 0 14px}
  .small{font-size:13px;color:var(--muted)}
  /* Código / CTA */
  pre,code{font-family:"SF Mono",Monaco,Consolas,monospace;background:#EEF1F6;border-radius:4px;font-size:13px}
  code{padding:2px 6px} pre{padding:12px;overflow-x:auto}
  .cta{background:linear-gradient(135deg,var(--primary),var(--accent));color:#fff;padding:16px 20px;border-radius:10px;margin:16px 0;text-align:center;font-weight:700}
  .cta a{color:#fff;text-decoration:underline}
  /* Referencias numeradas */
  .refs{counter-reset:r;list-style:none;padding:0;margin:6px 0 8px}
  .refs li{position:relative;padding:10px 0 10px 40px;border-bottom:1px solid var(--line);font-size:13px;color:#37424d}
  .refs li:last-child{border-bottom:none}
  .refs li::before{counter-increment:r;content:counter(r);position:absolute;left:0;top:10px;width:26px;height:26px;border-radius:8px;background:var(--panel2);border:1px solid var(--line);color:var(--primary);font-weight:800;font-size:12px;display:grid;place-items:center}
  .refs a{color:var(--primary);text-decoration:none}
  .note{font-size:12px;color:var(--muted);margin:10px 0 0}
  footer{text-align:center;color:var(--muted);font-size:13px;margin-top:26px} footer .sig{font-weight:700;color:var(--primary)}
  @media(max-width:560px){.hero h1{font-size:23px}.wrap{padding:18px 12px 50px}section{padding:18px 16px 4px}}
</style>
</head>
<body>
<div class="wrap">

  <header class="hero">
    <span class="kicker">{{ kicker }}</span>      <!-- etiqueta corta opcional -->
    <h1>{{ title }}</h1>
    <div class="meta">{{ meta_pills }}</div>       <!-- un <span class="pill">…</span> por metadato -->
  </header>

  <!-- Una <section> numerada por bloque temático, en orden secuencial 01, 02, … -->
  {{ sections }}

  <footer><span class="sig">Generado por Dr. Juan Camilo Paris</span></footer>

</div>
</body>
</html>
```

### Paso 4 · Renderizar bloques

**Cada bloque temático va dentro de una `<section>` numerada secuencialmente** (01, 02, 03…). Esa es la "forma fija" que se repite en todos los HTML:

```html
<section>
  <div class="sec-head"><span class="sec-num">01</span><h2>Título de la sección</h2></div>
  <!-- aquí el contenido de la sección (uno o varios de los componentes de abajo) -->
</section>
```

Componentes disponibles dentro de una sección:

| Tipo | HTML |
|---|---|
| `text` | `<p>{body}</p>` (usa `<h3>` para subtítulos dentro de la sección) |
| `list` | `<ul><li>…</li></ul>` (o `<ol>`) |
| `chips` (definiciones / abreviaturas) | `<div class="chips"><div class="item"><span class="sig">SIGLA</span><span class="term">término completo</span></div> …</div>` |
| `kpi` (métricas clave) | `<div class="kpi"><div class="k"><div class="v">{valor}</div><div class="l">{etiqueta}</div></div> …</div>` |
| `table` | `<div class="tablewrap"><table><thead><tr><th>…</th></tr></thead><tbody>…</tbody></table></div>` |
| `badge` | `<span class="badge b-hi">Alta</span>` · `b-med` (ámbar) · `b-lo` (rojo) — para estados/confianza |
| `callout` (idea clave) | `<div class="callout"><b>Título:</b> {body}</div>` |
| `gap` (vacíos / pendientes) | `<div class="gap"><ul><li>…</li></ul></div>` |
| `quote` | usa `callout` |
| `code` | `<pre><code>{body}</code></pre>` |
| `cta` | `<div class="cta">{body}</div>` |
| `refs` (referencias) | `<ol class="refs"><li id="r1">…</li> …</ol>` (numeración automática) |
| `image` | `<img src="{src}" alt="{alt}" style="max-width:100%;border-radius:10px;">` (preferir SVG inline) |

**Reglas de composición (de la búsqueda de buenas prácticas):**
- **Secuencial y numerado**: secciones en orden, con su `.sec-num`. Da una lectura guiada y la misma forma siempre.
- **Un solo color de realce domina** (azul); celeste acompaña; ámbar es solo acento puntual (kicker, filo de KPI, vacíos).
- **Máximo 3 niveles de jerarquía** de texto (h1 hero · h2 sección · h3 subtítulo).
- **Aire y tarjetas**: cada sección es una tarjeta con margen; no amontonar.
- El `metric-card` antiguo se reemplaza por `kpi`; `blockquote` por `callout`.

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
- **Usuario quiere paleta distinta a la de marca**: aceptar override en input (`brand_color: "#XYZ"` o un set de variables). Default mantiene la paleta de marca (azul confianza). Para un cambio global, editar el bloque `:root`.
- **HTML para email**: muchos clientes email rompen estilos. Si destino es email, simplificar (pocos colores, sin gradient en CTA, tipografía estándar) y avisar al usuario.

## Notas de diseño

- **Móvil-first**: el HTML se ve más en móviles (compartido por WhatsApp) que en desktop. Probar legibilidad en pantalla 360px ancho.
- **Sin JS**: aplicaciones de mensajería NO ejecutan JS. Si necesitas interactividad (toggle, accordion), usa `<details>` y `<summary>` (HTML semántico, funciona sin JS).
- **Sin tracking**: no embebas Google Analytics ni similares. El HTML es del usuario.

## Paleta de marca — Juan Camilo Paris

Identidad visual por defecto de todos los HTML. Dirección: **azul confianza sobrio**, modo claro. Casa credibilidad clínica con un toque cálido mínimo (sin caer en lo corporativo frío ni en lo estridente). Definida como variables CSS en `:root` — cambiar ahí actualiza todo el documento.

| Token | Hex | Rol | Uso |
|---|---|---|---|
| `--primary` | `#1D4E89` | Azul confianza (principal) | Bordes de hero/h2, h3, enlaces, valor de métricas, base del CTA |
| `--accent` | `#4FB0C6` | Celeste (acento) | Borde de citas, borde inferior de cabeceras de tabla, fin del degradado CTA |
| `--warm` | `#F2A65A` | Ámbar (toque cálido) | Solo como acento puntual (borde izq. de `metric-card`). Úsalo con moderación: es el guiño de calidez paisa, no el protagonista |
| `--ink` | `#16202B` | Tinta | Texto principal |
| `--muted` | `#5A6675` | Gris | Metadatos, texto secundario, footer |
| `--bg` | `#F5F8FC` | Fondo | Página |
| `--panel` | `#FFFFFF` | Tarjeta | Contenedor |
| `--line` | `#DDE6F0` | Borde | Separadores, bordes de tabla |

**Reglas de uso:**
- El **azul** manda; el **celeste** acompaña; el **ámbar** es solo un guiño (≤1 elemento por vista).
- Modo **claro** por defecto. Si el usuario pide versión oscura, invertir `--bg`/`--panel`/`--ink` manteniendo `--primary`/`--accent`/`--warm`.
- **Footer fijo**: `Generado por Dr. Juan Camilo Paris` (sin enlaces ni marca de terceros).
- Para una pieza puntual con otra identidad (p. ej. un cliente), override de variables en ese HTML; no se cambia el default de la skill.
