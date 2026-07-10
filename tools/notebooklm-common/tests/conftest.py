"""Pytest config: make the canonical lib importable as `lib`, and provide fixtures."""
from __future__ import annotations

import sys
from pathlib import Path

# tools/notebooklm-common/ on sys.path so `import lib.client` resolves.
ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

import pytest

from tests.fakes import FakeClient, FakeSource


@pytest.fixture
def fake_client():
    return FakeClient(sources=[FakeSource(id="src-1", title="Análisis táctico 2026"),
                               FakeSource(id="src-2", title="Modelos xG avanzados")])


@pytest.fixture
def tmp_project(tmp_path):
    """A fake project root with a conocimiento/ folder."""
    (tmp_path / "projects" / "demo").mkdir(parents=True)
    (tmp_path / "projects" / "demo" / "conocimiento").mkdir()
    return tmp_path
