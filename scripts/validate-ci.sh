#!/usr/bin/env bash
set -euo pipefail

checks=(
  "scripts/ci/check-skills-frontmatter.sh"
  "scripts/ci/check-skills-depth.sh"
  "scripts/ci/check-skills-registry.sh"
  "scripts/ci/check-internal-links.sh"
  "scripts/ci/check-syntax.sh"
  "scripts/ci/check-secrets.sh"
)

for check in "${checks[@]}"; do
  echo "==> $check"
  bash "$check"
done

