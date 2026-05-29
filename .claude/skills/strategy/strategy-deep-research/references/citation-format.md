# Disciplina de citas y plantilla de reporte

## Reglas de citado

1. **Inline numérico**: cada afirmación factual termina con `[n]`. Varias fuentes para una afirmación: `[1][3]`. (Vancouver también usa numeración por orden de aparición → encaja directo.)
2. **Una `[n]` = una entrada** en la lista de referencias. Sin huérfanas en ninguna dirección.
3. **Cita literal corta** cuando la redacción exacta importa (cifras, definiciones legales, dosis): usa comillas + `[n]`.
4. **Fecha de acceso obligatoria** para fuentes web (cambian). Para papers, basta DOI/PMID + fecha de publicación.
5. **Nunca parafrasear cambiando el sentido**. Si la fuente dice "puede reducir", no escribas "reduce".

## Abreviaturas (obligatorio en modo médico/científico)

En redacción científica, toda sigla se presenta **primero con su término completo** y la sigla entre paréntesis; después se usa la sigla. Además se incluye un **bloque "Abreviaturas"** al inicio del reporte (tras los metadatos, antes del resumen ejecutivo) para que cualquier lector lo entienda sin contexto previo.

Reglas:
1. Primera aparición en el texto: `término completo (SIGLA)` — p. ej. "supervivencia global (OS)", "ensayo clínico aleatorizado (ECA)".
2. Bloque "Abreviaturas" en formato lista o tabla `SIGLA — término completo`.
3. En el HTML, el mismo bloque va visible cerca del encabezado (no escondido).

Lista base frecuente en oncología (adáptala al tema; expande solo las que uses):

| Sigla | Término completo |
|---|---|
| OS | supervivencia global (overall survival) |
| PFS | supervivencia libre de progresión (progression-free survival) |
| HR | hazard ratio (razón de riesgos instantáneos) |
| IC95% | intervalo de confianza del 95% |
| ECA | ensayo clínico aleatorizado |
| EA | eventos adversos |
| ORR | tasa de respuesta objetiva (objective response rate) |
| CPS | puntuación positiva combinada de PD-L1 (combined positive score) |
| PD-1 | proteína de muerte celular programada 1 |
| PD-L1 | ligando 1 de muerte celular programada |
| MSI | inestabilidad de microsatélites (microsatellite instability); MSI-alto = MSI-high |
| ITT | intención de tratar (intention-to-treat) |
| HER2 | receptor 2 del factor de crecimiento epidérmico humano |
| UGE | unión gastroesofágica |

> Nota: HR (hazard ratio) NO es lo mismo que OR (odds ratio) ni RR (riesgo relativo). Usa el que reporte la fuente; no los intercambies.

## El estilo de referencia depende del carril

- **Modo médico / científico → estilo Vancouver** (es el estándar biomédico). Lista numerada por orden de aparición, no tabla.
- **Modo web / general → referencia web simple**: título · sitio/organismo · URL · fecha de acceso (+ tier). Tabla, para que sea fácil abrir y verificar cada página.
- **Modo mixto**: usa Vancouver para las fuentes científicas y la tabla web para el resto, en dos bloques separados dentro de la misma sección "Referencias".

### Formato Vancouver (modo médico/científico)

Numeración por orden de aparición en el texto. Estructura de cada entrada:

```
n. Autores. Título del artículo. Abreviatura del journal. Año;Volumen(Número):páginas. doi:DOI. PMID: nnnn.
```

Reglas Vancouver clave:
- **Autores**: apellido + iniciales sin puntos (`García-López MA`). Lista hasta **6 autores**; si hay 7+, los primeros 6 + `et al.`
- **Journal**: abreviatura oficial NLM (p. ej. `N Engl J Med`, `Lancet Oncol`, `J Clin Oncol`). Si dudas de la abreviatura, usa el nombre completo antes que inventarla.
- **Sin coma entre apellido e iniciales**; autores separados por coma; punto final tras la lista.
- **DOI y PMID** al final cuando existan (vienen del MCP de PubMed).

Ejemplos:

```
1. Janjigian YY, Shitara K, Moehler M, et al. First-line nivolumab plus chemotherapy versus chemotherapy alone for advanced gastric cancer (CheckMate 649). Lancet. 2021;398(10294):27-40. doi:10.1016/S0140-6736(21)00797-2. PMID: 34102137.
2. World Health Organization. WHO classification of tumours: digestive system tumours. 5th ed. Lyon: IARC; 2019.
```

Para libros, guías de sociedad e informes oficiales, usa la variante Vancouver correspondiente (autor/organismo. Título. Edición. Lugar: Editorial; Año.).

### Formato referencia web (modo general)

Tabla, una fila por fuente, pensada para abrir y verificar:

```
| # | Título | Sitio / Organismo | Tier | URL | Publicado | Accedido |
```

## Plantilla de `report.md`

```markdown
# Investigación: <pregunta principal>

> Fecha: <YYYY-MM-DD> · Profundidad: <rápida|estándar|exhaustiva> · Rondas: <n>
> Carril: <médico|web|mixto>

## Resumen ejecutivo
- Hallazgo clave 1 [1]
- Hallazgo clave 2 [2][5]
- ...

## Hallazgos

### <Subpregunta 1>
Prosa con citas inline [1]. Cuando hay cifras exactas, "cita literal" [2].

### <Subpregunta 2>
...

## Conflictos y nivel de confianza

| Afirmación | A favor | En contra | Confianza |
|---|---|---|---|
| <afirmación> | [1][4] | [7] | Media |

## Vacíos / no verificado
- <qué quedó sin fuente primaria y por qué>

## Referencias

<!-- MODO MÉDICO/CIENTÍFICO → lista numerada estilo Vancouver: -->
1. Janjigian YY, Shitara K, Moehler M, et al. First-line nivolumab plus chemotherapy versus chemotherapy alone for advanced gastric cancer. Lancet. 2021;398(10294):27-40. doi:10.1016/S0140-6736(21)00797-2. PMID: 34102137.
2. …

> Datos biomédicos vía **PubMed / PubMed Central** (NCBI). DOIs incluidos en cada referencia.

<!-- MODO WEB/GENERAL → tabla web (sustituye la lista de arriba): -->
| # | Título | Sitio / Organismo | Tier | URL | Publicado | Accedido |
|---|---|---|---|---|---|---|
| 1 | … | DIAN | 0 | https://… | 2026-01 | 2026-05-29 |

<!-- MODO MIXTO → ambos bloques, científicas en Vancouver y resto en tabla web. -->
```

## Nivel de confianza — cómo asignarlo

- **Alta**: ≥2 fuentes Tier 0–1 concordantes, recientes, sin conflicto de interés.
- **Media**: 1 fuente Tier 0–1, o varias Tier 1 sin Tier 0, o ligera discrepancia.
- **Baja**: solo Tier 2 rastreado a algo no confirmado, fuente única antigua, o conflicto abierto entre Tier 0.

Una afirmación de confianza Baja **debe** decirlo en el cuerpo, no solo en la tabla.
