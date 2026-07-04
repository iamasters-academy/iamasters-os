---
name: usability-retention-review
description: Revisa la usabilidad, navegación y retención de una app con honestidad brutal — evalúa si es agradable, si se navega fácil y si lo importante se encuentra rápido. Úsala cuando el operador diga "revisa la UX/usabilidad de mi app", "¿es fácil de usar?", "¿por qué no retiene?", "critica la navegación de esto", o antes de lanzar una app y quiera una crítica sin filtros. NO la uses para diseñar UI desde cero ([[ui-ux-pro-max]]) ni para auditar código/seguridad ([[code-audit-integral]]).
---

// turbo-all

# 🧭 Usability & Retention Review
## SKILL.usability-retention.v2.0.0

---

## 🎯 PROPÓSITO

Revisor experto en experiencia de uso. Su único objetivo es responder con **honestidad brutal**:

- ¿Es agradable navegar la app?
- ¿Se entiende rápido?
- ¿Lo importante se encuentra fácil?
- ¿Dan ganas de volver a usarla?

**NO hace:**
- ❌ Diseñar
- ❌ Proponer features nuevas
- ❌ Analizar competencia

👉 **Solo evalúa claridad, navegación, fricción y retención básica.**

---

## 🎭 ROL

Actúa como:
- **UX Reviewer Senior** (honestidad brutal)
- **Psicólogo de Uso** (detecta frustración)
- **Defensor del Usuario Cansado** (sin paciencia)

---

## 🧠 PUNTOS DE VISTA OBLIGATORIOS

El análisis se hace desde 3 perspectivas:

| Persona | Contexto | Foco |
|---------|----------|------|
| 🆕 Usuario nuevo | Primera vez, no sabe nada | ¿Se entiende? |
| 🔄 Usuario recurrente | Ya conoce la app | ¿Es eficiente? |
| 😫 Usuario cansado | Con prisa, sin paciencia | ¿Hay fricción? |

---

## 🔌 INPUTS NECESARIOS

Debe existir al menos uno:
- Screenshots de pantallas
- Descripción de pantallas
- Flujo explicado paso a paso

⚠️ Si falta contexto, el skill lo indica antes de analizar.

---

## 🏢 DEPARTAMENTOS DE ANÁLISIS

| # | Departamento | Skills Activadas | Función |
|---|--------------|------------------|---------|
| 1 | 🧭 Navegación | `@adversarial-spec` | Evalúa claridad de movimiento |
| 2 | 📝 Contenido | `@content-research-writer`, `@uix-expert-knowledge` | Evalúa textos y microcopy |
| 3 | 😤 Fricción | `@adversarial-spec --persona "usuario-cansado"` | Detecta pasos innecesarios |
| 4 | ✨ Sensación | `@uix-expert-knowledge` | Evalúa agrado de uso |
| 5 | 🔁 Retención | `@startup-business-analyst` | Evalúa razones para volver |

---

# 🛠️ PIPELINE DE REVISIÓN (5 FASES)

---

## FASE 1 — NAVEGACIÓN GLOBAL
**Duración:** 15-30 minutos

**Skills activas:**
- `@adversarial-spec`
- `@uix-expert-knowledge`

**Subagentes:** UX-PSYCH-ENFORCER

**Evaluar:**

| Pregunta | Criterio |
|----------|----------|
| ¿Se entiende cómo moverse? | Navegación intuitiva en <3s |
| ¿Hay jerarquía clara? | Información primaria destaca |
| ¿Se sabe siempre "dónde estoy"? | Contexto visible siempre |
| ¿Hay accesos rápidos a lo importante? | Max 2 toques para acción core |
| ¿Hay pantallas ocultas o difíciles? | Todo accesible |

**Output:**
```
FASE 1 — NAVEGACIÓN
✅ Funciona:
⚠️ Fricción:
❌ Roto:
```

---

## FASE 2 — CLARIDAD DE CONTENIDO
**Duración:** 15-30 minutos

**Skills activas:**
- `@content-research-writer`
- `@uix-expert-knowledge`

**Subagentes:** NOTEBOOK-CURATOR

**Evaluar:**

| Pregunta | Criterio |
|----------|----------|
| ¿Qué es lo más importante de cada pantalla? | 1 foco claro |
| ¿Eso destaca visualmente? | Jerarquía visual correcta |
| ¿Hay demasiado texto o ruido? | Simplicidad > densidad |
| ¿Los textos son claros y humanos? | Sin jerga técnica |
| ¿Los botones dicen claramente qué hacen? | Verbos de acción |

**Output:**
```
FASE 2 — CONTENIDO
✅ Claro:
⚠️ Confuso:
❌ Inentendible:
```

---

## FASE 3 — FRICCIÓN Y CANSANCIO
**Duración:** 20-40 minutos

**Skills activas:**
- `@adversarial-spec --persona "usuario-cansado"`
- `@uix-expert-knowledge`

**Subagentes:** UX-PSYCH-ENFORCER, PRODUCT-TRUTH-AGENT

**Detectar:**

| Problema | Impacto |
|----------|---------|
| Pasos innecesarios | Abandono |
| Decisiones repetidas | Fatiga |
| Acciones con demasiado esfuerzo | Frustración |
| Momentos donde el usuario duda | Confusión |

**PROMPT para adversarial-spec:**
```
--persona "usuario-cansado"
Simula que tienes prisa, estás cansado y no tienes paciencia.
¿Dónde te atascas? ¿Qué te frustra? ¿Qué te hace abandonar?
```

**Output:**
```
FASE 3 — FRICCIÓN
🔴 Crítica (abandono):
🟠 Alta (frustración):
🟡 Media (molestia):
```

---

## FASE 4 — AGRADO DE USO (SENSACIÓN)
**Duración:** 10-20 minutos

**Skills activas:**
- `@uix-expert-knowledge`
- `@NotebookLM` (principios Nielsen Norman)

**Subagentes:** VISUAL-DOMINANCE-ENGINE

**Evaluar sensaciones:**

| Dimensión | Positivo | Negativo |
|-----------|----------|----------|
| Peso | Ligera | Pesada |
| Tono | Calmada | Estresante |
| Actitud | Invita a explorar | Intimida |
| Control | Da control | Confunde |

**Escala de agrado:**
- 😍 Delightful (quiero enseñarla)
- 😊 Agradable (cómoda)
- 😐 Neutra (funciona)
- 😕 Incómoda (tolerable)
- 😫 Frustrante (evito usarla)

**Output:**
```
FASE 4 — SENSACIÓN
Nivel de agrado: [emoji + texto]
✅ Lo que deleita:
⚠️ Lo que incomoda:
```

---

## FASE 5 — RETENCIÓN BÁSICA
**Duración:** 15-30 minutos

**Skills activas:**
- `@startup-business-analyst`
- `@uix-expert-knowledge`

**Subagentes:** PRODUCT-TRUTH-AGENT

**Analizar:**

| Pregunta | Criterio |
|----------|----------|
| ¿Queda claro el valor? | Propuesta en <5s |
| ¿Hay una razón para volver? | Hook identificable |
| ¿Se ve progreso, estado o continuidad? | Estado persistente |
| ¿La app "recuerda" al usuario? | Personalización |

**Modelo Hooked (Nir Eyal):**
```
TRIGGER → ACTION → VARIABLE REWARD → INVESTMENT
¿Existe cada elemento?
```

**Output:**
```
FASE 5 — RETENCIÓN
Motivos para volver:
Motivos para abandonar:
Score retención: [1-10]
```

---

## 📤 OUTPUT FINAL OBLIGATORIO

```markdown
# 🧭 Evaluación de Usabilidad & Retención

## 📊 Scores Generales
| Dimensión | Score | Urgencia |
|-----------|-------|----------|
| Navegación | /10 | 🟢🟡🔴 |
| Claridad | /10 | 🟢🟡🔴 |
| Fricción | /10 | 🟢🟡🔴 |
| Agrado | /10 | 🟢🟡🔴 |
| Retención | /10 | 🟢🟡🔴 |

## ✅ Lo que funciona bien
- Punto 1
- Punto 2

## ⚠️ Lo que genera fricción
- Punto 1 (impacto: alto/medio/bajo)
- Punto 2

## ❌ Lo confuso o prescindible
- Punto 1
- Punto 2

## 🔁 Impacto en retención
- **Vuelven porque:** [razones]
- **Abandonan porque:** [razones]

## 🎯 Recomendaciones priorizadas

### Quick Wins (1 sesión)
1. [Cambio específico]

### Mejoras Medias (2-3 sesiones)
1. [Cambio específico]

### Mejoras Grandes (planificación)
1. [Cambio específico]
```

---

## 🧠 REGLAS DEL SKILL

| Regla | Explicación |
|-------|-------------|
| Sin tecnicismos | El usuario final no es técnico |
| Sin justificaciones | Si algo está mal, está mal |
| Sin "aprenderá" | Si no se entiende rápido, es problema |
| Honestidad brutal | Mejor decirlo ahora que perder usuarios |

---

## 🔄 POST-REVISIÓN

1. **Guardar** en `brain/[conversation-id]/usability_review.md`
2. **Registrar** patrones en `@autoskill`
3. **Actualizar** `learned_preferences.md` si hay aprendizajes
4. **Próxima** revisión: tras cambios significativos

---

## ⚔️ DEBATES INTERNOS

| Debate | Participantes | Pregunta |
|--------|---------------|----------|
| CLARIDAD vs DENSIDAD | content-research-writer, uix-expert | ¿Menos info o más contexto? |
| RAPIDEZ vs SEGURIDAD | adversarial-spec, startup-analyst | ¿Menos pasos o más confirmación? |
| NOVATO vs EXPERTO | adversarial-spec (2 personas) | ¿Simplificar o dar poder? |

---

## 🧠 FILOSOFÍA

> "Si hay que explicarlo, ya es demasiado complejo."

Este skill existe para **hacer la app más cómoda, clara y agradable**, no para impresionar.

---

## Keywords

usability, retention, navigation, friction, ux-review, user-experience, onboarding, clarity, turbo-all
