#!/usr/bin/env node
// ============================================================
//  iAmasters OS — regen-catalog.mjs
//  Regenera synapsis/skills-catalog.json DESDE EL DISCO (única
//  fuente de verdad). Lo invoca scripts/skills.sh tras add/remove/sync
//  (y el subcomando `catalog`), de modo que el catálogo nunca deriva.
//
//  status por skill:
//    - "core"      → instalada en .claude/skills/ y SIN copia en la biblioteca
//    - "installed" → instalada en .claude/skills/ y también en la biblioteca
//    - "library"   → solo en skills-library/ (no instalada, coste cero)
//
//  También pone .claude/.skills-pending.json a pending:false (drift resuelto).
// ============================================================
import { readFileSync, writeFileSync, readdirSync, existsSync, statSync } from "node:fs";
import { join, dirname, basename, relative } from "node:path";
import { fileURLToPath } from "node:url";

const REPO_ROOT = join(dirname(fileURLToPath(import.meta.url)), "..");
const INST_DIR = join(REPO_ROOT, ".claude", "skills");
const LIB_DIR = join(REPO_ROOT, "skills-library");
const OUT = join(REPO_ROOT, "synapsis", "skills-catalog.json");
const PENDING = join(REPO_ROOT, ".claude", ".skills-pending.json");
const quiet = process.argv.includes("--quiet");

// --- minimal YAML frontmatter extractor (name / description / version) ---
function parseFrontmatter(md) {
  md = md.replace(/\r\n?/g, "\n"); // normalizar CRLF/CR → LF (`.` no matchea \r en regex JS)
  if (!md.startsWith("---")) return {};
  const end = md.indexOf("\n---", 3);
  if (end === -1) return {};
  const block = md.slice(3, end).replace(/^\n/, "");
  const lines = block.split("\n");
  const out = {};
  for (let i = 0; i < lines.length; i++) {
    const m = lines[i].match(/^([A-Za-z_][\w-]*):\s*(.*)$/);
    if (!m) continue;
    const key = m[1];
    let val = m[2];
    // folded/literal block scalar (> or |) or empty → gather more-indented lines
    if (val === ">" || val === "|" || val === ">-" || val === "|-" || val === "") {
      const parts = [];
      let j = i + 1;
      for (; j < lines.length; j++) {
        if (/^\s+\S/.test(lines[j]) || lines[j].trim() === "") parts.push(lines[j].trim());
        else break;
      }
      val = parts.join(" ").trim();
      i = j - 1;
    }
    // strip surrounding quotes
    val = val.replace(/^["']|["']$/g, "").trim();
    if (key === "name" || key === "description" || key === "version") out[key] = val;
  }
  return out;
}

// --- scan a root two levels deep: <root>/<category>/<skill>/SKILL.md ---
function scan(root) {
  const found = [];
  if (!existsSync(root)) return found;
  for (const category of readdirSync(root)) {
    const catDir = join(root, category);
    let st;
    try { st = statSync(catDir); } catch { continue; }
    if (!st.isDirectory()) continue;
    for (const name of readdirSync(catDir)) {
      if (name.startsWith("_archived")) continue;
      const skillDir = join(catDir, name);
      const skillFile = join(skillDir, "SKILL.md");
      if (!existsSync(skillFile)) continue;
      const fm = parseFrontmatter(readFileSync(skillFile, "utf8"));
      const desc = (fm.description || "").replace(/\s+/g, " ").trim().slice(0, 220);
      found.push({
        name, category,
        path: relative(REPO_ROOT, skillDir).split("\\").join("/"),
        description: desc,
        version: fm.version || null,
      });
    }
  }
  return found;
}

const installed = scan(INST_DIR);
const library = scan(LIB_DIR);
const libNames = new Set(library.map((s) => s.name));
const instNames = new Set(installed.map((s) => s.name));

// Build the merged catalog. Installed entries win (their path is the live one).
const byName = new Map();
for (const s of installed) {
  byName.set(s.name, { ...s, status: libNames.has(s.name) ? "installed" : "core" });
}
for (const s of library) {
  if (instNames.has(s.name)) continue; // already represented by its installed copy
  byName.set(s.name, { ...s, status: "library" });
}

const skills = [...byName.values()].sort(
  (a, b) => a.category.localeCompare(b.category) || a.name.localeCompare(b.name)
);

const catalog = {
  version: "0.9.0",
  updated_at: new Date().toISOString(),
  count: skills.length,
  generated_by: "scripts/regen-catalog.mjs",
  note: "Regenerado desde el disco por skills.sh (add/remove/sync/catalog). NO editar a mano.",
  skills,
};

writeFileSync(OUT, JSON.stringify(catalog, null, 2) + "\n");
writeFileSync(
  PENDING,
  JSON.stringify({ pending: false, skill_count: skills.length, synced_at: catalog.updated_at }, null, 2) + "\n"
);

if (!quiet) {
  const core = skills.filter((s) => s.status === "core").length;
  const inst = skills.filter((s) => s.status === "installed").length;
  const lib = skills.filter((s) => s.status === "library").length;
  console.log(`catálogo regenerado: ${skills.length} skills (core ${core} · biblioteca-instaladas ${inst} · biblioteca ${lib})`);
}
