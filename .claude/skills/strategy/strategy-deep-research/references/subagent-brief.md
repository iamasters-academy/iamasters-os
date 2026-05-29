# Plantilla de instrucción para subagentes de búsqueda

Cada subagente investiga **una** subpregunta y escribe a archivo. Debe ser autocontenido (no conoce el resto de la conversación).

## Plantilla (modo web)

```
Investiga esta pregunta concreta: "<SUBPREGUNTA SIN ACRÓNIMOS>".

Contexto: forma parte de una investigación profunda sobre <TEMA>. Solo necesito ESTA subpregunta.

Reglas de fuentes (CRÍTICO):
- Prioriza fuentes PRIMARIAS y OFICIALES: organismos (.gov, .edu, OMS, agencias),
  papers, normativa, documentación oficial del fabricante. 
- Los blogs, Medium, LinkedIn, foros y Wikipedia NO cuentan como evidencia: úsalos solo
  para encontrar la fuente primaria que citan, y luego ve a esa fuente.
- Anota la fecha de publicación de cada fuente. Marca las que sean viejas para el tema.

Presupuesto: 4–6 búsquedas web. Usa WebSearch para descubrir y WebFetch/Firecrawl para leer.

Cuando termines, usa Write para guardar tus hallazgos en:
  projects/strategy-deep-research/<CARPETA>/findings-<slug-subpregunta>.md

Formato de cada hallazgo en ese archivo:
  - **Afirmación**: <qué encontraste>
  - **Cita literal** (si aplica): "<texto exacto>"
  - **Fuente**: <título> — <autor/organismo>
  - **URL**: <url>
  - **Publicado**: <fecha> · **Tier estimado**: <0|1|2|3>

No sintetices ni des conclusiones globales: solo recopila hallazgos citados. Si solo
encuentras fuentes Tier 2–3, dilo explícitamente.
```

## Plantilla (modo médico)

Igual que arriba, pero sustituye la estrategia de búsqueda:

```
Usa las tools del MCP de PubMed:
- mcp__58c80515-b371-45ea-be47-178343711676__search_articles para buscar
  (filtra por Meta-Analysis[Publication Type] / Guideline[Publication Type] / 
   Randomized Controlled Trial[Publication Type] cuando busques evidencia fuerte;
   usa date_from para limitar a los últimos años si la clínica cambia rápido).
- get_article_metadata para abstracts/DOIs.
- convert_article_ids (PMID→PMCID) y get_full_text_article para texto completo open-access.
Registra PMID y DOI de cada artículo (atribución obligatoria a PubMed).
Para artículos de pago sin PMC, registra el abstract + DOI y márcalo como
"texto completo pendiente vía proxy".
```

## Por qué a archivo y no en prosa

Los subagentes devuelven mucho texto. Escribir a archivo mantiene limpio el contexto del agente principal y permite releer hallazgos en la síntesis sin re-buscar.
