# finance-variance-analysis — Ejemplos

## Ejemplo 1 · PnL de trading peor de lo esperado

**Operador**: "Este mes el PnL de Polymarket bajó, ¿por qué?"

**Flujo**:
1. Baseline = mes anterior; actual = este mes. Componentes: nº de posiciones (volumen), edge medio
   (precio), mezcla de mercados (mix).
2. Descomposición: −40% por menor volumen (menos operaciones), −10% por peor edge medio, +5% por mix
   hacia mercados más líquidos. La suma cuadra con la caída total.
3. Waterfall + narrativa: "la caída es sobre todo de volumen, no de calidad del edge". Señal vs ruido señalado.

## Ejemplo 2 · Margen de un servicio de consultoría

**Operador**: "Descompón por qué cayó el margen de este servicio."

**Flujo**:
1. Efecto precio (bajé tarifa) vs efecto coste (más horas). Se aísla cada driver.
2. Recomendación conecta con `startup-business-analyst` si hay que re-modelar el pricing.

## Nota

Es descomposición de drivers, no contabilidad GAAP. Si la pregunta es de significancia estadística →
`statsmodels`/`statistical-analysis`; si son drivers de un modelo predictivo → `shap`.
