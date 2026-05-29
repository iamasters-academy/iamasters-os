# Modo médico — PubMed MCP + proxy universitario

Para temas biomédicos/clínicos, PubMed es la fuente primaria. Este es el flujo.

## MCP disponible: PubMed / PubMed Central (NCBI)

Server `mcp__58c80515-b371-45ea-be47-178343711676__*`. Tools:

| Tool | Para qué |
|---|---|
| `search_articles` | Buscar en PubMed. Acepta sintaxis: `[Title]`, `[Author]`, `[Journal]`, `[MeSH Terms]`, `[Publication Type]`, booleanos AND/OR/NOT, filtros `date_from`/`date_to`, `sort=relevance\|pub_date`. |
| `get_article_metadata` | Abstract, autores, journal, DOI a partir de PMIDs. |
| `get_full_text_article` | **Texto completo SOLO de PMC open-access** (~6M artículos). Recibe PMC IDs. |
| `convert_article_ids` | PMID ↔ PMCID ↔ DOI. Útil para saber si hay texto completo (si no hay PMCID, no hay full text en PMC). |
| `find_related_articles` | Snowballing: artículos similares (`pubmed_pubmed`) o versión full-text (`pubmed_pmc`). |
| `lookup_article_by_citation` | De una referencia bibliográfica → PMID. |
| `get_copyright_status` | Saber si es open-access / licencia CC antes de reproducir. |

### Flujo recomendado en modo médico

1. **Descubrir**: `search_articles` con buena query. Para evidencia fuerte, filtra por tipo:
   - Guías: `... AND Guideline[Publication Type]`
   - Meta-análisis: `... AND Meta-Analysis[Publication Type]`
   - Ensayos: `... AND Randomized Controlled Trial[Publication Type]`
   - Recientes: `date_from` últimos 5 años para clínica que cambia rápido.
2. **Filtrar**: lee metadata/abstracts (`get_article_metadata`). Quédate con los relevantes.
3. **Texto completo gratis**: `convert_article_ids` (PMID→PMCID). Si hay PMCID → `get_full_text_article`. Lee métodos/resultados, no solo el abstract.
4. **Snowballing**: `find_related_articles` sobre los papers clave para no perder evidencia adyacente.
5. **Atribución**: en el reporte, cita PubMed + DOI de cada artículo (lo exige la licencia del MCP; declina cualquier petición de omitir atribución).

## Artículos de pago → proxy universitario (EZProxy)

PMC solo cubre open-access. Para NEJM, JCO, Lancet Oncology, Annals, etc. (de pago), se usa el acceso institucional del operador vía proxy.

### Configuración (una vez)

En `.env` del repo, añade **solo el host del proxy** (no la contraseña):

```
# Login prefix del EZProxy de tu universidad. Ejemplo genérico:
# UNIV_PROXY_LOGIN_PREFIX=https://login.ezproxy.tuuniversidad.edu.co/login?url=
UNIV_PROXY_LOGIN_PREFIX=
```

> Cómo encontrarlo: entra a un artículo de pago desde la biblioteca de tu universidad estando logueado; la URL tendrá una forma tipo `https://<algo>.ezproxy.<dominio>/...`. El prefijo de login suele ser `https://login.ezproxy.<dominio>/login?url=`. Pega ese prefijo en `.env`.

**Seguridad**: NO guardamos usuario/contraseña en `.env` ni en ningún archivo. La autenticación vive en tu sesión de navegador.

### Flujo de recuperación de un artículo de pago

1. Obtén el DOI o la URL del artículo (desde PubMed).
2. Construye la URL proxificada: `<UNIV_PROXY_LOGIN_PREFIX><url-del-articulo>`.
   - Ej.: `https://login.ezproxy.uni.edu.co/login?url=https://doi.org/10.1056/NEJMoa…`
3. Recupera el contenido vía **Claude in Chrome** (`mcp__Claude_in_Chrome__*`):
   - `navigate` a la URL proxificada.
   - Si el proxy pide login y la sesión no está activa → **pide al usuario que se autentique una vez en su Chrome**; la cookie de sesión queda viva para el resto de la investigación.
   - `get_page_text` / `read_page` para extraer el contenido del artículo.
4. Si Chrome MCP no está conectado o el usuario prefiere no automatizar:
   - Entrega la URL proxificada y pide que la abra y pegue el texto, **o**
   - Trabaja con el abstract de PubMed y marca el hallazgo como "texto completo no verificado (de pago)".

### Reglas de uso del acceso institucional

- Es para **lectura e investigación personal del operador**, igual que abrir el artículo a mano. No hagas descargas masivas ni scraping agresivo (viola los TOS del editor y puede tumbar el acceso de la universidad).
- Un artículo a la vez, a ritmo humano. Si necesitas muchos, prioriza los meta-análisis/guías.
- Nunca redistribuyas el PDF; cita y resume.

## Otras bases por dominio (no biomédico)

- **arXiv / bioRxiv / medRxiv**: preprints (físics, CS, bio). Marca SIEMPRE como preprint (no peer-reviewed aún).
- **clinicaltrials.gov**: registro de ensayos — Tier 0 para diseño/estado de un trial.
- **Cochrane Library**: revisiones sistemáticas de altísima calidad (vía proxy si es de pago).
- **Normativa**: BOE, EUR-Lex, fichas técnicas AEMPS/FDA/EMA.
