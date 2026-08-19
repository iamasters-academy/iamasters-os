# Loop Engineering

Loop Engineering es la práctica de convertir trabajo repetitivo en un sistema operativo:
se diseña una vez, se ejecuta muchas veces, se verifica antes de molestar al humano y aprende
de cada corrección.

La skill fuente es
[`automation-loop-engine`](../.claude/skills/automation-loop-engine/SKILL.md).
Esta guía resume cómo usarla como miembro del OS sin duplicar toda la implementación.

## Qué es un loop

Un loop es un objetivo recursivo: defines qué debe producir, qué significa "hecho" y qué
criterios lo paran o lo escalan. El sistema itera hasta cumplirlos o hasta devolver el control
al usuario.

La línea de producción tiene 6 estaciones:

```text
COLA → DESPACHO → EJECUCIÓN → VERIFICACIÓN → COMPUERTA → REGISTRO
  ▲                                                          │
  └────────────── el aprendizaje vuelve a la cola ───────────┘
```

- **Cola**: dónde viven los items pendientes y cuándo están listos.
- **Despacho**: qué item entra, con qué prioridad y bajo qué restricciones.
- **Ejecución**: estaciones de trabajo con input y output definidos.
- **Verificación**: checklist automático antes de pedir revisión humana.
- **Compuerta**: aprobación, revisión o auditoría humana según nivel A.
- **Registro**: estado, métricas y reglas aprendidas para mejorar el siguiente lote.

## Tu primer loop en 10 minutos

Ejemplo real con la plantilla de propuestas:

1. Pide a Claude: `Monta el loop de propuestas desde la plantilla`.
2. Claude lee `loops/_templates/loop-propuestas.md`.
3. Copia el canvas a `loops/propuestas/loop-spec.md`.
4. Te pregunta solo los huecos `[PERSONALIZA: ...]`: rutas de plantillas, día de revisión,
   compuertas extra y herramienta de cola si no usas el default.
5. Genera `loops/propuestas/REGLAS.md` vacío con secciones por estación.
6. Genera `loops/propuestas/loop-state.md` para estado y métricas.
7. Actualiza `loops/_index.md`.
8. Propone un lote piloto de 3 solicitudes en A1.

No empieces por automatizarlo todo. Empieza con 3 items, mira dónde falla y convierte cada
corrección repetida en una regla.

## Plantillas incluidas

| Plantilla | Uso |
|---|---|
| [`loop-contenido-semanal.md`](../loops/_templates/loop-contenido-semanal.md) | 1 fuente semanal → 5-8 piezas multiplataforma listas para revisar. |
| [`loop-propuestas.md`](../loops/_templates/loop-propuestas.md) | Solicitud de cliente → propuesta lista para revisión humana. |
| [`loop-triaje-leads.md`](../loops/_templates/loop-triaje-leads.md) | Lead nuevo → ficha enriquecida, score ICP y borrador de respuesta. |
| [`loop-informe-cliente.md`](../loops/_templates/loop-informe-cliente.md) | Cliente activo → informe periódico HTML listo para enviar. |
| [`loop-revision-semanal.md`](../loops/_templates/loop-revision-semanal.md) | Todos los loops activos → scorecard y decisiones de autonomía. |

## Niveles A0-A3

| Nivel | Quién hace qué | Cuándo usarlo |
|---|---|---|
| **A0** | El usuario ejecuta, la IA asiste | Tarea nueva, criterio aún no explicitado |
| **A1** | La IA propone, el usuario aprueba ANTES de que salga nada | Default de todo loop nuevo |
| **A2** | La IA ejecuta, el usuario revisa DESPUÉS | Tras 10 items seguidos aceptados sin tocar en A1 |
| **A3** | La IA ejecuta y registra; el usuario audita por muestreo | Tras 20 items en A2 con first-pass ≥90% y riesgo bajo |

La promoción se propone con datos. La decisión siempre es humana.

## Los 3 peajes

Estos peajes son innegociables y se leen antes de cada loop nuevo:

1. **La verificación sigue siendo tuya.** Un loop desatendido también comete errores
   desatendidos. "Hecho" es una afirmación del agente, no una prueba.
2. **Deuda de comprensión.** Cuanto mejor el loop, más rápido crece el hueco entre lo que
   existe y lo que entiendes. Antídoto: auditoría por muestreo de A3 obligatoria.
3. **Rendición cognitiva.** Dos personas con el mismo loop obtienen resultados opuestos:
   una lo usa para ir más rápido en lo que domina; la otra para dejar de pensar.

Además, estas compuertas siempre son humanas y nunca A3:

- Todo lo que sale a un cliente o se publica con tu marca.
- Dinero: precios, cobros, presupuestos, pagos.
- Acciones irreversibles: borrar datos, enviar emails masivos, desplegar a producción.
- Compromisos: fechas, alcance, contratos.

## Cómo hacer que un loop corra solo

### Tarea programada en Claude Desktop

Usa este camino cuando quieres una cadencia estable:

1. Abre Claude Desktop.
2. Ve a `Routines`.
3. Crea una rutina nueva con `New routine`.
4. En instrucciones, escribe algo como: `corre el loop de contenido semanal`.
5. Elige horario: por ejemplo lunes 8:00 o viernes 16:00.
6. Guarda la rutina.

La rutina debe seguir respetando compuertas humanas. Si el loop genera algo para cliente,
publicación, dinero o compromisos, queda en revisión.

### `/loop <intervalo>` dentro de una sesión

Usa `/loop <intervalo>` cuando necesitas vigilancia temporal dentro de una sesión abierta,
por ejemplo:

```text
/loop 15m
```

Esto sirve para polling o seguimiento ligero mientras estás trabajando. No sustituye un
estado persistente: el loop debe seguir registrando en `loop-state.md` y `REGLAS.md`.

## FAQ

### ¿Y si el loop falla?

Se para según sus condiciones de parada. Normalmente: 3 fallos de checklist, dato faltante,
ambigüedad o error externo. Pide `/evalua-loop <nombre>` para revisar métricas y ajustar cola,
estaciones o verificación.

### ¿Cómo lo mato?

Di: `pausa el loop de <nombre>`. Si ya no rinde, en la revisión semanal se puede archivar el
canvas y marcarlo como muerto en `loops/_index.md`.

### ¿Dónde veo lo aprendido?

En `loops/<nombre>/REGLAS.md`. Cada corrección repetida debe convertirse en una regla numerada.
También puedes preguntar con `/recuerda`, por ejemplo: `¿qué aprendimos del loop de propuestas?`.

### ¿Dónde veo todos mis loops?

Usa `/loops` o abre `loops/_index.md`.

### ¿Qué pasa si no tengo plantilla?

Pide: `diseña el loop de <proceso>`. Claude rellena el Loop Canvas de 9 campos, pregunta solo
los huecos y genera la carpeta operativa.
