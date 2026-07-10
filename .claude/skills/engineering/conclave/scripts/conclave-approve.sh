#!/usr/bin/env bash
# Cónclave · sellar el árbol staged tras el DOBLE OK.
# Llamar SOLO cuando constructor + revisor han dado APTO. Después: git commit.
set -euo pipefail
mkdir -p .conclave
git write-tree > .conclave/pass
echo "✓ Conclave: sello escrito para el arbol staged actual. Ya puedes commitear."
