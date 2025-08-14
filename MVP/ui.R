# =============================================================================
# ARCHIVO DE INTERFAZ DE USUARIO (ui.R)
#
# Descripción: Define la estructura y apariencia de la aplicación Shiny.
#              Utiliza bslib para un diseño moderno y limpio.
# =============================================================================

library(shiny)
library(bslib)
library(DT)

ui <- page_navbar(
  title = "Analizador Demográfico de Antioquia",
  theme = bs_theme(version = 5, bootswatch = "cerulean"),
  
  # --- Panel Lateral de Controles ---
  sidebar = sidebar(
    title = "Controles de Análisis",
    
    # 1. Selección de Archivo
    fileInput("file_upload", "Cargar Archivo de Datos (.xlsx o .csv)",
              accept = c(".csv", ".xlsx"),
              buttonLabel = "Buscar...",
              placeholder = "Ningún archivo seleccionado"),
    
    # 2. Filtro dinámico por años
    uiOutput("year_selector_ui"),
    
    # Botón para ejecutar el análisis
    actionButton("run_analysis", "Generar Análisis", icon = icon("cogs"), class = "btn-primary btn-lg")
  ),
  
  # --- Panel Principal con Resultados ---
  nav_panel(
    title = "Resultados del Análisis",
    icon = icon("chart-bar"),
    
    # Layout para organizar los outputs
    layout_column_wrap(
      width = 1/2,
      
      # --- Columna Izquierda: Tablas ---
      card(
        card_header("Tablas de Indicadores"),
        tabsetPanel(
          id = "tablas_panel",
          tabPanel("Dependencia", DTOutput("tabla_dependencia")),
          tabPanel("Evolución", DTOutput("tabla_adicionales"))
        ),
        downloadButton("export_dependencia", "Exportar Tabla Dependencia (CSV)"),
        downloadButton("export_adicionales", "Exportar Tabla Evolución (CSV)")
      ),
      
      # --- Columna Derecha: Gráficos ---
      card(
        card_header("Visualizaciones Gráficas"),
        tabsetPanel(
          id = "graficos_panel",
          tabPanel("Dependencia", plotOutput("plot_dependencia")),
          tabPanel("Composición", plotOutput("plot_composicion")),
          tabPanel("Pirámide", plotOutput("plot_piramide", height = "600px"))
        ),
        downloadButton("export_plot_dependencia", "Guardar Gráfico Dependencia (PNG)"),
        downloadButton("export_plot_composicion", "Guardar Gráfico Composición (PNG)"),
        downloadButton("export_plot_piramide", "Guardar Gráfico Pirámide (PNG)")
      )
    )
  )
)
