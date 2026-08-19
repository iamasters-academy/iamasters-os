---
description: Health check de iAmasters OS. Verifica entorno, Sinapsis, brand-context, agent-context, skills, settings y propone fixes para todo lo que esté roto. Ejecuta la skill `health-check` y devuelve un reporte 🟢🟡🔴 con acciones concretas.
---

# /doctor

Diagnostica iAmasters OS y propone acciones concretas para corregir desviaciones.

Ejecuta la skill `health-check` siguiendo todos sus pasos al detalle.

Al terminar, presenta los resultados al usuario en formato:

```
🟢 OK — <componente>
🟡 AVISO — <componente> · <motivo> · acción sugerida
🔴 ERROR — <componente> · <motivo> · acción concreta para arreglar
```

Si hay errores 🔴, propón al usuario ejecutar el fix automático cuando exista. Si el fix requiere comando, muéstralo y pide confirmación antes de correrlo.

Si todo está 🟢, recuerda al usuario qué proyectos tiene abiertos en `projects/briefs/*/brief.md` con `status: active` y propón continuar con uno.
