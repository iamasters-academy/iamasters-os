#!/usr/bin/env bash
set -euo pipefail

# Claude Code SOLO indexa un nivel bajo skills/: <skills-dir>/<nombre>/SKILL.md.
# Una carpeta de categoría intermedia deja la skill invisible para el tool Skill
# ("Unknown skill: <nombre>") aunque el archivo exista y el frontmatter sea válido.
# Este check bloquea esa regresión. La categoría vive en skills-library/ (catálogo,
# que NO se indexa) y en el prefijo del nombre.

python3 - <<'PY'
from pathlib import Path
import sys

errors, warnings = [], []

# 1) Destinos indexados por Claude Code: todo .claude/skills del repo (raíz y clientes)
# Se excluyen las copias que no son instalaciones vivas: el backup con fecha que
# crea update.sh (guarda la estructura ANTIGUA, anidada, a propósito), vendor/ y
# cualquier archivado. Sin esto, /doctor y este check dan 🔴 falsos tras cada
# /actualiza, apuntando a un backup que debe quedarse tal cual.
SKIP = ("vendor", ".backup", "_archivado", "node_modules", ".git")
for root in sorted(Path(".").glob("**/.claude/skills")):
    if any(part in SKIP or part.startswith(".backup") for part in root.parts):
        continue
    if any("_archived" in part for part in root.parts):
        continue
    for path in sorted(root.rglob("SKILL.md")):
        rel = path.relative_to(root)
        if any(part.startswith("_archived") for part in rel.parts):
            continue  # anidado a propósito: no debe cargar
        if len(rel.parts) != 2:
            errors.append(
                f"{path}: anidada a {len(rel.parts) - 1} niveles — Claude Code no la indexa. "
                f"Mueve la carpeta a {root}/<nombre>/"
            )
            continue
        # 2) El nombre de invocación lo da la CARPETA, no el frontmatter
        name = ""
        for line in path.read_text(encoding="utf-8").splitlines()[1:30]:
            if line.strip() == "---":
                break
            if line.startswith("name:"):
                name = line.split(":", 1)[1].strip().strip('"').strip("'")
                break
        if name and name != path.parent.name:
            warnings.append(
                f"{path}: frontmatter name '{name}' != carpeta '{path.parent.name}' "
                f"— se invoca por la carpeta"
            )

# 3) La biblioteca es un catálogo, NO se indexa: ahí la categoría es obligatoria
lib = Path("skills-library")
if lib.is_dir():
    for path in sorted(lib.rglob("SKILL.md")):
        rel = path.relative_to(lib)
        if len(rel.parts) != 3:
            errors.append(
                f"{path}: la biblioteca es skills-library/<categoria>/<nombre>/SKILL.md "
                f"({len(rel.parts) - 1} niveles encontrados)"
            )

for w in warnings:
    print(f"WARN: {w}")

if errors:
    print("Skills depth check failed:", file=sys.stderr)
    for e in errors:
        print(f"- {e}", file=sys.stderr)
    sys.exit(1)

print("OK: skills instaladas a un nivel (indexables) y biblioteca categorizada")
PY
