# =============================================================================
# ARCHIVO DE INSTALACIÓN DE DEPENDENCIAS - Conversor SPSS Professional v2.0
#
# Descripción: Script para instalar todas las dependencias necesarias para
#              ejecutar la aplicación Shiny de conversión de archivos SPSS.
#
# Uso: Ejecute este script una sola vez antes de usar la aplicación.
#      source("install_dependencies.R")
# =============================================================================

cat("=== INSTALADOR DE DEPENDENCIAS - CONVERSOR SPSS v2.0 ===\n\n")

# Lista de paquetes requeridos para el funcionamiento completo de la aplicación
paquetes_requeridos <- c(
  # Shiny y UI/UX
  "shiny",          # Framework principal para aplicaciones web interactivas
  "bslib",          # Bootstrap 5 para diseños modernos
  "shinyjs",        # JavaScript en Shiny para interactividad avanzada
  "shinybusy",      # Indicadores de carga y progreso
  "shinydashboard", # Componentes de dashboard profesional
  "DT",             # Tablas interactivas DataTables
  "shinyWidgets",   # Widgets adicionales para mejor UX
  
  # Manipulación y procesamiento de datos
  "haven",          # Lectura de archivos SPSS, Stata, SAS
  "dplyr",          # Manipulación de datos del tidyverse
  "readr",          # Lectura rápida de archivos CSV
  "data.table",     # Procesamiento de datos de alto rendimiento
  "janitor",        # Limpieza de datos y nombres de columnas
  
  # Exportación de archivos
  "writexl",        # Escritura de archivos Excel sin Java
  "openxlsx",       # Manipulación avanzada de archivos Excel
  "readxl",         # Lectura de archivos Excel
  
  # Visualización y reportes
  "ggplot2",        # Gráficos elegantes
  "plotly",         # Gráficos interactivos
  "formattable",    # Formateo de tablas
  
  # Utilidades generales
  "tools",          # Herramientas de manipulación de archivos
  "stringr",        # Manipulación de strings
  "lubridate",      # Manipulación de fechas
  "glue"            # Interpolación de strings
)

# Función para instalar paquetes de manera inteligente
instalar_si_necesario <- function(paquetes) {
  paquetes_faltantes <- paquetes[!(paquetes %in% installed.packages()[,"Package"])]
  
  if(length(paquetes_faltantes) > 0) {
    cat("📦 Instalando paquetes faltantes:", paste(paquetes_faltantes, collapse = ", "), "\n\n")
    
    # Configurar repositorio CRAN para evitar problemas de conexión
    options(repos = c(CRAN = "https://cran.rstudio.com/"))
    
    # Instalar paquetes uno por uno para mejor seguimiento
    for(paquete in paquetes_faltantes) {
      cat("🔄 Instalando:", paquete, "...\n")
      tryCatch({
        install.packages(paquete, dependencies = TRUE, quiet = FALSE)
        cat("✅", paquete, "instalado correctamente.\n\n")
      }, error = function(e) {
        cat("❌ Error instalando", paquete, ":", e$message, "\n\n")
      })
    }
  } else {
    cat("✅ Todos los paquetes ya están instalados.\n")
  }
}

# Ejecutar instalación
cat("🚀 Iniciando verificación e instalación de dependencias...\n\n")
instalar_si_necesario(paquetes_requeridos)

# Verificación final
cat("\n=== VERIFICACIÓN FINAL ===\n")
paquetes_verificados <- sapply(paquetes_requeridos, function(x) {
  tryCatch({
    library(x, character.only = TRUE, quietly = TRUE)
    return(TRUE)
  }, error = function(e) {
    return(FALSE)
  })
})

if(all(paquetes_verificados)) {
  cat("🎉 ¡ÉXITO! Todas las dependencias están correctamente instaladas.\n")
  cat("✨ Su aplicación está lista para ser ejecutada.\n\n")
  cat("Para iniciar la aplicación, ejecute:\n")
  cat("   shiny::runApp()\n\n")
} else {
  paquetes_fallidos <- names(paquetes_verificados)[!paquetes_verificados]
  cat("⚠️  ADVERTENCIA: Los siguientes paquetes presentaron problemas:\n")
  cat("   ", paste(paquetes_fallidos, collapse = ", "), "\n")
  cat("💡 Intente instalarlos manualmente con install.packages()\n\n")
}

cat("📋 INFORMACIÓN DEL SISTEMA:\n")
cat("   R version:", R.version.string, "\n")
cat("   Platform:", R.version$platform, "\n")
cat("   Sistema:", Sys.info()["sysname"], "\n\n")

cat("=== FIN DEL INSTALADOR ===\n")
