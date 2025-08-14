# =============================================================================
# ARCHIVO DEL SERVIDOR (server.R)
#
# Descripción: Contiene la lógica reactiva de la aplicación. Carga los datos,
#              responde a los inputs del usuario, realiza los cálculos
#              (llamando a helpers.R) y renderiza los outputs.
# =============================================================================

library(shiny)
library(readxl)
library(DT)

# --- Cargar funciones auxiliares ---
source("helpers.R")

server <- function(input, output, session) {
  
  # --- 1. Carga de Datos Reactiva ---
  datos_cargados <- reactive({
    req(input$file_upload)
    
    tryCatch({
      ext <- tools::file_ext(input$file_upload$name)
      if (ext == "csv") {
        read.csv(input$file_upload$datapath)
      } else if (ext == "xlsx") {
        read_excel(input$file_upload$datapath)
      } else {
        stop("Formato de archivo no soportado. Por favor, suba un .csv o .xlsx.")
      }
    }, error = function(e) {
      showNotification(paste("Error al leer el archivo:", e$message), type = "error")
      return(NULL)
    })
  })
  
  # --- 2. Renderizar UI del Selector de Años ---
  output$year_selector_ui <- renderUI({
    df <- datos_cargados()
    if (!is.null(df) && "AÑO" %in% names(df)) {
      años_disponibles <- sort(unique(df$AÑO))
      selectInput("select_years", "Seleccionar Años para Análisis",
                  choices = años_disponibles,
                  selected = años_disponibles,
                  multiple = TRUE)
    }
  })
  
  # --- 3. Cálculos Reactivos (se ejecutan al presionar el botón) ---
  resultados <- eventReactive(input$run_analysis, {
    req(datos_cargados(), input$select_years)
    
    showNotification("Procesando datos y generando resultados...", type = "message")
    
    # Llamar a la función principal de helpers.R
    calcular_indicadores_demograficos(datos_cargados(), as.numeric(input$select_years))
  })
  
  # --- 4. Renderizar Tablas ---
  output$tabla_dependencia <- renderDT({
    req(resultados())
    datatable(resultados()$indices_dependencia, options = list(pageLength = 5, dom = 'Bfrtip', buttons = c('copy', 'csv', 'excel')), rownames = FALSE)
  })
  
  output$tabla_adicionales <- renderDT({
    req(resultados())
    datatable(resultados()$indices_adicionales, options = list(pageLength = 5, dom = 'Bfrtip', buttons = c('copy', 'csv', 'excel')), rownames = FALSE)
  })
  
  # --- 5. Renderizar Gráficos ---
  output$plot_dependencia <- renderPlot({
    req(resultados())
    crear_grafico_dependencia(resultados()$indices_dependencia)
  })
  
  output$plot_composicion <- renderPlot({
    req(resultados())
    crear_grafico_composicion(resultados()$datos_composicion)
  })
  
  output$plot_piramide <- renderPlot({
    req(resultados())
    crear_grafico_piramide(resultados()$datos_piramide %>% filter(AÑO %in% as.numeric(input$select_years)))
  })
  
  # --- 6. Lógica de Exportación / Descarga ---
  output$export_dependencia <- downloadHandler(
    filename = function() { paste0("indices_dependencia_", Sys.Date(), ".csv") },
    content = function(file) { write.csv(resultados()$indices_dependencia, file, row.names = FALSE) }
  )
  
  output$export_adicionales <- downloadHandler(
    filename = function() { paste0("indices_adicionales_", Sys.Date(), ".csv") },
    content = function(file) { write.csv(resultados()$indices_adicionales, file, row.names = FALSE) }
  )
  
  output$export_plot_dependencia <- downloadHandler(
    filename = function() { "grafico_dependencia.png" },
    content = function(file) {
      ggsave(file, plot = crear_grafico_dependencia(resultados()$indices_dependencia), device = "png", width = 10, height = 7)
    }
  )
  
  output$export_plot_composicion <- downloadHandler(
    filename = function() { "grafico_composicion.png" },
    content = function(file) {
      ggsave(file, plot = crear_grafico_composicion(resultados()$datos_composicion), device = "png", width = 10, height = 7)
    }
  )
  
  output$export_plot_piramide <- downloadHandler(
    filename = function() { "grafico_piramide.png" },
    content = function(file) {
      ggsave(file, plot = crear_grafico_piramide(resultados()$datos_piramide %>% filter(AÑO %in% as.numeric(input$select_years))), device = "png", width = 12, height = 9)
    }
  )
}


# ejecutando la app en un launcher
shinyApp(ui = ui, server = server)
