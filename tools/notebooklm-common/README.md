# notebooklm-common

Shared library for the `notebooklm-extractor` and `notebooklm-experto-deepresearch`
skills. Single source of truth for: path resolution, the SDK client wrapper
(auth / retry / serializer), the 8 strategic questions, frontmatter rendering,
and idempotent run state.

## Why this exists

Both skills previously duplicated ~70% of their code (SDK calls, the 8 questions,
auth, frontmatter) across dozens of ad-hoc scripts, and carried two critical bugs:

- **C1** — per-source questions used `CitedSourceSelection(source_ids=, mode=)` +
  `chat.ask(cited_source_selection=)`, neither of which exists in the SDK. The real
  per-source scope is `source_ids=[source.id]`.
- **C3** — answers were saved via `str(AskResult)`, leaking the whole dataclass
  including `raw_response` with raw Google RPC chunks (`)]}'...`).
- **C4** — deep research passed `task_id=task.task_id` (from `start`) to
  `import_sources`; it must be `result.task_id` (from `poll`). This is why all 7
  prompts ended in `failed` with `total_sources: 0`.

These fixes live in `lib/client.py` (`ask_per_source`, `serialize_answer`,
`run_deep_research`) so they are centralized and unit-tested once.

## Layout

```
lib/
├── paths.py        # output resolves under <cwd>/<project>/conocimiento/... (never in the skill)
├── client.py       # AuthManager, get_client, retry_network, serialize_answer (C3),
│                   # ask_per_source (C1), ask_transversal, run_deep_research (C4)
├── questions.py    # the 8 questions (per_source + transversal), load/adapt
├── frontmatter.py  # canonical frontmatter + render_markdown (the only .md writer)
└── state.py        # RunState for idempotent deep-research runs
tests/              # pytest, FakeClient — no network, no Google quota
sync_lib.py         # vendor lib/ into both skills + drift guard
```

## Run the tests

```bash
py -3 -m pip install -r requirements-dev.txt
py -3 -m pytest tests -v
```

Tests use a `FakeClient` that records every SDK call, so they assert the exact
arguments (e.g. `chat.ask` receives `source_ids=[...]`, `import_sources` receives
`task_id=<from poll>`) without spending NotebookLM quota.

## Vendor into the skills

After editing the canonical `lib/`, sync both skills (they must stay byte-identical):

```bash
py -3 sync_lib.py          # copy lib/ into ~/.claude/skills/<each>/lib/
py -3 sync_lib.py --check  # exit 1 if a vendored copy drifted
```

Each skill's script bootstraps its local `lib/` via `sys.path` (no install step),
so a skill folder remains self-contained and portable.

## Editing rules

- Edit ONLY files under `lib/` here. Never edit the vendored copies in the skills.
- After any change, run `sync_lib.py` so both skills pick it up.
- The SDK surface is isolated in `client.py`; if Google's undocumented API changes,
  adapt in one place.
