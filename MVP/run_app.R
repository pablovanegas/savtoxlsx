# =============================================================================
# ARCHIVO DE INICIO RÁPIDO (run_app.R)
#
# Descripción: Script para iniciar la aplicación de manera fácil y rápida.
#              Incluye verificaciones automáticas y configuración óptima.
# =============================================================================

# Función principal para ejecutar la aplicación
ejecutar_conversor_spss <- function(puerto = NULL, host = "127.0.0.1") {
  
  cat("🚀 CONVERSOR SPSS PROFESSIONAL v2.0\n")
  cat(paste(rep("=", 50), collapse = ""), "\n\n")
  
  # Verificar dependencias críticas
  cat("📦 Verificando dependencias críticas...\n")
  dependencias_criticas <- c("shiny", "bslib", "shinyjs", "DT", "haven", "writexl")
  
  for(dep in dependencias_criticas) {
    if(!require(dep, character.only = TRUE, quietly = TRUE)) {
      cat("❌ Dependencia faltante:", dep, "\n")
      cat("💡 Ejecute: source('install_dependencies.R')\n")
      return(invisible(FALSE))
    }
  }
  cat("✅ Todas las dependencias están disponibles\n\n")
  
  # Configuración óptima de memoria
  cat("⚙️  Configurando parámetros óptimos...\n")
  options(shiny.maxRequestSize = 500 * 1024^2)  # 500 MB
  options(shiny.sanitize.errors = FALSE)        # Mostrar errores detallados
  
  # Verificar archivos principales
  if(!file.exists("ui.R") || !file.exists("server.R")) {
    cat("❌ Archivos principales no encontrados\n")
    return(invisible(FALSE))
  }
  cat("✅ Archivos principales verificados\n\n")
  
  # Verificación de sintaxis básica
  cat("🔍 Verificando sintaxis...\n")
  test_ui <- tryCatch({
    source("ui.R", local = TRUE)
    TRUE
  }, error = function(e) {
    cat("❌ Error en ui.R:", e$message, "\n")
    FALSE
  })
  
  if(!test_ui) {
    cat("💡 Revise el archivo ui.R para errores de sintaxis\n")
    return(invisible(FALSE))
  }
  cat("✅ Archivos verificados correctamente\n\n")
  
  # Información de inicio
  cat("🌐 Iniciando aplicación web...\n")
  cat("📍 Host:", host, "\n")
  if(!is.null(puerto)) {
    cat("🔌 Puerto:", puerto, "\n")
  }
  cat("💾 Límite de archivo: 500 MB\n")
  cat("⏰ Tiempo de inicio:", format(Sys.time()), "\n\n")
  
  cat("✨ Para abrir la aplicación, use Ctrl+Click en la URL que aparecerá\n")
  cat("🛑 Para detener la aplicación, presione Ctrl+C en la consola\n\n")
  
  # Ejecutar aplicación
  tryCatch({
    if(is.null(puerto)) {
      shiny::runApp(host = host)
    } else {
      shiny::runApp(host = host, port = puerto)
    }
  }, error = function(e) {
    cat("❌ Error al iniciar la aplicación:", e$message, "\n")
    cat("💡 Verifique que el puerto no esté en uso\n")
    cat("💡 Si el error persiste, ejecute: source('quick_test.R')\n")
  })
}

# Función de ayuda rápida
ayuda_rapida <- function() {
  cat("📚 AYUDA RÁPIDA - CONVERSOR SPSS PROFESSIONAL\n")
  cat(paste(rep("=", 50), collapse = ""), "\n\n")
  
  cat("🚀 INICIO:\n")
  cat("   ejecutar_conversor_spss()              # Puerto automático\n")
  cat("   ejecutar_conversor_spss(puerto = 3838) # Puerto específico\n\n")
  
  cat("📦 INSTALACIÓN:\n")
  cat("   source('install_dependencies.R')       # Instalar dependencias\n")
  cat("   source('test_app.R')                   # Probar funcionalidad\n\n")
  
  cat("📁 ARCHIVOS:\n")
  cat("   ui.R           - Interfaz de usuario\n")
  cat("   server.R       - Lógica del servidor\n")
  cat("   etl_helpers.R  - Funciones de procesamiento\n")
  cat("   README.md      - Documentación completa\n\n")
  
  cat("🔧 SOLUCIÓN DE PROBLEMAS:\n")
  cat("   1. Verificar dependencias con test_app.R\n")
  cat("   2. Revisar README.md para problemas comunes\n")
  cat("   3. Asegurar que el puerto no esté en uso\n\n")
}

# Mostrar mensaje de bienvenida al cargar
cat("🎯 CONVERSOR SPSS PROFESSIONAL v2.0 - LISTO\n")
cat("💡 Ejecute: ejecutar_conversor_spss() para iniciar\n")
cat("📚 Ejecute: ayuda_rapida() para ver comandos disponibles\n\n")
