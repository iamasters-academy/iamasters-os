# Sistema de marca — Informe de Jugador con IA

> Creado: 2026-07-02 · Sistema visual + verbal del servicio de lanzamiento 2026.
> Fuente: `positioning/positioning.md` + `icp/icp.md`. Alcance: este servicio (no toda la marca del operador).
> Colores verificados contra WCAG AA (4.5:1 texto normal). Aplícalo con la skill `brand-guidelines`.

## Esencia (de dónde sale todo)

| Eje | Qué significa | Cómo se ve/suena |
|---|---|---|
| **Tecnología de club** | serio, profesional, club-grade | base oscura (ink), tipografía neutra, retícula limpia |
| **Medido, no opinado** | honestidad como diferencial visible | el **semáforo medido/estimado/no cubierto** es la seña de identidad |
| **A precio de jugador** | accesible, cercano, no elitista | verde de acción, lenguaje directo en "tú", sin jerga |

La marca NO es "verde de fútbol y ya". Es **rigor de club + honestidad hecha visible**. El verde
es el acento de acción y de "medido ✓"; la seriedad la da el ink oscuro; la confianza, el semáforo.

## Paleta

### Base (neutros — el 90% de la superficie)

| Rol | Nombre | Hex | Uso |
|---|---|---|---|
| Ink | slate-900 | `#0F172A` | titulares, secciones oscuras, footer, logo |
| Body | slate-700 | `#334155` | párrafos |
| Muted | slate-600 | `#475569` | texto secundario (mínimo legible sobre claro: 7:1 ✓) |
| Line | slate-200 | `#E2E8F0` | bordes, separadores |
| Bg | slate-50 | `#F8FAFC` | fondos de sección alternos |
| White | — | `#FFFFFF` | fondo base |

### Marca (verde — acento, no relleno)

| Rol | Nombre | Hex | Uso | Contraste |
|---|---|---|---|---|
| **Verde acción** | green-700 | `#15803D` | **botones/enlaces con texto** (CTA, nav) | blanco encima = **5.0:1 ✓** |
| Verde acento | green-600 | `#16A34A` | acentos GRANDES (span de titular, iconos ≥24px) | 3.3:1 — solo texto grande |
| Verde suave | green-50 | `#F0FDF4` | fondos de píldora/tinte de marca | — |

> ⚠️ Regla dura: **texto o botón pequeño = `green-700`**, nunca `green-600` (falla AA en tamaño normal:
> 3.3:1). El `green-600` es para acentos grandes. Verificado 02/07.

### Semáforo de honestidad (LA seña de identidad — no tocar la semántica)

Es el diferencial del positioning hecho color. Aparece en informes, landing y share-card.

| Estado | Hex | Significado |
|---|---|---|
| 🟢 Medido | `#16A34A` | dato calculado por el software (fiable) |
| 🟡 Estimado | `#D97706` (amber-600) | dato inferido, con su cobertura declarada |
| ⚪ No cubierto | `#94A3B8` (slate-400) | el vídeo no permitió medirlo — se dice, no se inventa |

Siempre color **+ etiqueta de texto** (nunca solo color → accesible para daltónicos).

## Tipografía

- **Familia única**: **Inter** (fallback `system-ui, "Segoe UI", sans-serif`). Neutra, profesional,
  gratis, legible en móvil — donde vive el ICP. Sin fuente display: la seriedad la da el peso, no la floritura.
- **Escala**: Display `text-4xl→6xl` extrabold (hero) · H2 `text-2xl→3xl` bold · Body `text-lg` ·
  Secundario `text-sm`. Interlineado 1.5-1.75 en cuerpo. `letter-spacing:-0.011em` en titulares.
- **Mínimos**: cuerpo ≥16px en móvil; nada por debajo de 14px salvo etiquetas/legales.

## Logotipo

Sin marca gráfica aún (MVP). **Wordmark tipográfico**: `Informe de Jugador` en ink extrabold +
`· IA` en verde acción (`green-700`). Es lo que usa el nav de la landing hoy. Un símbolo (balón/
diana/check) puede venir después; para lanzar, el wordmark basta y es coherente.

## Do / Don't

**Do**
- Ink como base seria; verde como acento puntual de acción/verificado.
- Semáforo siempre con etiqueta de texto.
- Espacio en blanco generoso (rigor = calma visual).
- Iconos SVG (WhatsApp, flechas), nunca emoji en botones/CTAs.

**Don't**
- ❌ Verde `green-600` en texto o botón pequeño (falla contraste → usa `green-700`).
- ❌ Fondos verdes grandes: el verde es acento, no protagonista (protagonista = ink + blanco).
- ❌ Segundo color de marca “por alegrar”: la paleta es ink + verde + semáforo. Nada más.
- ❌ Prometer resultados (ficha/prueba): la marca vende material honesto, no promesas.

## Aplicación en producto

- **Landing**: config Tailwind ya alineada; pendiente fijar el nav CTA a `green-700` (ver revisión 02/07).
- **Share-card (FVI)**: ✅ migrada al verde de marca `#16A34A` (era teal `#0d9488`) — coherente con la
  landing. Contraste sobre ink 5.4:1 (commit `a633ad2`).
- **Informe HTML/PDF**: aplicar semáforo + ink + Inter (ya alineado en gran parte).

## Pendiente (para completar la marca)

- **Voz**: `voice/voice-profile.md` = borrador v0 (de positioning + estilo del operador). Profundizar con
  la skill `marketing-brand-voice` (entrevista/simulaciones) cuando el operador tenga 25 min.
- **Assets**: `assets/` vacío — falta wordmark en SVG + favicon.
