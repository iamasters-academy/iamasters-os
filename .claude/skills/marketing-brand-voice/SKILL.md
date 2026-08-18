---
name: marketing-brand-voice
version: 2.0.0
description: Genera el voice profile completo del operador con 3 registros (A formal, B divulgativo, C cercano). Mecánica de doble ruta (artefactos reales o simulación guiada) que captura voz auténtica incluso si el operador no tiene presencia online. Combina interview directa + Firecrawl scraping de URLs públicas + 5 simulaciones por registro. Output a brand-context/voice/ con 8 archivos: voice-profile.md, samples.md, register-{a,b,c}.md, audit-prompt.md, vocabulary.md, installation.md. Lo invoca el onboarding wizard tras la identidad.
---

# marketing-brand-voice · v2.0

## Cambios respecto a v1.0

- **Doble ruta artefactos vs simulación** · por registro · accesible para operadores sin presencia online
- **15 simulaciones reales** (5 por registro) que capturan voz auténtica
- **3 archivos nuevos**: `audit-prompt.md`, `vocabulary.md`, `installation.md`
- Mantiene: Firecrawl auto-scraping, spectrum 0-10, anti-modelo/modelo aspirar, integración OS

## Cuándo se invoca

- `meta-onboarding-wizard` la llama tras configurar identidad básica
- Usuario invoca: "configura mi brand voice", "extrae mi voz", "rehaz el voice profile"
- Cuando se detecta drift en outputs (humanizer baja consistentemente) y se sugiere refinar voice

## Process

### Paso 1 · Detectar inputs disponibles

Pregunta al operador (usa AskUserQuestion):

1. **Web propia / blog**: URL (opcional)
2. **LinkedIn personal**: URL (opcional)
3. **YouTube canal**: URL (opcional, con 5+ vídeos)
4. **Twitter/X**: URL (opcional)
5. **Documentos propios**: ¿tienes copy ya escrito que represente tu voz? (newsletter, post anclado, etc.) Pega o ruta a archivo
6. **Voice profile previo**: ¿tienes ya un voice profile de otro lado? Pega lo que quieras integrar

### Paso 2 · Detección de ruta global *(nuevo en v2)*

Pregunta clave al operador para decidir cómo capturar la voz:

```
¿Eres una persona activa en redes / escribes mucho online (LinkedIn, Instagram, emails, blog, threads en X)?

(a) Sí, escribo mucho y tengo archivo
(b) No, escribo poco o nada online
(c) Mixto · escribo en algunos canales pero no otros
```

Según respuesta:
- **(a) → Ruta artefactos global**: en Paso 4 te pedirá material real para cada registro (apoyado por scraping)
- **(b) → Ruta simulación global**: en Paso 4 hará simulaciones reales por registro · captura voz auténtica
- **(c) → Ruta híbrida**: decide por cada registro según material disponible

Anota la ruta asignada por registro (A, B, C) para usarla en Paso 4.

### Paso 3 · Scrapear URLs (si las hay)

Si en Paso 1 se proporcionaron URLs, invocar `tool-firecrawl-scraper`:
```json
{
  "urls": [...],
  "format": "markdown",
  "extract_assets": true
}
```

Output esperado: contenido markdown + assets en `brand-context/assets/`.

### Paso 4 · Captura por registro · doble ruta *(nuevo en v2)*

Trabaja **un registro cada vez**. Anuncia el bloque, ejecuta la ruta asignada en Paso 2, valida, pasa al siguiente.

---

#### Registro A · Profesional / Formal

Anuncia: *"Empezamos por el registro profesional. Es como hablas cuando representas tu marca o cuando hay un cliente potencial al otro lado: LinkedIn, emails formales, propuestas comerciales."*

**Si Ruta artefactos** (o si Paso 3 ya scrapeó LinkedIn):
- Pide 3-5 posts de LinkedIn (los más representativos, no los virales accidentales)
- Pide 2-3 emails que ha enviado a clientes potenciales
- Pide 1-2 propuestas comerciales o documentos formales

**Si Ruta simulación**:
Lanza las 5 simulaciones de una en una. Espera respuesta antes de pasar a la siguiente:

1. *"Un cliente potencial te escribe por LinkedIn: 'Hola, he visto tu perfil. Trabajamos en un B2B SaaS y queremos integrar IA en nuestro pipeline de ventas. ¿Tienes 20 minutos para que te cuente?' Respóndele."*

2. *"Tienes que mandar un email a un cliente al que le entregaste un proyecto hace 3 meses y no ha vuelto a contratar. Quieres reactivar la relación sin presionar. Escríbelo."*

3. *"Estás escribiendo el primer párrafo de una propuesta comercial. El cliente es una empresa mediana que quiere migrar sus procesos a un sistema agéntico. Escribe el párrafo de apertura."*

4. *"Un post de LinkedIn tipo: vas a explicar por qué la mayoría de las empresas que dicen 'usar IA' en realidad solo usan ChatGPT. 3-5 líneas máximo."*

5. *"Un cliente te pregunta por qué tu propuesta es más cara que la del competidor. Respóndele con calma pero sin justificarte."*

---

#### Registro B · Divulgativo

Anuncia: *"Ahora el registro divulgativo. Es como hablas cuando enseñas, divulgas o creas contenido para audiencia amplia: Reels, captions de Instagram, posts de blog, newsletters, podcasts, YouTube."*

**Si Ruta artefactos** (o si Paso 3 ya scrapeó Instagram/blog):
- 3-5 captions de Instagram
- 1-2 posts de blog (si los hay)
- Transcripciones de Reels/TikToks/Shorts representativos
- 1-2 newsletters propias

**Si Ruta simulación**:

1. *"Tienes 90 segundos para grabar un Reel explicando qué es una skill de IA. Escribe lo que dirías a cámara, sin guion, en tu tono natural."*

2. *"Caption de Instagram para acompañar una foto tuya trabajando. Quieres bajar a tierra qué hace alguien que dice 'soy operador IA'. 4-6 líneas."*

3. *"Empiezas un post de blog titulado 'Por qué el 90% de la gente que dice usar IA en realidad la está usando mal'. Escribe los primeros 3 párrafos."*

4. *"Estás en directo en una clase de tu comunidad. Acabas de mostrar una demo de una skill. Cierra el bloque transitando al siguiente tema."*

5. *"Le explicas a tu cuñado que no tiene ni idea de tecnología qué es Claude Code. Sin jerga, sin condescendencia. 3-4 frases."*

---

#### Registro C · Conversacional / Cercano

Anuncia: *"Último registro. El conversacional. Es como hablas con tu gente cercana: WhatsApp con amigos, DMs, notas de voz, mensajes a tu equipo. Aquí sale tu voz más auténtica."*

**Si Ruta artefactos**:
- 5-8 mensajes de WhatsApp con amigos cercanos (anonimízalos si hace falta, NO los reformules)
- Transcripciones de notas de voz que manda
- DMs de Instagram con gente con confianza

⚠️ Importante: NO pides mensajes que el operador quiera mantener privados. Si duda, mejor ruta simulación.

**Si Ruta simulación**:

1. *"Un amigo te escribe a las 22h: 'tio acabo de ver tu directo, me ha flipado. cuéntame qué hago para empezar'. Respóndele."*

2. *"Estás en un grupo de WhatsApp de amigos. Sale el tema 'la IA va a quitar todos los trabajos'. Mete tu opinión en 2-3 mensajes."*

3. *"Le mandas una nota de voz a tu socio explicándole rápido por qué cambiaste de opinión sobre un cliente. Transcríbela como si la estuvieras hablando."*

4. *"Un amigo te pregunta por WhatsApp si vale la pena montar una agencia de IA ahora. Respondes lo que piensas de verdad."*

5. *"Le escribes a alguien que admiras (un creador, un referente) por DM de Instagram para tomaros un café. Sin parecer fanboy."*

---

### Paso 5 · 6 preguntas calibradoras

Independientemente de URLs y de la ruta de Paso 4, hacer 6 preguntas adicionales que capturan dimensiones que las simulaciones no cubren bien:

**Pregunta 1 · Tono dominante** (multi-select):
- (a) Formal y autoridad — propuesta corporativa
- (b) Divulgativo profesional — explicas con claridad sin ser corporate
- (c) Cercano y directo — como hablas con un amigo
- (d) Provocador — opiniones fuertes, sin miedo a ofender
- (e) Cálido y empático — humano, vulnerable
- (f) Técnico y específico — datos, números, precisión

**Pregunta 2 · Vocabulario del que huyes** (texto libre):
- "¿Qué palabras nunca usas porque suenan a corporate / a vendehumos / a AI?"

**Pregunta 3 · Frases-firma** (texto libre):
- "¿Hay frases que repites mucho y son tuyas? Dame 2-3"

**Pregunta 4 · Jerga propia** (texto libre):
- "¿Tienes términos propios o de tu nicho que uses constantemente? (ej. 'operador IA', 'aterrizar el sistema', 'no-fluff')"

**Pregunta 5 · Anti-modelos** (texto libre):
- "Dime una cuenta de LinkedIn / un creador / un autor cuyo tono ODIES. (Para evitarlo)"

**Pregunta 6 · Modelo a aspirar** (texto libre):
- "Dime una cuenta / autor / podcaster con un tono parecido al que quieres tener"

### Paso 6 · Análisis combinado

Combinar todas las fuentes:
- Texto scrapeado de URLs (si hubo)
- Material de artefactos (si ruta A)
- Respuestas a las 15 simulaciones (si ruta B o mixto)
- Respuestas de 6 preguntas calibradoras
- Voice profile previo (si proporcionó)

Extraer:

**Personalidad** (3-5 traits):
- ¿Es seguro / inseguro? ¿Optimista / cauto? ¿Concreto / abstracto? ¿Cálido / frío?

**Tono spectrum** (cuantificado 0-10):
- Formality: 0 (cercano) — 10 (formal)
- Directness: 0 (rodeos) — 10 (sin rodeos)
- Humor: 0 (serio) — 10 (mucho humor)
- Authority: 0 (humilde) — 10 (afirmativo)
- Warmth: 0 (distante) — 10 (cercano)

**Vocabulario**:
- Palabras-firma (las que aparecen ≥3 veces en samples scrapeados/simulaciones)
- Palabras prohibidas (de pregunta 2 + AI tells del humanizer + las que NUNCA aparecieron en simulaciones de su registro pero sí en patrones de IA)
- Jerga propia (de pregunta 4)
- Muletillas auténticas (palabras que repite muchas veces y son parte de su firma)

**Estructura típica** por registro:
- Longitud media de frase
- Uso de listas vs prosa
- Posición de la opinión (al inicio? al final? entrelazada?)
- Cómo abre / cómo cierra

### Paso 7 · Validación intermedia

ANTES de generar los 8 archivos, devolver al operador un análisis breve:

```
Tengo material de los 3 registros y las 6 preguntas. Antes de generar el voice-profile final, te devuelvo lo que detecto. Confírmame si te encaja:

**Registro Profesional (A):**
- Tono: [una frase descriptiva]
- Estructura típica: [cómo abre, desarrolla, cierra]
- Palabras/frases recurrentes: [3-5 ejemplos extraídos del material]
- Lo que NO haces: [2-3 cosas que evitas]

**Registro Divulgativo (B):** [mismo formato]
**Registro Conversacional (C):** [mismo formato]

**Spectrum global:**
- Formality: X/10
- Directness: X/10
- Humor: X/10
- Authority: X/10
- Warmth: X/10

¿Te suena? ¿Hay algo que matizar o corregir antes de que genere los archivos finales?
```

Espera confirmación o corrección. Si el usuario corrige, integra. Si dice "perfecto", pasa a Paso 8.

### Paso 8 · Generación de output · 8 archivos

#### 8.1 · `voice-profile.md`

```markdown
# Voice Profile — [Nombre operador]

> Generado: YYYY-MM-DD · v2 (doble ruta)
> Fuentes: web + LinkedIn + 15 simulaciones + 6 preguntas calibradoras
> Ruta usada: artefactos / simulación / mixto

## Personalidad
- Trait 1
- Trait 2
- Trait 3

## Tono spectrum
- Formality: X/10
- Directness: X/10
- Humor: X/10
- Authority: X/10
- Warmth: X/10

## Palabras-firma (uso frecuente, marcan voz)
- ...

## Vocabulario prohibido (nunca usar)
- ...

## Jerga propia (términos del nicho que uso natural)
- ...

## Muletillas auténticas (NO eliminarlas, son parte de mi marca)
- ...

## Estructura típica por registro
**Registro A (Profesional):**
- Longitud media de frase: X palabras
- Listas vs prosa: 60/40 prosa
- Opinión: al inicio del bloque
- Cierre: pregunta abierta o llamada concreta

**Registro B (Divulgativo):** [...]
**Registro C (Conversacional):** [...]

## Anti-modelo
- "No quiero sonar como [creador X], cuyo tono es [Y]"

## Modelo a aspirar
- "Tono parecido a [creador Z], cuya virtud es [W]"
```

#### 8.2 · `samples.md`

10-15 frases representativas:
- 5 de inputs scrapeados o artefactos (extraídas con criterio · no genéricas)
- 5 de las 15 simulaciones (las más auténticas)
- 5 sintéticas siguiendo el voice profile (para validar internamente)

#### 8.3 · `register-a-formal.md`

```markdown
# Registro A · Formal

## Cuándo usarlo
- Email a cliente premium o C-level
- Propuesta comercial
- Contrato o documento legal
- Pitch a inversor

## Reglas
- Frases largas y bien construidas (15-25 palabras)
- Vocabulario preciso, sin jerga
- Cero emojis
- Sin abreviaturas

## Vocabulario permitido
[lista del voice-profile aplicada]

## Vocabulario prohibido en este registro
[palabras del voice-profile que NO aplican aquí]

## Plantilla email cliente
[rellena según voice-profile + reglas formales]

## Ejemplo (de las simulaciones o samples)
[Frase del operador adaptada a tono formal]
```

#### 8.4 · `register-b-divulgativo.md`

```markdown
# Registro B · Divulgativo

## Cuándo usarlo
- LinkedIn post / artículo
- Blog post
- Video script (YouTube, talk)
- Newsletter (cuerpo)
- Twitter thread (largos)

## Reglas
- Frases mixtas (10-20 palabras), variar ritmo
- Lenguaje claro, sin jerga innecesaria pero con jerga propia OK
- 0-2 emojis intencionales máximo
- Apoyarse en números concretos

## Estructura típica para LinkedIn post
1. Hook (1-2 frases contundentes)
2. Contexto personal
3. Insight (la lección)
4. Detalle concreto
5. Pregunta o llamada al final

## Ejemplo (rebuild de samples del operador)
[Sample del voice-profile reescrito en B]
```

#### 8.5 · `register-c-cercano.md`

```markdown
# Registro C · Cercano

## Cuándo usarlo
- WhatsApp grupo comunidad
- Respuestas a comentarios en LinkedIn/Instagram
- DMs a leads cálidos
- Mensajes Slack a equipo
- Captions cortas en stories

## Reglas
- Frases cortas (5-12 palabras)
- Tono coloquial, contracciones permitidas
- 1-3 emojis OK si son relevantes
- Tuteo siempre

## Vocabulario permitido
[palabras-firma + slang propio + casual]

## Ejemplo
[Una de las simulaciones del registro C del operador]
```

#### 8.6 · `audit-prompt.md` *(nuevo en v2)*

```markdown
# Audit Prompt — Brand Voice Checker

Prompt sistema para auditar si un texto está en tu voz o no.

## Cómo usarlo

Pégalo como instrucción de sistema (Claude Project, ChatGPT GEM, instrucción inicial) acompañado de tu `voice-profile.md`. Después pásale cualquier texto a auditar.

## Prompt

Eres un auditor de voz de [Nombre del operador]. Tu única misión es verificar si un texto está escrito en la voz de [Nombre], y en qué registro (A profesional / B divulgativo / C conversacional).

Procedimiento:
1. Lee el voice-profile.md adjunto.
2. Lee el texto a auditar.
3. Identifica el registro probable según el contexto (LinkedIn = A, Reel = B, WhatsApp = C).
4. Audita en 4 dimensiones:
   - Tono (¿coincide con el registro?)
   - Estructura (¿usa la estructura típica del registro?)
   - Vocabulario (¿usa palabras-firma? ¿usa anti-vocabulario?)
   - Spectrum 0-10 (¿se ajusta a los valores del operador?)
5. Da una puntuación de 0 a 10 por dimensión.
6. Marca con ✗ las palabras/frases que son anti-voz y propón sustitución concreta.
7. Devuelve una versión corregida solo si la puntuación general es < 7.

Output formato:
- Registro detectado: [A/B/C]
- Puntuación general: X/10
- Desglose por dimensión: T:X E:X V:X S:X
- Anti-voz detectada: [lista con sustituciones]
- Versión corregida: [solo si <7]
```

#### 8.7 · `vocabulary.md` *(nuevo en v2)*

```markdown
# Vocabulary · [Nombre operador]

## Palabras y frases que SÍ usas

### Registro A · Profesional
- [palabra] — contexto: [ejemplo de uso]
- [10-15 entradas]

### Registro B · Divulgativo
- [10-15 entradas]

### Registro C · Conversacional
- [10-15 entradas]

## Palabras y frases que NUNCA usas (anti-vocabulario)

### Anti-corporate (no en A)
- "Estimado/a", "Cordialmente", "Quedo a su disposición"
- [palabras detectadas del análisis]

### Anti-hype (no en B)
- "Game changer", "Revolucionario"
- [específicos según análisis]

### Anti-genérico de IA (no en ningún registro)
- "No solo X sino también Y"
- "En el mundo actual..."
- [otros AI tells del humanizer]

## Muletillas auténticas

Palabras/frases que repites mucho de forma natural. NO eliminarlas · son parte de tu marca:
- [Muletilla 1]
- [3-5 más]
```

#### 8.8 · `installation.md` *(nuevo en v2)*

```markdown
# Cómo instalar tu Voice Profile en cualquier sistema

## Opción 1 · iAmasters OS (este repo)

Ya está instalado. Las skills `marketing-*` lo usan automáticamente al iniciar sesión.

## Opción 2 · Claude (Claude Desktop o claude.ai)

1. Crea un Project nuevo o edita el actual
2. En "Project Instructions" pega el contenido de `voice-profile.md`
3. Añade al final: "Antes de responder a cualquier prompt, escribe en el registro indicado del voice-profile. Si no se indica registro, pregunta cuál usar."

## Opción 3 · ChatGPT GEM

1. ChatGPT → "Crear un GEM"
2. Nombre: "Mi voz · [Tu nombre]"
3. Instrucciones: pega `voice-profile.md`
4. Knowledge: sube `voice-profile.md` + `vocabulary.md`
5. Conversation starters: "Escribe en mi registro A", "Audita este texto con mi voz"

## Opción 4 · Cualquier LLM

Al inicio de cada sesión, pega:

> Aquí está mi voice profile. Léelo. Todo lo que generes a continuación debe estar en uno de mis 3 registros. Si no sé cuál usar, pregúntame.
> [contenido de voice-profile.md]

## Mantenimiento

- Cada 3 meses revisa tu voice-profile.md. Tu voz evoluciona.
- Si haces cambios grandes (nueva línea de negocio, cambio de tono), re-ejecuta `marketing-brand-voice`.
- El `audit-prompt.md` te sirve para verificar outputs sospechosos. Úsalo cuando un output "no te suene a ti".
```

### Paso 9 · Cierre integrado con OS

- Output guardado en `brand-context/voice/`:
  - voice-profile.md
  - samples.md
  - register-a-formal.md
  - register-b-divulgativo.md
  - register-c-cercano.md
  - audit-prompt.md
  - vocabulary.md
  - installation.md
- Plus assets en `brand-context/assets/` (si Firecrawl extrajo)
- Append en `context/learnings.md`:
  ```
  ## marketing-brand-voice
  - YYYY-MM-DD: voice profile v2 generado. Ruta usada: <artefactos|simulación|mixto>. Reto principal: <X>. Aprender: <Y>.
  ```
- Update `~/.claude/skills/_operator-state.json` con flag `brandVoiceConfigured: true`

## Outputs

8 archivos en `brand-context/voice/`:
- voice-profile.md
- samples.md
- register-a-formal.md
- register-b-divulgativo.md
- register-c-cercano.md
- **audit-prompt.md** *(v2 NEW)*
- **vocabulary.md** *(v2 NEW)*
- **installation.md** *(v2 NEW)*

Plus assets en `brand-context/assets/` (si Firecrawl extrajo).

## Skills que llama

- `tool-firecrawl-scraper` — para scrapear URLs públicas (paso 3)

## Edge cases

- **Operador no tiene presencia online (común)**: usar Ruta simulación global. Las 15 simulaciones capturan voz tan bien o mejor que el material online porque las respuestas son espontáneas y auténticas.
- **Operador no quiere dar URLs ni simulación larga**: hacer Ruta simulación reducida (1-2 simulaciones por registro = 6 simulaciones totales). Generar voice profile con disclaimers ("low confidence, refine cuando tengas más datos").
- **URLs no scrapeables (login required)**: pedir al operador que copie/pegue 3-5 posts representativos.
- **Operador en idioma no castellano/inglés**: detectar y avisar — el flujo funciona pero la calidad de detección de patrones es menor.
- **Voice cambia mucho entre canales** (LinkedIn formal vs Instagram casual): generar 2 voice-profiles separados (`voice-profile-pro.md`, `voice-profile-personal.md`) y advertir al operador que las skills marketing-* preguntarán cuál usar.
- **Operador idealiza sus respuestas en simulaciones** (responde "como debería ser" en vez de "como soy"): el Paso 7 (validación intermedia) lo detecta. Si el operador dice "esto no soy yo", reformular preguntas de simulación pidiéndole respuestas más auténticas ("respóndeme como lo harías de verdad un sábado a las 23h, no como te gustaría sonar").

## Examples

Ver `references/examples.md` para 3 casos:
1. Operador con LinkedIn pro + blog → voice profile robusto con ruta artefactos + 3 registers diferenciados
2. Operador sin presencia online → ruta simulación 100%, voice profile auténtico
3. Operador mixto (LinkedIn sí, Instagram no) → ruta híbrida, registro A con artefactos + registro C con simulación
