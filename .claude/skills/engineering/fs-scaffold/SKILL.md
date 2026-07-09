---
name: fs-scaffold
description: Scaffolding profesional para proyectos de software. Arranca proyectos bien hechos en una conversación: 3 modos (nuevo/adoptar/mantener), 240+ piezas internas, regla de oro specs→tests→código
category: engineering
tags: [scaffolding, project-setup, quality-gates, cross-tool, tdd, documentation]
author: Fernando Montero <fernando@fersora.com>
company: Fersora Solutions SL
source: https://fersora.com
license: Commercial use with attribution
version: 1.0.0
---

# fs-scaffold — Scaffolding Profesional de Software

**Autor:** Fernando Montero (Fersora Solutions SL)  
**Presentación:** Café Camaleónico, 18 de mayo de 2026  
**Contacto:** info@fersora.com · https://fersora.com

---

## Qué es fs-scaffold

fs-scaffold es una skill de ingeniería de software que arranca proyectos profesionales bien hechos en una sola conversación. Resuelve el problema de perder días en configurar tecnologías, reglas de calidad, documentación y colaboración multi-IA cada vez que empiezas algo nuevo.

**La propuesta:** Una sola herramienta que monta el proyecto siempre igual, con todo lo bueno desde el primer minuto, y capaz de recuperarse si algo se tuerce.

---

## Los 3 modos de operación

### Modo 1: Empezar uno nuevo
Arrancar un proyecto desde cero. Le dices qué quieres construir y fs-scaffold lo deja montado:
- Estructura de carpetas
- Reglas de calidad
- Plantillas
- Todo listo para programar la primera funcionalidad

### Modo 2: Adoptar uno viejo
Tienes un proyecto antiguo sin método. fs-scaffold:
1. Lo respeta entero
2. Le inyecta el armazón nuevo encima (sin tocar código de usuario)
3. Guarda copia de seguridad por si acaso

### Modo 3: Mantener uno vivo
Proyecto bien montado pero armazón anticuado. fs-scaffold:
1. Detecta qué piezas renovar
2. Las renueva
3. Deja todo al día

---

## Cómo trabaja (pipeline)

Cuando pides un proyecto nuevo, esto es lo que pasa:

1. **Dices lo que quieres** (lenguaje natural, no técnico)
2. **fs-scaffold te entrevista** — una pregunta cada vez, solo lo que no sabe
3. **Te enseña el plan completo** antes de tocar nada — tú dices "adelante", "cambia esto" o "cancela"
4. **Trabaja en un sitio aparte** — si algo va mal, lo descarta y deja el ordenador como estaba
5. **Mueve todo de golpe** — un solo movimiento, todo o nada
6. **Primer registro en historial** — puedes volver atrás cuando quieras
7. **Te entrega el proyecto** con lista de siguientes pasos

---

## Qué deja montado en el proyecto

Todo lo que normalmente configurarías a mano, siempre igual:

- **Instrucciones únicas para todas las IAs** — un solo sitio con las reglas del proyecto
- **Reglas de calidad que se aplican solas** — cada cambio se comprueba automáticamente
- **Avisos de seguridad antes de subir** — detecta y bloquea secretos/contraseñas
- **Plantillas para funcionalidades nuevas** — empiezas desde plantilla, no desde cero
- **Catálogo de skills auxiliares verificadas** — herramientas con sello de origen
- **Documentación viva del proyecto** — la parte que cambia rara vez, se actualiza sola

---

## La regla de oro: escribir antes de programar

Esta es la parte que cambia la forma de trabajar para siempre.

**Lo normal:** Programar a lo loco y luego comprobar si funciona → código mal, incomprensible, se rompe.

**fs-scaffold:** Le da la vuelta. Antes de tocar código:

### El ciclo de una funcionalidad nueva

1. **Cuento la idea** — Una IA me entrevista hasta que está clara
2. **Otra IA escribe la especificación** — Qué hace, qué casos cubre, qué pasa si falla
3. **Otra IA escribe los tests primero** — Las pruebas que el código tendrá que pasar
4. **Otra IA escribe el código** — Solo el necesario para que los tests pasen
5. **Otra IA hace revisión crítica** — Busca fallos, agujeros, casos no cubiertos (despiadada)
6. **Si pasa la revisión → archivada como completada** — Si no, vuelta al paso correspondiente

> *"El código siempre cumple lo que prometió. Los tests lo demuestran. Una IA crítica busca fallos antes de que lleguen a producción."*

---

## Si algo falla a la mitad, no pasa nada

fs-scaffold tiene resuelto sin que te enteres:

- **Apunta cada cosa que toca** — registro interno de cada archivo
- **Si crashea a la mitad, deshace todo** — lee registro y devuelve estado anterior
- **Cierras ventana, vuelves y sigue** — sabe exactamente dónde se quedó
- **Dos sesiones a la vez: una espera** — no se pisan cambios
- **Antes de tocar nada, enseña el plan** — revisas lista, ejecutas solo si confirmas
- **Catálogo con sello verificado** — rechaza skills falsas automáticamente

---

## Funciona con todas las IAs, no solo una

El proyecto se monta con **instrucciones únicas** que cualquier herramienta de IA puede leer.

Hoy Claude, mañana OpenAI, pasado mañana las dos a la vez. Da igual. El proyecto les habla a todas en el mismo idioma:

- Mismas reglas
- Mismas plantillas
- Mismo método

**Beneficio:** El proyecto no queda atado a ninguna herramienta. Si aparece algo mejor, se adapta sin reescribir.

---

## Cómo se construyó fs-scaffold

Resultado de varias semanas de trabajo metódico:

- **21 fases ordenadas** — cada fase con objetivo y criterios de aceptación
- **Revisión crítica por fase** — sin pasar revisión, no se avanza
- **200+ mejoras incorporadas** — durante el propio proceso de construcción
- **Revisión cruzada final** — dos modelos críticos en paralelo

Disciplina extrema: cada fallo, agujero y caso no cubierto se corrigió antes de seguir.

---

## Para los curiosos: 240+ piezas dentro

Ver [references/profundidad.md](references/profundidad.md) para detalle completo de:

- Documentación interna canónica (9 fichas)
- Datos firmados de seguridad (3 ficheros)
- Motor del modo "empezar uno nuevo" (11 piezas)
- Motor del modo "adoptar uno viejo" (11 piezas)
- Motor del modo "mantener uno vivo" (7 piezas)
- Armazón común (~60 ficheros)
- Plantillas por tipo de proyecto (5 tipos · ~70 ficheros)
- Suite de comprobaciones internas (~50 ficheros)
- Utilidades de compatibilidad (11 piezas)
- Plan de construcción (3 ficheros centrales)

---

## Referencias

- [manifesto.md](references/manifesto.md) — El problema que resuelve
- [tres-modos.md](references/tres-modos.md) — Explicación detallada de los 3 modos
- [pipeline.md](references/pipeline.md) — 7 pasos de conversación
- [contenido.md](references/contenido.md) — Checklist completo de entregables
- [regla-oro.md](references/regla-oro.md) — Escribir antes de programar
- [fallos.md](references/fallos.md) — Recuperación ante errores
- [cross-tool.md](references/cross-tool.md) — Multi-IA
- [construccion.md](references/construccion.md) — 21 fases + revisión
- [profundidad.md](references/profundidad.md) — 240+ piezas detalladas

---

## Créditos y licencia

**Autoría:** Fernando Montero, Fersora Solutions SL  
**Contacto:** info@fersora.com · https://fersora.com  
**Origen:** Presentación Café Camaleónico, 18 de mayo de 2026

**Licencia de uso:** Esta skill se usa con permiso del autor. Para uso comercial o redistribución, contactar con Fernando Montero.

**Reconocimiento:** Al usar esta skill, mantener esta atribución visible en SKILL.md y cualquier derivado.

---

## Invocación

```bash
/fs-scaffold
```

O vía skill-router seleccionando "fs-scaffold" en la categoría engineering.
