# =============================================================================
# ARCHIVO DE INTERFAZ DE USUARIO (ui.R) - v3.0 (Profesional)
#
# Descripción: Interfaz moderna y profesional con dashboard, previsualización 
#              de datos, múltiples opciones de exportación y UX mejorada.
# =============================================================================

library(shiny)
library(bslib)
library(shinyjs)
library(DT)
library(shinyWidgets)
library(plotly)

ui <- page_navbar(
  title = "Conversor SPSS Professional v2.0",
  id = "main_navbar",
  theme = bs_theme(
    version = 5, 
    bootswatch = "flatly",
    primary = "#2C3E50",
    secondary = "#18BC9C",
    success = "#18BC9C",
    base_font = font_google("Inter")
  ),
  
  # Activar shinyjs y widgets
  useShinyjs(),
  
  # === PESTAÑA PRINCIPAL: CONVERSOR ===
  nav_panel(
    title = "📁 Conversor", 
    icon = icon("exchange-alt"),
    
    layout_sidebar(
      sidebar = sidebar(
        title = "🎛️ Panel de Control",
        width = 350,
        
        # === SECCIÓN 1: CARGA DE ARCHIVO ===
        card(
          card_header("📤 1. Cargar Archivo"),
          card_body(
            fileInput(
              "file_upload", 
              "Seleccionar archivo .sav",
              accept = c(".sav"),
              buttonLabel = "📁 Examinar",
              placeholder = "Ningún archivo seleccionado",
              width = "100%"
            ),
            # Información del archivo cargado
            conditionalPanel(
              condition = "output.file_info_available",
              div(
                style = "background-color: #f8f9fa; padding: 10px; border-radius: 5px; margin-top: 10px;",
                h6("📋 Información del archivo:", style = "margin-bottom: 5px;"),
                verbatimTextOutput("file_info", placeholder = FALSE)
              )
            )
          )
        ),
        
        # === SECCIÓN 2: PROCESAMIENTO ===
        card(
          card_header("⚙️ 2. Procesamiento"),
          card_body(
            actionButton(
              "run_conversion", 
              "🚀 Procesar Archivo", 
              icon = icon("cogs"), 
              class = "btn-primary btn-lg",
              width = "100%",
              style = "margin-bottom: 15px;"
            ),
            
            # Barra de progreso (inicialmente oculta)
            conditionalPanel(
              condition = "output.processing",
              div(
                style = "margin-top: 15px;",
                h6("📊 Progreso del procesamiento:"),
                progressBar(
                  id = "progress_bar",
                  value = 0,
                  status = "info",
                  striped = TRUE
                )
              )
            )
          )
        ),
        
        # === SECCIÓN 3: OPCIONES DE DESCARGA ===
        card(
          card_header("💾 3. Opciones de Descarga"),
          card_body(
            h6("Seleccione los formatos a descargar:"),
            
            # Checkboxes para seleccionar formatos
            div(
              style = "margin-bottom: 15px;",
              checkboxInput("download_excel", "📊 Excel (.xlsx)", value = TRUE),
              checkboxInput("download_csv", "📄 CSV (ambas versiones)", value = FALSE),
              checkboxInput("download_dictionary", "📖 Diccionario (.txt)", value = TRUE)
            ),
            
            # Botones de descarga (inicialmente deshabilitados)
            disabled(
              downloadButton(
                "export_excel", 
                "📊 Descargar Excel", 
                icon = icon("file-excel"),
                class = "btn-success",
                width = "100%",
                style = "margin-bottom: 8px;"
              )
            ),
            disabled(
              downloadButton(
                "export_csv", 
                "📄 Descargar CSV", 
                icon = icon("file-csv"),
                class = "btn-info",
                width = "100%",
                style = "margin-bottom: 8px;"
              )
            ),
            disabled(
              downloadButton(
                "export_dictionary", 
                "📖 Descargar Diccionario", 
                icon = icon("book"),
                class = "btn-warning",
                width = "100%"
              )
            )
          )
        )
      ),
      
      # === PANEL PRINCIPAL ===
      div(
        style = "padding: 20px;",
        
        # Título principal con estado
        div(
          class = "d-flex justify-content-between align-items-center mb-4",
          h2("🔄 Estado del Procesamiento", class = "mb-0"),
          uiOutput("status_badge")
        ),
        
        # Panel de estado y mensajes
        card(
          card_header("📢 Mensajes del Sistema"),
          card_body(
            uiOutput("status_display")
          )
        ),
        
        # Panel de previsualización (se muestra tras el procesamiento)
        conditionalPanel(
          condition = "output.data_processed",
          card(
            card_header("👀 Previsualización de Datos"),
            card_body(
              p("Primeras 100 filas del archivo procesado (versión con etiquetas):"),
              DT::dataTableOutput("data_preview")
            )
          )
        ),
        
        # Panel de resumen estadístico
        conditionalPanel(
          condition = "output.data_processed",
          card(
            card_header("📈 Resumen del Dataset"),
            card_body(
              fluidRow(
                column(4, uiOutput("summary_basic")),
                column(4, uiOutput("summary_variables")),
                column(4, uiOutput("summary_quality"))
              )
            )
          )
        )
      )
    )
  ),
  
  # === PESTAÑA: AYUDA Y DOCUMENTACIÓN ===
  nav_panel(
    title = "📚 Ayuda", 
    icon = icon("question-circle"),
    
    div(
      style = "padding: 30px; max-width: 1000px; margin: 0 auto;",
      
      h1("📚 Guía de Usuario - Conversor SPSS Professional"),
      
      # Instrucciones paso a paso
      card(
        card_header("🚀 Instrucciones Rápidas"),
        card_body(
          h4("¿Cómo usar esta aplicación?"),
          tags$ol(
            tags$li(strong("Cargar archivo:"), " Use el botón 'Examinar' para seleccionar su archivo .sav"),
            tags$li(strong("Procesar:"), " Haga clic en 'Procesar Archivo' y espere a que termine"),
            tags$li(strong("Previsualizar:"), " Revise los datos procesados en la tabla de previsualización"),
            tags$li(strong("Descargar:"), " Seleccione los formatos deseados y descargue sus archivos")
          )
        )
      ),
      
      # Características de la aplicación
      card(
        card_header("✨ Características"),
        card_body(
          h4("¿Qué hace esta aplicación?"),
          tags$ul(
            tags$li("🔄 ", strong("Conversión inteligente:"), " Transforma archivos SPSS (.sav) a formatos más accesibles"),
            tags$li("📊 ", strong("Doble exportación Excel:"), " Datos originales y datos con etiquetas en hojas separadas"),
            tags$li("📄 ", strong("Exportación CSV:"), " Opción adicional para máxima compatibilidad"),
            tags$li("📖 ", strong("Diccionario completo:"), " Metadatos detallados de todas las variables"),
            tags$li("🔍 ", strong("Previsualización:"), " Vea sus datos antes de descargar"),
            tags$li("📈 ", strong("Análisis automático:"), " Resumen estadístico del dataset"),
            tags$li("⚡ ", strong("Optimizado:"), " Maneja archivos grandes de manera eficiente")
          )
        )
      ),
      
      # Formatos soportados
      card(
        card_header("📁 Formatos Soportados"),
        card_body(
          h4("Entrada y Salida"),
          fluidRow(
            column(6,
              h5("📥 Formatos de Entrada:"),
              tags$ul(
                tags$li("📊 Archivos SPSS (.sav)")
              )
            ),
            column(6,
              h5("📤 Formatos de Salida:"),
              tags$ul(
                tags$li("📊 Excel (.xlsx) - Datos + Metadatos"),
                tags$li("📄 CSV (.csv) - Máxima compatibilidad"),
                tags$li("📖 Diccionario (.txt) - Documentación completa")
              )
            )
          )
        )
      ),
      
      # Solución de problemas
      card(
        card_header("🔧 Solución de Problemas"),
        card_body(
          h4("Problemas Comunes"),
          tags$dl(
            tags$dt("❌ 'El archivo no es un formato SPSS válido'"),
            tags$dd("Verifique que su archivo tenga extensión .sav y no esté corrupto."),
            
            tags$dt("⏱️ 'El procesamiento toma mucho tiempo'"),
            tags$dd("Archivos grandes pueden tardar varios minutos. Sea paciente."),
            
            tags$dt("💾 'Error al descargar archivos'"),
            tags$dd("Intente procesar el archivo nuevamente antes de descargar."),
            
            tags$dt("🔄 'La aplicación no responde'"),
            tags$dd("Recargue la página e intente con un archivo más pequeño.")
          )
        )
      )
    )
  ),
  
  # === PESTAÑA: ACERCA DE ===
  nav_panel(
    title = "ℹ️ Acerca de", 
    icon = icon("info-circle"),
    
    div(
      style = "padding: 30px; max-width: 800px; margin: 0 auto; text-align: center;",
      
      h1("🚀 Conversor SPSS Professional"),
      h3(class = "text-muted", "Versión 2.0"),
      
      br(),
      
      div(
        class = "card",
        style = "padding: 30px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white;",
        h3("✨ Aplicación Profesional de Conversión de Datos"),
        p(class = "lead", "Transforme sus archivos SPSS en formatos modernos y accesibles con un clic.")
      ),
      
      br(),
      
      fluidRow(
        column(4,
          div(class = "text-center",
            icon("rocket", style = "font-size: 48px; color: #3498db;"),
            h4("Rápido"),
            p("Procesamiento optimizado para archivos grandes")
          )
        ),
        column(4,
          div(class = "text-center",
            icon("shield-alt", style = "font-size: 48px; color: #27ae60;"),
            h4("Confiable"),
            p("Mantiene la integridad y metadatos de sus datos")
          )
        ),
        column(4,
          div(class = "text-center",
            icon("users", style = "font-size: 48px; color: #e74c3c;"),
            h4("Fácil de Usar"),
            p("Interfaz intuitiva para todos los usuarios")
          )
        )
      ),
      
      br(),
      
      card(
        card_body(
          h4("🛠️ Tecnologías Utilizadas"),
          p("Esta aplicación está construida con tecnologías modernas y robustas:"),
          tags$ul(
            class = "list-unstyled",
            tags$li("🔹 R Shiny - Framework de aplicaciones web"),
            tags$li("🔹 Haven - Lectura de archivos SPSS"),
            tags$li("🔹 Bootstrap 5 - Diseño responsivo"),
            tags$li("🔹 DT/DataTables - Tablas interactivas"),
            tags$li("🔹 WritexL - Exportación Excel optimizada")
          )
        )
      ),
      
      br(),
      
      p(class = "text-muted", 
        "Desarrollado con ❤️ para facilitar el análisis de datos científicos y sociales."
      ),
      
      p(class = "text-muted", 
        paste("© 2025 Conversor SPSS Professional - Generado el", format(Sys.Date(), "%d/%m/%Y"))
      )
    )
  )
)
