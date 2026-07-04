---
name: finance-variance-analysis
description: Descompone una varianza (real vs esperado/presupuesto) en sus drivers — precio/volumen, tasa/mix — con umbrales de materialidad y narrativa explicativa tipo waterfall. Úsala cuando el operador diga "por qué cambió este resultado", "descompón esta varianza", "analiza mi P&L de trading", "qué mueve mis márgenes" o quiera entender los drivers detrás de un número.
---

# finance-variance-analysis

> **Adaptación iAmasters OS** — Portada de `anthropics/knowledge-work-plugins` (plugin finance, Apache-2.0).
> Standalone (datos pegados; opcional data-warehouse MCP). Puente al OS: **complementa, no solapa** —
> [[startup-business-analyst]] modela el negocio (TAM/proyecciones) y [[statsmodels]]/[[statistical-analysis]]
> hacen inferencia estadística; esta descompone una **varianza** en drivers de negocio con narrativa.
> Encaja con P&L de trading (Polymarket) y unit economics de la consultoría.

## Cuándo se invoca
- El operador dice "por qué cambió este resultado", "descompón esta varianza", "analiza mi P&L de trading", "qué mueve mis márgenes".
- Quiere el porqué detrás de una desviación (real vs presupuesto/periodo anterior/esperado).

## Process

### Paso 1 · Definir la comparación
- Identifica: métrica (ingreso/margen/coste/PnL), baseline (presupuesto, periodo anterior, esperado) y actual. Recoge los datos por componente (precio, volumen, mix…).
- **Validación**: métrica + baseline + actual + componentes disponibles.

### Paso 2 · Descomponer en drivers
- Separa la varianza total en: efecto **precio**, efecto **volumen**, efecto **tasa/mix** (y otros que apliquen). Aplica umbral de materialidad (ignora ruido).
- **Validación**: la suma de los efectos ≈ varianza total (cuadra); drivers materiales aislados.

### Paso 3 · Narrativa + waterfall
- Explica en lenguaje llano qué movió el número y en qué orden (formato waterfall: baseline → +/− cada driver → actual). Señala qué es señal y qué es ruido.
- **Validación**: narrativa que cuadra con los números; drivers ordenados por impacto.

### Paso 4 · Cierre
- Guarda en `projects/finance-variance-analysis/<YYYY-MM-DD>-<caso>/`. Append en `context/learnings.md` bajo `## finance-variance-analysis`.

## Outputs
- Descomposición de la varianza (precio/volumen/mix) + waterfall + narrativa, en la carpeta del proyecto.

## Skills que llama
- **`startup-business-analyst`** — si además hay que modelar/proyectar el negocio.
- **`statsmodels`** / **`statistical-analysis`** — si la pregunta es de significancia estadística, no de descomposición contable.
- **`shap`** — si la "varianza" es de un modelo predictivo (drivers de la predicción).

## Edge cases
- Sin datos por componente → no se puede descomponer; pide el desglose (precio y volumen por separado).
- Varianza dominada por un one-off → sepáralo; no lo mezcles con la tendencia.
- Es contabilidad GAAP formal (asientos/cierre) → fuera de alcance; esto es análisis de drivers, no bookkeeping.

## Examples

Ver `references/examples.md`.
