---
description: Catálogo de skills del OS — ver instaladas, descubrir disponibles e instalar/desinstalar de la biblioteca. Uso — /skills, /skills add <nombre>, /skills remove <nombre>
---

# /skills

El OS funciona con un modelo **Core + Biblioteca**: las skills core vienen instaladas (el sistema las necesita) y el resto vive en `skills-library/` sin ocupar contexto hasta que el operador las instala. Cada skill instalada consume contexto en cada sesión — Anthropic recomienda no pasar de ~50 cargadas. Menos es más.

## Sin argumentos → mostrar catálogo

1. Ejecutar:
   ```bash
   bash scripts/skills.sh list
   ```
2. Presenta el resultado agrupado y legible: instaladas primero, luego disponibles por categoría (marketing, strategy, tools, automation, visualization), una línea por skill con su descripción en lenguaje llano.
3. Cierra con: "¿Quieres que instale alguna? Dime el nombre o cuéntame qué necesitas hacer y te digo cuál encaja."

## `add <nombre>` → instalar

1. Ejecutar `bash scripts/skills.sh add <nombre>` (resuelve dependencias solo).
2. Confirmar al usuario qué se instaló y recordarle: **reinicia Claude Code para que cargue**.

## `remove <nombre>` → desinstalar

1. Ejecutar `bash scripts/skills.sh remove <nombre>`.
2. Las core no se pueden quitar (el script lo impide y explica por qué).
3. Si la skill tenía personalización (`SKILL.local.md`), el script la guarda: si la reinstala en el futuro, vuelve con sus reglas.

## Matching por intención (IMPORTANTE)

Cuando el usuario pida algo que una skill de la **biblioteca** resuelve y no la tiene instalada (p. ej. "audita esta web" → `tool-web-legal-audit`, "transcribe este reel" → `tool-transcribe-social`, "analiza mi campaña de Meta" → `marketing-meta-ads-analyzer`):

1. NO digas solo "no tengo esa capacidad".
2. Ofrece: "Eso lo hace la skill `<nombre>` de la biblioteca. ¿La instalo? (un comando, 5 segundos)".
3. Si acepta → `bash scripts/skills.sh add <nombre>` y recuérdale reiniciar.

## Disparadores en lenguaje natural

"qué skills hay", "qué skills tengo", "lista de skills", "catálogo de skills", "instala <nombre>", "instálame la skill de <tema>", "quita/desinstala <nombre>", "qué más sabe hacer el OS".

## Retirar una skill CORE

Las core no se desinstalan con `remove` (el OS las necesita). Si quieres que una
deje de cargarse —para no gastar contexto por sesión— muévela a
`.claude/skills/_archived/<nombre>/` con el nombre exacto:

```bash
mv .claude/skills/<nombre> .claude/skills/_archived/<nombre>
```

`/actualiza` respeta ese archivado y no la reinstala. Nada se borra: para
recuperarla, muévela de vuelta y reinicia Claude Code.
