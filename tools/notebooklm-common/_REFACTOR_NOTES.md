# Refactor notes — NotebookLM skills (2026-07-10)

Full audit + refactor of the two global NotebookLM skills. Both were
non-functional as documented; both are now coherent, tested, and share a lib.

## Skills touched

- `~/.claude/skills/notebooklm-extractor/` — per-source extractor (EXISTING notebook → 8 questions × each source).
- `~/.claude/skills/notebooklm-experto-deepresearch/` — deep-research runner (prompts → create notebook + deep research + 8 transversal questions).

## Shared lib (canonical, here)

`tools/notebooklm-common/lib/` — the single source of truth, vendored into both
skills by `sync_lib.py`:

| Module | Role |
|---|---|
| `client.py` | `AuthManager`, `get_client`, `retry_network`, `serialize_answer` (C3), `ask_per_source` (C1), `ask_transversal`, `run_deep_research` (C4) |
| `questions.py` | the 8 questions (`per_source` + `transversal`), `load_questions`, `adapt_questions` |
| `frontmatter.py` | canonical frontmatter + `render_markdown` (the only `.md` writer) |
| `paths.py` | output resolves to `<cwd>/<project>/conocimiento/...` (never inside the skill) |
| `state.py` | `RunState` for idempotent deep-research runs |

## Critical bugs fixed (all guarded by regression tests in `tests/`)

- **C1** — per-source ask used the non-existent `CitedSourceSelection(source_ids=, mode=)` + `chat.ask(cited_source_selection=)`. Real API: `chat.ask(source_ids=[id])`. → `ask_per_source()`.
- **C2** — `Source` accessed as dict (`source.get('name')`); it's a frozen dataclass (`.id`/`.title`). → `extract_source_ids` / `source_title`.
- **C3** — answers saved via `str(AskResult)`, leaking `raw_response` with raw Google RPC chunks. → `serialize_answer()` returns only `.answer`.
- **C4** — `import_sources(task_id=task.task_id)` (from `start`); must be `result.task_id` (from `poll`). This is why all 7 experto prompts ended in `failed` with `total_sources: 0`. → `run_deep_research()`.
- **C5/C6** — experto SKILL.md had broken/duplicated Python; several scripts hardcoded `--project` / notebook IDs / absolute paths. → rewritten SKILL.md (prose + script reference), single canonical script.
- **A1–A9** — extractor SKILL.md fake pseudocode (`extract_tags` placeholder), SKILL↔README mismatch, no triggers, 8 questions duplicated in ~18 files, inconsistent frontmatter, no `requirements.txt`, cross-mislabeling, 17 ad-hoc scripts. → all resolved.
- **M1/M5** — outputs written inside the skill folder; run state inside the skill. → outputs go to the active project cwd; state next to output.

## What was archived (preserved, not deleted)

- Extractor: 17 ad-hoc scripts + `extract_questions.py` → `<skill>/_archive/pre_refactor/`.
- Experto: `run.py`, `run_robusto.py`, `auth_manager.py`, `execute_8_questions.py`, `generate_prompts.py`, `procesar_pendientes.py`, `procesar_notebooks_existentes.py`, `check_*`, `list_*`, `test_*`, `temp_list.py` + `NOTEBOOKLM_MANUAL/` + `.notebooklm_state.json` → `<skill>/_archive/pre_refactor/`.
- Legacy outputs (82 `.md`, carrying the C3/A7 bugs) → `projects/app video/conocimiento/notebooklm-extracted/_archive_pre_refactor/<skill>/` with `_README_LEGACY.md`.

## How to verify

```bash
# 1. unit + skill tests (FakeClient, no Google quota)
py -3 -m pytest tools/notebooklm-common/tests -p no:seleniumbase -p no:asyncio

# 2. vendored libs match the canonical copy
py -3 tools/notebooklm-common/sync_lib.py --check

# 3. scripts run (no API)
py -3 ~/.claude/skills/notebooklm-extractor/scripts/extract.py --help
py -3 ~/.claude/skills/notebooklm-experto-deepresearch/scripts/run.py --help
```

Test count: 41 (serialize/paths/questions/frontmatter/state/flow + extract-skill + run-skill).

## Editing rules going forward

- Edit ONLY `tools/notebooklm-common/lib/`. Never the vendored copies.
- After any change: `py -3 tools/notebooklm-common/sync_lib.py` to refresh both skills.
- The SDK surface is isolated in `lib/client.py` — if Google's undocumented API changes, adapt there.
- New tests go in `tools/notebooklm-common/tests/`.
