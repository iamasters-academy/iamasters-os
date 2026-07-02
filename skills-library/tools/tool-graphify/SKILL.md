---
name: tool-graphify
description: >
  Convierte cualquier proyecto en un grafo de conocimiento con Graphify (paquete
  'graphifyy', repo safishamsi/graphify) para que Claude navegue arquitectura y
  dependencias en vez de hacer grep/glob a ciegas — hasta ~71x menos tokens en
  codebases grandes. Usa esta skill SIEMPRE que el operador diga "graphify",
  "mapea/indexa este proyecto", "monta el grafo de conocimiento del código",
  "haz que Claude entienda la arquitectura sin leer todo el repo", "reduce los
  tokens de búsqueda", "grafo de dependencias", o cuando vaya a trabajar sobre un
  repo grande y quiera que Claude siga imports/relaciones con precisión. También
  cuando pregunte "¿cómo conecta X con Y?" o "qué depende de este módulo" a nivel
  de arquitectura. NO la uses para búsqueda semántica de contenido suelto por
  temas (eso es RAG), ni en repos pequeños (<30 archivos, no compensa).
version: 0.1.0
---

# tool-graphify — Grafo de conocimiento del código con Graphify

> **CLI vs slash**: conduce Graphify con la **CLI por Bash** (`graphify ...`) para que sea
> determinista y repetible. Tras `graphify install` también existe el slash-command nativo
> `/graphify ...` como atajo interactivo — mismos parámetros. Usa la CLI en los pasos de
> esta skill.

Graphify indexa un repo en un grafo (nodos: archivos, funciones, clases, conceptos;
aristas: imports, llamadas, dependencias, similitud semántica) y expone un
`GRAPH_REPORT.md` + `graph.json`. Claude consulta el grafo antes de buscar, así sigue
conexiones reales en vez de grepear archivo por archivo. Compensa en repos medianos/
grandes (cientos de archivos); en repos diminutos no aporta.

**Cada proyecto tiene SU grafo**: la herramienta y esta skill son globales, pero el grafo
se construye dentro de cada repo (`graphify-out/` local al proyecto) y nunca se mezclan.

## Regla de decisión (dísela al operador si duda)

- **Arquitectura / dependencias precisas** ("¿qué depende de X?", "¿cómo conecta login
  con la tabla de usuarios?") → usa el **grafo** (sigue conexiones).
- **Contenido suelto por temas / similitud** ("dónde se habla de rate limiting") → RAG
  tradicional. El grafo no sustituye a la búsqueda semántica.

## Requisitos (una sola vez por máquina)

Graphify se instala global; el grafo se construye por proyecto.

1. Instalador: preferir `uv` (ya presente). Alternativas: `pipx` o `pip`.
2. Instalar Graphify y su skill de Claude Code:
   ```bash
   uv tool install graphifyy && graphify install
   ```
   En Windows, si la autodetección falla: `graphify install --platform windows`.
3. Extras opcionales (solo si el repo los necesita):
   - Vídeo/audio (Whisper local, necesita ffmpeg — ya presente):
     `uv tool install 'graphifyy[video]'`
   - Documentos Office: `graphifyy[office]` · MCP: `graphifyy[mcp]`

Comprueba antes: `graphify --version`. Si `graphify` no está en PATH tras `uv tool install`,
`uv tool update-shell` (o reinicia la terminal). En una shell ya abierta:
`export PATH="$HOME/.local/bin:$PATH"`.

## Construir el grafo (por proyecto)

Desde la raíz del proyecto objetivo:

```bash
graphify .                    # indexa el directorio actual
graphify ./carpeta            # una subcarpeta concreta
graphify . --mode deep        # inferencia agresiva de relaciones (más tokens)
graphify . --update           # solo archivos cambiados, fusiona con el grafo existente
graphify . --watch            # auto-sincroniza mientras editas
```

Salida en `graphify-out/`: `GRAPH_REPORT.md` (god nodes + comunidades) y `graph.json`
(persistente; caché SHA256 salta archivos sin cambios). **Grafo vivo**: al reindexar solo
reprocesa lo modificado — no re-embebe todo como el RAG vectorial.

### Niveles de ingesta (decide según el repo)

- **L1 — Código** (tree-sitter, 25 lenguajes): **local, gratis, sin LLM**. Estructura,
  llamadas, imports. Es la base; empieza siempre por aquí.
- **L2 — Audio/vídeo** (faster-whisper local): transcribe multimedia al grafo. Requiere el
  extra `[video]` + ffmpeg. Local, sin coste de tokens.
- **L3 — Docs/imágenes** (PDFs, papers, diagramas): análisis **semántico vía subagentes de
  Claude → consume tokens de la API**. Actívalo solo si el repo tiene documentación que
  quieras en el grafo.

## Consultar el grafo

```bash
graphify explain "NombreDeNodo"        # fuerza a mirar el grafo antes de responder
graphify query "¿qué conecta X con Y?"
graphify path "NodoA" "NodoB"          # camino más corto entre dos nodos
```

## Modo always-on — YA ACTIVO vía Sinapsis (no uses el hook de Graphify)

El always-on de este entorno NO es el de Graphify: es la passive rule
`graphify-graph-first` en `~/.claude/skills/_passive-rules.json`, que antes de cada
`Grep`/`Glob` recuerda mirar `graphify-out/GRAPH_REPORT.md` si existe. Cubre todos los
proyectos con el hook Sinapsis ya instalado.

**Comportamiento esperado en sesión** (cualquier repo): antes de buscar a ciegas, comprueba
si existe `graphify-out/GRAPH_REPORT.md`. Si existe → léelo y navega el grafo
(`graphify query/explain/path`). Si no existe y el repo es mediano/grande → ofrece
construirlo con esta skill.

- ⚠️ **NO ejecutes `graphify claude install`** en ningún repo del operador: duplicaría el
  always-on (ya lo da la passive rule), y en `iamasters-os` chocaría con el CLAUDE.md y los
  hooks gestionados por el OS (historial de cuelgues por hooks PreToolUse nuevos). Si
  alguna vez aparece instalado, `graphify claude uninstall`.

## Exportar / visualizar (opcional)

```bash
graphify . --obsidian                  # vault de Obsidian navegable (notas por nodo)
graphify . --obsidian --obsidian-dir ~/vault
graphify . --graphml                   # export para Gephi/yEd
graphify . --wiki                      # artículos markdown
graphify . --no-viz                    # solo report + JSON
```

## Checklist al aplicar a un proyecto nuevo

1. ¿Repo mediano/grande? Si <30 archivos, avisa que no compensa.
2. `graphify .` (L1). Revisa `graphify-out/GRAPH_REPORT.md`.
3. ¿Hay docs/multimedia relevantes? Ofrece L2/L3 avisando del coste (L3 = tokens).
4. Añade `graphify-out/` al `.gitignore` del repo si el operador no quiere versionar el
   grafo (pregúntale; por defecto NO se versiona).
5. Mantenimiento: `graphify . --update` (o `--watch`) tras cambios grandes. El always-on
   ya está cubierto por la passive rule de Sinapsis — no instales el hook de Graphify.
