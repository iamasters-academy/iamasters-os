# marketing-viral-radar — Ejemplos

## Ejemplo 1 · Radar semanal de nicho

**Operador**: "¿Qué publico esta semana sobre análisis de vídeo de fútbol?"

**Flujo**:
1. Nicho = analítica de fútbol; fuentes: 5 cuentas IG/TikTok de referencia + r/soccer + Google Trends.
2. Apify saca reels con más engagement reciente; `tool-scrape-router` saca temas al alza en Reddit/Trends.
3. Patrón detectado: formato "1 clip + 1 dato táctico sorprendente" está rindiendo; audio X en tendencia.
4. Salida `radar.md`: 6 recomendaciones (ángulo + formato + gancho + plataforma), p.ej. "Reel 15s:
   heatmap de un jugador + dato contraintuitivo → hook 'esto no lo ves en la TV'". Pasa a
   `marketing-content-strategy`.

## Ejemplo 2 · Descartar viral irrelevante

**Operador**: "Dame tendencias para mi marca de consultoría IA."

**Flujo**:
1. Aparece un trend de baile muy viral → **se descarta** (mucho engagement pero cero encaje con B2B).
2. Se prioriza un formato "antes/después de automatizar una tarea" que sí encaja con el ICP.

## Nota

Señala QUÉ decir ahora (no escribe el contenido: eso es la cadena `content-strategy → copywriting/
video/social`). Viral ≠ relevante: honestidad sobre encaje de marca por encima del vanity.
