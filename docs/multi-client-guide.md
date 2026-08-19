# Multi-Cliente Guide

> Cómo trabajar con N clientes desde una sola instalación de iAmasters OS.

## Cuándo usar multi-cliente

Activa multi-cliente si:
- Eres freelance / agencia con 2+ clientes simultáneos
- Cada cliente tiene voice + ICP + positioning distintos
- Quieres separación clara de outputs por cliente

NO uses multi-cliente si:
- Eres single-business (trabaja directamente en raíz del repo)
- Tus "clientes" son verticales del mismo producto (eso es 1 marca con sub-segmentos)

## Crear cliente nuevo

```bash
bash scripts/add-client.sh acme-corp freelance-ia
```

Esto crea `clients/acme-corp/` con:

```
clients/acme-corp/
├── CLAUDE.md                       # Overrides específicos
├── brand-context/
│   ├── voice/voice-profile.md      # (con placeholders del template)
│   ├── positioning/positioning.md
│   ├── icp/icp.md
│   └── assets/
├── context/
│   ├── soul.md
│   └── user.md
└── projects/
    └── briefs/
```

**Verticales disponibles**:
- `freelance-ia` — operador IA solo
- `agencia-marketing` — pequeña agencia
- `formador-online` — coach/educador
- `consultoria-b2b` — high-ticket B2B
- `vacio` — sin template

## Trabajar dentro de un cliente

```bash
cd clients/acme-corp
claude
```

Claude Code arranca en el contexto del cliente:
- Lee `CLAUDE.md` raíz del repo (instrucciones generales)
- + `clients/acme-corp/CLAUDE.md` (overrides específicos)
- + `clients/acme-corp/brand-context/` (voice, positioning, ICP del cliente)
- + `clients/acme-corp/context/` (soul, user, learnings del cliente)

## Heredancia y overrides

### Qué se hereda del repo raíz
- `CLAUDE.md` raíz (las instrucciones generales)
- Skills del repo (`.claude/skills/`)
- Sinapsis (instalado global)

### Qué es del cliente solo
- `clients/<nombre>/CLAUDE.md` (overrides)
- `clients/<nombre>/brand-context/` (voice/positioning/ICP propios)
- `clients/<nombre>/context/` (soul/user del cliente)
- `clients/<nombre>/projects/` (outputs solo del cliente)

### Skills custom por cliente

Si un cliente requiere una skill que NO aplica a otros:

```bash
mkdir -p clients/acme-corp/.claude/skills/marketing-acme-special
# Crear SKILL.md, references/, etc.
```

Esa skill solo está disponible cuando trabajas en `clients/acme-corp/`. No se hereda al raíz ni a otros clientes.

## Cambiar de cliente

```bash
# Estás en clients/acme-corp
# Cierra Claude Code (Ctrl+C × 2) o ejecuta /wrap-up

cd ../widget-shop  # otro cliente
claude
```

El operator-state global de Sinapsis persiste, pero el contexto específico del cliente cambia automáticamente.

**Pro tip**: ejecuta `/wrap-up` ANTES de cambiar de cliente. Eso guarda el daily summary específico del cliente actual.

## Trabajar en raíz vs en cliente

| Si trabajas en... | Útil para... |
|---|---|
| Raíz del repo | Marketing del operador propio (LinkedIn personal, blog, marca personal), gestión interna |
| `clients/X/` | Cualquier output entregable al cliente X (copy, reports, deliverables) |

Regla: nunca generes contenido del cliente desde raíz. Siempre `cd clients/X` primero.

## Seguridad: separación de info

Por diseño, las skills NO comparten info entre clientes automáticamente:
- No sumas datos de cliente A en respuestas que vas a entregar al cliente B
- No referencias casos de cliente A en propuestas a cliente B
- `.gitignore` mantiene `clients/<nombre>/` fuera del git público (configurar por usuario si quieres compartir entre máquinas via repo privado)

Si quieres usar info de cliente A para inspirar cliente B:
- Hazlo manual y consciente
- Genera "case study anonimizado" como output de cliente A
- Referencia el case study en cliente B

## Update.sh y multi-cliente

Cuando ejecutas `bash scripts/update.sh`:
- ✅ Skills del repo raíz se actualizan
- ✅ Templates de `clients/_templates/` se actualizan (si upstream tiene cambios)
- ❌ Tus clientes en `clients/<nombre>/` NUNCA se tocan
- ❌ Tu brand-context, context, projects propios NUNCA se tocan

Si quieres "refrescar" un cliente con el último template:
- Hazlo manual: `cp -r clients/_templates/freelance-ia/X clients/<cliente>/X`
- Pero suele ser mala idea: el template es punto de partida, no destino

## Ejemplos de flujos típicos

### Flujo 1 · Lunes: 3 clientes

```bash
# Cliente A (freelance-ia)
cd clients/acme-corp && claude
> "Crea LinkedIn post sobre case study X" → marketing-copywriting genera con voice de Acme
> /wrap-up
exit

# Cliente B (agencia-marketing)
cd ../widget-shop && claude
> "Repurpose último video de su CEO en 5 piezas" → marketing-content-repurposing
> /wrap-up
exit

# Cliente C (consultoria-b2b)
cd ../north-star-consult && claude
> "Redacta propuesta comercial para nuevo lead" → marketing-copywriting registro A
> /wrap-up
exit
```

### Flujo 2 · Operador propio + 1 cliente

```bash
# Marca personal: contenido propio
cd /repos/iamasters-os
claude
> "Crea LinkedIn post sobre mi experiencia con cliente X (anonimizado)"
> /wrap-up
exit

# Cliente principal
cd clients/biggest-client && claude
> "Genera report mensual de KPIs"
> /wrap-up
```

## Best practices

1. **Siempre `cd` antes de `claude`**. No trabajar en cliente X desde raíz.
2. **Wrap-up al cambiar contexto**. Daily summary se separa por cliente.
3. **Brand voice por cliente**, no compartir entre clientes.
4. **Una skill custom = un cliente** o promoverla al raíz si aplica a varios.
5. **Backup el cliente regularmente** si tiene info crítica (no del git público).

## Troubleshooting

### "Claude no aplica voice del cliente"
- Verifica que estás `cd` en el cliente correcto antes de `claude`
- Comprueba `clients/<nombre>/brand-context/voice/voice-profile.md` está rellenado (no placeholders {{...}})
- Comprueba `clients/<nombre>/CLAUDE.md` referencia el path correcto

### "Skills del raíz no aparecen al estar en cliente"
- Las skills del raíz (`.claude/skills/`) son globales en el repo, deberían estar disponibles
- Si no se invocan: reinicia Claude Code (Ctrl+C × 2)
- Si persiste: ejecuta `bash scripts/sync-synapsis.sh` (futura skill v0.5)

### "Mezclo info de clientes accidentalmente"
- Es señal de no respetar `cd clients/X` antes de trabajar
- Implementa la regla: salir de Claude (Ctrl+C × 2) entre clientes, no abrir 2 sesiones a la vez
- Para 2 sesiones simultáneas: usar 2 terminales con `cd` distinto cada uno
