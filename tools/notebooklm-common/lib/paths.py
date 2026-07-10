"""Path resolution for the NotebookLM skills.

Outputs go under <cwd>/<project>/conocimiento/notebooklm-extracted/<slug> —
NEVER inside the skill folder. The old scripts wrote into ~/.claude/skills/<skill>/
because they used paths relative to __file__; this module removes that footgun.
"""
from __future__ import annotations

import re
import sys
from pathlib import Path


def slugify(text: str) -> str:
    """Convert text to a filesystem-safe slug (unicode-aware)."""
    if not isinstance(text, str):
        text = str(text)
    text = text.lower()
    text = re.sub(r"[^\w\s-]", "", text, flags=re.UNICODE)
    text = re.sub(r"[-\s]+", "-", text)
    return text.strip("-")


def resolve_output_dir(
    project: str | None,
    notebook_slug: str,
    *,
    base: Path | None = None,
) -> Path:
    """Resolve <base>/<project>/conocimiento/notebooklm-extracted/<notebook_slug>.

    base defaults to Path.cwd() (the active project). Raises ValueError if
    project is None, so we never silently write into the skill folder.
    """
    if project is None:
        raise ValueError(
            "No project specified. Pass --project <projects/...> (or run from a project root)."
        )
    base = Path.cwd() if base is None else Path(base)
    return base / project / "conocimiento" / "notebooklm-extracted" / notebook_slug


def list_projects(base: Path | None = None) -> list[str]:
    """List projects/ and clients/ folders relative to base."""
    base = Path.cwd() if base is None else Path(base)
    out: list[str] = []
    for parent in ("projects", "clients"):
        parent_dir = base / parent
        if parent_dir.exists():
            for p in sorted(parent_dir.iterdir()):
                if p.is_dir() and not p.name.startswith("."):
                    out.append(f"{parent}/{p.name}")
    return out


def ask_for_project(base: Path | None = None) -> str:
    """Interactive prompt to pick a project/client. Exits if none available."""
    projects = list_projects(base)
    if not projects:
        print("[ERROR] No projects/ or clients/ folders found in cwd.")
        print("Create one first with: bash scripts/create-project-standard.sh <name>")
        sys.exit(1)

    print("\n[PROJECT] Available projects/clients:")
    for i, project in enumerate(projects, 1):
        print(f"  [{i}] {project}")

    while True:
        try:
            choice = input("\n[INPUT] Pick a number (or type a path): ").strip()
            if choice.isdigit():
                idx = int(choice) - 1
                if 0 <= idx < len(projects):
                    return projects[idx]
                print(f"[ERROR] Number must be between 1 and {len(projects)}")
            else:
                root = Path.cwd() if base is None else Path(base)
                if choice in projects or (root / choice / "conocimiento").exists():
                    return choice
                print(f"[ERROR] '{choice}' has no conocimiento/ folder. Options: {', '.join(projects)}")
        except KeyboardInterrupt:
            print("\n[ABORT] Cancelled.")
            sys.exit(1)
