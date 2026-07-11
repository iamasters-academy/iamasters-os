# Sitio web virtuosopro.digital — de landing GHL a sitio SEO/GEO/AEO

> Spec de diseño. Aprobado por Héctor el 2026-07-10 en sesión de brainstorming.

## Contexto

`virtuosopro.digital` y sus nichos (`restaurantes.`, `hotel.`, `colegios.`, `bio.`) viven hoy como Sites/Funnels dentro de GoHighLevel — sin código propio, sin control real de SEO/GEO/AEO, y comunicando solo una fracción de las soluciones que Virtuoso IA ya tiene construidas (ver `projects/Virtuoso_Agency/virtuoso_portafolio/INVENTARIO-SOLUCIONES.md`, 30+ soluciones catalogadas).

**Problema:** el sitio actual no comunica lo que Virtuoso ya construyó. Varias soluciones con caso real y métricas verificadas (restaurantes/Al Bat, colegios/Miss Carmen) compiten por atención con soluciones sin evidencia, y capacidades transversales (reputación con IA, sitios SEO/GEO/AEO) no tienen página propia pese a tener ficha comercial ya redactada.

**Objetivo:** reconstruir como sitio propio (Next.js/Vercel, mismo patrón que `cct-sitio-web`), consolidando los nichos hoy repartidos en subdominios bajo un solo dominio con rutas, y ampliando la cobertura de soluciones — sin perder el diseño de marca actual, que Héctor aprobó explícitamente.

## Decisión de arquitectura: Opción C (híbrida)

Se evaluaron tres opciones:
- **A — por producto/agente** (como hoy): un visitante que busca "responder reseñas con IA" no sabe que eso vive dentro de "MesaLlena".
- **B — por nicho/industria**: replica el patrón que ya funciona en las landings vivas (restaurantes., hoteles., colegios.), pero no da lugar propio a capacidades transversales (reputación, sitios web) que no son de un solo nicho.
- **C — híbrida (elegida)**: nav primario por nicho (aprovecha lo ya validado) + capa de páginas por capacidad transversal, basada en la taxonomía de capacidades del inventario. Mejor para GEO: un motor de IA que responde "¿quién automatiza reseñas con IA en México?" cita mejor una página dedicada a esa capacidad que una mención dentro de la página de un producto con nombre propio.

**Consolidación de capacidades → páginas:** el inventario define 12 capacidades; el sitio las consolida en 7 páginas de `/soluciones/` para no fragmentar contenido delgado:
- *Agentes de voz IA* y *Calificación y nurturing de leads* → dentro de `/soluciones/agentes-whatsapp` (mismo pitch: agentes conversacionales que venden)
- *Admisiones educativas con IA* → vive en `/colegios` (es de un solo nicho, no transversal)
- *Auditoría y diagnóstico gratuito* → son las páginas `/diagnostico` y `/sesion-crecimiento`
- *Consultoría de calidad y procesos* → fuera del sitio Virtuoso (pertenece a CCT/ccturistica.com)

## Mapa de sitio

```
/                              Home
/restaurantes                  Nicho — MesaLlena + caso Al Bat Sport Bar
/hoteles                       Nicho — MACA
/colegios                      Nicho — Admisiones IA + caso Colegio Boston (Miss Carmen)
/inmobiliarias                 Nicho — SofIA (lanza con versión corta; se reemplaza con la landing de Codex al estar lista)
/soluciones                    Índice de capacidades transversales
/soluciones/reputacion-ia
/soluciones/sitios-web-seo-geo-aeo
/soluciones/automatizacion-financiera
/soluciones/agentes-whatsapp
/soluciones/menus-digitales
/soluciones/sistema-operativo-gestion   → tarjeta puente a sistemat.app (no duplica contenido)
/soluciones/gestion-sustentabilidad     → tarjeta puente a innovarse.com.mx (no duplica contenido)
/casos-de-exito                 Hub de casos (Al Bat, Colegio Boston, Bistro Aroma, Estudio Mezcal, Umbrella Shield)
/casos-de-exito/[slug]
/diagnostico                    Diagnóstico gratuito de 60 segundos (herramienta existente, migrar widget)
/sesion-crecimiento             Growth Session (servicio existente, migrar copy)
/contacto
/aviso-de-privacidad            Obligatorio (LFPDPPP): el diagnóstico guarda datos de prospectos en Airtable
```

**Nota sobre `/diagnostico`:** el widget existente llama a `virtuoso-api.vercel.app/api/diagnostico`, que desde 2026-07-10 **registra cada consulta en Airtable** (base "Lead Management", tabla `Diagnosticos_Virtuoso`) además de responder al usuario. La migración reutiliza ese backend tal cual — el CORS del API ya permite el dominio raíz. No reconstruir la lógica; solo re-empaquetar el widget como componente React.

**Sistema T y ECOSKOR no llevan página completa aquí** — ya tienen sitio comercial propio (`sistemat.app`, `innovarse.com.mx`). Su presencia en `virtuosopro.digital` es una tarjeta resumen + enlace de salida, para no duplicar ni desactualizar contenido en dos lugares.

**Cobertura completa desde el lanzamiento, profundidad variable:** el nav y el sitemap incluyen todas las secciones desde el día uno — nada se oculta hasta tener "suficiente" contenido. Restaurantes, Colegios, Reputación IA y Sitios SEO/GEO/AEO llevan página completa con caso real porque ya existe el contenido. Hoteles necesita copy nuevo o migrado de GHL. Inmobiliarias, Automatización financiera y Menús digitales salen con una versión honesta y corta (problema → promesa → cómo se entrega, sin métricas inventadas) y se enriquecen cuando haya caso real — mismo criterio de honestidad que ya usa `PORTAFOLIO.md` con sus estados 🟢/🟡.

## Plantillas de página (componentes reutilizables)

- **Home** — hero + selector de nicho en tarjetas + ticker de métricas agregadas (patrón ya validado en `restaurantes.virtuosopro.digital`) + capacidades destacadas + CTA doble (Diagnóstico / Sesión de Crecimiento).
- **Página de nicho** — problema específico del nicho → caso de éxito con métricas (si existe) → cómo funciona (4 pasos) → capacidades relacionadas (enlaza a `/soluciones/x`) → CTA.
- **Página de capacidad** — qué es → qué nichos ya la usan (con casos reales) → cómo se entrega → CTA.
- **Caso de éxito** — mismo patrón antes/después validado en el caso Al Bat: badge de caso real, métricas destacadas, sistema implementado, testimonio si existe.

Componentes compartidos: Hero, MetricTicker, CaseStudyCard, HowItWorksSteps, CTASection, NicheSelectorGrid — construidos una vez, reutilizados en todas las páginas de nicho/capacidad para mantener consistencia visual sin duplicar código.

## Stack y ubicación del proyecto

- **Repo:** `projects/Virtuoso_Agency/virtuoso-web/` (nuevo, junto a `virtuoso-api`)
- **Stack:** Next.js (App Router) + Tailwind CSS + TypeScript, desplegado en Vercel — mismas versiones que `cct-sitio-web` (Next 16 / Tailwind 4), que es la referencia probada
- **Sin CMS ni base de datos:** contenido en el propio código (constantes/MDX), igual que CCT — el catálogo cambia poco y así se evita infraestructura extra

## Capa técnica SEO/GEO/AEO

Mismo patrón que `cct-sitio-web` (ya en producción, referencia probada):
- `sitemap.xml` generado automáticamente desde las rutas
- `llms.txt` en la raíz
- JSON-LD: `Organization` en el layout raíz, `Service` en cada página de nicho/capacidad
- Metadata única (title/description) por ruta, generada desde el contenido de cada página
- Schema `FAQPage` en páginas con preguntas frecuentes (home, páginas de capacidad)
- Open Graph images por sección

## Contenido — qué ya existe vs qué falta escribir

| Página | Estado del contenido |
|---|---|
| Restaurantes | Completo — migrar de `landing-restaurantes-preview/index.html` |
| Colegios | Caso y métricas ya extraídos (agente Miss Carmen, 38% mejor conversión) — falta formatear a componentes |
| Reputación IA | Ficha comercial ya redactada en `INVENTARIO-SOLUCIONES.md` |
| Sitios SEO/GEO/AEO | Ficha comercial ya redactada en `INVENTARIO-SOLUCIONES.md` |
| Hoteles | Solo se confirmó el título de la página actual (`hotel.virtuosopro.digital`) — falta copy completo, migrar de GHL o reescribir |
| Inmobiliarias | Versión corta al lanzar (base: ficha SofIA en `PORTAFOLIO.md`, ya enriquecida con sync nocturno/WhatsApp/CRM) — se reemplaza con la landing de Codex cuando esté lista |
| Automatización financiera, Menús digitales | Por escribir — versión corta honesta, sin métricas inventadas |

## Diseño visual

Se mantiene la identidad de marca ya definida en `IDENTIDAD.md` — no se rediseña, se re-implementa en código:
- Colores: Azul Fuerte `#1a1a2e` (principal), Azul `#1e0a80` (secundario), Celeste `#5CD4E6` (acento frío), Amarillo `#dee800` (acento cálido), Blanco `#ffffff` (base)
- Tipografía: Poppins ExtraBold (títulos), Raleway Bold (cuerpo)
- Tono: profesional, orientado a resultados, sin tecnicismos innecesarios, español México

## Fuera de alcance de este spec

- Migración de subdominios existentes (redirects 301) — se planea por separado una vez el sitio nuevo esté listo, para no bloquear la construcción
- Blog / contenido evergreen — candidato a fase 2 si se necesita más profundidad GEO
- Página de Inmobiliarias completa — bloqueada por la landing en desarrollo en Codex
