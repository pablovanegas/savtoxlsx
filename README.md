# 🚀 Conversor SPSS Professional v2.0

![Estado del Build](https://img.shields.io/badge/build-passing-brightgreen)
![Versión](https://img.shields.io/badge/version-2.0-blue)
![R Version](https://img.shields.io/badge/R-4.0%2B-green)
![Licencia](https://img.shields.io/badge/license-MIT-green)
[![GitHub Stars](https://img.shields.io/github/stars/pablovanegas/savtoxlsx?style=social)](https://github.com/pablovanegas/savtoxlsx/stargazers)

Una aplicación web profesional desarrollada en **R Shiny** para convertir archivos de datos de **SPSS (.sav)** a formatos modernos y accesibles como Excel y CSV, generando además un diccionario de datos completo y detallado.

[Image of a professional software dashboard user interface]

---

## 📋 Tabla de Contenidos

1.  [Descripción General](#-descripción-general)
2.  [✨ Características Principales](#-características-principales)
3.  [📦 Instalación y Requisitos Previos](#-instalación-y-requisitos-previos)
4.  [🎯 Uso de la Aplicación](#-uso-de-la-aplicación)
5.  [🔧 Configuración Avanzada](#-configuración-avanzada)
6.  [🛣️ Roadmap Futuro](#️-roadmap-futuro)
7.  [🤝 Contribución](#-contribución)
8.  [📄 Licencia](#-licencia)
9.  [👥 Autores y Créditos](#-autores-y-créditos)
10. [📞 Contacto y Soporte](#-contacto-y-soporte)

---

## 📖 Descripción General

`savtoxlsx` es una herramienta diseñada para investigadores, analistas y estudiantes que trabajan con datos de SPSS. A menudo, los archivos `.sav` son difíciles de compartir y utilizar fuera del ecosistema de SPSS. Esta aplicación resuelve ese problema proporcionando una interfaz web intuitiva para:

-   **Convertir** archivos `.sav` grandes de manera eficiente.
-   **Preservar** metadatos cruciales como etiquetas de variables y valores.
-   **Generar** múltiples formatos de salida listos para análisis y reportes.
-   **Explorar** los datos con una previsualización y un resumen estadístico automático.

El objetivo es cerrar la brecha entre los formatos de datos estadísticos tradicionales y las herramientas de análisis modernas.

---

## ✨ Características Principales

| Característica                 | Descripción                                                                                                                              |
| :----------------------------- | :--------------------------------------------------------------------------------------------------------------------------------------- |
| ** Conversión Inteligente** | 🔄 Lee archivos `.sav` de hasta 500 MB (configurable), preservando la integridad de los metadatos y etiquetas.                                |
| ** Salidas Múltiples** | 💾 Genera archivos **Excel (.xlsx)** con múltiples hojas (datos crudos, etiquetados, resumen), **CSV (.csv)** y un **diccionario de datos (.txt)**. |
| ** Interfaz Profesional** | 🖥️ Un dashboard moderno y responsivo construido con `bslib` (Bootstrap 5), con pestañas de ayuda y navegación clara.                      |
| ** Feedback en Tiempo Real** | ⚡ Informa al usuario con notificaciones "toast", una barra de progreso y paneles de estado dinámicos.                                    |
| ** Previsualización de Datos** | 👀 Muestra una tabla interactiva con las primeras 100 filas del dataset procesado para una validación visual inmediata.                 |
| ** Análisis Automático** | 📈 Genera un resumen estadístico del dataset (dimensiones, tipos de variables, calidad de datos) que se muestra en la interfaz.           |
| ** Código Robusto** | ⚙️ Arquitectura modular, manejo de errores específico y documentación profesional del código.                                           |

---

## 📦 Instalación y Requisitos Previos

### Requisitos Previos

-   **R**: Versión 4.0 o superior.
-   **RStudio**: Recomendado para una mejor experiencia de desarrollo.

### Instalación Automática

La forma más sencilla de poner en marcha la aplicación es usando el script de instalación incluido.

1.  **Clona o descarga** este repositorio.
2.  **Abre el proyecto** (`MVP.Rproj`) en RStudio.
3.  **Ejecuta el instalador** de dependencias desde la consola de R:
    ```r
    source("install_dependencies.R")
    ```
    Este script verificará e instalará todos los paquetes necesarios automáticamente.

---

## 🎯 Uso de la Aplicación

### Inicio Rápido

Una vez instaladas las dependencias, puedes iniciar la aplicación de dos maneras:

1.  **Usando el script de inicio:**
    ```r
    source("run_app.R")
    ```
2.  **Manualmente:**
    ```r
    shiny::runApp()
    ```

### Flujo de Conversión
[Image of a user workflow diagram for data conversion]

1.  **Cargar Archivo:**
    -   Haz clic en `📁 Examinar` en el panel de control.
    -   Selecciona tu archivo `.sav`. La información del archivo (nombre, tamaño) aparecerá debajo.

2.  **Procesar:**
    -   Haz clic en el botón `🚀 Procesar Archivo`.
    -   Una barra de progreso te mostrará el estado. Para archivos grandes, este proceso puede tardar varios minutos.

3.  **Revisar y Descargar:**
    -   Una vez completado, verás un mensaje de éxito y un resumen estadístico.
    -   La tabla de previsualización se llenará con tus datos.
    -   Selecciona los formatos que deseas (`Excel`, `CSV`, `Diccionario`).
    -   Haz clic en los botones de descarga correspondientes, que ahora estarán habilitados.

---
