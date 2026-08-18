---
name: marketing-icp
description: Define el Ideal Customer Profile en detalle: dolor exacto, lenguaje que usa, buying triggers, anti-ICP. Combina interview con análisis de competidores (qué clientes tienen) y de testimonios reales del operador. Output a brand-context/icp/icp.md. Se invoca después de positioning o cuando el operador no sabe a quién venderle.
---

# marketing-icp

## Cuándo se invoca

- Después de `marketing-positioning` (positioning sin ICP claro = humo)
- Operador dice: "no sé a quién vender", "mi cliente actual no es ideal"
- Antes de cualquier campaña paid (sin ICP no segmentas)
- Cuando vas a escribir copy de landing/email y necesitas precisión

## Process

### Paso 1 · Recopilar inputs

Lee `brand-context/positioning/positioning.md` (si existe).

Pregunta al operador (6 preguntas):

1. **¿Tienes 3-5 clientes actuales o pasados que sean "buenos"?** (clientes que pagaron sin pelear, recomendaron, repitieron). Dame nombre, sector, tamaño y por qué los consideras buenos.

2. **¿Tienes 1-3 clientes que sean "malos"?** (que se quejaron mucho, no pagaron, churnearon en 30 días, te succionaron tiempo). Dame nombre, sector y por qué fallaron.

3. **¿Cómo te encontraron los buenos?** (Instagram, recomendación, búsqueda, evento, frío...)

4. **¿Qué dolor concreto tenían cuando te contactaron?** (no "querían más eficiencia" sino "estaban perdiendo 20h/semana en X")

5. **¿Qué objeción tuvieron antes de comprar?** (precio, riesgo, "ya probé antes", confianza, timing)

6. **¿Qué quieren tus mejores clientes que NO les das?** (límites de tu servicio actual)

### Paso 2 · Análisis de patrones

Cruzar las respuestas:

**Patrones positivos** (qué tienen en común los buenos clientes):
- Sector / industria
- Tamaño (revenue, headcount)
- Madurez digital
- Quien decide (rol del comprador)
- Cómo te encontraron (canal de adquisición que repiten)
- Dolor compartido (no genérico)
- Lenguaje que usan al describir el problema

**Patrones negativos** (qué tienen los malos):
- ¿Buscan algo distinto a lo que ofreces?
- ¿No tienen el dolor de verdad (lo "deberían tener" según vendor)?
- ¿Esperan magia / sin trabajar?
- ¿No tienen budget real?
- ¿Toman decisiones por comité / muy lento?

### Paso 3 · Construir ICP detallado

```markdown
# ICP — [Marca]

> Generado: YYYY-MM-DD

## Demográfico / Firmográfico

- **Sector**: [específico, ej. "gestorías y asesorías fiscales con 3-15 empleados"]
- **Tamaño**: [revenue range, ej. "150K-1.5M EUR/año"]
- **Headcount**: [rango, ej. "2-15 personas"]
- **Geografía**: [España + LATAM, o más específico]
- **Madurez digital**: [bajo / medio / alto. Más útil si es específico: "ya usan algún SaaS, no son anti-tech, pero no tienen IT in-house"]

## Quien decide

- **Rol del comprador**: [Founder / CEO / Office Manager / IT / ...]
- **Quien vetea**: [si hay aprobación de socio o partner]
- **Tiempo medio de decisión**: [2 semanas / 2 meses / 6 meses]

## Dolor concreto (en SU lenguaje, no en el tuyo)

> "Cita textual de cómo lo describen ellos cuando te llaman"

Síntomas observables (no abstractos):
- "Pierden X horas/semana en Y"
- "Tienen N personas haciendo tareas que un agente podría hacer"
- "Los clientes esperan respuestas de 2 días, ahora tardan 5"

Coste real del dolor (€):
- Pérdida directa: [tiempo facturable perdido]
- Coste de oportunidad: [proyectos no atendidos]
- Coste reputacional: [clientes que churnean por mal servicio]

## Buying triggers

¿Qué evento les hace pasar de "deberíamos hacer algo" a "necesito hablar con alguien YA"?

- Pierden cliente importante por falta de capacidad
- Empleado clave pide aumento o se va
- Cliente top les dice "o automatizáis o me voy"
- Lanzan producto/servicio nuevo y el equipo no escala
- Auditoría / regulación nueva (RGPD, IA Act, etc.)

## Lenguaje que usan

Palabras EN su mundo (úsalas en tu copy):
- ...

Palabras prohibidas (no las usan, no las entienden, las desconfían):
- "agéntico", "agente conversacional", "LLM", "RAG"
- "stack", "deploy", "API", "webhook" (a menos que sean técnicos)

## Objeciones típicas + respuesta

| Objeción | Respuesta breve |
|---|---|
| "Es muy caro" | Coste vs ROI: el dolor cuesta X€/mes, esto se amortiza en N meses |
| "Ya lo intentamos con [otro]" | Pregunta qué falló. Probablemente falló sin tu enfoque. |
| "No tenemos tiempo para implementarlo" | Por eso tu servicio incluye implementación, no es "te dejo la herramienta" |
| "¿Y si la IA falla?" | Mostrar control humano, validación antes de acciones, opción de off |
| "No sé si servirá para nuestro caso" | Pre-análisis gratuito de 30 min para confirmar fit |

## Canales donde están

¿Dónde consume contenido / busca soluciones?

- LinkedIn: ¿activo? ¿qué grupos sigue?
- YouTube: ¿qué canales del sector?
- Newsletter / podcasts del sector
- Eventos: cuáles atiende
- Búsqueda Google: keywords que prueba ("automatizar [su sector]", "ahorrar tiempo [su tarea]")

## Anti-ICP

Cliente que parece bueno pero NO debes aceptar:
- Síntoma 1
- Síntoma 2
- Síntoma 3

Razones por las que decir NO:
- ...

## Customer Journey

1. **Awareness**: ¿cómo se enteran de que existe esto? (LinkedIn de Angel, recomendación, evento)
2. **Consideration**: ¿qué buscan / leen para evaluar? (case studies, demos, conversación)
3. **Decision**: ¿qué cierra el deal? (llamada con caso real similar, prueba gratuita acotada, contrato corto inicial)
4. **Onboarding**: ¿cómo arranca el proyecto?
5. **Expansion**: ¿qué upsells aceptan después?

## Validación

Frases para validar este ICP en próxima llamada:
- "¿Pierdes alrededor de [X horas/semana] en [Y tarea]?"
- "¿Si pudieras tener [Z resuelto] te ahorraría [N€/mes]?"
- "¿Has intentado antes con [tipo de solución]? ¿Qué falló?"

Si la persona responde "no" o "más o menos" a 2+ preguntas → no es ICP, es prospect tibio.

## Cuándo revisar este ICP

- Cada 3 meses con datos nuevos (10+ clientes nuevos)
- Cuando cambies positioning
- Cuando entres a vertical nuevo
- Cuando observes drift (cierras a clientes muy distintos del descrito)
```

### Paso 4 · Validación cruzada

Pregunta al operador:
- "Mira la sección 'Lenguaje que usan'. ¿Reconoces estas palabras de tus llamadas?"
- "Mira 'Buying triggers'. ¿Cuál de estos viste en al menos 2 clientes?"
- "Mira 'Anti-ICP'. ¿Hay algún síntoma que no incluyera y deberías?"

Refinar hasta que el operador diga "sí, así es exactamente".

### Paso 5 · Cierre

- Guardar `brand-context/icp/icp.md`
- Append en `context/learnings.md`
- Sugerir actualizar copy de landing / email sequences / bio con el lenguaje del ICP detectado

## Outputs

- `brand-context/icp/icp.md`
- Append a `context/learnings.md`

## Skills que llama

Ninguna. Es introspectiva + análisis de datos del operador.

(Optional: si el operador menciona muchos clientes, podría llamar `tool-firecrawl-scraper` para enriquecer datos de cada cliente desde sus webs).

## Edge cases

- **Operador no tiene clientes aún (pre-revenue)**: ICP es hipotético. Marcar `confidence: low` y planear validación con 5 entrevistas a prospects en 30 días.
- **Operador tiene 100+ clientes muy variados**: segmentar en 2-3 ICPs distintos en lugar de forzar 1.
- **Cliente "bueno" no responde al perfil del positioning**: investigar por qué. Puede que el positioning esté mal o que el cliente sea outlier.

## Examples

Ver `references/examples.md` para 2 ICPs completos:
1. Operador IA freelance servicio a gestorías españolas
2. Agencia marketing especializada en formadores online
