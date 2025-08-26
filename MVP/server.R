# =============================================================================
# ARCHIVO DEL SERVIDOR (server.R) - v3.0 (Profesional)
#
# Descripción: Lógica del servidor completamente renovada con arquitectura
#              profesional, manejo robusto de errores, notificaciones 
#              dinámicas y funcionalidades avanzadas.
#
# Changelog v3.0:
# - ARQUITECTURA: Reestructuración completa con módulos especializados
# - UX AVANZADA: Notificaciones toast, barras de progreso, previsualización
# - ROBUSTEZ: Manejo específico de errores con mensajes informativos
# - FUNCIONALIDADES: Soporte CSV, selector de columnas, resumen estadístico
# - RENDIMIENTO: Optimizaciones para archivos grandes
# =============================================================================

# Configuración inicial del servidor
options(shiny.maxRequestSize = 500 * 1024^2)  # 500 MB máximo

# Cargar librerías necesarias en orden específico para evitar conflictos
suppressMessages({
  library(shiny)
  library(shinyjs)
  library(haven)
  library(tools)
  library(writexl)
  library(readr)
  library(dplyr)
  library(DT)          # Después de dplyr para evitar conflictos
  library(shinyWidgets) # Después de shiny
  library(formattable)
})

# Cargar módulos de procesamiento
source("etl_helpers.R")

shinyServer(function(input, output, session) {
  
  # =============================================================================
  # VARIABLES REACTIVAS PRINCIPALES
  # =============================================================================
  
  # Almacena los resultados del procesamiento
  resultados_procesados <- reactiveVal(NULL)
  
  # Estado del procesamiento
  estado_procesamiento <- reactiveVal("esperando")  # esperando, procesando, completado, error
  
  # Información del archivo cargado
  info_archivo <- reactiveVal(NULL)
  
  # =============================================================================
  # PROCESAMIENTO DE ARCHIVO CARGADO
  # =============================================================================
  
  # Mostrar información del archivo cuando se carga
  observeEvent(input$file_upload, {
    req(input$file_upload)
    
    archivo_info <- list(
      nombre = input$file_upload$name,
      tamaño = paste(round(input$file_upload$size / (1024^2), 2), "MB"),
      tipo = tools::file_ext(input$file_upload$name)
    )
    
    info_archivo(archivo_info)
  })
  
  # Output para mostrar si hay información de archivo disponible
  output$file_info_available <- reactive({
    !is.null(info_archivo())
  })
  outputOptions(output, 'file_info_available', suspendWhenHidden = FALSE)
  
  # Mostrar información del archivo
  output$file_info <- renderText({
    req(info_archivo())
    info <- info_archivo()
    paste0(
      "📄 ", info$nombre, "\n",
      "📏 Tamaño: ", info$tamaño, "\n",
      "🔧 Tipo: .", info$tipo
    )
  })
  
  # =============================================================================
  # LÓGICA PRINCIPAL DE PROCESAMIENTO
  # =============================================================================
  
  observeEvent(input$run_conversion, {
    req(input$file_upload)
    
    # Resetear estado
    estado_procesamiento("procesando")
    resultados_procesados(NULL)
    
    # Deshabilitar botones de descarga
    disable("export_excel")
    disable("export_csv")
    disable("export_dictionary")
    
    # Simular progreso inicial
    updateProgressBar(session, "progress_bar", value = 10)
    
    # Mostrar notificación de inicio
    showNotification(
      "🚀 Iniciando procesamiento del archivo...",
      type = "message",
      duration = 3
    )
    
    # Procesamiento principal
    tryCatch({
      
      # Simular pasos de progreso
      updateProgressBar(session, "progress_bar", value = 30)
      
      # Procesar archivo usando función modularizada
      resultado <- procesar_archivo_sav_para_exportar(
        ruta_archivo = input$file_upload$datapath,
        nombre_archivo = input$file_upload$name
      )
      
      updateProgressBar(session, "progress_bar", value = 90)
      
      # Éxito en el procesamiento
      resultados_procesados(resultado)
      estado_procesamiento("completado")
      
      # Completar progreso
      updateProgressBar(session, "progress_bar", value = 100)
      
      # Habilitar botones según selección del usuario
      if(input$download_excel) enable("export_excel")
      if(input$download_csv) enable("export_csv") 
      if(input$download_dictionary) enable("export_dictionary")
      
      # Notificación de éxito
      showNotification(
        "🎉 ¡Procesamiento completado exitosamente!",
        type = "success",
        duration = 5
      )
      
    }, error = function(e) {
      # Error en el procesamiento
      error_msg <- as.character(e)
      estado_procesamiento("error")
      
      # Resetear progreso
      updateProgressBar(session, "progress_bar", value = 0)
      
      # Notificación de error
      showNotification(
        paste("❌", error_msg),
        type = "error",
        duration = 10
      )
    })
  })
  
  # =============================================================================
  # OUTPUTS DINÁMICOS DE ESTADO
  # =============================================================================
  
  # Badge de estado
  output$status_badge <- renderUI({
    estado <- estado_procesamiento()
    
    switch(estado,
      "esperando" = span(class = "badge bg-secondary", "⏳ Esperando archivo"),
      "procesando" = span(class = "badge bg-info", "⚡ Procesando..."),
      "completado" = span(class = "badge bg-success", "✅ Completado"),
      "error" = span(class = "badge bg-danger", "❌ Error")
    )
  })
  
  # Display principal de estado
  output$status_display <- renderUI({
    estado <- estado_procesamiento()
    resultados <- resultados_procesados()
    
    if (estado == "esperando") {
      div(
        class = "text-center p-4",
        icon("upload", style = "font-size: 48px; color: #6c757d; margin-bottom: 20px;"),
        h4("👋 ¡Bienvenido al Conversor SPSS Professional!"),
        p(class = "text-muted", "Cargue su archivo .sav para comenzar el procesamiento."),
        p("Esta aplicación convertirá sus datos SPSS a formatos modernos como Excel y CSV,", 
          "además de generar un diccionario completo de metadatos.")
      )
    } else if (estado == "procesando") {
      div(
        class = "text-center p-4",
        icon("cogs", style = "font-size: 48px; color: #007bff; margin-bottom: 20px;"),
        h4("⚡ Procesando su archivo..."),
        p("Esto puede tardar varios minutos para archivos grandes."),
        p(class = "text-muted", "Por favor, no cierre esta ventana mientras se procesa el archivo.")
      )
    } else if (estado == "completado" && !is.null(resultados)) {
      div(
        class = "p-3",
        div(
          class = "alert alert-success",
          icon("check-circle"),
          strong(" ¡Procesamiento Completado! "),
          "Su archivo ha sido procesado exitosamente."
        ),
        h5("📊 Resumen de Procesamiento:"),
        tags$ul(
          tags$li("📄 Archivo procesado: ", strong(resultados$metadata$archivo_original)),
          tags$li("📏 Dimensiones: ", 
                  strong(format(nrow(resultados$datos_raw), big.mark = ",")), 
                  " filas × ", 
                  strong(ncol(resultados$datos_raw)), 
                  " columnas"),
          tags$li("🏷️ Variables con etiquetas: ", 
                  strong(resultados$resumen$variables_etiquetadas)),
          tags$li("🕐 Procesado el: ", 
                  strong(format(resultados$metadata$fecha_procesamiento, "%d/%m/%Y %H:%M")))
        )
      )
    } else if (estado == "error") {
      div(
        class = "p-3",
        div(
          class = "alert alert-danger",
          icon("exclamation-triangle"),
          strong(" Error en el Procesamiento "),
          br(),
          "Hubo un problema al procesar su archivo. Verifique que:",
          tags$ul(
            tags$li("El archivo tenga extensión .sav"),
            tags$li("El archivo no esté corrupto"),
            tags$li("El archivo no sea demasiado grande (>500MB)")
          )
        )
      )
    }
  })
  
  # =============================================================================
  # PREVISUALIZACIÓN DE DATOS
  # =============================================================================
  
  # Indicador de datos procesados
  output$data_processed <- reactive({
    !is.null(resultados_procesados()) && estado_procesamiento() == "completado"
  })
  outputOptions(output, 'data_processed', suspendWhenHidden = FALSE)
  
  # Tabla de previsualización
  output$data_preview <- DT::renderDataTable({
    req(resultados_procesados())
    
    datos <- resultados_procesados()$datos_etiquetados
    
    # Tomar solo las primeras 100 filas para rendimiento
    datos_preview <- head(datos, 100)
    
    DT::datatable(
      datos_preview,
      options = list(
        pageLength = 10,
        scrollX = TRUE,
        scrollY = "400px",
        dom = 'frtip',
        columnDefs = list(
          list(className = 'dt-center', targets = '_all')
        )
      ),
      class = "table-bordered table-striped",
      caption = "Nota: Se muestran únicamente las primeras 100 filas por rendimiento."
    )
  })
  
  # =============================================================================
  # PANELES DE RESUMEN ESTADÍSTICO
  # =============================================================================
  
  # Resumen básico
  output$summary_basic <- renderUI({
    req(resultados_procesados())
    resumen <- resultados_procesados()$resumen
    
    div(
      h5("📋 Información Básica"),
      tags$ul(
        class = "list-unstyled",
        tags$li("📊 Filas: ", strong(format(resumen$dimension$filas, big.mark = ","))),
        tags$li("📈 Columnas: ", strong(resumen$dimension$columnas)),
        tags$li("💾 Tamaño: ", strong(round(resumen$tamaño_mb, 2), " MB"))
      )
    )
  })
  
  # Resumen de variables
  output$summary_variables <- renderUI({
    req(resultados_procesados())
    resumen <- resultados_procesados()$resumen
    
    div(
      h5("🔧 Tipos de Variables"),
      tags$ul(
        class = "list-unstyled",
        lapply(names(resumen$tipos_variables), function(tipo) {
          tags$li(paste0(tipo, ": "), strong(resumen$tipos_variables[[tipo]]))
        })
      )
    )
  })
  
  # Calidad de datos
  output$summary_quality <- renderUI({
    req(resultados_procesados())
    resumen <- resultados_procesados()$resumen
    
    pct_faltantes <- round((resumen$valores_faltantes$total / 
                           (resumen$dimension$filas * resumen$dimension$columnas)) * 100, 2)
    
    div(
      h5("✅ Calidad de Datos"),
      tags$ul(
        class = "list-unstyled",
        tags$li("🏷️ Con etiquetas: ", strong(resumen$variables_etiquetadas)),
        tags$li("📊 Numéricas: ", strong(resumen$variables_numericas)),
        tags$li("❓ Valores faltantes: ", strong(paste0(pct_faltantes, "%")))
      )
    )
  })
  
  # =============================================================================
  # INDICADORES DE PROGRESO
  # =============================================================================
  
  # Indicador de procesamiento activo
  output$processing <- reactive({
    estado_procesamiento() == "procesando"
  })
  outputOptions(output, 'processing', suspendWhenHidden = FALSE)
  
  # =============================================================================
  # HANDLERS DE DESCARGA AVANZADOS
  # =============================================================================
  
  # Descarga Excel con múltiples hojas
  output$export_excel <- downloadHandler(
    filename = function() {
      if(!is.null(input$file_upload)) {
        paste0(tools::file_path_sans_ext(input$file_upload$name), "_profesional.xlsx")
      } else {
        "datos_spss_profesional.xlsx"
      }
    },
    content = function(file) {
      req(resultados_procesados())
      
      resultados <- resultados_procesados()
      
      # Preparar lista para Excel con múltiples hojas
      lista_excel <- list(
        "📊_Datos_Etiquetados" = resultados$datos_etiquetados,
        "📋_Datos_Originales" = resultados$datos_raw,
        "📈_Resumen_Estadistico" = crear_hoja_resumen(resultados$resumen),
        "📖_Info_Variables" = crear_hoja_variables(resultados$datos_raw)
      )
      
      # Exportar con formato profesional
      tryCatch({
        writexl::write_xlsx(lista_excel, path = file)
        
        showNotification(
          "📊 Archivo Excel descargado correctamente",
          type = "success",
          duration = 3
        )
      }, error = function(e) {
        showNotification(
          paste("❌ Error al crear Excel:", e$message),
          type = "error",
          duration = 5
        )
      })
    }
  )
  
  # Descarga CSV (múltiples archivos comprimidos)
  output$export_csv <- downloadHandler(
    filename = function() {
      if(!is.null(input$file_upload)) {
        paste0(tools::file_path_sans_ext(input$file_upload$name), "_csv_bundle.zip")
      } else {
        "datos_spss_csv.zip"
      }
    },
    content = function(file) {
      req(resultados_procesados())
      
      resultados <- resultados_procesados()
      
      # Crear directorio temporal
      temp_dir <- tempdir()
      base_name <- tools::file_path_sans_ext(input$file_upload$name)
      
      # Archivos CSV a crear
      archivo_etiquetados <- paste0(base_name, "_etiquetados.csv")
      archivo_originales <- paste0(base_name, "_originales.csv")
      
      archivos_csv <- list()
      archivos_csv[[archivo_etiquetados]] <- resultados$datos_etiquetados
      archivos_csv[[archivo_originales]] <- resultados$datos_raw
      
      # Crear archivos CSV
      archivos_creados <- c()
      for(nombre_archivo in names(archivos_csv)) {
        ruta_completa <- file.path(temp_dir, nombre_archivo)
        readr::write_csv(archivos_csv[[nombre_archivo]], ruta_completa, na = "")
        archivos_creados <- c(archivos_creados, ruta_completa)
      }
      
      # Crear archivo ZIP
      zip(file, archivos_creados, flags = "-j")
      
      showNotification(
        "📄 Archivos CSV descargados en ZIP",
        type = "success",
        duration = 3
      )
    }
  )
  
  # Descarga diccionario mejorado
  output$export_dictionary <- downloadHandler(
    filename = function() {
      if(!is.null(input$file_upload)) {
        paste0("diccionario_", tools::file_path_sans_ext(input$file_upload$name), ".txt")
      } else {
        "diccionario_datos.txt"
      }
    },
    content = function(file) {
      req(resultados_procesados())
      
      diccionario_texto <- resultados_procesados()$diccionario
      
      tryCatch({
        writeLines(diccionario_texto, file, useBytes = TRUE)
        
        showNotification(
          "📖 Diccionario descargado correctamente",
          type = "success",
          duration = 3
        )
      }, error = function(e) {
        showNotification(
          paste("❌ Error al crear diccionario:", e$message),
          type = "error",
          duration = 5
        )
      })
    }
  )
  
  # =============================================================================
  # FUNCIONES AUXILIARES PARA EXCEL
  # =============================================================================
  
  # Crear hoja de resumen estadístico para Excel
  crear_hoja_resumen <- function(resumen) {
    data.frame(
      Caracteristica = c(
        "Total de Filas",
        "Total de Columnas", 
        "Variables con Etiquetas",
        "Variables Numéricas",
        "Tamaño en MB",
        "Total Valores Faltantes",
        "Porcentaje Datos Completos"
      ),
      Valor = c(
        format(resumen$dimension$filas, big.mark = ","),
        resumen$dimension$columnas,
        resumen$variables_etiquetadas,
        resumen$variables_numericas,
        round(resumen$tamaño_mb, 2),
        format(resumen$valores_faltantes$total, big.mark = ","),
        paste0(round((1 - resumen$valores_faltantes$total / 
                     (resumen$dimension$filas * resumen$dimension$columnas)) * 100, 2), "%")
      ),
      stringsAsFactors = FALSE
    )
  }
  
  # Crear hoja de información de variables para Excel
  crear_hoja_variables <- function(datos_raw) {
    info_variables <- data.frame(
      Variable = names(datos_raw),
      Tipo_R = sapply(datos_raw, function(x) class(x)[1]),
      Tiene_Etiquetas = sapply(datos_raw, haven::is.labelled),
      Valores_Faltantes = sapply(datos_raw, function(x) sum(is.na(x))),
      Descripcion = sapply(datos_raw, function(x) {
        desc <- attr(x, "label")
        if(is.null(desc) || length(desc) == 0) return("No especificada")
        paste(desc, collapse = " ")
      }),
      stringsAsFactors = FALSE
    )
    
    return(info_variables)
  }
  
}
)  # Fin de shinyServer
