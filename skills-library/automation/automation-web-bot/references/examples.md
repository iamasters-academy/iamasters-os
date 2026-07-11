# Ejemplos — el caso de origen y 6 casos copiables

Cada caso se escribe primero como **la frase única** y luego mapea las piezas. Si tu caso se
escribe así, tienes bot.

## Caso de origen — el bot de Skool (iAmasters Academy, real y en producción)

**Frase**: "Cada hora, entra al canal ⛑️ Preguntas y dudas de mi comunidad en Skool como la cuenta de Soporte, mira los posts sin respuesta del equipo, decide qué contestar con el RAG de la comunidad, publica el comentario, anótalo en Supabase, avísame por WhatsApp."

| Pieza | Elección |
|---|---|
| Manos/ojos | Playwright + sesión de la cuenta "Soporte iAmasters" |
| Casa / bloque | Docker → VPS existente, gestionado con Portainer |
| Despertador | Cada hora |
| Cerebro | Webhook n8n → RAG con el contenido de la comunidad |
| Memoria | Supabase (ya en el stack) |
| Altavoz | WhatsApp (Evolution API, ya montada) |
| Autonomía | Discover 2h → live con `MAX_ACTIONS_PER_CYCLE=5` + espera 30 min + "si el cerebro no sabe, no publica" |

Resultado: contesta 24/7 sin PC encendido; el operador supervisa por WhatsApp y ajusta límites.

## 1. 📩 Bot que responde DMs de Instagram
**Frase**: "Cada 30 min, entra a mis DMs, mira los mensajes nuevos, decide si son consulta habitual (precios, horarios) con reglas + plantillas, responde las simples, marca las complejas para mí, avísame por Telegram."
Piezas: Playwright · reglas si-entonces (cerebro barato) · SQLite · Telegram. ⚠️ ToS de Meta estricto con automatización — chequeo del Paso 2 obligatorio; valorar la API oficial de Messaging.
Útil para: tiendas, profesionales con muchos DMs.

## 2. 📊 Bot que descarga reportes de Meta Ads
**Frase**: "Cada mañana a las 8h, entra al panel de anuncios, mira las métricas de ayer, descárgalas, mételas en un Google Sheet con resumen, avísame."
Piezas: **API oficial primero** (Marketing API existe — Playwright solo si el dato no está en la API) · cron diario · sin cerebro (determinista) · Sheet como memoria/salida.
Útil para: quien gestione campañas y odie descargar reportes.

## 3. 🎓 Bot que da seguimiento a alumnos
**Frase**: "Cada mañana, entra a la comunidad, mira los miembros nuevos, mándales bienvenida personalizada, agenda recordatorios a 7 y 14 días, anótalo, avísame."
Piezas: Playwright · cerebro IA (personalización) o plantillas · memoria con fechas programadas (la tabla guarda `next_touch_at`) · Telegram.
Útil para: comunidades, academias, cursos online.

## 4. 📰 Bot que monitoriza precios o noticias
**Frase**: "Cada hora, entra a las webs de la competencia, mira precios/titulares, compara con ayer, y si algo cambió avísame por Telegram."
Piezas: Playwright sin sesión (webs públicas — a menudo ni hace falta `auth.json`) · reglas (diff contra la memoria) · SQLite · Telegram. Es A0 puro: solo observa y avisa — el modo discover ES el producto.
Útil para: eCommerce, periodistas, analistas.

## 5. 📅 Bot que rellena un Excel desde un panel sin API
**Frase**: "Cada lunes, entra al CRM viejo como yo, mira los datos de la semana, cópialos a la hoja con la que trabajo, anota qué filas migró, avísame."
Piezas: Playwright + sesión · cron semanal · sin cerebro · memoria = las filas ya migradas (dedup crítico aquí).
Útil para: cualquier herramienta antigua o cerrada.

## 6. 🤝 Bot que ordena la bandeja de entrada
**Frase**: "Cada mañana, lee mis emails de la noche, clasifícalos (urgente/spam/newsletter/cliente), archiva lo que no necesita mi atención, avísame con el resumen."
Piezas: **API primero** (Gmail API — no uses Playwright para Gmail) · cerebro IA para clasificar · empezar en A1 (etiqueta pero no archiva) hasta validar la clasificación.
Útil para: quien reciba >30 emails/día.

---

## Anti-ejemplos (no es esta skill)

- "Scrapea los precios de esta web **una vez** y dame un CSV" → `tool-scrape-router`.
- "Cuando llegue un lead al form, créalo en el CRM y mándale email" (API a API, sin navegador) → `automation-n8n-builder`.
- "Cada viernes genero el informe del cliente con Claude, sistematízalo" (loop local, Claude presente) → `automation-loop-engine`.
- "Ya tengo el bot construido, súbelo al VPS" → `automation-client-deploy`.
