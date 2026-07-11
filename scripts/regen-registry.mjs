#!/usr/bin/env node
// ============================================================
//  iAmasters OS — regen-registry.mjs
//  Genera synapsis/skills-registry.md DESDE synapsis/skills-catalog.json
//  (que a su vez se regenera desde el disco por regen-catalog.mjs).
//
//  Es el índice COMPACTO que CLAUDE.md @-importa cada sesión: da a Claude
//  el mapa de skills activas (se invocan solas) + la tabla de Biblioteca
//  con la columna "Ofrécela cuando…" (los disparadores del routing).
//
//  Self-healing: skills.sh lo llama tras add/remove/sync/catalog, así que
//  el índice nunca deriva del catálogo. NO editar skills-registry.md a mano.
// ============================================================
import { readFileSync, writeFileSync } from "node:fs";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const REPO_ROOT = join(dirname(fileURLToPath(import.meta.url)), "..");
const CATALOG = join(REPO_ROOT, "synapsis", "skills-catalog.json");
const OUT = join(REPO_ROOT, "synapsis", "skills-registry.md");
const quiet = process.argv.includes("--quiet");

const CATEGORY_ORDER = ["_meta", "strategy", "marketing", "sales", "automation", "engineering", "tools", "legal", "finance", "visualization"];
const catRank = (c) => { const i = CATEGORY_ORDER.indexOf(c); return i === -1 ? 999 : i; };

// "Ofrécela cuando…": extrae la frase-disparador de la description.
// Prioriza el patrón "Úsala/Úsalo/Usar cuando…"; recorta la coletilla
// "NO la uses…" y trunca. Fallback: primera frase.
function offerWhen(desc) {
  if (!desc) return "—";
  let d = desc.replace(/\s+/g, " ").trim();
  const m = d.match(/[ÚU]sal[ao] cuando|[ÚU]sal[ao] para|Usar cuando|Use (?:this skill )?when|Úsalo cuando/i);
  let s = m ? d.slice(m.index) : d;
  // corta antes de la desambiguación negativa (no aporta al disparador)
  s = s.split(/\.?\s+(?:NO la uses|NO la dispares|No la uses|≠)/i)[0];
  s = s.replace(/\s+/g, " ").trim();
  if (s.length > 200) s = s.slice(0, 197).replace(/[\s,;]+\S*$/, "") + "…";
  return s.replace(/\|/g, "\\|");
}

// One-liner de una skill activa: primera frase (antes del "Úsala cuando").
function oneLiner(desc) {
  if (!desc) return "—";
  let d = desc.replace(/\s+/g, " ").trim();
  d = d.split(/\.?\s+[ÚU]sal[ao] (?:cuando|para)|Usar cuando/i)[0];
  d = d.split(/(?<=\.)\s/)[0];
  d = d.replace(/\s+/g, " ").trim();
  if (d.length > 130) d = d.slice(0, 127).replace(/[\s,;]+\S*$/, "") + "…";
  return d.replace(/\|/g, "\\|");
}

const catalog = JSON.parse(readFileSync(CATALOG, "utf8"));
const skills = catalog.skills || [];
const core = skills.filter((s) => s.status === "core");
const installed = skills.filter((s) => s.status === "installed");
const library = skills.filter((s) => s.status === "library");

const byCat = (arr) => {
  const g = {};
  for (const s of arr) (g[s.category] ||= []).push(s);
  return Object.entries(g)
    .sort((a, b) => catRank(a[0]) - catRank(b[0]) || a[0].localeCompare(b[0]))
    .map(([cat, list]) => [cat, list.sort((a, b) => a.name.localeCompare(b.name))]);
};

const lines = [];
lines.push("# Skills registry (GENERADO — NO editar a mano)");
lines.push("");
lines.push("> Regenerado por `scripts/regen-registry.mjs` desde `synapsis/skills-catalog.json`.");
lines.push("> `skills.sh` lo actualiza tras cada `add/remove/sync/catalog`. Fuente de verdad en vivo: `bash scripts/skills.sh list`.");
lines.push(`> Actualizado ${catalog.updated_at || new Date().toISOString()} · ${skills.length} skills · **activas ${core.length + installed.length}** (core ${core.length} · biblioteca-instaladas ${installed.length}) · biblioteca a coste cero ${library.length}.`);
lines.push("");
lines.push("## Activas — se cargan e invócalas directamente cuando la intención encaje");
lines.push("");
lines.push("_Core (el OS las necesita) + ✅ instaladas desde biblioteca. No preguntes: úsalas._");
lines.push("");
for (const [cat, list] of byCat([...core, ...installed])) {
  lines.push(`### \`${cat}/\``);
  for (const s of list) {
    const tag = s.status === "installed" ? " ✅" : "";
    lines.push(`- \`${s.name}\`${tag} — ${oneLiner(s.description)}`);
  }
  lines.push("");
}
lines.push("## Biblioteca — coste cero hasta instalarla");
lines.push("");
lines.push("_Routing por intención: si la petición encaja con una fila, **ofrécela** → \"Eso lo hace `<skill>`. ¿La instalo?\" → `bash scripts/skills.sh add <skill>`. No la resuelvas a mano ni la ignores._");
lines.push("");
for (const [cat, list] of byCat(library)) {
  lines.push(`### \`${cat}/\``);
  lines.push("| Skill | Ofrécela cuando el operador… |");
  lines.push("|---|---|");
  for (const s of list) lines.push(`| \`${s.name}\` | ${offerWhen(s.description)} |`);
  lines.push("");
}

writeFileSync(OUT, lines.join("\n") + "\n");

if (!quiet) {
  console.log(`skills-registry.md generado: activas ${core.length + installed.length} (core ${core.length} · instaladas ${installed.length}) · biblioteca ${library.length}`);
}
