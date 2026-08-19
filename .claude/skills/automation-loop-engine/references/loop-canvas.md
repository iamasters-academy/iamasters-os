# Loop Canvas — plantilla de los 9 campos

El canvas es UNA página. Si no cabe en una página, el loop está mal acotado: pártelo en dos loops.

Regla de oro al rellenarlo: **Claude llega con el canvas pre-rellenado** (deducido del contexto,
la CONFIG del usuario y los defaults) y solo pregunta los huecos, en máximo 2 tandas. Nunca
interrogatorio en blanco.

---

## Plantilla

```
LOOP CANVAS — [nombre corto del loop]            v1.0 · [fecha] · Diseñado por: [usuario] + Claude

1 · OBJETIVO Y "HECHO"
   Produce: [qué sale del loop, en una frase]
   Hecho cuando: [criterio VERIFICABLE — si no se puede comprobar con un sí/no, reescribir]

2 · DISPARADOR
   [ ] Manual por lote ("procesa la cola")
   [ ] Programado: [cadencia — diario 8:00, lunes, etc.] vía [cron / tarea programada / automatización de su herramienta]
   [ ] Por evento: [qué evento — formulario, email entrante, nueva fila, webhook]

3 · COLA DE ENTRADA
   Vive en: [gestor de tareas / CRM / hoja de cálculo / carpeta o etiqueta de email / tabla en chat]
   Un item está LISTO cuando tiene: [campos mínimos — sin esto, el item no entra al loop]

4 · ESTACIONES (3–7, en orden)
   E1 [nombre] : [input] → [output]
   E2 [nombre] : [input] → [output]
   E3 [nombre] : [input] → [output]
   ...

5 · OPERARIO POR ESTACIÓN
   E1 → [skill / agente / herramienta / humano]
   E2 → ...
   (Separar SIEMPRE maker de checker: quien produce en una estación no verifica esa estación)

6 · VERIFICACIÓN AUTOMÁTICA (el checklist, máx. 5 criterios binarios)
   ☐ [criterio 1 — objetivo, sin "que quede bien"]
   ☐ [criterio 2]
   ☐ ...
   Auto-corrección: máx. [3] intentos antes de escalar.

7 · COMPUERTAS HUMANAS
   Estación [X] → nivel [A0/A1/A2/A3] — el usuario [aprueba antes / revisa después / audita 1 de N]
   Innegociables (siempre humanas): salida a cliente · dinero · irreversibles · compromisos
   · + las compuertas propias de su CONFIG.

8 · CONDICIONES DE PARADA
   Presupuesto por item: [máx. iteraciones / minutos]
   Escala al usuario si: [3 fallos de checklist / dato faltante / ambigüedad / error externo]
   Kill switch: [cómo se pausa todo el loop con una orden]

9 · MÉTRICAS Y APRENDIZAJE
   Se mide: first-pass yield · retrabajo · tiempo de ciclo · escalaciones · reglas/semana
   Estado del loop vive en: [loop-state-X.md / hoja / base de datos]
   Reglas aprendidas viven en: REGLAS.md del loop (toda corrección del usuario → regla numerada)
   Revisión: [semanal, 15 min — día fijo]
```

---

## Ejemplo rellenado — loop de solicitudes de presupuesto (universal: vale para freelance, estudio, agencia o consultora)

```
LOOP CANVAS — presupuestos                        v1.0 · [fecha] · Diseñado por: [usuario] + Claude

1 · OBJETIVO Y "HECHO"
   Produce: propuesta de presupuesto lista para enviar a quien la solicitó.
   Hecho cuando: existe el documento con alcance, precio y plazo, el email de envío está en
   borradores, y el usuario ha aprobado el envío.

2 · DISPARADOR
   [x] Por evento: entra una solicitud por el formulario de la web o por email.
   [x] Manual por lote: "procesa las solicitudes de la semana".

3 · COLA DE ENTRADA
   Vive en: etiqueta "Solicitudes nuevas" del email (o fila en la hoja de seguimiento).
   Item LISTO cuando tiene: nombre + qué necesita + plazo deseado + forma de contacto.

4 · ESTACIONES
   E1 Clasificar : solicitud → tipo de servicio + tamaño estimado (S/M/L)
   E2 Contexto   : solicitante → resumen de 5 líneas (quién es, a qué se dedica, señales públicas)
   E3 Redactar   : E1+E2 + plantillas del usuario → borrador de propuesta (alcance, precio, plazo)
   E4 Revisar    : borrador → versión final                       [HUMANO mientras esté en A1]
   E5 Preparar   : versión final → email de envío listo en borradores

5 · OPERARIO POR ESTACIÓN
   E1 → Claude con el catálogo de servicios del usuario
   E2 → Claude (búsqueda pública básica)
   E3 → Claude con las plantillas y el tarifario del usuario
   E4 → el usuario
   E5 → Claude
   Checker de E3 → checklist del campo 6, con instrucciones distintas a las de redacción.

6 · VERIFICACIÓN AUTOMÁTICA
   ☐ Precio dentro del tarifario vigente del usuario
   ☐ Alcance en máximo 5 puntos, sin ambigüedad
   ☐ Plazo realista según la carga declarada
   ☐ Ninguna promesa fuera del catálogo de servicios
   ☐ Nombre y datos del solicitante correctos en documento y email
   Auto-corrección: máx. 3 intentos.

7 · COMPUERTAS HUMANAS
   E1–E3 → A2 cuando lleven 10 items seguidos limpios (mientras tanto, A1).
   E5 → A1 SIEMPRE (dinero + cliente: el usuario aprueba antes de que salga nada).

8 · CONDICIONES DE PARADA
   Presupuesto: 1 ciclo completo por solicitud.
   Escala si: falta información clave · la petición está fuera de catálogo · es un cliente
   existente con condiciones especiales.
   Kill switch: "pausa el loop de presupuestos" → nada nuevo entra; lo abierto se congela.

9 · MÉTRICAS Y APRENDIZAJE
   Estado: hoja de seguimiento (una fila por solicitud) o loop-state-presupuestos.md.
   REGLAS.md: ej. R-001 "en proyectos S, ofrecer siempre dos opciones de alcance, no una".
   Revisión: viernes, 15 minutos.
```

---

## Errores típicos al rellenar el canvas (vistos en la práctica)

1. **"Hecho" subjetivo** ("que quede profesional") → reescribir como binarios comprobables.
2. **Cola sin criterio de "listo"** → el loop traga basura y la tasa de escalación se dispara.
3. **Estación gigante** ("E1: hacer todo el análisis") → si una estación tiene más de un output,
   son dos estaciones.
4. **Maker = checker** → quien redacta no puede ser el único que verifica su redacción.
5. **Sin kill switch** → todo loop necesita poder pararse con una frase.
6. **Empezar en A2/A3** → la autonomía se gana con datos (first-pass yield), no se regala el día 1.
