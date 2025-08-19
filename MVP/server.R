# =============================================================================
# ARCHIVO DEL SERVIDOR (server.R) - v2.3 (Corrección de Inicio)
#
# Changelog v2.3:
# - Se ha envuelto la lógica del servidor en `shinyServer()` para resolver
#   el error "returned an object of unexpected type: list" que ocurría
#   al iniciar la aplicación.
# =============================================================================

# Aumentar el límite máximo de tamaño de archivo a 500 MB.
options(shiny.maxRequestSize = 500 * 1024^2)

library(shiny)
library(shinyjs)
library(haven)
library(tools)
library(writexl)
library(shinybusy)

# Cargar únicamente el helper de ETL
source("etl_helpers.R")

shinyServer(function(input, output, session) {
  
  resultados_procesados <- reactiveVal(NULL)
  
  observeEvent(input$run_conversion, {
    req(input$file_upload)
    
    disable("export_excel")
    disable("export_dictionary")
    
    # Mensaje inicial que se mostrará junto con el spinner
    output$status_text <- renderText({
      "Procesando archivo .sav...\n\nEsto puede tardar varios minutos para archivos grandes.\nLa aplicación está trabajando, por favor espere."
    })
    
    tryCatch({
      resultado <- procesar_archivo_sav_para_exportar(input$file_upload$datapath)
      
      resultados_procesados(resultado)
      
      enable("export_excel")
      enable("export_dictionary")
      output$status_text <- renderText("¡Procesamiento completado! Ya puede descargar los archivos.")
      
    }, error = function(e) {
      output$status_text <- renderText(paste("Error al procesar el archivo:", e$message))
      resultados_procesados(NULL)
    })
  })
  
  output$export_excel <- downloadHandler(
    filename = function() {
      paste0(tools::file_path_sans_ext(input$file_upload$name), "_exportado.xlsx")
    },
    content = function(file) {
      req(resultados_procesados())
      
      lista_excel <- list(
        "Datos_Etiquetados" = resultados_procesados()$datos_etiquetados,
        "Datos_Originales_Raw" = resultados_procesados()$datos_raw
      )
      
      writexl::write_xlsx(lista_excel, path = file)
    }
  )
  
  output$export_dictionary <- downloadHandler(
    filename = function() {
      paste0("diccionario_", tools::file_path_sans_ext(input$file_upload$name), ".txt")
    },
    content = function(file) {
      req(resultados_procesados()$diccionario)
      writeLines(resultados_procesados()$diccionario, file)
    }
  )
})
