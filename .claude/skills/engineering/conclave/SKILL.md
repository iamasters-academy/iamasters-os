---
name: conclave
description: Metodología de desarrollo multi-agente — un modelo de mayor capacidad planifica y diseña (código + pruebas), agentes de ejecución codifican en paralelo (fan-out) y un revisor adversarial (abogado del diablo) hace de gate antes de CADA commit. Sin doble OK, no hay commit. USAR cuando construyas una feature, bug o fix con agentes de IA y quieras verificar el código, cazar bugs y elevar la calidad y la fiabilidad de forma continuada. Versión OS: delega la revisión en cognito/code-review/verify/security-review y el fan-out en Workflow/Agent.
---

# Cónclave — Multi-Agent Dev Loop

> Los agentes construyen en paralelo y un revisor hace de **abogado del diablo**
> hasta que hay consenso (doble OK) antes de cada commit.

> **Versión iAmasters OS.** Adaptada del paquete de FlowenUp (Arturo Soto). No
> duplica el revisor adversarial: lo **delega** en skills existentes
> (`cognito`, `code-review`, `verify`, `security-review`) y el fan-out en la
> herramienta nativa `Workflow` / `Agent`. El aporte neto de Cónclave aquí es
> **dos piezas que el OS no tenía**: (1) formalizar el bucle
> plan→fan-out→gate→doble-OK→commit, y (2) el **enforcement por hook** que
> fuerza el doble OK antes de commitear código.

## Propósito (el norte — SIEMPRE)
No es poner un candado antes del commit: es **verificar el código, detectar
bugs y mejorar de forma continuada el desarrollo**, para aumentar la
**calidad** del código generado y su **fiabilidad**. La revisión es análisis
adversarial real que busca fallos genuinos y deja el código mejor que antes —
nunca un "apto" de trámite.

## Qué es
**Un plano + dos mitades.** Primero, un modelo de **mayor capacidad** planifica
y diseña el código **y las pruebas** y deja el trabajo servido. Luego
**(1) Fan-out** (opcional) — agentes de **ejecución** codifican en paralelo
sobre ese plano (el esfuerzo de cada uno escala con la complejidad de su
sub-tarea). Y **(2) Cónclave** (incondicional) — un revisor adversarial
delibera contra el código antes de CADA commit. Nada se commitea sin doble OK.

## PASO 0 · INTERROGATORIO OBLIGATORIO AL INVOCAR (no saltar)
Antes de construir nada, la skill **pregunta y confirma** con el usuario — no
asumir:
1. **¿Con qué agente(s) se hará la REVISIÓN (el gate)?** Presenta opciones y
   espera respuesta. En este OS las opciones canónicas son:
   - `cognito` (modo *devil's advocate* en planning + modo *auditor* en review)
     para razonamiento adversarial estructurado.
   - `code-review` (bugs + cleanups del diff) + `verify` (ejercitar el cambio
     end-to-end) + `security-review` si toca seguridad — el combo de revisión
     de código built-in.
   - Ambos (cognito + code-review/verify) para cambios sensibles.
   El usuario confirma. Si el cambio es trivial/bajo riesgo, uno basta.
2. **Evalúa el riesgo del cambio y recomienda:** ¿toca dinero, identidad,
   seguridad o datos personales? → revisor fuerte y/o doble. ¿Cambio
   mecánico/bajo riesgo? → uno basta. La elección la confirma el usuario.
3. **Valida que la petición está bien formada:** unidad de trabajo clara ·
   criterio de "hecho" (qué tests/build deben pasar) · descomposición en
   sub-tareas independientes si va a haber fan-out.

No avanzar hasta tener (a) revisor(es) elegido(s) y (b) petición validada.

## REGLA INCONDICIONAL · SIN DOBLE OK NO HAY COMMIT
El cambio pasa SIEMPRE por el revisor elegido antes de commitear. Solo se
commitea con **doble OK** (modelo constructor + revisor). Hallazgos ≥
IMPORTANTE → corregir → **re-pasar por el revisor** (nunca self-review) → bucle
hasta APTO. Nunca `--no-verify`, nunca saltarse el gate "porque es pequeño".

## ENFORCEMENT POR HOOK (la skill propone, el hook obliga)
La skill es comportamiento; el **hook `pre-commit`** es el candado que lo hace
inviolable.
- Tras el doble OK, el proceso sella el árbol staged:
  `git write-tree > .conclave/pass` (o `bash
  .claude/skills/engineering/conclave/scripts/conclave-approve.sh`).
- El hook compara el árbol staged con el sello: coincide → commit + consume el
  sello; no coincide → **aborta**.
- Un `git add` posterior invalida el sello → obliga a re-revisar. Override
  consciente: `CONCLAVE_OVERRIDE=1 git commit …`.
- **Scope en este OS:** el hook **solo exige sello cuando el staged toca
  código** (`.sh .mjs .js .ts .py .ps1` o rutas bajo `hooks/` `vendor/`
  `scripts/`). Los commits de solo docs/skills/`.md`/`brand-context`/`context`
  pasan sin sello — el gate adversarial brilla en código, no asfixia docs. Los
  guards de **secretos** y **archivos grandes** (heredados de Arnes) siguen
  activos SIEMPRE, con o sin sello.
- Instalación del hook: ver `references/install.md`.

## Proceso
- **Paso 0 · Interrogatorio + validación** (arriba) — elegir revisor, validar
  la petición y **evaluar la complejidad para dimensionar el equipo**.
- **Paso 1 · Plan & diseño (modelo de mayor capacidad):** analiza la tarea,
  **diseña el código Y las pruebas** y la descompone en N sub-tareas
  independientes con criterio de "hecho". Ese plano es el **contexto
  compartido** que recibe cada agente de ejecución → la ejecución va
  "servida". Si el proyecto arranca de cero, considera `arnes` (scaffolding)
  o `spec-kit` (desarrollo dirigido por spec) antes de picar código.
- **Paso 2 · Fan-out — ejecución (opcional):** lanzar N agentes constructores
  en paralelo. En este OS, usa la herramienta **`Workflow`** (pipeline:
  cada sub-tarea fluye por sus stages; verify adversarial al final) o el tool
  **`Agent`** (varios en un solo mensaje para concurrencia). Cada agente recibe
  su trozo del plano + reglas del proyecto (TDD + seguridad + "no tocar más de
  lo pedido") + criterio de "hecho". Devuelven diff + tests, **NO commitean**.
  Si no hay partes independientes → construcción única (sin fan-out).
- **Paso 3 · Integración:** recomponer diffs, resolver solapes (el plano común
  arbitra), correr build completo + suite entera.
- **Paso 4 · Cónclave (gate adversarial)** con el revisor elegido — **delega**:
  pasa el diff por `code-review` (bugs + cleanups) + `verify` (end-to-end) +
  `security-review` (si toca seguridad). Para razonamiento adversarial
  multimodo, `cognito` (devil's advocate / auditor). Veredicto APTO o
  hallazgos.
- **Paso 5 · Iterar** hasta que constructor + revisor coincidan en APTO
  (re-corriendo build + tests cada vuelta).
- **Paso 6 · Commit:** solo con doble OK. Sellar
  (`bash .claude/skills/engineering/conclave/scripts/conclave-approve.sh` o
  `git write-tree > .conclave/pass`) y commitear. Conventional Commits. Sin
  `--no-verify`.

## Output
Cambio commiteado + traza de calidad (revisor usado, qué cazó, cuántas vueltas).
Reutilizable para enseñar y para auditoría.

## Skills colaboradoras
- `cognito` — razonamiento adversarial (devil's advocate, auditor).
- `code-review` / `verify` / `security-review` (built-in) — revisión de código
  del diff (bugs, end-to-end, seguridad).
- `arnes` / `spec-kit` / `ask-questions-if-underspecified` — planificar y
  arrancar de cero (Paso 1).
- `tool-quality-gate` / `code-audit-integral` — gates pre-deploy más amplios
  (no solo commit): build/env/tests/security con score.
- `meta-wrap-up` — cierre de sesión; propone commit con aprobación blanda
  (Cónclave es el candado duro para código).

## Notas
- Máx ~10-16 agentes concurrentes; diffs paralelos sobre el mismo fichero se
  resuelven en integración (o worktree por agente si mutan en paralelo).
- Si el revisor de código no responde en tu entorno, usa un fallback (otro
  revisor) — nunca saltarte el gate.
- El sello `.conclave/pass` es local al working tree (ignorado por git); no
  viaja entre máquinas ni sobrevive a `git clean`.
