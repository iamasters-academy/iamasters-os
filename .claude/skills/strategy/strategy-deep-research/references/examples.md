# Ejemplos de uso

## Ejemplo 1 — Modo médico (oncología)

**Usuario**: "Investiga a fondo la evidencia actual sobre pembrolizumab en cáncer gástrico avanzado HER2-negativo."

**Flujo**:
1. Paso 0 → tema biomédico → modo médico.
2. Plan: subpreguntas (a) eficacia en 1ª línea, (b) perfil de seguridad, (c) qué dicen las guías ESMO/NCCN 2024–2025.
3. Ronda 1 → 3 subagentes: dos usan `search_articles` (filtro `Randomized Controlled Trial[Publication Type]`, `date_from=2020`), uno busca las guías.
4. Texto completo: `convert_article_ids` → PMCID → `get_full_text_article` para los KEYNOTE relevantes; los de pago (NEJM) → vía proxy con Chrome MCP.
5. Conflicto detectado entre subgrupos PD-L1 → ronda 2 con `find_related_articles` + meta-análisis.
6. `report.md` con resumen, hallazgos por subpregunta, tabla de conflictos (confianza por subgrupo CPS), referencias con PMID+DOI, atribución a PubMed.
7. `report.html` compartible.

**Output esperado**: reporte donde cada afirmación de eficacia lleva su PMID/DOI, las guías citadas con fecha, y los subgrupos donde la evidencia es Baja están marcados.

## Ejemplo 2 — Modo web (regulatorio/negocio)

**Usuario**: "Deep research sobre los requisitos legales para facturación electrónica de un profesional sanitario independiente en Colombia en 2026."

**Flujo**:
1. Paso 0 → no biomédico → modo web, foco en fuentes oficiales (DIAN, normativa).
2. Plan: (a) normativa vigente DIAN, (b) plazos/obligados 2026, (c) requisitos técnicos del proveedor tecnológico.
3. Subagentes priorizan `.gov.co`, resoluciones DIAN, no blogs de asesorías.
4. Gap: una pista venía de un blog → ronda 2 rastrea la resolución DIAN exacta que cita.
5. Reporte con cada requisito ligado a su resolución oficial + fecha, y nota de vigencia.

**Clave**: si solo hubiera blogs de gestorías, el reporte lo dice: "no localizado en fuente oficial DIAN; confirmar con la resolución".

## Ejemplo 3 — Derivar a la skill ligera

**Usuario**: "¿En qué año se aprobó el primer CAR-T?"

→ Es un dato único. **No** se usa deep-research; se sugiere `strategy-web-research` o respuesta directa con una cita. Deep-research es para profundidad, no para datos sueltos.
