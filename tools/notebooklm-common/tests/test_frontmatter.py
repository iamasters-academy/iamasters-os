"""FIX A7 + C3 at the rendering layer: generated_by fixed by the caller; the answer
is always routed through serialize_answer, so the raw_response leak cannot appear.
"""
import yaml

from lib.frontmatter import CANONICAL_KEYS, build_frontmatter, render_markdown
from lib.questions import load_questions
from tests.fakes import FakeAskResult

Q = load_questions(None, scope="per_source")[0]


def test_build_frontmatter_has_all_canonical_keys():
    fm = build_frontmatter(
        question=Q, notebook_id="nb1", notebook_nombre="nb-slug",
        total_sources=5, generated_by="notebooklm-extractor",
        source_name="Fuente A", scope="per_source",
    )
    for key in CANONICAL_KEYS:
        assert key in fm, f"missing canonical key: {key}"
    assert fm["generated_by"] == "notebooklm-extractor"
    assert fm["total_sources"] == 5


def test_render_markdown_yaml_is_parseable_and_clean():
    md = render_markdown(
        question=Q, notebook_id="nb1", notebook_nombre="nb-slug",
        total_sources=5, generated_by="notebooklm-extractor",
        source_name="Fuente A", scope="per_source",
        answer=FakeAskResult(answer="texto limpio"),
    )
    assert md.startswith("---\n")
    fm_block, body = md[4:].split("---\n", 1)
    fm = yaml.safe_load(fm_block)
    assert fm["generated_by"] == "notebooklm-extractor"
    assert fm["total_sources"] == 5
    # body carries the answer but never the leak
    assert "texto limpio" in body
    assert "raw_response" not in body
    assert ")]}'" not in body
    assert "AskResult(" not in body


def test_generated_by_is_caller_controlled():
    """FIX A7: extractor and deep-research can't mislabel each other anymore."""
    md_ext = render_markdown(
        question=Q, notebook_id="nb1", notebook_nombre="x",
        total_sources=1, generated_by="notebooklm-extractor",
        source_name="s", scope="per_source", answer="a",
    )
    md_dr = render_markdown(
        question=Q, notebook_id="nb1", notebook_nombre="x",
        total_sources=1, generated_by="notebooklm-experto-deepresearch",
        source_name="s", scope="transversal", answer="a",
    )
    assert "generated_by: notebooklm-extractor" in md_ext
    assert "generated_by: notebooklm-experto-deepresearch" in md_dr
