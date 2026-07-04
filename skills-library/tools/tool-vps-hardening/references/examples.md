# tool-vps-hardening — Ejemplos

## Ejemplo 1 · Dashboard expuesto sin auth (caso real)

**Operador**: "Revisa la seguridad de mi VPS."

**Flujo**:
1. `ss -tlnp` revela un dashboard en el puerto 8010 accesible desde Internet **sin auth** 🔴.
2. Higiene de secrets: un PAT antiguo aún válido → marcado para rotar/revocar 🔴.
3. Informe: (a) 🔴 cerrar 8010 (`sudo ufw deny 8010/tcp`) o ponerlo tras túnel SSH/Basic Auth;
   (b) 🔴 rotar el PAT; (c) 🟠 SSH solo-clave + fail2ban. Los comandos `sudo`/rotación los ejecuta
   el operador. Informe en `projects/tool-vps-hardening/2026-07-04-contabo/informe.md`.

## Ejemplo 2 · Checklist pre-deploy a cliente

**Operador**: "Voy a entregar el bot al PC del cliente, ¿está seguro?"

**Flujo**:
1. Se corre el checklist pre-deploy: puertos mínimos, `.env` fuera del repo, RGPD (deriva a
   `tool-web-legal-audit` si es público), logs sin secrets, backups.
2. Se listan los 🔴/🟠 antes de entregar; se enlaza con `automation-client-deploy` para el despliegue.

## Nota

Solo servidores propios o con permiso. Las acciones que cambian estado (cerrar puertos, `sudo`,
reiniciar servicios) las hace el operador salvo autorización explícita — nunca cortar acceso sin avisar.
