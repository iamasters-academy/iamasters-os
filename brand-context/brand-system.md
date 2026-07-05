# Sistema de marca — Informe de Jugador con IA · v2

> v2 · 2026-07-05 — rediseño visual tras investigación de tendencias 2026 (ver
> `projects/briefs/informe-jugador-ia/marketing/brand-system-propuestas.md` y el plan de la Fase 5).
> Dirección elegida por el operador: **"Expediente de ojeador"** (variante AB-1).
> Fuente conceptual: `positioning/positioning.md` + `icp/icp.md`. Alcance: este servicio.
> Colores verificados contra WCAG AA. Aplícalo con la skill `brand-guidelines`.
>
> **Cambio respecto a v1**: se retira el sistema oscuro (ink #0F172A) + verde de marca (#16A34A) +
> badges de semáforo. Motivo (investigación 2026): el verde-sage estaba "sobado", el dark-SaaS ya no
> diferencia, y el badge de color se leía como dashboard corporativo. v1 archivado abajo.

## Esencia (de dónde sale todo)

La marca ES el **cuaderno de campo de un ojeador**: papel, tinta, sellos, anotaciones. No es una app
tech pulida — es un expediente honesto, hecho a mano y medido con software. Traduce el positioning:

| Eje | Qué significa | Cómo se ve |
|---|---|---|
| **Tecnología de club** | rigor, criterio profesional | tipografía serif editorial, retícula de expediente, metadatos en mono |
| **Medido, no opinado** | honestidad como diferencial visible | el **sello** (medido/estimado/no cubierto), no el badge de color |
| **A precio de jugador** | cercano, no elitista, humano | papel cálido, anotación manuscrita, terracota, cero frialdad corporativa |

La honestidad no se declara: se **ve**. Un dato que no se pudo medir lleva un sello discontinuo. Eso
es más creíble que cualquier eslogan.

## Paleta

### Base (papel + tinta — el 90% de la superficie)
| Rol | Nombre | Hex | Uso |
|---|---|---|---|
| Papel | stone-100 | `#F5F1EA` | fondo base de toda pieza |
| Rayado | stone-200 | `#E7E1D5` | líneas tenues de cuaderno (opacidad baja) |
| Grafito | stone-900 | `#1C1917` | titulares, texto principal, bordes de sello |
| Cuerpo | stone-700 | `#57534E` | párrafos, subtítulos |
| Muted | stone-500 | `#78716C` | metadatos, notas secundarias |
| Faint | stone-400 | `#A8A29E` | pie de página, numeración, legales |
| Foto/tarjeta | — | `#FFFFFF` / `#E5DFD2` | fichas de foto, tarjetas |

### Acento (terracota — uno solo, no relleno)
| Rol | Hex | Uso | Contraste sobre papel |
|---|---|---|---|
| **Terracota** | `#C2410C` | línea de margen · "· IA" del wordmark · frase clave en cursiva · subrayado manual | 4.9:1 — **solo texto grande/acentos**, nunca cuerpo pequeño |

> Regla dura: el acento es terracota y **nada más**. No hay segundo color de marca. Para texto pequeño
> siempre grafito (`#1C1917`), nunca terracota (falla AA en tamaño normal).

### Semáforo de honestidad (LA seña de identidad — ahora es SELLO, no badge)
Se dibuja como **etiqueta rectangular con borde grafito 1.5px**, ligeramente rotada (tampón de goma).
El color va en el **texto de la etiqueta**, no en un fondo plano.

| Estado | Hex texto | Ejecución |
|---|---|---|
| 🟢 Medido | `#166534` | sello con borde continuo grafito |
| 🟡 Estimado | `#B45309` | sello con borde continuo grafito |
| ⚪ No cubierto | `#57534E` | sello con **borde discontinuo** (`stroke-dasharray`) — la discontinuidad comunica "falta dato" sin leyenda |

Siempre color **+ etiqueta de texto** (accesible a daltónicos). El "no cubierto" discontinuo es
obligatorio: es el detalle que hace el diferencial legible de un vistazo.

## Tipografía

Sistema de **tres voces** (el contraste entre ellas ES la identidad):
- **Serif editorial** — titulares y la frase clave en cursiva. `Fraunces` / `Instrument Serif` ideal;
  fallback `Georgia, 'Times New Roman', serif`. Da el "rigor de club" y el aire de expediente impreso.
- **Inter** — wordmark, cuerpo/UI, etiquetas de los sellos. `system-ui, 'Segoe UI', sans-serif` fallback.
- **Mono** — metadatos de expediente (`EXPEDIENTE Nº 001`, `TEMP. 2026/27`, pie "regla de la casa").
  `'Courier New', monospace`. Es la "voz de ficha técnica"; usar con moderación, solo datos/sellos.

Escala: Display serif `72–104px` bold · Frase clave serif italic `46–54px` terracota · H2 `28–34px` ·
Cuerpo Inter `16–26px` · Metadatos mono `16–18px`. Titulares `letter-spacing` ligeramente negativo.
Mínimos: cuerpo ≥16px en móvil.

## Lenguaje gráfico (los elementos del expediente)

Recurrentes, no todos en cada pieza — elegir 2-3 por composición:
- **Línea de margen** izquierda en terracota (opacidad ~0.5) — firma estructural, casi siempre presente.
- **Rayado de cuaderno** tenue de fondo (`#E7E1D5`, líneas cada ~46px) — textura base opcional.
- **Taladros** (3 círculos `#EDE7DB` con borde) en el margen — detalle de libreta.
- **Cabecera de expediente**: wordmark + línea fina + `EXPEDIENTE Nº / TEMP.` en mono.
- **Ficha de foto**: rectángulo blanco con clip dibujado + pie en mono (`DORSAL 10 / MC`).
- **Subrayado manual** (trazo curvo terracota) bajo la frase clave en cursiva.
- **Numeración** `pág. X de 7` en serif italic (pie derecho).
- **Firma verbal** al pie en mono: *"si no se pudo medir, se dice — regla de la casa"*.

## Logotipo / wordmark
**Wordmark tipográfico**: `Informe de Jugador` en Inter 600 grafito + `· IA` en terracota 700
(`#C2410C`). Sin símbolo gráfico (MVP). Sobre papel; nunca sobre fondo de color.

## Do / Don't
**Do**
- Papel como base; grafito para texto; terracota como único acento puntual.
- Semáforo siempre como sello con etiqueta; "no cubierto" siempre discontinuo.
- Contraste de las 3 voces tipográficas (serif titular · Inter cuerpo · mono metadatos).
- Elementos de expediente con moderación (2-3 por pieza), no saturar.
- Blanco/aire generoso: el rigor se comunica con calma, no con ruido.

**Don't**
- ❌ Volver al fondo oscuro o al verde de marca (eso es v1, retirado).
- ❌ Terracota en texto pequeño (usa grafito; terracota solo acentos/grande).
- ❌ Segundo color de marca "por alegrar" — la paleta es papel + grafito + terracota + semáforo.
- ❌ Badge de color plano para el semáforo (era el look SaaS que abandonamos).
- ❌ Derivar a "vintage/nostálgico": es un expediente de trabajo actual, no papel envejecido decorativo.
- ❌ Prometer resultados (ficha/prueba): la marca vende material honesto.

## Aplicación en producto
- **Carrusel IG / Reels**: plantilla base = AB-1. Portada de referencia:
  `projects/briefs/informe-jugador-ia/marketing/assets/brand-propuesta-ab1.svg` (1080×1350).
- **Landing**: pendiente re-skin de v1 (dark) a v2 (papel) — tarea separada cuando se despliegue.
- **Share-card (FVI)**: migrar de verde de marca v1 al sistema v2 (papel + sello) — tarea en repo FVI.
- **Informe HTML/PDF**: aplicar semáforo-sello + grafito + serif/Inter.

## Pendiente (para completar v2)
- **Fuentes reales**: instalar/embeber Fraunces (o Instrument Serif) para titulares — hoy fallback Georgia.
- **Assets**: generar wordmark SVG + las 7 slides de la Pieza 1 + portadas de highlights con el sistema v2.
- **Re-skin** de landing y share-card (dependencias visuales de v1).
- **Voz**: `voice/voice-profile.md` sigue vigente (no cambia con el rediseño visual).

---

## ANEXO — v1 (archivado, 2026-07-02 → 2026-07-05)

Sistema original: base oscura ink `#0F172A` + verde de marca `#15803D`/`#16A34A` + semáforo en badges
redondeados (verde `#16A34A` / ámbar `#D97706` / slate `#94A3B8`) + Inter única. Retirado tras la
investigación de tendencias 2026 (verde-sage fatigado, dark-SaaS no diferencia, badge = look dashboard).
El **semáforo como concepto y su semántica (medido/estimado/no cubierto) se conservan** — solo cambia
su ejecución (badge → sello). Positioning e ICP no se vieron afectados.
