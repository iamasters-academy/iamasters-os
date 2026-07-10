---
name: project-architect
description: Reorganiza y documenta un proyecto caótico con estructura profesional: detecta duplicados y archivos huérfanos, crea README/PROJECT_MAP/AI_CONTEXT/CHANGELOG y reagrupa archivos por función sin tocar el contenido. Úsala cuando el operador diga "ordena este proyecto", "limpia la estructura", "genera README/PROJECT_MAP", "detecta archivos huérfanos" o herede un repo confuso.
category: strategy
tags: [organization, documentation, architecture, knowledge-management, refactoring]
version: "1.0.0"
---

# Project Architect — Arquitecto de Organización de Proyectos

**Skill de estrategia y herramientas para análisis y reorganización profunda de proyectos.**

## CUÁNDO USAR

- El proyecto tiene una estructura confusa o desorganizada
- Archivos difícilmente localizables
- Documentación inexistente o dispersa
- "No encuentro nada" o "¿Dónde va X?"
- Antes de pasar el proyecto a otra persona/IA
- Proyecto heredado sin documentación
- Mezcla de tipos de archivos en carpetas raíz
- Necesidad de mapa del proyecto para IA

## QUÉ HACE

1. **Análisis completo** del proyecto (estructura, relaciones, dependencias)
2. **Detección de problemas**: duplicados, temporales, huérfanos, documentos repetidos
3. **Diseño de nueva estructura** profesional y escalable
4. **Creación de documentación** base si no existe
5. **Reorganización de archivos** (mover, agrupar)
6. **Entrega de informe completo** con árbol, listas y recomendaciones

## LO QUE NO HACE

- ❌ NO elimina archivos
- ❌ NO renombra archivos/carpetas
- ❌ NO modifica contenido de archivos
- ❌ NO altera configuraciones
- ❌ NO cambia código

**Todo el contenido original se mantiene intacto.**

---

## WORKFLOW DEL ARQUITECTO

### FASE 0: ENTRADA Y CONTEXTO

1. **Identificar el directorio objetivo**:
   - Si el usuario no especifica → usar `$PWD` (directorio actual)
   - Confirmar: "¿Analizar y reorganizar `<directorio>`?"

2. **Verificar permisos de escritura**:
   - La skill necesita poder crear carpetas y mover archivos
   - Si hay restricciones → advertir y pedir confirmación

3. **Capturar estado inicial**:
   - Guardar árbol actual del proyecto
   - Timestamp: `PROJECT_ARCHITECT_ANALYSIS_YYYY-MM-DD_HH-mm-ss`

---

### FASE 1: ANÁLISIS PROFUNDO

#### 1.1 Escaneo Estructural

```bash
# Árbol completo del proyecto
tree -L 4 -a --gitignore > /tmp/project_tree_before.txt

# Estadísticas básicas
find . -type f | wc -l    # Total archivos
find . -type d | wc -l    # Total carpetas
du -sh *                   # Tamaños por carpeta raíz

# Identificar tipos de archivos
find . -type f -name "*.md" | wc -l      # Documentación
find . -type f -name "*.json" | wc -l    # Configuraciones
find . -type f -name "*.js" -o -name "*.ts" -o -name "*.py" -o -name "*.go" | wc -l  # Código
```

#### 1.2 Análisis de Archivos por Categoría

**Código fuente**:
- Identificar lenguaje(s) principal(es)
- Buscar `package.json`, `go.mod`, `pyproject.toml`, `Cargo.toml`, etc.
- Ubicar carpetas `src/`, `lib/`, `app/`, `internal/`

**Documentación**:
- Ubicar todos los `.md` (README, CONTRIBUTING, LICENSE, etc.)
- Docs en `docs/`, `documentation/`,GUIDES/
- READMEs en subcarpetas

**Configuración**:
- `.env*`, config files, `.json`, `.yaml`, `.toml`
- `.gitignore`, `.dockerignore`, etc.

**Recursos**:
- Imágenes: `.png`, `.jpg`, `.svg`, `.gif`
- Fuentes: `.ttf`, `.otf`, `.woff`
- Datos: `.csv`, `.json` (data), `.db`, `.sqlite`

**Scripts/Herramientas**:
- `scripts/`, `tools/`, `utils/`
- Makefiles, `package.json` scripts

**Tests**:
- `tests/`, `test/`, `__tests__`, `spec/`

**Build/Deploy**:
- `Dockerfile`, `docker-compose.yml`
- `.github/workflows/`, CI configs
- `build/`, `dist/` (si existen)

#### 1.3 Detección de Problemas

**Archivos duplicados** (sin eliminar):
```bash
# Por nombre
find . -type f -printf "%f\n" | sort | uniq -d

# Por contenido (más lento, usar solo si necesario)
fdupes -r . > /tmp/duplicates.txt 2>/dev/null || echo "fdupes no disponible"
```

**Archivos temporales**:
- `.tmp`, `.temp`, `~`, `.swp`, `.bak`
- `.DS_Store`, `Thumbs.db`
- `node_modules/`, `__pycache__/`, `.venv/`, `target/`
- `.cache/`, `.next/`, `.nuxt/`, `dist/`

**Archivos huérfanos**:
- Archivos sin referencias (difícil de detectar automáticamente)
- Soluciones PARCIALES:
  - Si es código → buscar imports/referencias con `grep`
  - Si es recurso → buscar en archivos de código/config
  - Marcar como "potencialmente huérfano"

**Documentación repetida**:
- Múltiples README.md
- Mismo tema en varios `.md`
- Docs que deberían estar consolidados

**Recursos mal ubicados**:
- Imágenes en carpetas de código
- Datos en documentación
- Scripts en raíz cuando deberían estar en `scripts/`

#### 1.4 Análisis de Relaciones

- **Dependencias del proyecto**: `package.json`, `requirements.txt`, `go.mod`, etc.
- **Flujos de trabajo** evidentes: scripts que llaman a otros
- **Carpetas con contenido mezclado**: código + datos + docs juntas

---

### FASE 2: DISEÑO DE NUEVA ESTRUCTURA

#### 2.1 Principios de Diseño

1. **Separación por responsabilidad**: cada carpeta tiene UN propósito claro
2. **Profundidad mínima**: evitar estructuras >4 niveles cuando sea posible
3. **Nomenclatura consistente**: usar una convención (kebab-case recomendado)
4. **Ubicación predecible**: usuario puede adivinar dónde está algo
5. **Optimizado para IA**: estructura clara que facilita navegación semi-autónoma

#### 2.2 Plantillas de Estructura por Tipo de Proyecto

**Proyecto Software (web/app)**:
```
project/
├── src/              # Código fuente
│   ├── components/   # Componentes UI
│   ├── lib/          # Utilidades compartidas
│   ├── styles/       # Estilos globales
│   └── ...
├── tests/            # Tests
├── scripts/          # Scripts de utilidad
├── docs/             # Documentación detallada
├── assets/           # Recursos estáticos
│   ├── images/
│   ├── fonts/
│   └── ...
├── config/           # Configuraciones
├── public/           # Archivos públicos
├── .github/          # GitHub workflows
├── README.md         # Documentación principal
└── package.json      # Metadata del proyecto
```

**Proyecto Data/ML**:
```
project/
├── data/             # Datos
│   ├── raw/          # Datos originales (no tocar)
│   ├── processed/    # Datos procesados
│   └── external/     # Datos de terceros
├── notebooks/        # Jupyter notebooks
├── src/              # Código fuente
├── models/           # Modelos entrenados
├── reports/          # Reportes generados
├── scripts/          # Scripts ETL, processing
├── tests/            # Tests
├── docs/             # Documentación
└── requirements.txt  # Dependencias
```

**Proyecto Documentación/Knowledge**:
```
project/
├── topics/           # Contenido por tema
├── templates/        # Plantillas
├── assets/           # Imágenes, recursos
├── drafts/           # Borradores
├── published/        # Contenido final
├── scripts/          # Scripts de generación
└── README.md
```

**Mono-repo multi-proyecto**:
```
monorepo/
├── apps/             # Aplicaciones independientes
├── packages/         # Paquetes compartidos
├── services/         # Microservicios
├── infrastructure/   # Docker, K8s, Terraform
├── docs/             # Documentación global
└── scripts/          # Scripts monorepo
```

**ADAPTAR al proyecto específico**. Estas son plantillas, no reglas fijas.

#### 2.3 Diseñar la Nueva Estructura

Basado en el análisis:

1. **Identificar carpetas actuales bien organizadas** → PRESERVAR
2. **Identificar carpetas mezcladas** → SEPARAR
3. **Identificar archivos raíz que deben agruparse** → CREAR carpeta
4. **Identificar recursos sin ubicación** → CREAR `assets/` o equivalente
5. **Detectar huecos estructurales** → CREAR carpetas necesarias

**Documento de diseño**: antes de cualquier cambio, proponer:
- Nuevo árbol (texto)
- Justificación de cada cambio mayor
- Archivos que se moverán
- Nuevas carpetas a crear

---

### FASE 3: CREACIÓN DE DOCUMENTACIÓN

#### 3.1 Checklist Inicial

Verificar qué ya existe:

```bash
ls -la | grep -E "(README|PROJECT_MAP|AI_CONTEXT|CHANGELOG|TODO|DECISIONS)"
find . -maxdepth 2 -name "*.md" -type f
```

#### 3.2 README.md (si no existe)

**Estructura mínima**:

```markdown
# <Nombre del Proyecto>

## Resumen
Descripción breve del proyecto (2-3 líneas).

## Objetivo
Qué resuelve, para quién, por qué existe.

## Estado Actual
- Estado: [En desarrollo | Activo | Mantenimiento | Deprecado]
- Última actualización: YYYY-MM-DD
- Versión: X.Y.Z

## Quick Start
Instrucciones rápidas para empezar (3-5 comandos máx).

## Estructura General
Descripción breve de las carpetas principales.

## Cómo Contribuir
Guía básica para contribuir.

## Licencia
Tipo de licencia.
```

#### 3.3 PROJECT_MAP.md

**Contenido**:

```markdown
# Project Map — <Nombre del Proyecto>

## Visión General
Descripción de alto nivel del proyecto.

## Estructura de Carpetas

### `/src/`
Código fuente del proyecto.
- `components/`: Componentes UI reutilizables
- `lib/`: Utilidades compartidas
- ...

### `/docs/`
Documentación detallada.
- `guides/`: Guías de uso
- `api/`: Documentación de API
- ...

### `/tests/`
Suite de tests del proyecto.

## Flujo de Trabajo Principal
Descripción del flujo básico del proyecto.

## Puntos de Entrada Importantes
- Archivo principal: `<path>`
- Configuración: `<path>`
- Entry point: `<path>`
```

#### 3.4 AI_CONTEXT.md

**Contenido**:

```markdown
# AI Context — <Nombre del Proyecto>

## Resumen Ejecutivo
<Descripción completa para IA>

## Objetivos
1. <Objetivo 1>
2. <Objetivo 2>
...

## Arquitectura
<Descripción técnica de alto nivel>

## Componentes Principales
- **<Componente 1>**: <Función>
- **<Componente 2>**: <Función>
...

## Flujo General
<Paso a paso del flujo principal>

## Archivos Importantes
- `<path>`: <Por qué es importante>
- `<path>`: <Por qué es importante>
...

## Dependencias Externas
- **<Dependencia 1>**: <Versión, propósito>
- **<Dependencia 2>**: <Versión, propósito>
...

## Estado Actual
- Lo que funciona: ...
- Lo que está en progreso: ...
- Lo que está roto: ...

## Pendientes
1. <Pendiente 1>
2. <Pendiente 2>
...

## Riesgos Conocidos
- **<Riesgo 1>**: <Impacto, mitigación>
- **<Riesgo 2>**: <Impacto, mitigación>
...

## Información de Contexto
<Cualquier información relevante para IA>

## Decisiones Arquitectónicas Recientes
- **YYYY-MM-DD**: <Decisión, por qué>
```

#### 3.5 CHANGELOG.md

```markdown
# Changelog

Todos los cambios notables del proyecto.

## [Unreleased]

### Added
- Nueva funcionalidad X

### Changed
- Cambiado Y

### Fixed
- Fix de Z

### Organizational
- Reorganización de archivos (Project Architect)
```

#### 3.6 TODO.md

```markdown
# TODO — Pendientes del Proyecto

## Crítico
- [ ] <Pendiente crítico 1>

## Importante
- [ ] <Pendiente importante 1>

## Mejoras
- [ ] <Mejora 1>

## Documentación
- [ ] <Doc pendiente 1>
```

#### 3.7 DECISIONS.md

```markdown
# Decisiones Arquitectónicas y Organizativas

Registro de decisiones importantes del proyecto.

Formato: YYYY-MM-DD - [Decisión]

## 2024-01-15 — Elegir X sobre Y para Z

**Contexto**: <Por qué se tomó esta decisión>

**Decisión**: <Qué se decidió>

**Consecuencias**: <Impacto de la decisión>

**Alternativas consideradas**: <Otras opciones y por qué no se eligieron>
```

---

### FASE 4: REORGANIZACIÓN (CON CONFIRMACIÓN)

#### 4.1 Plan de Movimiento

Antes de mover cualquier archivo, crear un plan:

```markdown
## Plan de Reorganización

### Nuevas Carpetas a Crear
- `docs/` — Documentación consolidada
- `assets/images/` — Imágenes organizadas
- `scripts/` — Scripts de utilidad

### Archivos a Mover
- `README.md` → `docs/README.md` (o mantener en raíz)
- `image1.png` → `assets/images/image1.png`
- `script.sh` → `scripts/script.sh`

### Justificaciones
- Imágenes estaban dispersas en 5 carpetas
- Scripts mezclados con código fuente
- Docs duplicadas en 3 READMEs
```

#### 4.2 Ejecución (Solo con Confirmación)

```bash
# Crear nuevas carpetas
mkdir -p docs/{guides,api}
mkdir -p assets/{images,fonts,icons}
mkdir -p scripts

# Mover archivos
mv image1.png assets/images/
mv script.sh scripts/

# NO mover archivos críticos sin confirmación explícita
```

#### 4.3 Verificación

Después de cada movimiento:
- Verificar que no se rompieron imports/relaciones
- Actualizar referencias si es necesario (PERO: esto modifica contenido, pedir confirmación)

---

### FASE 5: ENTREGA DE INFORME

#### 5.1 Contenido del Informe Final

```markdown
# Informe de Reorganización — <Nombre del Proyecto>

## Resumen Ejecutivo
<Descripción breve de lo que se hizo y por qué>

## Antes (Árbol Original)
```
<output de tree antes>
```

## Después (Árbol Resultante)
```
<output de tree después>
```

## Carpetas Creadas
| Carpeta | Propósito |
|---------|-----------|
| `docs/` | Documentación consolidada |
| `assets/images/` | Imágenes organizadas |
...

## Archivos Movidos
| Archivo | Origen | Destino | Razón |
|---------|--------|---------|-------|
| `image1.png` | `./` | `assets/images/` | Agrupar recursos |
...

## Archivos Duplicados Detectados
| Archivo | Ubicaciones | Acción |
|---------|-------------|--------|
| `config.json` | `./config.json`, `src/config.json` | Revisar consolidación |
...

## Archivos Temporales Detectados
| Archivo | Tipo | Nota |
|---------|------|------|
| `.DS_Store` | Sistema | Puede eliminarse |
...

## Archivos Huérfanos (Potencialmente)
| Archivo | Última modificación | Nota |
|---------|-------------------|------|
| `old_file.txt` | 2023-01-01 | Sin referencias encontradas |
...

## Documentación Creada
- ✅ README.md
- ✅ PROJECT_MAP.md
- ✅ AI_CONTEXT.md
- ✅ CHANGELOG.md
- ✅ TODO.md
- ✅ DECISIONS.md

## Autoevaluación

### Claridad
[✓/✗] La estructura es intuitiva y fácil de entender

### Escalabilidad
[✓/✗] El proyecto puede crecer sin perder organización

### Mantenibilidad
[✓/✗] Es fácil mantener y actualizar la organización

### Compatibilidad con IA
[✓/✗] Una IA puede navegar y comprender el proyecto rápidamente

## Recomendaciones Futuras

1. **Mantener la estructura**: Cuando se añadan nuevos archivos, seguir la convención establecida
2. **Documentar cambios**: Actualizar CHANGELOG.md para cambios organizativos
3. **Revisión periódica**: Revisar la organización cada X meses
4. **Automatizar**: Considerar scripts para verificar estructura automáticamente

## Próximos Pasos Sugeridos
1. Revisar los archivos duplicados detectados
2. Eliminar archivos temporales si se desea
3. Investigar archivos huérfanos antes de eliminar
4. Compartir la nueva estructura con el equipo
```

#### 5.2 Archivos de Salida

Crear carpeta temporal con outputs:
```
project-architect-output/
├── informe_completo.md
├── arbol_antes.txt
├── arbol_despues.txt
├── lista_duplicados.txt
├── lista_temporales.txt
├── lista_huerfanos.txt
└── plan_reorganizacion.md
```

---

## EJEMPLO DE USO

### Entrada del Usuario

```
"Analiza y reorganiza el proyecto ~/projects/mi-app"
```

### Salida del Arquitecto

```
1. Analizando ~/projects/mi-app...
   - Encontrados 247 archivos en 32 carpetas
   - Lenguaje principal: TypeScript (Next.js)
   - Detectados: 15 imágenes dispersas, 8 scripts sin agrupar

2. Diseñando nueva estructura...
   - Propuesta: Consolidar imágenes en public/images/
   - Propuesta: Agrupar scripts en scripts/
   - Propuesta: Crear docs/ con README, PROJECT_MAP, AI_CONTEXT

3. Documentación a crear:
   - README.md (no existe)
   - PROJECT_MAP.md (no existe)
   - AI_CONTEXT.md (no existe)
   - CHANGELOG.md (no existe)

4. Plan de reorganización:
   [Mostrar plan detallado]

   ¿Proceder con la reorganización? [s/no]

5. [Si confirma]
   - Creando carpetas...
   - Moviendo archivos...
   - Creando documentación...

6. Informe completo:
   [Generar informe final con todas las secciones]
```

---

## CHECKLIST FINAL

Antes de considerar la tarea completa:

- [ ] Árbol completo capturado (antes y después)
- [ ] Todos los archivos analizados
- [ ] Duplicados detectados
- [ ] Temporales identificados
- [ ] Huérfanos marcados
- [ ] Nueva estructura diseñada
- [ ] Documentación base creada (README, PROJECT_MAP, AI_CONTEXT, CHANGELOG, TODO, DECISIONS)
- [ ] Archivos movidos (con confirmación)
- [ ] Informe completo generado
- [ ] Autoevaluación completada
- [ ] Recomendaciones documentadas

---

## NOTAS PARA LA IA

- **Paciencia y rigor**: Analizar a fondo antes de proponer cambios
- **Confirmación constante**: Mover archivos es destructivo si no se puede deshacer; siempre pedir confirmación
- **Preservar intención**: No reorganizar por estética; cada cambio debe tener una razón clara
- **Documentar todo**: El informe final es tan importante como la reorganización misma
- **Adaptabilidad**: Estas son guías, no reglas fijas. Adaptar al tipo de proyecto específico.
- **Optimizado para IA**: Una IA futura debe poder entender el proyecto rápidamente. Estructura clara = mejor performance de IA.

## ERRORES COMUNES A EVITAR

- ❌ Reorganizar sin entender primero el propósito del proyecto
- ❌ Mover archivos que rompen imports sin avisar
- ❌ Crear demasiadas carpetas vacías "para el futuro"
- ❌ Forzar una plantilla que no encaja con el proyecto
- ❌ No capturar el estado antes de empezar
- ❌ Eliminar archivos pensando que son "basura"
- ❌ Crear documentación genérica sin contexto real del proyecto

---

**Versión**: 1.0.0
**Categoría**: strategy / tools
**Autoría**: iAmasters OS
**Tipo**: Pure AI skill (sin driver script — el "driver" es el agente siguiendo este protocolo)
