# =============================================================================
# ARCHIVO DE INTERFAZ DE USUARIO (ui.R) - v2.0 (Conversor Dedicado)
#
# Descripción: Interfaz minimalista enfocada únicamente en la conversión
#              de archivos .sav a .xlsx y .txt.
# =============================================================================

library(shiny)
library(bslib)
library(shinyjs) # Necesario para habilitar/deshabilitar botones

ui <- page_fluid(
  useShinyjs(), # Activa shinyjs
  theme = bs_theme(version = 5, bootswatch = "cerulean"),
  
  layout_sidebar(
    sidebar = sidebar(
      title = "Controles",
      fileInput("file_upload", "1. Cargar Archivo .sav",
                accept = c(".sav"),
                buttonLabel = "Buscar...",
                placeholder = "Ningún archivo seleccionado"),
      
      actionButton("run_conversion", "2. Procesar Archivo", icon = icon("cogs"), class = "btn-primary btn-lg"),
      
      hr(),
      
      h5("3. Descargar Resultados"),
      # Los botones de descarga empiezan deshabilitados
      disabled(
        downloadButton("export_excel", "Descargar Excel (.xlsx)", icon = icon("file-excel"))
      ),
      br(),
      disabled(
        downloadButton("export_dictionary", "Descargar Diccionario (.txt)", icon = icon("book"))
      )
    ),
    
    # Panel principal
    card(
      card_header("Conversor de Archivos SPSS (.sav)"),
      card_body(
        p("Bienvenido al conversor de archivos de SPSS."),
        p("Instrucciones:"),
        tags$ol(
          tags$li("Cargue su archivo .sav usando el panel de la izquierda."),
          tags$li("Presione el botón 'Procesar Archivo'."),
          tags$li("Una vez que el proceso termine, los botones de descarga se activarán.")
        ),
        hr(),
        h4("Estado del Procesamiento:"),
        textOutput("status_text") # Para mostrar mensajes al usuario
      )
    )
  )
)
