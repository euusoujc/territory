# graficos.R — funções de visualização

library(ggplot2)

cores_rubricas <- c(
  "Furto (art. 155)"          = "#1F4E79",
  "Roubo (art. 157)"          = "#C00000",
  "Lesão corporal (art. 129)" = "#ED7D31"
)

# Gráfico de barras: top 10 municípios por rubrica
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
      title    = paste("Top", top_n, "Municípios —", rubrica),
      subtitle = "Dados criminais SP 2025 (JAN–DEZ)",
      x = NULL, y = "Quantidade de Ocorrências"
    ) +
    theme_minimal(base_size = 12) +
    theme(
      plot.title         = element_text(face = "bold", size = 13, color = "#1F4E79"),
      plot.subtitle      = element_text(size = 9, color = "gray50"),
      panel.grid.major.y = element_blank(),
      panel.grid.minor   = element_blank(),
      axis.text.y        = element_text(size = 10)
    )
}

# Scatter: ocorrências vs renda — cor por faixa de renda + ggrepel
grafico_ocorrencias_vs_renda <- function(df_com_renda, top_n = 30) {
  if (!requireNamespace("ggrepel", quietly = TRUE)) install.packages("ggrepel")
  library(ggrepel)
  
  df <- df_com_renda %>%
    filter(!is.na(RENDA)) %>%
    slice_max(order_by = TOTAL_OCORRENCIAS, n = top_n) %>%
    mutate(
      FAIXA_RENDA = case_when(
        RENDA < 2500                 ~ "Baixa (< R$ 2.500)",
        RENDA >= 2500 & RENDA < 3500 ~ "Média (R$ 2.500–3.500)",
        RENDA >= 3500 & RENDA < 4500 ~ "Alta (R$ 3.500–4.500)",
        TRUE                         ~ "Muito Alta (> R$ 4.500)"
      ),
      FAIXA_RENDA = factor(FAIXA_RENDA, levels = c(
        "Baixa (< R$ 2.500)", "Média (R$ 2.500–3.500)",
        "Alta (R$ 3.500–4.500)", "Muito Alta (> R$ 4.500)"
      ))
    )
  
  cores_faixa <- c(
    "Baixa (< R$ 2.500)"        = "#C00000",
    "Média (R$ 2.500–3.500)"    = "#ED7D31",
    "Alta (R$ 3.500–4.500)"     = "#2E75B6",
    "Muito Alta (> R$ 4.500)"   = "#1F4E79"
  )
  
  ggplot(df, aes(x = RENDA, y = TOTAL_OCORRENCIAS, color = FAIXA_RENDA)) +
    geom_smooth(method = "lm", se = TRUE, color = "gray60",
                fill = "gray80", alpha = 0.2, linewidth = 0.8,
                linetype = "dashed", inherit.aes = FALSE,
                data = df, mapping = aes(x = RENDA, y = TOTAL_OCORRENCIAS)) +
    geom_point(aes(size = TOTAL_OCORRENCIAS), alpha = 0.85) +
    geom_label_repel(
      aes(label = NOME_MUNICIPIO),
      size = 2.7, fontface = "bold",
      box.padding = 0.45, point.padding = 0.3,
      max.overlaps = 25, seed = 42,
      show.legend = FALSE
    ) +
    scale_color_manual(values = cores_faixa, name = "Faixa de Renda") +
    scale_size_continuous(guide = "none") +
    scale_x_continuous(labels = scales::dollar_format(prefix = "R$ ", big.mark = ".")) +
    scale_y_continuous(
      labels = scales::comma_format(big.mark = "."),
      limits = c(0, NA)
    ) +
    labs(
      title    = "Ocorrências Totais vs Renda Média — Top 30 Municípios",
      subtitle = "Fonte renda: Censo Demográfico 2022 (IBGE) | Linha tracejada = tendência linear",
      x        = "Renda Média per capita (R$)",
      y        = "Total de Ocorrências"
    ) +
    theme_minimal(base_size = 12) +
    theme(
      plot.title      = element_text(face = "bold", size = 13, color = "#1F4E79"),
      plot.subtitle   = element_text(size = 9, color = "gray50"),
      legend.position = "bottom",
      legend.title    = element_text(face = "bold", size = 9),
      legend.text     = element_text(size = 8)
    )
}

# Top N municípios por ocorrências per capita (por 1.000 hab.)
# pop_min filtra municípios muito pequenos, cuja taxa dispara com poucos casos
grafico_top10_per_capita <- function(df_com_pop, top_n = 10, pop_min = 10000) {
  df <- df_com_pop %>%
    filter(!is.na(POPULACAO), POPULACAO >= pop_min) %>%
    slice_max(order_by = ocorrencias_por_1000_hab, n = top_n) %>%
    mutate(NOME_MUNICIPIO = reorder(NOME_MUNICIPIO, ocorrencias_por_1000_hab))

  ggplot(df, aes(x = NOME_MUNICIPIO, y = ocorrencias_por_1000_hab)) +
    geom_col(fill = "#1F4E79", width = 0.7) +
    geom_text(aes(label = scales::comma(ocorrencias_por_1000_hab, decimal.mark = ",", big.mark = ".")),
              hjust = -0.1, size = 3.2, color = "gray20") +
    coord_flip() +
    scale_y_continuous(
      labels = scales::comma_format(decimal.mark = ",", big.mark = "."),
      expand = expansion(mult = c(0, 0.15))
    ) +
    labs(
      title    = paste("Top", top_n, "Municípios — Ocorrências per Capita"),
      subtitle = paste0("Ocorrências por 1.000 habitantes | Municípios com população ≥ ",
                         scales::comma(pop_min, big.mark = ".", decimal.mark = ","), " | SP 2025"),
      x = NULL, y = "Ocorrências por 1.000 hab."
    ) +
    theme_minimal(base_size = 12) +
    theme(
      plot.title         = element_text(face = "bold", size = 13, color = "#1F4E79"),
      plot.subtitle      = element_text(size = 9, color = "gray50"),
      panel.grid.major.y = element_blank(),
      panel.grid.minor   = element_blank(),
      axis.text.y        = element_text(size = 10)
    )
}

# Top N municípios por taxa per capita de uma rubrica específica
grafico_top10_rubrica_per_capita <- function(dados_rubrica_pop, rubrica, top_n = 10, pop_min = 10000) {
  df <- dados_rubrica_pop %>%
    filter(RUBRICA == rubrica, !is.na(POPULACAO), POPULACAO >= pop_min) %>%
    slice_max(order_by = ocorrencias_por_1000_hab, n = top_n) %>%
    mutate(NOME_MUNICIPIO = reorder(NOME_MUNICIPIO, ocorrencias_por_1000_hab))

  cor <- ifelse(rubrica %in% names(cores_rubricas), cores_rubricas[[rubrica]], "#2E75B6")

  ggplot(df, aes(x = NOME_MUNICIPIO, y = ocorrencias_por_1000_hab)) +
    geom_col(fill = cor, width = 0.7) +
    geom_text(aes(label = scales::comma(ocorrencias_por_1000_hab, decimal.mark = ",", big.mark = ".")),
              hjust = -0.1, size = 3.2, color = "gray20") +
    coord_flip() +
    scale_y_continuous(
      labels = scales::comma_format(decimal.mark = ",", big.mark = "."),
      expand = expansion(mult = c(0, 0.15))
    ) +
    labs(
      title    = paste("Top", top_n, "Municípios per Capita —", rubrica),
      subtitle = paste0("Ocorrências por 1.000 habitantes | Municípios com população ≥ ",
                         scales::comma(pop_min, big.mark = ".", decimal.mark = ","), " | SP 2025"),
      x = NULL, y = "Ocorrências por 1.000 hab."
    ) +
    theme_minimal(base_size = 12) +
    theme(
      plot.title         = element_text(face = "bold", size = 13, color = "#1F4E79"),
      plot.subtitle      = element_text(size = 9, color = "gray50"),
      panel.grid.major.y = element_blank(),
      panel.grid.minor   = element_blank(),
      axis.text.y        = element_text(size = 10)
    )
}

# Painel facetado: top 5 por cada uma das top 3 rubricas
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
      plot.title         = element_text(face = "bold", size = 13, color = "#1F4E79"),
      plot.subtitle      = element_text(size = 9, color = "gray50"),
      strip.text         = element_text(face = "bold", size = 10),
      panel.grid.major.y = element_blank()
    )
}

# Histograma da distribuição de renda entre municípios
grafico_distribuicao_renda <- function(renda) {
  ggplot(renda, aes(x = RENDA)) +
    geom_histogram(binwidth = 200, fill = "#1F4E79", color = "white", alpha = 0.85) +
    geom_vline(aes(xintercept = mean(RENDA, na.rm = TRUE)),
               color = "#C00000", linetype = "dashed", linewidth = 0.8) +
    geom_vline(aes(xintercept = median(RENDA, na.rm = TRUE)),
               color = "#ED7D31", linetype = "dashed", linewidth = 0.8) +
    annotate("text", x = mean(renda$RENDA, na.rm = TRUE) + 80,
             y = Inf, vjust = 2, label = "Média", color = "#C00000", size = 3.5) +
    annotate("text", x = median(renda$RENDA, na.rm = TRUE) - 80,
             y = Inf, vjust = 2, label = "Mediana", color = "#ED7D31",
             size = 3.5, hjust = 1) +
    scale_x_continuous(labels = scales::dollar_format(prefix = "R$ ", big.mark = ".")) +
    scale_y_continuous(expand = expansion(mult = c(0, 0.05))) +
    labs(
      title    = "Distribuição da Renda Média por Município — SP",
      subtitle = "Fonte: Censo Demográfico 2022 (IBGE) | 645 municípios",
      x        = "Renda Média per capita (R$)",
      y        = "Nº de Municípios"
    ) +
    theme_minimal(base_size = 12) +
    theme(
      plot.title         = element_text(face = "bold", size = 13, color = "#1F4E79"),
      plot.subtitle      = element_text(size = 9, color = "gray50"),
      panel.grid.major.x = element_blank()
    )
}