---
name: find-skills
description: Ayuda a descubrir e instalar skills de agente cuando el usuario pregunta "cómo hago X", "busca una skill para X", "hay alguna skill que pueda...", o quiere ampliar capacidades. Usar cuando el usuario busca una funcionalidad que quizá exista como skill instalable. English triggers: find a skill, is there a skill, install skill.
---

# Buscar skills

Esta skill ayuda a descubrir e instalar skills del ecosistema abierto de agentes.

## Cuándo usar esta skill

Úsala cuando el usuario:

- Pregunta "cómo hago X" y X parece una tarea común que podría tener skill.
- Dice "busca una skill para X" o "hay alguna skill para X".
- Pregunta "puedes hacer X" y X requiere una capacidad especializada.
- Quiere ampliar capacidades del agente.
- Quiere buscar herramientas, plantillas o workflows.
- Menciona que le gustaría tener ayuda en un dominio concreto: diseño, testing, deployment, documentación, etc.

## Qué es Skills CLI

Skills CLI (`npx skills`) es el gestor de paquetes del ecosistema abierto de agent skills. Las skills son paquetes modulares que amplían capacidades del agente con conocimiento, procesos y herramientas especializadas.

Comandos clave:

- `npx skills find [query]` - Buscar skills de forma interactiva o por palabra clave.
- `npx skills add <package>` - Instalar una skill desde GitHub u otras fuentes.
- `npx skills check` - Comprobar actualizaciones de skills.
- `npx skills update` - Actualizar todas las skills instaladas.

Catálogo público:

```text
https://skills.sh/
```

## Cómo ayudar al usuario a encontrar skills

### Paso 1: entender qué necesita

Cuando el usuario pida ayuda con algo, identifica:

1. Dominio: React, testing, diseño, deployment, documentación, etc.
2. Tarea concreta: escribir tests, crear animaciones, revisar PRs, preparar changelog.
3. Si es una tarea suficientemente común como para que exista una skill.

### Paso 2: buscar skills

Ejecuta el comando de búsqueda con una query relevante:

```bash
npx skills find [query]
```

Ejemplos:

- "¿Cómo hago mi app React más rápida?" -> `npx skills find react performance`
- "¿Puedes ayudarme con reviews de PR?" -> `npx skills find pr review`
- "Necesito crear un changelog" -> `npx skills find changelog`

El comando devolverá resultados parecidos a:

```text
Install with npx skills add <owner/repo@skill>

vercel-labs/agent-skills@vercel-react-best-practices
└ https://skills.sh/vercel-labs/agent-skills/vercel-react-best-practices
```

### Paso 3: presentar opciones

Cuando encuentres skills relevantes, muestra:

1. Nombre de la skill y qué hace.
2. Comando de instalación.
3. Enlace para leer más en `skills.sh`.

Ejemplo de respuesta:

```text
He encontrado una skill que encaja: "vercel-react-best-practices".
Trae guías de optimización de React y Next.js basadas en patrones de Vercel Engineering.

Para instalarla:
npx skills add vercel-labs/agent-skills@vercel-react-best-practices

Más información:
https://skills.sh/vercel-labs/agent-skills/vercel-react-best-practices
```

### Paso 4: ofrecer instalación

Si el usuario quiere seguir, puedes instalarla:

```bash
npx skills add <owner/repo@skill> -g -y
```

La flag `-g` instala a nivel de usuario y `-y` omite prompts de confirmación.

## Categorías frecuentes

| Categoría | Queries de ejemplo |
|---|---|
| Desarrollo web | react, nextjs, typescript, css, tailwind |
| Testing | testing, jest, playwright, e2e |
| DevOps | deploy, docker, kubernetes, ci-cd |
| Documentación | docs, readme, changelog, api-docs |
| Calidad de código | review, lint, refactor, best-practices |
| Diseño | ui, ux, design-system, accessibility |
| Productividad | workflow, automation, git |

## Consejos para buscar bien

1. Usa palabras específicas: "react testing" mejor que "testing".
2. Prueba términos alternativos: si "deploy" no funciona, usa "deployment" o "ci-cd".
3. Revisa fuentes populares como `vercel-labs/agent-skills` o `ComposioHQ/awesome-claude-skills`.

## Si no encuentras skills

Si no aparece nada relevante:

1. Di claramente que no has encontrado una skill existente.
2. Ofrece resolver la tarea directamente con capacidades generales.
3. Sugiere crear una skill propia si es una tarea recurrente.

Ejemplo:

```text
He buscado skills relacionadas con "xyz" y no he encontrado una opción clara.
Puedo ayudarte igualmente con la tarea directamente.

Si esto es algo que haces a menudo, también podemos convertirlo en una skill propia con:
npx skills init my-xyz-skill
```
