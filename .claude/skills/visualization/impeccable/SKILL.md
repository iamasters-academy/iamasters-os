---
name: impeccable
description: >
  Lenguaje de diseño anti-slop para que la UI que genera la IA deje de parecer plantilla: detecta
  antipatrones (fuentes sobreusadas, gradientes morados por defecto, bounce easing, sombras genéricas)
  y aplica criterio de diseño con comandos concretos. Úsala cuando el operador diga "esto parece hecho
  por IA", "quita el AI slop", "dale criterio de diseño", "audita el diseño", "pule esta pantalla",
  "hazlo más atrevido/más sobrio", "critica este diseño", o vaya a revisar/mejorar el aspecto de una
  web o app. Complementa a [[ui-ux-pro-max]] (catálogo de estilos) y [[theme-factory]] (temas/paletas):
  impeccable es el DETECTOR de mal gusto + set de ajustes finos. NO la uses para: construir el sistema
  de diseño desde cero (ui-ux-pro-max), aplicar colores/tipografía de marca (brand-guidelines), ni
  lógica de producto. Es diseño visual, no funcionalidad. Basada en pbakaus/impeccable (Apache-2.0).
version: 0.1.0
---

# impeccable — Lenguaje de diseño anti-slop

Adaptación para iAmasters OS del núcleo de **`pbakaus/impeccable`** (Apache-2.0, atribución al autor
original). Se porta la **capa de criterio** (vocabulario + comandos + reglas detectoras); se descartan
la extensión de navegador, los hooks multi-proveedor y el CLI standalone del proyecto original.

Objetivo: dar a la IA un vocabulario compartido y reglas deterministas para producir diseño **variado
y con intención** en vez de la plantilla genérica de siempre ("AI slop").

## Comandos `/impeccable <comando>`

**Setup**
- `init` — infiere el producto y escribe `PRODUCT.md` + `DESIGN.md` en el proyecto (fuente de verdad del criterio de diseño).
- `document` — documenta el sistema de diseño existente.

**Planificar**
- `shape` — define la forma/estructura antes de maquetar.
- `craft` — construye una pieza con criterio desde el brief.

**Revisar**
- `critique` — crítica honesta de una pantalla/URL (qué chirría y por qué).
- `audit` — pasa las reglas detectoras de antipatrones y lista hallazgos.
- `polish` — pulido final (micro-detalles, espaciado, jerarquía).

**Ajustes finos** (empujan un eje concreto sin rehacer)
- `bolder` / `quieter` — sube o baja la intensidad visual.
- `distill` — quita ruido, deja lo esencial.
- `harden` — más contraste/estructura/rigor.
- `animate` — movimiento con criterio (no bounce por defecto).
- `colorize` / `typeset` / `layout` — color, tipografía, composición.
- `delight` — detalle que sorprende sin estorbar.
- `clarify` / `adapt` / `optimize` — legibilidad, adaptación responsive, rendimiento percibido.

## Reglas detectoras de antipatrones (el "audit")

Marca como hallazgo cuando detecte los tells típicos de diseño generado sin criterio:

- **Tipografía por defecto sobreusada** (Inter/Roboto sin intención, pesos planos, escala tipográfica pobre).
- **Gradiente morado/violeta** genérico como recurso por defecto.
- **Bounce easing** y animaciones de librería sin propósito.
- **Sombras genéricas** uniformes (`box-shadow` de plantilla) sin jerarquía de elevación.
- **Bordes redondeados uniformes** aplicados a todo por igual.
- **Espaciado inconsistente** (no hay sistema de spacing).
- **Centrado de todo** por defecto en vez de composición intencional.
- **Emojis como iconografía** en contextos serios.
- **Contraste insuficiente** (cruza con accesibilidad AA).

Cada hallazgo → qué es, por qué es slop, y el ajuste concreto (`bolder`, `typeset`, etc.) para arreglarlo.

## Cómo encaja en el OS

En la cadena de construir web/app: `ui-ux-pro-max` (sistema y estilos) → `theme-factory` (tema/paleta)
→ **`impeccable audit/critique/polish`** (quitar el slop) → `brand-guidelines` (marca) →
`usability-retention-review` (UX). No cargues las skills de diseño todas a la vez; usa impeccable
cuando el problema sea **"parece hecho por IA"**.

## Atribución

Basada en `pbakaus/impeccable`, licencia Apache-2.0. Se conserva el crédito al autor original;
esta es una adaptación de su lenguaje de diseño a las convenciones de iAmasters OS.
