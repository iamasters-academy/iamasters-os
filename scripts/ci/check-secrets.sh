#!/usr/bin/env bash
set -euo pipefail

python3 - <<'PY'
import re
import subprocess
import sys
from pathlib import Path

patterns = [
    re.compile(r"sk-ant-"),
    re.compile(r"sk-proj-"),
    re.compile(r"ghp_"),
    re.compile(r"AKIA"),
    re.compile(r"api_key\s*=\s*['\"][A-Za-z0-9]", re.IGNORECASE),
]

tracked = subprocess.run(
    ["git", "ls-files"],
    check=True,
    text=True,
    stdout=subprocess.PIPE,
).stdout.splitlines()

errors = []
for name in tracked:
    path = Path(name)
    if name == ".env.example":
        continue
    # The scanner itself and the CI workflow list the patterns literally.
    if name in ("scripts/ci/check-secrets.sh", ".github/workflows/validate.yml"):
        continue
    if "vendor" in path.parts:
        continue
    try:
        text = path.read_text(encoding="utf-8")
    except UnicodeDecodeError:
        continue
    except (FileNotFoundError, IsADirectoryError, PermissionError):
        # Trackeado en git pero ausente en disco: el operador lo movió o borró sin
        # commitear todavía (p. ej. tras la migración de estructura de v0.11.0).
        # No hay nada que escanear y crashear aquí dejaba un traceback de Python
        # en la cara de cualquiera que corriese el check tras actualizar.
        continue
    for line_no, line in enumerate(text.splitlines(), start=1):
        lower = line.lower()
        if "tu-api-key" in lower or "your-api-key" in lower or "placeholder" in lower:
            continue
        for pattern in patterns:
            if pattern.search(line):
                errors.append(f"{name}:{line_no}: matched {pattern.pattern}")

if errors:
    print("Secret scan failed:", file=sys.stderr)
    for error in errors:
        print(f"- {error}", file=sys.stderr)
    sys.exit(1)

print("OK: no obvious secrets in tracked files")
PY

