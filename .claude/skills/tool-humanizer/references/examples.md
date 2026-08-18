# Ejemplos tool-humanizer

## Ejemplo 1 · LinkedIn post

### Input (score 4.0)

> 🚀 In today's fast-paced world, AI is fundamentally transforming how businesses operate.
>
> It's not just about automation — it's about empowering teams to leverage cutting-edge technology and unlock unprecedented value.
>
> Here are 3 ways to navigate this shift:
>
> 1. **Embrace innovation** — adopt new tools that streamline workflows
> 2. **Foster collaboration** — break down silos across departments
> 3. **Elevate your team** — invest in continuous learning and upskilling
>
> Remember: it's not the technology, it's the mindset.
>
> What's your take? Drop a comment below! 💡✨ #AI #Innovation #FutureOfWork #Transformation #Leadership

### Análisis

| Detector | Hits | Penalty |
|---|---:|---:|
| Frase muleta "in today's fast-paced world" | 1 | -1.0 |
| Verbo sobreusado "leverage", "empower", "unlock", "streamline", "elevate", "navigate", "foster" | 7 | -3.5 |
| Em-dash overuse | 3 | -2.0 |
| Regla de 3 abusada | 2 (lista + cierre) | -1.5 |
| Negación-afirmación "it's not X, it's Y" | 2 | -1.0 |
| Triple emoji | 1 (🚀💡✨) | -2.0 |
| Hashtags excesivos | 5 | -1.0 |
| Conclusión obvia | 1 ("Remember...") | -1.0 |

**Score: 0/10** (clamp). Output: completamente AI.

### Versión humanizada

> Llevo 3 años montando IA en empresas y he visto patrón claro:
>
> Las que se obsesionan con la herramienta, fracasan.
> Las que se obsesionan con el problema, ganan.
>
> Lo que hace que un proyecto IA aterrice no es Claude, n8n o ChatGPT. Es alguien dentro de la empresa que conozca el dolor real y empuje desde dentro.
>
> Sin esa persona, ninguna herramienta sobrevive 6 meses.
>
> Lo que sí cambió en mis últimos 5 proyectos: dedicar 2 semanas a pelear el "qué automatizamos" antes de tocar "con qué". Nadie quiere hacerlo, pero ahorra meses después.
>
> ¿Tú cómo decides qué automatizar primero?

### Cambios principales

- Eliminado emoji al inicio
- "In today's fast-paced world" → contexto personal específico ("Llevo 3 años...")
- Verbos abstractos → verbos concretos ("aterrice", "pelear", "ahorra")
- Em-dashes → puntos
- Regla de 3 → estructura de contraste 2 puntos
- Negación-afirmación reducida a 1 (sigue siendo retórica útil cuando no se abusa)
- Triple emoji → 0 emojis
- Hashtags → 0
- "Remember: ..." → pregunta abierta al final
- Añadidos números concretos ("3 años", "5 proyectos", "2 semanas", "6 meses")

**Score post-rewrite: 9.0/10** ✓

---

## Ejemplo 2 · Email de propuesta a cliente

### Input (score 5.5)

> Estimado Juan,
>
> Espero que este email te encuentre bien. Me complace presentarte una propuesta integral diseñada para transformar tus procesos operativos y desbloquear todo el potencial de tu equipo.
>
> Como hemos discutido, en el mundo actual de la transformación digital, es fundamental aprovechar las herramientas de IA de vanguardia para optimizar workflows, fomentar la colaboración y elevar la productividad de manera holística.
>
> Nuestra propuesta abarca 3 pilares fundamentales:
>
> - **Implementación robusta** — desplegamos una solución sin fisuras
> - **Capacitación integral** — formamos a tu equipo de manera comprehensiva
> - **Soporte continuo** — acompañamos en cada paso del journey
>
> Quedo a tu disposición para resolver cualquier duda.
>
> Un saludo cordial,
> [Nombre]

### Análisis

| Detector | Hits | Penalty |
|---|---:|---:|
| Frase muleta "espero que este email te encuentre bien" | 1 | -1.0 |
| "Me complace presentarte" / "Me complace" | 1 | -0.5 |
| Frase muleta "en el mundo actual" | 1 | -1.0 |
| Verbo sobreusado: aprovechar, optimizar, fomentar, elevar, transformar, desbloquear | 6 | -3.0 |
| Adjetivos vacíos: integral (x3), holístico, robusto, sin fisuras, comprehensiva, continuo, vanguardia | 9 | -4.5 |
| Em-dash | 3 | -2.0 |
| Regla de 3 (3 pilares) | 1 | -0.5 |

**Score: 0/10** (slop muy típico de propuesta).

### Versión humanizada

> Hola Juan,
>
> Tras nuestra reunión del martes, he aterrizado la propuesta. Te la resumo en lo que importa:
>
> **Qué te entrego**
> 1. Implementación del sistema de IA para tu proceso de admisión (4 semanas)
> 2. Formación a tu equipo de 5 personas (2 sesiones de 2h)
> 3. Soporte de 30 días post-go-live (Slack + 1 llamada semanal)
>
> **Qué no incluye** (para que no haya sorpresas):
> - Migración de datos antiguos (presupuesto aparte si lo necesitas)
> - Integración con tu CRM actual (lo evaluamos en semana 2)
>
> **Inversión**: 8.500€ + IVA. Pagable 50% al inicio + 50% al go-live.
>
> Si te encaja, te paso el contrato esta semana. Si tienes dudas, responde a este email o llámame al 600 123 456.
>
> Un abrazo,
> [Nombre]

### Cambios principales

- Saludo formal vacío → directo, contextualizado ("tras nuestra reunión del martes")
- Lenguaje abstracto → entregables concretos con tiempos
- Añadido "qué no incluye" (humano honesto, no lo haría AI por defecto)
- Inversión y forma de pago explícita (no "ROI demostrado y propuesta competitiva")
- Cierre con opciones reales ("contrato esta semana" o "responde / llámame al X")
- Sin frases muleta de cierre formal ("quedo a tu disposición")

**Score post-rewrite: 9.5/10** ✓

---

## Ejemplo 3 · Blog post intro

### Input (score 6.0)

> ## How AI is Reshaping the Modern Workplace
>
> In today's rapidly evolving digital landscape, organizations are increasingly recognizing the transformative power of artificial intelligence. As we navigate this paradigm shift, it's becoming crystal clear that AI is not merely a buzzword — it's a fundamental force that's reshaping how we work, collaborate, and innovate.
>
> In this post, we'll delve into 3 key areas where AI is making significant impact:

### Análisis

| Detector | Hits | Penalty |
|---|---:|---:|
| Frase muleta "in today's rapidly evolving" | 1 | -1.0 |
| Frase muleta "delve into" | 1 | -1.0 |
| Adjetivos vacíos: transformative, evolving, modern | 3 | -1.5 |
| Verbos sobreusados: navigate, reshape | 2 | -1.0 |
| Negación-afirmación "not merely a buzzword" | 1 | -0.5 |

**Score: 5/10**.

### Versión humanizada

> ## Cómo está cambiando el trabajo con IA (3 patrones que veo en clientes reales)
>
> Llevo 18 meses implementando IA en pequeñas empresas españolas: gestorías, agencias, consultoras de 5-30 personas.
>
> No vengo a contarte que la IA es revolucionaria. Vengo a contarte qué funciona y qué no, basado en 23 proyectos que vi de cerca.
>
> Lo que sí está cambiando: 3 patrones concretos que se repiten.
>
> 1. ...

### Cambios principales

- Headline genérico → headline con número y promesa específica
- "In today's evolving landscape" → contexto personal ("18 meses... 23 proyectos")
- Promesa abstracta → promesa específica (qué funciona y qué no)
- Eliminada la frase "not merely a buzzword"
- Tono autoral establecido en frase 1 ("llevo, vi, vengo")

**Score post-rewrite: 9.0/10** ✓

---

## Notas para el detector

- En español, "delve into" no aparece pero sí "profundizar en", "adentrarse en"
- "Holístico" es un tell castellano sin equivalente directo en inglés (el término existe pero AI lo sobreusa solo en español)
- "Aprovechar el potencial" = literal del "leverage potential" — uno de los más obvios
- Los emojis 🚀💡✨🔥 al inicio o final son tells fuertes en LinkedIn ES
