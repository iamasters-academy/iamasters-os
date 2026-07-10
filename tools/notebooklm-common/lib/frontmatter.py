"""Canonical frontmatter + markdown rendering for NotebookLM output .md files.

render_markdown() is the SINGLE function that writes .md bodies. It always routes
the answer through serialize_answer(), so the str(AskResult) leak (C3) cannot
reappear via copy-paste. generated_by is fixed by the calling skill, killing the
cross-mislabeling (A7) where extractor outputs were tagged as deep-research.
"""
from __future__ import annotations

from datetime import date
from typing import Literal

import yaml

from .client import SDK_VERSION, serialize_answer
from .paths import slugify
from .questions import Question, Scope

CANONICAL_KEYS: tuple[str, ...] = (
    "title", "slug", "category", "created", "generated_by", "notebook_id",
    "notebook_nombre", "source_name", "question_type", "sdk_version",
    "source", "source_url", "total_sources", "type", "tags",
)

GeneratedBy = Literal["notebooklm-extractor", "notebooklm-experto-deepresearch"]


def build_frontmatter(
    *,
    question: Question,
    notebook_id: str,
    notebook_nombre: str,
    total_sources: int,
    generated_by: GeneratedBy,
    source_name: str,
    scope: Scope,
    prompt_numero: int | None = None,
) -> dict:
    """Build a canonical frontmatter dict containing every CANONICAL_KEY."""
    scope_tag = "per_source" if scope == "per_source" else "transversal"
    fm: dict = {
        "title": f"{question.num}. {question.name.upper()} - {scope_tag.upper()}",
        "slug": f"{slugify(question.name)}-{scope_tag}-{date.today().isoformat()}",
        "category": f"conocimiento-{scope_tag}",
        "created": date.today().isoformat(),
        "generated_by": generated_by,
        "notebook_id": notebook_id,
        "notebook_nombre": notebook_nombre,
        "source_name": source_name,
        "question_type": f"{question.name}_{scope_tag}",
        "sdk_version": SDK_VERSION,
        "source": f"notebooklm-{scope_tag}",
        "source_url": f"https://notebooklm.google.com/notebook/{notebook_id}",
        "total_sources": total_sources,
        "type": f"analisis-{scope_tag}",
        "tags": [scope_tag, slugify(question.name), "conocimiento-profundo"],
    }
    if prompt_numero is not None:
        fm["prompt_numero"] = prompt_numero
    return fm


def render_markdown(
    *,
    question: Question,
    notebook_id: str,
    notebook_nombre: str,
    total_sources: int,
    generated_by: GeneratedBy,
    source_name: str,
    scope: Scope,
    answer,
    prompt_numero: int | None = None,
) -> str:
    """Render full .md content: frontmatter + body. answer is routed through serialize_answer."""
    fm = build_frontmatter(
        question=question,
        notebook_id=notebook_id,
        notebook_nombre=notebook_nombre,
        total_sources=total_sources,
        generated_by=generated_by,
        source_name=source_name,
        scope=scope,
        prompt_numero=prompt_numero,
    )
    fm_yaml = yaml.dump(fm, default_flow_style=False, allow_unicode=True, sort_keys=False)
    clean_answer = serialize_answer(answer)

    scope_label = "por fuente individual" if scope == "per_source" else "transversal (TODAS las fuentes)"
    return (
        f"---\n"
        f"{fm_yaml}---\n"
        f"# {question.num}. {question.name.upper()} - {fm['type'].upper()}\n\n"
        f"## Pregunta\n{question.question}\n\n"
        f"## Contexto del análisis\n"
        f"- **Total fuentes analizadas:** {total_sources}\n"
        f"- **Fuente:** {source_name}\n"
        f"- **Alcance:** {scope_label}\n\n"
        f"## Respuesta NotebookLM\n{clean_answer}\n\n"
        f"---\n"
        f"**SDK:** {SDK_VERSION} · **Generado por:** {generated_by}\n"
    )
