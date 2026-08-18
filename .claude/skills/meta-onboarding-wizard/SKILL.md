---
name: meta-onboarding-wizard
description: Lanza el onboarding inicial cuando un operador instala iAmasters OS por primera vez. NO es un formulario — es una entrevista conversacional adaptativa que cubre 8 dimensiones críticas (identidad, negocio, foco, objetivos). v0.6 CRÍTICO -- la entrevista está dividida en 4 sub-fases con COMMITS INCREMENTALES después de cada una, y actualiza ~/.claude/skills/_install-state.json. Si el usuario abandona a mitad, el progreso queda persistido y la siguiente sesión retoma exactamente donde se quedó (gracias al install-gate hook).
---

# meta-onboarding-wizard

> **Filosofía**: esto NO es un formulario con 15 preguntas predefinidas. Es una entrevista conversacional. Las preguntas concretas las decide el agente en cada turno, según la respuesta anterior. Lo que está fijo son las **dimensiones a cubrir** y las **reglas de profundización**.
>
> **CRÍTICO v0.6** — La entrevista está dividida en 4 sub-fases. Después de cada sub-fase escribes el archivo correspondiente Y actualizas `~/.claude/skills/_install-state.json`. NUNCA esperes al final para escribir nada. Si el usuario se cansa o se va, lo que ya está capturado queda persistido.

## Cuándo se invoca

- El hook `_install-gate.sh` detecta `phases.context-files.status != "done"` y guía al usuario hacia aquí
- El usuario ejecuta `/install --resume` y la fase activa es `context-files` u `operator-state`
- El usuario pide explícitamente "vuelve a hacerme el onboarding" o "rehacer onboarding"

NO se invoca cuando:
- `phases.context-files.status == "done"` Y `phases.operator-state.status == "done"` en el state
- Hay daily summary del día anterior (continuidad normal, ir a `meta-start-here`)

## Las 8 dimensiones críticas que TIENE que capturar

Lee también [`references/dimensiones-express.md`](references/dimensiones-express.md) para el detalle de qué información concreta debe quedar en cada una.

| # | Dimensión | Sub-fase del wizard | Archivo destino |
|:--|---|---|---|
| 1 | Identidad (nombre + 1 frase pro) | **W1 · Identidad** | `context/me.md` |
| 2 | Ubicación + idioma | **W1 · Identidad** | `context/me.md` |
| 3 | Negocio principal | **W2 · Negocio** | `context/work.md` |
| 4 | Modelo de ingresos | **W2 · Negocio** | `context/work.md` |
| 5 | Cliente ideal | **W2 · Negocio** | `context/work.md` |
| 6 | Stack diario | **W2 · Negocio** | `context/work.md` |
| 7 | Foco del mes | **W3 · Foco** | `context/current-priorities.md` |
| 8 | Objetivo 12 meses | **W3 · Foco** | `context/goals.md` |
| — | Config técnica (nivel, idioma outputs, Firecrawl) | **W4 · Config** | `~/.claude/skills/_operator-state.json` |

**Definición de "done" por sub-fase**: cada sub-fase tiene un archivo correspondiente que debe quedar escrito con contenido real (no plantilla vacía, no placeholders). Mínimo 100 caracteres de contenido útil.

**Tiempo objetivo total**: 10-12 minutos. Si tarda más, algo va mal con la profundización.

## Reglas de profundización

Las preguntas concretas las decide el agente en cada turno. Para cada respuesta del usuario, aplica estas reglas:

### Señales que piden profundizar (haz 1 follow-up, no más)

| Señal en la respuesta | Movimiento |
|---|---|
| Menos de 15 palabras en una dimensión clave | "Cuéntame más" o pide ejemplo concreto |
| Cifra sin contexto ("facturo 30K") | Pregunta tendencia o ticket medio |
| Adjetivo abstracto ("cliente difícil") | Pide ejemplo de la última semana |
| Generalidad sin sustancia ("ayudo a la gente") | Reformula: "¿gente cómo? Píntame al cliente perfecto" |
| Contradicción aparente entre respuestas | Pide clarificación 1 línea, sin juicio |

### Señales que piden NO profundizar (pasa a la siguiente dimensión)

| Señal | Movimiento |
|---|---|
| Respuesta rica y completa (>50 palabras con datos concretos) | Salta a siguiente. No insistas |
| Usuario dice "no sé", "todavía no", "después" | Acepta. Apunta "(por definir)" y propón skill concreta |
| Respuestas cortas seguidas (3+ turnos) | Señal de fatiga. Acelera, salta dimensiones con dato mínimo |
| Usuario muestra urgencia ("siguiente", "ya está") | Respeta. Cierra la sub-fase actual y commit |

## Anti-formulario (prohibido explícitamente)

- ❌ Decir "pregunta 3 de 10" o cualquier numeración visible
- ❌ Anunciar la siguiente pregunta antes de hacerla
- ❌ Hacer 2 preguntas en el mismo turno (excepto apertura: "¿cómo te llamas y dónde vives?")
- ❌ Listas de bullets en TUS respuestas durante la entrevista (solo en cierres)
- ❌ Repetir literalmente la respuesta del usuario "para confirmar"
- ❌ Anunciar "ahora pasamos a W2" — las sub-fases son interna del wizard, NO del usuario
- ❌ Usar emojis durante la entrevista (sí en cierres)

---

## Process — 4 sub-fases con commits incrementales

### Antes de empezar: lectura de estado

Al ser invocado, **antes** de saludar al usuario:

1. Lee `~/.claude/skills/_install-state.json` con la tool `Read`.
2. Localiza `phases.context-files.filesCreated` — esto te dice qué archivos ya están escritos de una sesión anterior.
3. Identifica la sub-fase pendiente:
   - Si `context/me.md` no está en filesCreated → empezar en W1
   - Si `me.md` sí pero `work.md` no → empezar en W2 (saluda diciendo "Sigamos donde lo dejamos. Ya sé tu nombre y dónde estás. Ahora cuéntame de tu negocio...")
   - Si `me.md` y `work.md` están pero faltan `current-priorities.md` o `goals.md` → empezar en W3
   - Si los 4 archivos de context están pero `operator-state.status != "done"` → empezar en W4

**Si retomas a mitad, NO repitas la apertura completa**. Solo di "Sigamos. Ya tenemos X. Vamos con Y."

### W1 · Identidad (dimensiones 1-2)

**Apertura** (solo si no estás retomando):
```
Bienvenido a iAmasters OS.

Antes de generarte nada, necesito conocerte un poco. No es un
formulario — es una conversación rápida. Te pregunto, me cuentas,
y si algo me parece interesante te pido más detalle.

Tarda ~10 minutos y solo se hace una vez. Lo bueno: si te interrumpes,
retomamos exactamente donde lo dejaste, no se pierde nada.

¿Empezamos? Dime tu nombre y dónde vives.
```

Captura nombre + ubicación + idioma operativo. Si faltó algo, pregunta UN follow-up.

**Cuando tengas dimensiones 1+2 con dato sólido:**

1. **COMMIT inmediato**: escribe `context/me.md` con la tool `Write`:
   ```markdown
   # me.md — quien soy

   ## Nombre
   <nombre>

   ## Ubicación
   <ciudad, país>

   ## Idioma operativo
   <idioma>

   ## Frase pro (descripción profesional en 1 frase)
   <si la dio, va aquí; si no, escribe "(por definir — el wizard insistirá en W4 si toca)">

   ---
   *Última actualización: <fecha actual>*
   *Generado por: meta-onboarding-wizard · sub-fase W1*
   ```

2. **Actualizar state**: usa la tool `Bash` para añadir el archivo a la lista `filesCreated`:
   ```bash
   node -e "
   const fs = require('fs');
   const p = process.env.HOME + '/.claude/skills/_install-state.json';
   const s = JSON.parse(fs.readFileSync(p, 'utf8'));
   if (!s.phases['context-files'].filesCreated.includes('context/me.md')) {
     s.phases['context-files'].filesCreated.push('context/me.md');
   }
   s.phases['context-files'].status = 'in-progress';
   if (!s.phases['context-files'].startedAt) {
     s.phases['context-files'].startedAt = new Date().toISOString();
   }
   s.phases['context-files'].filesPending = s.phases['context-files'].filesPending.filter(f => f !== 'context/me.md');
   s.lastUpdatedAt = new Date().toISOString();
   s.currentPhase = 'context-files';
   fs.writeFileSync(p, JSON.stringify(s, null, 2));
   console.log('[wizard W1] me.md committed');
   "
   ```

3. **NO le digas al usuario "he guardado en me.md"** — encadena natural a W2:
   > "Vale, ya te tengo ubicado. Vamos al negocio: ¿a qué te dedicas?"

### W2 · Negocio (dimensiones 3-6)

Cubre en este orden (pero sin anunciarlo):
1. **Negocio principal** — "¿A qué te dedicas? Cuéntamelo como se lo contarías a alguien en una cena."
2. **Modelo de ingresos** — Derivado de 1. Si no quedó claro: "¿De qué viene el dinero hoy? Servicios, productos, suscripciones, mix..."
3. **Cliente ideal** — "Pinta a tu cliente perfecto. Sector, tamaño, momento en el que llegan a ti."
4. **Stack diario** — "¿Con qué herramientas trabajas día a día? Las imprescindibles."

Aplica reglas de profundización. Si una respuesta cubre 2 dimensiones, márcalas y avanza.

**Cuando tengas dimensiones 3-6 con dato sólido:**

1. **COMMIT inmediato**: escribe `context/work.md`:
   ```markdown
   # work.md — mi negocio

   ## Qué hago
   <negocio principal, 2-3 líneas>

   ## Modelo de ingresos
   <servicios / productos / suscripción / mix, con detalle>

   ## Cliente ideal (descripción inicial)
   <sector, tamaño, momento, dolor principal — lo que tengamos>

   ## Stack diario
   <herramientas mencionadas, en bullets>

   ## Cifras clave (si las dio)
   <revenue / ticket / volumen, si fueron mencionadas>

   ---
   *Última actualización: <fecha>*
   *Para profundizar: ejecuta /deep-dive cuando estés listo*
   ```

2. **Actualizar state** (igual que W1, añadir `context/work.md` a `filesCreated`).

3. Encadenar a W3:
   > "Vale, ya tengo claro a qué te dedicas. Última parte antes del cierre: ¿qué hay en tu radar?"

### W3 · Foco (dimensiones 7-8)

1. **Foco del mes** — "¿En qué estás centrado ESTE mes? Si tuvieras que elegir 2-3 cosas que llevarte por delante."
2. **Objetivo 12 meses** — "Mírate dentro de 12 meses. ¿Qué tiene que pasar para que digas 'el año mereció la pena'?"

**Cuando tengas dimensiones 7+8:**

1. **COMMIT inmediato**: dos archivos.

   `context/current-priorities.md`:
   ```markdown
   # current-priorities.md — foco este mes

   ## Top prioridades (orden de impacto)
   1. <prioridad 1>
   2. <prioridad 2>
   3. <prioridad 3, si la dio>

   ## Por qué importan
   <contexto que diste sobre por qué estas y no otras>

   ---
   *Actualizado: <fecha>*
   *Refresco recomendado: mensual o cuando cambien las circunstancias*
   ```

   `context/goals.md`:
   ```markdown
   # goals.md — meta a 12 meses

   ## Donde quiero estar dentro de 12 meses
   <descripción literal o reformulada del operador>

   ## Métricas / señales de éxito
   <si las dio, en bullets; si no, "(por definir en /deep-dive)">

   ---
   *Actualizado: <fecha>*
   *Refresco recomendado: trimestral*
   ```

2. **Actualizar state**: añadir ambos a `filesCreated`.

3. Encadenar a W4:
   > "Casi. Última cosa, 3 preguntas técnicas rápidas para configurar el sistema."

### W4 · Config técnica + cierre context-files

3 preguntas seguidas (SÍ rápidas y directas — son técnicas):

1. "¿Tu nivel técnico? Cero (nunca tocaste terminal) / intermedio / avanzado"
2. "¿Idioma de outputs hacia tus clientes? Castellano / inglés / bilingüe / otro"
3. "¿Tienes Firecrawl API key? Si no, te la salto y el sistema funciona igual con fallback manual."

**Cuando tengas las 3 respuestas:**

1. **Inicializar headers de archivos auxiliares** (`team.md`, `decisions-log.md`, `learnings.md`, `soul.md`) si no existen — `install.sh` ya los creó vacíos, no los reescribas.

2. **COMMIT a `~/.claude/skills/_operator-state.json`**: actualizar el JSON con los datos recogidos. Usa Bash:
   ```bash
   node -e "
   const fs = require('fs');
   const p = process.env.HOME + '/.claude/skills/_operator-state.json';
   const s = JSON.parse(fs.readFileSync(p, 'utf8'));
   s.needsOnboarding = false;
   s.onboardingDate = new Date().toISOString().slice(0,10);
   s.operator = s.operator || {};
   s.operator.name = '<nombre>';
   s.operator.location = '<ubicación>';
   s.operator.language = '<idioma>';
   s.operator.technicalLevel = '<respuesta>';
   s.operator.clientOutputLanguage = '<respuesta>';
   s.firecrawlAvailable = <true|false>;
   s.welcomeCompleted = false;
   s.deepDiveCompleted = false;
   s.lastUpdated = new Date().toISOString();
   fs.writeFileSync(p, JSON.stringify(s, null, 2));
   console.log('[wizard W4] operator-state committed');
   "
   ```

3. **Si el usuario dio Firecrawl key**: añadirla a `.env` (`FIRECRAWL_API_KEY=...`).

4. **Marcar ambas fases `done` en `_install-state.json`**:
   ```bash
   node -e "
   const fs = require('fs');
   const p = process.env.HOME + '/.claude/skills/_install-state.json';
   const s = JSON.parse(fs.readFileSync(p, 'utf8'));
   const now = new Date().toISOString();

   // context-files done
   s.phases['context-files'].status = 'done';
   s.phases['context-files'].validatedAt = now;
   if (!s.completedPhases.includes('context-files')) s.completedPhases.push('context-files');

   // operator-state done
   s.phases['operator-state'].status = 'done';
   s.phases['operator-state'].validatedAt = now;
   s.phases['operator-state'].fields = {
     needsOnboarding: false,
     onboardingDate: now.slice(0,10),
     technicalLevel: '<respuesta>',
     clientOutputLanguage: '<respuesta>'
   };
   if (!s.completedPhases.includes('operator-state')) s.completedPhases.push('operator-state');

   s.currentPhase = 'welcome-completed';
   s.lastUpdatedAt = now;
   fs.writeFileSync(p, JSON.stringify(s, null, 2));
   console.log('[wizard W4] context-files + operator-state marked done');
   "
   ```

5. **Validación post-commit** (defensa contra "instalación fantasma"):
   - Confirma que los 4 archivos en `context/` existen y cada uno tiene >100 chars.
   - Si alguno falla, NO marques `done`. Avisa al usuario, marca la fase como `in-progress` y para.

### W5 · Transición a welcome-quick-win

Mensaje:

```
🎉 Setup mínimo completo. Tengo:

  ✓ Tu identidad y dónde estás
  ✓ Tu negocio principal y a quién sirves
  ✓ Tu stack diario
  ✓ Tu foco este mes y tu meta a 12 meses

Voy a generarte tu primer entregable real ahora. ~5 min. Te queda
un HTML compartible.

¿Vamos?
```

Si "sí": invoca `welcome-quick-win`. Esa skill marca `phases.welcome-completed.status = "done"` al terminar.

Si "no" o "después":
- Marca `pausedBy: "user"`, `pausedAtPhase: "welcome-completed"` en `_install-state.json`.
- Despídete: "Vale. Cuando vuelvas, te lo recordaré con `/install --resume`. El sistema sigue funcional aunque sin el primer entregable."

### W6 · Anuncio de deep-dive

Tras `welcome-quick-win` (o si dijo "después"):

```
Última cosa antes de cerrar.

Lo de hoy ha sido el mínimo. El sistema ya funciona, pero te
conoce todavía superficialmente. Si quieres que los outputs salgan
realmente en tu voz, hay una skill que se llama `meta-deep-dive` que
profundiza otras 20-25 áreas: tus ritmos, tu modelo financiero, tu
equipo, tu definición de éxito.

Tarda ~25 minutos. Lo recomiendo para mañana, no hoy.

Cuando quieras, ejecuta:  /deep-dive

Suerte. Nos vemos mañana.
```

---

## Comportamiento ante interrupciones

**Usuario dice "para", "cierra", "no quiero seguir":**
1. NO marques nada como `done` que no esté efectivamente done.
2. Lo que hayas commiteado de archivos ya está persistido en disco.
3. Actualiza `_install-state.json`: `pausedBy: "user"`, `pausedAt: <now>`, `pausedAtPhase: <sub-fase actual>`.
4. Mensaje breve: "Sin problema. Hemos guardado lo que ya tenemos. Cuando vuelvas, `/install --resume` retoma desde aquí."
5. NO insistas. NO pidas confirmación. NO digas "¿seguro?".

**Sesión se rompe (context window, error)**:
- Lo último commiteado a disco persiste.
- La siguiente sesión: el hook `_install-gate.sh` detectará `phases.context-files.status: "in-progress"` y guiará al usuario a `/install --resume`.
- La nueva ejecución del wizard lee `filesCreated` y arranca en la primera sub-fase que tenga archivos pendientes.

**Usuario es curioso sin negocio activo**:
- En W2, marca `avatar: "curioso"` en operator-state, salta a W3 con "Sin negocio activo todavía, vale. Pasamos a tu foco."
- Anota en work.md: "Sin negocio activo. Cuando lo tengas, reejecuta el wizard."

**Usuario contesta todo en 1 párrafo gigante**:
- Extrae las 8 dimensiones de ese párrafo. NO pidas desglose.
- Solo profundiza dimensiones que quedaron débiles.
- Confirma con el usuario antes de commitear cada archivo: "Voy a anotar X, Y, Z. ¿Va?"

---

## Edge cases técnicos

- **`_install-state.json` no existe cuando arranca el wizard**: el wizard NO fue invocado por install.sh correctamente. Avisa al usuario: "El installer técnico no se ha ejecutado. Sal de Claude Code y ejecuta `bash scripts/install.sh` desde terminal."
- **`_install-state.json` existe pero `phases.sinapsis-engine` no está `done`**: Sinapsis no está bien instalada. Avisa y deriva a `bash scripts/install.sh --resume`.
- **El operator-state.json ya existe con datos previos**: NO lo sobrescribas en bloque. Hace merge: preserva campos no tocados por el wizard.
- **Firecrawl key suena fake** (no empieza por `fc-` o tiene menos de 20 chars): pídela otra vez con suavidad o márcala como `firecrawlAvailable: false`.

## Outputs (al cerrar correctamente)

- `context/me.md`, `work.md`, `current-priorities.md`, `goals.md` — escritos con contenido real
- `context/team.md`, `decisions-log.md`, `learnings.md`, `soul.md` — inicializados con header (lo hizo `install.sh`)
- `~/.claude/skills/_operator-state.json` — campos críticos rellenos
- `~/.claude/skills/_install-state.json` — `context-files.status = "done"`, `operator-state.status = "done"`
- `.env` con Firecrawl si aplica

## Skills que llama

- **`welcome-quick-win`** — al final de W4, para generar primer entregable (esa skill marca `welcome-completed: done`)

## Skills que recomienda al cerrar

- **`meta-deep-dive`** — para las 22 dimensiones restantes
