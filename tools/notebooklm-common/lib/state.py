"""Run state for idempotent deep-research runs (notebooklm-experto-deepresearch).

State lives at <cwd>/<project>/.notebooklm_state.json — NEVER inside the skill
folder. On --resume, completed notebooks are skipped; failed ones can be retried.
"""
from __future__ import annotations

import json
from datetime import datetime, timezone
from pathlib import Path


class RunState:
    """Append-only-ish JSON state tracking completed/failed notebooks."""

    def __init__(self, path: Path) -> None:
        self.path = Path(path)
        self.path.parent.mkdir(parents=True, exist_ok=True)
        self._data: dict = self._load()

    def _load(self) -> dict:
        if self.path.exists():
            try:
                data = json.loads(self.path.read_text(encoding="utf-8"))
                if isinstance(data, dict):
                    data.setdefault("completed", {})
                    data.setdefault("failed", {})
                    return data
            except (json.JSONDecodeError, OSError) as e:
                print(f"[WARN] Could not parse {self.path}: {e} — starting fresh.")
        return {"completed": {}, "failed": {}}

    def _save(self) -> None:
        self._data["last_update"] = datetime.now(timezone.utc).isoformat()
        self.path.write_text(
            json.dumps(self._data, indent=2, ensure_ascii=False),
            encoding="utf-8",
        )

    def is_completed(self, notebook_name: str) -> bool:
        return notebook_name in self._data.get("completed", {})

    def mark_completed(self, notebook_name: str, notebook_id: str, sources: int) -> None:
        self._data.setdefault("completed", {})[notebook_name] = {
            "notebook_id": notebook_id,
            "sources": sources,
        }
        # A completed notebook is no longer failed.
        self._data.get("failed", {}).pop(notebook_name, None)
        self._save()

    def mark_failed(self, notebook_name: str, err: str) -> None:
        self._data.setdefault("failed", {})[notebook_name] = {"error": str(err)[:500]}
        self._save()

    def summary(self) -> dict:
        return {
            "completed": len(self._data.get("completed", {})),
            "failed": len(self._data.get("failed", {})),
        }
