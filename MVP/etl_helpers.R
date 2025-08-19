# =============================================================================
# ARCHIVO DE AYUDANTES ETL (etl_helpers.R) - v2.1 (Conversor Dedicado)
#
# Descripción: Funciones optimizadas para la conversión de .sav.
#              Esta es la "sala de máquinas" que realiza todo el trabajo
#              de procesamiento de datos.
# Changelog v2.1:
# - CORRECCIÓN DE ERROR: Se añadió una lógica robusta para manejar etiquetas
#   de variables que son vectores en lugar de strings únicos. Esto soluciona
#   el error "'length = X' in coercion to 'logical(1)'".
# =============================================================================

library(haven)
library(dplyr)

#' Procesa un archivo .sav y prepara los datos para la exportación.
#'
#' Lee un archivo .sav, crea una versión con etiquetas de texto, y genera
#' un diccionario de datos detallado a partir de los metadatos.
#'
#' @param ruta_archivo La ruta temporal del archivo .sav subido por el usuario.
#' @return Una lista con tres elementos:
#'         - `datos_raw`: El dataframe tal como está en el .sav (valores numéricos).
#'         - `datos_etiquetados`: El dataframe con etiquetas de valor aplicadas (factores de R).
#'         - `diccionario`: Un string de texto largo que contiene el diccionario de datos completo.
procesar_archivo_sav_para_exportar <- function(ruta_archivo) {
  
  # --- 1. Carga de Datos ---
  # Lee el archivo .sav usando la librería 'haven'.
  datos_raw <- haven::read_sav(ruta_archivo)
  
  # Crea una segunda versión del dataframe donde las variables con etiquetas
  # (ej: 1 = "Masculino", 2 = "Femenino") se convierten a texto legible.
  datos_etiquetados <- datos_raw %>%
    dplyr::mutate(across(where(is.labelled), haven::as_factor))
  
  # --- 2. Generación del Diccionario de Datos ---
  # 'capture.output' es un truco útil para capturar todo lo que la función
  # 'cat' imprimiría en la consola y guardarlo en una variable de texto.
  texto_diccionario <- capture.output({
    
    # Encabezado del archivo de texto
    cat("=========================================================\n")
    cat("      DICCIONARIO DE DATOS GENERADO POR APP\n")
    cat("=========================================================\n\n")
    cat(">>> Fecha de Generación:", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "<<<\n\n")
    cat(paste("Total de Observaciones:", nrow(datos_raw)), "\n")
    cat(paste("Total de Variables:", ncol(datos_raw)), "\n")
    cat("---------------------------------------------------------\n\n")
    
    # Bucle que recorre cada columna del dataframe
    for (i in 1:ncol(datos_raw)) {
      columna <- datos_raw[[i]]
      
      cat(paste("Variable #", i, ": ", names(datos_raw)[i]), "\n")
      cat(".........................................................\n")
      
      # Extraer y escribir cada metadato usando la función segura 'attr'
      descripcion <- attr(columna, "label")
      
      # --- INICIO DE LA CORRECCIÓN ---
      # Maneja casos donde la etiqueta (label) puede ser un vector.
      if (is.null(descripcion) || length(descripcion) == 0) {
        descripcion_final <- "No especificada."
      } else {
        # Une todas las partes de la etiqueta en un solo texto.
        descripcion_texto <- paste(descripcion, collapse = " ")
        # Verifica si el texto resultante está vacío (después de quitar espacios).
        if (nchar(trimws(descripcion_texto)) == 0) {
          descripcion_final <- "No especificada."
        } else {
          descripcion_final <- descripcion_texto
        }
      }
      cat(paste("  Descripción:", descripcion_final), "\n")
      # --- FIN DE LA CORRECCIÓN ---
      
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
      
      cat("\n---------------------------------------------------------\n\n")
    }
    
    cat("\n\n>>> Fin del Diccionario. <<<")
  })
  
  # Une todas las líneas de texto capturadas en un solo string, separado por saltos de línea.
  texto_diccionario <- paste(texto_diccionario, collapse = "\n")
  
  # Devuelve la lista final con todos los productos generados.
  return(list(
    datos_raw = datos_raw,
    datos_etiquetados = datos_etiquetados,
    diccionario = texto_diccionario
  ))
}
