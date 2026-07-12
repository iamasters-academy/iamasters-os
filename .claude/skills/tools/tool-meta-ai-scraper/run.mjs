// Driver for tool-meta-ai-scraper. Orchestrates scrape + parse in one command.
// Opens a browser (first run needs the operator's Facebook login), captures the
// chat DOM, then parses it into a clean Markdown transcript.
//
// Usage:
//   node run.mjs <meta-ai-prompt-url> [--out <dir>]
//
// To re-parse an existing capture without a browser (fast, no login):
//   node parse.mjs <path/to/<id>.debug.html> <id>
import { spawnSync } from 'child_process';
import { existsSync, writeSync } from 'fs';
import { dirname, join, resolve } from 'path';
import { fileURLToPath } from 'url';

const here = dirname(fileURLToPath(import.meta.url));
const cwd = process.cwd();
const out = (m) => writeSync(1, `[run] ${m}\n`);

const args = process.argv.slice(2);
const url = args.find((a) => /^https?:\/\//.test(a));
if (!url || !/meta\.ai\/prompt\//.test(url)) {
  writeSync(2, 'Usage: node run.mjs https://www.meta.ai/prompt/<uuid> [--out <dir>]\n');
  process.exit(1);
}
const promptId = (url.match(/prompt\/([a-f0-9-]+)/) || [])[1];
if (!promptId) { writeSync(2, 'Could not parse prompt id from URL\n'); process.exit(1); }

const outIdx = args.indexOf('--out');
const OUT_DIR = outIdx >= 0 && args[outIdx + 1] ? resolve(args[outIdx + 1]) : join(cwd, 'meta-ai-scrape');
const debugHtml = join(OUT_DIR, `${promptId}.debug.html`);
const cleanMd = join(OUT_DIR, `${promptId}.clean.md`);

out(`Prompt: ${promptId}`);
out(`Output: ${OUT_DIR}`);
out('Step 1/2 — scrape (opens a browser; first run needs Facebook login)...');
const r1 = spawnSync('node', [join(here, 'scrape.mjs'), url, '--out', OUT_DIR], { stdio: 'inherit', cwd });
if (r1.status !== 0) { out(`scrape failed (exit ${r1.status})`); process.exit(r1.status ?? 1); }
if (!existsSync(debugHtml)) { out('scrape produced no debug.html — aborting'); process.exit(1); }

out('Step 2/2 — parse → clean Markdown transcript...');
const r2 = spawnSync('node', [join(here, 'parse.mjs'), debugHtml, promptId], { stdio: 'inherit', cwd });
if (r2.status !== 0) { out(`parse failed (exit ${r2.status})`); process.exit(r2.status ?? 1); }

out('DONE');
out(`  clean transcript: ${cleanMd}`);
out(`  raw debug html:   ${debugHtml}`);
