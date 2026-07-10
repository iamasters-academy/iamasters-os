"""FIX A4: the 8 questions live in ONE place; per-source vs transversal stay distinct,
and adapt_questions injects the user's domain.
"""
import pytest

from lib.questions import (
    BASE_QUESTIONS_PER_SOURCE,
    BASE_QUESTIONS_TRANSVERSAL,
    adapt_questions,
    load_questions,
)


def test_eight_questions_per_source():
    qs = load_questions(None, scope="per_source")
    assert len(qs) == 8
    assert [q.num for q in qs] == list(range(1, 9))
    assert all(q.name and q.question and q.type for q in qs)


def test_eight_questions_transversal():
    qs = load_questions(None, scope="transversal")
    assert len(qs) == 8
    assert [q.num for q in qs] == list(range(1, 9))


def test_no_cross_contamination():
    """Per-source questions reference a single source; transversal ones do not."""
    per = load_questions(None, scope="per_source")
    trans = load_questions(None, scope="transversal")
    # per-source always addresses a single source ("esta fuente")
    assert all("esta fuente" in q.question.lower() for q in per)
    # transversal must NOT carry the singular per-source phrasing
    assert all("esta fuente" not in q.question.lower() for q in trans)


def test_adapt_questions_injects_domain():
    qs = load_questions(None, scope="transversal")
    adapted = adapt_questions(qs, "analítica de fútbol")
    assert all("analítica de fútbol" in q.question for q in adapted)
    # original untouched (frozen dataclass -> new instances)
    assert "analítica de fútbol" not in qs[0].question


def test_adapt_questions_none_is_noop():
    qs = load_questions(None, scope="per_source")
    assert adapt_questions(qs, None) == qs
    assert adapt_questions(qs, "") == qs


def test_load_questions_from_json(tmp_path):
    f = tmp_path / "q.json"
    f.write_text('[{"name":"x","question":"¿q?"},{"name":"y","question":"¿q2?"}]', encoding="utf-8")
    qs = load_questions(f, scope="per_source")
    assert [q.name for q in qs] == ["x", "y"]
    assert [q.num for q in qs] == [1, 2]


def test_load_questions_from_yaml(tmp_path):
    f = tmp_path / "q.yaml"
    f.write_text("questions:\n  - name: a\n    question: ¿a?\n  - name: b\n    question: ¿b?\n", encoding="utf-8")
    try:
        qs = load_questions(f, scope="transversal")
    except RuntimeError as e:  # PyYAML not installed
        pytest.skip(str(e))
    assert [q.name for q in qs] == ["a", "b"]


def test_load_questions_rejects_bad_shape(tmp_path):
    f = tmp_path / "bad.json"
    f.write_text('{"not": "a list"}', encoding="utf-8")
    with pytest.raises(ValueError):
        load_questions(f, scope="per_source")
