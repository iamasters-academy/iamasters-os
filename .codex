# AGENTS.md — Instrucciones para agentes IA

> Este archivo lo lees TÚ (un agente IA) cuando alguien te pasa la URL de este repo o cuando abres el repo por primera vez. Define tu workflow para instalar y arrancar iAmasters OS de forma plug-and-play.

---

## 🤖 Si eres Claude Code y recibes el prompt URL canónico

**Prompt típico del usuario:**

> "Instala iAmasters OS desde https://github.com/iamasters-academy/iamasters-os y guíame en el setup"

Variantes que también debes reconocer:
- "Instala el OS de iAmasters"
- "Configura mi sistema con iAmasters OS"
- "Quiero usar iAmasters OS"
- Cualquier URL del repo `iamasters-academy/iamasters-os`

### Tu workflow exacto (no improvises)

#### Paso 1 · Confirma intent y prerequisitos (30s)

Antes de tocar nada, confirma con el usuario en castellano (siempre castellano):

```
Voy a instalar iAmasters OS en tu sistema. El proceso:

1. Clonar el repo en ~/iamasters-os/ (~5 segundos)
2. Ejecutar el instalador (~30 segundos)
3. Lanzar el onboarding wizard (~10 minutos contigo)
4. Generarte tu primer entregable (~5 minutos)

Total: ~15-20 minutos. ¿Empezamos?

⚠️ Antes de seguir, confirma que tienes:
- Anthropic Pro o Max (Free no llega para uso real, ver docs/anthropic-plans.md)
- Git instalado (debería estar ya en macOS / Windows con Desktop)
- ~50MB libres en disco
```

Espera confirmación afirmativa ("sí", "vamos", "ok", "adelante") antes de continuar.

#### Paso 2 · Clone

```bash
cd ~ && git clone https://github.com/iamasters-academy/iamasters-os.git
cd ~/iamasters-os
```

Si la carpeta ya existe, pregunta al usuario:
- "Ya tienes `~/iamasters-os/`. ¿Lo actualizo (`git pull`), reinicio limpio (backup + clone fresh) o uso lo que hay?"

#### Paso 3 · Install

```bash
bash scripts/install.sh
```

El script `install.sh` es idempotente y devuelve salida estructurada. Parsea:
- ✅ Lo que hizo: `[OK] <componente>`
- ⚠️ Avisos: `[WARN] <componente> — <motivo>`
- ❌ Errores: `[ERROR] <componente> — <motivo>`

Si hay errores, NO sigas al paso 4. Diagnostica con `/doctor` (se instala junto con el OS) y reporta al usuario en castellano qué falla y cómo arreglarlo.

#### Paso 4 · Onboarding wizard

Una vez `install.sh` termina con éxito, lanza el flujo de configuración:

1. Lee `~/.claude/skills/_operator-state.json` para confirmar que Sinapsis se instaló
2. Invoca la skill `meta-onboarding-wizard` (en `.claude/skills/_meta/meta-onboarding-wizard/SKILL.md`)
3. Sigue exactamente sus pasos — entrevista al usuario por secciones (no todo de golpe)
4. Llena los archivos `context/me.md`, `context/work.md`, `context/team.md`, `context/current-priorities.md`, `context/goals.md`

#### Paso 5 · Welcome quick-win (PRIMER WOW garantizado)

Tras el onboarding, invoca la skill `welcome-quick-win` (en `.claude/skills/_meta/welcome-quick-win/SKILL.md`).

Esta skill:
- Pide al usuario su URL pública (LinkedIn / web personal / web de su negocio)
- Ejecuta `marketing-positioning` con esa URL
- Genera HTML autocontenido con análisis posicionamiento + 3 hooks LinkedIn + plan semana
- Guarda en `projects/welcome/<fecha>-tu-primer-entregable.html`
- Abre el HTML en navegador (o sugiere al usuario que lo abra)

Mensaje final al usuario:

```
🎉 Tu primer entregable está listo.

Ábrelo en tu navegador. Es totalmente compartible — pégalo en
WhatsApp o en la comunidad iAmasters Skool si te ha gustado.

¿Qué quieres hacer ahora?
1. Configurar tu Brand Voice completo (10 min más)
2. Ejecutar otra skill (te sugiero copywriting)
3. Cerrar sesión por hoy
```

### Reglas durante la instalación

- **Idioma**: castellano siempre, sin excepciones
- **Tono**: directo, cálido, sin rodeos. NO uses emojis en exceso (1-2 por mensaje máximo)
- **Permisos**: el usuario probablemente abrirá Claude Desktop con "omitir permisos" activado en su primera prueba — aprovecha pero NO ejecutes acciones destructivas (rm -rf, git reset --hard, etc.) sin confirmar
- **Si el usuario no es Angel**: SIEMPRE preguntar antes de tocar archivos fuera de `~/iamasters-os/`. Sinapsis vive en `~/.claude/` — solo `install.sh` la toca
- **Si algo falla**: para inmediatamente, ejecuta `/doctor`, reporta en castellano. Nunca sigas a paso siguiente con error abierto

---

## 🛠️ Si eres Claude Code y abres el repo desde el filesystem

(El usuario ya tiene el repo, abre Claude Code dentro de la carpeta.)

1. Lee `CLAUDE.md` (entry point principal)
2. Sigue las instrucciones de "Session Entry — EXECUTE ON FIRST MESSAGE OF EVERY SESSION"
3. Si `~/.claude/skills/_operator-state.json` no existe → onboarding wizard
4. Si existe pero `context/me.md` no existe → `meta-start-here`
5. Si todo configurado → `/start-here` ritual normal

---

## 🔌 Si NO eres Claude Code (Codex, Cursor, otros)

Este repo está optimizado para Claude Code, pero las skills son markdown estándar y otros agentes pueden usarlas.

### Limitaciones conocidas

1. **No ejecutes los hooks de Sinapsis** — están en `~/.claude/settings.json` y son específicos de Claude Code
2. **Sí puedes usar las skills** que viven en `.claude/skills/<categoria>/<nombre>/SKILL.md` — son markdown estándar
3. **Sí puedes leer brand-context y context** — son markdown plain
4. **Skills format**: cada skill tiene `SKILL.md` con YAML frontmatter (name, description) seguido de instrucciones
5. **Comandos**: viven en `.claude/commands/<nombre>.md` y son slash commands de Claude Code; otros agentes los pueden leer como referencia

### Cómo invocar una skill genéricamente

1. Lee `.claude/skills/<categoria>/<nombre>/SKILL.md`
2. Sigue las instrucciones del bloque "Process" o "Steps"
3. Si la skill referencia archivos en `references/`, léelos solo cuando los pidan los pasos
4. Si la skill referencia otra skill (skill-to-skill), invoca esa skill y luego continúa

### Compatibilidad probada

- ✅ **Claude Code** (entorno principal, todos los hooks Sinapsis activos)
- 🟡 **Codex (OpenAI)** — skills funcionan, hooks Sinapsis no aplican
- 🟡 **Cursor** — skills funcionan como prompts, no hay integración directa
- ❌ **Antigravity / Other** — no probado

---

## Variables clave (cualquier agente)

- **Idioma operativo**: castellano
- **Estilo de respuesta**: directo, sin rodeos, 2-3 opciones máx con recomendación
- **Validación humana**: siempre antes de acciones destructivas
- **Secretos**: nunca commitear `.env`, credentials, API keys

## Estructura mínima del repo (no romper)

```
.claude/skills/<categoria>/<nombre>/SKILL.md   ← skills curadas
.claude/commands/<nombre>.md                    ← slash commands
brand-context/voice/voice-profile.md            ← Brand Voice del operador
brand-context/positioning/positioning.md
brand-context/icp/icp.md
context/me.md                                   ← perfil personal
context/work.md                                 ← negocio, servicios, revenue
context/team.md                                 ← equipo y comunicación
context/current-priorities.md                   ← foco actual (cambia a menudo)
context/goals.md                                ← objetivos trimestrales
context/decisions-log.md                        ← decisiones append-only
context/learnings.md                            ← feedback de skills
projects/briefs/<nombre>/brief.md               ← planned projects
clients/<nombre>/{brand-context,context,projects}  ← multi-cliente
vendor/sinapsis/                                ← Sinapsis vendored, no tocar
```

## Para soporte cross-tool más profundo

Abre un issue en https://github.com/iamasters-academy/iamasters-os/issues
