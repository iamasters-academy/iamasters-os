# Scaffold — esqueleto de proyecto para un bot web autónomo

Plantillas listas para rellenar. Genera el proyecto en `projects/<nombre-bot>/` (o
`clients/<cliente>/projects/<nombre-bot>/`). Código y comentarios en inglés; adapta los
`TODO` al caso. Al escribir/modificar este código aplica la regla `conclave` del OS.

## Estructura

```
<nombre-bot>/
├── src/
│   ├── bot.mjs              # Main loop: discover|live cycle
│   ├── notify.mjs           # Altavoz (Telegram default)
│   ├── memory.mjs           # SQLite dedup + audit log
│   └── brain.mjs            # Cerebro (webhook / rules / Claude API)
├── config/
│   └── selectors.json       # Selectores de la web — NUNCA en el código
├── scripts/
│   └── save-session.mjs     # Captura de sesión (una vez, en local)
├── data/                    # Volumen: auth.json, bot.db, screenshots/ (gitignored)
├── Dockerfile
├── docker-compose.yml
├── .env.example
├── .gitignore               # data/, .env, auth.json
└── README.md                # La frase única + tabla de piezas + nivel de autonomía
```

## .env.example

```bash
# Mode: discover = observe only (day 1 ALWAYS starts here) | live = act with limits
BOT_MODE=discover
# Kill switch: set to false to pause without redeploy
BOT_ENABLED=true

TARGET_URL=https://example.com/your-channel
CYCLE_MINUTES=60
CYCLE_JITTER_MINUTES=7          # random +/- so the bot never acts on the exact second
MAX_ACTIONS_PER_CYCLE=5         # hard limit — your seatbelt
MIN_ITEM_AGE_MINUTES=30         # wait before acting, leaves room for humans

# Brain (pick one in brain.mjs)
BRAIN_WEBHOOK_URL=              # n8n / RAG endpoint, returns {answer, confident}
# ANTHROPIC_API_KEY=            # only if brain = Claude API

# Notify (Telegram default)
TELEGRAM_BOT_TOKEN=
TELEGRAM_CHAT_ID=

# Heartbeat (optional): pinged at the end of every successful cycle
HEARTBEAT_URL=                  # e.g. https://hc-ping.com/<uuid>
```

## scripts/save-session.mjs — captura de sesión (una vez, en local)

```js
// Run locally ONCE: opens a real browser, you log in manually with the BOT account,
// session is saved to data/auth.json. Re-run whenever the session expires.
// Usage: node scripts/save-session.mjs
import { chromium } from 'playwright';

const TARGET_URL = process.env.TARGET_URL ?? 'https://example.com/login';
const browser = await chromium.launch({ headless: false });
const context = await browser.newContext();
const page = await context.newPage();
await page.goto(TARGET_URL);

console.log('Log in manually with the BOT account, then press Enter here...');
process.stdin.resume();
await new Promise((res) => process.stdin.once('data', res));

await context.storageState({ path: 'data/auth.json' });
console.log('Session saved to data/auth.json — upload it to the server volume.');
await browser.close();
process.exit(0);
```

## config/selectors.json — selectores fuera del código

```json
{
  "_comment": "Filled/updated by discover mode. When the site changes, edit THIS, not the code.",
  "itemList": "div[data-testid='post-list'] article",
  "itemTitle": "h3",
  "itemLink": "a[href*='/post/']",
  "itemHasReply": ".reply-count:not(:empty)",
  "replyBox": "textarea[placeholder*='comment']",
  "replySubmit": "button[type='submit']",
  "loggedOutMarker": "form[action*='login']"
}
```

## src/bot.mjs — esqueleto del ciclo

```js
import { chromium } from 'playwright';
import { readFileSync } from 'node:fs';
import { notify } from './notify.mjs';
import { seen, record } from './memory.mjs';
import { decide } from './brain.mjs';

const cfg = {
  mode: process.env.BOT_MODE ?? 'discover',
  enabled: process.env.BOT_ENABLED !== 'false',
  url: process.env.TARGET_URL,
  cycleMin: Number(process.env.CYCLE_MINUTES ?? 60),
  jitterMin: Number(process.env.CYCLE_JITTER_MINUTES ?? 7),
  maxActions: Number(process.env.MAX_ACTIONS_PER_CYCLE ?? 5),
  minAgeMin: Number(process.env.MIN_ITEM_AGE_MINUTES ?? 30),
};
const sel = JSON.parse(readFileSync('config/selectors.json', 'utf8'));

async function cycle() {
  if (!cfg.enabled) { console.log('kill switch on — skipping cycle'); return; }

  const browser = await chromium.launch();
  const context = await browser.newContext({ storageState: 'data/auth.json' });
  const page = await context.newPage();
  try {
    await page.goto(cfg.url, { waitUntil: 'domcontentloaded' });

    // Session expired? Never fail silently, never try to log in by itself.
    if (await page.locator(sel.loggedOutMarker).count()) {
      await notify('⚠️ Session expired. Re-run save-session.mjs and upload data/auth.json.');
      return;
    }

    const items = await scanItems(page);        // TODO: read sel.itemList, extract id/title/age/hasReply
    const candidates = items.filter((i) => !i.hasReply && i.ageMinutes >= cfg.minAgeMin && !seen(i.id));

    if (cfg.mode === 'discover') {
      await notify(`🔎 discover: ${items.length} items seen, ${candidates.length} would be acted on:\n` +
        candidates.map((i) => `- ${i.title}`).join('\n'));
      return;
    }

    let acted = 0;
    for (const item of candidates) {
      if (acted >= cfg.maxActions) break;        // hard limit — the seatbelt
      const { answer, confident } = await decide(item);
      if (!confident) {                          // brain doesn't know → do NOT publish
        record(item.id, 'skipped_unconfident', item.title);
        await notify(`🤷 Skipped (brain not confident): ${item.url}`);
        continue;
      }
      await page.screenshot({ path: `data/screenshots/${item.id}-before.png` });
      await act(page, item, answer);             // TODO: fill sel.replyBox, click sel.replySubmit
      await page.screenshot({ path: `data/screenshots/${item.id}-after.png` });
      record(item.id, 'replied', answer);
      await notify(`✅ Acted on: ${item.url}\n${answer}`);
      acted++;
    }
  } catch (err) {
    // Selector failures degrade to observation — never act blindly on a changed layout.
    console.error('cycle failed:', err);
    await notify(`🔴 Cycle error (bot degraded to observe-only): ${err.message}`);
  } finally {
    await browser.close();
  }
  if (process.env.HEARTBEAT_URL) await fetch(process.env.HEARTBEAT_URL).catch(() => {});
}

// Internal loop with jitter — simpler than cron, container stays up.
const jitterMs = () => (Math.random() * 2 - 1) * cfg.jitterMin * 60_000;
while (true) {
  await cycle();
  await new Promise((r) => setTimeout(r, cfg.cycleMin * 60_000 + jitterMs()));
}
```

## src/notify.mjs — Telegram (default)

```js
export async function notify(text) {
  const { TELEGRAM_BOT_TOKEN: token, TELEGRAM_CHAT_ID: chat } = process.env;
  if (!token) { console.log('[notify]', text); return; }
  const res = await fetch(`https://api.telegram.org/bot${token}/sendMessage`, {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({ chat_id: chat, text }),
  });
  if (!res.ok) console.error('notify failed:', res.status, await res.text());
}
```

Para WhatsApp (Evolution API) o email, sustituye el `fetch` por el endpoint correspondiente — misma firma `notify(text)`.

## src/memory.mjs — SQLite (default)

```js
import { DatabaseSync } from 'node:sqlite';
const db = new DatabaseSync('data/bot.db');
db.exec(`CREATE TABLE IF NOT EXISTS actions (
  item_id TEXT PRIMARY KEY, action TEXT NOT NULL, detail TEXT,
  created_at TEXT DEFAULT (datetime('now'))
)`);
export const seen = (id) =>
  !!db.prepare('SELECT 1 FROM actions WHERE item_id = ?').get(id);
export const record = (id, action, detail) =>
  db.prepare('INSERT OR IGNORE INTO actions (item_id, action, detail) VALUES (?, ?, ?)').run(id, action, detail);
```

Para Supabase: misma interfaz `seen/record` contra una tabla `bot_actions` vía `@supabase/supabase-js`.

## src/brain.mjs — webhook (caso típico)

```js
// Contract: returns { answer: string, confident: boolean }.
// If confident is false the bot must NOT publish — no exceptions.
export async function decide(item) {
  const res = await fetch(process.env.BRAIN_WEBHOOK_URL, {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({ question: item.title, url: item.url }),
  });
  if (!res.ok) throw new Error(`brain webhook ${res.status}`);
  return res.json();
}
```

## Dockerfile

```dockerfile
FROM mcr.microsoft.com/playwright:v1.49.0-noble
WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev
COPY . .
# data/ (auth.json, bot.db, screenshots) is a mounted volume — see compose
CMD ["node", "src/bot.mjs"]
```

## docker-compose.yml

```yaml
services:
  bot:
    build: .
    restart: unless-stopped
    env_file: .env            # in Portainer: paste vars in the panel instead
    volumes:
      - ./data:/app/data      # auth.json, bot.db, screenshots survive redeploys
```

## Checklist de scaffold completado

- [ ] `data/`, `.env` y `auth.json` en `.gitignore` — el repo (privado) solo lleva el plano.
- [ ] `docker compose up` en local arranca en modo `discover` y manda el resumen al altavoz.
- [ ] `README.md` del bot contiene: la frase única, tabla de piezas elegidas, nivel de autonomía, y cómo re-capturar la sesión.
