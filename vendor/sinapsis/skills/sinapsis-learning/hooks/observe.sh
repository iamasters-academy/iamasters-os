#!/bin/bash
# Sinapsis Observer - v4.1
# Writes one JSONL line per tool use to observations.jsonl
# Requires: python3
# Called by settings.json hooks as:
#   PreToolUse:  bash ~/.claude/skills/sinapsis-learning/hooks/observe.sh pre
#   PostToolUse: bash ~/.claude/skills/sinapsis-learning/hooks/observe.sh post

HOOK_PHASE="${1:-post}"

# Read stdin
INPUT_JSON=$(cat)
[ -z "$INPUT_JSON" ] && exit 0

# Skip if disabled
[ -f "$HOME/.claude/homunculus/disabled" ] && exit 0

# Skip non-interactive entrypoints
case "${CLAUDE_CODE_ENTRYPOINT:-cli}" in
  cli|sdk|api|claude-desktop|"") ;;
  *) exit 0 ;;
esac

[ "${ECC_HOOK_PROFILE:-standard}" = "minimal" ] && exit 0
[ "${ECC_SKIP_OBSERVE:-0}" = "1" ] && exit 0

# Find a REAL Python 3. IMPORTANT: validate `--version` actually reports
# "Python 3" — the Windows Store "python3"/"python" aliases exist on PATH but
# only open the Store (exit 49), so `command -v` alone gives a false positive
# and observations silently stop. Try the Windows `py -3` launcher last.
PYRUN=""
for cand in "python3" "python" "py -3"; do
  if $cand --version 2>&1 | grep -q "^Python 3"; then PYRUN="$cand"; break; fi
done
[ -z "$PYRUN" ] && exit 0

# Run the observer ($PYRUN unquoted so "py -3" splits into command + arg)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
echo "$INPUT_JSON" | $PYRUN "$SCRIPT_DIR/observe_v3.py" "$HOOK_PHASE"

exit 0
