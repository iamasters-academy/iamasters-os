---
description: Pasa esta carpeta a IA Masters OS, la versión nueva de la comunidad, sin reinstalar y sin perder nada. Uso — /actualiza
---

# /actualiza · Pasar a IA Masters OS

Esta versión (iAmasters OS, con Sinapsis) está **retirada** y ya no recibe cambios. `/actualiza` ya no la actualiza: pasa **esta misma carpeta** a **IA Masters OS**, la versión nueva de la comunidad. No hay que reinstalar nada y no se pierde nada: la carpeta antigua se guarda entera en `.backup/` y se puede volver atrás.

No hagas `git pull` ni ejecutes `scripts/update.sh`, `/doctor` o `/restaura`: eso era de la versión antigua.

## 1 · Explícaselo y pide el token

Con tus palabras, en pocas líneas:

> Hay una versión nueva: **IA Masters OS**. Es más sencilla (ya no usa Sinapsis) y trae todas las skills de la comunidad listas para activar. Te paso a ella **en esta misma carpeta**, sin reinstalar:
> - Lo tuyo se viene contigo: tu marca y tu contexto, tus proyectos y clientes, tus skills y comandos propios y tus claves.
> - Tu carpeta antigua se queda guardada entera, por si quieres volver.
>
> Solo necesito el **token de acceso** de la comunidad: está en Skool, justo debajo de la clase **Instala IA Masters OS** («Token del mes»). Cópialo y pégamelo aquí.

Si prefiere seguir con la versión antigua por ahora, no insistas y ayúdale con lo que necesite. Si te dice que **ya instaló IA Masters OS en otra carpeta**, no hace falta pasar esta: que siga con aquella.

## 2 · Guarda el token

Cuando lo pegue, guárdalo así, sin repetirlo en tus mensajes:

```bash
mkdir -p .claude && printf '%s' 'EL_TOKEN_QUE_HA_PEGADO' > .claude/acceso-token
```

## 3 · Pásala a la versión nueva

Ejecútalo con el **tiempo máximo** de la herramienta (10 minutos, `timeout: 600000`): suele tardar menos de un minuto, pero con muchos proyectos o vídeos puede tardar más, y cortarlo a medias deja la carpeta a medio camino.

```bash
bash scripts/pasar-a-ia-masters-os.sh
```

Lee la línea `PARA CLAUDE:` y la etiqueta del final:

- **`[MIGRADO]`** → haz lo que dice la línea `PARA CLAUDE:`: un resumen corto y que abra una conversación nueva en esta carpeta. No sigas trabajando en esta conversación (tiene cargadas las instrucciones de la versión antigua).
- **`[SIN_TOKEN]`** o **`[TOKEN_NO_VALE]`** → pide otra vez el token, guárdalo como en el paso 2 y repite el paso 3. Si falla dos veces, explícale las causas (mal copiado, caducado, sin internet) y para.
- **Cualquier otra etiqueta** → haz lo que dice la línea `PARA CLAUDE:`.

**Si se corta** (se acaba el tiempo o la persona lo para), no toques nada a mano y mira si existe `.backup/pasando-a-ia-masters-os-<fecha>/EN_CURSO`:
- **Existe** → el paso quedó a medias. Ejecuta `bash .backup/volver-a-la-version-antigua-<la misma fecha>.sh`, que deja la carpeta exactamente como estaba antes, y cuando diga `[VUELTA_A_LA_ANTIGUA]` repite el paso 3 con el tiempo máximo. (Si ese script no existe, repite el paso 3 directamente: él mismo lo arregla.)
- **No existe** → no se cortó nada importante: repite el paso 3. Si `scripts/pasar-a-ia-masters-os.sh` ya no está y `mi-negocio/version-antigua/LEEME.md` sí, el paso terminó bien: haz lo de `[MIGRADO]`.

## Reglas

- No muevas, borres ni cambies ficheros a mano, ni toques git (`checkout`, `stash`, `reset`, `pull`), aunque git haya dado error antes: todo lo hace el script, que antes lo guarda todo.
- Nunca enseñes ni repitas el token.
- Para volver a la versión antigua después del cambio: `bash .backup/volver-a-la-version-antigua-<fecha>.sh` (la ruta exacta está en `mi-negocio/version-antigua/LEEME.md`).

## Disparadores en lenguaje natural

Activa este flujo también cuando diga, sin el comando: «actualízate», «actualiza el OS», «ponme la última versión», «tráete los cambios nuevos», «pásame a la versión nueva», «quiero IA Masters OS», «update».
