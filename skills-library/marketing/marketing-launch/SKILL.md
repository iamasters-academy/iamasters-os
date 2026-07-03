---
name: marketing-launch
description: >
  Planifica y ejecuta lanzamientos de producto o de feature: estrategia de fases, canales y Product
  Hunt. Úsala cuando el operador diga "voy a lanzar", "plan de lanzamiento", "launch", "sacar el
  producto", "anunciar una feature nueva", "lanzar en Product Hunt", "cómo hago el go-to-market del
  lanzamiento". NO la uses para el plan de marketing continuo ([[marketing-plan]]), para PR/medios
  ([[marketing-public-relations]]) ni para el pricing/oferta ([[marketing-offers]]/[[marketing-pricing]]).
version: 0.1.0
---

# marketing-launch

> **Adaptación iAmasters OS** — Estructura tomada de `coreyhaines31/marketingskills` (`launch`); cuerpo
> reescrito a la convención del OS (no portado verbatim: la fuente no era accesible en crudo en el
> momento del port). El doc base `.agents/product-marketing.md` = tu `brand-context/` + `context/`
> (crea/actualiza con [[marketing-product-context]]). Las "Related Skills" citadas por nombre pelado
> son aquí `marketing-<nombre>`.

## Principio rector

Las mejores empresas **no lanzan una vez**: lanzan una y otra vez. Un lanzamiento no es un evento de un
día, es una secuencia de fases que construye relación antes, convierte tráfico durante, y educa después.
La regla de oro: **todo tráfico externo se convierte en relación propia** (email/comunidad) — si al
acabar el lanzamiento solo tienes un pico de tráfico y ninguna lista, has fallado.

## Framework ORB — clasifica tus canales

| Tipo | Ejemplos | Qué aporta | Coste |
|---|---|---|---|
| **Owned (propio)** | email, blog, comunidad, la propia app | Valor compuesto en el tiempo; control total | Lento de construir |
| **Rented (alquilado)** | redes sociales, App Store/Play, directorios | Velocidad y alcance | Dependes del algoritmo; no lo controlas |
| **Borrowed (prestado)** | podcasts, influencers, partners, newsletters ajenas | Credibilidad y audiencia ya existente | Requiere relación previa |

Estrategia: **empieza el trabajo en Borrowed semanas antes** (relaciones), amplifica en Rented el día del
lanzamiento, y **convierte todo a Owned** (captura de email) para que el activo quede tuyo.

## Las 5 fases del lanzamiento

1. **Internal launch** — feedback de usuarios amigos/allegados antes de nada. Objetivo: cazar lo roto y lo confuso sin exponerte.
2. **Alpha launch** — validación externa con acceso temprano controlado (signup a lista de espera). Objetivo: primeras señales reales de valor.
3. **Beta launch** — escalar el testing mientras generas expectativa (teasers, "building in public"). Objetivo: buzz + robustez.
4. **Early access** — ampliar base de usuarios y **refinar el mensaje con datos** (qué gancho convierte). Objetivo: encontrar el mensaje que pega.
5. **Full launch** — signups self-serve abiertos en todos los canales a la vez. Objetivo: pico coordinado (Product Hunt, redes, email, partners).

Cada transición es una compuerta: no pases de fase si la anterior no dio la señal que buscabas.

## Product Hunt (si aplica)

El éxito en Product Hunt **no es visibilidad, es preparación**:
- **Antes**: avisa a tu red con días de antelación, ten hunter/assets listos (galería, primer comentario del maker, GIF), programa el lanzamiento al inicio del día PT.
- **Durante**: engagement en tiempo real — responde cada comentario, no compres upvotes (penaliza).
- **Después**: **convierte** el tráfico del día en email/trial; un pico sin captura se evapora en 48h.

## Checklist de lanzamiento

- [ ] Oferta y pricing cerrados ([[marketing-offers]] / [[marketing-pricing]]).
- [ ] Trabajo de canales Borrowed empezado con semanas de antelación.
- [ ] Captura de email en TODO punto de tráfico externo ([[marketing-lead-magnets]] / [[marketing-popups]]).
- [ ] Secuencia de bienvenida/onboarding lista para educar tras el alta ([[marketing-email-sequence]] / [[marketing-onboarding]]).
- [ ] Assets de anuncio por canal ([[marketing-social]] / [[marketing-ad-creative]] / [[marketing-image]]).
- [ ] Distribución de amplificación: PR ([[marketing-public-relations]]), directorios ([[marketing-directory-submissions]]), partners ([[marketing-co-marketing]]).
- [ ] Métricas y tracking del lanzamiento listos ([[marketing-analytics]]).
- [ ] Plan de momentum post-lanzamiento: anuncios de feature recurrentes (vuelve a lanzar).

## Skills relacionadas

Cadena de lanzamiento: [[marketing-plan]] → [[marketing-offers]]/[[marketing-pricing]] → **marketing-launch**
→ [[marketing-public-relations]] + [[marketing-directory-submissions]] + [[marketing-co-marketing]] → [[marketing-social]].
Para el momentum continuo tras el lanzamiento, [[automation-loop-engine]] (lente marketing).
