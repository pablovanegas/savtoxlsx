# =============================================================================
# ARCHIVO DE FUNCIONES AUXILIARES (helpers.R) - v2.0 (Compatibilidad)
#
# Descripción: Funciones auxiliares para análisis demográfico.
#              Mantenido por compatibilidad con versiones anteriores.
#              En la v2.0 Professional, estas funciones son opcionales.
# =============================================================================

library(dplyr)
library(ggplot2)
library(tidyr)
library(scales)

#' Calcula todos los indicadores demográficos a partir de los datos crudos.
#'
#' @param datos_crudos Un dataframe con la estructura: AÑO, GENERO, EDAD, VALOR, ÁREA GEOGRÁFICA.
#' @param años_seleccionados Un vector de años para filtrar y analizar.
#' @return Una lista con varios dataframes: indices_dependencia, indices_adicionales, y datos_composicion.
calcular_indicadores_demograficos <- function(datos_crudos, años_seleccionados) {
  
  # --- 1. Análisis de Dependencia ---
  df_dependencia <- datos_crudos %>%
    filter(AÑO %in% años_seleccionados) %>%
    mutate(
      GRUPO_ETARIO = case_when(
        EDAD <= 14 ~ "0-14",
        EDAD >= 15 & EDAD <= 64 ~ "15-64",
        EDAD >= 65 ~ "65+",
        TRUE ~ NA_character_
      )
    )
  
  poblacion_absoluta <- df_dependencia %>%
    group_by(AÑO, GRUPO_ETARIO) %>%
    summarise(VALOR = sum(VALOR, na.rm = TRUE), .groups = 'drop') %>%
    pivot_wider(names_from = GRUPO_ETARIO, values_from = VALOR)
  
  indices_dependencia <- poblacion_absoluta %>%
    mutate(
      `Dependencia Infantil` = (`0-14` / `15-64`) * 100,
      `Dependencia Mayores` = (`65+` / `15-64`) * 100,
      `Dependencia Económica` = `Dependencia Infantil` + `Dependencia Mayores`
    ) %>%
    select(AÑO, `Dependencia Infantil`, `Dependencia Mayores`, `Dependencia Económica`) %>%
    pivot_longer(-AÑO, names_to = "Indice", values_to = "Valor")
  
  # --- 2. Índices Adicionales (Envejecimiento, Mediana, Masculinidad) ---
  indices_adicionales <- datos_crudos %>%
    group_by(AÑO) %>%
    summarise(
      pob_infantil = sum(VALOR[EDAD <= 14], na.rm = TRUE),
      pob_mayor_60 = sum(VALOR[EDAD >= 60], na.rm = TRUE),
      pob_hombres = sum(VALOR[GENERO == "HOMBRES"], na.rm = TRUE),
      pob_mujeres = sum(VALOR[GENERO == "MUJERES"], na.rm = TRUE),
      
      `Índice de Envejecimiento` = if_else(pob_infantil > 0, (pob_mayor_60 / pob_infantil) * 100, 0),
      `Índice de Masculinidad` = if_else(pob_mujeres > 0, (pob_hombres / pob_mujeres) * 100, 0),
      `Mediana de Edad` = median(rep(EDAD, VALOR)),
      .groups = 'drop'
    ) %>%
    select(AÑO, `Índice de Envejecimiento`, `Índice de Masculinidad`, `Mediana de Edad`) %>%
    pivot_longer(-AÑO, names_to = "Indice", values_to = "Valor")
  
  # --- 3. Datos para Composición y Pirámide ---
  datos_composicion <- df_dependencia # Ya tiene los grupos etarios
  
  # --- 4. Datos Urbano/Rural ---
  if ("ÁREA GEOGRÁFICA" %in% names(datos_crudos)) {
    datos_urbano_rural <- datos_crudos %>%
      filter(AÑO %in% años_seleccionados) %>%
      mutate(TIPO_AREA = case_when(
        `ÁREA GEOGRÁFICA` %in% c("Cabecera", "Urbano") ~ "Urbano",
        `ÁREA GEOGRÁFICA` %in% c("Resto", "Rural") ~ "Rural",
        TRUE ~ NA_character_
      )) %>%
      filter(!is.na(TIPO_AREA))
  } else {
    datos_urbano_rural <- data.frame()
  }
  
  return(list(
    indices_dependencia = indices_dependencia,
    indices_adicionales = indices_adicionales,
    datos_composicion = datos_composicion,
    datos_piramide = datos_crudos, # La pirámide necesita datos sin agrupar
    datos_urbano_rural = datos_urbano_rural
  ))
}

# --- Funciones de Graficación ---

#' Gráfico de Evolución de Índices de Dependencia
crear_grafico_dependencia <- function(datos_filtrados) {
  ggplot(datos_filtrados, aes(x = AÑO, y = Valor, color = Indice, group = Indice)) +
    geom_line(linewidth = 1.5) +
    geom_point(size = 4) +
    geom_text(aes(label = sprintf("%.1f%%", Valor)), vjust = -1, show.legend = FALSE) +
    labs(
      title = "Evolución de los Índices de Dependencia en Antioquia",
      y = "Dependientes por cada 100 personas (15-64 años)",
      x = "Año",
      color = "Índice"
    ) +
    theme_minimal(base_size = 15)
}

#' Gráfico de Composición Poblacional
crear_grafico_composicion <- function(datos_filtrados) {
  datos_plot <- datos_filtrados %>%
    group_by(AÑO, GRUPO_ETARIO) %>%
    summarise(Total = sum(VALOR, na.rm = TRUE), .groups = 'drop') %>%
    group_by(AÑO) %>%
    mutate(Porcentaje = Total / sum(Total) * 100)
  
  ggplot(datos_plot, aes(x = factor(AÑO), y = Porcentaje, fill = GRUPO_ETARIO)) +
    geom_bar(stat = "identity", position = "stack") +
    labs(
      title = "Composición Poblacional por Grandes Grupos de Edad",
      x = "Año",
      y = "Distribución Porcentual (%)",
      fill = "Grupo Etario"
    ) +
    scale_y_continuous(labels = percent_format(scale = 1)) +
    theme_minimal(base_size = 15)
}

#' Gráfico de Pirámide Poblacional
crear_grafico_piramide <- function(datos_filtrados) {
  datos_plot <- datos_filtrados %>%
    group_by(AÑO, EDAD, GENERO) %>%
    summarise(Poblacion = sum(VALOR, na.rm = TRUE), .groups = 'drop') %>%
    mutate(Poblacion = if_else(GENERO == "HOMBRES", -Poblacion, Poblacion))
  
  ggplot(datos_plot, aes(x = Poblacion, y = EDAD, fill = GENERO)) +
    geom_bar(stat = "identity") +
    facet_wrap(~AÑO, ncol = 2) +
    scale_x_continuous(labels = function(x) scales::comma(abs(x))) +
    labs(
      title = "Transformación Demográfica Comparativa",
      x = "Población",
      y = "Edad",
      fill = "Género"
    ) +
    theme_minimal(base_size = 15)
}