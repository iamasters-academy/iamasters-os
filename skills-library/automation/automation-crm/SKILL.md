---
name: automation-crm
description: Monta y gestiona un CRM (contactos, empresas, oportunidades y pipeline) sobre Supabase o Twenty, y lo orquesta con las skills de ventas. Úsala cuando el operador diga "monta mi CRM", "guarda este contacto/lead", "actualiza el pipeline", "en qué etapa está este deal", "necesito un CRM" o quiera un sistema unificado de clientes/oportunidades para su consultoría o agencia.
---

# automation-crm

> **Skill del OS** — CRM unificado. Puente al OS: es la base de datos de clientes que **desbloquea**
> [[sales-pipeline-forecast]] (pedía CRM) y alimenta [[sales-call-prep]] y [[marketing-prospecting]].
> Dos vías (ver Setup): **Supabase** (ligero, ya tienes MCP) por defecto · **Twenty** (open-source,
> AGPLv3, UI completa) como opción. Modelo de datos en `references/schema.md`.

## Cuándo se invoca
- El operador dice "monta mi CRM", "guarda este contacto/lead", "actualiza el pipeline", "en qué etapa está este deal", "necesito un CRM".
- Otra skill de ventas necesita leer/escribir contactos u oportunidades.

## Setup (elige una vía)
- **Vía A · Supabase (recomendada, ligera)**: usa el MCP de Supabase ya conectado. Crea el esquema `contacts / companies / deals / activities` (ver `references/schema.md`) con RLS. Sin infra nueva.
- **Vía B · Twenty (UI completa, como Claura)**: self-host de `twentyhq/twenty` (Docker, React+Node+PostgreSQL). **AGPLv3** → se **usa/conecta** (API GraphQL), no se vendoriza su código. Más potente, más pesado.
- **Validación**: el backend elegido responde y el esquema/entidades existen (contacts, companies, deals).

## Process

### Paso 1 · Determinar la operación
- Clasifica: alta/edición de contacto o empresa, mover deal de etapa, registrar actividad, o consulta (¿qué deals en etapa X?, ¿contactos de la empresa Y?).
- **Validación**: operación + entidad + campos claros.

### Paso 2 · Ejecutar sobre el CRM
- **Supabase**: `execute_sql`/insert/update vía MCP contra el esquema. **Twenty**: mutación/consulta GraphQL a su API.
- Normaliza (dedup por email/dominio; no dupliques contactos).
- **Validación**: la fila existe/actualizó; devuelve el id.

### Paso 3 · Orquestar con ventas + cerrar
- Si el trabajo es de pipeline/previsión → pasa a [[sales-pipeline-forecast]] (lee los deals). Si es preparar una reunión → [[sales-call-prep]].
- Append en `context/learnings.md` bajo `## automation-crm`.

## Outputs
- Registros creados/actualizados en el CRM (Supabase o Twenty) + resumen de la operación. Export opcional (CSV) a `projects/automation-crm/<YYYY-MM-DD>/` para `sales-pipeline-forecast`.

## Skills que llama
- **`sales-pipeline-forecast`** — previsión/priorización leyendo los deals del CRM.
- **`sales-call-prep`** — contexto de la cuenta antes de una reunión.
- **`marketing-prospecting`** — alta de leads captados como contactos.

## Edge cases
- Datos personales → RGPD: base legal, `.env` para claves (NUNCA commitear), RLS en Supabase. Ver [[legal-compliance]].
- Twenty AGPLv3: solo usar/conectar; si se quisiera modificar/redistribuir su código, avisar del copyleft.
- Dedup: antes de crear, busca por email/dominio; fusiona en vez de duplicar.
- Sin Supabase ni Twenty montados → para en Setup; no simules un CRM en memoria.

## Examples

Ver `references/schema.md` (modelo de datos) y `references/examples.md` (casos).
