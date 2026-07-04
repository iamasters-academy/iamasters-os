---
name: automation-fork-and-resell
description: Convierte software open-source (Cal.com, Ghost, Medusa, n8n, Supabase…) en un servicio vendible a PYMEs — elige la oportunidad, forkea, aplica marca, despliega en VPS/cloud y define el modelo de cobro (setup + mantenimiento). Úsala cuando el operador diga "cómo monetizo este repo open-source", "quiero revender X a clientes", "monta un servicio con este software libre" o busque productizar una herramienta OSS para su consultoría IA-PYMEs.
---

# automation-fork-and-resell

> **Adaptación iAmasters OS** — Playbook/metodología del OS (no wrapper de un repo). Empaqueta software
> open-source como oportunidades de servicio para el frente **IA-para-PYMEs**. Puente al OS: el despliegue
> se apoya en [[automation-client-deploy]] (entorno cliente/VPS) y [[vercel-deploy]] (web); el arranque
> de código, en [[arnes]]. El catálogo de oportunidades vive en `references/opportunities.md`.

## Cuándo se invoca
- El operador dice "cómo monetizo este repo open-source", "quiero revender X a clientes", "monta un servicio con este software libre".
- Busca un servicio productizable para su consultoría (setup + mantenimiento recurrente).

## Process

### Paso 1 · Elegir la oportunidad
- Consulta `references/opportunities.md` (qué reemplaza cada OSS, a quién venderlo, esfuerzo, cobro).
- Cruza con el ICP del operador y el cliente concreto. **Verifica la LICENCIA** del proyecto (¿permite ofrecer como servicio / SaaS?; ojo AGPL).
- **Validación**: oportunidad elegida + cliente/segmento + licencia compatible con el modelo de negocio.

### Paso 2 · Forkear + marca + configurar
- Fork del repo; branding (logo/colores/dominio); configuración mínima viable para el caso del cliente.
- **Validación**: instancia personalizada arranca en local con la marca aplicada.

### Paso 3 · Desplegar
- Despliega en VPS/cloud del operador o del cliente. Web → [[vercel-deploy]]; entorno cliente/VPS → [[automation-client-deploy]]. Aplica [[tool-vps-hardening]] antes de exponer.
- **Validación**: servicio accesible, seguro (puertos/auth/TLS), con backups.

### Paso 4 · Modelo de cobro + entrega
- Define precio: setup único + mantenimiento mensual (hosting + soporte). Documenta qué incluye y qué no.
- Append en `context/learnings.md` bajo `## automation-fork-and-resell` (qué oportunidad, qué margen real).

## Outputs
- `projects/automation-fork-and-resell/<YYYY-MM-DD>-<oportunidad>/` con: decisión, config de marca, notas de deploy, propuesta de precio.

## Skills que llama
- **`arnes`** — scaffold/arranque si hay que tocar código.
- **`tool-vps-hardening`** — asegurar antes de exponer.
- **`automation-client-deploy`** / **`vercel-deploy`** — despliegue.
- **`startup-business-analyst`** — validar el modelo (unit economics del servicio).

## Edge cases
- **Licencia incompatible** (p. ej. AGPL con SaaS) → para y avisa; propón otra oportunidad o modelo (self-host en casa del cliente).
- Marca de terceros / marcas registradas → no reutilizar; branding propio del operador o del cliente.
- El OSS ya lo ofrece el propio proyecto como cloud de pago → diferénciate en nicho/idioma/soporte local, no compitas en precio puro.

## Examples

Ver `references/opportunities.md` (catálogo) y `references/examples.md` (casos).
