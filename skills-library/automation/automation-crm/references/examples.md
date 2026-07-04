# automation-crm — Ejemplos

## Ejemplo 1 · Montar el CRM (Supabase)

**Operador**: "Necesito un CRM para llevar mis leads de consultoría."

**Flujo**:
1. Vía A (Supabase, MCP ya conectado). Se crea el esquema `companies/contacts/deals/activities`
   (`schema.md`) con RLS on.
2. Se confirma con una consulta de prueba. CRM listo sin infra nueva.
3. Se ofrece encadenar `marketing-prospecting` (para poblar contactos) y `sales-pipeline-forecast`.

## Ejemplo 2 · Alta de lead + mover deal

**Operador**: "Guarda a Ana de Empresa Demo SL y ábrele un deal en 'proposal' por 3.000€."

**Flujo**:
1. Dedup por email/dominio (no existe). Se crea company `empresademo.com`, contact Ana, deal
   `proposal` 3000 EUR, prob 0.5.
2. Devuelve los ids. Queda listo para que `sales-pipeline-forecast` lo incluya en la previsión.

## Ejemplo 3 · Twenty (UI completa)

**Operador**: "Quiero el CRM con interfaz visual tipo Claura."

**Flujo**:
1. Vía B: self-host Twenty (Docker). Se **conecta** por su API GraphQL (no se toca su código, AGPLv3).
2. Operaciones vía mutaciones/queries GraphQL; mapeo People/Companies/Opportunities/Activities.

## Nota

Default = Supabase (ligero, tu stack). Twenty para UI completa. RGPD siempre: RLS, claves en `.env`,
consultar `legal-compliance` si hay datos sensibles.
