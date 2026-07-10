"""Skill-level test for notebooklm-experto-deepresearch's canonical scripts/run.py.

Drives ask_transversal_questions() and the --prompts / --existing flows with the
FakeClient. Verifies: transversal scope (source_ids=None), correct generated_by,
the C4 fix (import_sources uses the poll task_id), idempotent state, and no leak.
No network, no Google quota.
"""
import argparse
import asyncio
import importlib
import sys
from pathlib import Path

import pytest

from lib import RunState, load_questions
from tests.fakes import FakeSource

EXPERT_SCRIPTS = Path.home() / ".claude" / "skills" / "notebooklm-experto-deepresearch" / "scripts"


@pytest.fixture(scope="module")
def run():
    if not EXPERT_SCRIPTS.exists():
        pytest.skip(f"expert skill not installed at {EXPERT_SCRIPTS}")
    sys.path.insert(0, str(EXPERT_SCRIPTS))
    import run as _run
    return importlib.reload(_run)


def _ns(**kw):
    base = dict(sleep=0, max_sources=10, dry_run=False, resume=False, domain=None, questions_file=None)
    base.update(kw)
    return argparse.Namespace(**base)


def test_ask_transversal_uses_no_source_ids(run, tmp_path):
    from tests.fakes import FakeClient

    questions = load_questions(None, scope="transversal")
    client = FakeClient()
    out = tmp_path / "nb"
    out.mkdir()

    written = asyncio.run(run.ask_transversal_questions(
        client, "nb1", "nb-slug", questions, out, total_sources=3, sleep=0,
    ))
    assert written == 8
    asks = client.calls_of("chat.ask")
    assert len(asks) == 8
    # transversal = source_ids is None (all sources), never a list
    assert all(a["source_ids"] is None for a in asks)


def test_transversal_output_markdown(run, tmp_path):
    from tests.fakes import FakeClient

    questions = load_questions(None, scope="transversal")
    client = FakeClient()
    out = tmp_path / "nb"
    out.mkdir()

    asyncio.run(run.ask_transversal_questions(
        client, "nb1", "nb-slug", questions, out, total_sources=5, sleep=0,
    ))

    files = sorted(out.glob("*_TRANSVERSAL.md"))
    assert len(files) == 8
    md = (out / "01_descomposicion_profunda_TRANSVERSAL.md").read_text(encoding="utf-8")
    assert "generated_by: notebooklm-experto-deepresearch" in md
    assert "raw_response" not in md
    assert ")]}'" not in md


def test_run_prompts_end_to_end_uses_poll_task_id(run, tmp_path):
    """FIX C4 at the script level: import_sources receives result.task_id (from poll)."""
    from tests.fakes import FakeClient

    questions = load_questions(None, scope="transversal")
    client = FakeClient(research_sources=[FakeSource(id="rs-1", title="Web A")])
    out = tmp_path / "cuaderno-test-001"
    out.mkdir()
    state = RunState(tmp_path / "state.json")
    args = _ns(prompts=["scouting FIFA"], name="test")

    asyncio.run(run._run_prompts(client, args, questions, out, state))

    # notebook created
    assert client.calls_of("notebooks.create")
    # import_sources got the POLL task_id, not the start one (FIX C4)
    imports = client.calls_of("research.import_sources")
    assert len(imports) == 1
    assert imports[0]["task_id"] == "task-from-poll"
    # 8 transversal .md written
    assert len(list(out.glob("*_TRANSVERSAL.md"))) == 8
    # state marked completed
    assert state.is_completed("cuaderno-test-001")


def test_run_prompts_resume_skips_completed(run, tmp_path):
    from tests.fakes import FakeClient

    questions = load_questions(None, scope="transversal")
    client = FakeClient()
    out = tmp_path / "out"
    out.mkdir()
    state = RunState(tmp_path / "state.json")
    state.mark_completed("cuaderno-test-001", "nb-old", sources=4)
    args = _ns(prompts=["already done"], name="test", resume=True)

    asyncio.run(run._run_prompts(client, args, questions, out, state))

    # resumed -> no new notebook created, no research, no chat.ask
    assert not client.calls_of("notebooks.create")
    assert not client.calls_of("chat.ask")


def test_run_existing_with_sources(run, tmp_path):
    from tests.fakes import FakeClient

    questions = load_questions(None, scope="transversal")
    sources = [FakeSource(id="s1", title="A"), FakeSource(id="s2", title="B")]
    client = FakeClient(sources=sources)
    out = tmp_path / "nb"
    out.mkdir()
    args = _ns(existing="nb-existing", name="existing-slug")

    rc = asyncio.run(run._run_existing(client, args, questions, out))
    assert rc == 0
    assert len(list(out.glob("*_TRANSVERSAL.md"))) == 8
    asks = client.calls_of("chat.ask")
    assert all(a["source_ids"] is None for a in asks)


def test_run_prompts_records_failure_in_state(run, tmp_path):
    from tests.fakes import FakeClient

    questions = load_questions(None, scope="transversal")

    class BoomClient(FakeClient):
        async def notes_create_boom(self, *a, **k):
            raise RuntimeError("boom")

    client = BoomClient()
    # sabotage notebook creation so the prompt fails
    client.notebooks.create = client.notes_create_boom
    out = tmp_path / "out"
    out.mkdir()
    state = RunState(tmp_path / "state.json")
    args = _ns(prompts=["will fail"], name="test")

    asyncio.run(run._run_prompts(client, args, questions, out, state))

    assert not state.is_completed("cuaderno-test-001")
    assert "cuaderno-test-001" in state._data["failed"]
