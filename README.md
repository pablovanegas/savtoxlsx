🚀 Conversor SPSS Professional v2.0
Una aplicación web profesional desarrollada en R Shiny para convertir archivos de datos de SPSS (.sav) a formatos modernos y accesibles como Excel y CSV, generando además un diccionario de datos completo y detallado.

📋 Tabla de Contenidos
Descripción General

✨ Características Principales

📦 Instalación y Requisitos Previos

🎯 Uso de la Aplicación

🔧 Configuración Avanzada

🛣️ Roadmap Futuro

🤝 Contribución

📄 Licencia

👥 Autores y Créditos

📞 Contacto y Soporte

📖 Descripción General
savtoxlsx es una herramienta diseñada para investigadores, analistas y estudiantes que trabajan con datos de SPSS. A menudo, los archivos .sav son difíciles de compartir y utilizar fuera del ecosistema de SPSS. Esta aplicación resuelve ese problema proporcionando una interfaz web intuitiva para:

Convertir archivos .sav grandes de manera eficiente.

Preservar metadatos cruciales como etiquetas de variables y valores.

Generar múltiples formatos de salida listos para análisis y reportes.

Explorar los datos con una previsualización y un resumen estadístico automático.

El objetivo es cerrar la brecha entre los formatos de datos estadísticos tradicionales y las herramientas de análisis modernas.

✨ Características Principales
Característica

Descripción

** Conversión Inteligente**

🔄 Lee archivos .sav de hasta 500 MB (configurable), preservando la integridad de los metadatos y etiquetas.

** Salidas Múltiples**

💾 Genera archivos Excel (.xlsx) con múltiples hojas (datos crudos, etiquetados, resumen), CSV (.csv) y un diccionario de datos (.txt).

** Interfaz Profesional**

🖥️ Un dashboard moderno y responsivo construido con bslib (Bootstrap 5), con pestañas de ayuda y navegación clara.

** Feedback en Tiempo Real**

⚡ Informa al usuario con notificaciones "toast", una barra de progreso y paneles de estado dinámicos.

** Previsualización de Datos**

👀 Muestra una tabla interactiva con las primeras 100 filas del dataset procesado para una validación visual inmediata.

** Análisis Automático**

📈 Genera un resumen estadístico del dataset (dimensiones, tipos de variables, calidad de datos) que se muestra en la interfaz.

** Código Robusto**

⚙️ Arquitectura modular, manejo de errores específico y documentación profesional del código.

📦 Instalación y Requisitos Previos
Requisitos Previos
R: Versión 4.0 o superior.

RStudio: Recomendado para una mejor experiencia de desarrollo.

Instalación Automática
La forma más sencilla de poner en marcha la aplicación es usando el script de instalación incluido.

Clona o descarga este repositorio.

Abre el proyecto (MVP.Rproj) en RStudio.

Ejecuta el instalador de dependencias desde la consola de R:

source("install_dependencies.R")

Este script verificará e instalará todos los paquetes necesarios automáticamente.

🎯 Uso de la Aplicación
Inicio Rápido
Una vez instaladas las dependencias, puedes iniciar la aplicación de dos maneras:

Usando el script de inicio:

source("run_app.R") 

Manualmente:

shiny::runApp()
