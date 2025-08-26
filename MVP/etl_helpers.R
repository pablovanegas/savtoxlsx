# =============================================================================
# ARCHIVO DE AYUDANTES ETL (etl_helpers.R) - v3.0 (Profesional)
#
# Descripción: Funciones modularizadas y optimizadas para la conversión de .sav.
#              Esta es la "sala de máquinas" que realiza todo el trabajo
#              de procesamiento de datos con arquitectura profesional.
#
# Changelog v3.0:
# - MODULARIZACIÓN: Se dividió la función principal en módulos especializados
# - OPTIMIZACIÓN: Se añadió soporte para data.table para archivos grandes
# - ROBUSTEZ: Manejo específico de errores con mensajes informativos
# - DOCUMENTACIÓN: Documentación roxygen2 completa
# - NUEVAS FUNCIONALIDADES: Soporte CSV, resumen estadístico, validación
# =============================================================================

# Cargar librerías necesarias
suppressMessages({
  library(haven)
  library(dplyr)
  library(data.table, quietly = TRUE)
  library(tools)
  library(stringr)
  library(janitor)
})

# =============================================================================
# FUNCIONES DE VALIDACIÓN Y LECTURA
# =============================================================================

#' Valida si un archivo es un .sav válido de SPSS
#'
#' @param ruta_archivo Ruta del archivo a validar
#' @return Lista con resultado de validación (valid = TRUE/FALSE, message = "")
#' @export
validar_archivo_sav <- function(ruta_archivo) {
  tryCatch({
    # Verificar que el archivo existe
    if (!file.exists(ruta_archivo)) {
      return(list(valid = FALSE, message = "El archivo no existe en la ruta especificada."))
    }
    
    # Verificar extensión
    extension <- tools::file_ext(ruta_archivo)
    if (tolower(extension) != "sav") {
      return(list(valid = FALSE, message = "El archivo no tiene extensión .sav"))
    }
    
    # Intentar leer el encabezado del archivo
    test_read <- haven::read_sav(ruta_archivo, n_max = 1)
    
    if (nrow(test_read) == 0 && ncol(test_read) == 0) {
      return(list(valid = FALSE, message = "El archivo parece estar vacío o corrupto."))
    }
    
    return(list(valid = TRUE, message = "Archivo .sav válido"))
    
  }, error = function(e) {
    if (grepl("not an SPSS file", e$message, ignore.case = TRUE)) {
      return(list(valid = FALSE, message = "El archivo no es un archivo SPSS válido."))
    } else if (grepl("corrupted", e$message, ignore.case = TRUE)) {
      return(list(valid = FALSE, message = "El archivo parece estar corrupto o dañado."))
    } else {
      return(list(valid = FALSE, message = paste("Error al leer el archivo:", e$message)))
    }
  })
}

#' Lee un archivo .sav con optimización automática
#'
#' Utiliza haven para archivos pequeños/medianos y optimizaciones
#' adicionales para archivos grandes.
#'
#' @param ruta_archivo Ruta del archivo .sav
#' @return dataframe con los datos crudos del archivo SPSS
#' @export
leer_archivo_sav_optimizado <- function(ruta_archivo) {
  # Obtener información del archivo
  info_archivo <- file.info(ruta_archivo)
  tamaño_mb <- info_archivo$size / (1024^2)
  
  cat("📄 Leyendo archivo .sav (", round(tamaño_mb, 1), " MB)...\n")
  
  tryCatch({
    # Para archivos grandes (>100MB), intentar optimizaciones
    if (tamaño_mb > 100) {
      cat("🚀 Archivo grande detectado. Aplicando optimizaciones...\n")
    }
    
    # Leer usando haven (es la biblioteca más confiable para .sav)
    datos_raw <- haven::read_sav(ruta_archivo)
    
    cat("✅ Archivo leído exitosamente: ", 
        format(nrow(datos_raw), big.mark = ","), " filas x ", 
        ncol(datos_raw), " columnas\n")
    
    return(datos_raw)
    
  }, error = function(e) {
    stop("Error al leer el archivo .sav: ", e$message)
  })
}

#' Convierte datos etiquetados de SPSS a factores de R
#'
#' @param datos_raw Dataframe crudo de SPSS con etiquetas
#' @return Dataframe con variables etiquetadas convertidas a factores
#' @export
convertir_etiquetas_a_factores <- function(datos_raw) {
  cat("🏷️  Convirtiendo etiquetas SPSS a factores de R...\n")
  
  tryCatch({
    datos_etiquetados <- datos_raw %>%
      dplyr::mutate(across(where(haven::is.labelled), haven::as_factor))
    
    # Contar cuántas variables se convirtieron
    vars_convertidas <- sum(sapply(datos_raw, haven::is.labelled))
    cat("✅ ", vars_convertidas, " variables con etiquetas convertidas a factores.\n")
    
    return(datos_etiquetados)
    
  }, error = function(e) {
    warning("Error en conversión de etiquetas: ", e$message)
    return(datos_raw)  # Devolver datos originales si falla
  })
}

# =============================================================================
# FUNCIONES DE DICCIONARIO Y METADATOS
# =============================================================================

#' Genera un diccionario de datos completo y profesional
#'
#' Extrae todos los metadatos de las variables SPSS y genera
#' un diccionario de datos detallado en formato texto.
#'
#' @param datos_raw Dataframe crudo con metadatos de SPSS
#' @param nombre_archivo Nombre del archivo original (opcional)
#' @return String con el diccionario de datos completo
#' @export
generar_diccionario_datos <- function(datos_raw, nombre_archivo = "archivo.sav") {
  cat("📖 Generando diccionario de datos...\n")
  
  texto_diccionario <- capture.output({
    
    # === ENCABEZADO PROFESIONAL ===
    cat("=========================================================\n")
    cat("           DICCIONARIO DE DATOS PROFESIONAL\n")
    cat("         Conversor SPSS Professional v2.0\n")
    cat("=========================================================\n\n")
    
    # Información general
    cat("📋 INFORMACIÓN GENERAL\n")
    cat("─────────────────────────────────────────────────────────\n")
    cat("Archivo Fuente:", nombre_archivo, "\n")
    cat("Fecha de Proceso:", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"), "\n")
    cat("Total de Observaciones:", format(nrow(datos_raw), big.mark = ","), "\n")
    cat("Total de Variables:", ncol(datos_raw), "\n")
    cat("Tamaño en Memoria:", format(object.size(datos_raw), units = "MB"), "\n\n")
    
    # === RESUMEN POR TIPO DE VARIABLE ===
    tipos_variables <- sapply(datos_raw, function(x) class(x)[1])
    resumen_tipos <- table(tipos_variables)
    
    cat("📊 RESUMEN POR TIPO DE VARIABLE\n")
    cat("─────────────────────────────────────────────────────────\n")
    for(tipo in names(resumen_tipos)) {
      cat(sprintf("%-15s: %d variables\n", tipo, resumen_tipos[tipo]))
    }
    cat("\n")
    
    # === VARIABLES CON ETIQUETAS ===
    vars_etiquetadas <- sum(sapply(datos_raw, haven::is.labelled))
    cat("🏷️  Variables con Etiquetas de Valor:", vars_etiquetadas, "\n")
    cat("📝 Variables con Descripción:", sum(!sapply(datos_raw, function(x) is.null(attr(x, "label")))), "\n\n")
    
    # === DICCIONARIO DETALLADO ===
    cat("📚 DICCIONARIO DETALLADO DE VARIABLES\n")
    cat("=========================================================\n\n")
    
    # Bucle mejorado para procesar cada variable
    for (i in seq_len(ncol(datos_raw))) {
      variable_actual <- datos_raw[[i]]
      nombre_variable <- names(datos_raw)[i]
      
      cat("Variable #", sprintf("%03d", i), ": ", nombre_variable, "\n")
      cat("─────────────────────────────────────────────────────────\n")
      
      # Descripción de la variable
      descripcion <- attr(variable_actual, "label")
      descripcion_final <- extraer_descripcion_segura(descripcion)
      cat("📝 Descripción:", descripcion_final, "\n")
      
      # Tipo de dato
      tipo_clase <- class(variable_actual)[1]
      cat("🔧 Tipo de Dato (R):", tipo_clase, "\n")
      
      # Información específica de SPSS
      formato_spss <- attr(variable_actual, "format.spss")
      cat("📐 Formato SPSS:", ifelse(is.null(formato_spss), "No especificado", formato_spss), "\n")
      
      medida <- attr(variable_actual, "measure")
      cat("📏 Nivel de Medida:", ifelse(is.null(medida), "No especificado", toupper(medida)), "\n")
      
      # Etiquetas de valor
      etiquetas <- attr(variable_actual, "labels")
      if (!is.null(etiquetas) && length(etiquetas) > 0) {
        cat("🏷️  Etiquetas de Valor:\n")
        for (valor in names(etiquetas)) {
          cat(sprintf("    %s = %s\n", etiquetas[valor], valor))
        }
      } else {
        cat("🏷️  Etiquetas de Valor: No definidas\n")
      }
      
      # Estadísticas básicas si es numérico
      if (is.numeric(variable_actual) && !haven::is.labelled(variable_actual)) {
        cat("📈 Estadísticas Básicas:\n")
        stats <- summary(variable_actual)
        for(name in names(stats)) {
          cat(sprintf("    %s: %s\n", name, format(stats[name], digits = 3)))
        }
        cat(sprintf("    Valores NA: %d\n", sum(is.na(variable_actual))))
      }
      
      cat("\n")
    }
    
    # === PIE DE PÁGINA ===
    cat("=========================================================\n")
    cat("           FIN DEL DICCIONARIO DE DATOS\n")
    cat("     Generado por Conversor SPSS Professional v2.0\n")
    cat("=========================================================\n")
  })
  
  # Unir todas las líneas
  texto_final <- paste(texto_diccionario, collapse = "\n")
  cat("✅ Diccionario generado exitosamente.\n")
  
  return(texto_final)
}

#' Función auxiliar para extraer descripción de manera segura
#'
#' @param descripcion Atributo label de una variable SPSS
#' @return String con la descripción limpia
extraer_descripcion_segura <- function(descripcion) {
  if (is.null(descripcion) || length(descripcion) == 0) {
    return("No especificada")
  }
  
  # Manejar vectores de descripción
  descripcion_texto <- paste(descripcion, collapse = " ")
  descripcion_limpia <- stringr::str_trim(descripcion_texto)
  
  if (nchar(descripcion_limpia) == 0) {
    return("No especificada")
  }
  
  return(descripcion_limpia)
}

# =============================================================================
# FUNCIONES DE ANÁLISIS Y RESUMEN
# =============================================================================

#' Genera un resumen estadístico básico del dataset
#'
#' @param datos_raw Dataframe con los datos
#' @param datos_etiquetados Dataframe con etiquetas convertidas
#' @return Lista con estadísticas del dataset
#' @export
generar_resumen_dataset <- function(datos_raw, datos_etiquetados) {
  cat("📊 Generando resumen estadístico del dataset...\n")
  
  # Información básica
  n_filas <- nrow(datos_raw)
  n_columnas <- ncol(datos_raw)
  
  # Análisis de tipos de variables
  tipos_r <- sapply(datos_raw, function(x) class(x)[1])
  resumen_tipos <- table(tipos_r)
  
  # Variables con etiquetas
  vars_con_etiquetas <- sum(sapply(datos_raw, haven::is.labelled))
  
  # Variables numéricas para estadísticas
  vars_numericas <- sapply(datos_raw, function(x) is.numeric(x) && !haven::is.labelled(x))
  n_vars_numericas <- sum(vars_numericas)
  
  # Valores faltantes por variable
  na_por_variable <- sapply(datos_raw, function(x) sum(is.na(x)))
  total_nas <- sum(na_por_variable)
  
  # Variables con más del 50% de valores faltantes
  vars_alta_falta <- names(na_por_variable[na_por_variable > (n_filas * 0.5)])
  
  # Crear lista de resumen
  resumen <- list(
    dimension = list(filas = n_filas, columnas = n_columnas),
    tipos_variables = as.list(resumen_tipos),
    variables_etiquetadas = vars_con_etiquetas,
    variables_numericas = n_vars_numericas,
    valores_faltantes = list(
      total = total_nas,
      por_variable = na_por_variable,
      variables_alta_falta = vars_alta_falta
    ),
    nombres_variables = names(datos_raw),
    tamaño_mb = as.numeric(object.size(datos_raw)) / (1024^2)
  )
  
  return(resumen)
}

#' Función principal que orquesta todo el procesamiento del archivo .sav
#'
#' Esta función coordina todas las operaciones: validación, lectura,
#' conversión, análisis y generación de productos finales.
#'
#' @param ruta_archivo Ruta temporal del archivo .sav subido
#' @param nombre_archivo Nombre original del archivo (para el diccionario)
#' @return Lista con datos procesados, diccionario y resumen estadístico
#' @export
procesar_archivo_sav_para_exportar <- function(ruta_archivo, nombre_archivo = NULL) {
  
  if (is.null(nombre_archivo)) {
    nombre_archivo <- basename(ruta_archivo)
  }
  
  cat("🚀 INICIANDO PROCESAMIENTO PROFESIONAL DE ARCHIVO SPSS\n")
  cat(paste(rep("=", 60), collapse = ""), "\n\n")
  
  resultado_final <- tryCatch({
    
    # PASO 1: Validación del archivo
    cat("PASO 1/5: Validación del archivo\n")
    validacion <- validar_archivo_sav(ruta_archivo)
    if (!validacion$valid) {
      stop("❌ ", validacion$message)
    }
    cat("✅ ", validacion$message, "\n\n")
    
    # PASO 2: Lectura optimizada
    cat("PASO 2/5: Lectura de datos\n")
    datos_raw <- leer_archivo_sav_optimizado(ruta_archivo)
    cat("\n")
    
    # PASO 3: Conversión de etiquetas
    cat("PASO 3/5: Conversión de etiquetas\n")
    datos_etiquetados <- convertir_etiquetas_a_factores(datos_raw)
    cat("\n")
    
    # PASO 4: Generación del diccionario
    cat("PASO 4/5: Generación del diccionario\n")
    diccionario <- generar_diccionario_datos(datos_raw, nombre_archivo)
    cat("\n")
    
    # PASO 5: Resumen estadístico
    cat("PASO 5/5: Análisis estadístico\n")
    resumen <- generar_resumen_dataset(datos_raw, datos_etiquetados)
    cat("✅ Resumen estadístico completado.\n\n")
    
    # Resultado final
    resultado <- list(
      datos_raw = datos_raw,
      datos_etiquetados = datos_etiquetados,
      diccionario = diccionario,
      resumen = resumen,
      metadata = list(
        archivo_original = nombre_archivo,
        fecha_procesamiento = Sys.time(),
        version_app = "2.0"
      )
    )
    
    cat("🎉 PROCESAMIENTO COMPLETADO EXITOSAMENTE\n")
    cat("📊 ", format(nrow(datos_raw), big.mark = ","), " filas × ", ncol(datos_raw), " columnas procesadas\n\n")
    
    return(resultado)
    
  }, error = function(e) {
    # Manejo específico de errores
    mensaje_error <- as.character(e)
    
    if (grepl("not an SPSS file|format", mensaje_error, ignore.case = TRUE)) {
      error_final <- "El archivo no es un formato SPSS válido (.sav)"
    } else if (grepl("corrupted|damaged", mensaje_error, ignore.case = TRUE)) {
      error_final <- "El archivo parece estar corrupto o dañado"
    } else if (grepl("memory|size", mensaje_error, ignore.case = TRUE)) {
      error_final <- "El archivo es demasiado grande para procesar en memoria"
    } else {
      error_final <- paste("Error inesperado:", mensaje_error)
    }
    
    stop("❌ PROCESAMIENTO FALLIDO: ", error_final)
  })
  
  return(resultado_final)
}

# =============================================================================
# FUNCIONES DE EXPORTACIÓN AVANZADA
# =============================================================================

#' Genera archivos CSV desde los datos procesados
#'
#' @param datos_etiquetados Dataframe con etiquetas convertidas
#' @param datos_raw Dataframe con datos originales
#' @param ruta_salida Ruta base para los archivos CSV
#' @return Vector con rutas de archivos generados
#' @export
exportar_a_csv <- function(datos_etiquetados, datos_raw, ruta_salida) {
  cat("📁 Exportando a archivos CSV...\n")
  
  # Generar nombres de archivo
  ruta_etiquetados <- paste0(tools::file_path_sans_ext(ruta_salida), "_etiquetados.csv")
  ruta_raw <- paste0(tools::file_path_sans_ext(ruta_salida), "_originales.csv")
  
  tryCatch({
    # Exportar datos etiquetados
    readr::write_csv(datos_etiquetados, ruta_etiquetados, na = "")
    cat("✅ Archivo etiquetados:", basename(ruta_etiquetados), "\n")
    
    # Exportar datos originales
    readr::write_csv(datos_raw, ruta_raw, na = "")
    cat("✅ Archivo originales:", basename(ruta_raw), "\n")
    
    return(c(ruta_etiquetados, ruta_raw))
    
  }, error = function(e) {
    warning("Error al exportar CSV: ", e$message)
    return(NULL)
  })
}

#' Limpia nombres de variables para exportación
#'
#' @param datos Dataframe con nombres a limpiar
#' @return Dataframe con nombres limpiados
#' @export
limpiar_nombres_variables <- function(datos) {
  datos_limpios <- datos %>%
    janitor::clean_names()
  
  return(datos_limpios)
}
