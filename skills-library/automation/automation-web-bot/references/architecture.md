# Las 7 piezas del bot — con metáforas y alternativas

Ninguna pieza es un invento propio: son herramientas estándar conectadas en el orden correcto.
No todas son obligatorias — elige por pieza según el caso y anota la decisión en el README del bot.

## 1. 🖐️ Las manos y los ojos — cómo actúa sobre la web

| Opción | Cuándo elegirla |
|---|---|
| **API oficial** de la plataforma | **SIEMPRE que exista y cubra el caso.** Más estable, más barata de mantener, legítima. Playwright solo cuando no hay API. |
| **Playwright** (navegador headless) | La web no tiene API o la API no cubre la acción. Entra con sesión guardada (`storageState`/`auth.json`), hace clic, escribe y lee como una persona. |
| Playwright + `selectors.json` externo | Obligatorio si eliges Playwright: los selectores viven en config versionada, no en el código. Cuando la web cambie, se edita un JSON, no el bot. |

## 2. 📦 La casa — empaquetado

- **Docker** (única opción recomendada): el bot entero en una cajita portátil. Imagen base oficial de Playwright (`mcr.microsoft.com/playwright`) ya trae navegadores y dependencias.
- Cero "en mi máquina funciona": la cajita corre igual en local que en el VPS.

## 3. 🏢 El bloque de pisos — dónde vive

| Opción | Cuándo |
|---|---|
| **VPS + Portainer** | Default. Panel visual: deploy desde repo Git, env vars pegadas en el panel, logs con un clic. Ideal si el operador ya tiene Portainer. |
| VPS + `docker compose` por SSH | Sin Portainer. Igual de válido, menos visual. `restart: unless-stopped` cubre reboots. |
| PC del operador | ❌ NO sirve para 24/7 (se apaga, se reinicia, viaja). Solo para desarrollo y modo discover inicial. |

Coste: VPS básico 5-10 €/mes (Hetzner, Contabo, DigitalOcean). Reutiliza el VPS existente si ya hay uno.

## 4. ⏰ El despertador — el disparador

| Opción | Cuándo |
|---|---|
| **Bucle interno con `setInterval`/sleep + jitter** | Default recomendado: el contenedor corre siempre y el propio bot duerme entre ciclos. Más simple que cron, permite jitter (±minutos aleatorios para no actuar siempre al segundo exacto). |
| cron DENTRO del contenedor | Ciclos largos (diario, semanal) donde no compensa tener el proceso vivo. |
| cron del host / systemd timer | Si el bot es un one-shot (`docker compose run`) por diseño. |
| Webhook entrante | El disparador no es tiempo sino un evento (llega un email, alguien rellena un form). Combina con n8n. |

## 5. 🧠 El cerebro — quién decide qué hacer

| Opción | Cuándo |
|---|---|
| **Reglas si-entonces en el código** | La decisión es determinista ("si el precio bajó → avisa"). Gratis, predecible. Empieza aquí si puedes. |
| **Webhook a n8n / RAG propio** | Ya existe un cerebro montado (caso Skool: RAG con el contenido de la comunidad). El bot es solo el mensajero: manda la pregunta a una URL, recibe el texto. Separación clave: mejoras el cerebro sin tocar el bot, y al revés. |
| **API de Claude directa** | No hay cerebro previo y la decisión requiere criterio. Suma coste por llamada — estímalo antes. |

Regla de oro del cerebro: **si no sabe la respuesta, devuelve "no sé" y el bot NO publica.**

## 6. 🗂️ La memoria — anti-duplicados y auditoría

| Opción | Cuándo |
|---|---|
| **SQLite en un volumen Docker** | Default para bots de un solo contenedor. Cero dependencias, cero coste, backup = copiar un archivo. |
| **Supabase** (self-hosted o cloud) | Ya hay Supabase en el stack, o el operador quiere ver el registro desde fuera (dashboard, otros servicios que leen la tabla). |

Esquema mínimo: `item_id · action · detail · created_at` + índice único por `item_id`. Sin memoria, el bot contesta lo mismo 10 veces.

## 7. 📱 El altavoz — cómo avisa al operador

| Opción | Cuándo |
|---|---|
| **Telegram bot** | **Default recomendado**: gratis, API oficial trivial (un token de @BotFather + un POST), cero infra. |
| WhatsApp (Evolution API) | El operador ya tiene Evolution API corriendo y vive en WhatsApp. Self-hosted, más piezas que mantener. |
| Email (SMTP/Brevo) | Avisos de baja frecuencia (resumen diario) o destinatario no técnico. |

El altavoz manda: cada acción ejecutada (con URL y contenido), el resumen de cada ciclo discover, y las alertas (sesión caducada, selectores rotos, heartbeat).

---

## Piezas transversales (mejoras sobre el patrón original)

- **Kill switch**: variable (`BOT_ENABLED=false` en env o flag en la memoria) que pausa el bot sin redeploy.
- **Heartbeat / dead man's switch**: si pasan N ciclos sin reporte, algo murió en silencio → aviso. Opción simple: ping a healthchecks.io al final de cada ciclo.
- **Detector de sesión caducada**: si aparece la pantalla de login, el bot avisa y se detiene — nunca falla en silencio ni intenta loguearse solo.
- **Screenshot por acción** (modo live): captura antes/después de cada acción, guardada en volumen, para auditar qué hizo exactamente.
- **Degradación a discover**: si los selectores clave fallan, el bot baja solo a modo observación y avisa, en vez de actuar a ciegas.
