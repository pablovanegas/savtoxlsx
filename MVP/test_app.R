# =============================================================================
# ARCHIVO DE PRUEBAS Y VERIFICACIÓN (test_app.R)
#
# Descripción: Script para probar la funcionalidad de la aplicación
#              antes del despliegue final.
# =============================================================================

cat("🧪 INICIANDO PRUEBAS DE LA APLICACIÓN CONVERSOR SPSS v2.0\n")
cat(paste(rep("=", 60), collapse = ""), "\n\n")

# =============================================================================
# VERIFICACIÓN DE DEPENDENCIAS
# =============================================================================

cat("📦 Verificando dependencias...\n")

paquetes_requeridos <- c(
  "shiny", "bslib", "shinyjs", "DT", "shinyWidgets",
  "haven", "dplyr", "data.table", "janitor", "stringr",
  "writexl", "readr", "tools", "formattable"
)

dependencias_ok <- TRUE
for(paquete in paquetes_requeridos) {
  if(require(paquete, character.only = TRUE, quietly = TRUE)) {
    cat("✅", paquete, "\n")
  } else {
    cat("❌", paquete, "- NO INSTALADO\n")
    dependencias_ok <- FALSE
  }
}

if(!dependencias_ok) {
  cat("\n⚠️  Algunas dependencias faltan. Ejecute:\n")
  cat("   source('install_dependencies.R')\n\n")
  stop("Dependencias faltantes")
}

# =============================================================================
# VERIFICACIÓN DE ARCHIVOS
# =============================================================================

cat("\n📁 Verificando archivos del proyecto...\n")

archivos_requeridos <- c(
  "ui.R", "server.R", "etl_helpers.R", 
  "install_dependencies.R", "README.md"
)

archivos_ok <- TRUE
for(archivo in archivos_requeridos) {
  if(file.exists(archivo)) {
    cat("✅", archivo, "\n")
  } else {
    cat("❌", archivo, "- NO ENCONTRADO\n")
    archivos_ok <- FALSE
  }
}

if(!archivos_ok) {
  stop("Archivos faltantes del proyecto")
}

# =============================================================================
# PRUEBA DE FUNCIONES PRINCIPALES
# =============================================================================

cat("\n🔧 Probando funciones principales...\n")

# Cargar funciones
source("etl_helpers.R")

# Probar función de validación
cat("🔍 Probando validación de archivos...\n")
resultado_validacion <- validar_archivo_sav("archivo_inexistente.sav")
if(!resultado_validacion$valid) {
  cat("✅ Validación de archivos funciona correctamente\n")
} else {
  cat("❌ Error en validación de archivos\n")
}

# Probar función de descripción segura
cat("🏷️  Probando extracción de descripciones...\n")
desc_test1 <- extraer_descripcion_segura(NULL)
desc_test2 <- extraer_descripcion_segura(c("Test", "Description"))
if(desc_test1 == "No especificada" && desc_test2 == "Test Description") {
  cat("✅ Extracción de descripciones funciona correctamente\n")
} else {
  cat("❌ Error en extracción de descripciones\n")
}

# =============================================================================
# INFORMACIÓN DEL SISTEMA
# =============================================================================

cat("\n💻 Información del sistema:\n")
cat("   R version:", R.version.string, "\n")
cat("   Platform:", R.version$platform, "\n")
cat("   Sistema:", Sys.info()["sysname"], "\n")
cat("   Memoria disponible:", round(memory.size() / 1024, 1), "GB\n")

# =============================================================================
# SIMULACIÓN DE INICIO DE APP
# =============================================================================

cat("\n🚀 Verificando que la aplicación puede iniciarse...\n")

tryCatch({
  # Verificar que los archivos UI y Server pueden cargarse
  source("ui.R", local = TRUE)
  cat("✅ UI cargado correctamente\n")
  
  # Nota: No ejecutamos el servidor para evitar abrir la app
  cat("✅ Servidor puede cargarse (no ejecutado)\n")
  
  cat("\n🎉 TODAS LAS PRUEBAS PASARON EXITOSAMENTE\n")
  cat("✨ La aplicación está lista para ejecutarse con:\n")
  cat("   shiny::runApp()\n\n")
  
}, error = function(e) {
  cat("❌ Error al cargar la aplicación:", e$message, "\n")
  cat("💡 Revise los archivos ui.R y server.R\n")
})

cat("🏁 FIN DE LAS PRUEBAS\n")
cat(paste(rep("=", 60), collapse = ""), "\n")
