---
name: design-taste-frontend
description: >
  Framework anti-slop para frontend: lee el brief y entrega webs/apps con criterio que no parecen
  plantilla, ajustando tres diales (variación de diseño, intensidad de movimiento, densidad visual).
  Úsala cuando el operador diga "hazme un frontend con gusto", "que no parezca plantilla", "dale más
  carácter/movimiento", "más denso/más aireado", "diséñame esta landing con criterio", o vaya a
  maquetar una web/app y quiera control fino del estilo antes de picar código. Framework-agnostic
  (React/Vue/Svelte). Complementa a [[ui-ux-pro-max]] (catálogo de +60 estilos) y [[impeccable]]
  (detector de antipatrones): esta aporta los DIALES y skeletons de animación. NO la uses para:
  lógica de backend/negocio, aplicar identidad de marca concreta (brand-guidelines), ni auditar UX de
  retención (usability-retention-review). Basada en Leonxlnx/taste-skill.
version: 0.1.0
---

# design-taste-frontend — Frontend con criterio

Adaptación para iAmasters OS de **`Leonxlnx/taste-skill`**. Evita que el frontend generado por IA
parezca genérico aplicando estrategias de layout, tipografía, motion y espaciado más fuertes, con
control explícito mediante tres diales.

## Los 3 diales (1-10)

Se fijan al inicio, según el brief y el tono de la marca:

- **DESIGN_VARIANCE** — experimentación del layout. `1-3` centrado/limpio/seguro · `4-7` moderno con
  asimetrías controladas · `8-10` editorial/atrevido/asimétrico.
- **MOTION_INTENSITY** — profundidad de la animación. `1-3` solo hovers · `4-7` transiciones y scroll
  reveals · `8-10` scroll-driven, magnético, parallax con criterio (nunca bounce por defecto).
- **VISUAL_DENSITY** — densidad de información. `1-3` espacioso/landing · `4-7` equilibrado ·
  `8-10` dashboard denso.

Declara los tres valores elegidos antes de construir, y justifícalos en una línea.

## Protocolo

1. **Brief inference** — deduce producto, audiencia y tono del brief (o pregunta lo mínimo si falta).
2. **Design-system map** — define tokens: escala tipográfica, spacing, color, elevación, radios —
   coherentes con los diales. Un sistema, no decisiones sueltas.
3. **Pre-flight check** — antes de escribir código, confirma: diales fijados, tokens definidos,
   framework objetivo, referencias de estilo.
4. **Build** — maqueta usando el sistema; sin valores mágicos sueltos.
5. **Redesign-audit** — si es rediseño, audita lo existente y lista qué cambia y por qué.

## Reglas duras

- **Ban del em-dash** en la copy generada (tell de IA); usa alternativas.
- **Skeletons GSAP canónicos** para el motion (código de animación consistente y reutilizable, no
  ad-hoc por componente).
- **Sin plantilla por defecto**: nada de gradiente morado + Inter + sombras genéricas (cruza con
  [[impeccable]] `audit`).
- **Tokens antes que valores**: todo color/spacing/tipo sale del design-system map.

## Cómo encaja en el OS

Cadena de construir web/app: `ask-questions-if-underspecified` → `ui-ux-pro-max` →
**`design-taste-frontend`** (diales + tokens + motion) → `impeccable` (quitar slop) → `theme-factory`
→ `brand-guidelines`. Usa esta cuando quieras **control fino del carácter** del frontend antes de
maquetar. No cargues todas las skills de diseño a la vez.

## Atribución

Basada en `Leonxlnx/taste-skill`, adaptada a las convenciones de iAmasters OS.
