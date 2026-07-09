# La Regla de Oro: Escribir Antes de Programar

Esta es la parte que cambia la forma de trabajar para siempre.

---

## El problema normal

Lo normal en software es ponerse a programar a lo loco y luego comprobar a ver si funciona.

Eso produce:
- Código que va mal
- No se entiende a los tres meses
- Se rompe en sitios raros

---

## La solución: fs-scaffold le da la vuelta

Antes de tocar una sola línea de código, hay que escribir **qué tiene que hacer**.

Y eso lo hacen **varias IAs en cadena**, cada una con un rol distinto.

---

## El ciclo de una funcionalidad nueva

### 1. Cuento la idea
Una IA me entrevista **pregunta por pregunta** hasta que la idea está clara del todo.

### 2. Otra IA escribe la especificación
- Qué tiene que hacer
- Qué casos cubre
- Qué pasa si algo va mal

Todo escrito, en cristiano.

### 3. Otra IA escribe los tests primero
Las pruebas que el código tendrá que pasar después.

**Esto es muy raro pero es lo que cambia el juego.**

### 4. Otra IA escribe el código
Solo el código necesario para que los tests pasen.

**Ni más, ni menos.**

### 5. Otra IA hace una revisión crítica
Esta IA tiene un solo trabajo: buscar fallos, agujeros, casos que no se han cubierto.

**Es despiadada.**

### 6. Si pasa la revisión, queda archivada como completada
Si no, vuelta al paso correspondiente hasta que pase.

---

## La cita

> *"El código siempre cumple lo que prometió. Los tests lo demuestran. Una IA crítica busca fallos antes de que lleguen a producción."*
>
> — La regla de oro de fs-scaffold

---

*Extraído de la presentación de Fernando Montero (Fersora) — Café Camaleónico, 18/05/2026*
