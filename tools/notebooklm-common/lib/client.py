"""Client helpers for NotebookLM: auth, retry, serializer, and the high-level
ask/research operations that centralize the two critical bug fixes.

This module is the SINGLE adaptation point for the notebooklm-py SDK surface.
If Google changes its undocumented API, fix it here — both skills inherit it.

Fixes centralized here:
  C1: per-source ask uses source_ids=[id], NOT the non-existent cited_source_selection.
  C2: Source is a frozen dataclass (.id/.title), not a dict.
  C3: serialize_answer() extracts .answer — never str() the AskResult object
      (which leaks raw_response with raw Google RPC chunks like )]}'...).
  C4: run_deep_research() passes result.task_id (from poll) to import_sources,
      NOT task.task_id (from start).
"""
from __future__ import annotations

import asyncio
import subprocess
import sys
from contextlib import asynccontextmanager
from datetime import datetime
from pathlib import Path
from typing import Any, Awaitable, Callable, TypeVar

T = TypeVar("T")

STORAGE_PATH = Path.home() / ".notebooklm" / "profiles" / "default" / "storage_state.json"
SDK_VERSION = "notebooklm-py 0.7.3"
# Renew auth proactively if the stored session is older than this.
AUTH_MAX_AGE_HOURS = 6.0


# --------------------------------------------------------------------------- #
# C3: serializer
# --------------------------------------------------------------------------- #
def serialize_answer(result: Any) -> str:
    """Extract the clean answer text from a chat.ask() result.

    Never returns the raw object repr. The old `str(response)` fallback dumped the
    whole AskResult dataclass, including raw_response with raw Google RPC chunks.
    """
    if result is None:
        return ""
    answer = getattr(result, "answer", None)
    if isinstance(answer, str):
        return answer
    if isinstance(result, dict):  # legacy dict shape some scripts returned
        a = result.get("answer")
        if isinstance(a, str):
            return a
    if isinstance(result, str):
        return result
    return ""  # do NOT str() the object — that is the bug


# --------------------------------------------------------------------------- #
# C2: Source accessors
# --------------------------------------------------------------------------- #
def extract_source_ids(sources: list[Any]) -> list[str]:
    """Pull .id from each source. Source is a frozen dataclass, not a dict."""
    ids: list[str] = []
    for s in sources:
        sid = getattr(s, "id", None)
        if sid:
            ids.append(sid)
    return ids


def source_title(source: Any) -> str:
    """Safe .title accessor. Source has .title (not .name)."""
    return getattr(source, "title", None) or "fuente-sin-titulo"


# --------------------------------------------------------------------------- #
# Retry with exponential backoff (network/transient errors only)
# --------------------------------------------------------------------------- #
_NETWORK_MARKERS = ("getaddrinfo", "connection", "dns", "network", "timeout", "reset", "unreachable")


async def retry_network(
    operation: Callable[[], Awaitable[T]],
    *,
    max_retries: int = 3,
    backoff: int = 2,
) -> T:
    """Retry a coroutine factory on transient network/timeout errors."""
    for attempt in range(max_retries):
        try:
            return await operation()
        except (asyncio.TimeoutError, TimeoutError) as e:
            if attempt < max_retries - 1:
                wait = backoff ** attempt
                print(f"[RETRY] Timeout — retrying in {wait}s (attempt {attempt + 1}/{max_retries})")
                await asyncio.sleep(wait)
            else:
                raise TimeoutError(f"Operation timed out after {max_retries} attempts") from e
        except (ConnectionError, OSError) as e:
            msg = str(e).lower()
            is_network = any(k in msg for k in _NETWORK_MARKERS)
            if not is_network:
                raise  # not a network error — propagate immediately
            if attempt < max_retries - 1:
                wait = backoff ** attempt
                print(f"[RETRY] Network error: {e} — retrying in {wait}s (attempt {attempt + 1}/{max_retries})")
                await asyncio.sleep(wait)
            else:
                raise ConnectionError(f"Persistent network error after {max_retries} attempts: {e}") from e
    raise RuntimeError(f"retry_network exhausted after {max_retries} attempts")


# --------------------------------------------------------------------------- #
# Auth
# --------------------------------------------------------------------------- #
class AuthManager:
    """Manages NotebookLM auth with automatic renewal."""

    def __init__(self, storage_path: Path | None = None) -> None:
        self.storage_path = storage_path or STORAGE_PATH

    def check_auth_health(self) -> dict:
        """Probe auth health. Returns {status, age_hours, ...}."""
        if not self.storage_path.exists():
            return {"status": "no_auth", "age_hours": None, "action": "login_required"}

        age_hours = (datetime.now() - datetime.fromtimestamp(self.storage_path.stat().st_mtime)).total_seconds() / 3600

        async def _probe() -> None:
            from notebooklm import NotebookLMClient  # lazy: lib imports without the SDK installed
            async with NotebookLMClient.from_storage() as client:
                await client.notebooks.list()

        try:
            asyncio.run(_probe())
            return {"status": "healthy", "age_hours": age_hours}
        except Exception as e:
            return {"status": "expired", "age_hours": age_hours, "error": str(e), "action": "renew_required"}

    async def ensure_auth(self) -> bool:
        """Ensure valid auth, renewing if missing/expired/older than AUTH_MAX_AGE_HOURS."""
        health = self.check_auth_health()
        status = health["status"]
        if status == "no_auth":
            print("[AUTH] No stored auth — login required.")
            return await self.login_fresh()
        if status == "expired":
            print(f"[AUTH] Tokens expired (age {health['age_hours']:.1f}h) — renewing.")
            return await self.login_fresh()
        if health["age_hours"] > AUTH_MAX_AGE_HOURS:
            print(f"[AUTH] Auth {health['age_hours']:.1f}h old — renewing proactively.")
            return await self.login_fresh()
        print(f"[OK] Auth valid ({health['age_hours']:.1f}h).")
        return True

    async def login_fresh(self) -> bool:
        """Run a fresh browser login via the SDK CLI (uses sys.executable = py -3)."""
        print("[AUTH] Running: py -3 -m notebooklm login --fresh --browser chrome")
        try:
            result = subprocess.run(
                [sys.executable, "-m", "notebooklm", "login", "--fresh", "--browser", "chrome"],
                capture_output=True, text=True, timeout=300,
            )
        except subprocess.TimeoutExpired:
            print("[ERROR] Login timed out (>5 min).")
            return False
        except Exception as e:
            print(f"[ERROR] Login failed: {e}")
            return False
        if result.returncode == 0:
            print("[OK] Login completed.")
            return True
        print(f"[ERROR] Login failed: {result.stderr}")
        return False


# --------------------------------------------------------------------------- #
# Client context manager
# --------------------------------------------------------------------------- #
@asynccontextmanager
async def get_client():
    """Async context manager yielding an authenticated client from storage."""
    from notebooklm import NotebookLMClient  # lazy: lib imports without the SDK installed
    async with NotebookLMClient.from_storage() as client:
        yield client


# --------------------------------------------------------------------------- #
# C1 + C4: high-level operations (the fixes, centralized & testable)
# --------------------------------------------------------------------------- #
async def ask_per_source(client: Any, notebook_id: str, source_id: str, question: str) -> str:
    """Ask ONE source a question.

    FIX C1: the per-source scope is `source_ids=[source_id]`. The old code built
    `CitedSourceSelection(source_ids=, mode=)` (invalid constructor → TypeError) and
    passed `cited_source_selection=` to chat.ask (kwarg that does not exist).
    """
    result = await client.chat.ask(notebook_id, question, source_ids=[source_id])
    return serialize_answer(result)


async def ask_transversal(client: Any, notebook_id: str, question: str) -> str:
    """Ask ALL sources (no source_ids). Returns clean answer text."""
    result = await client.chat.ask(notebook_id, question)
    return serialize_answer(result)


async def run_deep_research(
    client: Any,
    notebook_id: str,
    query: str,
    *,
    max_sources: int = 10,
    poll_interval: float = 5.0,
    poll_max: int = 60,
) -> tuple[list, Any]:
    """Run Deep Research end-to-end and import sources.

    FIX C4: import_sources receives `task_id=result.task_id` (from the POLL result),
    NOT `task.task_id` (from start). Using the start task_id was why all 7 prompts
    ended in `failed` with total_sources=0. Verified against test_deepresearch_corregido.py.

    Returns (imported_sources, poll_result).
    """
    task = await retry_network(
        lambda: client.research.start(notebook_id, query, source="web", mode="deep")
    )
    if task is None:
        raise ValueError("Deep Research start returned no task")

    result = None
    for _ in range(poll_max):
        result = await client.research.poll(notebook_id, task_id=task.task_id)
        status = getattr(result, "status", None)
        if status == "completed":
            break
        if status == "failed":
            raise ValueError("Deep Research poll returned status=failed")
        await asyncio.sleep(poll_interval)
    if result is None or getattr(result, "status", None) != "completed":
        raise TimeoutError("Deep Research did not complete within the poll window")

    sources_to_import = list(getattr(result, "sources", []) or [])[:max_sources]
    if not sources_to_import:
        raise ValueError("Deep Research completed but found no sources to import")

    # FIX C4: task_id comes from the POLL result.
    imported = await retry_network(
        lambda: client.research.import_sources(
            notebook_id, task_id=result.task_id, sources=sources_to_import
        )
    )
    await retry_network(
        lambda: client.sources.wait_for_sources(
            notebook_id,
            source_ids=[getattr(s, "id", s) for s in imported],
            timeout=180.0,
        )
    )
    return imported, result
