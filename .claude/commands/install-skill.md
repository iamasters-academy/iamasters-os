---
description: Instala una skill desde URL de GitHub con validación local previa. Anti-inflación: verifica estructura antes de globalizar.
---

# /install-skill

Instala una skill externa desde GitHub al repo local con validación previa de estructura.

## Uso

```
/install-skill <github-url>
/install-skill <nombre-skill-opcional>
```

Ejemplos:
- `/install-skill https://github.com/scrapes/skills/humanizer`
- `/install-skill https://github.com/anthropics/skills/copywriting`
- `/install-skill cognito` (atajo a skill local en `_optional/`)

## Modo "atajo biblioteca" (sin URL)

Si el argumento NO es URL sino un nombre simple (ej. `cognito`, `seis-sombreros`):

→ Es una skill de la **biblioteca del OS** (`skills-library/`). Delega en `/skills`:

```bash
bash scripts/skills.sh add <nombre>
```

Mensaje: *"Skill `<nombre>` instalada. Reinicia Claude Code para que cargue."*
Si no existe en la biblioteca, el script lo dice y sugiere `bash scripts/skills.sh list` — muestra ese catálogo al usuario.

Para desinstalar: `bash scripts/skills.sh remove <nombre>` (ver `/skills`).

## Process

### Paso 1 · Validar URL
- ¿Es URL de GitHub válida?
- ¿Apunta a una carpeta o archivo `SKILL.md`?

### Paso 2 · Descargar a temporal

Ejecuta `bash scripts/validate-skill.sh <url>`. El script:
1. Crea carpeta temporal en `/tmp/iamasters-os-skill-validate-<hash>/`
2. Clona la URL completa o usa `git archive` para descargar solo la subcarpeta
3. Lista archivos descargados

### Paso 3 · Validar estructura

El script valida:

**Obligatorio**:
- `SKILL.md` existe en la raíz de la skill
- YAML frontmatter presente (líneas 1-3 con `---`)
- Campo `name` presente y kebab-case
- Campo `description` presente, ≥50 chars, ≤500 chars
- `description` contiene al menos un verbo de intención (crea, genera, analiza, extrae, etc.)

**Recomendado** (warnings, no bloquean):
- `references/` carpeta presente si SKILL.md > 2500 caracteres
- `examples.md` presente en references si hay
- Skill no contiene `eval()` o ejecución de código sin sandbox
- No hay rutas `/etc/`, `~/`, paths absolutos sospechosos
- No hay credenciales hardcoded (regex API keys, tokens)

**Bloqueantes** (rechazo automático):
- No hay SKILL.md
- YAML frontmatter mal formado
- description < 30 chars (insuficiente)
- description duplica nombre de skill ya instalada localmente
- Scripts `.sh` con `rm -rf /` o similares destructivos sin justificación

### Paso 4 · Mostrar resultado al operador

```markdown
## Validación de skill

**URL**: https://github.com/scrapes/skills/humanizer
**Skill**: tool-humanizer (¡atención: ya tienes una skill local con ese nombre!)
**Tamaño**: SKILL.md 2.1KB, references 4.5KB, scripts 0KB

### Validaciones
- ✅ SKILL.md presente
- ✅ YAML frontmatter correcto
- ✅ description 187 chars (en rango)
- ⚠️ Conflicto: ya existe `.claude/skills/tool-humanizer/`
- ✅ Sin código ejecutable peligroso
- ✅ Sin credenciales hardcoded

### Acción a tomar

[1] Cancelar
[2] Reemplazar tu local (con backup automático)
[3] Instalar como tool-humanizer-v2 (renombrar)
[4] Ver diff vs tu versión local
```

### Paso 5 · Instalación local

Si el operador acepta:
1. Si existe local: backup en `.backup/<timestamp>/.claude/skills/...`
2. Copiar a `.claude/skills/<nombre>/`
3. Si la categoría es ambigua, preguntar al operador donde categorizar (`_meta` / `marketing` / `tools` / etc.)
4. Update `synapsis/skills-catalog.json` con nueva entrada
5. Update `CLAUDE.md` skills registry

### Paso 6 · Test de activación

Tras instalar:
- Reiniciar Claude Code (Ctrl+C × 2 + claude)
- Probar prompt que debería activar la skill (basado en su description)
- Si activa correctamente: confirmar instalación
- Si no activa: ofrecer (a) editar description, (b) renombrar, (c) desinstalar

### Paso 7 · Cierre

- Mostrar al operador qué se instaló y dónde
- Sugerir ejecutar `/wrap-up` para que el cambio quede registrado
- Append en `context/learnings.md` si la skill aporta valor diferencial:
  ```
  ## install-skill
  - YYYY-MM-DD: instalada <skill> de <url>. Útil para <caso>.
  ```

## Edge cases

- **Repo privado en GitHub**: pide al operador token o que la haga pública temporalmente
- **Skill duplica funcionalidad de una local**: avisar y dejar al operador decidir si fusionar o mantener ambas
- **Skill con dependencias** (otra skill no instalada): avisar y preguntar si instalar dependencias también
- **Skill huge** (>50KB): warning sobre token consumption — sugerir leer SKILL.md primero

## Implementación

Este comando llama a `bash scripts/validate-skill.sh <url>` que hace todo el trabajo.
