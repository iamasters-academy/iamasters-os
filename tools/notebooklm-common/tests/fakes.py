"""Fake NotebookLM client for tests — records every call so tests can assert on
the exact arguments (especially chat.ask source_ids and research.import_sources task_id).

No network, no Google quota. Mirrors the real SDK surface we depend on.
"""
from __future__ import annotations

from dataclasses import dataclass, field


@dataclass
class FakeSource:
    id: str
    title: str
    kind: str = "web"
    url: str = ""
    status: str = "active"


@dataclass
class FakeAskResult:
    # The leak that must NEVER reach a .md file (the C3 bug dumped str(AskResult)).
    answer: str
    conversation_id: str = "conv-1"
    raw_response: str = ")]}'\n\n920\n[[\"wrb.fr\",null,\"[[\\\"**Initiating..."


@dataclass
class FakeResearchStart:
    task_id: str = "task-from-start"
    mode: str = "deep"


@dataclass
class FakeResearchResult:
    status: str = "completed"
    # The task_id import_sources MUST use (the poll one, NOT the start one). FIX C4.
    task_id: str = "task-from-poll"
    sources: list = field(default_factory=list)


class _Chat:
    def __init__(self, calls):
        self._calls = calls

    async def ask(self, notebook_id, question, source_ids=None, conversation_id=None):
        self._calls.append({
            "method": "chat.ask", "notebook_id": notebook_id,
            "question": question, "source_ids": source_ids,
        })
        return FakeAskResult(answer=f"Respuesta a: {question}")


class _Sources:
    def __init__(self, calls, sources):
        self._calls = calls
        self._sources = sources

    async def list(self, notebook_id):
        self._calls.append({"method": "sources.list", "notebook_id": notebook_id})
        return list(self._sources)

    async def wait_for_sources(self, notebook_id, source_ids, timeout=None):
        self._calls.append({
            "method": "sources.wait_for_sources", "notebook_id": notebook_id,
            "source_ids": list(source_ids), "timeout": timeout,
        })


class _Research:
    def __init__(self, calls, sources=None):
        self._calls = calls
        self._sources = sources or [FakeSource(id="rs-1", title="Web A"), FakeSource(id="rs-2", title="Web B")]

    async def start(self, notebook_id, query, source="web", mode="fast"):
        self._calls.append({
            "method": "research.start", "notebook_id": notebook_id,
            "query": query, "source": source, "mode": mode,
        })
        return FakeResearchStart()

    async def poll(self, notebook_id, task_id=None):
        self._calls.append({
            "method": "research.poll", "notebook_id": notebook_id, "task_id": task_id,
        })
        return FakeResearchResult(status="completed", task_id="task-from-poll", sources=list(self._sources))

    async def import_sources(self, notebook_id, task_id, sources):
        self._calls.append({
            "method": "research.import_sources", "notebook_id": notebook_id,
            "task_id": task_id, "sources": list(sources),
        })
        return [FakeSource(id="s-1", title="Imported A"), FakeSource(id="s-2", title="Imported B")]


class _Notebooks:
    def __init__(self, calls):
        self._calls = calls

    async def list(self):
        self._calls.append({"method": "notebooks.list"})
        return []

    async def create(self, title):
        nb = FakeSource(id="nb-new", title=title)
        self._calls.append({"method": "notebooks.create", "title": title})
        return nb


class FakeClient:
    """Drop-in fake for NotebookLMClient. Records all calls in self.calls."""

    def __init__(self, sources=None, research_sources=None):
        self.calls: list[dict] = []
        self.chat = _Chat(self.calls)
        self.sources = _Sources(self.calls, sources or [])
        self.research = _Research(self.calls, sources=research_sources)
        self.notebooks = _Notebooks(self.calls)

    def calls_of(self, method: str) -> list[dict]:
        return [c for c in self.calls if c["method"] == method]

    async def __aenter__(self):
        return self

    async def __aexit__(self, *exc):
        return False
