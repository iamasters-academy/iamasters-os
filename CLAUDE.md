# iAmasters OS — CLAUDE.md (project root)

> Sistema operativo agéntico para operadores de IA.
> Sinapsis v4.6.1 (engine) + capa OS (brand context, agent context, skills curadas, multi-cliente).

---

## ⛔ INSTALLATION GATE — LEER ANTES QUE NADA

Antes de responder al primer mensaje del usuario en este repo, **debes** comprobar si la instalación está completa.

**Fuente de verdad**: `~/.claude/skills/_install-state.json` (state machine persistente, v0.6+).

**Comprobación obligatoria** (en este orden):

1. **¿Existe el state file?**
   - Si NO existe → la instalación técnica nunca corrió. Indica al usuario:
     > "iAmasters OS no está instalado. Necesito que ejecutes desde terminal: `bash scripts/install.sh`. Cuando termine, vuelve aquí."
   - NO crees archivos manualmente para simular instalación. NO marques nada como instalado.

2. **Si existe, ¿todas las fases `required: true` están en `status: "done"`?**
   - Si NO → la instalación está incompleta. Invoca el comando `/install` (o el wizard directamente, según la fase pendiente).
   - **NO respondas a otras peticiones del usuario hasta cerrar la instalación.**

3. **El hook SessionStart (`_install-gate.sh`) ya inyecta este aviso automáticamente cuando aplica.** Esta sección es tu *backup* por si el hook falla, no la fuente principal.

**Lo que NUNCA haces durante una instalación incompleta**:
- ❌ Reportar "todo instalado" cuando el state dice lo contrario
- ❌ Crear archivos `.json` o `.md` manualmente para "completar" fases
- ❌ Marcar fases como `done` sin que la validación profunda lo confirme
- ❌ Avanzar a tareas del usuario si quedan fases `required` sin completar

**Si el usuario dice "para" / "ya no quiero seguir":**
- Marca `pausedBy: "user"` en el state con la fase actual
- Despídete: "Cuando vuelvas, `/install --resume` retoma desde aquí. Lo guardado está guardado."
- NO insistas. NO reportes la instalación como completa.

**Si dudas del estado**: ejecuta `/install-status` para ver el dashboard sin tocar nada.

---

## Session Entry — EXECUTE ON FIRST MESSAGE OF EVERY SESSION

(Una vez que el INSTALLATION GATE de arriba ha pasado.)

### Paths absolutos (relativos a este repo)
- **Skills del OS**: `.claude/skills/`
- **Commands del OS**: `.claude/commands/`
- **Brand context**: `brand-context/` (voice, positioning, ICP, assets)
- **Agent context sectorizado**: `context/` (working-memory.md, me.md, work.md, team.md, current-priorities.md, goals.md, decisions-log.md, learnings.md, soul.md)
- **Proyectos**: `projects/` (`projects/briefs/<nombre>/`, `projects/welcome/`, `projects/seis-sombreros/`, `projects/metodo-ias/`, `projects/visual/`)
- **Clientes**: `clients/<nombre>/` (con `clients/_templates/` para nuevos)
- **Docs operativos**: `docs/`
- **Scripts del installer**: `scripts/install.sh`, `scripts/_install-gate.sh`, `scripts/_install-state.template.json`
- **Vendored**: `vendor/sinapsis/` (engine), `vendor/cognito/` (Sistema Operativo de Pensamiento de Luis Pitik), `vendor/arnes/` (skill opt-in para arrancar proyectos software, concepto fs-scaffold de Fernando Montero)

### Paths Sinapsis (engine global del operador)
- **Skills root global**: `~/.claude/skills/` (Sinapsis instalado por install.sh)
- **Operator state**: `~/.claude/skills/_operator-state.json`
- **Install state (v0.6+)**: `~/.claude/skills/_install-state.json` ← fuente de verdad de la instalación
- **Install gate hook**: `~/.claude/skills/_install-gate.sh` (SessionStart hook)
- **Instincts**: `~/.claude/skills/_instincts-index.json`
- **Daily summaries**: `~/.claude/skills/_daily-summaries/`
- **Catalog**: `~/.claude/skills/_catalog.json`

### MANDATORY first action (post-gate)

Una vez confirmado que la instalación está completa, antes de responder al primer mensaje del usuario:

1. Lee `~/.claude/skills/_operator-state.json` (Sinapsis: perfil del operador, decisiones, lecciones).
2. Lee `context/working-memory.md` — **scratchpad de trabajo** (hilos activos / notas de entorno / decisiones pendientes). Es lo primero que te pone al día sobre el estado actual, sin buscar nada.
3. Lee los 5 archivos sectorizados de `context/` si existen: `me.md`, `work.md`, `team.md`, `current-priorities.md`, `goals.md`.
4. Lee `context/decisions-log.md` (últimas 5 entradas) para mantener coherencia.
5. Lee cualquier plan activo en `.claude/plans/` si la carpeta existe (planes en progreso de sesiones anteriores).
6. Lee `synapsis/daily-summaries/<TODAY>.md` o `<YESTERDAY>.md` (continuidad diaria).

### Session continuity (operativa diaria)

Cuando todo está configurado y la instalación está completa:
1. Daily summary de ayer (Sinapsis)
2. `context/learnings.md` (feedback consolidado de skills)
3. Proyectos abiertos en `projects/briefs/*/brief.md` con `status: active`
4. Saluda con: "Ayer dejaste X. Sigues con Y o cambias?"

---

## Actualizar el OS

Cuando el usuario diga **"actualízate"**, **"actualiza el OS"**, **"actualízate a la última versión"**, **"tráete los cambios nuevos"**, **"ponme la última versión de iAmasters OS"** o **"update"** → ejecuta el comando `/actualiza`:

```bash
git pull --ff-only
bash scripts/update.sh
```

`update.sh` preserva SIEMPRE lo del operador (skills propias, `brand-context/`, `context/`, `projects/`, `clients/`, `loops/`); solo actualiza el código del OS, las skills curadas y Sinapsis vendored. Si `git pull` falla por cambios locales, NO fuerces: explica qué tiene modificado y pregunta. Al terminar, resume lo nuevo desde el `CHANGELOG.md`.

Cuando lo lanzas tú (sin terminal del usuario), `update.sh` detecta que no hay TTY y entra en modo no-interactivo: nunca pregunta, mantiene la versión local ante cualquier conflicto y lista al final los "Pendientes de decisión". Resuélvelos conversacionalmente con el usuario (enséñale qué cambia cada archivo y aplica lo que decida con `git checkout origin/<branch> -- <archivo>`).

**Si tras actualizar algo se rompe** → `/restaura` (rollback completo al estado anterior: código + datos). Cada update deja backup automático en `.backup/`.

---

## Sobre el sistema

### Sinapsis (engine de memoria)
Sinapsis es el sistema que hace que Claude Code aprenda de ti. Vive instalado en `~/.claude/` (no en este repo). El repo lo trae vendored en `vendor/sinapsis/` para instalación.

Sinapsis te da:
- **Operator state**: tu identidad, stack, decisiones — persiste en TODOS los proyectos
- **Instincts**: patrones aprendidos que se inyectan automáticamente cuando aplican
- **Passive rules**: guardrails técnicos (seguridad, calidad, workflow)
- **Skills on-demand**: solo carga las relevantes (~2.800 tokens vs ~25.000)
- **Dream cycle**: limpieza periódica de memoria
- **Dashboard** (`/dashboard-sinapsis`): métricas reales

Comandos Sinapsis instalados global:
- `/system-status` · `/evolve` · `/instinct-status` · `/passive-status` · `/eod` · `/dream` · `/analyze-session`

### Capa OS (este repo)
Lo que aporta este repo encima de Sinapsis:

**Brand Context (`brand-context/`)** — estática:
- Voice profile + 3 registros (A formal / B divulgativo / C cercano)
- Positioning, ICP, brand assets

**Agent Context (`context/`)** — dinámica:
- `working-memory.md` — **scratchpad de trabajo** (hilos activos / notas de entorno / decisiones pendientes). Se inyecta al inicio y se mantiene al cierre. Tope ~2.500 car.
- `soul.md` — personalidad del agente (cómo respondes)
- `me.md`, `work.md`, `team.md`, `current-priorities.md`, `goals.md`
- `learnings.md`, `decisions-log.md`

**Memoria de trabajo (memo manual)**: cuando el operador diga *"recuerda esto"*, *"apunta que"*, *"nota que"* o *"para la próxima"*, escribe el ítem en la sección que corresponda de `context/working-memory.md` (Hilos activos / Notas de entorno / Decisiones pendientes), con dedup y respetando el tope. Visible de inmediato en esta sesión; en sesiones futuras se carga al inicio.

**Skills curadas** — modelo Core + Biblioteca: 17 core en `.claude/skills/` (siempre cargadas) + 21 en `skills-library/` instalables con `/skills` (ver registry abajo).

**Niveles de proyecto**:
1. **Single task** — pregunta directa. Output a `projects/<skill-name>/<fecha>-<titulo>/`.
2. **Planned project** — scoping conversation. Output a `projects/briefs/<nombre>/`.
3. **GSD project** — multi-fase. `.planning/` en cliente o raíz.

**Multi-cliente**:
- `clients/<nombre>/` con su propio brand-context, context, projects
- Templates en `clients/_templates/` para 4 verticales

---

## Skills registry (v0.11.0)

Modelo **Core + Biblioteca**: 27 skills core siempre instaladas (el OS las necesita) + 80 en `skills-library/` que el operador instala a demanda con `/skills` (proyecto `nuevas-skills`: pack de marketing completo — 39 skills portadas de `coreyhaines31/marketingskills`, lotes M1-M4 + `marketing-launch`; fusiones F.0 aplicadas). **El operador tiene 19 de biblioteca instaladas** → **46 skills activas** (tope elegido; marcadas con ✅ en las tablas de Biblioteca; se cargan e invocan solas como las Core). El resto queda en catálogo a coste cero y se ofrece por routing cuando la intención encaje. Cada skill instalada consume contexto en cada sesion (recomendacion Anthropic: <50 cargadas) — instala solo lo que uses.

**Routing por intencion (OBLIGATORIO — actívalo en CADA petición)**: antes de responder que no puedes hacer algo, o de resolverlo a mano, contrasta SIEMPRE la intención del operador contra la tabla de **Biblioteca** de abajo (la columna "Ofrécela cuando…" lista los disparadores de cada skill no instalada). Si una encaja, NO la ignores ni la resuelvas tú: ofrécela → "Eso lo hace la skill `<nombre>`. ¿La instalo?" → `bash scripts/skills.sh add <nombre>`. Las skills instaladas (sección Core **y las marcadas ✅ en Biblioteca**) sí se cargan solas: invócalas directamente cuando la intención encaje, sin preguntar. Catálogo en vivo y fuente de verdad de descripciones: `bash scripts/skills.sh list`.

**Fallback obligatorio (auto-activación de `find-skills`)**: si la intención del operador **no encaja con NINGUNA** skill —ni Core, ni Biblioteca instalada, ni Biblioteca disponible—, **antes de decir "no puedo" o de resolverlo a mano, invoca automáticamente la skill `find-skills`** (core `_meta/find-skills`) para buscar en el ecosistema externo (`npx skills`). No esperes a que el operador diga "busca una skill": el no-match del catálogo del OS ES el disparador. Solo si `find-skills` tampoco encuentra nada, resuelve la tarea con capacidades generales y sugiere crearla con `meta-skill-creator` si es recurrente.

### Core — siempre instaladas (27)

#### `_meta/` — sistema (10)

| Skill | Descripción corta |
|---|---|
| `meta-skill-creator` | Crea skills nuevas |
| `meta-onboarding-wizard` | Entrevista express por **4 sub-fases con commits incrementales** (v0.6) |
| `meta-deep-dive` | Entrevista profunda (22-25 dimensiones) — opcional |
| `meta-start-here` | Ritual diario de inicio |
| `meta-wrap-up` | Ritual diario de cierre |
| `welcome-quick-win` | Primer entregable en 5 min |
| `decisions-log` | Diario append-only de decisiones |
| `health-check` | Diagnóstico del OS con **validación profunda y detección de drift** (v0.6) |
| `find-skills` | Descubre e instala skills por intención del usuario |
| `recuerda` | **Recall de memoria local** (SQLite+FTS5) con fuente citada — base para todos, semántico opt-in (v0.8.2) |

#### Fundación de marca + motor (7)

| Skill | Descripción |
|---|---|
| `marketing-brand-voice` | Voice profile + 3 registros |
| `marketing-positioning` | Posicionamiento competitivo |
| `marketing-icp` | Cliente ideal |
| `automation-loop-engine` | Loop Engineering: convierte trabajo repetitivo en sistemas con verificación, compuertas humanas y aprendizaje |
| `tool-firecrawl-scraper` | Wrapper Firecrawl |
| `tool-humanizer` | Quita patrones AI-tell |
| `tool-output-verifier` | Gate de calidad |

#### `marketing/` — core (2)

| Skill | Descripción |
|---|---|
| `brand-guidelines` | Aplica colores y tipografía de marca a artefactos (consistencia visual) |
| `competitive-ads-extractor` | Extrae y analiza anuncios de la competencia (mensajes, dolores, creatividades que funcionan) |

#### `strategy/` — core (3)

| Skill | Descripción |
|---|---|
| `competencia` | Inteligencia competitiva con NotebookLM + web (insights, oportunidades, fortalezas). Usa `notebooklm-mcp` |
| `notebooklm-mcp` | Investigación fundamentada (grounded) sobre documentos vía NotebookLM MCP, con perfiles de tokens |
| `startup-business-analyst` | Análisis de negocio para startups: TAM/SAM/SOM, modelo financiero, competitivo, planificación |

#### `tools/` — core (4)

| Skill | Descripción |
|---|---|
| `ask-questions-if-underspecified` | Hace las preguntas mínimas antes de construir cuando la petición llega ambigua |
| `usability-retention-review` | Revisa usabilidad, navegación y retención de apps con honestidad brutal |
| `react-best-practices` | Guías de React/Next.js: hooks, patrones de componente, estado, rendimiento |
| `backend-development` | Diseño de APIs, esquemas de BBDD, microservicios y TDD |

#### `visualization/` — core (1)

| Skill | Descripción |
|---|---|
| `ui-ux-pro-max` | Inteligencia de diseño UI/UX (50 estilos, paletas, tipografías, 9 stacks): planear/construir/revisar UI |

### Biblioteca — instalables con `/skills` (35)

Viven en `skills-library/` (cero coste de contexto hasta instalarlas). Instalar: `bash scripts/skills.sh add <nombre>` · Quitar: `remove` · Catálogo: `list`.

#### `marketing/` (43)

> Pack `coreyhaines31/marketingskills` portado completo (proyecto `nuevas-skills`, lotes M1-M4):
> 38 skills nuevas + las 4 previas. Todas en biblioteca; instala a demanda con `/skills`. Cuerpo
> original inglés, frontmatter en castellano, nota-puente al OS en cada una.

| Skill | Ofrécela cuando el operador… |
|---|---|
| `marketing-copywriting` | ✅ **instalada** — invócala directamente. pida un texto de marketing: "escríbeme/redacta/hazme un post de LinkedIn", "un tweet", "un hilo de X", "un email", "un anuncio", "una landing", "un headline", "copy para…" |
| `marketing-content-repurposing` | quiera multiplicar una pieza: "repurpose este vídeo/podcast", "saca contenido de esto", "trocea esto para redes", "distribuye esto en varias plataformas" |
| `marketing-email-sequence` | pida secuencias/automatizaciones de email: "secuencia de bienvenida", "nurture", "win-back", "drip", "qué emails enviar", "cadencia de emails", "embudo de emails" |
| `marketing-meta-ads-analyzer` | quiera diagnosticar Meta Ads: "analiza mi campaña", "por qué no convierte", "CPA/ROAS/CPM/CTR", "revisa estas audiencias/creatividades", pegue datos o capturas de Meta |
| `marketing-product-context` | arranque un proyecto de marketing o diga "contexto de producto", "marketing context", "define mi producto/audiencia". Doc base que referencian las demás; puentea con `brand-context/`+`context/` |
| `marketing-plan` | diga "hazme un plan de marketing", "estrategia de marketing", "plan de crecimiento", "roadmap de marketing", "por dónde empiezo a promocionar" |
| `marketing-content-strategy` | diga "estrategia de contenido", "qué contenido publico", "calendario editorial", "pilares/topics de contenido" (≠ trocear pieza = `marketing-content-repurposing`) |
| `marketing-ideas` | diga "dame ideas de marketing", "no sé qué hacer para crecer", "lluvia de ideas", "qué táctica pruebo" (140+ jugadas) |
| `marketing-psychology` | diga "usa psicología", "gatillos mentales", "principios de persuasión", "por qué la gente compra", "sesgos para conversión" |
| `marketing-offers` | diga "diseña/mejora una oferta", "cómo empaqueto esto", "qué incluyo en el paquete", "value framing", "hazlo irresistible" |
| `marketing-pricing` | diga "qué precio pongo", "estrategia de precios", "cuánto cobro", "pricing tiers", "monetización" |
| `marketing-customer-research` | diga "investiga a mis clientes", "entrevistas de cliente", "qué quieren mis clientes", "voice of customer", "jobs to be done", "analiza reseñas/feedback" |
| `marketing-cold-email` | diga "email en frío", "cold email", "correo de prospección", "outreach B2B", "secuencia de follow-up a prospectos" |
| `marketing-prospecting` | diga "lista de prospectos", "encuentra clientes potenciales", "cualifica leads", "a quién le vendo", "lista de contactos para outreach" |
| `marketing-ads` | diga "monta una campaña de pago", "configura anuncios en Google/Meta/LinkedIn", "gestiona mis ads", "estructura/presupuesto de campañas" (≠ diagnosticar Meta = `marketing-meta-ads-analyzer`) |
| `marketing-ad-creative` | diga "crea creatividades de anuncio", "headlines para ads", "variantes de anuncio", "ángulos para la campaña" |
| `marketing-social` | diga "posts para redes", "contenido de social media", "qué publico en IG/LinkedIn/X", "ideas para redes" |
| `marketing-video` | diga "guion de vídeo", "ideas para reels/shorts", "vídeo de marketing", "vídeo para el anuncio" (≠ FVI ni descargar/transcribir) |
| `marketing-image` | diga "gráficos para redes", "imágenes de marketing", "genera una imagen para post/anuncio", "banner", "creatividad visual" |
| `marketing-public-relations` | diga "campaña de PR", "nota de prensa", "contacta periodistas", "aparecer en medios", "relaciones públicas" |
| `marketing-community` | diga "crea una comunidad", "estrategia de comunidad", "hacer crecer comunidad", "Discord/Skool/grupo" (≠ captación redes = `automation-embudo-captacion`) |
| `marketing-co-marketing` | diga "co-marketing", "partners para campañas", "alianza/colaboración de marketing", "campaña conjunta", "cross-promotion" |
| `marketing-directory-submissions` | diga "envía mi producto a directorios", "Product Hunt", "G2/Capterra", "listar en directorios SaaS/startup" |
| `marketing-lead-magnets` | diga "crea un lead magnet", "imán de leads", "ebook/checklist para captar", "recurso gratuito a cambio del email" |
| `marketing-free-tools` | diga "herramienta gratuita para captar", "free tool", "calculadora/generador como gancho de leads" |
| `marketing-launch` | diga "voy a lanzar", "plan de lanzamiento", "launch", "sacar el producto", "anunciar una feature nueva", "lanzar en Product Hunt", "go-to-market del lanzamiento" (≠ plan de marketing continuo = `marketing-plan`; ≠ PR = `marketing-public-relations`) |
| `marketing-cro` | diga "optimiza esta landing", "mejora la conversión", "CRO", "por qué no convierte", "revisa el formulario/checkout" |
| `marketing-popups` | diga "monta un popup", "overlay de captura", "exit-intent", "modal de descuento", "banner de suscripción" |
| `marketing-paywalls` | diga "crea un paywall", "pantalla de upgrade in-app", "muro de pago", "conversión a premium" (apps propias) |
| `marketing-signup` | diga "mejora el registro", "optimiza el signup", "flujo de alta", "reduce fricción de registro", "trial sin tarjeta" |
| `marketing-onboarding` | diga "mejora el onboarding", "activación de usuarios", "time to value", "flujo post-registro" |
| `marketing-churn-prevention` | diga "reduce el churn", "evita cancelaciones", "flujo de cancelación", "oferta de retención", "win-back de cancelados" |
| `marketing-referrals` | diga "programa de referidos", "sistema de afiliados", "member-get-member", "cómo hago que me recomienden" |
| `marketing-revops` | diga "revops", "lead scoring", "pipeline de leads", "ciclo de vida del lead", "handoff marketing-ventas" |
| `marketing-sales-enablement` | diga "material de ventas", "pitch deck", "guion de demo", "one-pager", "cómo respondo objeciones" |
| `marketing-analytics` | diga "configura GA4", "tracking de eventos", "mide mis conversiones", "audita mi analítica", "atribución" |
| `marketing-ab-testing` | diga "plan de A/B testing", "diseña un experimento", "qué testeo primero", "significancia del test", "variantes a probar" |
| `marketing-programmatic-seo` | diga "SEO programático", "páginas a escala", "cientos de páginas SEO", "pSEO", "plantillas de landing por keyword" |
| `marketing-site-architecture` | diga "reestructura mi web", "arquitectura del sitio", "jerarquía de páginas", "navegación/menú", "internal linking" |
| `marketing-competitors` | diga "página de comparación", "X vs Y", "alternativa a Z", "landing de versus" (≠ inteligencia competitiva de negocio = `competencia`) |
| `marketing-copy-editing` | diga "edita este copy", "revisa este texto", "mejóralo/púlelo", "hazlo más claro/corto" (≠ escribir desde cero = `marketing-copywriting`) |
| `marketing-aso` | diga "optimiza mi ficha de la app", "ASO", "keywords de la app", "screenshots de la ficha" (apps propias) |
| `marketing-sms` | diga "campaña de SMS", "marketing por SMS/MMS", "cadencia de SMS", "opt-in de SMS" |

#### `strategy/` (8)

| Skill | Ofrécela cuando el operador… |
|---|---|
| `desbloqueo` | diga "estoy bloqueado", "no consigo arrancar/publicar/lanzar", "llevo semanas dándole vueltas", "no me decido", "me disperso", "empiezo cosas y no las cierro", "procrastino", "síndrome del impostor", o describa parálisis/perfeccionismo/miedo a lanzar (estado de bloqueo personal, NO decisión con trade-offs → eso es `seis-sombreros`/`cognito`) |
| `metodo-ias` | diga "método IAS", "planifica la sesión", "recap semanal", "me estoy quemando con la IA", "AI brain fry", "tomo demasiadas micro-decisiones", o quiera estructurar trabajo con IA sin saturarse |
| `developer-growth-analysis` | diga "analiza mi historial de código", "en qué estoy fallando programando", "dónde puedo mejorar como dev", "detecta mis gaps técnicos", o quiera un informe de sus patrones de desarrollo |
| `seis-sombreros` | ✅ **instalada** — invócala directamente. pida "seis sombreros", "six hats", "ayúdame a pensar esto", "pros y contras en serio", "rompe el ancla", "análisis multi-perspectiva", o esté ante una decisión con sesgo de anclaje |
| `cognito` | ✅ **instalada**. afronte decisiones con trade-offs, tensión emocional+técnica+estratégica, "¿debería hacer X?", análisis profundo o cambios de enfoque que pidan modos cognitivos explícitos |
| `strategy-web-research` | ✅ **instalada**. pida búsqueda web **ligera y rápida**: "búscame", "investiga rápido", "compara X e Y", 3-5 fuentes, info actual acotada (no informe largo) |
| `strategy-investigacion-profunda` | pida un **informe completo**: "investiga a fondo", "informe con fuentes", "triangula", "verifica con varias fuentes", "due diligence", "estado del arte" |
| `strategy-stack-recommender` | pregunte "¿con qué construyo esto?", "¿qué stack me recomiendas?", "¿qué tecnologías uso para…?", o describa un proyecto y necesite orientación técnica antes de picar código |

#### `tools/` (21)

| Skill | Ofrécela cuando el operador… |
|---|---|
| `tool-caveman` | ✅ **instalada**. diga "modo caverna", "caveman", "menos tokens", "comprime tus respuestas", "sé ultra conciso", "ahorra contexto", o "/caveman". Comprime ~75% quitando relleno, mantiene código y sustancia; persiste hasta "modo normal". NO comprime warnings/acciones irreversibles/entregables |
| `tool-geo-seo-audit` | ✅ **instalada**. diga "audita el SEO de mi web", "optimiza para IA / para que me cite ChatGPT", "GEO", "llms.txt", "schema markup", "structured data", "¿por qué no aparezco en Google/IA?", o vaya a posicionar una web pública. Fusiona ai-seo/seo-audit/schema; LLM-native (Python opcional) |
| `arnes` | diga "nuevo proyecto", "crea una app/web/landing", "arranca un proyecto", "adopta/renueva este proyecto", o quiera montar software paso a paso (Express/Estándar/PRO) |
| `vercel-deploy` | diga "despliega esto en Vercel", "súbelo a Vercel", "pon esta web/app online en Vercel", o cierre un proyecto web listo para producción en Vercel (último paso de la cadena build) |
| `obsidian-plugin` | diga "crea un plugin de Obsidian", "desarrolla algo para Obsidian", "extiende Obsidian", "plugin para mi bóveda de notas", o trabaje sobre la Obsidian API |
| `video-downloader` | diga "descárgame este vídeo", "bájate este YouTube/Vimeo", "guarda este vídeo en local", "saca el audio de este vídeo", o pase una URL de vídeo para tenerla en disco |
| `exploratory-data-analysis` | ✅ **instalada**. diga "saca insights de estos datos", "explora este dataset/CSV", "haz un EDA", "qué hay en estos datos", o pase un fichero de datos para entenderlo (primer paso del análisis) |
| `statistical-analysis` | diga "qué test estadístico uso", "comprueba si esto es significativo", "potencia estadística", "compara estos grupos", o necesite elegir/justificar un test con sus supuestos |
| `statsmodels` | ✅ **instalada**. necesite "regresión OLS/GLM", "ARIMA/series temporales", "modelos mixtos", "diagnósticos de residuos", econometría o inferencia con detalle (encaja con Polymarket) |
| `scikit-learn` | ✅ **instalada**. diga "entréname un modelo", "clasificación/regresión", "clustering", "reducción de dimensionalidad", "pipeline de ML", o haga machine learning clásico en Python |
| `pytorch-lightning` | diga "red neuronal", "deep learning", "entrenar un modelo en GPU", "LightningModule/Trainer", o monte un pipeline de DL organizado |
| `shap` | diga "explica las predicciones del modelo", "importancia de variables", "por qué predice esto el modelo", "explicabilidad/interpretabilidad", "SHAP values" (encaja con honestidad-FVI) |
| `code-audit-integral` | ✅ **instalada** — invócala directamente. diga "audita mi app/código a fondo", "revisión técnica completa", "¿está lista para producción?", "revisa seguridad/backend/rendimiento antes de lanzar", "auditoría integral", o cierre un desarrollo grande y quiera un informe priorizado P0/P1/P2 (13 fases modulares Sprint/Standard/Full; se adapta al stack) |
| `tool-zoom-summary` | pida "resume esta reunión", "qué se dijo en la call", "recap de la reunión", "resumen zoom", "/zoom", o documente una clase/call recurrente |
| `tool-seguridad-ia` | diga "revisa la seguridad de este código", "¿es seguro lo que ha escrito la IA?", "checklist antes de desplegar", o genere código sensible (credenciales, endpoints, BBDD) |
| `tool-quality-gate` | diga "antes de desplegar", "voy a hacer push", "¿está listo para producción?", "valida esta app", o cierre un proyecto arnes |
| `tool-transcribe-social` | pase una URL de Reel/TikTok/Short/vídeo y diga "transcribe esto", "saca lo que dice", "de qué va este vídeo" |
| `tool-web-legal-audit` | ✅ **instalada**. diga "audita legalmente esta web", "¿cumple RGPD/LSSI?", "revisa cookies/trackers", "comprueba accesibilidad", o lance una landing pública |
| `tool-web-security-audit` | ✅ **instalada**. diga "¿tiene vulnerabilidades mi web?", "pentest a mi sitio", "busca agujeros de seguridad", "¿es hackeable?" (solo webs propias/autorizadas). v2.1: scorecard 0-100 + auto-fix |
| `daily-brief` | ✅ **instalada**. diga "brief de hoy", "resúmeme el correo y la agenda", "qué tengo hoy", "daily brief", o acepte la oferta matutina de `meta-start-here` (correo Gmail + Google Calendar; Drive aún no conectado) |
| `tool-graphify` | ✅ **instalada** (también global en `~/.claude/skills/` — aplica a TODOS los proyectos). diga "graphify", "mapea/indexa este proyecto", "monta el grafo de conocimiento", "grafo de dependencias", o pregunte arquitectura ("¿qué depende de X?") en un repo grande. Always-on vía passive rule Sinapsis `graphify-graph-first`; NUNCA usar `graphify claude install`. Cada repo tiene su grafo propio en `graphify-out/` |

#### `automation/` (4) — ✅ las 4 instaladas, invócalas directamente

| Skill | Ofrécela cuando el operador… |
|---|---|
| `automation-n8n-to-claude` | diga "tengo un workflow en n8n que quiero traer aquí", "pasa esta automatización a Claude", "migra mi n8n", o pegue un JSON de n8n/Make para reimplementar |
| `automation-n8n-builder` | ✅ **instalada**. diga "créame un workflow en n8n", "monta esto en n8n", "automatiza X en n8n", o quiera construir/desplegar un flujo n8n vía MCP |
| `automation-client-deploy` | ✅ **instalada**. diga "despliega esto al cliente", "llévalo al VPS/PC del cliente", "empaqueta y entrega", o tenga un proyecto local listo para producción en el entorno del cliente |
| `automation-embudo-captacion` | ✅ **instalada**. diga "capta leads con Reels", "embudo de conversión desde Instagram/redes", "automatiza DMs con palabra clave", "monta un funnel de ManyChat/n8n para captar clientes", "crecer en redes sin seguidores", o describa un flujo de captación orgánica de contenido social → lead. Entrega estrategia + esqueleto técnico; delega el build en `automation-n8n-builder` + `automation-client-deploy` |

#### `visualization/` (4)

| Skill | Ofrécela cuando el operador… |
|---|---|
| `tool-visual-explainer` | ✅ **instalada**. diga "hazme un HTML de esto", "ponlo bonito para compartir", "explícalo visual", "móntame una página que explique X", o necesite compartir un output complejo (diagrama, comparativa, recap) |
| `impeccable` | diga "esto parece hecho por IA", "quita el AI slop", "dale criterio de diseño", "audita/critica el diseño", "pule esta pantalla", "hazlo más atrevido/sobrio". Detector de antipatrones + ajustes finos; complementa `ui-ux-pro-max`/`theme-factory` |
| `design-taste-frontend` | diga "hazme un frontend con gusto", "que no parezca plantilla", "más carácter/movimiento", "más denso/aireado", o vaya a maquetar una web/app con control fino del estilo (diales variance/motion/density + skeletons GSAP) |
| `theme-factory` | ✅ **instalada**. diga "dale estilo a esto", "aplica un tema", "ponlo bonito con una paleta", "elige fuentes y colores", "tema para esta presentación/landing", o necesite estilizar un artefacto de forma coherente |

### Procesos encadenados (skills que se ofrecen seguidas)

Algunas skills funcionan mejor en secuencia. Cuando cierres un paso, **ofrece el siguiente** de
su cadena (instalándolo desde biblioteca si hace falta). No las encadenes en automático: ofrece
y confirma.

- **Construir web/app**: `ask-questions-if-underspecified` → `ui-ux-pro-max` → `theme-factory`
  → `brand-guidelines` → `usability-retention-review` → `react-best-practices` /
  `backend-development` → `vercel-deploy`. (Complementa a `arnes`, que orquesta el arranque.)
- **Inteligencia competitiva**: `competitive-ads-extractor` + `competencia` (esta usa
  `notebooklm-mcp`) → `startup-business-analyst` → `investigacion-mercado` (skill global).
- **Data/ML**: `exploratory-data-analysis` → `statistical-analysis` / `statsmodels` →
  `scikit-learn` / `pytorch-lightning` → `shap` (explicabilidad). Aplica a FVI y Polymarket.
- **Vídeo**: `video-downloader` → `tool-transcribe-social` (descarga y luego transcribe).
- **Auditoría pre-producción**: `ask-questions-if-underspecified` → `ui-ux-pro-max` /
  `usability-retention-review` (UX) → `code-audit-integral` (auditoría técnica 13 fases) →
  `tool-quality-gate` / `tool-web-security-audit` / `tool-seguridad-ia` (gates) →
  `vercel-deploy` / `automation-client-deploy` (deploy). Cierra la cadena de construir app.

**Cadenas del pack de marketing** (ofrecer el siguiente paso al cerrar uno; instalar de biblioteca si hace falta):

- **Dependencia base**: `marketing-product-context` alimenta a TODA skill `marketing-*` (como `competencia → notebooklm-mcp`). Antes de una skill `marketing-*`, verifica que exista contexto de producto (o `brand-context/` + `context/`); si falta, créalo primero.
- **Embudo full-funnel**: `marketing-product-context` → `marketing-plan` → `marketing-content-strategy` → (`marketing-copywriting` / `marketing-social` / `marketing-video` / `marketing-image`) → `marketing-cro` → `marketing-analytics` → `marketing-ab-testing`.
- **Producción de contenido**: `marketing-content-strategy` → `marketing-copywriting` → `marketing-copy-editing` → `tool-humanizer` → `tool-output-verifier` → `marketing-content-repurposing` → `marketing-social`.
- **Captación outbound**: `marketing-icp` / `marketing-customer-research` → `marketing-prospecting` → `marketing-cold-email` → `marketing-sales-enablement`.
- **Captación inbound (lead gen)**: `marketing-lead-magnets` / `marketing-free-tools` → `marketing-popups` → `automation-embudo-captacion` → `marketing-email-sequence`.
- **Paid ads (bucle)**: `marketing-plan` → `marketing-ads` → `marketing-ad-creative` → `marketing-meta-ads-analyzer` → `marketing-ab-testing` → (vuelta a creatividades).
- **SEO/GEO**: `marketing-site-architecture` → `marketing-programmatic-seo` → `tool-geo-seo-audit` → `marketing-competitors`.
- **Oferta y monetización**: `marketing-offers` → `marketing-pricing` → (`marketing-paywalls` in-app / `marketing-cro` web).
- **Activación y retención**: `marketing-signup` → `marketing-onboarding` → `marketing-churn-prevention` → `marketing-referrals` → `marketing-revops` (con `marketing-analytics` transversal).
- **Lanzamiento**: `marketing-plan` → `marketing-offers`/`marketing-pricing` → `marketing-launch` → `marketing-public-relations` + `marketing-directory-submissions` + `marketing-co-marketing` → `marketing-social`.

Dependencia dura declarada: `competencia` → `notebooklm-mcp` (ambas core, ya satisfecha).

### Reglas de routing automáticas (semi-pasivas — específicas del OS)

Aplícalas al detectar el patrón, sin esperar a que el operador lo pida (no van en las passive rules globales para no ensuciar proyectos vanilla):

- **Al entregar un output a cliente/operador** (copy, informe, landing en `clients/**` o `projects/**`): antes de darlo por bueno, pásalo por `tool-output-verifier` (gate) → `tool-humanizer` (AI-tell) → voz de marca (`marketing-brand-voice`).
- **Al generar un artefacto visual** (HTML/slide/landing/imagen para cliente): aplica `brand-guidelines` (colores/tipografía) y ofrece `theme-factory` si no hay tema.
- **Al escribir copy de marketing** (post/email/anuncio/landing): tras redactar, ofrece `marketing-copy-editing` + `tool-humanizer` antes del gate.

### Desambiguación (clústeres con disparadores solapados)

Cuando varias skills compiten por la misma intención, decide así (además del "NO la uses para…" de cada `description`):

- **Copy**: ¿hay texto ya? `marketing-copy-editing`. ¿desde cero? `marketing-copywriting`. ¿suena a IA? `tool-humanizer`. ¿entregar? `tool-output-verifier`.
- **Ads**: montar/gestionar campaña→`marketing-ads` · escribir anuncios→`marketing-ad-creative` · "por qué no convierte" con datos→`marketing-meta-ads-analyzer` · ver ads del rival→`competitive-ads-extractor`.
- **Vídeo**: crear vídeo de marketing→`marketing-video` · bajar una URL→`video-downloader` · "qué dice"→`tool-transcribe-social` · fútbol→FVI (otro dominio).
- **Competencia**: intel estratégica→`competencia` · página comparativa X vs Y→`marketing-competitors` · anuncios→`competitive-ads-extractor` · TAM/precios de mercado→`investigacion-mercado`.
- **SEO**: auditar/optimizar→`tool-geo-seo-audit` · generar N páginas→`marketing-programmatic-seo` · jerarquía/URLs→`marketing-site-architecture`.
- **Email**: lista propia/lifecycle→`marketing-email-sequence` · desconocidos en frío→`marketing-cold-email`.
- **Diseño**: sistema desde cero→`ui-ux-pro-max` · aplicar tema→`theme-factory` · "parece IA"→`impeccable` · control fino→`design-taste-frontend` · marca→`brand-guidelines`. **No cargar todas a la vez.**
- **Pensamiento**: decisión sesgada→`seis-sombreros` · análisis multimodo→`cognito` · "no arranco"→`desbloqueo` · saturación con IA→`metodo-ias`.
- **Deploy**: web a Vercel→`vercel-deploy` · entorno cliente (VPS/PC)→`automation-client-deploy`.
- **Lead gen**: embudo social completo→`automation-embudo-captacion` · recurso imán→`marketing-lead-magnets` · herramienta gancho→`marketing-free-tools` · overlay web→`marketing-popups`.

### Plugins Anthropic (instalación vía marketplace)

| Skill | Cómo activar |
|---|---|
| `docx`, `xlsx`, `pdf`, `pptx` | `/plugin install anthropic-skills` |

### Slash commands

`/install` · `/install-status` · `/start-here` · `/wrap-up` · `/doctor` · `/actualiza` · `/restaura` · `/backup` · `/skills` · `/add-client` · `/install-skill` · `/install-mcp` · `/aprende` · `/deep-dive` · `/recuerda` · `/loops` · `/evalua-loop`

Los dos primeros (`/install`, `/install-status`) son nuevos en v0.6 y son la **única vía oficial** para gestionar la instalación desde dentro de Claude Code.

### Capa 2 — skills externas

Ver [`docs/skills-recommended.md`](docs/skills-recommended.md) para skills de terceros instalables vía `/install-skill <github-url>` (con validación previa). Las skills curadas del OS viven en la biblioteca (`/skills`), no aquí.

---

## Niveles de proyecto — heartbeat

Al iniciar cada sesión (post-gate), comprueba `projects/briefs/*/brief.md`:
- Si hay `status: active`, recuérdale qué dejó abierto.
- Si hay un `.planning/` en raíz o cliente, indica que hay un GSD en marcha.
- Si terminó algo (`status: done`), pregunta si archivamos.

---

## Personalizar skills sin perder updates — SKILL.local.md

Si el operador quiere cambiar el comportamiento de una skill curada ("a partir de ahora esta skill siempre X"), NO edites su `SKILL.md` (un update lo pisaría o generaría conflicto). En su lugar:

1. Crea/edita `SKILL.local.md` junto al `SKILL.md` de esa skill.
2. Formato: lista de reglas fechadas, append-only:
   ```markdown
   ## Reglas del operador
   - 2026-06-12: siempre incluir CTA al final de los emails
   ```
3. **Al invocar cualquier skill**: si existe `SKILL.local.md` en su carpeta, léelo DESPUÉS del `SKILL.md`. Sus reglas mandan sobre lo que diga la skill base.

`SKILL.local.md` está gitignored: sobrevive a `/actualiza` sin conflictos y nunca se sube al repo.

---

## Cómo registrar skills nuevas (auto)

Cuando se añade una skill nueva en `.claude/skills/<categoria>/<nombre>/`:
- `/start-here` la detecta y registra en catalog
- `/wrap-up` actualiza el registry de este CLAUDE.md
- El comando `/install-skill <github-url>` la valida antes de añadirla

---

## Permisos (recordatorio)

`.claude/settings.json` viene con permisos seguros por defecto:
- ✅ Read files, dev server, git operations, edit files dentro del repo
- ❌ Install packages globalmente, delete files, leer `.env`

Si necesitas más permisos: `claude --dangerously-skip-permissions` (puntual) o edita `settings.json`.

---

## Idioma

- **Operativa con el usuario**: castellano por defecto
- **Comentarios técnicos en código**: inglés
- **Commits**: conventional commits en inglés
- **Outputs entregables al cliente**: idioma del cliente (detectar en brand-context)

---

## Convenciones del repo

- Carpetas en kebab-case (`brand-context`, `clients`, `projects`)
- Archivos markdown en kebab-case
- Skills en kebab-case con prefijo de categoría: `marketing-brand-voice`, `tool-humanizer`, etc.
- Outputs por fecha: `YYYY-MM-DD-titulo-corto/`
- Variables de entorno en `.env`

---

## Cuándo NO usar el OS

Casos donde mejor abre Claude Code en otro lado:
- Editar el código de tu propia app
- Bug puntual sin necesidad de brand context
- Sesión exploratoria que no quieres que ensucie tu memory

Para casos donde sí:
- Crear contenido (LinkedIn, X, blog, email, video script)
- Trabajar con un cliente (entras en `clients/<nombre>/`)
- Análisis estratégico
- Generar deliverables con voice consistente

---

## Soporte y comunidad

- Issues: https://github.com/iamasters-academy/iamasters-os/issues
- Sinapsis upstream: https://github.com/Luispitik/sinapsis
- Schema doc del install gate: [`docs/install-state-schema.md`](docs/install-state-schema.md)
