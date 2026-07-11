# Checklist, costes y líneas rojas

## Gate pre-live (todas ✓ antes de cambiar BOT_MODE a live)

- [ ] Cuenta **dedicada** para el bot, claramente identificable (p. ej. "Soporte [marca]") — nunca la personal.
- [ ] Chequeo de ToS de la plataforma hecho y en verde (Paso 2 de la skill).
- [ ] Sesión capturada en `data/auth.json`; credenciales y claves solo en `.env`/panel — nada en el repo.
- [ ] Modo **discover** corrió 2-3 ciclos y el operador validó lo que el bot "ve" y "haría".
- [ ] `config/selectors.json` versionado y separado del código.
- [ ] `MAX_ACTIONS_PER_CYCLE` bajo (≤5) al arrancar.
- [ ] Espera mínima configurada (`MIN_ITEM_AGE_MINUTES`, p. ej. 30) — el humano tiene prioridad.
- [ ] Dedup activo: si el ítem ya se tocó o ya tiene respuesta humana, se salta.
- [ ] "Si el cerebro no sabe, NO publica" implementado y probado (respuesta `confident: false`).
- [ ] Aviso al operador en **cada acción** (URL + contenido) por el altavoz elegido.
- [ ] Registro auditable en la memoria (qué, cuándo, por qué) + screenshots por acción.
- [ ] Kill switch probado (`BOT_ENABLED=false` pausa sin redeploy).
- [ ] Heartbeat configurado o decisión consciente de no tenerlo.
- [ ] Deploy verificado con `automation-client-deploy`; `tool-vps-hardening` ofrecido si hay algo expuesto.

## Gate de operación (revisión semanal)

- [ ] Avisos revisados a diario — ¿alguna respuesta mejorable? → corregir el cerebro.
- [ ] ¿Fallos de selectores? → actualizar `config/selectors.json`, no el código.
- [ ] ¿Sube la confianza? → subir límite/autonomía gradual. ¿Algo raro? → bajar o kill switch.
- [ ] Sesión válida (sin avisos de re-captura pendientes).

## Costes de referencia (2026)

| Pieza | Coste |
|---|---|
| VPS básico (Hetzner, Contabo, DigitalOcean…) | 5–10 €/mes |
| Repo privado GitHub · Docker · Portainer CE | Gratis |
| SQLite / Supabase self-hosted | Gratis (con VPS) |
| Telegram bot / Evolution API self-hosted | Gratis |
| Cerebro vía RAG/n8n propio | Gratis (ya montado) |
| Cerebro vía API Claude | Por consumo — estimar antes |
| Tiempo de montaje con Claude Code | ~3 h la primera vez |
| **Total operativo típico** | **5–10 €/mes** |

## Líneas rojas — cuándo NO construir el bot

- 🚷 **Spam**: mensajes masivos no solicitados. Bloqueo de cuenta + mala reputación garantizados.
- 🚷 **Cuentas falsas**: identidades inventadas que se hacen pasar por usuarios reales. Manipulación.
- 🚷 **Crítico sin supervisión**: cobros, contratos, decisiones médicas o legales. El bot ayuda, no decide.
- 🚷 **Saltarse ToS**: si la plataforma prohíbe automatización, se respeta. En duda, preguntar al servicio.
- 🚷 **Saltarse captchas o detección de bots**: nunca. Es señal de que la plataforma no lo quiere.
