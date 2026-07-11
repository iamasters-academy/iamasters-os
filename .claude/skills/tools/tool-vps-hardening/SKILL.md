---
name: tool-vps-hardening
description: Asegura un VPS/servidor y la higiene de secrets — SSH por clave, firewall ufw, auditoría de puertos expuestos, Docker security, fail2ban, rotación de claves y checklist pre-deploy a cliente. Úsala cuando el operador diga "asegura mi VPS", "¿tengo puertos expuestos?", "hardening del servidor", "revisa la seguridad de mi Docker/servidor" o antes de exponer un servicio público.
---

# tool-vps-hardening

> **Adaptación iAmasters OS** — Skill original del OS. Destila los dominios relevantes de la seguridad
> de servidor al stack real del operador (VPS Contabo + Docker + despliegues a cliente). **Complementa,
> no solapa**: [[tool-web-security-audit]] (capa web/app), [[tool-seguridad-ia]] (código que escribe la
> IA), [[tool-web-legal-audit]] (RGPD/cookies). Esta cubre el **servidor y los secrets**, que hoy es un
> hueco con exposición real. Autorización: solo servidores propios o con permiso explícito.

## Cuándo se invoca
- El operador dice "asegura mi VPS", "¿tengo puertos expuestos?", "hardening del servidor", "revisa mi Docker".
- Antes de exponer un servicio público (dashboard, API) o de entregar a un cliente.
- Auditoría periódica de higiene de secrets (rotación de claves, `.env` sin commitear).

## Setup
- Acceso SSH al servidor (idealmente por clave, no interactivo). Autorización confirmada.
- **Validación**: se conecta y puede leer estado de `ufw`, `docker`, puertos (`ss -tlnp`).

## Process

### Paso 1 · Auditar superficie expuesta
- Enumera puertos a la escucha (`ss -tlnp`) y reglas de `ufw`. Marca servicios accesibles desde Internet **sin auth** (caso real: dashboards en puertos altos).
- Revisa acceso SSH (¿password auth activo? ¿root login?), `fail2ban` presente.
- **Validación**: lista de puertos expuestos + veredicto por cada uno (necesario / cerrar / poner tras auth/túnel).

### Paso 2 · Higiene de secrets
- Comprueba que las claves viven en `.env`/gestor y **no** en el repo (`git log`/grep de patrones). Identifica claves a **rotar** (expuestas, antiguas, en repos que fueron públicos).
- **Validación**: inventario de secrets + acciones (rotar / mover a `.env` / revocar).

### Paso 3 · Recomendaciones + checklist
- Propón fixes priorizados 🔴🟠🟡: cerrar/`ufw deny` puertos, SSH solo-clave, `fail2ban`, Docker (no `--privileged`, puertos bind a `127.0.0.1` + reverse proxy, imágenes actualizadas), backups.
- Genera checklist pre-deploy a cliente (puertos, RGPD, claves, logs sin secrets).
- **Validación**: informe accionable. Los comandos que cambian estado (`ufw deny`, rotaciones, `sudo`) los ejecuta el operador salvo autorización explícita.

### Paso 4 · Cierre
- Append en `context/learnings.md` bajo `## tool-vps-hardening`. Si algo es urgente (servicio abierto sin auth), dilo primero y claro.

## Outputs
- `projects/tool-vps-hardening/<YYYY-MM-DD>-<host>/informe.md` (puertos, secrets, fixes 🔴🟠🟡, checklist).

## Skills que llama
- **`tool-web-security-audit`** — para la capa web/app del servicio expuesto.
- **`tool-web-legal-audit`** — RGPD si el servicio es público.
- **`automation-client-deploy`** — al entregar a cliente, aplicar el checklist.

## Edge cases
- Servidor de terceros sin autorización → NO auditar; pide permiso.
- Acciones destructivas/`sudo` (cerrar puertos, reiniciar) → las hace el operador salvo OK explícito; nunca cortes acceso sin avisar.
- Secret ya expuesto en repo público → rotar es obligatorio, no opcional; avisar a clones si la historia se reescribió.

## Examples

Ver `references/checklist.md` y `references/examples.md`.
