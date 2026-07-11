---
name: automation-embudo-captacion
description: Diseña el embudo completo de captación orgánica de leads: vídeo corto (Reels/Carruseles) → comentario con palabra clave → DM automático con enlace → landing/formulario → base de datos (Supabase/CRM), con guiones de alto alcance, esqueleto técnico y cuadro de métricas. Es ESTRATEGIA+DISEÑO del recorrido entero, no una pieza suelta. Úsala cuando el operador quiera convertir alcance en redes en leads: "captar leads/clientes/pacientes con Reels o Instagram", "embudo/funnel desde Instagram/TikTok", "que comenten una palabra y les llegue el enlace por DM", "comenta-palabra→DM automático→landing", "captación orgánica", "growth con Reels", "embudo social". El disparo es la INTENCIÓN de diseñar el recorrido contenido-social→lead. NO la dispares para UNA pieza aislada: un workflow n8n concreto (→ automation-n8n-builder), migrar un JSON n8n/ManyChat (→ automation-n8n-to-claude), solo copy/hooks (→ marketing-copywriting), analizar Meta Ads (→ marketing-meta-ads-analyzer), una secuencia de emails (→ marketing-email-sequence) o una landing/tabla suelta (→ automation-client-deploy).
author: IA Masters Academy
version: 1.0.0
tags: [captacion, embudo, funnel, reels, dm-automation, manychat, n8n, supabase, growth, leads]
---

# automation-embudo-captacion — Embudo de captación orgánica (contenido → DM → landing → BBDD)

> Convierte una intención vaga ("quiero captar clientes con Reels") en un **sistema de captación completo**: qué contenido publicar, cómo se automatiza el paso de comentario a lead, dónde caen los datos, y qué métricas dicen si funciona o dónde se rompe. Entrega estrategia + esqueleto técnico; el build real lo hacen las skills `automation-n8n-builder` y `automation-client-deploy`.

Esta skill existe porque el error más caro en captación por redes es construir el embudo antes de saber **dónde pierde gente**. El recorrido comentario → DM → clic → formulario → registro tiene fugas conocidas y grandes (el salto DM→landing suele perder >60%). Un plan honesto se diseña sabiendo eso desde el minuto uno, no descubriéndolo tras invertir en contenido.

---

## Qué produce (el entregable)

Un documento de embudo tancado al caso concreto, con 6 bloques:

1. **Diagnóstico** — las variables del embudo, decididas (no genéricas).
2. **Estrategia de contenido** — guiones concretos de Hook / Retención / CTA para el formato elegido.
3. **Arquitectura del embudo** — el diagrama del recorrido, con las fugas señaladas donde tocan.
4. **Esqueleto técnico** — esquema de la tabla de leads (Supabase) + el flujo n8n/ManyChat descrito paso a paso, listo para pasar a `automation-n8n-builder`.
5. **Cuadro de métricas** — qué medir, en qué orden, y el umbral que dispara cada diagnóstico.
6. **Análisis crítico** — los puntos débiles reales de ESTE embudo y cómo mitigarlos.

Guárdalo en `projects/<skill>/<fecha>-<titulo>/embudo.md` (nivel single-task) o en el brief del proyecto/cliente si viene de ahí.

---

## Flujo de trabajo

### Paso 1 · Diagnóstico (no arranques sin esto)

El contenido y la automatización dependen de decisiones que el operador debe fijar antes. Si faltan, pregúntalas — máximo en un bloque, no de una en una:

| Variable | Qué decidir |
|---|---|
| **Nicho / especialidad** | El área exacta. Un embudo genérico atrae leads genéricos. |
| **Público objetivo** | Enfocado en gente que **no** te conoce (el alcance viene de desconocidos). |
| **Oferta / lead magnet** | Qué recibe quien deja la palabra clave. Sin esto no hay motivo para convertir. |
| **Formato principal** | Reel (alcance frío, gancho en vídeo) vs Carrusel (retención por swipe, más educativo). Elige uno para empezar. |
| **Palabra clave** | La que dispara el DM automático. Simple, memorable, única por campaña. |
| **Promesa del gancho** | Qué transformación o respuesta rápida promete el contenido. |
| **Estilo de comunicación** | Educativo / opinión / directo / práctico. Debe encajar con la voz de marca. |
| **Objetivo primario** | Alcance masivo vs captación cualificada — condiciona todo lo demás (ver Paso 6). |

Si el operador ya tiene voz de marca definida (`brand-context/`), léela y alinea el estilo; no inventes tono.

Cuando el objetivo sea "alcance masivo" **y** el producto tenga ticket alto, avisa ya aquí: alcance masivo + palabra clave fácil = base de datos grande y poco cualificada. No es un fallo a arreglar al final; es una decisión de diseño a tomar ahora (filtros en el formulario vs volumen bruto).

### Paso 2 · Estrategia de contenido de alto alcance

El contenido tiene tres etapas y cada una responde a una señal distinta del algoritmo. No las trates como "hacer un vídeo bonito":

- **Hook (0–2 s)** — su único trabajo es frenar el scroll de un desconocido. Sin apelar a autoridad previa ("como experto en…") porque el espectador no te conoce; apela a curiosidad, contradicción o dolor inmediato. Escribe 3 variantes de gancho para que el operador pruebe.
- **Retención** — evita pausas muertas; ritmo visual ágil, micro-curiosidades abiertas que se resuelven más tarde. El objetivo medible es superar el tiempo medio de permanencia (si abandonan en los primeros 3 s, el Hook falla, no la retención).
- **CTA** — una sola acción, sencilla: "comenta [palabra clave]". Cada comentario es una señal de engagement que amplía el alcance **y** el disparador del embudo. No pidas dos cosas a la vez.

Entrega guiones concretos (texto del gancho + esqueleto de retención + frase exacta de CTA), no consejos abstractos. Si el operador tiene la skill `marketing-copywriting` instalada y quiere pulir los guiones, ofrécela como paso siguiente.

### Paso 3 · Arquitectura del embudo

Muestra el recorrido completo como diagrama de texto, y marca la fuga donde ocurre:

```
[ Contenido: Reel / Carrusel ]
        │
        ▼  (el usuario comenta la PALABRA CLAVE)   ← fuga 1: % que ve pero no comenta
[ Disparador automático: n8n / ManyChat ]
        │
        ▼  (DM con el enlace)
[ DM enviado ]
        │
        ▼  (el usuario abre el enlace)             ← fuga 2 (la grande): DM→landing pierde >60%
[ Landing / formulario de captación ]
        │
        ▼  (el usuario introduce datos)            ← fuga 3: fricción del formulario
[ Registro en Supabase / CRM ]
```

Nombrar las fugas en el propio diagrama no es pesimismo: es lo que permite decidir dónde invertir esfuerzo (p. ej. entregar valor dentro del propio DM antes de pedir el clic, para no perder a la mayoría en la fuga 2).

### Paso 4 · Esqueleto técnico

No construyas aquí — define lo justo para que `automation-n8n-builder` y `automation-client-deploy` lo levanten.

**Tabla de leads (Supabase)** — propón un esquema mínimo pero útil:

```sql
create table leads (
  id           uuid primary key default gen_random_uuid(),
  created_at   timestamptz default now(),
  campaign     text,              -- qué campaña/palabra clave lo trajo
  handle       text,              -- usuario de la red social
  nombre       text,
  email        text,
  fuente       text,              -- reel_id / carrusel_id
  cualificacion text,             -- respuesta al filtro del formulario, si lo hay
  estado       text default 'nuevo'  -- nuevo / contactado / cliente / descartado
);
```

Ajusta las columnas al caso (si el objetivo es cualificar, añade las preguntas de filtro como campos).

**Flujo de automatización** — descríbelo como pasos que `automation-n8n-builder` pueda convertir en workflow:

1. **Trigger**: nuevo comentario en el post con la palabra clave (webhook de ManyChat / Instagram Graph API, o polling).
2. **Filtro**: el comentario contiene exactamente la palabra clave.
3. **Acción DM**: enviar mensaje directo con el enlace a la landing (y, si aplica, valor entregado en el propio DM para reducir la fuga 2).
4. **Registro de interacción**: opcional, apuntar el `handle` que pidió el enlace (permite medir C2C y tasa de apertura de DM).
5. **Captura final**: la landing hace `insert` en la tabla `leads` de Supabase al enviar el formulario.
6. **Rama de error**: si el DM no se puede enviar (usuario no sigue, límite de API), registrar el fallo para no perder la señal.

Al terminar el esqueleto, di explícitamente: "El build real lo hace `automation-n8n-builder` (workflow) + `automation-client-deploy` (landing + Supabase). ¿Lo lanzo?".

### Paso 5 · Cuadro de métricas y ciclo de validación

Las métricas se auditan **en orden secuencial**: cada una diagnostica una etapa concreta, y no tiene sentido optimizar una etapa posterior si la anterior sangra. Entrega la tabla con el umbral que dispara la acción:

| Métrica | Qué mide | Señal / umbral |
|---|---|---|
| **Retención temprana (3 s)** | % que no abandona en los primeros 3 s | Abandono alto → el **Hook** falla. Arréglalo antes de nada. |
| **Tiempo de reproducción total** | Si la estructura de retención aguanta | Bajo con Hook bueno → falla la retención media. |
| **Ratio C2C (comment-to-content)** | Cuántos de los que ven ejecutan el CTA | Bajo → CTA poco claro o palabra clave con fricción. |
| **Tasa de apertura en DM** | % que abre el enlace enviado | Baja → el DM no da motivo para clicar (fuga 2). |
| **Tasa de registro final** | Leads que completan el formulario / tráfico a la landing | Baja → fricción del formulario o desalineación oferta↔landing. |

El ciclo es: mide en orden, encuentra la primera métrica que sangra, corrige esa etapa, vuelve a medir. No cambies cinco cosas a la vez o no sabrás qué movió la aguja.

### Paso 6 · Análisis crítico honesto

Cierra siempre con los puntos débiles reales de este embudo — no como advertencia genérica, sino aplicados al caso concreto del operador. Los tres estructurales:

1. **Fricción DM → landing.** El plan asume que muchos comentarios = muchos registros. En la práctica el salto de DM a abrir enlace externo e introducir datos pierde con frecuencia >60–70%. Mitigación: entregar valor dentro del DM y reducir campos del formulario.
2. **Dependencia del algoritmo.** Apoyar la estrategia en "funcionar sin base de seguidores" expone todo el embudo a la volatilidad de la distribución de Reels. Si la prueba inicial del algoritmo se estanca, el embudo se queda sin tráfico y todo lo demás da igual. Mitigación: no depender de un solo formato/plataforma; tener una segunda fuente de tráfico.
3. **Calidad vs. volumen de leads.** Alcance masivo + palabra clave fácil = público amplio y poco cualificado. Si el formulario no filtra, la base se llena de leads de bajo valor comercial. Mitigación: preguntas de cualificación en el formulario, asumiendo que bajan el volumen a cambio de subir el valor.

Esta sección es parte del producto, no un descargo. La honestidad sobre dónde se rompe el embudo es lo que hace el plan accionable.

---

## Plantilla de salida

Usa esta estructura para el documento final:

```markdown
# Embudo de captación — [nicho / campaña]

## 1. Diagnóstico
- Nicho · Público · Oferta · Formato · Palabra clave · Promesa · Estilo · Objetivo

## 2. Estrategia de contenido
### Hook (3 variantes)
### Retención
### CTA

## 3. Arquitectura del embudo
[diagrama con fugas señaladas]

## 4. Esqueleto técnico
### Tabla de leads (Supabase)
### Flujo de automatización (pasos para n8n-builder)

## 5. Cuadro de métricas
[tabla con umbrales de diagnóstico]

## 6. Análisis crítico
1. Fricción DM→landing · 2. Dependencia del algoritmo · 3. Calidad vs volumen

## Siguiente paso
Build: automation-n8n-builder + automation-client-deploy
```

---

## Encadenado con otras skills

- **Antes**: si la petición llega ambigua, `ask-questions-if-underspecified` para cerrar las variables del Paso 1.
- **Contenido**: `marketing-copywriting` para pulir guiones de Hook/CTA; `marketing-brand-voice` para alinear el estilo.
- **Build**: `automation-n8n-builder` (workflow del disparador DM) → `automation-client-deploy` (landing + Supabase en el entorno del cliente).
- **Después**: `marketing-meta-ads-analyzer` si más adelante se quiere amplificar el alcance con pauta pagada en vez de depender solo del algoritmo.
