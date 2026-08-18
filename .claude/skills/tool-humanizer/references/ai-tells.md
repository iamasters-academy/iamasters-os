# AI Tells — patrones detectables de escritura AI

> Lista mantenida por la comunidad. Si detectas un nuevo patrón en sesión, append aquí y proponlo en wrap-up.

## Patrones léxicos (palabras y frases)

### Verbos sobreusados
- leverage / aprovechar
- delve into / adentrarse en
- navigate / navegar
- foster / fomentar
- streamline / optimizar
- unlock / desbloquear
- empower / empoderar
- transform / transformar (cuando se usa para todo)
- elevate / elevar
- harness / aprovechar (variante de leverage)

### Sustantivos abstractos
- tapestry
- realm
- landscape (cuando es metafórico)
- ecosystem (cuando se aplica a todo)
- paradigm
- synergy / sinergia
- holistic approach
- value proposition (sobreusado)

### Adjetivos vacíos
- robust / robusto
- seamless / sin fisuras
- comprehensive / completo
- innovative / innovador (cuando no aplica)
- cutting-edge / vanguardista
- state-of-the-art
- world-class
- best-in-class

### Adverbios infladores
- incredibly / increíblemente
- remarkably / notablemente
- surprisingly / sorprendentemente
- arguably / posiblemente
- indeed / ciertamente
- ultimately / en última instancia

### Frases muleta
- "In today's fast-paced world..."
- "In the realm of..."
- "At the end of the day..."
- "It's worth noting that..."
- "It's important to note that..."
- "Needless to say..."
- "When it comes to..."
- "The fact of the matter is..."
- "In conclusion..."
- "To summarize..."
- "Moving forward..."

### En castellano
- "En el mundo actual..."
- "En el mundo de..."
- "Al final del día..."
- "Cabe destacar que..."
- "Es importante señalar que..."
- "Por no mencionar..."
- "Cuando se trata de..."
- "La realidad es que..."
- "En conclusión..."
- "En resumen..."
- "De cara al futuro..."

## Patrones estructurales

### Em-dash overuse (—)
ChatGPT/Claude usan em-dash en lugar de:
- comas
- puntos
- paréntesis
- dos puntos

**Regla**: máx 1 em-dash cada 200 palabras. Más = AI.

### Regla de 3 abusada
"X, Y, and Z" repetido párrafo tras párrafo.

Humanos varían: 2 puntos, 4 puntos, listas no paralelas.

### Negación-afirmación
"It's not X, it's Y. It's not A, it's B."
"No se trata de X, se trata de Y."

Repetir esa estructura 3+ veces en el mismo bloque = AI.

### Frases todas iguales
- Misma longitud (todas 20-25 palabras)
- Mismo arranque (todas pronombres, todas verbo)
- Mismo ritmo (sujeto + verbo + complemento, sin variación)

### Bullet points hipersimétricos
Todos los bullets:
- empiezan con verbo
- tienen exactamente 3 palabras de noun phrase
- terminan en punto sin variación

### Conclusiones obvias
"In conclusion, AI is changing the world."
"En resumen, la IA está transformando todo."

Humanos cierran con anécdota, pregunta o llamada concreta.

## Patrones de tono

### Optimismo unilateral
Todo "transforma", "revoluciona", "empodera". Sin contras, riesgos, limitaciones.

### Hedging excesivo
"Could potentially be considered as one of the possible..."
"Quizás podría ser considerado como una opción..."

3+ hedges en una frase = AI inseguro.

### Sin opinión personal
Frases en pasiva, sin "yo", "creo", "he visto", "me equivoqué".

Humanos meten "yo" cada 100-150 palabras al menos.

### Sin números concretos
"Many companies", "muchos", "varios", "algunos".

Humanos: "47 clientes", "el 23%", "tres veces en marzo".

## Patrones de formato

### Triple emoji
🚀 al inicio + 💡 al medio + ✨ al final = AI por defecto.

Humanos: 0 emojis o 1 emoji intencional.

### Hashtags excesivos
\#AI #MachineLearning #Innovation #FutureTech #Revolution = AI sin filtro.

Humanos: 0-3 hashtags relevantes.

### Listas con bullet point siempre que hay 2+ ítems
"Hay dos opciones:
- Opción A
- Opción B"

vs humano:
"Hay dos opciones: A o B."

### Headings cada 3 frases
Subtítulos forzados que no aportan jerarquía real.

## Patrones específicos de Claude

### "I'd be happy to..."
"Me encantaría ayudarte con..."

Cuando aparece en outputs entregables al cliente final = AI puro (es respuesta de chat, no contenido).

### "Let me know if you need..."
"Déjame saber si necesitas..."

Estructura de chat metida en blog/email donde no debería.

### "Here's a breakdown..."
"Aquí tienes un desglose..."

Conector típico de Claude entre secciones.

## Patrones específicos de GPT

### "It's a great question!"
"¡Es una gran pregunta!"

Validación del usuario en el contenido.

### "Certainly!"
"¡Por supuesto!"

Affirming token al inicio del output.

## Cómo añadir nuevos patrones

Si detectas un patrón AI no listado:

1. Documenta 3+ ejemplos donde aparece
2. Verifica que es predominantemente AI (no aparece en escritura humana frecuente)
3. Append en la categoría apropiada con peso de penalty
4. En wrap-up, propón commit: "feat(humanizer): detect <patrón>"

## Pesos por categoría (para scoring)

| Categoría | Penalty per match |
|---|---:|
| Verbos/sustantivos sobreusados | -0.5 |
| Adjetivos vacíos | -0.5 |
| Adverbios infladores | -0.3 |
| Frases muleta | -1.0 |
| Em-dash overuse | -1.0 (a partir de 2º match) |
| Regla de 3 abusada | -1.5 (si 3+ párrafos seguidos) |
| Negación-afirmación | -1.5 (si 3+ veces) |
| Triple emoji | -2.0 |
| Hashtags excesivos (5+) | -1.0 |
| Conclusión obvia | -1.0 |
