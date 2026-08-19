# Dimensiones · Express (8 críticas)

Esta es la "definición de done" del wizard inicial. Cada dimensión debe quedar capturada con **dato sólido** (no genérica, no "todavía no", no vacía).

---

## Bloque A · Persona

### 1. Identidad básica

**Qué tiene que quedar capturado:**
- Nombre del operador (cómo prefiere que le llamen)
- Frase profesional autodefinida (1 línea, en sus palabras)

**Ejemplo de dato sólido:**
> "Marta Sánchez. Consultora de IA para PYMEs de servicios — automatizo procesos sin que su equipo tenga que aprender a programar."

**Señales de respuesta débil que piden profundizar:**
- "Soy emprendedor" (¿en qué?)
- "Trabajo con IA" (¿haciendo qué con IA?)
- "Ayudo a la gente" (¿a quién y con qué?)

### 2. Ubicación + idioma

**Qué tiene que quedar capturado:**
- Ciudad + país (para timezone y referencias culturales)
- Idioma principal de trabajo (inferido si no se dice)

**Ejemplo de dato sólido:**
> "Madrid, España. Trabajo en castellano principalmente, algunos clientes en inglés."

---

## Bloque B · Negocio

### 3. Negocio principal

**Qué tiene que quedar capturado:**
- Nombre del negocio (si tiene)
- Qué hace concretamente (servicio o producto que vende)
- Vertical / sector si aplica

**Ejemplo de dato sólido:**
> "Sintaxis Lab. Implemento sistemas de OCR + automatización en empresas de logística, transporte y distribución. Proyecto típico: 8 semanas, 14-25K€."

**Señales de respuesta débil:**
- "Consultoría" (¿de qué tipo?)
- "Vendo formación" (¿sobre qué tema?)
- "Es complicado de explicar" (= necesita profundización con ejemplo concreto)

### 4. Modelo de ingresos

**Qué tiene que quedar capturado:**
- Cómo entra el dinero (servicios / productos / suscripciones / mix)
- Si tiene varias fuentes, distribución aproximada (no exacta)

**Ejemplo de dato sólido:**
> "80% proyectos puntuales de implementación. 20% mantenimiento mensual recurrente. Cero formación de momento."

### 5. Cliente ideal

**Qué tiene que quedar capturado:**
- Sector, tamaño, momento en que llegan
- Algún rasgo diferenciador (no genérico)

**Ejemplo de dato sólido:**
> "Director de PYME, 50-200 empleados, sector tradicional (transporte, distribución, manufactura). Llega cuando algún proceso manual le está costando horas extras al equipo o errores caros."

**Señales de respuesta débil:**
- "Cualquier empresa" (no)
- "B2B" (no es un ICP)
- "Gente que quiere automatizar" (¿qué tipo de gente?)

### 6. Stack diario

**Qué tiene que quedar capturado:**
- Las 4-6 herramientas que usa cada día (no la lista exhaustiva)
- Mención especial si usa Claude/IA, n8n, CRM concreto

**Ejemplo de dato sólido:**
> "Google Workspace, Notion, Cal.com, Stripe, n8n, Claude Code, GitHub."

---

## Bloque D · Foco

### 7. Foco del mes (prioridades)

**Qué tiene que quedar capturado:**
- 1-3 prioridades concretas del mes en curso
- Si tiene cuello de botella claro, captúralo también

**Ejemplo de dato sólido:**
> "Mayo 2026: (1) Cerrar proyecto con Logística del Norte. (2) Lanzar página de servicios renovada. (3) Buscar perfil técnico junior para apoyo. Cuello: hago todas las propuestas comerciales yo, no escalo."

**Señales de respuesta débil:**
- "Crecer" (¿en qué métrica?)
- "Más clientes" (¿cuántos? ¿de qué tipo?)
- "Lo de siempre" (= no hay foco real, vale la pena profundizar 1 vez)

### 8. Objetivo 12 meses

**Qué tiene que quedar capturado:**
- Objetivo concreto a 12 meses (revenue, producto, equipo, lo que sea)
- Idealmente con número o hito verificable

**Ejemplo de dato sólido:**
> "12 meses: facturar 180K€ (vs 120K actuales), contratar 1 perfil técnico, soltar el 50% de la operativa comercial."

**Señales de respuesta débil:**
- "Que vaya bien" (no es objetivo)
- "Crecer mucho" (¿cuánto es mucho?)
- "Lo veré cuando llegue" (vale, ahí tienes la primera dimensión a profundizar en deep-dive)

---

## Plantillas de output

Estos son los headers canónicos para los archivos sectorizados. El wizard escribe el contenido derivado de la conversación dentro.

### `context/me.md`

```markdown
# Me · <Nombre>

## Identidad
- **Nombre**: <nombre>
- **Ubicación**: <ciudad, país>
- **Timezone**: <calculado>
- **Idioma principal**: <castellano | inglés | otro>
- **Idioma con clientes**: <si distinto>

## Cómo me describo profesionalmente
> <frase autodefinida del operador>

## Cómo quiero que Claude me hable
(Se profundiza en deep-dive · Bloque A.9 / A.10)

---
*Última actualización: <fecha>*
```

### `context/work.md`

```markdown
# Work · <Negocio>

## Qué hago
> <descripción del negocio principal>

## Cómo gano dinero
<bullets si hay varios streams>

## Cliente ideal (ICP inicial)
> <descripción>
> 
> *Se refinará con `marketing-icp` y `meta-deep-dive` (Bloque B.8)*

## Stack actual
<lista o tabla>

## Negocios / proyectos paralelos
(se profundiza en deep-dive · Bloque B.9)

---
*Última actualización: <fecha>*
```

### `context/current-priorities.md`

```markdown
# Current priorities

> Este archivo cambia mensualmente. Edítalo cuando tu foco cambie.

## Foco del mes (<mes año>)

1. <prioridad 1>
2. <prioridad 2>
3. <prioridad 3>

## Cuello de botella actual

> <respuesta si la dio · si no, "(por capturar en deep-dive)">

## Decisiones abiertas

(se profundiza con `decisions-log` y `meta-deep-dive` D.3)

---
*Última actualización: <fecha>*
```

### `context/goals.md`

```markdown
# Goals

## Objetivo 12 meses

> <objetivo capturado>

## Meta a 3 años

(se profundiza en deep-dive · Bloque D.4)

## Meta personal a 3 años (no profesional)

(se profundiza en deep-dive · Bloque D.5)

## Métrica que miras semanalmente

(se profundiza en deep-dive · Bloque D.7)

## Definición personal de éxito

(se profundiza en deep-dive · Bloque D.8)

---
*Última actualización: <fecha>*
```
