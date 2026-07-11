# iAmasters OS — CLAUDE.md (project root)

> Sistema operativo agéntico para operadores de IA.
> Sinapsis (engine de memoria) + capa OS (brand context, agent context, skills curadas, multi-cliente).
>
> **Este fichero es OPERATIVO y se carga cada sesión** (routing de skills, ritual de
> inicio, cadenas). Si acabas de recibir la URL del repo para **instalar** el OS,
> lee **`AGENTS.md`** (guía plug-and-play de instalación), no este fichero.

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
3. **El hook SessionStart (`_install-gate.sh`) ya inyecta este aviso automáticamente cuando aplica.** Esta sección es tu *backup* por si el hook falla.

**Nunca durante una instalación incompleta**: reportar "todo instalado" cuando el state dice lo contrario · crear `.json`/`.md` a mano para "completar" fases · marcar fases `done` sin validación · avanzar a tareas del usuario con fases `required` pendientes.

**Si el usuario dice "para" / "ya no quiero seguir"**: marca `pausedBy: "user"` con la fase actual, despídete ("Cuando vuelvas, `/install --resume` retoma desde aquí") y no insistas. **Si dudas del estado**: `/install-status` (solo lectura).

---

## Session Entry — EXECUTE ON FIRST MESSAGE OF EVERY SESSION

(Una vez que el INSTALLATION GATE de arriba ha pasado.)

### Paths absolutos (relativos a este repo)
- **Skills del OS**: `.claude/skills/` · **Commands**: `.claude/commands/`
- **Brand context**: `brand-context/` (voice, positioning, ICP, assets)
- **Agent context**: `context/` (working-memory.md, me.md, work.md, team.md, current-priorities.md, goals.md, decisions-log.md, learnings.md, soul.md)
- **Proyectos**: `projects/` · **Clientes**: `clients/<nombre>/` (templates en `clients/_templates/`)
- **Catálogo de skills**: `synapsis/skills-catalog.json` (fuente de verdad, self-healing) · índice para routing: `synapsis/skills-registry.md`
- **Vendored**: `vendor/sinapsis/` (engine), `vendor/cognito/`, `vendor/arnes/`

### Paths Sinapsis (engine global del operador)
- **Skills root global**: `~/.claude/skills/` · **Operator state**: `~/.claude/skills/_operator-state.json`
- **Install state (v0.6+)**: `~/.claude/skills/_install-state.json` ← fuente de verdad de la instalación
- **Instincts**: `~/.claude/skills/_instincts-index.json` · **Daily summaries**: `~/.claude/skills/_daily-summaries/`

### MANDATORY first action (post-gate)
Antes de responder al primer mensaje:
1. Lee `~/.claude/skills/_operator-state.json` (perfil del operador, decisiones, lecciones).
2. Lee `context/working-memory.md` — scratchpad de trabajo (hilos activos / notas de entorno / decisiones pendientes).
3. Lee los sectorizados de `context/` si existen: `me.md`, `work.md`, `team.md`, `current-priorities.md`, `goals.md`.
4. Lee `context/decisions-log.md` (últimas 5 entradas) y `context/learnings.md` (feedback de skills).
5. Lee cualquier plan activo en `.claude/plans/` si existe.
6. Lee `synapsis/daily-summaries/<TODAY>.md` o `<YESTERDAY>.md` (continuidad diaria).

### Session continuity
Con todo configurado: saluda con "Ayer dejaste X. ¿Sigues con Y o cambias?" cruzando el daily summary de ayer + `learnings.md` + proyectos abiertos en `projects/briefs/*/brief.md` con `status: active`.

### Memoria de trabajo (memo manual)
Cuando el operador diga *"recuerda esto"*, *"apunta que"*, *"nota que"* o *"para la próxima"*, escribe el ítem en la sección correspondiente de `context/working-memory.md` (Hilos activos / Notas de entorno / Decisiones pendientes), con dedup y respetando el tope (~2.500 car.).

---

## Actualizar el OS

Cuando el usuario diga **"actualízate"**, **"actualiza el OS"**, **"tráete los cambios nuevos"** o **"update"** → comando `/actualiza` (`git pull --ff-only` + `bash scripts/update.sh`). `update.sh` preserva SIEMPRE lo del operador (skills propias, `brand-context/`, `context/`, `projects/`, `clients/`, `loops/`); solo actualiza código del OS, skills curadas y Sinapsis vendored. Si `git pull` falla por cambios locales, NO fuerces: explica y pregunta. **Si algo se rompe** → `/restaura` (rollback código + datos desde `.backup/`).

---

## Skills — modelo Core + Biblioteca

Las **core** viven en `.claude/skills/` (siempre cargadas, el OS las necesita); la **biblioteca** en `skills-library/` es instalable a demanda con `/skills`. **Los recuentos (total/core/instaladas/activas) NO se hardcodean aquí** — viven en la cabecera del índice generado (`synapsis/skills-registry.md`, abajo) y en vivo en `bash scripts/skills.sh list`. Cada skill activa consume contexto en cada sesión (recomendación Anthropic: <50 cargadas) — instala solo lo que uses; en el tope, cada install nueva exige un retiro (swap).

> **Arquitectura (para no confundir en auditorías)**: una skill instalada vive **a la vez** en
> `skills-library/<cat>/<nombre>/` (fuente, coste cero) y en `.claude/skills/<cat>/<nombre>/` (copia
> activa). Es **intencional**, no duplicación: `skills.sh add` copia, `remove` borra la copia activa,
> `sync` la refresca. La **fuente de verdad** es `synapsis/skills-catalog.json` (self-healing, cuenta
> skills distintas). Algunas skills citadas en cadenas/desambiguación son **globales**
> (`~/.claude/skills/`, p. ej. `investigacion-mercado`, `graphify`, las `notebooklm-*`) y no viven en
> este repo — se marcan "(skill global)".

**Routing por intención (OBLIGATORIO — actívalo en CADA petición)**: antes de responder que no puedes hacer algo, o de resolverlo a mano, contrasta SIEMPRE la intención del operador contra la tabla de **Biblioteca** del índice de abajo (columna "Ofrécela cuando…" = los disparadores de cada skill no instalada). Si una encaja, NO la ignores ni la resuelvas tú: ofrécela → "Eso lo hace la skill `<nombre>`. ¿La instalo?" → `bash scripts/skills.sh add <nombre>`. Las **activas** (Core y las ✅ instaladas) se cargan solas: invócalas directamente cuando la intención encaje, sin preguntar. Catálogo en vivo: `bash scripts/skills.sh list`.

**Fallback obligatorio (auto-activación de `find-skills`)**: si la intención **no encaja con NINGUNA** skill —ni Core, ni Biblioteca instalada, ni Biblioteca disponible—, **antes de decir "no puedo" o resolverlo a mano, invoca automáticamente `find-skills`** (core `_meta/find-skills`) para buscar en el ecosistema externo (`npx skills`). No esperes a que el operador diga "busca una skill": el no-match del catálogo del OS ES el disparador. Solo si `find-skills` tampoco encuentra nada, resuelve con capacidades generales y sugiere crearla con `meta-skill-creator` si es recurrente.

### Índice de skills (generado — mapa de activas + tabla de Biblioteca con disparadores)

@synapsis/skills-registry.md

> El índice de arriba lo regenera `scripts/regen-registry.mjs` desde el catálogo tras cada
> `skills.sh add/remove/sync/catalog` (nunca deriva). No lo edites a mano.

### Procesos encadenados (skills que se ofrecen seguidas)

Cuando cierres un paso, **ofrece el siguiente** de su cadena (instalándolo de biblioteca si hace falta). No las encadenes en automático: ofrece y confirma.

- **Construir web/app**: `ask-questions-if-underspecified` → `spec-kit` → `ui-ux-pro-max` → `theme-factory` → `brand-guidelines` → `usability-retention-review` → `react-best-practices` / `backend-development` → `vercel-deploy`. (Complementa a `arnes`, que orquesta el arranque.)
- **Legal (agencia)**: `legal-nda-triage` → `legal-contract-review` → `legal-compliance` (si hay datos personales/DPA). Siempre con disclaimer: análisis de apoyo, no asesoría jurídica.
- **Ventas (IA-PYMEs)**: `marketing-prospecting`/`marketing-cold-email` → `automation-crm` → `sales-call-prep` → `marketing-sales-enablement` → `sales-pipeline-forecast`.
- **Monetizar OSS**: `automation-fork-and-resell` → `arnes` → `tool-vps-hardening` → `automation-client-deploy`/`vercel-deploy` → `startup-business-analyst`.
- **Scraping → análisis**: `tool-scrape-router` → `tool-firecrawl-scraper`/otra → `strategy-web-research`/`investigacion-mercado` (skill global).
- **Bot web autónomo 24/7**: `ask-questions-if-underspecified` → `automation-web-bot` (diseño + scaffold) → `conclave` (build) → `tool-vps-hardening` → `automation-client-deploy` → `automation-loop-engine` (scorecard).
- **Inteligencia competitiva**: `competitive-ads-extractor` + `competencia` (usa `notebooklm-mcp`) → `startup-business-analyst` → `investigacion-mercado` (skill global).
- **Data/ML**: `exploratory-data-analysis` → `statistical-analysis` / `statsmodels` → `scikit-learn` / `pytorch-lightning` → `shap`. Aplica a FVI y Polymarket.
- **Vídeo**: `video-downloader` → `tool-transcribe-social`.
- **Auditoría pre-producción**: `ask-questions-if-underspecified` → `ui-ux-pro-max` / `usability-retention-review` → `code-audit-integral` → `tool-quality-gate` / `tool-web-security-audit` / `tool-seguridad-ia` → `vercel-deploy` / `automation-client-deploy`.

**Cadenas del pack de marketing** (ofrecer el siguiente al cerrar uno; instalar de biblioteca si hace falta):
- **Dependencia base**: `marketing-product-context` alimenta a TODA skill `marketing-*`. Antes de una `marketing-*`, verifica que exista contexto de producto (o `brand-context/` + `context/`); si falta, créalo.
- **Embudo full-funnel**: `marketing-product-context` → `marketing-plan` → `marketing-content-strategy` → (`marketing-copywriting`/`marketing-social`/`marketing-video`/`marketing-image`) → `marketing-cro` → `marketing-analytics` → `marketing-ab-testing`.
- **Producción de contenido**: `marketing-viral-radar` → `marketing-content-strategy` → `marketing-storytelling` → `marketing-copywriting` → `marketing-hooks` → `marketing-copy-editing` → `tool-humanizer` → `tool-output-verifier` → `marketing-content-repurposing` → `marketing-social` → `marketing-analytics`.
- **Producción de vídeo**: `marketing-video` → `tool-voicebox` → `tool-video-generator` **o** `tool-video-montage` **o** `tool-avatar-video` → `tool-opencut` → `tool-output-verifier` → `marketing-content-repurposing` → `marketing-social` **o** `marketing-autopublish`. E-commerce social: `marketing-autoecom`.
- **Captación outbound**: `marketing-icp`/`marketing-customer-research` → `marketing-prospecting` → `marketing-cold-email` → `marketing-sales-enablement`.
- **Captación inbound**: `marketing-lead-magnets`/`marketing-free-tools` → `marketing-popups` → `automation-embudo-captacion` → `marketing-email-sequence`.
- **Paid ads (bucle)**: `marketing-plan` → `marketing-ads` → `marketing-ad-creative` → `marketing-meta-ads-analyzer` → `marketing-ab-testing` → (vuelta a creatividades).
- **SEO/GEO**: `marketing-site-architecture` → `marketing-programmatic-seo` → `tool-geo-seo-audit` → `marketing-competitors`.
- **Oferta y monetización**: `marketing-offers` → `marketing-pricing` → (`marketing-paywalls` in-app / `marketing-cro` web).
- **Activación y retención**: `marketing-signup` → `marketing-onboarding` → `marketing-churn-prevention` → `marketing-referrals` → `marketing-revops` (con `marketing-analytics` transversal).
- **Lanzamiento**: `marketing-plan` → `marketing-offers`/`marketing-pricing` → `marketing-launch` → `marketing-public-relations` + `marketing-directory-submissions` + `marketing-co-marketing` → `marketing-social`.

Dependencia dura: `competencia` → `notebooklm-mcp` (ambas core, satisfecha).

### Reglas de routing automáticas (semi-pasivas — específicas del OS)
Aplícalas al detectar el patrón, sin esperar a que el operador lo pida:
- **Al entregar un output a cliente/operador** (copy, informe, landing en `clients/**` o `projects/**`): pásalo por `tool-output-verifier` → `tool-humanizer` → voz de marca (`marketing-brand-voice`).
- **Al generar un artefacto visual** (HTML/slide/landing/imagen): aplica `brand-guidelines` y ofrece `theme-factory` si no hay tema.
- **Al escribir copy de marketing**: tras redactar, ofrece `marketing-copy-editing` + `tool-humanizer` antes del gate.
- **Al construir código con agentes de IA** (feature/bug/fix que toca `.sh/.mjs/.js/.ts/.py/.ps1` o `hooks/`/`vendor/`/`scripts/`): activa `conclave` — planifica → fan-out (`Workflow`/`Agent`) → gate adversarial (`cognito`/`code-review`/`verify`) → doble OK → sellar y commitear. El hook `pre-commit` fuerza el doble OK en commits de código; sin sello, git bloquea (override consciente: `CONCLAVE_OVERRIDE=1`).

### Desambiguación (clústeres con disparadores solapados)
Cuando varias skills compiten por la misma intención (además del "NO la uses para…" de cada `description`):
- **Copy**: ¿hay texto ya? `marketing-copy-editing`. ¿desde cero? `marketing-copywriting`. ¿arco narrativo de un tema plano? `marketing-storytelling`. ¿suena a IA? `tool-humanizer`. ¿entregar? `tool-output-verifier`.
- **Publicar en redes** (⚠️ 3 skills solapan): `marketing-autopublish` (proyecto, pipeline AiToEarn) · `social-media-autopublish` (skill global, AiToEarn+Postiz) · `publicar-redes` (skill global, Upload-Post, imágenes manuales). Elige por la herramienta que el operador YA usa; no ofrezcas las tres.
- **Investigación NotebookLM** (⚠️ clúster global): `notebooklm-mcp` (proyecto core, MCP multi-fuente persistente sin alucinaciones) · `notebooklm` (global, chat simple) · `notebooklm-extractor` (global SDK, 8 preguntas por fuente) · `notebooklm-standard` (global SDK, genérico) · `notebooklm-experto-deepresearch` (global, crea notebook + deep research). Intel competitiva → `competencia` (envuelve `notebooklm-mcp`).
- **Ads**: montar campaña→`marketing-ads` · escribir anuncios→`marketing-ad-creative` · "por qué no convierte" con datos→`marketing-meta-ads-analyzer` · ver ads del rival→`competitive-ads-extractor`.
- **Vídeo**: guion/ideas→`marketing-video` · render corto AI→`tool-video-generator` · producción con research/archivo→`tool-video-montage` · edición/subtítulos→`tool-opencut` · avatar hablando→`tool-avatar-video` · voz en off/clonación→`tool-voicebox` · modelo concreto (Flux/Kling/Sora)→`tool-genai-studio` · bajar URL→`video-downloader` · "qué dice"→`tool-transcribe-social` · fútbol→FVI (otro dominio).
- **Competencia**: intel estratégica→`competencia` · página X vs Y→`marketing-competitors` · anuncios→`competitive-ads-extractor` · TAM/precios de mercado→`investigacion-mercado` (skill global).
- **SEO**: auditar/optimizar→`tool-geo-seo-audit` · generar N páginas→`marketing-programmatic-seo` · jerarquía/URLs→`marketing-site-architecture`.
- **Email**: lista propia/lifecycle→`marketing-email-sequence` · desconocidos en frío→`marketing-cold-email`.
- **Diseño**: sistema desde cero→`ui-ux-pro-max` · aplicar tema→`theme-factory` · "parece IA"→`impeccable` · control fino→`design-taste-frontend` · marca→`brand-guidelines`. **No cargar todas a la vez.**
- **Pensamiento**: decisión sesgada→`seis-sombreros` · análisis multimodo→`cognito` · "no arranco"→`desbloqueo` · saturación con IA→`metodo-ias`.
- **Deploy**: web a Vercel→`vercel-deploy` · entorno cliente (VPS/PC)→`automation-client-deploy`.
- **Automatizar tarea repetitiva**: ¿bot 24/7 en servidor sobre una web?→`automation-web-bot` · ¿loop local con Claude supervisando?→`automation-loop-engine` · ¿workflow API a API?→`automation-n8n-builder` · ¿extraer datos una vez?→`tool-scrape-router` · ¿solo el deploy de algo ya construido?→`automation-client-deploy`.
- **Scraping/crawling**: decidir herramienta + ejecutar→`tool-scrape-router` · Firecrawl directo→`tool-firecrawl-scraper` · investigar (no solo extraer)→`strategy-web-research`/`investigacion-mercado` (skill global) · redes (IG/TikTok/YT)→Apify MCP · "qué dice un vídeo"→`tool-transcribe-social` · bajar un vídeo→`video-downloader`. **Regla**: empezar por lo gratis (WebFetch nativo) y escalar solo si falla.

### Plugins Anthropic y skills externas
- Ofimática (`docx`, `xlsx`, `pdf`, `pptx`): `/plugin install anthropic-skills`.
- `knowledge-work-plugins` (finance/sales/legal/PM): `anthropics/knowledge-work-plugins`. Las de más valor ya están portadas a biblioteca (`legal-*`, `sales-*`, `finance-variance-analysis`).
- Terceros: `docs/skills-recommended.md`, instalables con `/install-skill <github-url>` (validación previa).

### Slash commands
`/install` · `/install-status` · `/start-here` · `/wrap-up` · `/doctor` · `/actualiza` · `/restaura` · `/backup` · `/skills` · `/add-client` · `/install-skill` · `/install-mcp` · `/aprende` · `/deep-dive` · `/recuerda` · `/loops` · `/evalua-loop`

Comandos Sinapsis (global): `/system-status` · `/evolve` · `/instinct-status` · `/passive-status` · `/eod` · `/dream` · `/analyze-session`

---

## Convenciones (cualquier agente)
- **Idioma operativo**: castellano. **Estilo**: directo, sin rodeos, 2-3 opciones máx con recomendación.
- **Validación humana** siempre antes de acciones destructivas. **Secretos**: nunca commitear `.env`, credentials, API keys.
- Commits: conventional commits en inglés. Comentarios de código en inglés; operativa con el usuario en castellano.

## Fin de sesión
`meta-wrap-up` (`/wrap-up`) se sugiere con >80% de contexto, después de las 17:00, o tras trabajo productivo (≥3 archivos). Guarda daily summary, sincroniza el catálogo/registro de skills y propone commit (espera aprobación).
