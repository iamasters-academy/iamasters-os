# Cónclave — instalación (versión iAmasters OS)

> **Esta variante NO usa el `install.sh`/`install.ps1` original del paquete.**
> El instalador original sobrescribe `.git/hooks/pre-commit` sin backup y
> pisaría el hook **Arnes v0.2.4** (guard de secretos + archivos grandes) que
> ya vive en este repo. Aquí el hook se **fusiona** a mano.

## Qué se instaló en este OS

```
.claude/skills/engineering/conclave/
├── SKILL.md                  ← la skill (adaptada: delega revisión en cognito/code-review/verify)
├── scripts/
│   └── conclave-approve.sh   ← sella el árbol tras el doble OK (one-liner envuelto)
└── references/
    └── install.md            ← esto
```

Más:
- `hooks/pre-commit` ← **fusionado**: Arnes (secretos + archivos grandes,
  SIEMPRE) + sello Cónclave (SOLO si el staged toca código).
- `.git/hooks/pre-commit` ← copia activa de `hooks/pre-commit` (no commiteada).
- `.gitignore` ← entrada `.conclave/` añadida.
- Catálogo/registry regenerados: `conclave` aparece como skill core bajo
  `engineering/`.

## Cómo funciona el gate (el flujo real)

1. Desarrollas con la skill (fan-out opcional + revisión adversarial delegada
   en `cognito`/`code-review`/`verify`/`security-review`).
2. Cuando el **constructor y el revisor dan APTO** (doble OK), sellas el árbol
   staged:
   ```bash
   bash .claude/skills/engineering/conclave/scripts/conclave-approve.sh
   # equivale a: git write-tree > .conclave/pass
   ```
3. `git commit` → el hook compara el árbol staged con el sello. Coincide →
   commit (y consume el sello). No coincide → **aborta**.
4. Cualquier `git add` posterior al sello lo invalida → obliga a re-revisar
   (garantiza que se commitea EXACTAMENTE lo revisado).

## Scope del gate en este OS

El hook **solo exige sello cuando el staged toca código**:
- Extensiones: `.sh .mjs .js .ts .py .ps1`
- Rutas bajo: `hooks/`, `vendor/`, `scripts/`

Los commits de **solo docs/skills/`.md`/`brand-context`/`context`/`projects`**
pasan **sin sello** (el gate no asfixia docs). Los guards de **secretos**
(`API_KEY|SECRET|PASSWORD|TOKEN`) y **archivos grandes (>1M)** son
incondicionales: bloquean siempre, con o sin sello.

## Override de emergencia (deja rastro, úsalo consciente)

```bash
CONCLAVE_OVERRIDE=1 git commit -m "..."
```

Bypassa **solo** el sello de Cónclave. **No** bypassa el guard de secretos ni
el de archivos grandes — esos siguen bloqueando.

## Re-aplicar el hook en otro repo (p. ej. un proyecto de software)

Si quieres llevar el gate a un repo de software de verdad (FVI, Polymaster…):

1. Copia la skill: `cp -r .claude/skills/engineering/conclave <destino>/.claude/skills/engineering/`
2. Copia el hook: `cp hooks/pre-commit <destino>/.git/hooks/pre-commit && chmod +x <destino>/.git/hooks/pre-commit`
3. Añade `.conclave/` al `.gitignore` del destino.

> En un repo de software (no de skills), considera cambiar el scope del gate a
> "todos los commits" (quitar el filtro por extensión) — ahí todo es código.

## Requisitos
- git. Bash disponible (Git Bash en Windows sirve). Un agente de IA (Claude
  Code u otro) que ejecute la skill y un revisor (`cognito`/`code-review`/…
  en este OS) para el gate.
