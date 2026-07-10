---
name: cache-manager
description: Sistema de caché inteligente para skills. Registra uso, instala automáticamente skills de biblioteca cuando se necesitan y retira skills no usadas tras 7 días. Actúa como middleware entre el operador y las skills: cuando Claude detecta que necesita una skill no instalada, la ofrece instalar, la usa, registra el uso y la deja cachada 7 días. Se invoca automáticamente desde otras skills o cuando Claude detecta un trigger que requiere una skill específica.
author: IA Masters Academy (basado en sistema anterior del operador)
version: 1.0.0
tags: [cache, skills, auto-install, auto-retire, tracking, optimización]
---

# cache-manager — Sistema de Caché Inteligente para Skills

> **Skill de infraestructura**: No resuelve problemas del operador directamente, sino
> optimiza cómo se cargan las otras skills. Similar a como `automation-loop-engine`
> es una skill sobre construir sistemas, esta skill es una skill sobre gestionar skills.

---

## Qué hace

1. **Tracking de uso**: Registra cuándo se usa cada skill (timestamp)
2. **Auto-instalación**: Detecta skills no instaladas, ofrece instalarlas
3. **Auto-retiro**: Retira skills no usadas en 7 días
4. **Reporting**: Muestra estado del caché (skills cacheadas, retiradas, disponibles)

## Cuándo se invoca

Esta skill se invoca de dos formas:

### 1. Automática (desde otras skills)

Cuando otra skill detecta que necesita una skill auxiliar:
```markdown
Ejemplo: marketing-copywriting necesita tool-humanizer
1. Claude detecta: "Necesito tool-humanizer para quitar AI-tell"
2. cache-manager evalúa: "¿Está tool-humanizer instalada?"
3. Si no: cache-manager ofrece: "Detecto que necesitas tool-humanizer. ¿La instalo?"
4. Si usuario: "Sí" → cache-manager la instala
5. cache-manager la usa → registra uso
6. La skill cacheada 7 días
```

### 2. Manual (cuando el operador lo pide)

Cuando el operador dice:
- "Estado del caché de skills"
- "¿Qué skills tengo instaladas?"
- "Limpia el caché de skills"
- "Retira skills no usadas"

## Flujo de Trabajo

### Paso 1: Detectar necesidad de skill

**Trigger:** Claude identifica: "Necesito X skill para Y tarea"

**Verificación:**
```bash
# ¿Está la skill instalada?
if [ -f ".claude/skills/<categoria>/<skill>/SKILL.md" ]; then
  ESTA_INSTALADA=true
else
  ESTA_INSTALADA=false
fi
```

**Acción:** Si no está instalada, ofrecer instalación

---

### Paso 2: Ofrecer instalación

**Prompt:**
```
Detecto que necesitas <skill> para completar esta tarea.

<skill> está en biblioteca pero no instalada.

¿La instalo ahora?
- [Sí, instálala]
- [No, usar solo lo que tengo]

Respuesta del usuario: _
```

**Si usuario: "Sí"**
```bash
# Instalar desde biblioteca
bash scripts/skills.sh add <skill>
```

**Si usuario: "No"**
- Continuar sin esa skill (fallback)

---

### Paso 3: Usar la skill

Una vez instalada, Claude puede invocarla normalmente:
```markdown
Claude: "Voy a usar <skill> para X"

[Resto del workflow normal de la skill]
```

---

### Paso 4: Registrar uso

**Registrar timestamp inmediatamente después de usar:**
```bash
# Actualizar usage-tracker.json
LAST_USED=$(date +%Y-%m-%d)
tmpfile=$(mktemp)
jq --arg skill "$skill" --arg last_used "$LAST_USED" '.skills[skill] = {last_used: $last_used, status: "cached"}' .claude/skills/usage-tracker.json > "$tmpfile"
mv "$tmpfile" .claude/skills/usage-tracker.json
```

---

### Paso 5: Auto-retiro (ejecutar en meta-wrap-up)

**Script auto-retire-skills.sh:**
- Revisa skills instaladas (no core)
- Calcula días desde último uso
- Si > 7 días → retira (mueve a biblioteca)
- Actualiza tracker con status: "retired"

**Trigger:** Ejecutar al final de cada sesión (meta-wrap-up)

---

## Estructura de usage-tracker.json

```json
{
  "version": "1.0.0",
  "last_updated": "2025-01-15",
  "skills": {
    "marketing-copywriting": {
      "last_used": "2025-01-15",
      "status": "cached"
    },
    "tool-humanizer": {
      "last_used": "2025-01-10",
      "status": "retired"
    },
    "automation-n8n-builder": {
      "last_used": "2025-01-14",
      "status": "cached"
    }
  }
}
```

**Estados de status:**
- `"core"` — Skill pre-instalada (nunca se retira)
- `"cached"` — Skill instalada por caché (sujeta a auto-retire)
- `"retired"` — Skill movida a biblioteca (disponible, no instalada)

---

## Integración con meta-wrap-up

Añadir al final de `.claude/skills/_meta/meta-wrap-up/SKILL.md`:

```markdown
## Fase Final: Auto-Retire de Skills

1. Ejecutar script de auto-retire:
   ```bash
   bash scripts/auto-retire-skills.sh
   ```

2. Reportar:
   - Skills retiradas (no usadas 7 días)
   - Skills mantenidas (usadas recientemente)
   - Estado del caché (X skills cacheadas)

3. Actualizar usage-tracker.json con fecha actual
```

---

## Comandos Disponibles

**Manual:**
- `/skills cache-status` — Ver estado del caché
- `/skills cache-retire` — Ejecutar auto-retiro manual
- `/skills cache-clean` — Limpiar tracker (reset)

**Automático:**
- Integrado en meta-wrap-up (se ejecuta al cierre de sesión)

---

## Ejemplo de Uso Completo

### Sesión 1: Crear contenido

```
1. Usuario: "Hazme un post de LinkedIn sobre FVI"

2. Claude: "Voy a usar marketing-copywriting para crear el post"

3. cache-manager evalúa: "¿Tengo marketing-copywriting instalada?" → NO

4. cache-manager: "Detecto que necesitas marketing-copywriting para crear el post.
   marketing-copywriting está en biblioteca pero no instalada.

   ¿La instalo ahora?
   - [Sí, instálala]
   - [No, usar solo lo que tengo]

5. Usuario: "Sí"

6. cache-manager:
   - bash scripts/skills.sh add marketing-copywriting
   - Claude: "Ahora uso marketing-copywriting..."
   - [Genera post]
   - Registra uso: marketing-copywriting usado [2025-01-15]

7. cache-manager: "marketing-copywriting cacheada por 7 días"
```

### Sesión 2: 8 días después

```
1. Usuario: "Hazme un post de LinkedIn sobre X"

2. Claude: "Voy a usar marketing-copywriting para crear el post"

3. cache-manager evalúa: "¿Tengo marketing-copywriting instalada?" → SÍ

4. Claude: "La tengo instalada (cache). Uso marketing-copywriting..."
   - [Genera post]
   - Refresca uso: marketing-copywriting usado [2025-01-23]
```

### meta-wrap-up (Sesión 2):

```
1. meta-wrap-up ejecuta auto-retire-skills.sh

2. Script detecta:
   - marketing-copywriting: usada hace 1 día → MANTENER
   - automation-n8n-builder: NO usada 8 días → RETIRAR

3. Output:
   "🗑️ automation-n8n-builder: No usada 8 días → RETIRAR"
   "✓ marketing-copywriting: Usada hace 1 día → MANTENER"

4. Resultado:
   - marketing-copywriting: Se queda (sigue cacheada)
   - automation-n8n-builder: Se mueve a biblioteca (disponible)
```

---

## Benefits

### Para el operador:
- ✅ **Menos tokens desperdiciados**: Solo pagan por skills usadas recientemente
- ✅ **Experiencia fluida**: Skills frecuentes se quedan instaladas
- ✅ **Auto-optimización**: El sistema aprende tus patrones de uso
- ✅ **Visibilidad**: Siempre sabes qué skills tienes instaladas y por qué

### Para Claude:
- ✅ **Auto-instalación**: No recuerda instalar skills, Claude lo hace solo
- ✅ **Contexto ligero**: Más tokens disponibles para el trabajo real
- ✅ **Escalabilidad**: Puedes tener 200 skills en biblioteca, pero solo 15-20 activas
- ✅ **Sin fricción**: Skills frecuentes (marketing-copywriting) parecen pre-instaladas

---

## Comparativa de Eficiencia

### Antes (45 skills pre-instaladas):
- Tokens skills: ~131K (65%)
- Sesión típica: 5-10 skills usadas
- Tokens desperdiciados: ~100K (pagas por tenerlas "por si acaso")

### Después (cache inteligente):
- Tokens skills: ~45K (22%)
  - Core: ~30K (11 skills)
  - Cacheadas: ~15K (5-10 skills frecuentes)
- Sesión típica: 5-10 skills usadas
- Tokens desperdiciados: ~0

**Ahorro: ~86K tokens recuperados (43% más contexto para trabajo real)**

---

## Troubleshooting

**P: No se registra el uso de una skill**
- Verificar que la skill que usaste invoca cache-manager al final
- Revisar permisos de escritura en usage-tracker.json

**P: Skills se retiran demasiado rápido**
- Aumentar RETIRE_DAYS de 7 a 14 días en auto-retire-skills.sh
- Verificar que timestamp se actualiza correctamente

**P: Demasiadas skills cacheadas**
- Ejecutar `/skills cache-retire` manualmente para forzar retirado
- Revisar qué skills se usan realmente (puede haber ghost skills)

**P: tracking.json se corrupto**
- Copia de seguridad en `.claude/skills/usage-tracker.json.backup`
- Si corrupto: Eliminar archivo, se regenerará vacío al próximo uso
