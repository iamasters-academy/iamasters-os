"""FIX C3 regression guard: serialize_answer must return ONLY .answer text,
never str(AskResult) (which leaked raw_response with raw Google RPC chunks).
"""
from types import SimpleNamespace

from lib.client import serialize_answer

# The raw chunk that appeared in the broken output (notebook-agencia-001/01_...md:32).
RAW_LEAK = ")]}'"
RAW_LEAK_FULL = "raw_response=')]}\\'\\n\\n920\\n[[\"wrb.fr\""


def test_extracts_answer_from_askresult_like_object():
    obj = SimpleNamespace(answer="Conceptos clave del fútbol.", raw_response=RAW_LEAK_FULL)
    assert serialize_answer(obj) == "Conceptos clave del fútbol."


def test_does_not_leak_raw_response():
    obj = SimpleNamespace(answer="respuesta limpia", raw_response=RAW_LEAK_FULL)
    out = serialize_answer(obj)
    assert RAW_LEAK not in out
    assert "AskResult" not in out
    assert "raw_response" not in out


def test_returns_empty_for_none():
    assert serialize_answer(None) == ""


def test_returns_empty_for_object_without_answer():
    # Must NOT fall back to str(obj) — that is precisely the bug.
    obj = SimpleNamespace(raw_response=RAW_LEAK_FULL)  # no .answer attr
    assert serialize_answer(obj) == ""
    assert RAW_LEAK not in serialize_answer(obj)


def test_legacy_dict_shape():
    assert serialize_answer({"answer": "texto"}) == "texto"
    assert serialize_answer({"answer": ""}) == ""


def test_plain_string_passthrough():
    assert serialize_answer("solo texto") == "solo texto"
