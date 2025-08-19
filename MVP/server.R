# =============================================================================
# ARCHIVO DEL SERVIDOR (server.R) - v2.0 (Conversor Dedicado)
#
# Descripción: Lógica simplificada para la conversión de archivos .sav.
# =============================================================================

# --- CONFIGURACIÓN INICIAL ---
# Aumentar el límite máximo de tamaño de archivo a 150 MB.
options(shiny.maxRequestSize = 150 * 1024^2)

library(shiny)
library(shinyjs)
library(haven)
library(tools)
library(writexl) # Necesario para exportar a .xlsx

# Cargar únicamente el helper de ETL
source("etl_helpers.R")

server <- function(input, output, session) {
  
  # Valor reactivo para almacenar los resultados del procesamiento
  resultados_procesados <- reactiveVal(NULL)
  
  # --- 1. Lógica de Procesamiento ---
  observeEvent(input$run_conversion, {
    req(input$file_upload)
    
    # Deshabilitar botones y mostrar estado
    disable("export_excel")
    disable("export_dictionary")
    output$status_text <- renderText("Procesando archivo .sav, por favor espere... Esto puede tardar varios minutos para archivos grandes.")
    
    tryCatch({
      resultado <- procesar_archivo_sav_para_exportar(input$file_upload$datapath)
      
      # Guardar los resultados
      resultados_procesados(resultado)
      
      # Habilitar botones de descarga y mostrar mensaje de éxito
      enable("export_excel")
      enable("export_dictionary")
      output$status_text <- renderText("¡Procesamiento completado! Ya puede descargar los archivos.")
      showNotification("Archivo procesado exitosamente.", type = "message")
      
    }, error = function(e) {
      output$status_text <- renderText(paste("Error al procesar el archivo:", e$message))
      showNotification("Error en el procesamiento.", type = "error")
      resultados_procesados(NULL) # Limpiar resultados en caso de error
    })
  })
  
  # --- 2. Lógica de Descarga de Excel ---
  output$export_excel <- downloadHandler(
    filename = function() {
      paste0(tools::file_path_sans_ext(input$file_upload$name), "_exportado.xlsx")
    },
    content = function(file) {
      req(resultados_procesados())
      
      # Crear una lista con los dos dataframes para las hojas de Excel
      lista_excel <- list(
        "Datos_Etiquetados" = resultados_procesados()$datos_etiquetados,
        "Datos_Originales_Raw" = resultados_procesados()$datos_raw
      )
      
      # Escribir el archivo .xlsx
      writexl::write_xlsx(lista_excel, path = file)
    }
  )
  
  # --- 3. Lógica de Descarga del Diccionario ---
  output$export_dictionary <- downloadHandler(
    filename = function() {
      paste0("diccionario_", tools::file_path_sans_ext(input$file_upload$name), ".txt")
    },
    content = function(file) {
      req(resultados_procesados()$diccionario)
      writeLines(resultados_procesados()$diccionario, file)
    }
  )
}
