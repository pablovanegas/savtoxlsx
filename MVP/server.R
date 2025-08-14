# =============================================================================
# ARCHIVO DEL SERVIDOR (server.R) - v1.0
#
# Descripción: Contiene la lógica reactiva de la aplicación.
# Changelog v1.0:
# - Se añaden las librerías 'haven' y 'tools'.
# - Se importa el nuevo 'etl_helpers.R'.
# - La carga de datos ahora detecta la extensión del archivo (.sav, .xlsx, .csv)
#   y utiliza la función de procesamiento adecuada.
# - Se crea un reactive 'diccionario_generado' para almacenar el diccionario.
# - Se añade la lógica para renderizar y gestionar la descarga del diccionario.
# =============================================================================

library(shiny)
library(readxl)
library(DT)
library(haven) # Necesaria para leer .sav
library(tools) # Necesaria para file_ext

# --- Cargar funciones auxiliares ---
source("helpers.R")
source("etl_helpers.R") # ¡Importamos nuestro nuevo módulo ETL!

server <- function(input, output, session) {
  
  # Objeto reactivo para almacenar los resultados del procesamiento del archivo
  datos_procesados <- reactiveVal(NULL)
  
  # --- 1. Procesamiento de Archivo Cargado ---
  observeEvent(input$file_upload, {
    req(input$file_upload)
    
    # Mostrar notificación al usuario
    showNotification("Procesando archivo...", type = "message", duration = 5)
    
    tryCatch({
      ext <- tools::file_ext(input$file_upload$name)
      
      if (ext == "sav") {
        # Usar nuestra nueva función del helper ETL
        resultado <- procesar_archivo_sav(input$file_upload$datapath)
        datos_procesados(resultado)
        showNotification("Archivo .sav procesado exitosamente.", type = "message")
        
      } else if (ext == "xlsx") {
        datos <- read_excel(input$file_upload$datapath)
        datos_procesados(list(datos = datos, diccionario = NULL)) # No hay diccionario para xlsx
        showNotification("Archivo .xlsx cargado.", type = "message")
        
      } else if (ext == "csv") {
        datos <- read.csv(input$file_upload$datapath)
        datos_procesados(list(datos = datos, diccionario = NULL)) # No hay diccionario para csv
        showNotification("Archivo .csv cargado.", type = "message")
        
      } else {
        stop("Formato de archivo no soportado.")
      }
      
    }, error = function(e) {
      showNotification(paste("Error al procesar el archivo:", e$message), type = "error")
      datos_procesados(NULL) # Limpiar en caso de error
    })
  })
  
  # --- 2. Renderizar UI del Selector de Años (basado en datos procesados) ---
  output$year_selector_ui <- renderUI({
    df <- datos_procesados()$datos
    if (!is.null(df) && "AÑO" %in% names(df)) {
      años_disponibles <- sort(unique(df$AÑO))
      selectInput("select_years", "Seleccionar Años para Análisis",
                  choices = años_disponibles,
                  selected = años_disponibles,
                  multiple = TRUE)
    }
  })
  
  # --- 3. Renderizar UI del Botón de Descarga del Diccionario ---
  output$download_dictionary_ui <- renderUI({
    if (!is.null(datos_procesados()$diccionario)) {
      downloadButton("export_dictionary", "Descargar Diccionario de Datos", icon = icon("book"))
    }
  })
  
  # --- 4. Cálculos Reactivos (se ejecutan al presionar el botón) ---
  resultados_analisis <- eventReactive(input$run_analysis, {
    req(datos_procesados()$datos, input$select_years)
    
    showNotification("Generando análisis demográfico...", type = "message")
    
    # Llamar a la función principal de helpers.R
    calcular_indicadores_demograficos(datos_procesados()$datos, as.numeric(input$select_years))
  })
  
  # --- 5. Renderizar Tablas y Gráficos (sin cambios) ---
  output$tabla_dependencia <- renderDT({
    req(resultados_analisis())
    datatable(resultados_analisis()$indices_dependencia, options = list(pageLength = 10))
  })
  
  output$tabla_adicionales <- renderDT({
    req(resultados_analisis())
    datatable(resultados_analisis()$indices_adicionales, options = list(pageLength = 10))
  })
  
  output$plot_dependencia <- renderPlot({
    req(resultados_analisis())
    crear_grafico_dependencia(resultados_analisis()$indices_dependencia)
  })
  
  output$plot_composicion <- renderPlot({
    req(resultados_analisis())
    crear_grafico_composicion(resultados_analisis()$datos_composicion)
  })
  
  output$plot_piramide <- renderPlot({
    req(resultados_analisis())
    crear_grafico_piramide(resultados_analisis()$datos_piramide %>% filter(AÑO %in% as.numeric(input$select_years)))
  })
  
  # --- 6. Lógica de Descarga del Diccionario ---
  output$export_dictionary <- downloadHandler(
    filename = function() {
      paste0("diccionario_de_datos_", Sys.Date(), ".txt")
    },
    content = function(file) {
      writeLines(datos_procesados()$diccionario, file)
    }
  )
}
