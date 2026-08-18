# Los 7 patrones de diseño de loops

Todo loop real es una combinación de estos patrones. Al diseñar, elegir el patrón DOMINANTE
primero y añadir los secundarios después. Regla: si dudas entre dos, elige el más simple —
un loop se complica solo con el uso, nunca hace falta ayudarle.

---

## P1 · CADENA (pipeline)
**Forma:** estaciones en secuencia fija: A → B → C → D. El output de una es el input de la siguiente.
**Cuándo:** el camino se conoce de antemano y siempre es el mismo.
**Ejemplo:** solicitud de presupuesto → clasificar → investigar contexto → redactar propuesta → preparar envío.
**Autonomía típica:** A2 en estaciones intermedias, A1 en la final.
**Riesgo:** una estación lenta atasca toda la cadena → medir tiempo de ciclo por estación.

## P2 · LOTE (batch)
**Forma:** la misma operación sobre N items de una cola, uno a uno o en paralelo.
**Cuándo:** volumen homogéneo: 50 productos que describir, 30 filas que clasificar, 15 fichas que redactar.
**Ejemplo:** generar las fichas de un calendario editorial mensual completo.
**Autonomía típica:** A1 en los 3 primeros items (calibración), A2 después.
**Riesgo:** el error sistemático se multiplica por N → verificar SIEMPRE los 3 primeros antes de soltar el resto.

## P3 · ITERA-HASTA-VERDE
**Forma:** producir → verificar contra criterio objetivo → si ❌, corregir → repetir hasta ✅ o hasta agotar presupuesto.
**Cuándo:** existe una condición de parada VERIFICABLE (tests pasan, checklist completo, validador en verde).
**Ejemplo:** código que itera hasta que la suite de tests pasa; un texto que itera hasta cumplir un checklist de 5 criterios.
**Autonomía típica:** A2 — la verificación objetiva sustituye la mirada humana en cada vuelta.
**Riesgo:** criterio de verde mal escrito = el loop optimiza lo equivocado con mucha eficiencia.

## P4 · GENERADOR–CRÍTICO (maker/checker)
**Forma:** un operario produce; OTRO operario, con instrucciones distintas, verifica. El que escribe no se aprueba a sí mismo.
**Cuándo:** calidad crítica, salidas a cliente, cualquier cosa donde el productor "se enamora" de su output.
**Ejemplo:** un redactor genera la propuesta; un revisor con ojos de cliente (y criterios propios) la destripa antes de presentarla.
**Autonomía típica:** permite subir a A2/A3 antes, porque hay un segundo par de ojos estructural.
**Riesgo:** crítico demasiado blando (mismas instrucciones que el generador) = teatro de verificación.

## P5 · ORQUESTADOR–TRABAJADORES (fan-out / fan-in)
**Forma:** un orquestador parte el trabajo, lo reparte a trabajadores en paralelo y consolida resultados.
**Cuándo:** subtareas independientes entre sí: investigar 5 competidores a la vez, 3 secciones de un informe.
**Ejemplo:** análisis de competencia donde cada competidor lo investiga un trabajador y el orquestador monta la comparativa.
**Autonomía típica:** trabajadores en A2, consolidación en A1.
**Riesgo:** el paralelo cuesta tokens y atención de revisión — el techo eres tú, no la herramienta.
Usar solo cuando la independencia es real.

## P6 · COMPUERTA HUMANA (checkpoint loop)
**Forma:** el loop corre solo HASTA un punto definido, presenta, espera el veredicto humano y continúa.
**Cuándo:** decisiones de criterio, gusto o riesgo en mitad del proceso (no solo al final).
**Ejemplo:** calendario editorial: la IA propone 12 temas (compuerta: el usuario elige 8) → redacta los 8 elegidos.
**Autonomía típica:** mixta por diseño — es el patrón que materializa el human-in-the-loop.
**Riesgo:** demasiadas compuertas = vuelves a operar paso a paso con extra de burocracia.
Máximo 2 compuertas por loop; si necesitas más, el loop es prematuro.

## P7 · PROGRAMADO / CONTINUO (heartbeat)
**Forma:** el loop se dispara solo, por calendario o por evento, sin que nadie lo pida.
**Cuándo:** trabajo recurrente con cadencia natural: informe semanal, triaje diario del inbox o del CRM, vigilancia de competencia.
**Ejemplo:** cada lunes a las 8:00, un resumen de la actividad de la semana anterior aterriza listo para leer.
**Dónde vive:** cron, tareas programadas o la automatización nativa de la herramienta del usuario.
**Autonomía típica:** A2 con bandeja de triaje — lo que el loop no resuelve cae en una bandeja para el usuario;
lo que no encuentra nada, se archiva solo.
**Riesgo:** es el único patrón que trabaja cuando no miras → las condiciones de parada y las
notificaciones de fallo son OBLIGATORIAS, no opcionales.

---

## Tabla de selección rápida

| Si la tarea es... | Patrón dominante |
|---|---|
| Siempre los mismos pasos, en orden | P1 Cadena |
| Lo mismo sobre muchos items | P2 Lote |
| Tiene un "verde" comprobable | P3 Itera-hasta-verde |
| No puede salir mal hacia fuera | P4 Generador–Crítico |
| Partes independientes en paralelo | P5 Orquestador–Trabajadores |
| Hay decisiones de criterio a mitad | P6 Compuerta humana |
| Pasa cada semana/día sin que la pidas | P7 Programado |

Combinación más frecuente en negocios de servicios: **P1 + P3 + P6** (cadena cuyas estaciones
iteran hasta verde, con compuerta humana antes de la salida) — es la forma típica de un loop
comercial o de entregables a cliente.
