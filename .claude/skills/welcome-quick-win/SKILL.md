---
name: welcome-quick-win
description: Genera el primer entregable del usuario en 5 minutos tras el onboarding. Pide su URL pública (LinkedIn / web), ejecuta análisis de posicionamiento, produce 3 hooks LinkedIn y plan de 3 acciones para la semana, todo empaquetado en HTML autocontenido y compartible. Se invoca automáticamente al final del onboarding wizard o manualmente vía `/welcome`. Es la skill que entrega el "primer wow" del OS.
---

# welcome-quick-win

## Cuándo se invoca

- Automáticamente al terminar `meta-onboarding-wizard` (si el flag `welcomeCompleted: false` en `~/.claude/skills/_operator-state.json`)
- Manualmente cuando el usuario ejecuta el slash command `/welcome`
- Cuando el usuario pide explícitamente: "dame mi primer entregable", "prueba el sistema", "haz una primera tarea de ejemplo"

## Por qué importa

Esta es la skill que convierte "acabo de instalar el sistema" en "tengo algo concreto en pantalla, bonito, que se puede compartir". Es el momento crítico de adopción — el avatar no técnico decide aquí si el sistema le sirve o si lo abandona. **Tu trabajo es entregar valor real en 5 minutos sin fricción.**

## Process

### Paso 1 · Pedir la URL pública

Mensaje exacto al usuario (castellano, directo, cálido):

```
Vamos a hacer tu primer entregable. Necesito una URL pública tuya
donde se vea qué haces profesionalmente. Puede ser:

• Tu LinkedIn (https://linkedin.com/in/tu-perfil)
• Tu web personal o de tu negocio
• Un link a tu portfolio, About me, o página de servicios

Pégame UNA URL.
```

Si el usuario responde "no tengo nada público":

- Pídele un párrafo: "Cuéntame en 3-5 frases qué haces, para quién, y cuál es tu diferencial."
- Salta al Paso 3 con ese texto como input directo.

### Paso 2 · Extraer contenido de la URL

Invoca `tool-firecrawl-scraper` con la URL recibida.

**Si falla** (sin API key, dominio bloqueado, timeout):
- Reporta al usuario: "No he podido leer tu URL automáticamente."
- Pídele que pegue manualmente: "Copia 2-3 párrafos clave de tu página (About, servicios, descripción)."
- Continúa con ese texto como input.

**Si tiene éxito**: extrae:
- Título / headline / hero text
- Sección "About" o equivalente
- Servicios o productos
- Tono general (formal / cercano / divulgativo)

Guarda el contenido scrapeado en variable temporal `scraped_content` para los siguientes pasos.

### Paso 3 · Análisis de posicionamiento

Invoca `marketing-positioning` con `scraped_content` como input.

Espera que te devuelva al menos:
- **Quién eres** (1 frase)
- **Para quién trabajas** (ICP en 1 frase)
- **Qué problema resuelves** (1 frase)
- **Por qué tú vs otros** (diferencial en 1-2 frases)
- **Score de claridad de posicionamiento** (1-10) con 1-2 oportunidades de mejora

Si `marketing-positioning` falla o devuelve algo incompleto, genera tú mismo un análisis de posicionamiento básico siguiendo esa estructura, basado en `scraped_content`.

### Paso 4 · Generar 3 hooks LinkedIn

Basado en el análisis de posicionamiento + `scraped_content`, genera 3 hooks de post LinkedIn que el usuario podría publicar esta semana.

Cada hook debe:
- **Empezar con frase corta** (≤12 palabras) que pare el scroll
- **Conectar con un dolor del ICP** (no "yo yo yo")
- **Tener un POV claro** (opinión, no descripción genérica)
- **Estar en castellano natural**, sin AI-tells (em-dashes raros, "navegar", "abrazar", "desbloquear")
- Longitud máxima del hook: 2 líneas (no el post completo, solo el gancho)

Si existe `brand-context/voice/voice-profile.md` cárgalo y aplica el tono. Si no existe, usa registro divulgativo neutral y advierte al usuario que podrá personalizarlo después con `marketing-brand-voice`.

### Paso 5 · Plan de la semana — 3 acciones concretas

Genera 3 acciones específicas que el usuario puede hacer esta semana basadas en lo que viste en el análisis. Formato:

| # | Acción | Tiempo | Output esperado |
|---:|---|---|---|
| 1 | (verbo + qué hacer) | (15 min / 30 min / 1h / 2h) | (qué tendrá al terminar) |
| 2 | ... | ... | ... |
| 3 | ... | ... | ... |

Las acciones deben ser:
- **Ejecutables sin contratar a nadie** (el usuario las hace solo)
- **Con output verificable** (no "reflexionar sobre X")
- **Conectadas al diagnóstico de posicionamiento** (atacan las oportunidades detectadas)

### Paso 6 · Empaquetar todo en HTML autocontenido

Si la skill `tool-visual-explainer` está disponible en el repo, invócala con un brief del contenido. Si no, genera HTML inline siguiendo este esqueleto:

- HTML5 válido, una sola página, sin dependencias externas (no CDN)
- CSS embebido en `<style>` — sin JS (compartible por WhatsApp)
- Tipografía: system stack (`-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif`)
- Paleta sobria: blanco/gris muy claro de fondo, negro/gris oscuro texto, 1 color acento (naranja `#ff8c42` que es la paleta iAmasters Academy)
- Estructura visual:
  1. Hero con título "Tu primer entregable · iAmasters OS" + fecha
  2. Bloque "Tu posicionamiento ahora mismo" con el análisis
  3. Bloque "3 hooks LinkedIn para esta semana"
  4. Bloque "Plan de los próximos 7 días" (la tabla)
  5. Footer pequeño: "Generado por iAmasters OS · [iamastersacademy.com](https://iamastersacademy.com)"

El HTML debe verse **bonito en móvil** (max-width responsive, padding generoso) porque es probable que se comparta por WhatsApp.

Guarda en: `projects/welcome/<YYYY-MM-DD>-tu-primer-entregable.html`

### Paso 7 · Mensaje final al usuario

Tras guardar el archivo, muestra al usuario:

```
🎉 Tu primer entregable está listo:
projects/welcome/<YYYY-MM-DD>-tu-primer-entregable.html

Ábrelo en tu navegador. Es totalmente compartible — pégalo en
WhatsApp o en la comunidad iAmasters Skool si te ha gustado.

¿Qué hacemos ahora?

  1. Configurar tu Brand Voice completo (10 min más, recomendado)
  2. Ejecutar otra skill (te sugiero `marketing-copywriting`)
  3. Cerrar sesión por hoy con `/wrap-up`
```

Espera respuesta del usuario antes de hacer nada más.

### Paso 8 · Marcar como completado y aprender

1. Edita `~/.claude/skills/_operator-state.json` y pon `welcomeCompleted: true` (para que no se vuelva a disparar automático).
2. Append en `context/learnings.md` bajo `## welcome-quick-win`:
   ```
   - <fecha>: completado para <nombre del usuario>. URL usada: <url>.
     Score posicionamiento inicial: <X>/10.
   ```
3. Si la skill detectó algo notable (URL muy técnica, ICP poco definido, tono incoherente), propón en wrap-up un proyecto siguiente que ataque ese gap.

## Outputs

- `projects/welcome/<YYYY-MM-DD>-tu-primer-entregable.html` — entregable compartible
- Update en `~/.claude/skills/_operator-state.json` (`welcomeCompleted: true`)
- Append en `context/learnings.md`

## Skills que llama

- **`tool-firecrawl-scraper`** — para extraer contenido de la URL pública (Paso 2)
- **`marketing-positioning`** — para el análisis de posicionamiento (Paso 3)
- **`tool-visual-explainer`** (si disponible) — para empaquetar HTML (Paso 6); fallback HTML inline
- **`tool-output-verifier`** (opcional) — para verificar quality del HTML antes de entregar; si no se detecta AI-slop en hooks LinkedIn, omitir

## Edge cases

- **Sin URL pública**: pedir párrafo descriptivo, saltar Paso 2.
- **Firecrawl sin API key o falla**: pedir al usuario que pegue contenido manualmente.
- **LinkedIn rechaza scraping (robots.txt o redirección a login)**: pedir export manual del perfil o párrafo descriptivo.
- **`marketing-positioning` no disponible**: hacer análisis tú mismo siguiendo la estructura del Paso 3.
- **`tool-visual-explainer` no instalada**: generar HTML inline (esqueleto del Paso 6).
- **Sin `brand-context/voice/voice-profile.md`**: usar registro divulgativo neutral + advertencia al usuario.
- **Usuario tarda mucho en responder al Paso 1 (>2 min sin respuesta)**: NO insistir, esperar.
- **Plan Anthropic Free**: probable que la skill agote contexto. Detectar antes y advertir: "Esta skill funciona mejor con Pro/Max. ¿Sigues o lo dejamos?"

## Examples

Ver `references/examples.md` para 2 ejemplos completos:
1. Usuario freelancer con LinkedIn público (caso ideal)
2. Usuario empresario sin web propia (fallback párrafo descriptivo)

## Notas de diseño

- Esta skill es **el momento de la verdad** del OS. Si falla, el usuario abandona. Por eso tiene fallbacks en cada paso.
- El HTML output es deliberadamente compartible (sin JS, móvil-first) — convierte el output personal en objeto social que circula por la comunidad.
- No se invoca a `tool-output-verifier` por defecto para no añadir tiempo al primer wow; si el usuario lo pide después, sí.
- Si el usuario tiene Brand Voice ya configurado, los hooks LinkedIn se generan en su voz; si no, en voz neutral con advertencia.
