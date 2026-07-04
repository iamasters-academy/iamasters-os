# automation-fork-and-resell — Ejemplos

## Ejemplo 1 · Cal.com para una clínica

**Operador**: "Quiero venderle un sistema de reservas a una clínica con Cal.com."

**Flujo**:
1. Oportunidad = Cal.com. Licencia AGPL → **self-host en el servidor del cliente** (no SaaS multi-tenant).
2. Fork + marca de la clínica + configuración (servicios, horarios, recordatorios).
3. Deploy en el entorno del cliente con `automation-client-deploy`; asegurado con `tool-vps-hardening`.
4. Precio: setup único + mantenimiento mensual (hosting + soporte). `startup-business-analyst` valida margen.

## Ejemplo 2 · Descartar por licencia

**Operador**: "Monto un SaaS multi-cliente con [OSS AGPL]."

**Flujo**:
1. La licencia AGPL obliga a liberar cambios si se ofrece por red. Se avisa y se propone alternativa:
   self-host por cliente, u otra oportunidad con licencia permisiva (MIT/Apache).

## Nota

El margen está en personalización + mantenimiento + soporte local, no en el software (es libre). No
compitas en precio contra el cloud oficial del propio proyecto; diferénciate en nicho/idioma/cercanía.
