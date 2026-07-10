"""Shared library for the notebooklm-extractor and notebooklm-experto-deepresearch skills.

Single source of truth for: path resolution, the SDK client wrapper (auth/retry/
serializer), the 8 strategic questions, frontmatter rendering, and run state.

This package is vendored identically into both skills by sync_lib.py. Edit ONLY
the canonical copy at tools/notebooklm-common/lib/ — never the vendored copies.
"""
from .client import (
    AuthManager,
    SDK_VERSION,
    ask_per_source,
    ask_transversal,
    extract_source_ids,
    get_client,
    retry_network,
    run_deep_research,
    serialize_answer,
    source_title,
)
from .frontmatter import CANONICAL_KEYS, build_frontmatter, render_markdown
from .paths import ask_for_project, list_projects, resolve_output_dir, slugify
from .questions import (
    BASE_QUESTIONS_PER_SOURCE,
    BASE_QUESTIONS_TRANSVERSAL,
    Question,
    adapt_questions,
    load_questions,
)
from .state import RunState

__all__ = [
    # client
    "AuthManager", "SDK_VERSION", "get_client", "retry_network",
    "serialize_answer", "extract_source_ids", "source_title",
    "ask_per_source", "ask_transversal", "run_deep_research",
    # frontmatter
    "CANONICAL_KEYS", "build_frontmatter", "render_markdown",
    # paths
    "resolve_output_dir", "slugify", "list_projects", "ask_for_project",
    # questions
    "Question", "BASE_QUESTIONS_PER_SOURCE", "BASE_QUESTIONS_TRANSVERSAL",
    "load_questions", "adapt_questions",
    # state
    "RunState",
]
