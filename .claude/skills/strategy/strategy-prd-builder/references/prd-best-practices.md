# Buenas prácticas de PRD (destiladas)

> Síntesis de fuentes reales consultadas el 2026-05-30: Atlassian (Agile/Requirements), Maze, Lenny's Newsletter, Figma resource library. Aplica esto al escribir cualquier PRD con `strategy-prd-builder`.

## Principios rectores

1. **Problema antes que solución.** Empieza por el dolor del usuario y el "porqué", no por la lista de features. Un PRD que abre con features está mal planteado.
2. **El "qué" y el "porqué", nunca el "cómo".** Los requisitos describen comportamiento esperado, no implementación. El "cómo" (stack, prompts, pasos) va en el playbook (parte 2 del PRD híbrido).
3. **Documento vivo y conciso.** Atlassian: "mejor escribir requisitos de forma ligera y ajustarlos constantemente que pasar semanas en un documento que queda obsoleto." Enlaza a material de apoyo en vez de meterlo todo dentro.
4. **Colaborativo, no aislado.** Un PRD escrito en una cueva sin validar con stakeholders/usuarios es un error recurrente.
5. **Métricas medibles o no sirven.** Toda meta lleva un número y un plazo.
6. **Alcance explícito.** La sección "Lo que NO hacemos" evita el scope creep y aclara expectativas. Es la sección que más se omite y más valor da.

## Secciones canónicas (intersección de las fuentes)

| Sección | Qué responde | Obligatoria |
|---|---|---|
| Objetivo / visión | ¿Por qué existe esto? ¿Qué problema resuelve? | Sí |
| Métricas de éxito | ¿Cómo sabremos que funcionó? (número + plazo) | Sí |
| Usuarios / personas / ICP | ¿Para quién? | Sí |
| Supuestos | ¿Qué damos por cierto? (técnico y de negocio) | Recomendada |
| User stories / escenarios | ¿Cómo lo usan? | Sí |
| Requisitos funcionales | ¿Qué debe hacer el sistema? | Sí |
| Requisitos no funcionales | ¿Cómo debe rendir? (perf, seguridad, privacidad, escalabilidad) | Según categoría |
| Diseño / wireframes / flujo | ¿Cómo se ve y se navega? | Si aplica |
| Alcance — "Lo que NO hacemos" | Límites explícitos | Sí |
| Riesgos y dependencias | ¿Qué puede salir mal? ¿De qué depende? | Recomendada |
| Timeline / hitos | ¿Cuándo? | Recomendada |
| Preguntas abiertas | ¿Qué falta decidir? | Recomendada |

## Formatos estándar

- **User story**: `Como [tipo de usuario], quiero [acción] para [beneficio/valor].`
- **Métrica de éxito** (estilo Atlassian): `[Categoría]: [número]% de [usuarios] [hace acción] dentro de [plazo].`
  Ejemplo: "Adopción: 80% de los dictados se insertan sin que el usuario los edite, en la primera semana."
- **Requisito funcional**: verbo de comportamiento observable. "El sistema transcribe el audio al soltar la tecla." NO "usar faster-whisper" (eso es el cómo → playbook).
- **Requisito no funcional**: atributo de calidad medible. "La transcripción de 30s termina en < 5s en CPU."

## Errores comunes a evitar

- Ser demasiado vago **o** demasiado detallado (sobre-especificar implementación).
- Saltarse la investigación de usuario.
- No definir métricas de éxito claras.
- Tratarlo como documento estático que nadie vuelve a tocar.
- Trabajar en aislamiento sin input de stakeholders.
- Enfocarse en soluciones antes de entender el problema.
- Rellenar secciones que no aplican con paja. Si no aplica, omítela o márcala "Pendiente".

## Adaptación por categoría

- **App de software**: fuerte en requisitos funcionales + estructura de archivos + playbook de prompts de build.
- **SaaS**: añade modelo de datos, auth/roles, planes/pricing, métricas de retención y activación.
- **No-code / automatización**: requisitos funcionales como pasos de flujo; el playbook son pasos de configuración (Forms, Excel, n8n), no código.
- **Marca / contenido**: "requisitos" = especificación del entregable (formato, duración, canal, voz); el playbook es el pipeline de producción y distribución.

## Fuentes

- Atlassian — How to Write a PRD / What is a PRD: https://www.atlassian.com/agile/product-management/requirements
- Maze — Product Requirements Document: How-to & Examples: https://maze.co/blog/product-requirements-document/
- Lenny's Newsletter — My favorite templates: PRDs, strategy, processes: https://www.lennysnewsletter.com/p/my-favorite-templates-prds-strategy
- Figma — 15 Best PRD Templates 2025: https://www.figma.com/resource-library/product-requirements-document-templates/
