"""FIX C1 + C4 regression guards — the two bugs that made both skills non-functional.

These assert the EXACT arguments the high-level helpers pass to the SDK, using a
FakeClient that records every call. If anyone reverts source_ids or task_id, these fail.
"""
import asyncio

from lib.client import ask_per_source, ask_transversal, run_deep_research


def test_ask_per_source_uses_source_ids(fake_client):
    # FIX C1: per-source scope = source_ids=[id], NOT the non-existent cited_source_selection.
    out = asyncio.run(ask_per_source(fake_client, "nb1", "src-1", "¿De qué trata?"))
    asks = fake_client.calls_of("chat.ask")
    assert len(asks) == 1
    assert asks[0]["source_ids"] == ["src-1"]
    assert asks[0]["question"] == "¿De qué trata?"
    assert "¿De qué trata?" in out


def test_ask_transversal_omits_source_ids(fake_client):
    # Transversal scope: source_ids=None means "all sources".
    asyncio.run(ask_transversal(fake_client, "nb1", "pregunta transversal"))
    asks = fake_client.calls_of("chat.ask")
    assert len(asks) == 1
    assert asks[0]["source_ids"] is None


def test_run_deep_research_uses_poll_task_id(fake_client):
    # FIX C4: import_sources must receive result.task_id (from poll), NOT task.task_id (from start).
    imported, result = asyncio.run(run_deep_research(fake_client, "nb1", "query", poll_max=3))
    imports = fake_client.calls_of("research.import_sources")
    assert len(imports) == 1
    assert imports[0]["task_id"] == "task-from-poll"   # NOT "task-from-start"
    assert len(imported) == 2
    assert fake_client.calls_of("sources.wait_for_sources"), "sources must be awaited"


def test_run_deep_research_start_params(fake_client):
    asyncio.run(run_deep_research(fake_client, "nb1", "fútbol", poll_max=3))
    starts = fake_client.calls_of("research.start")
    assert len(starts) == 1
    assert starts[0]["mode"] == "deep"
    assert starts[0]["source"] == "web"
    assert starts[0]["query"] == "fútbol"


def test_run_deep_research_poll_disambiguates_with_start_task_id(fake_client):
    # poll() is called with the start task_id to disambiguate (SDK recommends it).
    asyncio.run(run_deep_research(fake_client, "nb1", "query", poll_max=3))
    polls = fake_client.calls_of("research.poll")
    assert len(polls) == 1
    assert polls[0]["task_id"] == "task-from-start"
