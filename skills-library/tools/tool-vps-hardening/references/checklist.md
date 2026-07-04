# tool-vps-hardening — Checklist

## Superficie expuesta
- [ ] `ss -tlnp` — inventario de puertos a la escucha.
- [ ] Ningún servicio sensible accesible desde Internet **sin auth** (dashboards, APIs internas, BBDD).
- [ ] `ufw` activo; solo puertos necesarios abiertos; el resto `deny`.
- [ ] Servicios internos bind a `127.0.0.1` + reverse proxy con TLS (Caddy/nginx) o túnel SSH/Tailscale.

## SSH
- [ ] Password auth desactivado (`PasswordAuthentication no`); solo clave.
- [ ] Root login desactivado (`PermitRootLogin no`).
- [ ] `fail2ban` instalado y activo.

## Docker
- [ ] Sin contenedores `--privileged` salvo necesidad justificada.
- [ ] Puertos publicados bind a `127.0.0.1` cuando no deban ser públicos.
- [ ] Imágenes actualizadas; sin secrets en `ENV`/layers.

## Secrets
- [ ] Claves en `.env`/gestor, **nunca** en el repo (grep de patrones + `git log`).
- [ ] `.env*` en `.gitignore`.
- [ ] Rotación de claves antiguas / expuestas / de repos que fueron públicos.

## Pre-deploy a cliente
- [ ] Solo puertos necesarios; nada de debug abierto.
- [ ] RGPD si es público (cookies/consentimiento) → `tool-web-legal-audit`.
- [ ] Logs sin secrets. Backups configurados.
