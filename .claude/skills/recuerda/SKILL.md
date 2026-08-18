---
name: recuerda
description: Recupera información del histórico del operador (decisiones, eventos, estados de proyectos, contexto de sesiones pasadas) y responde citando la fuente. Se activa ante preguntas sobre el pasado — "¿qué decidimos sobre...", "¿por qué...", "¿cuándo...", "qué pasó con...", "recuérdame..." — o el comando /recuerda. Responde SOLO con lo que encuentra en memoria, citando archivo y fecha; si no lo encuentra, lo dice sin inventar. NO usar para conocimiento general ni para entender el código actual (eso es otra skill / CodeGraph).
---

# recuerda — recall de memoria local

Recall sobre el histórico markdown del operador, indexado localmente (SQLite + FTS5, sin servicios externos). Capa base por keyword para todos; capa semántica opt-in.

## Cuándo se invoca
- Preguntas sobre el pasado: decisiones, por qués, fechas, estado de un proyecto, "qué pasó con X".
- `/recuerda <pregunta>`.
- NO para conocimiento general, ni para el código del proyecto actual.

## Process

### Paso 1 · Tier 0 — ¿ya está en contexto?
Antes de buscar nada, revisa lo ya cargado: `context/working-memory.md`, el daily summary y lo leído en esta sesión. Si la respuesta está ahí → respóndela citando la fuente. Cero búsqueda.

### Paso 2 · Recall (capa base, FTS5)
Si no está en contexto, ejecuta desde la raíz del repo:
```bash
python3 scripts/memory-index/ingest.py --query "{pregunta del usuario}"
```
Hace un ingest incremental rápido (se salta lo que no cambió) y devuelve top-5 chunks con `source_path`, `score` (BM25, más negativo = más relevante), `date`, `section` y un preview.

- Si dice "no se encontraron archivos" o el `.db` no existe → el índice no está creado. Ofrece crearlo: `python3 scripts/memory-index/ingest.py` (sin `--query`).
- Si Python/yaml no están disponibles → degrada a `grep -ri "<términos clave>"` sobre las rutas de `scripts/memory-index/corpus.yaml`. Nunca te quedes sin responder por un fallo técnico.

### Paso 3 · Juzgar relevancia (CRÍTICO — no inventar)
Lee los previews. Decide si alguno **responde de verdad** la pregunta:
- Si SÍ → compón la respuesta con esos chunks. Si el preview no basta, abre el archivo fuente con `Read` en la sección indicada.
- Si NINGUNO responde (hay coincidencia de palabras pero no contienen la respuesta concreta) → di **"No lo tengo registrado en memoria."** y, si procede, ofrece añadirlo al working-memory. **NUNCA inventes el dato** (coherente con la regla no-inventar-datos).

Juzga por el CONTENIDO, no solo por el score. Scores flojos y dispersos suelen indicar que no hay respuesta real.

### Paso 4 · Responder con fuente
```
[Respuesta concreta y directa].
📄 Fuente: `<source_path>` · <fecha>
```
Si combinas varias fuentes, cítalas todas. Conciso.

## Capa semántica (opt-in)
Si el operador la activó (`pip install sqlite-vec fastembed`), añade `--semantic` al comando del Paso 2 para fusionar keyword + significado (RRF). Por defecto NO está activa — la base FTS5 funciona sin instalar nada.

## Reglas
- Cita SIEMPRE la fuente de lo que afirmes desde memoria.
- Si no está, dilo. Cero invención.
- No re-indexes a mano salvo que el índice no exista; `--query` ya hace el ingest incremental.

## Outputs
- Respuesta citada al usuario. No genera archivos.
