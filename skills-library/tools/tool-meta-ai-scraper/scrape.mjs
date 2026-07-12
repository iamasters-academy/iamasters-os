// Scrapes the full history of a Meta AI prompt chat using the operator's own
// logged-in session (persistent Chromium profile). First run opens a visible
// browser so the operator can sign in once; the session is reused afterwards
// across every project (profile lives in ~/.meta-ai-profile).
//
// Usage:
//   node scrape.mjs <prompt-url> [--out <dir>]
//
// The chat DOM is multi-MB and meta.ai ships the ENTIRE conversation in the
// /prompt HTML (Next.js RSC, no pagination), so we capture the scroller once
// and parse offline — never scroll (it freezes the renderer) and never read
// innerText per step (it forces a full reflow).
import { chromium } from 'playwright';
import { writeFileSync, mkdirSync, writeSync } from 'fs';
import { join, resolve } from 'path';
import { homedir } from 'os';

const args = process.argv.slice(2);
const PROMPT_URL = args.find((a) => /^https?:\/\//.test(a));
if (!PROMPT_URL || !/meta\.ai\/prompt\//.test(PROMPT_URL)) {
  writeSync(2, 'Usage: node scrape.mjs https://www.meta.ai/prompt/<uuid> [--out <dir>]\n');
  process.exit(1);
}
const outIdx = args.indexOf('--out');
const OUT_DIR = outIdx >= 0 && args[outIdx + 1] ? resolve(args[outIdx + 1]) : join(process.cwd(), 'meta-ai-scrape');
const PROMPT_ID = (PROMPT_URL.match(/prompt\/([a-f0-9-]+)/) || [, 'unknown'])[1];
const PROFILE_DIR = join(homedir(), '.meta-ai-profile'); // shared across projects, never committed
mkdirSync(OUT_DIR, { recursive: true });

// Unbuffered log: writeSync(1,...) bypasses Node's stdout block buffering so
// progress shows up immediately when stdout is redirected to a file.
const log = (...a) => {
  const line = '[meta-ai] ' + a.map((x) => (typeof x === 'object' ? JSON.stringify(x) : String(x))).join(' ') + '\n';
  writeSync(1, line);
};
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
const safeEval = async (fn) => {
  try { return await page.evaluate(fn); } catch (_) { return null; }
};

const ctx = await chromium.launchPersistentContext(PROFILE_DIR, {
  headless: false,
  viewport: { width: 1366, height: 920 },
  args: [
    '--disable-blink-features=AutomationControlled',
    '--disable-session-crashed-bubble',
    '--disable-features=InfiniteSessionRestore',
    '--no-default-browser-check',
    '--no-first-run',
  ],
});
const page = ctx.pages()[0] || (await ctx.newPage());

const networkCaptures = [];
page.on('response', async (resp) => {
  try {
    const url = resp.url();
    if (!/meta\.ai/.test(url)) return;
    const ct = resp.headers()['content-type'] || '';
    if (!ct.includes('json') && !ct.includes('text')) return;
    const text = await resp.text();
    if (text.length < 80) return;
    if (/"text"|"message"|"content"|"prompt_id"|"response"|"stream"/i.test(text) || /graphql|prompt|conversation|stream/i.test(url)) {
      networkCaptures.push({ url, status: resp.status(), size: text.length, body: text.slice(0, 800000) });
    }
  } catch (_) {}
});

async function gotoPrompt() {
  log('Navigating to', PROMPT_URL);
  try { await page.goto(PROMPT_URL, { waitUntil: 'domcontentloaded', timeout: 60000 }); }
  catch (e) { log('goto warn:', e.message); }
  await page.waitForLoadState('networkidle', { timeout: 20000 }).catch(() => {});
  await sleep(3000);
  log('Landed on URL:', page.url());
}
await gotoPrompt();

// meta.ai client-side redirects to auth.meta.com (Facebook login) with no session.
// It does NOT redirect to /login — it renders the prompt page with a "Iniciar
// sesión" overlay first. Detect logout by auth URL or a password field.
async function authState() {
  const onAuthUrl = () => /auth\.meta\.com|facebook\.com\/login|\/login|accounts\.facebook\.com/i.test(page.url());
  const onPromptUrl = () => /meta\.ai\/prompt\//i.test(page.url());
  const composerVisible = async () => {
    try { return await page.locator('[contenteditable="true"], textarea, [role="textbox"]').first().isVisible({ timeout: 800 }); }
    catch (_) { return false; }
  };
  const strongLoginSignals = async () => {
    const out = await safeEval(() => {
      if (document.querySelector('input[type="password"]')) return true;
      return !!document.querySelector('input[type="email"], input[name*="email"], input[autocomplete*="email"]');
    });
    return !!out;
  };
  const start = Date.now();
  while (Date.now() - start < 20000) {
    const auth = onAuthUrl();
    const strong = await strongLoginSignals();
    const composer = await composerVisible();
    if (composer && !auth && !strong) return 'authed';
    if (auth || strong) return 'needs-login';
    await sleep(1000);
  }
  return onPromptUrl() && !onAuthUrl() ? 'authed' : 'needs-login';
}

let state = await authState();
log('Auth state:', state);
if (state === 'needs-login') {
  log('LOGIN REQUIRED. A browser window is open (it may show a Facebook login page).');
  log('>> Sign in with your Facebook account (email + password) in that window. <<');
  log('>> After login, Meta redirects back to the prompt automatically. <<');
  let waited = 0;
  do {
    await sleep(2500);
    waited += 2500;
    if (waited % 20000 === 0) log(`Waiting for your login... (${waited / 1000}s / 300s)`);
    state = await authState();
  } while (state !== 'authed' && waited < 300000);
  if (state !== 'authed') { log('LOGIN_TIMEOUT after 5 min. Exiting.'); await ctx.close(); process.exit(2); }
  log('Session detected. Reloading the prompt to capture history...');
  await gotoPrompt();
}

log('Waiting for chat surface...');
await page.waitForSelector('[contenteditable="true"], textarea, [role="textbox"]', { timeout: 30000 }).catch(() => {});
await sleep(2000);

// Locate the chat scroller via elementsFromPoint at viewport center + ancestor
// walk (O(depth)). querySelectorAll('*') on a multi-MB DOM is fatal — don't.
log('Locating chat scroller...');
await safeEval(() => {
  const findScroller = () => {
    const stack = document.elementsFromPoint(Math.floor(window.innerWidth / 2), Math.floor(window.innerHeight / 2));
    for (const el of stack) {
      let node = el;
      while (node && node !== document.body) {
        const st = getComputedStyle(node);
        if ((st.overflowY === 'auto' || st.overflowY === 'scroll') && node.clientHeight > 250 && node.scrollHeight > node.clientHeight + 100) return node;
        node = node.parentElement;
      }
    }
    return null;
  };
  const t = findScroller();
  if (t) { t.setAttribute('data-ma-scroller', '1'); return true; }
  return false;
});

const extracted = await safeEval(() => {
  let target = document.querySelector('[data-ma-scroller="1"]') || document.body;
  return { html: target.outerHTML, text: target.textContent }; // textContent, NOT innerText (no reflow)
}) || { html: '', text: '' };

log('Captured DOM:', { textLen: extracted.text.length, htmlLen: extracted.html.length });

writeFileSync(join(OUT_DIR, `${PROMPT_ID}.debug.html`), extracted.html, 'utf8');
writeFileSync(join(OUT_DIR, `${PROMPT_ID}.full-text.txt`), extracted.text || '', 'utf8');
if (networkCaptures.length) writeFileSync(join(OUT_DIR, `${PROMPT_ID}.network.json`), JSON.stringify(networkCaptures, null, 2), 'utf8');

log('DONE. Raw capture written to', OUT_DIR);
log('  -', `${PROMPT_ID}.debug.html (${Math.round(extracted.html.length / 1024)} KB)`);
log('Next: run parse.mjs to produce the clean Markdown transcript.');

await ctx.close();
process.exit(0);
