---
name: automation-web-bot
description: Diseña y scaffoldea un bot web autónomo 24/7 que vive en un VPS — Playwright con sesión guardada, Docker, cron, cerebro IA opcional, memoria anti-duplicados y avisos al operador — con modo discover→live y límites duros. Úsala cuando el operador diga "monta un bot que revise/conteste/vigile X", "bot 24/7", "automatiza esta web sin API", "que funcione con el PC apagado" o "bot que entra como yo a una web". NO para scraping puntual (tool-scrape-router), workflows n8n (automation-n8n-builder), loops locales supervisados (automation-loop-engine) ni solo el deploy (automation-client-deploy).
author: IA Masters Academy
version: 1.0.0
tags: [bot, playwright, docker, vps, cron, automatizacion, 24-7, browser-automation]
---

# automation-web-bot — Bot web autónomo 24/7 sobre cualquier web

> Generaliza el patrón del bot de Skool de iAmasters Academy (Café Camaleónico 25/05/2026):
> *"Cada X tiempo, entra a Y como si fueras yo, mira Z, decide qué hacer con A, ejecuta B,
> anota lo hecho, avísame."* Si el caso del operador se escribe así, hay bot. El bot NO vive
> en el PC del operador: vive en un servidor que nunca se apaga.

## Cuándo se invoca
- "Monta un bot que conteste/revise/vigile/publique en [web] cada [intervalo]".
- "Quiero automatizar [tarea repetitiva] en una web que no tiene API".
- "Que funcione aunque apague el ordenador" / "bot 24/7" / "un becario virtual para X".
- Otra skill detecta una tarea web recurrente que pide vivir en servidor (p. ej. el RADAR de `automation-loop-engine` cuando el loop necesita correr solo, sin sesión de Claude).

## Process

### Paso 1 · La frase única (cualificación)
Pide al operador (usa `ask-questions-if-underspecified` si hace falta) que el bot quepa en UNA frase con el patrón canónico:

> **"Cada X, entra a Y como si fueras yo, mira Z, decide qué hacer con A, ejecuta B, anota lo hecho, avísame."**

Cualifica con la receta de 5 preguntas:
1. ¿Qué haces a mano hoy que repites cada X tiempo?
2. ¿Ocurre en una web a la que entras con usuario y contraseña?
3. ¿Quién decide qué hacer en cada caso? (criterio humano → IA; regla simple → si-entonces)
4. ¿El resultado lo apruebas tú o lo publica el bot directo? (empezar SIEMPRE por "yo apruebo")
5. ¿Cada cuánto debe ocurrir? (el disparador: cron, evento, email)

**Gate**: si no se puede escribir la frase, NO es este patrón. Redirige: extraer datos una vez → `tool-scrape-router` · workflow entre APIs → `automation-n8n-builder` · loop local con Claude supervisando → `automation-loop-engine`.

**Validación**: frase escrita y aprobada por el operador.

### Paso 2 · Chequeo ético, ToS y ruta API (gate bloqueante)
Antes de diseñar nada:
- **Líneas rojas** (si cae en una, NO se construye): spam / mensajes masivos no solicitados · cuentas falsas que se hacen pasar por humanos reales · acciones críticas sin supervisión (cobros, contratos, decisiones médicas/legales) · saltarse los términos de uso de la plataforma.
- **ToS**: revisa si la plataforma prohíbe automatización. Si hay duda, que el operador pregunte al servicio.
- **Ruta API primero**: si la web tiene API oficial que cubre el caso, **prefiere la API sobre Playwright** — más estable, más barata de mantener y legítima. El resto del patrón (Docker, cron, memoria, avisos) se mantiene igual; solo cambian las "manos".

**Validación**: veredicto explícito (verde / verde-con-condiciones / rojo) registrado con el operador.

### Paso 3 · Cuenta dedicada + captura de sesión
- Cuenta **dedicada e identificable como bot** (p. ej. "Soporte [marca]"), nunca la personal del operador. Separación: retirar el bot no afecta a su marca.
- Captura de sesión **una sola vez** en local: navegador controlado por código, login manual del operador, se guarda `auth.json` (Playwright `storageState`). El bot entra siempre como usuario ya logueado — sin usuario/contraseña en cada ciclo, sin captchas de login.
- `auth.json` y todas las claves van en `.env` / volumen montado. **Nunca en el repo ni en el código.**

**Validación**: `auth.json` capturado y verificado (el script de scaffold lo comprueba abriendo la web logueado).

### Paso 4 · Diseñar las piezas y el nivel de autonomía
Recorre las 7 piezas en `references/architecture.md` y elige alternativa por pieza según el caso (¿cerebro IA o reglas? ¿Supabase o SQLite? ¿WhatsApp, Telegram o email?). No todas las piezas son obligatorias.

Decide el **nivel de autonomía objetivo** (alineado con A0-A3 de `automation-loop-engine`):
- **A0** — solo observa y avisa (modo discover permanente).
- **A1** — prepara borradores; el operador aprueba antes de publicar.
- **A2** — actúa solo, con límite duro por ciclo. ← objetivo típico
- **A3** — actúa solo sin límite. Solo tras semanas de A2 limpio.

**Validación**: tabla de piezas elegidas + nivel de autonomía inicial y objetivo, aprobada por el operador.

### Paso 5 · Scaffolding del proyecto
Genera el proyecto desde `references/scaffold-template.md`: estructura, `Dockerfile`, `docker-compose.yml`, `save-session.mjs`, esqueleto del bot con modos `discover|live`, límites duros, dedup, kill switch, heartbeat y detección de sesión caducada.

- El proyecto vive en `projects/<nombre-bot>/` (o `clients/<cliente>/projects/<nombre-bot>/` si es para cliente).
- Al escribir el código aplica la regla `conclave` del OS (gate adversarial antes de commitear).
- Los selectores de la web van en `config/selectors.json`, NUNCA hardcodeados en el código (las webs cambian; separar selectores abarata el mantenimiento).

**Validación**: el bot corre en local en modo `discover` con `docker compose up`.

### Paso 6 · Deploy al servidor
- Encadena con **`automation-client-deploy`** (archetype A — VPS): transfer, Portainer o compose por SSH, autoarranque, verificación post-deploy.
- Antes de exponer cualquier puerto/panel, ofrece **`tool-vps-hardening`**.
- Variables de entorno se pegan en Portainer/`.env` del servidor — el repo (privado) solo lleva el plano.

**Validación**: contenedor corriendo en el VPS, logs limpios en el primer ciclo.

### Paso 7 · Modo discover (obligatorio — el día 1 NUNCA es live)
El bot solo entra, observa, mapea la estructura y reporta. Cero acciones de escritura.
- Salida del discover: `config/selectors.json` versionado + resumen por el canal de avisos (qué ve, cuántos ítems, qué haría).
- Mantén discover al menos 2-3 ciclos completos. Si algo no encaja, se corrige a coste cero.

**Validación**: el operador confirma que lo que el bot "ve" y "haría" es correcto.

### Paso 8 · Pasar a live, con límites duros
Cambia `BOT_MODE=discover` → `live`. Los límites NO son opcionales:
- `MAX_ACTIONS_PER_CYCLE` bajo al empezar (p. ej. 5). Si algo se descontrola, afecta a 5 ítems, no a 50.
- **Espera mínima** antes de actuar sobre un ítem (p. ej. 30 min) — deja hueco al humano.
- **Dedup**: consulta la memoria antes de actuar; si el ítem ya se tocó o ya tiene respuesta humana, se salta.
- **Si el cerebro no sabe, no publica.** Sin certeza → marcar para el operador, no inventar.

**Validación**: primer ciclo live revisado ítem a ítem por el operador vía los avisos.

### Paso 9 · Operar y mejorar
Un bot no es "monto y olvido"; es "monto, observo, ajusto" (y el 90% es observar):
- Revisar avisos a diario; corregir el cerebro si hay respuestas mejorables.
- Subir `MAX_ACTIONS_PER_CYCLE` / nivel de autonomía cuando haya confianza; bajar o pausar (kill switch) si algo huele raro.
- Si la web cambia de layout: el bot lo detecta (selectores fallan), avisa y vuelve solo a discover — actualizar `config/selectors.json`, no el código.
- Ofrece `automation-loop-engine` (`/evalua-loop`) para el scorecard periódico del loop.

### Paso 10 · Cierre y aprendizaje
- Pasa el checklist final de `references/checklist.md` antes de declarar el bot "en producción".
- Append en `context/learnings.md` bajo `## automation-web-bot` (qué web, qué pieza dio guerra, qué selector fue frágil).
- Propón commit del proyecto del bot (repo privado propio o carpeta del OS, según el caso).

## Outputs
- Proyecto del bot en `projects/<nombre-bot>/` (o `clients/<cliente>/projects/<nombre-bot>/`): código, `Dockerfile`, `docker-compose.yml`, `config/selectors.json`, `.env.example`, `README.md`.
- Tabla de diseño (piezas elegidas + nivel de autonomía) en el `README.md` del bot.
- Bot desplegado y verificado en el VPS (con `automation-client-deploy`).

## Skills que llama
- **`ask-questions-if-underspecified`** — Paso 1, si la frase única no sale a la primera.
- **`conclave`** — Paso 5, al escribir el código del bot (regla del OS para código con agentes).
- **`automation-client-deploy`** — Paso 6, el salto al VPS.
- **`tool-vps-hardening`** — Paso 6, antes de exponer nada público.
- **`automation-n8n-builder`** — Paso 4, si el cerebro es un webhook n8n que aún no existe.
- **`automation-loop-engine`** — Paso 9, scorecard y evolución A0→A3 del loop.

## Edge cases
- **Sesión caducada**: el bot lo detecta (elemento de login visible), avisa "re-captura la sesión" y NO actúa. Re-ejecutar `save-session.mjs` en local y subir el nuevo `auth.json`.
- **Captcha / detección de bot**: no intentes saltarlo. Baja frecuencia, revisa ToS, valora la ruta API o retira el bot de esa plataforma.
- **Cambio de layout**: selectores fallan → modo discover automático + aviso. Actualizar `config/selectors.json`.
- **Plataforma prohíbe bots en ToS**: rojo en Paso 2. No se construye; busca ruta API oficial o alternativa.
- **El operador quiere A3 el día 1**: no. El camino es discover → A1/A2 con límite → subir gradual. Explica el porqué (coste de un fallo × volumen).

## Examples
Ver `references/examples.md`: el caso real de Skool + 6 casos copiables (DMs de Instagram, reportes Meta Ads, seguimiento de alumnos, monitor de precios, Excel desde panel sin API, triaje de inbox).

## Referencias
- Café Camaleónico 25/05/2026 — "Cómo monté un bot que contesta Skool 24/7 sin mi PC encendido" (IA Masters Academy, caso real de origen).
- Playwright (`storageState`): https://playwright.dev/docs/auth — Apache-2.0.
