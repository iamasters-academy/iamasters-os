#!/usr/bin/env bash
# skill-usage-tracker — hook PostToolUse (Skill), best-effort.
# Registra cada invocación de skill en .claude/skills/usage-tracker.json:
#   .skills[<name>] = { last_used: <YYYY-MM-DD>, count: <n>, status: <preservado|active> }
# Alimenta a cache-manager / auto-retire-skills.sh (que hasta ahora corrían sobre datos vacíos).
# Best-effort por diseño: NUNCA rompe ni bloquea la sesión; errores a stderr, stdout silencioso.

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." 2>/dev/null && pwd)" || exit 0
TRACKER="$REPO_DIR/.claude/skills/usage-tracker.json"

# stdin = JSON del hook PostToolUse: { tool_name, tool_input:{skill,...}, ... }
payload="$(cat 2>/dev/null)" || exit 0
[ -n "$payload" ] || exit 0

command -v node >/dev/null 2>&1 || { echo "skill-usage-tracker: node no disponible" >&2; exit 0; }

TRACKER="$TRACKER" node - "$payload" <<'NODE' || echo "skill-usage-tracker: upsert falló" >&2
const fs = require("node:fs");
const path = process.env.TRACKER;
let payload = {};
try { payload = JSON.parse(process.argv[2] || "{}"); } catch { process.exit(0); }

// El nombre de la skill llega en tool_input.skill (Skill tool). Fallbacks defensivos.
const ti = payload.tool_input || payload.toolInput || {};
const skill = (ti.skill || ti.name || payload.skill || "").trim();
if (!skill) process.exit(0);

// Fecha local YYYY-MM-DD (sin hora, como el resto del tracker).
const d = new Date();
const today = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}-${String(d.getDate()).padStart(2, "0")}`;

let db = { version: "1.0.0", last_updated: today, skills: {} };
try {
  const raw = fs.readFileSync(path, "utf8");
  const parsed = JSON.parse(raw);
  if (parsed && typeof parsed === "object") db = parsed;
} catch { /* fichero ausente o corrupto → arrancamos limpio */ }
if (!db.skills || typeof db.skills !== "object") db.skills = {};

const prev = db.skills[skill] || {};
db.skills[skill] = {
  ...prev,
  last_used: today,
  count: (Number.isInteger(prev.count) ? prev.count : 0) + 1,
  // preserva status existente (core/cached/retired); si es nuevo, "active".
  status: prev.status || "active",
};
db.last_updated = today;

const tmp = path + ".tmp";
fs.writeFileSync(tmp, JSON.stringify(db, null, 2) + "\n");
fs.renameSync(tmp, path);
NODE

exit 0
