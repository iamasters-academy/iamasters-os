// Parses the saved Meta AI chat HTML (debug.html from scrape.mjs) into a clean,
// structured Markdown transcript: alternating Usuario / Meta AI turns, UI noise
// stripped (copy/like buttons, citation pills, thinking blocks), plus an appendix
// of cited sources (research leads).
//
// Usage: node parse.mjs <debug.html> <prompt-id>
import { readFileSync, writeFileSync } from 'fs';
import { join, basename, dirname } from 'path';
import * as cheerio from 'cheerio';

const htmlPath = process.argv[2];
const promptId = process.argv[3] || basename(dirname(htmlPath)) || 'unknown';
if (!htmlPath) { console.error('Usage: node parse.mjs <debug.html> [prompt-id]'); process.exit(1); }

const html = readFileSync(htmlPath, 'utf8');
const $ = cheerio.load(html);

// Capture cited sources BEFORE stripping them (research leads). Filter trivial.
const TRIVIAL = new Set([
  'gmail.com', 'www.facebook.com', 'facebook.com', 'www.instagram.com', 'instagram.com',
  'l.meta.ai', 'meta.ai', 'www.meta.ai', 'fuentes', 'cancelar', 'menú', 'menu',
]);
const sources = new Set();
$('[data-testid="citation-pill"], [data-testid="sources-pill"]').each((_, el) => {
  const t = $(el).text().trim();
  if (t && t.length > 1 && t.length < 120 && !TRIVIAL.has(t.toLowerCase())) sources.add(t);
});
$('[data-testid="assistant-message"] a[href], [data-testid="assistant-message"] [aria-label]').each((_, el) => {
  for (const s of [$(el).attr('href') || '', $(el).attr('aria-label') || '']) {
    const m = s.match(/(?:https?:\/\/)?([a-z0-9.-]+\.(?:com|net|org|io|co|es|ai|tv))(?:\/|$)/i);
    if (m && !TRIVIAL.has(m[1].toLowerCase())) sources.add(m[1].toLowerCase());
  }
});

// Strip UI noise globally so it never leaks into message text.
const NOISE = [
  '[data-testid="citation-pill"]', '[data-testid="sources-pill"]',
  '[data-testid="thinking-status"]', '[data-testid="subagent-cot-list"]',
  '[aria-label="Copiar respuesta"]', '[aria-label="Copiar tabla"]',
  '[aria-label="Compartir prompt"]', '[aria-label="Compartir"]',
  '[aria-label="Me gusta esta respuesta"]', '[aria-label="No me gusta esta respuesta"]',
  '[aria-label="Ampliar mensaje"]', '[aria-label="Cancelar"]',
  '[aria-label="Cambiar nombre"]', '[aria-label="Menú"]', 'button[aria-label]',
];
$(NOISE.join(',')).remove();

// Collect turns in document order. User and assistant blocks are siblings under
// the chat scroller, so a combined selector yields chronological order. Skip
// nested matches to avoid duplicate text.
const USER_SEL = 'div[data-message-type="user"]';
const ASST_SEL = '[data-testid="assistant-message"]';
const turns = [];
$(USER_SEL + ', ' + ASST_SEL).each((_, el) => {
  const $el = $(el);
  if ($el.parents(USER_SEL + ', ' + ASST_SEL).length > 0) return;
  const isUser = $el.attr('data-message-type') === 'user';
  const text = $el.text().replace(/ /g, ' ').replace(/[ \t]+/g, ' ').replace(/\n{3,}/g, '\n\n').trim();
  if (!text) return;
  turns.push({ role: isUser ? 'user' : 'assistant', text });
});

let title = '';
$('h1, h2').each((_, el) => {
  if (title) return;
  const $el = $(el);
  if ($el.parents('[data-testid="assistant-message"], div[data-message-type="user"]').length) return;
  const t = $el.text().trim();
  if (t) title = t;
});

const lines = [];
lines.push('---');
lines.push(`source: https://www.meta.ai/prompt/${promptId}`);
lines.push(`prompt_id: ${promptId}`);
lines.push(`title: ${title || 'Meta AI chat'}`);
lines.push(`scraped: ${new Date().toISOString().slice(0, 10)}`);
lines.push(`turns: ${turns.length}`);
lines.push(`type: meta-ai-chat-export`);
lines.push('---');
lines.push('');
lines.push(`# ${title || 'Meta AI — chat ' + promptId}`);
lines.push('');
lines.push(`> Historial completo del chat de Meta AI. ${turns.length} turnos (usuario + asistente).`);
lines.push('');
lines.push('---');
lines.push('');

let u = 0, a = 0;
turns.forEach((t) => {
  if (t.role === 'user') { u++; lines.push(`## 👤 Usuario #${u}`); }
  else { a++; lines.push(`## 🤖 Meta AI #${a}`); }
  lines.push('', t.text, '', '---', '');
});

if (sources.size) {
  lines.push(`## 📎 Fuentes citadas por Meta AI (${sources.size})`, '');
  lines.push('> Dominios y perfiles referenciados por el asistente. Leads de investigación, no verificados.', '');
  [...sources].sort().forEach((s) => lines.push(`- ${s}`));
  lines.push('');
}

const md = lines.join('\n');
const outPath = join(dirname(htmlPath), `${promptId}.clean.md`);
writeFileSync(outPath, md, 'utf8');
const log = (m) => console.log(`[parse] ${m}`);
log(`Turns: ${turns.length} (user=${u}, assistant=${a})`);
log(`Title: ${title || '(none)'}`);
log(`Sources: ${sources.size}`);
log(`Output: ${outPath} (${(md.length / 1024).toFixed(1)} KB)`);
