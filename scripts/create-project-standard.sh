#!/bin/bash
# create-project-standard.sh
# Crea nuevo proyecto con estructura estándar de conocimiento/
# Uso: ./create-project-standard.sh [project|client] [nombre]

set -e  # Exit on error

PROJECT_TYPE=$1  # "project" o "client"
PROJECT_NAME=$2

if [ -z "$PROJECT_TYPE" ] || [ -z "$PROJECT_NAME" ]; then
    echo "Uso: $0 [project|client] [nombre]"
    echo "Ejemplo: $0 project nuevo-proyecto"
    echo "Ejemplo: $0 client cliente-nuevo"
    exit 1
fi

# Validar tipo
if [ "$PROJECT_TYPE" != "project" ] && [ "$PROJECT_TYPE" != "client" ]; then
    echo "Error: PROJECT_TYPE debe ser 'project' o 'client'"
    exit 1
fi

# Determinar directorio base
if [ "$PROJECT_TYPE" = "client" ]; then
    PROJECT_DIR="clients/$PROJECT_NAME"
else
    PROJECT_DIR="projects/$PROJECT_NAME"
fi

# Verificar si ya existe
if [ -d "$PROJECT_DIR" ]; then
    echo "⚠️  El proyecto '$PROJECT_NAME' ya existe en $PROJECT_DIR"
    echo "¿Deseas actualizar su estructura conocimiento/? (s/n)"
    read -r response
    if [ "$response" != "s" ]; then
        echo "Cancelado."
        exit 0
    fi
    UPDATE_MODE=true
else
    UPDATE_MODE=false
    # Crear directorio del proyecto
    mkdir -p "$PROJECT_DIR"
    echo "✅ Directorio creado: $PROJECT_DIR"
fi

# Crear estructura estándar de conocimiento/
CONOCIMIENTO_DIR="$PROJECT_DIR/conocimiento"

mkdir -p "$CONOCIMIENTO_DIR/notebooklm-extracted"
mkdir -p "$CONOCIMIENTO_DIR/_metadata"

echo "✅ Estructura conocimiento/ creada en $CONOCIMIENTO_DIR"

# Crear archivos base
if [ "$UPDATE_MODE" = false ] || [ ! -f "$CONOCIMIENTO_DIR/_metadata/project_info.md" ]; then
    cat > "$CONOCIMIENTO_DIR/_metadata/project_info.md" << EOF
# Metadatos del Proyecto - $PROJECT_NAME

**Nombre:** $PROJECT_NAME
**Tipo:** $PROJECT_TYPE
**Fecha creación:** $(date +%Y-%m-%d)
**Estructura:** Estándar unificada projects/clients/

## Configuración

Este proyecto usa la estructura estándar de conocimiento permanente.

### Carpetas
- \`notebooklm-extracted/\` - Contenido extraído por NotebookLM
- \`_metadata/\` - Metadatos del proyecto

### Integración
- notebooklm-extractor guardará aquí automáticamente
- conocimiento-query buscará aquí automáticamente

---
**Creado por:** create-project-standard.sh
**Fecha:** $(date +%Y-%m-%d %H:%M:%S)
EOF
    echo "✅ project_info.md creado"
fi

if [ "$UPDATE_MODE" = false ] || [ ! -f "$CONOCIMIENTO_DIR/notebooklm-extracted/00_index.md" ]; then
    cat > "$CONOCIMIENTO_DIR/notebooklm-extracted/00_index.md" << EOF
# Índice de Conocimiento - $PROJECT_NAME

**Creado:** $(date +%Y-%m-%d)
**Estructura:** Estándar unificada projects/clients/

## Contenido

*Este índice se actualizará automáticamente cuando notebooklm-extractor procese notebooks.*

## Categorías de Conocimiento

- *Sin contenido aún*

## Estadísticas
- **Notebooks procesados:** 0
- **Fuentes analizadas:** 0
- **Conceptos extraídos:** 0
- **Última actualización:** $(date +%Y-%m-%d)

---
**Sistema:** knowledge-base estándar
**Generado por:** create-project-standard.sh
EOF
    echo "✅ 00_index.md creado"
fi

# Crear .gitkeep para mantener carpetas vacías en git
touch "$CONOCIMIENTO_DIR/notebooklm-extracted/.gitkeep"
touch "$CONOCIMIENTO_DIR/_metadata/.gitkeep"

echo ""
echo "🎉 Estructura estándar creada para $PROJECT_TYPE '$PROJECT_NAME'"
echo "📍 Ubicación: $PROJECT_DIR/conocimiento/"
echo ""
echo "📂 Estructura creada:"
echo "   ├── conocimiento/"
echo "   │   ├── notebooklm-extracted/"
echo "   │   │   ├── 00_index.md"
echo "   │   │   └── .gitkeep"
echo "   │   └── _metadata/"
echo "   │       ├── project_info.md"
echo "   │       └── .gitkeep"
echo ""
echo "✅ El proyecto está listo para usar con notebooklm-extractor y conocimiento-query"
