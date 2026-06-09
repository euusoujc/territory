# graficos.R — funções de visualização

library(ggplot2)

cores_rubricas <- c(
  "Furto (art. 155)"        = "#1F4E79",
  "Roubo (art. 157)"        = "#C00000",
  "Lesão corporal (art. 129)" = "#ED7D31"
)

# Gráfico de barras: top 10 municípios por rubrica (um gráfico por rubrica)
grafico_top10_por_rubrica <- function(dados_rubrica_mun, rubrica, top_n = 10) {
  df <- dados_rubrica_mun %>%
    filter(RUBRICA == rubrica) %>%
    slice_max(order_by = QUANTIDADE, n = top_n) %>%
    mutate(NOME_MUNICIPIO = reorder(NOME_MUNICIPIO, QUANTIDADE))
  
  cor <- ifelse(rubrica %in% names(cores_rubricas), cores_rubricas[[rubrica]], "#2E75B6")
  
  ggplot(df, aes(x = NOME_MUNICIPIO, y = QUANTIDADE)) +
    geom_col(fill = cor, width = 0.7) +
    geom_text(aes(label = scales::comma(QUANTIDADE, big.mark = ".")),
              hjust = -0.1, size = 3.2, color = "gray20") +
    coord_flip() +
    scale_y_continuous(
      labels = scales::comma_format(big.mark = "."),
      expand = expansion(mult = c(0, 0.15))
    ) +
    labs(
      title = paste("Top", top_n, "Municípios —", rubrica),
      subtitle = "Dados criminais SP 2025 (JAN–DEZ)",
      x = NULL,
      y = "Quantidade de Ocorrências"
    ) +
    theme_minimal(base_size = 12) +
    theme(
      plot.title    = element_text(face = "bold", size = 13, color = "#1F4E79"),
      plot.subtitle = element_text(size = 9, color = "gray50"),
      panel.grid.major.y = element_blank(),
      panel.grid.minor   = element_blank(),
      axis.text.y = element_text(size = 10)
    )
}

# Gráfico: ocorrências vs renda — scatter por município (top 30 por volume)
grafico_ocorrencias_vs_renda <- function(df_com_salarios, top_n = 30) {
  df <- df_com_salarios %>%
    filter(!is.na(`Salário Médio (salários mínimos)`)) %>%
    slice_max(order_by = TOTAL_OCORRENCIAS, n = top_n)
  
  ggplot(df, aes(x = `Salário Médio (salários mínimos)`, y = TOTAL_OCORRENCIAS,
                 label = NOME_MUNICIPIO)) +
    geom_point(aes(size = TOTAL_OCORRENCIAS), color = "#1F4E79", alpha = 0.7) +
    geom_text(vjust = -0.8, size = 2.8, color = "gray30") +
    geom_smooth(method = "lm", se = FALSE, color = "#C00000", linewidth = 0.8, linetype = "dashed") +
    scale_y_continuous(labels = scales::comma_format(big.mark = ".")) +
    scale_size_continuous(guide = "none") +
    labs(
      title    = "Ocorrências Totais vs Renda Média — Top 30 Municípios",
      subtitle = "Linha tracejada = tendência linear | Tamanho do ponto = volume de ocorrências",
      x        = "Salário Médio (salários mínimos)",
      y        = "Total de Ocorrências"
    ) +
    theme_minimal(base_size = 12) +
    theme(
      plot.title    = element_text(face = "bold", size = 13, color = "#1F4E79"),
      plot.subtitle = element_text(size = 9, color = "gray50")
    )
}

# Gráfico: top 5 por cada uma das top 3 rubricas — facetado
grafico_top5_facetado <- function(top5_df) {
  top5_df %>%
    mutate(
      NOME_MUNICIPIO = reorder_within(NOME_MUNICIPIO, QUANTIDADE, RUBRICA),
      RUBRICA_CURTO  = case_when(
        grepl("Furto",  RUBRICA) ~ "Furto (art. 155)",
        grepl("Roubo",  RUBRICA) ~ "Roubo (art. 157)",
        grepl("Lesão",  RUBRICA) ~ "Lesão Corporal (art. 129)",
        TRUE ~ RUBRICA
      )
    ) %>%
    ggplot(aes(x = NOME_MUNICIPIO, y = QUANTIDADE, fill = RUBRICA_CURTO)) +
    geom_col(width = 0.7, show.legend = FALSE) +
    geom_text(aes(label = scales::comma(QUANTIDADE, big.mark = ".")),
              hjust = -0.1, size = 3) +
    coord_flip() +
    facet_wrap(~RUBRICA_CURTO, scales = "free_y", ncol = 1) +
    scale_x_reordered() +
    scale_y_continuous(
      labels = scales::comma_format(big.mark = "."),
      expand = expansion(mult = c(0, 0.18))
    ) +
    scale_fill_manual(values = unname(cores_rubricas)) +
    labs(
      title    = "Top 5 Municípios por Tipo de Ocorrência",
      subtitle = "Top 3 rubricas em SP 2025",
      x = NULL, y = "Quantidade"
    ) +
    theme_minimal(base_size = 11) +
    theme(
      plot.title     = element_text(face = "bold", size = 13, color = "#1F4E79"),
      plot.subtitle  = element_text(size = 9, color = "gray50"),
      strip.text     = element_text(face = "bold", size = 10),
      panel.grid.major.y = element_blank()
    )
}