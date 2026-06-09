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

# Ocorrências por município (total)
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

# Join com salários e calcula ocorrências por salário mínimo (índice)
join_com_salarios <- function(ocorrencias_mun, salarios) {
  ocorrencias_mun %>%
    left_join(salarios, by = c("NOME_MUNICIPIO" = "Município_key")) %>%
    mutate(
      ocorrencias_por_sm = round(TOTAL_OCORRENCIAS / `Salário Médio (salários mínimos)`, 2)
    ) %>%
    arrange(desc(TOTAL_OCORRENCIAS))
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