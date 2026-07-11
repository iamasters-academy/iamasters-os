#!/usr/bin/env bash
# skill-change-detector — hook PostToolUse (Edit|Write), best-effort.
# Cuando cambian skills en .claude/skills/, deja un flag .claude/.skills-pending.json
# para que /start-here o /wrap-up sincronicen el catálogo en la próxima sesión.
# Best-effort por diseño: NUNCA debe romper ni bloquear la sesión.

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." 2>/dev/null && pwd)" || exit 0
SKILLS_DIR="$REPO_DIR/.claude/skills"
FLAG="$REPO_DIR/.claude/.skills-pending.json"

[ -d "$SKILLS_DIR" ] || exit 0

# exclude _archived/ drafts (matches regen-catalog.mjs): archived isn't a real skill
count=$(find "$SKILLS_DIR" -name SKILL.md -not -path "*/_archived/*" 2>/dev/null | wc -l | tr -d ' ')
ts=$(date -u +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || echo "")
printf '{"pending":true,"skill_count":%s,"detected_at":"%s"}\n' "${count:-0}" "$ts" > "$FLAG" 2>/dev/null || true

exit 0
