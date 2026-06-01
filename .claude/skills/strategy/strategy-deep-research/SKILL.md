---
name: strategy-deep-research
description: Investigación profunda multironda con disciplina de fuentes primarias y citas verificables. Se comporta como un agente de deep research: planifica, delega subagentes en paralelo, prioriza fuentes oficiales/primarias sobre blogs, itera hasta saturar el tema, y entrega un reporte Markdown + HTML con cada afirmación citada (URL + fecha + tier de confianza). Para temas biomédicos usa el MCP de PubMed como fuente primaria y el proxy universitario para artículos de pago. Úsala cuando el usuario diga "investiga a fondo", "deep research", "investigación profunda", "qué dice la evidencia sobre", "revisión de literatura", o pida un informe documentado con referencias.
---

# strategy-deep-research

Agente de investigación profunda. No es una búsqueda rápida: es un proceso iterativo que prioriza fuentes primarias/oficiales, descarta blogs sin actualización como evidencia, y **nunca afirma nada sin citar de dónde salió**.

## Cuándo se invoca

- Usuario: "investiga a fondo X", "deep research sobre Y", "investigación profunda", "revisión de literatura", "qué dice la evidencia sobre Z", "hazme un informe documentado de…"
- Cuando una decisión (clínica, de negocio, técnica) necesita respaldo con fuentes verificables, no opinión.
- **NO** para lookups rápidos de un dato único → eso es `strategy-web-research`. Esta skill es la versión pesada: úsala cuando la profundidad y la trazabilidad importan más que la velocidad.

## Principios no negociables

1. **Prioridad de fuente primaria.** Toda afirmación se respalda con la fuente más cercana al origen posible. Clasifica cada fuente por tier (ver `references/source-tiers.md`). Solo **Tier 0–1** cuentan como evidencia citable. Tier 2–3 (blogs, agregadores, foros) sirven como *pistas* para encontrar la fuente primaria, nunca como autoridad.
2. **Recencia explícita.** Cada fuente lleva fecha de publicación y de último update conocido. Marca como ⚠️ cualquier fuente cuya antigüedad importe para el tema (guías clínicas >5 años, datos de mercado >18 meses, docs técnicas de una versión obsoleta).
3. **Cero afirmación sin cita.** Cada frase con contenido factual lleva `[n]` inline. Si no hay fuente, se dice explícitamente "sin fuente verificable" y se trata como hipótesis, no como hecho.
4. **Conflictos a la vista.** Si dos fuentes Tier 0–1 se contradicen, se reportan ambas con su cita y se da un nivel de confianza. No se esconde la discrepancia eligiendo una.
5. **Trazabilidad.** El reporte permite a cualquiera reconstruir la búsqueda: query usada, fecha de acceso, tier, URL/DOI.

## Process

### Paso 0 · Clasificar el dominio y elegir el carril

Antes de buscar, decide:

- **¿Tema biomédico/clínico/ciencias de la vida?** (oncología, fármacos, fisiología, epidemiología, genética…) → **modo médico**: PubMed MCP es la fuente primaria. Lee `references/medical-sources.md`.
- **¿Tema general / negocio / técnico / regulatorio?** → **modo web**: WebSearch + WebFetch + Firecrawl, con foco en fuentes oficiales (`.gov`, `.edu`, organismos, papers, docs oficiales del fabricante, normativa).
- **¿Mixto?** Corre ambos carriles en paralelo.

Detecta también el **idioma de salida** (español por defecto) y la **profundidad pedida** (rápida 1 ronda / estándar 2 / exhaustiva 3+).

### Paso 1 · Plan de investigación (escrito)

1. Crea la carpeta de trabajo:
   ```
   projects/strategy-deep-research/<YYYY-MM-DD>-<tema-corto>/
   ```
2. Escribe `research-plan.md` con:
   - **Pregunta principal** (reformulada con precisión, sin acrónimos ambiguos)
   - **2–5 subpreguntas** ortogonales (sin solapamiento)
   - **Fuentes esperadas por subpregunta** (qué tier y qué tipo: paper, guía clínica, normativa, doc oficial)
   - **Criterio de parada** (cuándo consideramos el tema saturado)

**Guía de alcance:**
- Fact-finding documentado: 1–2 subpreguntas
- Comparativa: 1 subpregunta por elemento (máx 3)
- Revisión profunda: 3–5 subpreguntas

### Paso 2 · Ronda 1 — búsqueda amplia con subagentes en paralelo

Por cada subpregunta, lanza un subagente (`Agent`, subagent_type `general-purpose`) **en paralelo (máx 3 a la vez)**. Cada subagente:

- Recibe la subpregunta concreta + el **tier mínimo aceptable** + instrucción de priorizar fuentes oficiales.
- Tiene presupuesto: 4–6 búsquedas.
- En **modo médico**, usa las tools `mcp__58c80515-…__search_articles` / `get_article_metadata` / `get_full_text_article` en vez de (o además de) WebSearch.
- **Escribe sus hallazgos a archivo**, no los devuelve en prosa: `findings-<subpregunta>.md` con, por cada hallazgo: afirmación, cita literal corta, URL/DOI, fecha pub, tier estimado.

Plantilla de instrucción al subagente → `references/subagent-brief.md`.

### Paso 3 · Análisis de vacíos (gap analysis)

Lee todos los `findings-*.md`. Construye un mapa:

- Qué subpreguntas quedaron bien cubiertas con Tier 0–1.
- Qué quedó solo con Tier 2–3 (necesita rastrear la fuente primaria).
- Qué afirmaciones se contradicen entre fuentes.
- Qué quedó sin responder.

Si todo está cubierto con Tier 0–1 y sin conflictos abiertos → salta a Paso 5. Si no → Paso 4.

### Paso 4 · Rondas de profundización (el "deep")

Lanza búsquedas **dirigidas** (no amplias) solo sobre los huecos:

- Rastrear la fuente primaria detrás de una pista Tier 2–3 (p. ej. el blog cita un estudio → ir al estudio).
- Resolver conflictos buscando una fuente Tier 0 que arbitre (meta-análisis, guía oficial, normativa vigente).
- **Modo médico**: usa `find_related_articles` para snowballing y `get_full_text_article` para leer métodos/resultados; para artículos de pago, activa la **vía proxy universitario** (`references/medical-sources.md`).

Repite Paso 3 ↔ 4 hasta cumplir el criterio de parada o tope de rondas. **No sobre-investigues**: si dos rondas no mueven la aguja, para y reporta el vacío.

### Paso 5 · Síntesis citada

Escribe `report.md` siguiendo la plantilla de `references/citation-format.md`:

1. **Resumen ejecutivo** (5–8 bullets, cada uno con su `[n]`)
2. **Hallazgos por subpregunta**, prosa con citas inline `[n]`
3. **Conflictos y nivel de confianza** (tabla: afirmación · fuentes a favor · en contra · confianza Alta/Media/Baja)
4. **Vacíos / lo que no se pudo verificar**
5. **Abreviaturas / glosario (obligatorio en modo médico/científico)** — coloca un bloque "Abreviaturas" justo después de los metadatos del reporte, antes del resumen ejecutivo, con cada sigla y su término completo. Además, **expande toda sigla en su primera aparición en el texto**: término completo seguido de la sigla entre paréntesis (p. ej. "ensayo clínico aleatorizado (ECA)", "supervivencia global (OS)"), y a partir de ahí usa la sigla. Esto vale tanto para `report.md` como para `report.html`. Objetivo: que el operador y cualquiera con quien comparta el documento entiendan cada término sin conocimiento previo.
6. **Referencias** — el estilo depende del carril (ver `references/citation-format.md`):
   - **Modo médico/científico → estilo Vancouver**: lista numerada por orden de aparición (`Autores. Título. Abrev journal. Año;Vol(Núm):págs. doi. PMID.`), hasta 6 autores + `et al.`
   - **Modo web/general → tabla web**: título · sitio/organismo · tier · URL · fecha publicación · fecha de acceso (para abrir y verificar cada página).
   - **Modo mixto**: Vancouver para las científicas + tabla web para el resto, en dos bloques.
7. En modo médico, **atribución obligatoria a PubMed + DOIs** (lo exige la licencia del MCP).

### Paso 6 · Gate de calidad

Invoca `tool-output-verifier` sobre `report.md`. Debe pasar:
- ¿Toda afirmación factual tiene `[n]`?
- ¿Toda `[n]` resuelve a una entrada de la lista/tabla de referencias?
- ¿Hay alguna fuente Tier 2–3 citada como evidencia? (debe ser 0)
- **¿El estilo de referencia coincide con el carril?** Médico/científico → Vancouver bien formado (autores, journal abreviado, año, vol, DOI/PMID); web/general → cada entrada tiene URL abrible + fecha de acceso.
- ¿Cada referencia tiene fecha y URL/DOI?
- **(Modo médico) ¿Hay bloque de abreviaturas y toda sigla se expande en su primera aparición?** Si aparece una sigla sin definir (CPS, OS, PFS, HR, ECA, EA, MSI, ITT, etc.), corrige antes de entregar.

Si falla, vuelve al paso correspondiente. No entregues un reporte que no pase el gate.

### Paso 7 · HTML visual compartible

Invoca `tool-visual-explainer` para generar `report.html` autocontenido a partir de `report.md`, usando su **plantilla fija de marca** (hero con degradado + secciones numeradas). Mapea siempre las secciones en este orden y con estos componentes para que todos los reportes tengan la misma forma:

1. **Abreviaturas** → componente `chips` (sigla en pastilla + término).
2. **Resumen ejecutivo** → `kpi` (cifras clave) + `list` (bullets citados).
3. **Hallazgos / gradiente** → `table` (en `tablewrap`).
4. **Conflictos y confianza** → `table` + `badge` (`b-hi`/`b-med`/`b-lo` = Alta/Media/Baja) + `callout` para la lectura clínica.
5. **Vacíos / no verificado** → bloque `gap`.
6. **Referencias** → `refs` (lista numerada con DOI/PMID enlazados).

Footer fijo: "Generado por Dr. Juan Camilo Paris". Es el entregable que se comparte.

### Paso 8 · Cierre y aprendizaje

- Append en `context/learnings.md` bajo `## strategy-deep-research`: fecha + qué fuentes/queries funcionaron mejor para este tipo de tema, qué proxy/journal dio problemas.
- Si el tema reaparece, propón guardarlo como nota en el segundo cerebro (ver memoria del operador).
- Propón commit del reporte si vive dentro del repo.

## Outputs

```
projects/strategy-deep-research/<YYYY-MM-DD>-<tema>/
├── research-plan.md
├── findings-<subpregunta>.md   (uno por subagente)
├── report.md                   # entregable principal, citado
└── report.html                 # versión visual compartible
```

## Skills / tools que llama

- **Subagentes `Agent` (general-purpose)** — búsqueda paralela por subpregunta.
- **MCP PubMed** (`mcp__58c80515-b371-45ea-be47-178343711676__*`) — fuente primaria en modo médico.
- **Claude in Chrome** (`mcp__Claude_in_Chrome__*`) — recuperar texto completo de artículos de pago vía proxy universitario (sesión autenticada por el usuario).
- **`tool-firecrawl-scraper`** — extraer contenido limpio de webs oficiales con bot-blockers.
- **WebSearch / WebFetch** — búsqueda y fetch general (modo web).
- **`tool-output-verifier`** — gate de citas antes de entregar.
- **`tool-visual-explainer`** — HTML compartible.
- **`strategy-web-research`** — NO la llama; es su hermana ligera. Si el usuario solo quiere un dato rápido, deriva a esa.

## Edge cases

- **Sin acceso a internet / tools de web fallan**: reporta qué se pudo y qué no; no inventes fuentes.
- **Artículo de pago sin proxy configurado**: usa abstract de PubMed + marca el hallazgo como "texto completo no verificado", y ofrece la URL proxificada para que el usuario lo abra.
- **Tema fuera de PubMed** (física, CS, derecho): PubMed no aplica; usa modo web con fuentes oficiales del dominio (arXiv, BOE/normativa, docs oficiales).
- **Solo hay blogs sobre el tema**: dilo explícitamente — "no encontré fuentes primarias; lo disponible es Tier 2–3" — y no eleves un blog a evidencia.
- **El usuario pide velocidad**: ofrece bajar a 1 ronda, pero mantén la disciplina de citas.

## Examples

Ver `references/examples.md`.
