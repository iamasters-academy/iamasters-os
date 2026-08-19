---
name: marketing-positioning
description: Construye o refina el posicionamiento del operador. Analiza competidores (con tool-firecrawl-scraper), identifica hueco de mercado, propone 3-5 ángulos de posicionamiento y deja al operador elegir. Output a brand-context/positioning/positioning.md. Se invoca tras brand-voice o cuando el operador siente que el mensaje no diferencia.
---

# marketing-positioning

## Cuándo se invoca

- Tras `marketing-brand-voice` en el flujo de onboarding
- Operador dice: "no diferencio bien", "todos dicen lo mismo que yo", "ayúdame a posicionarme"
- Cambio de mercado o lanzamiento de producto nuevo

## Process

### Paso 1 · Recopilar inputs

Si NO existe `brand-context/positioning/positioning.md`:
- Modo: construcción desde cero

Si existe pero el operador pidió refinarlo:
- Leer el actual y modo: refinamiento

Pregunta al operador (4-5 preguntas):

1. **¿Qué problema resuelves?** (1 frase, claro)
2. **¿Para quién exactamente?** (perfil del cliente, no "todos")
3. **¿Qué alternativas tienen ya?** (otras soluciones, agencias, productos, DIY)
4. **¿Qué haces tú diferente?** (sin "es que somos los mejores")
5. **¿Cuál es tu unfair advantage?** (algo que solo tú o pocos tienen)

### Paso 2 · Investigar competidores (opcional)

Pregunta: "¿Tienes 3-5 competidores cuyas webs analicemos?"

Si sí:
- Invoca `tool-firecrawl-scraper` con sus URLs
- Extraer su positioning declarado: hero headline, sub-headline, "for who" sections
- Analizar patrones repetidos (ej. "todos dicen 'la solución todo-en-uno'")

Si no:
- Saltar a Paso 3 con la info que tengas del operador

### Paso 3 · Análisis del hueco

Construir matriz de positioning:

```
                Generic                    Specialized
                |                          |
Tech-heavy  ----+--------------------------+----
                |                          |
                | (competidor A)           |
                |                          |
Human-heavy ----+--------------------------+----
                |                          |
                | (competidor B)           | (TÚ)
                |                          |
```

Identificar: ¿dónde están todos? ¿dónde hay hueco? ¿dónde puedes tú estar coherentemente con tu voice + advantage?

### Paso 4 · Generar 3-5 ángulos

Para cada ángulo:

**Estructura del ángulo**:
- **Headline statement** (1 frase): "Para [ICP], [tu marca] es [categoría] que [diferencial], a diferencia de [competidor genérico]."
- **Por qué este ángulo funciona**: (2-3 razones basadas en análisis)
- **Riesgos de este ángulo**: (qué te encierra, qué clientes pierdes)
- **Evidencia**: ¿qué del operador apoya este ángulo? (su experiencia, sus skills, sus casos)

Ejemplo de ángulos para un operador IA freelancer:

**Ángulo 1 — Anti-vendehumos práctico**:
> "Para empresarios de pyme que han probado IA y se han quemado, soy el operador que monta sistemas que sí aterrizan, sin demos espectaculares y con métricas reales de ahorro."

**Ángulo 2 — IA + procesos, no IA suelta**:
> "Para gestoría/agencia que automatiza tareas pero no procesos completos, soy quien entra dentro de la operativa y monta agentes que sustituyen al becario que no tienen."

**Ángulo 3 — La voz castellana de Claude Code**:
> "Para operadores hispanohablantes que aprenden Claude Code en inglés y se pierden, soy el primer recurso completo en castellano con casos reales de comunidad."

### Paso 5 · Recomendación + decisión del operador

Mostrar los 3-5 ángulos al operador con análisis. Recomendar 1 o 2 con justificación clara.

Preguntar: "¿Con cuál te quedas? ¿O quieres mezclar dos?"

Si el operador no decide: ofrecer hacer un mini test (escribir 1 LinkedIn post en cada ángulo y ver cuál le sale más natural / le encaja mejor con la voz).

### Paso 6 · Generar `positioning.md`

```markdown
# Positioning — [Marca]

> Generado: YYYY-MM-DD
> Última revisión: YYYY-MM-DD

## Statement principal

> Para [ICP], [marca] es [categoría] que [diferencial], a diferencia de [alternativa].

## Para quién (ICP en una frase)

[ICP statement compacto. La definición completa está en brand-context/icp/icp.md]

## Categoría

[En qué casilla mental quieres que te metan: ej. "operador IA freelance especialista en gestorías" no "consultoría de IA"]

## Diferencial

[2-3 cosas concretas, verificables, que te distinguen]

1. ...
2. ...
3.

## Alternativas que tu cliente considera

| Alternativa | Por qué no funciona para él |
|---|---|
| Agencia grande de IA | Demasiado caro, demos sin aterrizar, no entiende su sector |
| Becario con ChatGPT | No escala, no integra con sus apps, no garantiza calidad |
| DIY (lo hacemos nosotros) | Sin tiempo, sin expertise, no hay quién lo mantenga |

## Tu unfair advantage

[Lo que solo tú o muy pocos tenéis. Puede ser experiencia, network, asset, capacidad técnica + comercial juntas, idioma, vertical específico]

## Mensaje en 3 longitudes

### Long (LinkedIn about, web hero, propuesta)
[2-3 frases con el statement + advantage + por qué confiar]

### Mid (X bio, email signature, intro de podcast)
[1 frase con el statement compacto]

### Short (tagline, slug)
["[Categoría] para [ICP-clave]"]

## Riesgos del posicionamiento elegido

- ¿Qué clientes potenciales pierdes con este ángulo? (válido, focalizar tiene coste)
- ¿Qué pasa si tu mercado cambia? (plan B)
- ¿Qué te encierra?

## Cuándo revisar

- Cada 6 meses (revisión rutinaria)
- Cuando aparezca competidor nuevo que copie tu ángulo
- Cuando tu mercado se mueva (M&A, regulación, nueva tecnología)
- Cuando sientas que el mensaje no resuena (engagement cae sin causa)
```

### Paso 7 · Cierre

- Guardar `brand-context/positioning/positioning.md`
- Append en `context/learnings.md`:
  ```
  ## marketing-positioning
  - YYYY-MM-DD: ángulo elegido X. Riesgos identificados: Y.
  ```
- Sugerir al operador re-revisar `brand-context/icp/icp.md` (si no encaja con nuevo positioning, hay desalineación)
- Sugerir actualizar bio/about en LinkedIn/web con el mensaje en sus 3 longitudes (no hacerlo automático — eso es comunicación externa)

## Outputs

- `brand-context/positioning/positioning.md`
- Append a `context/learnings.md`

## Skills que llama

- `tool-firecrawl-scraper` (opcional, paso 2)

## Edge cases

- **Operador no quiere "encerrarse"**: explicar que no posicionarse es posicionarse mal. Si insiste, generar positioning más amplio con disclaimer "low differentiation, expect higher CAC".
- **Mercado super saturado**: el ángulo viable suele ser hyper-niche. Forzar concretar el ICP a un sub-vertical específico.
- **Operador es tech bueno pero comm malo**: el positioning correcto puede ser "white-label tech para agencias", no servir a clientes finales.
- **Operador es solo bueno en una vertical**: positioning vertical-first ("Operador IA para clínicas dentales") es legítimo y suele convertir mejor que horizontal.

## Examples

Ver `references/examples.md` para 3 casos completos.
