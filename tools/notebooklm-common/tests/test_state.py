"""FIX M5: idempotent run state for deep-research."""
from lib.state import RunState


def test_mark_completed_and_is_completed(tmp_path):
    st = RunState(tmp_path / "state.json")
    assert not st.is_completed("nb-001")
    st.mark_completed("nb-001", "id-abc", sources=10)
    assert st.is_completed("nb-001")


def test_mark_failed_then_completed_clears_failed(tmp_path):
    st = RunState(tmp_path / "state.json")
    st.mark_failed("nb-001", "boom")
    st.mark_completed("nb-001", "id-abc", sources=10)
    assert st.is_completed("nb-001")
    assert "nb-001" not in st._data["failed"]


def test_persists_across_reload(tmp_path):
    p = tmp_path / "state.json"
    RunState(p).mark_completed("nb-001", "id-abc", sources=10)
    st2 = RunState(p)
    assert st2.is_completed("nb-001")
    assert st2.summary()["completed"] == 1


def test_corrupt_state_starts_fresh(tmp_path):
    p = tmp_path / "state.json"
    p.write_text("{not valid json", encoding="utf-8")
    st = RunState(p)
    assert st.summary() == {"completed": 0, "failed": 0}
