# =============================================================================
# ARCHIVO DE AYUDANTES ETL (etl_helpers.R)
#
# Descripción: Contiene funciones para la fase de Extracción, Transformación
#              y Carga (ETL). Se especializa en manejar archivos .sav.
# =============================================================================

library(haven)
library(dplyr)

#' Procesa un archivo .sav cargado.
#'
#' Lee el archivo .sav y genera una lista que contiene el dataframe con
#' datos etiquetados (para análisis) y el texto del diccionario de datos.
#'
#' @param ruta_archivo La ruta temporal del archivo .sav subido.
#' @return Una lista con dos elementos: `datos` (el dataframe) y `diccionario` (el texto del diccionario).
procesar_archivo_sav <- function(ruta_archivo) {
  
  # --- 1. Carga de Datos ---
  datos_raw <- haven::read_sav(ruta_archivo)
  
  # Convertir variables etiquetadas a factores para el análisis
  datos_etiquetados <- datos_raw %>%
    dplyr::mutate(across(where(is.labelled), haven::as_factor))
  
  # --- 2. Generación del Diccionario de Datos ---
  # Usamos capture.output para capturar todo lo que normalmente se imprimiría en la consola
  texto_diccionario <- capture.output({
    
    # Encabezado y Marca de Agua
    cat("=========================================================\n")
    cat("      DICCIONARIO DE DATOS AVANZADO (v2.1)\n")
    cat("=========================================================\n\n")
    cat(">>> Generado por App Analizador Demográfico el", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "<<<\n\n")
    cat(paste("Total de Observaciones:", nrow(datos_raw)), "\n")
    cat(paste("Total de Variables:", ncol(datos_raw)), "\n")
    cat("---------------------------------------------------------\n\n")
    
    # Iterar sobre cada variable
    for (i in 1:ncol(datos_raw)) {
      columna <- datos_raw[[i]]
      
      cat(paste("Variable #", i, ": ", names(datos_raw)[i]), "\n")
      cat(".........................................................\n")
      
      descripcion <- attr(columna, "label")
      cat(paste("  Descripción:", ifelse(is.null(descripcion) || nchar(descripcion) == 0, "No especificada.", descripcion)), "\n")
      
      cat(paste("  Tipo de Dato (R):", class(columna)[1]), "\n")
      
      formato_spss <- attr(columna, "format.spss")
      cat(paste("  Formato (SPSS):", ifelse(is.null(formato_spss), "No especificado.", formato_spss)), "\n")
      
      medida <- attr(columna, "measure")
      cat(paste("  Nivel de Medida:", ifelse(is.null(medida), "No especificado.", toupper(medida))), "\n")
      
      etiquetas <- attr(columna, "labels")
      if (is.null(etiquetas)) {
        cat("  Etiquetas de Valor: No tiene.\n")
      } else {
        cat("  Etiquetas de Valor:\n")
        for (valor in names(etiquetas)) {
          cat(paste("    -", etiquetas[valor], "=", valor), "\n")
        }
      }
      
      valores_perdidos <- attr(columna, "na_values")
      rango_perdido <- attr(columna, "na_range")
      if (is.null(valores_perdidos) && is.null(rango_perdido)) {
        cat("  Valores Perdidos (User): No definidos.\n")
      } else {
        cat("  Valores Perdidos (User):\n")
        if (!is.null(valores_perdidos)) {
          cat(paste("    - Valores discretos:", paste(valores_perdidos, collapse = ", ")), "\n")
        }
        if (!is.null(rango_perdido)) {
          cat(paste("    - Rango:", rango_perdido[1], "a", rango_perdido[2]), "\n")
        }
      }
      
      cat("\n---------------------------------------------------------\n\n")
    }
    
    cat("\n\n>>> Fin del Diccionario. <<<")
  })
  
  # Unir las líneas de texto en un solo string
  texto_diccionario <- paste(texto_diccionario, collapse = "\n")
  
  return(list(datos = datos_etiquetados, diccionario = texto_diccionario))
}
