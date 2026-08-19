# Changelog

Todos los cambios notables a iAmasters OS se documentan aquí.

Formato basado en [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

---

## [Unreleased]

### Roadmap
- **P2 captura de contenido** (opcional) — resumen legible por sesión que engorda el corpus. Bajo valor incremental: ya hay daily summaries indexados; pendiente de decidir si aporta.
- **Team OS** — memoria/permisos compartidos para equipo. Módulo AVANZADO opcional (no core), decisión de negocio pendiente. (Antes etiquetado como v0.9.0; re-planificado al dedicar la v0.9.0 a Loop Engineering.)
- Skills nativas en español adicionales (proposal-writer, youtube-transcript, linkedin-posts) con voice profile del operador.
- Dashboard del OS (pendiente decidir si se integra con dashboard Sinapsis).
- Onboarding con extracción desde URL (web/LinkedIn del operador → brand-context automático vía Firecrawl).
- GitHub privado como destino adicional de `/backup` (versionado completo). Requiere `gh` autenticado y excluir `.env` del push — evaluar si la fricción compensa para miembros no técnicos.
- Loops desatendidos (ejecución programada sin sesión abierta) — decisión pendiente para v1.0.
- Test end-to-end de instalación en máquina limpia antes de v1.0.
- v1.0.0: release pública estable + vídeos Loom + landing en iamastersacademy.com/os.

---

## [0.11.2] — 2026-08-19

### Fixed
- **`/actualiza` reportaba como conflicto tuyo lo que él mismo acababa de traer.** `update.sh` no hace merge ni mueve `HEAD` —trae archivos con `git checkout origin/<rama> -- <archivo>` para no pisar nunca los datos del operador—, pero medía **todo** contra `HEAD`, que se queda atrás para siempre. Consecuencia: un archivo traído por una actualización previa parecía "editado por el operador" en cada actualización siguiente. Medido en sandbox: **33 conflictos falsos en una segunda pasada seguida, con el árbol perfectamente al día**, y un `git status` permanentemente sucio. Fue lo que hizo sospechar a `/doctor` de "archivos staged sin commit" al diagnosticar [#17](https://github.com/iamasters-academy/iamasters-os/issues/17), y la raíz que compartía con [#16](https://github.com/iamasters-academy/iamasters-os/issues/16). Ahora `update.sh` registra en `.claude/.upstream-state` (local, gitignored) qué commit upstream aplicó y mide contra **esa base**: si un archivo coincide con la versión ya aplicada, lo trajo el update anterior y no es una edición tuya. Una segunda pasada seguida responde **"Ya estás al día"**.
- **Los archivos que upstream retira nunca desaparecían de tu repo.** `git checkout origin/<rama> -- <ruta>` falla en silencio para una ruta que ya no existe en remoto (el `|| true` se lo comía), así que cada archivo renombrado o retirado upstream se quedaba para siempre. Ahora se retiran con tres salvaguardas: **nunca** datos del operador (`brand-context/`, `context/`, `projects/`, `clients/`, `.env`, `loops/`, `settings.json`), **nunca** si tú habías editado el archivo (se mantiene y se avisa), y **copia al backup** antes de tocar nada. `.claude/skills/` se excluye a propósito: de ese árbol se encarga `_flatten-skills.sh`, que además rescata los `SKILL.local.md`.
- **`rollback.sh` invalida el estado de upstream.** Volver atrás deja el árbol en un punto anterior, así que el commit registrado como aplicado ya no describe lo que hay en disco; el siguiente `/actualiza` vuelve a medir contra `HEAD` en vez de fiarse de una base falsa.

### Notas
- Verificado con 8 escenarios en sandbox: convergencia en dos pasadas, edición real del operador preservada y reportada, datos del operador intocables, primer update sin estado (retrocompatible), retirada de archivos obsoletos con copia en backup, retirada bloqueada cuando el operador editó el archivo, camino completo de migración desde v0.10.2 (0 → 17 skills, 6/6 checks) y rollback.
- Si vienes de **≤ v0.10.2**: el ruido de conflictos aparece una última vez (tu `update.sh` en disco es el antiguo y no registra la base todavía) y a partir de la actualización siguiente queda limpio.

---

## [0.11.1] — 2026-08-19

Ronda de auditoría tras la v0.11.0: se revisaron los scripts, las skills, la documentación y los issues/PRs abiertos. Todo lo de aquí son fallos reales encontrados y verificados, no limpieza cosmética.

### Fixed
- **Las skills que el operador archiva reaparecían en cada `/actualiza`** ([#16](https://github.com/iamasters-academy/iamasters-os/issues/16), reportado por un miembro el 21-jul). Quien retira una skill core de `.claude/skills/` (para no gastar contexto por sesión) la veía volver en cada actualización y tenía que quitarla otra vez a mano. La causa **no** era `skills.sh sync` como suponía el reporte —ese salta las core a propósito— sino el `git checkout origin/<branch> -- <archivo>` de `update.sh`: al no existir la ruta en local, la clasificaba como "skill nueva" y la restauraba. Ahora `update.sh` comprueba si la skill está en `.claude/skills/_archived/<nombre>/` y respeta la decisión del operador, informando de cuáles ha respetado. Verificado en sandbox: las archivadas no vuelven y el resto se actualiza con normalidad.
- **`/doctor` daba errores rojos falsos justo después de actualizar** ([#19](https://github.com/iamasters-academy/iamasters-os/pull/19)). El check de profundidad recorría también el `.backup/<fecha>/` que crea `update.sh`, que guarda **a propósito** la estructura antigua anidada. Se excluyen los roots `.backup*/`, `vendor/`, `_archivado/`, `node_modules/` y `.git/`.
- **El escáner de secretos crasheaba con un traceback de Python** ([#20](https://github.com/iamasters-academy/iamasters-os/pull/20)). Leía todas las rutas de `git ls-files` sin tolerar que un archivo esté en el índice pero ya no en disco — exactamente el estado que deja la migración de estructura antes de commitear.
- **Seis skills remitían a un `references/examples.md` que nunca se creó**: `marketing-icp`, `marketing-positioning`, `marketing-brand-voice` y `tool-output-verifier` (core), `marketing-copywriting` y `marketing-content-repurposing` (biblioteca). Claude seguía la instrucción, intentaba leer el archivo y fallaba en silencio. Donde los casos ya estaban enumerados en el propio `SKILL.md` se conservan; donde la sección quedaba vacía se retira. Los ejemplos de ICP, posicionamiento y voz salen del criterio del operador: no se inventan aquí.
- **Una skill de la biblioteca invocaba una skill personal del autor que no existe en el repo**: `tool-web-legal-audit` hacía "invoca la skill `whatsapp`" con el `.docx` de la auditoría. Ningún miembro tiene esa skill. Ahora entrega la ruta y ofrece usar la skill de envío que el operador tenga, sin asumirla.
- **`marketing-content-repurposing` citaba `strategy-trending-research`** como si existiera; esa skill nunca se creó (aparece como "futura" en la presentación de equipo). Reformulado sin la dependencia fantasma.
- **`docs/multi-client-guide.md` mandaba ejecutar `bash scripts/sync-synapsis.sh`** ("futura skill v0.5") — script que no existe, y con "Sinapsis" mal escrito. Reescrito el troubleshooting con el comportamiento real: las skills se cargan desde el directorio de arranque hacia arriba, las de un subdirectorio (`clients/<nombre>/`) no entran hasta que Claude toca un archivo de ahí, y toda skill debe estar a un nivel.
- **Precedencia de `find` en `scripts/install.sh`**: `-type f -name "_*.json" -o -name "_*.sh"` no aplicaba `-type f` al segundo patrón, así que un directorio llamado `_algo.sh` entraba en el checksum de integridad de Sinapsis y podía provocar un falso positivo de drift. Agrupado con paréntesis.

### Added
- **`skill_archived_by_operator()`** en `scripts/update.sh`: para retirar una skill core, mueve su carpeta a `.claude/skills/_archived/<nombre>/` con el nombre exacto. Las copias que archiva `_flatten-skills.sh` llevan sufijo `-anidada-<fecha>` y no cuentan como decisión del operador, así que no interfieren.

### Notas
- Los arreglos de `update.sh` viajan dentro de `update.sh`, que se sobrescribe a sí mismo durante `/actualiza`: **empiezan a aplicar a partir de la actualización siguiente**. Si vienes de ≤ v0.10.2 y tenías skills archivadas, en la primera pasada pueden volver una vez; vuelve a archivarlas y no reaparecerán más.

---

## [0.11.0] — 2026-08-18

### Fixed
- **🔴 NINGUNA skill del OS cargaba en Claude Code.** Reportado por **Andrés Arias** (miembro de la comunidad) con reproducción en dos entornos independientes — [issue #17](https://github.com/iamasters-academy/iamasters-os/issues/17). Toda skill instalada en `.claude/skills/<categoria>/<nombre>/SKILL.md` (las 17 core y cualquiera añadida desde la biblioteca) respondía `Error: Unknown skill: <nombre>` al invocarla, y no aparecía en el listado de la sesión. **Causa raíz**: Claude Code descubre skills a **exactamente un nivel** — `<skills-dir>/<nombre>/SKILL.md`. El loader del CLI lee `<dir>/SKILL.md`, y si no lo encuentra prueba `<dir>/<entrada>/SKILL.md` y se detiene ahí: no hay recursión. Una carpeta de categoría intermedia deja la skill invisible aunque el archivo exista y el frontmatter sea válido. Las subcarpetas de una skill son sus recursos (`references/`, `scripts/`), nunca skills anidadas. **No era un bug de Claude Code ni una regresión de una versión reciente: el patrón nunca funcionó.** Lo que sí cargaba —y ocultaba el problema— eran los `.claude/commands/*.md`.
- **`/doctor` fallaba con el mismo error** (`.claude/commands/doctor.md`): invocaba la skill por ruta (`_meta/health-check`) en vez de por nombre (`health-check`). Una ruta no es un nombre de skill válido.
- **Drift en la lista de skills mínimas** (skill `health-check`): declaraba 24 rutas "v0.6 Capa 1" cuando solo 17 son core — 8 pasaron a la biblioteca en v0.10.0 (opt-in) y faltaba `recuerda` (core desde v0.8.1). Provocaba avisos 🟡 fantasma por skills cuya ausencia es normal.
- **Rutas de instalación rotas dentro de la biblioteca**: `tool-transcribe-social` documentaba un `python3 .claude/skills/tools/tool-transcribe-social/transcribe.py` que no existiría tras instalarse (ruta **ejecutable**, fallaba al correr). Igual en el README de `strategy-investigacion-profunda` y en los wrappers de `arnes` y `cognito`, que además describían el patrón `_optional/` retirado en v0.10.0.
- **`.github/CODEOWNERS`** apuntaba a `/.claude/skills/_meta/` y `/.claude/skills/marketing/`, rutas que dejan de existir: las reglas quedaban muertas. Ahora cubre `/.claude/skills/` y `/skills-library/`.

### Changed
- **`/actualiza` ya no reporta un rename como conflicto del operador** (`scripts/update.sh`). Clasificaba cualquier ruta presente en local como "skill modificada → potencial conflicto", sin comprobar si seguía existiendo upstream. Al mover 17 skills, el informe se llenaba de conflictos falsos y el operador no sabía qué mirar. Ahora una ruta que ya no existe en `origin` se marca como obsoleta y la archiva la migración. Verificado en el E2E: de 5 falsos conflictos a 0.
- **Estructura de instalación PLANA (breaking).** El destino pasa a `.claude/skills/<nombre>/SKILL.md`. Las 17 core aplanadas con `git mv` (historial preservado) y `scripts/skills.sh` instala, lista, sincroniza y desinstala en plano. **La categoría no se pierde**: sigue viva en la **biblioteca** (`skills-library/<categoria>/<nombre>/`, que es un catálogo y por diseño NO se indexa) y en el **prefijo del nombre** (`marketing-`, `tool-`, `strategy-`, `automation-`).
- **Documentación corregida en origen.** `docs/skill-creation-guide.md` documentaba el patrón roto como "estructura canónica" — de ahí se propagó a todo el repo. Reescrita explicando el contrato de un nivel, por qué falla el anidamiento y dónde vive la categoría. Actualizadas 20 referencias más en `AGENTS.md`, `CLAUDE.md`, commands, `meta-skill-creator`, `docs/` y `scripts/validate-skill.sh`. `CHANGELOG` histórico intacto a propósito.
- **El nombre de invocación lo da la CARPETA**, no el `name:` del frontmatter (para skills de proyecto). Documentado y validado.

### Added
- **`scripts/_flatten-skills.sh`** — migración de estructura como script autónomo, invocado por `/actualiza`. Idempotente, **no borra nada** (si el destino ya existe, la copia anidada se archiva en `.claude/skills/_archived/`) y **rescata el `SKILL.local.md`** del operador a la ruta nueva antes de archivar. Vive en su propio archivo por dos razones verificadas en un E2E que reproduce una instalación v0.10.2 real: (a) `update.sh` se sobrescribe a sí mismo durante el update y bash sigue ejecutando la versión antigua ya cargada, así que una migración escrita dentro de `update.sh` no corre hasta el update *siguiente*; (b) suelto, da a quien ya tenía el OS instalado un comando único: `bash scripts/_flatten-skills.sh`.
- **Guardarraíl de CI** `scripts/ci/check-skills-depth.sh` (cableado en `validate.yml`): falla si aparece una `SKILL.md` a más de un nivel bajo cualquier `.claude/skills/` del repo, si `skills-library/` pierde su categoría, y avisa si `name:` no coincide con la carpeta. `_archived/` exento: está anidado a propósito para no cargar. Verificado que caza la regresión.
- **Check de estructura en la skill `health-check`** (`/doctor`): ahora detecta skills anidadas con severidad 🔴 y explica el arreglo. Es el chequeo que habría cazado esto antes de llegar a la comunidad.

### Cómo actualizar si ya tenías el OS instalado (≤ v0.10.2)

Di **"actualiza"**. Eso te trae ya las skills en la ruta correcta y **empiezan a funcionar**. Como tu `update.sh` en disco era el antiguo, la limpieza de las carpetas viejas necesita una pasada más — cualquiera de las dos:

```bash
bash scripts/_flatten-skills.sh
```

o simplemente di **"actualiza"** otra vez. Reinicia Claude Code al terminar. No se borra nada: lo viejo se archiva en `.claude/skills/_archived/` y tus `SKILL.local.md` se rescatan a la ruta nueva. `/doctor` avisa 🔴 si queda algo anidado.

---

## [0.10.2] — 2026-07-17

### Fixed
- **Los hooks de Sinapsis no se cableaban si `~/.claude/settings.json` ya existía** (`scripts/install.sh`). El instalador vendored de Sinapsis, ante un `settings.json` preexistente (el caso de casi todos los usuarios de Claude Code), solo imprimía *"merge manually"* y NO registraba sus hooks. Consecuencias: (a) en máquinas cuyo `settings.json` no tenía sección `hooks`, la validación profunda abortaba la instalación con *"Sinapsis se ejecutó pero la validación profunda falla"*; (b) en las que sí tenían hooks de otra cosa, la validación pasaba en falso y **el motor de aprendizaje de Sinapsis quedaba inerte sin avisar**. Nuevo `ensure_sinapsis_hooks()`: deep-merge **idempotente** de los 7 hooks de la plantilla de Sinapsis dentro del `settings.json` del operador, preservando permisos/config/hooks previos. El upstream de Luis (v4.8.0) tampoco resuelve esto, por eso se arregla en la capa OS.
- **Validación profunda endurecida** (`scripts/install.sh`, skill `health-check`): antes comprobaba solo 3 de los 7 hooks y un `grep '"hooks"'` que daba falso OK. Ahora valida los 7 hooks y el **cableado real** de los activadores en `settings.json`.
- **Error fantasma en `/install-status`** (`scripts/install.sh`): `mark_phase_done` no limpiaba el array global `errors[]`, así que un fallo de un intento previo seguía apareciendo tras un reintento exitoso. Nuevo `clear_phase_errors()`; se purga al completar o revalidar una fase.

### Changed
- **Instalación sin terminal (primary path).** Claude Code ahora **ejecuta el installer por ti** con tu OK, en vez de mandarte a una terminal. Nuevo comando **`/instala`** (y disparadores en lenguaje natural: "instala esto", "install this", "set this up") que detecta el SO, corre `bash scripts/install.sh` (Mac/Linux y Windows vía Git Bash), verifica y sigue con el onboarding. Alineados `CLAUDE.md` (install gate), `/install`, `AGENTS.md` y `README.md`, que antes se contradecían (AGENTS decía "ejecútalo" y el gate lo prohibía).
- **`/actualiza` ahora también REPARA los hooks.** `update.sh` re-cablea los hooks de Sinapsis al final (vía el nuevo `scripts/_ensure-sinapsis-hooks.sh`, compartido con `install.sh`). Así, los miembros que ya tenían el motor de aprendizaje inerte (por haber instalado con la versión previa) quedan arreglados con solo decir **"actualiza"** — sin reinstalar. Idempotente y preserva permisos/config/hooks del operador.

---

## [0.10.1] — 2026-06-12

### Changed
- `/backup` ahora detecta también **Google Drive** y **OneDrive** (además de iCloud y Dropbox), incluyendo las rutas `CloudStorage` modernas de macOS y "Mi unidad" en español. La primera vez, el OS pregunta al operador en qué nube quiere sus copias y guarda la elección en `.env` (`IAMASTERS_BACKUP_DIR`); nunca vuelve a preguntar. Nuevos flags: `--where` (nubes detectadas) y `--dest <ruta>`.

---

## [0.10.0] — 2026-06-12

**Skills a la carta.** Se acabó instalar las 35 skills a todo el mundo: ahora el OS trae 17 core (las que el sistema necesita) y las otras 20 viven en la biblioteca, visibles pero sin gastar contexto hasta que el operador las instala. Anthropic recomienda no pasar de ~50 skills cargadas; con este modelo el catálogo puede crecer sin límite.

### Added
- **Modelo Core + Biblioteca**: 17 skills core en `.claude/skills/` + 20 instalables en `skills-library/` (incluye absorber el antiguo `_meta/_optional/`: cognito y arnes pasan a la biblioteca).
- **`/skills`** (`scripts/skills.sh`) — catálogo y gestión: `list` (instaladas vs disponibles con descripción), `add <nombre>` (con resolución automática de dependencias), `remove <nombre>` (las core no se pueden quitar), `sync` (refresca instaladas tras `/actualiza`). `SKILL.local.md` se preserva en todo el ciclo: instalar, quitar, reinstalar y sincronizar.
- **Routing por intención**: si el usuario pide algo que resuelve una skill de biblioteca no instalada, el agente ofrece instalarla en vez de decir que no puede.

### Changed
- `/install-skill <nombre>` (modo atajo) ahora instala desde la biblioteca vía `scripts/skills.sh`; el modo URL de GitHub sigue igual con validación previa.
- `scripts/update.sh` ejecuta `skills.sh sync` al final: las skills de biblioteca instaladas se refrescan solas con cada actualización.
- CI `check-skills-registry.sh` valida el registry contra ambas raíces (`.claude/skills/` + `skills-library/`).

---

## [0.9.2] — 2026-06-12

**Resilience pack.** El OS se respalda, se actualiza y se recupera solo: `/backup` a iCloud/Dropbox, `/restaura` como botón de deshacer de `/actualiza`, updates no-interactivos que nunca pisan lo del operador, y state de instalación que siempre dice la verdad.

### Added
- **`/backup`** (`scripts/backup.sh`) — copia de seguridad de todo lo irreemplazable del operador (context, brand-context, projects, clients, loops, .env, skills propias + memoria Sinapsis global: operator-state, instincts, daily summaries). Destino automático: iCloud → Dropbox → `~/iAmasters-Backup/` (override con `IAMASTERS_BACKUP_DIR` en `.env`). Rotación: últimos 7. `/wrap-up` lo sugiere si el último backup tiene >7 días.
- **`/restaura`** (`scripts/rollback.sh`) — botón de deshacer de `/actualiza`: devuelve código Y datos al estado previo a la última actualización. Antes de restaurar guarda snapshot del estado actual (`.backup/pre-rollback-*`), así el rollback también es reversible. `update.sh` ahora escribe `META.txt` (commit pre-update) en cada backup.
- **Convención `SKILL.local.md`** — personalizaciones del operador sobre skills curadas en archivo aparte (gitignored): sobreviven a `/actualiza` sin conflictos. El agente lo lee tras el `SKILL.md` y sus reglas mandan. (Patrón inspirado en agentic-os de Simon C.)

### Fixed
- `scripts/update.sh` — un fetch fallido quedaba enmascarado por el pipe a `tail` y `git rev-parse` sin `--verify` devolvía el nombre del ref inexistente: el script creía que había cambios upstream y abortaba a mitad con un error críptico. Ahora distingue "rama no está en origin" (update local-only, exit limpio) de "sin conexión/permisos" (error claro).

### Changed
- `scripts/update.sh` — modo no-interactivo automático cuando no hay TTY (p. ej. lanzado por Claude vía `/actualiza`): nunca pregunta, mantiene la versión local ante cualquier conflicto y lista "Pendientes de decisión" al final para resolverlos conversacionalmente. Antes, los prompts interactivos colgaban el flujo "sin terminal". Además ya no pisa archivos con cambios locales sin commitear.
- `scripts/install.sh` — la validación profunda de `sinapsis-engine` ahora escribe los resultados reales de cada check en `_install-state.json` (antes quedaban los `false` del template aunque todo pasara, confundiendo a `/install-status` y al gate).

---

## [0.9.1] — 2026-06-11

### Added
- Comando `/actualiza` y disparadores en lenguaje natural ("actualízate a la última versión", "update"...) → corre `git pull` + `bash scripts/update.sh` preservando el contenido del operador. Pensado para miembros no técnicos: actualizan sin tocar la terminal.
- Sección "Actualizar el OS" en `CLAUDE.md` y rama en `docs/quickstart.md`.

---

## [0.9.0] — 2026-06-11

**Loop Engineering release.** El OS aprende a convertir trabajo repetitivo en sistemas: `automation-loop-engine` como skill core, 5 plantillas de loops listas para usar, 8 skills nuevas portadas del arsenal de Angel, catálogo 100% en español y CI anti-drift.

### Fixed
- Sincronizadas las menciones de Sinapsis vendored a v4.6.1 en README y CITATION.
- Unificado el conteo documental a 35 skills core + 2 opcionales (cognito, arnes).
- Añadido H1 descriptivo al comando `.claude/commands/doctor.md`.
- Ajustada la detección de Python en `scripts/install.sh` para separar candidatos POSIX de `py -3` en Windows/Git Bash.

### Added
- `docs/automatizaciones.md` — guía de loops programados y rutinas para hacer que el OS trabaje solo.
- CI de validación anti-drift en `.github/workflows/validate.yml` con checks locales reutilizables.
- Nueva guía `docs/skill-creation-guide.md` con patrón real de skills, frontmatter, validación y ejemplo mínimo.
- Nueva plantilla `brand-context/glossary-template.json` para correcciones STT de `tool-zoom-summary`.
- `automation-loop-engine` (Loop Engineering) como skill core + carpeta `loops/` + comandos `/loops` y `/evalua-loop` + integración con `health-check`, `/recuerda` y `working-memory`.
- 5 plantillas de loops (`contenido-semanal`, `propuestas`, `triaje-leads`, `informe-cliente`, `revision-semanal`) + `docs/loop-engineering.md`.
- `tool-seguridad-ia` — prompts preventivos y checklist pre-deploy de seguridad para desarrollo con IA.
- `tool-quality-gate` — validación pre-deploy con setup de tests y score 0-100.
- `marketing-meta-ads-analyzer` — diagnóstico experto de campañas Meta Ads con Breakdown Effect.
- `tool-transcribe-social` — transcripción de Reels/TikTok/Shorts con Groq Whisper y fallback claro.
- `tool-web-legal-audit` — auditoría RGPD/LSSI/cookies/accesibilidad con evidencias y remediación.
- `strategy-investigacion-profunda` — informes completos con triangulación, scoring y verificación de citas.
- `tool-web-security-audit` — auditoría defensiva de seguridad web para objetivos autorizados.
- `strategy-stack-recommender` — recomendación de stack tecnológico antes de construir.

### Changed
- `docs/quickstart.md` ampliado con árbol de decisión y plan de primera semana.
- `docs/skills-recommended.md` reescrito como tabla accionable sin inventar URLs nuevas.
- Traducidas al español las skills `find-skills`, `marketing-email-sequence` y `strategy-web-research`.
- `marketing-email-sequence` ahora carga brand voice/contexto real del OS y pasa cada email por `tool-output-verifier`.
- `tool-zoom-summary` menciona la plantilla de glosario cuando no existe `brand-context/glossary.json`.

---

## v0.8.2 — Memory Upgrade · P1: recall local (SQLite + FTS5) + CodeGraph en el catálogo (2026-06-03)

> **Por qué esta release**: el recall se construyó **LOCAL-FIRST** (SQLite + FTS5, cero servicios externos) en vez de Supabase/pgvector. Motivo: este repo lo instala **gente no técnica** de la comunidad — la sencillez de instalación manda sobre la potencia máxima. Búsqueda por keyword español para todos; semántica (embeddings) **opt-in** para quien ya tenga histórico que lo justifique. Patrón inspirado en CodeGraph (índice local en un `.db`, instalable de un comando).

### Added
- **Recall de memoria local** (`scripts/memory-index/`): índice SQLite + FTS5 sobre el corpus markdown del operador. `ingest.py` (chunking por encabezados, scrub de secretos, incremental por SHA1, ranking BM25), `schema.sql` (FTS5 external-content + triggers de sync), `corpus.yaml`. Capa semántica **opt-in** en `semantic.py` (`sqlite-vec` + `multilingual-e5-small`) tras `--semantic`. 100% local, sin API keys, sin connection strings.
- **Skill `/recuerda`** (`_meta/recuerda`) — recall con Tier 0 (contexto cargado) → FTS5; responde **con fuente citada** o **"no lo tengo registrado"** sin inventar (coherente con la regla no-inventar-datos).
- **CodeGraph** documentado en `docs/mcps-curated.md` como MCP **add-on opcional** (grafo de código local, 100% local, MIT) para usuarios que programan. Validado en un repo real antes de recomendarlo.
- **Auto-sync** vía hook SessionStart: refresca el índice (ingest incremental, best-effort, no bloqueante) al abrir el repo, sin cron del sistema. Además, `/recuerda` re-indexa en cada consulta.

### Changed
- `CLAUDE.md` registry: +`recuerda` en `_meta`, +`/recuerda` en slash commands, conteo a 26 skills core.

### Review del maintainer (Opus)
- Eliminado un atajo de query **hardcodeado** con términos de iAmasters (`cpl→leadgen/ret/...`) que Codex había metido: rompía la promesa de repo genérico (misma clase de fuga limpiada en v0.7.1). Ahora `FTS_EXPANSIONS` está vacío y es configurable por el operador.
- `--smoke-query` renombrado a `--query` (con alias) para uso de producción.

### Validado (end-to-end, local)
- Ingest: **108 archivos → 789 chunks en 0,15 s**, SQLite local 1,5 MB.
- Validado con 3 preguntas de control sobre decisiones pasadas: devuelven la fuente correcta en top-5. Una pregunta sobre un dato que no existe en el corpus no produce falsos positivos (responde "no lo tengo registrado").

---

## v0.8.1 — Memory Upgrade · Fase A: working memory + memo manual (2026-06-02)

> **Por qué esta release**: benchmark del OS contra Agentic OS (Scrapes) Phase 2, que organiza la memoria en tres ejes — Store / Inject / Recall. El análisis confirmó que iAmasters OS ya gana en Store e Inject (captura turno a turno vía Sinapsis + instincts con confidence decay) y tiene un motor de aprendizaje que ellos no tienen, pero que el **recall semántico** es el hueco real. Esta Fase A cierra primero la pieza más barata y de mayor uso diario: una memoria de trabajo curada que se inyecta al inicio y se mantiene en el cierre, más un memo manual en lenguaje natural.

### Added

- **`context/working-memory.md`** — scratchpad de trabajo curado con tres secciones (Hilos activos / Notas de entorno / Decisiones pendientes), tope ~2.500 caracteres y máx. 5 ítems por sección. Es la memoria "de trabajo" del OS: lo que el agente tiene presente sin buscar nada. Privado (gitignored); se bootstrappea en `meta-start-here` si no existe.
- **Memo manual** — comportamiento documentado en `CLAUDE.md`: cuando el operador dice "recuerda esto" / "apunta que" / "nota que" / "para la próxima", el agente escribe el ítem en la sección correcta del working-memory con dedup y respeto del tope.

### Changed

- **`meta-start-here`** (Paso 2) — ahora carga `context/working-memory.md` lo primero como foto del estado actual (y lo crea si falta).
- **`meta-wrap-up`** (nuevo Paso 5.5) — mantiene el working-memory al cierre: quita hilos cerrados, mueve decisiones tomadas a `decisions-log.md`, respeta el tope.
- **`CLAUDE.md`** — `working-memory.md` añadido a la carga obligatoria de inicio, a la lista de paths de `context/` y a la capa Agent Context; nueva nota de memo manual.
- **`context/README.md`** — documentado `working-memory.md`.
- **`.gitignore`** — `context/working-memory.md` marcado como dato privado del operador.

### Meta

- Análisis comparativo completo iAmasters OS vs Agentic OS (Store/Inject/Recall, orquestación, multi-cliente, Team OS, UI) — 2026-06-02. Conclusión rectora: no copiar su Command Centre ni sus skill systems de contenido (ya cubiertos por skills propias); sí cerrar el recall semántico y evaluar Team OS dado el equipo creciente.

---

## v0.8.0 — Skill opt-in `arnes` (2026-05-20)

> **Por qué esta release**: incorporar al catálogo una skill nativa creada en la comunidad de IA Masters Academy para arrancar proyectos software. Sigue el modelo de "sistema vivo" del OS: una skill validada en producción (139/139 tests, 5/5 sub-agentes Haiku en paralelo en E2E, 3 rondas de review con Fernando Montero) que ahora cualquier miembro puede activar con un comando. Se integra como **opt-in** (no se instala por defecto) siguiendo el mismo patrón que `cognito`: vendoreada intacta en `vendor/arnes/` y activable con `/install-skill arnes`.

### Added — skill nueva (opt-in)

- **`_meta/_optional/arnes`** (nueva, opt-in) — skill para vibe-coders no técnicos que ayuda a arrancar proyectos software por niveles: **Express** (5 min, web simple sin login), **Estándar** (20-30 min, app con login y datos), **PRO** (1-2 h, software profesional con SDD+TDD completo y revisión adversarial). Más dos modos para proyectos existentes: **Adoptar** (mete armazón sin tocar el código del usuario) y **Mantener** (actualiza armazón cuando la skill evoluciona). Pregunta SIEMPRE qué nivel quieres antes de avanzar — nunca decide por el usuario. Mantenida en repo separado [`iamasters-academy/arnes`](https://github.com/iamasters-academy/arnes) (público, MIT).

- **`vendor/arnes/`** — copia intacta del repo arnes v0.2.4 (incluye SKILL.md, README, CHANGELOG, CITATION, LICENSE MIT, CODEOWNERS, docs/, modos/, plantillas/, scripts/, tutorial/, estado/). 452K.

### Concepto original y créditos

`arnes` adapta el concepto **fs-scaffold** de **Fernando Montero** (Fersora Solutions SL), presentado en el Café Camaleónico del 18 de mayo de 2026 en la comunidad iAmasters Academy. La adaptación para vibe-coders no técnicos mantiene el rigor donde importa (Modo PRO) pero ofrece niveles más ligeros (Express, Estándar) para el 80% de casos donde no hace falta tanto ceremonial.

Fernando aparece como contributor en `CITATION.cff` por la integración de arnes en este OS, y arnes se referencia explícitamente como software vendored.

### Changed

- **`README.md`** — badge versión actualizado a v0.8.0. Nueva entrada `arnes` en sección "Skills incluidas → `_meta/_optional/`". Entrada en Roadmap. Entrada en Créditos con atribución a Fernando.
- **`CLAUDE.md`** — Skills registry actualizado a v0.8.0. Sección `_meta/_optional/ (2)`, fila nueva para arnes. Mención de `vendor/arnes/` en la sección "Vendored".
- **`CITATION.cff`** — bump versión `0.7.1` → `0.8.0`. Fernando Montero añadido como `contributors`. arnes añadida en `references` como software vendored.
- **`scripts/_install-state.template.json`** — version bump `0.7.1` → `0.8.0`.

### Cómo activar

Desde Claude Code en este repo:

```
/install-skill arnes
```

Reinicia Claude Code tras la activación. Triggea con frases como «crea una app», «monta una landing», «nuevo proyecto».

### No breaking changes

Ninguna skill existente, configuración o flujo se modifica. La instalación de iAmasters OS sigue exactamente igual: arnes solo aparece si el usuario decide activarla explícitamente. `scripts/install.sh` no la copia automáticamente (mismo criterio que con cognito desde v0.4.3).

---

## v0.7.1 — Patch · multi-cliente cleanup + drift fixes (2026-05-20)

> **Por qué este patch**: tras ejecutar un test controlado de instalación con `$HOME` aislado (simulando un usuario nuevo), aparecieron 3 bugs que no se vieron en review: las `references/` de `tool-zoom-summary` se copiaron sin limpiar y conservaban nombres de reuniones específicas + marca personal del maintainer; el template del state machine no se bumpeó con la release; y el `CLAUDE.md` mantenía un conteo viejo de skills. Los 3 son menores en código pero rompen la promesa de "multi-cliente" del OS, así que se corrigen como patch independiente.

### Fixed

- **`tools/tool-zoom-summary/references/color_schemes.md`** reescrito como catálogo neutro de 4 esquemas (`Warm Professional`, `Business Clean`, `Techy Modern`, `AI Future`). Eliminados los nombres de reuniones específicas del autor. El mapping topic→esquema ahora se documenta en `brand-context/meeting-types.md` del operador.
- **`tools/tool-zoom-summary/references/html_template_guide.md`** — footer del template ya no hardcodea marca ni URL del autor. Las variables `{{BRAND_NAME}}`, `{{BRAND_WEBSITE}}` y `{{TIMEZONE}}` se resuelven desde `brand-context/identity.md`. Ejemplo del parser de chat usa nombre genérico.
- **`scripts/_install-state.template.json`** — campo `version` bumpeado de `"0.6.0"` a `"0.7.1"`. Antes, el state machine generado por `install.sh` reportaba la versión equivocada, rompiendo la trazabilidad de qué versión del OS había instalado el usuario.
- **`CLAUDE.md`** — sección "Capa OS" decía "23 skills core" cuando el registry abajo decía 25. Corregido a 25.

### Test coverage

Patch validado con re-ejecución del test controlado (`$HOME` aislado, clone fresco desde GitHub, `bash scripts/install.sh`, auditoría estructural de las 25 skills, validación del install gate, smoke test de las 3 skills nuevas). Confirmado: 0 referencias residuales al stack/marca del autor en las skills genéricas, state machine reporta v0.7.1, conteo coherente en toda la documentación.

---

## v0.7.0 — Skills nativas: `seis-sombreros`, `metodo-ias`, `tool-zoom-summary` (2026-05-20)

> **Por qué esta release**: cerrar la promesa de v0.7 sobre skills nativas en español con tres incorporaciones de alto valor para el ICP del OS. Dos son contribuciones originales del maintainer (método I.A.S. y reescritura rigurosa de seis-sombreros con sistema anti-ancla), una traslada al OS una herramienta de uso semanal probado (resumen de reuniones Zoom). Todas pasan por adaptación multi-cliente: sin paths personales, sin referencias a stacks específicos del autor, sin glosarios privados.

### Added — skills nuevas

- **`_meta/seis-sombreros`** (nueva, reemplaza a `six-hats`) — implementación operativa de los 6 sombreros de De Bono con dos capas: (1) Fase 0 anti-ancla obligatoria con 4 movimientos (reformulación pura, asunción fundacional, steel-man del opuesto, pre-mortem rápido), y (2) sombreros con aislamiento estricto. Incluye 7 variantes de orden según tipo de problema (`references/variants.md`), catálogo de 10 marcos divergentes para el sombrero verde (`references/divergence-frameworks.md`), checklist anti-entrega y matriz de decisión operacionalizable en la síntesis. Mantiene integraciones con `tool-visual-explainer`, `decisions-log` y `projects/seis-sombreros/`.

- **`strategy/metodo-ias`** (nueva) — método I.A.S. (Intención · Acción · Síntesis) para operar con IA agéntica sin AI brain fry. Dos modos: diario (planificación previa con checklist verde/rojo y decisiones congeladas) y semanal (recap macro con inventario, Pareto 80/20, boundary erosion, recalibración de techo y delegables). Incluye protocolos completos en `protocolos/` y stubs de comandos `/ias-start` y `/ias-recap`. Salidas en `projects/metodo-ias/diarios/` y `projects/metodo-ias/semanales/`.

- **`tools/tool-zoom-summary`** (nueva) — genera un HTML interactivo premium a partir de una reunión de Zoom. Pipeline en 7 fases: FETCH (lista de grabaciones) → DETECT (mapping configurable de tipos de reunión vía `brand-context/meeting-types.md`) → DOWNLOAD (transcripción VTT + chat) → ANALYZE (parse + topic analysis + mini-resumen + resources) → GLOSSARY PASS (corrección de errores STT con glosario del operador en `brand-context/glossary.json`) → GENERATE (HTML con timestamps clickables) → SAVE + entregables de texto (títulos, descripción larga, mini-resumen para comunidad).

### Changed — archivado controlado

- **`_meta/six-hats/`** movida a `_meta/_archived/six-hats-2026-05-20/`. No se borra — se conserva como referencia histórica de la v0.4.3. El reemplazo (`seis-sombreros`) cubre el mismo caso de uso con mucho más rigor (anti-ancla, variantes, marcos divergentes, matriz de decisión).

### Changed — registry y atribución

- **README.md** actualizado: badge a v0.7.0, árbol de skills con tres entradas nuevas marcadas con 🆕 y nota de versión.
- **CLAUDE.md** del repo: tabla de skills registry actualizada con `seis-sombreros` reemplazando `six-hats`, `metodo-ias` en `strategy/`, y `tool-zoom-summary` en `tools/`. Conteo actualizado a 25 skills core.
- **CITATION.cff** bumpeada a 0.7.0 (2026-05-20).

### Notas operativas

- Las tres skills nuevas se diseñaron para multi-cliente desde el principio: paths configurables, sin asunciones sobre el stack del operador, sin referencias a marcas o cuentas privadas.
- `seis-sombreros` cambia el nombre canónico al español (coherente con el ICP hispanohablante del OS). Si una skill o agente externo invocaba `six-hats`, debe actualizarse a `seis-sombreros`.

---

## v0.6.0 — Install Gate · state machine anti-instalación-fantasma (2026-05-15)

> **Por qué esta release**: el primer feedback negativo de la comunidad reportó una instalación que parecía completa pero no lo estaba — el agente Claude del usuario había creado archivos JSON "fantasma" simulando que Sinapsis se instaló, cuando en realidad había fallado por Python en Windows. Esta versión cierra esa puerta a nivel estructural: hay un state machine persistente, un hook SessionStart que bloquea respuestas si la instalación no está completa, y validación profunda en cada fase.

### Added — Install gate con state machine

- **`scripts/_install-state.template.json`** (nuevo) — template del state machine persistente. Tras `install.sh`, vive en `~/.claude/skills/_install-state.json` con 6 fases tipadas: `prereqs`, `sinapsis-engine`, `context-files`, `operator-state`, `welcome-completed`, `deep-dive-completed` (esta última deferrable).
- **`scripts/_install-gate.sh`** (nuevo) — hook SessionStart en bash + node. Lee el state file y, si hay fases `required: true` no `done`, inyecta `additionalContext` al modelo: `"[INSTALL GATE] Installation incomplete. Before responding to the user, you MUST execute /install --resume."`. Es enforcement real — la harness lo ejecuta antes de que el modelo vea el primer mensaje, no depende de la voluntad del modelo de leer el CLAUDE.md.
- **`docs/install-state-schema.md`** (nuevo) — spec completa del schema: estados por fase, contrato de quién escribe qué, validación de "done", edge cases (sesión rota a mitad, drift, reinstalación).
- **Comandos `/install` y `/install-status`** en `.claude/commands/` — orquestador reentrante y dashboard read-only. `/install` lee el state, identifica la fase pendiente y la ejecuta (script bash desde terminal si es `prereqs`/`sinapsis-engine`, skill conversacional si es `context-files`/`operator-state`/`welcome-completed`). `--resume` continúa desde donde se quedó. `--force-reinstall` requiere confirmación explícita y hace backup del state.

### Changed — `scripts/install.sh` reescrito completo

- **Detección Python multi-plataforma**: intenta `python3` → `py -3` → `python` → `python3.11/12/10` → rutas absolutas Windows (`/c/Python311/python.exe` etc.). Resuelve el caso típico Windows + Microsoft Store launcher que rompía la v0.5.x.
- **Validación profunda de Sinapsis** (función `validate_sinapsis_deep`): no se conforma con "el archivo existe". Comprueba JSON parseable, hooks ejecutables (`_passive-activator.sh`, `_session-learner.sh`, etc.), settings.json con sección hooks, y conteo ≥1 de `SKILL.md` reales. Si Sinapsis se instaló pero la validación profunda falla, marca `failed` con detalle en `errors[]` y aborta.
- **Modo `--resume`**: si el state file existe con fases `done`, las salta. Continúa solo desde la primera no completada. Idempotente — ejecutar varias veces no rompe nada.
- **Modo `--force-reinstall`**: backup del state actual a `_install-state.<timestamp>.bak`, borra y arranca limpio.
- **`compute_and_store_checksum`** — guarda hash sha256 de los archivos críticos de Sinapsis (`_*.json` + `_*.sh`) en el state. `health-check` puede detectar drift posterior comparando.
- **`register_session_start_hook`** — modifica `~/.claude/settings.json` para añadir el hook SessionStart preservando todos los hooks existentes de Sinapsis (PreToolUse, PostToolUse, Stop, PreCompact). Idempotente: no duplica si ya está registrado.
- **Output estructurado** mantenido: `[OK]/[SKIP]/[WARN]/[ERROR]`. Cada fase escribe su estado al state file en cuanto termina, no al final.

### Changed — `meta-onboarding-wizard` con commits incrementales

- **De entrevista monolítica a 4 sub-fases con commits**. La v0.5 escribía los 4 archivos de `context/` al final ("Solo cuando las 8 dimensiones tienen dato sólido"). La v0.6 escribe cada archivo **inmediatamente** al cerrar su sub-fase:
  - W1 Identidad → `context/me.md` + actualiza state
  - W2 Negocio → `context/work.md` + actualiza state
  - W3 Foco → `context/current-priorities.md` + `context/goals.md` + actualiza state
  - W4 Config técnica → `~/.claude/skills/_operator-state.json` + marca `context-files.status: done` + `operator-state.status: done`
- **Reentrada inteligente**: al arrancar lee `phases.context-files.filesCreated` y empieza en la primera sub-fase con archivos pendientes. Si el usuario hizo W1+W2 ayer, hoy retoma en W3 con un saludo breve, sin repetir la apertura completa.
- **Comportamiento ante "para"** definido y persistido: marca `pausedBy: user` con la sub-fase actual, no insiste, no reporta como completo. La siguiente sesión el hook lo detecta y guía a `/install --resume`.
- **Validación post-commit anti-fantasma**: al cerrar cada sub-fase verifica que el archivo escrito existe con >100 chars de contenido real. Si la validación falla, NO marca `done`. Avisa al usuario y deja la fase `in-progress`.

### Changed — `health-check` con validación profunda y detección de drift

- **Antes**: comprobaba presencia de archivos. **Ahora**: parsea JSON, valida campos mínimos, ejecuta `test -x` sobre hooks, mide tamaño de archivos críticos (`me.md` debe tener >100 chars y `## Nombre` con valor real).
- **DRIFT detection** (nuevo): si el state machine dice que una fase está `done` pero la validación profunda falla, lo reporta como 🔴 **STATE DRIFT** y ofrece revertir el state a `in-progress` para que el sistema fuerce re-ejecución. Requiere confirmación literal "sí, revertir" — no es auto-fix por defecto.
- **Cruce con state machine**: la skill ahora usa `~/.claude/skills/_install-state.json` como fuente de verdad sobre qué *debería* estar instalado, y compara con el estado real del disco.

### Changed — `CLAUDE.md` del repo

- **Sección `⛔ INSTALLATION GATE` al inicio del documento**, antes que cualquier otra cosa. Imposible de ignorar visualmente. Define el contrato anti-fantasma: nunca crear archivos manualmente para simular instalación, nunca reportar `done` sin que el state lo confirme.
- Movida la sección `MANDATORY first action` a *post-gate*. Añadida instrucción explícita de leer planes activos en `.claude/plans/` (caso del feedback).

### Fixed

- **Detección "Sinapsis ya instalada" falsa positiva**: la v0.5.x consideraba Sinapsis instalada con solo la presencia de `_catalog.json` o `_operator-state.json`. Si el agente del usuario había creado esos archivos previamente (caso del feedback), el script saltaba la instalación real. Ahora se valida que esos JSON sean parseables, que los hooks de Sinapsis sean ejecutables y que haya al menos 1 `SKILL.md` real instalada.

### Migración desde v0.5.x

Para operadores que ya tenían v0.5.x funcionando:
1. `git pull` para traer v0.6.0
2. `bash scripts/install.sh --resume` — el script detectará que Sinapsis ya estaba instalada (validación profunda pasa), creará el `_install-state.json` retroactivamente con `sinapsis-engine.status: done` y `prereqs.status: done`, y registrará el hook SessionStart.
3. Si el operator-state ya tenía `needsOnboarding: false`, el wizard marca `context-files` y `operator-state` como `done` también — la migración es transparente y no rompe la instalación existente.

---

## v0.5.2 — Brand Voice v2.0 con doble ruta (2026-05-15)

> **Visión**: la skill `marketing-brand-voice` capturaba bien la voz si el operador tenía presencia online (URLs scrapeables, posts representativos), pero se quedaba corta cuando alguien no tenía archivo digital o no quería compartir privados. Esta release integra la mecánica de **Brand Voice Pro** (skill standalone publicada como bonus del lanzamiento iAmasters Academy 17-may en `iamasters-academy/brand-voice-pro`), manteniendo toda la integración con el ecosistema OS.

### Changed — `marketing-brand-voice` reescrita a v2.0

- **De preguntas teóricas a captura de voz auténtica**. La v1 hacía 6 preguntas sobre el tono (que el operador podía contestar de forma idealizada). La v2 incorpora **doble ruta por registro**: artefactos reales o **15 simulaciones reales** (5 por cada registro A/B/C) que sacan la voz natural sin que el operador sepa que está "siendo medido".
- **Detección de ruta global** al inicio (Paso 2). Pregunta clave: *"¿Eres una persona activa en redes / escribes mucho online?"* → asigna ruta artefactos (a), simulación (b) o híbrida (c) por registro.
- **Validación intermedia** antes de generar los archivos finales (Paso 7). Muestra al operador el análisis detectado por registro + spectrum 0-10 y pide corrección antes de cerrar.
- **Edge case nuevo**: operador idealiza respuestas en simulación. Si en Paso 7 el operador dice "esto no soy yo", reformular preguntas pidiendo respuestas más auténticas ("respóndeme como lo harías un sábado a las 23h, no como te gustaría sonar").

### Added — 3 archivos nuevos al output

Output total: 5 → **8 archivos** en `brand-context/voice/`:

- **`audit-prompt.md`** *(nuevo)* — prompt sistema reutilizable para auditar cualquier texto y verificar si está en la voz del operador. Devuelve puntuación por dimensión (tono, estructura, vocabulario, spectrum 0-10) + sustituciones concretas para anti-voz detectada. Pegable como instrucción de sistema en Claude Project, ChatGPT GEM o cualquier LLM.
- **`vocabulary.md`** *(nuevo)* — archivo independiente con: palabras-firma por registro · anti-corporate · anti-hype · anti-genérico de IA · muletillas auténticas (las que el operador repite naturalmente y NO debe eliminar porque son parte de su marca).
- **`installation.md`** *(nuevo)* — guía multi-sistema para instalar el voice profile en Claude Desktop / Claude Project / ChatGPT GEM / cualquier LLM externo. Permite que el operador use su voz fuera del OS también.

### Kept — toda la integración OS y la calidad cuantitativa de la v1

Se mantiene sin cambios:

- Firecrawl auto-scraping de URLs (web, LinkedIn, YouTube, X) via `tool-firecrawl-scraper`
- Spectrum 0-10 en 5 dimensiones: formality, directness, humor, authority, warmth
- 6 preguntas calibradoras (anti-modelo, modelo aspiracional, frases-firma, jerga propia, vocabulario prohibido, tono dominante)
- Integración con `meta-onboarding-wizard` (invocación tras identidad)
- Update de `operator-state.json` con flag `brandVoiceConfigured: true`
- Append a `context/learnings.md` con la entrada del día
- Edge cases existentes: idioma no castellano, voice multi-canal, URLs no scrapeables, sin presencia online

### Relación con Brand Voice Pro (repo standalone)

El repo privado [`iamasters-academy/brand-voice-pro`](https://github.com/iamasters-academy/brand-voice-pro) **se mantiene** como producto independiente para:

- Bonus de la lista prioritaria del lanzamiento iAmasters Academy del 17-may-2026 (ventana 18:00-19:00h)
- Operadores que aún no usan iAmasters OS y quieren la skill desde ChatGPT GEM o Claude Project sueltos

La v2 dentro del OS añade encima de Brand Voice Pro la **integración con el ecosistema** (Firecrawl + spectrum + onboarding-wizard + learnings + multi-cliente). Quien usa el OS tiene la versión completa.

---

## v0.5.1 — Onboarding profundo y conversacional (2026-05-13)

> **Visión**: el wizard inicial era un formulario disfrazado de conversación (14 preguntas predefinidas, respuestas planas). Esta release lo convierte en una entrevista real adaptativa, con profundización dinámica según las respuestas. Y añade una segunda fase opcional (`meta-deep-dive`) que profundiza 22-25 dimensiones residuales en ~25 min.

### Changed — `meta-onboarding-wizard` reescrita

- **De formulario a entrevista conversacional adaptativa**. Ya no hay preguntas literales en el SKILL.md — solo **8 dimensiones críticas** que el agente cubre dinámicamente.
- **Reglas de profundización explícitas**: cuándo insistir (respuesta corta, abstracta, cifra sin contexto, adjetivo sin ejemplo) vs cuándo pasar (respuesta rica, fatiga del usuario, "no sé" honesto).
- **Repertorio de 6 técnicas conversacionales** en `references/tecnicas-conversacionales.md`: pedir ejemplo concreto, 5 whys ligero (máx 2 niveles), inversión, espejo corto, anclaje temporal, aceptar el "no sé".
- **Anti-formulario explícito** documentado: prohibido numerar preguntas visibles al usuario, anunciar la siguiente pregunta, doble pregunta por turno, tono terapéutico, emojis durante la entrevista, juicio implícito, validación falsa tipo "qué buena pregunta".
- **Definición de "done"** clara por dimensión en `references/dimensiones-express.md` — cada dimensión exige dato sólido (no genérico, no evasivo) antes de cerrar el wizard.
- Tiempo objetivo del express: 10-12 min (sin cambios respecto a versión anterior, pero ahora con info más valiosa por turno).

### Added — `meta-deep-dive` (skill nueva)

- **Segunda fase del onboarding** — opcional pero recomendada al día siguiente del wizard inicial.
- Profundiza **22-25 dimensiones residuales** organizadas en 4 bloques:
  - **A · Persona profunda** (7): horario productivo, interrupciones, contexto vital, motivadores profundos, drenadores, estilo de comunicación con IA, palabras/tonos prohibidos.
  - **B · Negocio profundo** (6): salud financiera (rango), margen, ticket medio, diferencial real, side projects, fricciones del modelo.
  - **C · Equipo y clientes** (6, condicional): tamaño equipo, roles + dinámica, comunicación interna, delegación, clientes top, clientes problemáticos.
  - **D · Foco profundo** (6): decisión pendiente, meta 3 años profesional, meta 3 años vital, miedo profesional, métrica semanal, definición personal de éxito.
- **Idempotente**: si el operador para a la mitad, `operator-state.deepDiveProgress` guarda el avance. Retoma donde se quedó.
- **Branching condicional**: si trabaja solo, el bloque equipo se reduce a 2 dimensiones (clientes top + problemáticos).
- **Checkpoints cada 7 dimensiones**: oportunidad de pausar sin perder progreso.
- Tarda ~25-30 min total.
- Reglas de profundización y técnicas conversacionales idénticas al wizard inicial — `references/tecnicas-conversacionales.md` duplicada para autocontención.

### Added — `/deep-dive` (slash command nuevo)

- Invoca `meta-deep-dive` con detección automática de estado: primera vez vs retomar vs ya completado.
- Avisa si el operador no ha hecho aún el onboarding inicial (lo redirige al wizard).

### Changed — `meta-start-here` actualizada

- Detecta `deepDiveCompleted: false` + `onboardingDate > 12h` y muestra **recordatorio breve** (1 línea) al final del saludo diario hasta que el operador complete la deep-dive.
- No es intrusivo: aparece como PD, no como bloqueo del flow normal.

### Filosofía v0.5.1

- **La diferencia entre output decente y output que parece tuyo está en el contexto que el sistema tiene de ti**. Una entrevista de 14 preguntas planas genera contexto plano. Una entrevista adaptativa de 30+ preguntas dinámicas genera contexto que el sistema puede usar para hablar como tú.
- **Honestidad sobre el coste de tiempo**: el wizard inicial sigue siendo ~10 min (no inflar el primer wow). La deep-dive (~25 min) es opcional, separada, recomendada al día siguiente.
- **No formularios disfrazados**: si el agente termina haciendo las mismas preguntas en el mismo orden a todos los operadores, hemos fallado. La entrevista tiene que sentirse como conversación humana, no como tour guiado.

### Counts post-v0.5.1

| Categoría | v0.5.0 | v0.5.1 |
|---|---:|---:|
| `_meta/` | 9 | **10** (+meta-deep-dive) |
| Resto | 13 | 13 |
| **Total core** | **22** | **23** |
| Opcional | 1 (cognito) | 1 (cognito) |
| Slash commands | 7 | **8** (+`/deep-dive`) |

---

## v0.5.0 — Sistema vivo + skills automation/email/strategy + /aprende (2026-05-13)

> **Visión**: convertir iAmasters OS en un **sistema vivo** que crece con la comunidad. Cierre del feedback de Fernando Montero sobre v0.4.3 con decisiones tomadas explícitamente (vendoreo selectivo, plugins Anthropic vía marketplace, comando educativo `/aprende`).

### Added — Skills nuevas vendoreadas (3, todas MIT con ORIGIN.md)

- **`marketing-email-sequence`** — secuencias welcome/nurture/win-back/lifecycle. Vendoreada de [coreyhaines31/marketingskills](https://github.com/coreyhaines31/marketingskills) (MIT, Corey Haines). Renombrada de `email-sequence` para seguir convención iAmasters OS.
- **`strategy-web-research`** — research profundo multi-fuente con subagentes. Vendoreada de [langchain-ai/deepagents](https://github.com/langchain-ai/deepagents) (MIT, LangChain Inc.). Renombrada de `web-research`.
- **`automation-n8n-to-claude`** — migra workflows n8n/Make al ecosistema Claude. Vendoreada del catálogo personal de Angel Aparicio (iAmasters Automations).

### Added — Skill nueva escrita desde cero (1)

- **`automation-n8n-builder`** — crea, valida y despliega workflows n8n desde Claude usando el MCP `n8n-mcp`. Incluye patrones comunes (webhook→procesar→notificar, schedule→leer→reportar, etc.) y guardrails sobre cuándo NO usar n8n.

### Added — Slash command nuevo

- **`/aprende`** — tour interactivo de 5 días para alumnos que empiezan desde cero. Idempotente vía marker en `context/learn-progress.json`. Currículum:
  - **Día 1**: qué es una skill, cómo Claude las activa sola, demo en vivo
  - **Día 2**: brand context (voice, ICP, positioning) — output personal vs genérico
  - **Día 3**: multi-cliente con `/add-client`
  - **Día 4**: catálogo (plugins Anthropic, `/install-skill`, `/install-mcp`)
  - **Día 5**: flujo end-to-end real (reunión → notas → propuesta → email)

### Changed — Cognito mueve a opcional

- **`cognito` movida a `.claude/skills/_meta/_optional/cognito/`**. No se instala automáticamente. Se activa con `/install-skill cognito` cuando el alumno conoce los fundamentos. Razón: feedback de Fernando — para alguien que abre el OS por primera vez, cognito es ruido conceptual.
- **`/install-skill`** ampliado: si el argumento NO es URL sino nombre simple (ej. `cognito`), busca en `_optional/` y activa.
- **`scripts/install.sh`** YA NO copia cognito automáticamente — solo muestra mensaje informativo.

### Changed — tool-visual-explainer mueve a visualization/

- **`tool-visual-explainer`** movida de `tools/` → `visualization/`. Razón: las carpetas `operations/`, `strategy/` y `visualization/` existían vacías en v0.4.3 (bug documental detectado por Fernando). Ahora `visualization/` tiene contenido coherente.

### Changed — Filosofía "Sistema vivo" explícita en README

- Nueva sección 🌱 **Sistema vivo** en README explicando que el catálogo crece con la comunidad (ciclo 4-6 semanas). Refuerza el proceso de propuesta y retirada de skills documentado en `docs/skills-recommended.md`.
- Cadencia esperada de release menor: cada 4-6 semanas con skills validadas por la comunidad.

### Changed — Plugins oficiales Anthropic vía marketplace (NO vendoreados)

- **Decisión legal**: las 4 skills oficiales de Anthropic (`docx`, `xlsx`, `pdf`, `pptx`) tienen licencia **"source-available", NO open source** (verificado en `skills/docx/LICENSE.txt` del repo `anthropics/skills`). **No se pueden redistribuir** en este repo MIT.
- **Solución**: documentar instalación vía marketplace oficial dentro de Claude Code (`/plugin install anthropic-skills`). El usuario las recibe directamente de Anthropic, no de este repo. Ventaja añadida: cuando Anthropic actualiza, el usuario las recibe sin esperar release.
- **Integración**: día 4 del comando `/aprende` guía al alumno paso a paso para activarlas.

### Added — Showcase pre-poblado

- **`projects/_showcase/`** — 4 outputs reales generados con datos sintéticos para que el alumno vea qué tipo de resultado produce el sistema antes de generar el suyo:
  1. **Post LinkedIn** — preview visual simulando LinkedIn nativo
  2. **Secuencia de bienvenida** (5 emails) — HTML interactivo desplegable
  3. **Resumen de reunión kick-off** — HTML con temas, action items y riesgos
  4. **Propuesta comercial** — HTML branded premium estilo Sintaxis Lab
- Caso unificado: consultora ficticia "Marta Sánchez" trabajando con "Logística del Norte SL". Coherencia entre outputs muestra cómo el brand context atraviesa todas las skills.
- Borrable sin afectar nada: `rm -rf projects/_showcase/`.

### Fixed — Inconsistencias documentales detectadas en revisión Fernando

- **`docs/quickstart.md`** ya no menciona skills inexistentes (`operations-meeting-notes`, `strategy-competitor-monitor`). Sustituidas por ejemplos con skills que sí existen.
- **Recuento de skills**: README y CLAUDE.md ahora dicen 22 skills core (era 18 anunciadas pero descuadradas con el sistema real).
- **Carpetas vacías**: `operations/` y `strategy/` ya no son fantasmas — `strategy/` tiene `strategy-web-research`. `operations/` se mantiene vacía hasta v0.6.0 (donde entran las versiones nativas en español).

### Filosofía v0.5.0

- **Vendoreo selectivo, no a ciegas**: de 6 skills sugeridas por Fernando, solo 2 pasaron auditoría (Haiku-evaluated): email-sequence y web-research. Las otras 4 (meeting-notes, proposal-writer, youtube-transcript, linkedin-posts) están en backlog v0.6.0 para reescritura nativa en español con voice profile.
- **Cumplimiento legal explícito**: dos decisiones de licencia tomadas (Sinapsis pasa a MIT por acuerdo con Luis Pitik · skills oficiales Anthropic vía marketplace, no copiadas). Cero zonas grises.
- **Sistema vivo como narrativa**: el repo no es producto cerrado. Cada release menor incorpora 1-3 skills validadas por la comunidad.
- **Educación incluida**: el alumno desde cero tiene un tutorial guiado (`/aprende`) y un showcase de referencia (`projects/_showcase/`). No depende de vídeos externos.

### Counts post-v0.5.0

| Categoría | v0.4.3 | v0.5.0 |
|---|---:|---:|
| `_meta/` | 10 (con cognito) | 9 |
| `_meta/_optional/` | 0 | 1 (cognito) |
| `marketing/` | 5 | 6 (+email-sequence) |
| `automation/` | 0 | 2 (nuevo) |
| `strategy/` | 0 | 1 (nuevo) |
| `tools/` | 4 | 3 (-visual-explainer) |
| `visualization/` | 0 | 1 (+visual-explainer) |
| **Total core** | **18** | **22** |
| Plugins Anthropic | — | 4 (via marketplace) |

---

## v0.4.3 — Plug-and-play conversacional (2026-05-08)

> **Visión**: convertir la instalación de iAmasters OS en una experiencia conversacional. El miembro pega una URL en Claude Code y el sistema sabe qué hacer. Cero terminal manual, primer entregable garantizado en ~15-20 min.

### Added — Skills nuevas

- **`_meta/welcome-quick-win`** — primera tarea garantizada en 5 min tras el onboarding. Pide URL pública del usuario (LinkedIn / web), ejecuta análisis de posicionamiento, genera 3 hooks LinkedIn + plan semana, todo empaquetado en HTML autocontenido y compartible. Es la skill que entrega el "primer wow".
- **`_meta/six-hats`** — método de los 6 sombreros de Edward de Bono. Analiza decisiones desde 6 perspectivas separadas (proceso, datos, riesgos, oportunidades, creatividad, intuición). Universal y útil para cualquier emprendedor que toma decisiones grandes.
- **`_meta/decisions-log`** — diario append-only de decisiones del operador. Inspirado directamente en [`Luispitik/claude-code-second-brain`](https://github.com/Luispitik/claude-code-second-brain) de Luis Pitik (con crédito explícito en SKILL.md y README). Mantiene a Claude coherente entre sesiones.
- **`_meta/health-check`** — diagnóstico completo del OS. Verifica entorno, Sinapsis, brand-context, context sectorizado, skills curadas, settings, API keys. Devuelve reporte 🟢🟡🔴 con auto-fixes.
- **`_meta/cognito`** (wrapper) — Sistema Operativo de Pensamiento de Luis Pitik vendoreado en `vendor/cognito/`. El installer la copia a `~/.claude/skills/cognito/` la primera vez. Mantenida intacta.
- **`_meta/find-skills`** — descoverabilidad. Te ayuda a encontrar skills cuando el catálogo crezca por intent en lenguaje natural.
- **`tools/tool-visual-explainer`** — genera HTML autocontenido y bonito para outputs compartibles (sin JS, móvil-first, paleta naranja iAmasters). Invocada por welcome-quick-win, six-hats, marketing-positioning, etc.

### Added — Slash commands

- **`/doctor`** — invoca `_meta/health-check` con presentación 🟢🟡🔴 + propuesta auto-fix
- (Pendiente v0.5.0: `/welcome` y `/cognito-mode` como aliases explícitos)

### Changed — Refactor crítico

- **`AGENTS.md`** completamente reescrito. Sección principal nueva: "Si eres Claude Code y recibes el prompt URL canónico" con workflow paso-a-paso (clone → install → onboarding → welcome). Sección cross-tool conservada al final.
- **`README.md`** rediseñado con:
  - Sección "🚀 Instalación en 30 segundos" al inicio con prompt URL canónico copy-paste destacado
  - Sección "💰 Coste real" transparente sobre Anthropic Pro/Max ($20-200/mes) — comunicación honesta antes que el miembro choque con la factura
  - Lista de 18 skills core preinstaladas (12 v0.4.2 + 6 nuevas)
  - Renovado bloque créditos con autoría correcta (Luis Pitik, De Bono, Anthropic skills)
- **`scripts/install.sh`** robustecido:
  - Detección OS (macOS / Linux / Windows-bash)
  - Salida estructurada parseable: `[OK]`, `[SKIP]`, `[WARN]`, `[ERROR]` (Claude Code agent puede leer el output y reaccionar)
  - Idempotente: ejecutar varias veces no rompe nada
  - Crea `context/decisions-log.md` con header canónico
  - Crea `projects/welcome/` directorio
  - Step 7 nuevo: copia `vendor/cognito/` a `~/.claude/skills/cognito/` si no existe
- **`meta-onboarding-wizard`** completamente reescrito:
  - Entrevista por bloques temáticos (no todo de golpe — patrón second-brain)
  - Llena 5 archivos sectorizados: `context/me.md`, `work.md`, `team.md`, `current-priorities.md`, `goals.md` (en lugar de `user.md` monolítico)
  - Pregunta cognito mode (guiado / completo) y guarda en operator-state
  - Lanza `welcome-quick-win` al cerrar para garantizar primer wow

### Added — Documentación

- **`docs/skills-recommended.md`** rediseñado:
  - Catálogo Capa 2 con ~30 skills opcionales agrupadas por categoría
  - Sección "Alternativa lean: claude-code-second-brain" con tabla "cuándo elegir uno u otro" — referencia y respeta a Luis
  - Procesos de propuesta y retirada de skills del catálogo
- **`context/README.md`** nuevo, explicando el patrón sectorizado
- **`brand-context/README.md`** explicando qué skill genera cada archivo

### Refactor — context/ sectorizado

- `context/user.md` monolítico → 5 archivos sectorizados creados por el wizard:
  - `me.md` — identidad personal (nombre, ubicación, descripción profesional)
  - `work.md` — negocio, servicios, revenue, stack
  - `team.md` — equipo (puede estar vacío si trabaja solo)
  - `current-priorities.md` — foco del mes, cuello de botella
  - `goals.md` — objetivos 12 meses
- `context/decisions-log.md` nuevo (creado por install.sh con header)
- `context/soul.md` y `context/learnings.md` mantenidos

### Vendored

- **`vendor/cognito/`** — sistema cognito de Luis Pitik vendoreado intacto (sin modificar). Incluye SKILL.md, modes/, phases/, profiles/, hooks/, commands/, integrations/, templates/, config/. Excluido: tests/, .git/, .github/.

### Filosofía v0.4.3

- **No inflar el catálogo**: pasamos de 12 → 18 skills core (todas validadas), no a 19 con sprint a ciegas. Catálogo Capa 2 disponible on-demand.
- **Validación antes que construcción**: el experimento de Sesión 1 (Angel + URL canónico en Claude Desktop limpio) confirmó que el flow funcionará. Sprint v0.5.0 esperará a feedback real de uso, no a planificación a ciegas.
- **Crédito explícito a Luis Pitik**: tres de las skills nuevas (decisions-log inspirada en second-brain, cognito vendoreada intacta, find-skills) referencian a Luis con atribución completa. Coherente con regla de las 6 capas de atribución.

---

## v0.4.2 — Migración a org iamasters-academy + datos finales (2026-05-07)

### Changed
- **Repo migrado**: `angelapaia/iamasters-os` → `iamasters-academy/iamasters-os`
  - Nueva URL: https://github.com/iamasters-academy/iamasters-os
  - GitHub mantiene redirects automáticos del URL anterior
- **Atribución corregida** en todos los archivos del repo:
  - "iAmasters Academy" → "IA Masters Academy" (3 palabras separadas, según logo oficial)
  - Email gmail → `aaparicio@iamastersacademy.com` (corporativo)
  - Copyright `2026` → `2025-2026` (incluye año fundación academia)
  - Añadida entidad legal: AASC Associates (a brand of)
  - Añadido LinkedIn: linkedin.com/in/angel-aparicio92/
  - Añadido GitHub Org link: @iamasters-academy
- **Logo añadido**: `assets/logo.png` (2.4 MB, 1536×1024 PNG RGBA transparente). Mostrado en header del README, header del HTML team-presentation y footer del HTML.
- **README header rediseñado**: logo centrado + título + subtitle + 5 badges centrados.
- **LICENSE** ampliada con sección "Trademark notice" (marcas de AASC Associates).
- **CITATION.cff** version bumpeada a 0.4.2 con URLs actualizadas a la org nueva.

### Added
- **`assets/logo.png`** — logo oficial IA Masters Academy
- **Sweep global** automatizado para reemplazar referencias antiguas en todos los .md, .html, .cff, .json, .sh del repo

### Brand assets central
El logo y futuros assets viven en
`Empresa/01-IA Masters/07-Equipo/brand-assets/iamasters-academy-logo.png`
como fuente única de verdad. Cada repo nuevo lo copia desde ahí siguiendo el
checklist `captacion-shared/07-Equipo/repo-attribution-checklist.md`.

---

## v0.4.1 — Atribución y propiedad (2026-05-07)

### Added
- **LICENSE actualizado** con copyright "© 2026 Angel Aparicio · IA Masters Academy" + sección Authorship & Maintenance + bloque Vendored components clarificando licencia Sinapsis + bloque How to cite
- **README badges** (5): version, license, sinapsis-engine, maintained-by-angel-aparicio, by-iamasters-academy
- **README sección "Sobre el proyecto"** con tabla de autoría + cómo citar + nota de marca + code ownership
- **`.github/CODEOWNERS`** con `* @angelapaia` global + paths específicos
- **`CITATION.cff`** formato académico con datos completos + preferred-citation + referencia a Sinapsis vendored
- **GitHub repo metadata** actualizado: description con atribución, homepage a comunidad iAmasters, 7 topics (claude-code, agentic-os, sinapsis, ai-operator, skills-on-demand, iamasters, castellano)
- **Footer team-presentation.html** con copyright, links propios, nota de marcas

Aplica las 6 capas estándar de atribución documentadas en el repo
compartido del equipo (`captacion-shared/07-Equipo/repo-attribution-checklist.md`).

---

## v0.4.0 — Marketplace local + MCPs curados (2026-05-07)

### Added
- **`/install-skill <github-url>`** comando para instalar skills externas con validación previa:
  - Descarga a `/tmp/iamasters-os-skill-validate-<hash>/`
  - Valida estructura (SKILL.md, YAML frontmatter, name kebab-case, description 50-500 chars)
  - Detecta verbos de intención en description (afecta activación)
  - Comprueba scripts por patrones peligrosos (rm -rf /, eval, dd if=, mkfs, etc.)
  - Detecta credenciales hardcoded (regex API keys, tokens)
  - Comprueba conflicto con skills locales del mismo nombre
  - Output: report con OK/WARN/ERROR + recomendaciones de instalación
- **`/install-mcp <name>`** comando para instalar MCP servers:
  - Lista curada en `docs/mcps-curated.md` (top 5 + 5 útiles + warnings)
  - Configura `.mcp.json` con templates probados
  - Mode custom para URLs no curadas (con warnings)
- **`scripts/validate-skill.sh`** ejecuta toda la validación
- **`docs/mcps-curated.md`** lista mantenida de 10 MCPs útiles para operadores IA:
  - ⭐ Top 5: context7, github, supabase, notion, firecrawl
  - 🔧 Útiles: linear, gmail (read-only), slack, filesystem
  - ⚠️ MCPs a evitar (write redes sociales sin gates, scopes opacos)
  - Patrón de token budget (5-7 MCPs activos máximo)
- **`docs/skills-recommended.md`** lista de skills externas validadas:
  - Anthropic core: skill-creator, visual-explainer, pdf, docx, xlsx
  - Marketing: content-strategy, social-content, email-marketing-bible, ad-creative
  - Operations: marketing-psychology, product-management, saas-revenue-growth-metrics
  - Tech: nextjs-*, vercel-deployment, tailwind-design-system, web-security-audit
  - ⚠️ Skills a evitar (sin description clara, duplicadas, "todo en uno")
- **`docs/multi-client-guide.md`** guía operativa multi-cliente:
  - Cuándo usar / no usar
  - Estructura herencia CLAUDE.md
  - Skills custom por cliente vs skills globales del repo
  - Best practices de seguridad: separación de info entre clientes
  - Troubleshooting típico

### Decisiones de diseño
- Validate-skill.sh siempre crea TMP dir y NO elimina automáticamente (operador puede inspeccionar manualmente)
- Hardcoded secrets detection usa regex permissivo (puede haber falsos positivos, mejor warning que false-negative)
- MCP install no toca .mcp.json sin confirmación explícita del operador
- Curated lists son opinionated: solo skills/MCPs con experiencia real >2 semanas

---

## v0.3.0 — Multi-cliente + scripts de gestión (2026-05-07)

### Added
- **4 templates verticales completos** en `clients/_templates/`:
  - `freelance-ia/` — operador IA solo, ticket 5-50K€/proyecto
  - `agencia-marketing/` — pequeña agencia, MRR recurrente
  - `formador-online/` — coach/educador, ticket 200-2000€
  - `consultoria-b2b/` — high-ticket 30-300K€/engagement
- Cada template incluye: README específico + voice-profile + positioning + ICP + soul + user (template) — 6 archivos × 4 templates = 24 archivos
- **`scripts/add-client.sh`** — crea cliente nuevo desde template o vacío:
  - Valida nombre kebab-case
  - Clona template + reemplaza placeholders `{{CLIENT_NAME}}`
  - Genera `clients/<nombre>/CLAUDE.md` con overrides específicos
  - Output: estructura completa lista para configurar
- **`scripts/update.sh`** — actualiza repo desde upstream con conflict resolution:
  - 4 escenarios manejados: nada cambia / upstream actualiza / local modificó / conflicto
  - Backup automático en `.backup/<timestamp>/` antes de tocar nada
  - User data (brand-context, context, projects, clients, .env) NUNCA se sobrescribe
  - Skills locales modificadas: prompt caso por caso (keep / use upstream / diff / skip)
  - Vendor sinapsis + system files: safe to update

### Notas operativas
- Heredancia CLAUDE.md: el del cliente añade overrides al del raíz, no lo sustituye
- Skills se copian al cliente (no se heredan automáticamente); se sincronizan con `update.sh`
- El operador puede crear skills custom dentro de `clients/<nombre>/.claude/skills/` que sólo aplican a ese cliente

---

## v0.2.0 — Skills marketing core (2026-05-07)

### Added
- **8 skills nuevas** siguiendo patrón canónico del meta-skill-creator:
  - `tool-humanizer` — detector + reescritor anti-AI con `references/ai-tells.md`
  - `tool-output-verifier` — gate 4-checks (humanizer + brand-voice + length + factuality)
  - `tool-firecrawl-scraper` — wrapper Firecrawl con degradación graceful
  - `marketing-brand-voice` — voice profile + 3 registros A/B/C (formal/divulgativo/cercano)
  - `marketing-positioning` — análisis competidores + 3-5 ángulos + recomendación
  - `marketing-icp` — perfil cliente ideal completo con buying triggers + lenguaje + anti-ICP
  - `marketing-copywriting` — generador con voice + register auto + 2-3 variaciones por output
  - `marketing-content-repurposing` — 1 fuente → 5-8 piezas multiplataforma con calendar
- **Patrón de skill collaboration** documentado: copywriting → output-verifier → humanizer
- **Plataform limits reference** mantenido con 30+ plataformas

### Decisiones de diseño
- Todas las skills marketing-* invocan tool-output-verifier obligatoriamente como gate
- Humanizer score thresholds varían por plataforma (email premium ≥8, WhatsApp ≥6)
- Brand voice se compone de 3 registros separados, no 1 generic
- Firecrawl es opcional: si falta API key, fallback a WebFetch con warning

---

## v0.1.0 — esqueleto + Sinapsis (2026-05-07)

**Objetivo**: repo clonable que instale Sinapsis y deje preparada la capa OS para construir encima.

### Added
- Estructura completa de carpetas
- Sinapsis v4.5 vendored en `vendor/sinapsis/`
- `install.sh` que delega a Sinapsis y luego inicializa capa OS
- README, CLAUDE.md, AGENTS.md, LICENSE, .gitignore, .env.example
- Meta-skills v0: `meta-skill-creator`, `meta-onboarding-wizard`, `meta-start-here`, `meta-wrap-up`
- Plantillas vacías de brand-context y context

---

## Versionado de Sinapsis vendored

| iAmasters OS | Sinapsis vendored |
|---|---|
| v0.1.0 | v4.5.0 |

Cuando Sinapsis publique nueva versión upstream, se actualiza vendor con un commit dedicado.
