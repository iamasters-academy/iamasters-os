"""Skill-level test for notebooklm-extractor's canonical scripts/extract.py.

Drives process_sources() with the FakeClient to verify the script writes 8 .md per
source with the correct generated_by, per-source source_ids, and no raw_response
leak. No network, no Google quota.
"""
import asyncio
import importlib
import sys
from pathlib import Path

import pytest

from lib import load_questions
from tests.fakes import FakeSource

EXTRACTOR_SCRIPTS = Path.home() / ".claude" / "skills" / "notebooklm-extractor" / "scripts"


@pytest.fixture(scope="module")
def extract():
    if not EXTRACTOR_SCRIPTS.exists():
        pytest.skip(f"extractor skill not installed at {EXTRACTOR_SCRIPTS}")
    sys.path.insert(0, str(EXTRACTOR_SCRIPTS))
    # ensure the vendored lib resolves (extract.py bootstraps skill/lib on import)
    import extract as _extract
    return importlib.reload(_extract)


def test_process_sources_writes_8_per_source(extract, tmp_path):
    from tests.fakes import FakeClient

    questions = load_questions(None, scope="per_source")
    sources = [FakeSource(id="s1", title="Fuente Uno"), FakeSource(id="s2", title="Fuente Dos")]
    client = FakeClient(sources=sources)
    out = tmp_path / "out"
    out.mkdir()

    written = asyncio.run(extract.process_sources(
        client, "nb1", "nb-slug", sources, questions, out, sleep=0,
    ))

    assert written == 16  # 8 questions x 2 sources
    # one folder per source slug
    assert (out / "fuente-uno").is_dir()
    assert (out / "fuente-dos").is_dir()
    files = sorted((out / "fuente-uno").glob("*.md"))
    assert len(files) == 8


def test_process_sources_uses_per_source_source_ids(extract, tmp_path):
    from tests.fakes import FakeClient

    questions = load_questions(None, scope="per_source")
    sources = [FakeSource(id="abc", title="Solo")]
    client = FakeClient(sources=sources)
    out = tmp_path / "out"
    out.mkdir()

    asyncio.run(extract.process_sources(client, "nb1", "slug", sources, questions, out, sleep=0))

    asks = client.calls_of("chat.ask")
    assert len(asks) == 8
    # every ask targets exactly the one source id (per-source scope) — never None
    assert all(a["source_ids"] == ["abc"] for a in asks)


def test_output_has_correct_generated_by_and_no_leak(extract, tmp_path):
    from tests.fakes import FakeClient

    questions = load_questions(None, scope="per_source")
    sources = [FakeSource(id="s1", title="Fuente")]
    client = FakeClient(sources=sources)
    out = tmp_path / "out"
    out.mkdir()

    asyncio.run(extract.process_sources(client, "nb1", "slug", sources, questions, out, sleep=0))

    md = (out / "fuente" / "01_descomposicion_profunda.md").read_text(encoding="utf-8")
    assert "generated_by: notebooklm-extractor" in md
    assert "raw_response" not in md
    assert ")]}'" not in md
    assert "AskResult(" not in md


def test_process_sources_continues_on_error(extract, tmp_path):
    """A failing question must not abort the whole source."""
    from tests.fakes import FakeClient

    questions = load_questions(None, scope="per_source")

    class BoomClient(FakeClient):
        pass

    sources = [FakeSource(id="s1", title="Fuente")]
    client = BoomClient(sources=sources)
    # make the 3rd question blow up
    original_ask = client.chat.ask

    async def flaky_ask(notebook_id, question, source_ids=None, conversation_id=None):
        if "resumen ejecutivo" in question.lower():
            raise RuntimeError("simulated network error")
        return await original_ask(notebook_id, question, source_ids=source_ids)

    client.chat.ask = flaky_ask
    out = tmp_path / "out"
    out.mkdir()

    written = asyncio.run(extract.process_sources(client, "nb1", "slug", sources, questions, out, sleep=0))
    # 7 of 8 succeeded (resumen_ejecutivo is question 4)
    assert written == 7
