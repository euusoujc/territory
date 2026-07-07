# analise.R — funções de análise

library(dplyr)

# Retorna top N rubricas por volume
top_rubricas <- function(base, n = 3) {
  base %>%
    count(RUBRICA, name = "QUANTIDADE") %>%
    arrange(desc(QUANTIDADE)) %>%
    slice_head(n = n) %>%
    pull(RUBRICA)
}

# Ocorrências totais por município
ocorrencias_por_municipio <- function(base) {
  base %>%
    count(NOME_MUNICIPIO, name = "TOTAL_OCORRENCIAS") %>%
    arrange(desc(TOTAL_OCORRENCIAS))
}

# Ocorrências por município e rubrica (filtrado pelas top rubricas)
ocorrencias_por_municipio_rubrica <- function(base, rubricas) {
  base %>%
    filter(RUBRICA %in% rubricas) %>%
    count(NOME_MUNICIPIO, RUBRICA, name = "QUANTIDADE") %>%
    arrange(RUBRICA, desc(QUANTIDADE))
}

# Join com base de renda (Censo 2022) e calcula índice ocorrências/renda
join_com_renda <- function(ocorrencias_mun, renda) {
  ocorrencias_mun %>%
    left_join(renda, by = c("NOME_MUNICIPIO" = "MUNICIPIO_key")) %>%
    mutate(
      ocorrencias_por_real = round(TOTAL_OCORRENCIAS / RENDA, 4)
    ) %>%
    arrange(desc(TOTAL_OCORRENCIAS))
}

# Join com população (IBGE, Tabela 4709) e calcula taxa de ocorrências per capita
join_com_populacao <- function(ocorrencias_mun, populacao) {
  ocorrencias_mun %>%
    left_join(populacao, by = c("NOME_MUNICIPIO" = "MUNICIPIO_key")) %>%
    mutate(
      ocorrencias_por_1000_hab = round(TOTAL_OCORRENCIAS / POPULACAO * 1000, 3)
    ) %>%
    arrange(desc(ocorrencias_por_1000_hab))
}

# Ocorrências por município e rubrica com taxa per capita (por 1.000 hab.)
ocorrencias_por_municipio_rubrica_per_capita <- function(ocorr_mun_rubrica, populacao) {
  ocorr_mun_rubrica %>%
    left_join(populacao, by = c("NOME_MUNICIPIO" = "MUNICIPIO_key")) %>%
    mutate(
      ocorrencias_por_1000_hab = round(QUANTIDADE / POPULACAO * 1000, 3)
    ) %>%
    arrange(RUBRICA, desc(ocorrencias_por_1000_hab))
}

# Top 5 municípios por cada rubrica
top5_por_rubrica <- function(base, rubricas) {
  base %>%
    filter(RUBRICA %in% rubricas) %>%
    count(RUBRICA, NOME_MUNICIPIO, name = "QUANTIDADE") %>%
    group_by(RUBRICA) %>%
    slice_max(order_by = QUANTIDADE, n = 5) %>%
    ungroup() %>%
    arrange(RUBRICA, desc(QUANTIDADE))
}

# Estatísticas descritivas da renda por município
estatisticas_renda <- function(renda) {
  calcular_moda <- function(x) {
    x <- x[!is.na(x)]
    ux <- unique(x)
    ux[which.max(tabulate(match(x, ux)))]
  }
  
  data.frame(
    Estatistica = c("Média", "Mediana", "Moda", "Mínimo", "Máximo",
                    "Desvio Padrão", "1º Quartil (Q1)", "3º Quartil (Q3)"),
    Valor_R = round(c(
      mean(renda$RENDA, na.rm = TRUE),
      median(renda$RENDA, na.rm = TRUE),
      calcular_moda(round(renda$RENDA)),
      min(renda$RENDA, na.rm = TRUE),
      max(renda$RENDA, na.rm = TRUE),
      sd(renda$RENDA, na.rm = TRUE),
      quantile(renda$RENDA, 0.25, na.rm = TRUE),
      quantile(renda$RENDA, 0.75, na.rm = TRUE)
    ), 2)
  )
}

# Estatísticas descritivas de ocorrências por município
estatisticas_ocorrencias <- function(ocorr_mun) {
  calcular_moda <- function(x) {
    x <- x[!is.na(x)]
    ux <- unique(x)
    ux[which.max(tabulate(match(x, ux)))]
  }
  
  data.frame(
    Estatistica = c("Média", "Mediana", "Moda", "Mínimo", "Máximo",
                    "Desvio Padrão", "1º Quartil (Q1)", "3º Quartil (Q3)"),
    Valor = round(c(
      mean(ocorr_mun$TOTAL_OCORRENCIAS, na.rm = TRUE),
      median(ocorr_mun$TOTAL_OCORRENCIAS, na.rm = TRUE),
      calcular_moda(ocorr_mun$TOTAL_OCORRENCIAS),
      min(ocorr_mun$TOTAL_OCORRENCIAS, na.rm = TRUE),
      max(ocorr_mun$TOTAL_OCORRENCIAS, na.rm = TRUE),
      sd(ocorr_mun$TOTAL_OCORRENCIAS, na.rm = TRUE),
      quantile(ocorr_mun$TOTAL_OCORRENCIAS, 0.25, na.rm = TRUE),
      quantile(ocorr_mun$TOTAL_OCORRENCIAS, 0.75, na.rm = TRUE)
    ), 2)
  )
}