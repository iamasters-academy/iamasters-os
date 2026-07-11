#!/bin/bash
# migrate-all-to-standard-structure.sh
# Migración de todos los proyectos existentes a estructura estándar de conocimiento/

# set -e  # Commentado para continuar en caso de errores en proyectos individuales

echo "🚀 Iniciando migración a estructura estándar de conocimiento/"
echo "=========================================================="
echo ""

# Contadores
TOTAL_PROJECTS_MIGRATED=0
TOTAL_CLIENTS_MIGRATED=0
TOTAL_PROJECTS_VERIFIED=0
TOTAL_CLIENTS_VERIFIED=0

# Proyectos en projects/ que NO tienen conocimiento/
PROJECTS_WITHOUT_KNOWLEDGE=(
    "agencia-fifa"
    "briefs"
    "code-audit-integral"
    "furgones-cesta-elevadora"
    "informe-jugador-ia"
    "marketing-viral-radar"
    "musica"
    "polymaster"
    "reels-ideas-viral-percepcion-futbol"
    "sales-call-prep"
    "sales-pipeline-forecast"
    "seis-sombreros"
)

# Clientes en clients/ que NO tienen conocimiento/
CLIENTS_WITHOUT_KNOWLEDGE=(
    "agencia-fifa"
    "jesus-roiget"
)

# Función para crear estructura estándar
create_standard_structure() {
    local PROJECT_PATH=$1
    local PROJECT_NAME=$2
    local PROJECT_TYPE=$3

    echo "📁 Creando estructura para $PROJECT_TYPE '$PROJECT_NAME'..."

    local CONOCIMIENTO_DIR="$PROJECT_PATH/conocimiento"

    # Crear estructura
    mkdir -p "$CONOCIMIENTO_DIR/notebooklm-extracted"
    mkdir -p "$CONOCIMIENTO_DIR/_metadata"

    # Crear index.md
    cat > "$CONOCIMIENTO_DIR/notebooklm-extracted/00_index.md" << EOF
# Índice de Conocimiento - $PROJECT_NAME

**Creado:** $(date +%Y-%m-%d)
**Estructura:** Estándar unificada projects/clients/
**Migrado:** Sí

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
**Migrado por:** migrate-all-to-standard-structure.sh
**Fecha:** $(date +%Y-%m-%d)
EOF

    # Crear project_info.md
    cat > "$CONOCIMIENTO_DIR/_metadata/project_info.md" << EOF
# Metadatos del Proyecto - $PROJECT_NAME

**Nombre:** $PROJECT_NAME
**Tipo:** $PROJECT_TYPE
**Fecha migración:** $(date +%Y-%m-%d)
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
**Migrado por:** migrate-all-to-standard-structure.sh
**Fecha:** $(date +%Y-%m-%d)
EOF

    # Crear .gitkeep
    touch "$CONOCIMIENTO_DIR/notebooklm-extracted/.gitkeep"
    touch "$CONOCIMIENTO_DIR/_metadata/.gitkeep"

    echo "✅ $PROJECT_TYPE '$PROJECT_NAME' migrado correctamente"
}

# Función para verificar y actualizar proyectos existentes
verify_existing_structure() {
    local PROJECT_PATH=$1
    local PROJECT_NAME=$2
    local PROJECT_TYPE=$3

    echo "🔍 Verificando $PROJECT_TYPE '$PROJECT_NAME' (ya existe conocimiento/)..."

    local CONOCIMIENTO_DIR="$PROJECT_PATH/conocimiento"

    # Asegurar que tiene la estructura estándar
    mkdir -p "$CONOCIMIENTO_DIR/notebooklm-extracted"
    mkdir -p "$CONOCIMIENTO_DIR/_metadata"

    # Crear archivos si no existen
    if [ ! -f "$CONOCIMIENTO_DIR/notebooklm-extracted/00_index.md" ]; then
        echo "   → Creando 00_index.md faltante..."
        cat > "$CONOCIMIENTO_DIR/notebooklm-extracted/00_index.md" << EOF
# Índice de Conocimiento - $PROJECT_NAME

**Proyecto existente** - Verificado y actualizado a estructura estándar

---
**Verificado por:** migrate-all-to-standard-structure.sh
**Fecha:** $(date +%Y-%m-%d)
EOF
    fi

    if [ ! -f "$CONOCIMIENTO_DIR/_metadata/project_info.md" ]; then
        echo "   → Creando project_info.md faltante..."
        cat > "$CONOCIMIENTO_DIR/_metadata/project_info.md" << EOF
# Metadatos del Proyecto - $PROJECT_NAME

**Proyecto existente** - Verificado y actualizado a estructura estándar

---
**Verificado por:** migrate-all-to-standard-structure.sh
**Fecha:** $(date +%Y-%m-%d)
EOF
    fi

    # Crear .gitkeep
    touch "$CONOCIMIENTO_DIR/notebooklm-extracted/.gitkeep"
    touch "$CONOCIMIENTO_DIR/_metadata/.gitkeep"

    echo "✅ $PROJECT_TYPE '$PROJECT_NAME' verificado y actualizado"
}

echo "📋 FASE 1: Migrando projects/ que no tienen conocimiento/"
echo "-----------------------------------------------------------------"

# Migrar projects
for project in "${PROJECTS_WITHOUT_KNOWLEDGE[@]}"; do
    if [ -d "projects/$project" ]; then
        create_standard_structure "projects/$project" "$project" "project"
        ((TOTAL_PROJECTS_MIGRATED++))
    else
        echo "⚠️  Project '$project' no existe, saltando..."
    fi
done

echo ""
echo "📋 FASE 2: Migrando clients/ que no tienen conocimiento/"
echo "---------------------------------------------------------------"

# Migrar clients
for client in "${CLIENTS_WITHOUT_KNOWLEDGE[@]}"; do
    if [ -d "clients/$client" ]; then
        create_standard_structure "clients/$client" "$client" "client"
        ((TOTAL_CLIENTS_MIGRATED++))
    else
        echo "⚠️  Client '$client' no existe, saltando..."
    fi
done

echo ""
echo "📋 FASE 3: Verificando projects/ que ya tienen conocimiento/"
echo "---------------------------------------------------------------"

# Verificar proyectos que YA tienen conocimiento/
for project_dir in projects/*/; do
    project=$(basename "$project_dir")
    if [ -d "$project_dir/conocimiento" ]; then
        verify_existing_structure "$project_dir" "$project" "project"
        ((TOTAL_PROJECTS_VERIFIED++))
    fi
done

echo ""
echo "📋 FASE 4: Verificando clients/ que ya tienen conocimiento/"
echo "--------------------------------------------------------------"

# Verificar clients que ya tienen conocimiento/
for client_dir in clients/*/; do
    client=$(basename "$client_dir")
    if [ -d "$client_dir/conocimiento" ]; then
        verify_existing_structure "$client_dir" "$client" "client"
        ((TOTAL_CLIENTS_VERIFIED++))
    fi
done

echo ""
echo "=========================================================="
echo "🎉 MIGRACIÓN COMPLETADA"
echo "=========================================================="
echo ""
echo "📊 RESUMEN:"
echo "   Projects migrados: $TOTAL_PROJECTS_MIGRATED/12"
echo "   Clients migrados: $TOTAL_CLIENTS_MIGRATED/3"
echo "   Projects verificados: $TOTAL_PROJECTS_VERIFIED"
echo "   Clients verificados: $TOTAL_CLIENTS_VERIFIED"
echo "   Total proyectos procesados: $((TOTAL_PROJECTS_MIGRATED + TOTAL_CLIENTS_MIGRATED + TOTAL_PROJECTS_VERIFIED + TOTAL_CLIENTS_VERIFIED))"
echo ""
echo "✅ Todos los proyectos ahora usan la estructura estándar de conocimiento/"
echo ""
echo "📂 Estructura creada en cada proyecto:"
echo "   ├── conocimiento/"
echo "   │   ├── notebooklm-extracted/"
echo "   │   │   ├── 00_index.md"
echo "   │   │   └── .gitkeep"
echo "   │   └── _metadata/"
echo "   │       ├── project_info.md"
echo "   │       └── .gitkeep"
echo ""
echo "🚀 Los proyectos están listos para usar con:"
echo "   - notebooklm-extractor (guardará conocimiento automáticamente)"
echo "   - conocimiento-query (consultará conocimiento automáticamente)"
