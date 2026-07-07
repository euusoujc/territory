# =============================================================
# main.R — Pipeline principal de análise criminal SP 2025
# =============================================================
# Estrutura:
#   src/utils.R    → normalização de nomes de municípios
#   src/analise.R  → funções de agregação e cruzamento
#   src/graficos.R → funções de visualização (ggplot2)
#   docs/          → bases de dados e outputs
# =============================================================

# ----- 0. Dependências ----------------------------------------
pacotes <- c("readxl", "openxlsx", "dplyr", "ggplot2", "tidytext",
             "scales", "stringi", "patchwork", "ggrepel")
novos <- pacotes[!sapply(pacotes, requireNamespace, quietly = TRUE)]
if (length(novos)) install.packages(novos)
invisible(lapply(pacotes, library, character.only = TRUE))

# ----- 1. Caminhos --------------------------------------------
DIR_SRC  <- "C:/Users/User/Documents/territory/src"
DIR_DOCS <- "C:/Users/User/Documents/territory/docs"
DIR_ROOT <- dirname(DIR_DOCS)
OUT_DIR  <- DIR_DOCS

source(file.path(DIR_SRC, "utils.R"))
source(file.path(DIR_SRC, "analise.R"))
source(file.path(DIR_SRC, "graficos.R"))

# ----- 2. Leitura das bases -----------------------------------
base  <- read_excel(file.path(DIR_DOCS, "base_tratada_2025.xlsx"))
renda <- read_excel(file.path(DIR_DOCS, "Renda_por_Municipio_-_SP.xlsx"))

cat(sprintf("Base criminal: %s linhas | %s municípios únicos\n",
            format(nrow(base), big.mark = "."),
            base$NOME_MUNICIPIO |> unique() |> length()))
cat(sprintf("Base renda: %s municípios\n", nrow(renda)))

populacao <- read.csv(file.path(DIR_ROOT, "tabela4709.csv"),
                       fileEncoding = "UTF-8-BOM", stringsAsFactors = FALSE)
colnames(populacao) <- c("COD_IBGE", "MUNICIPIO", "POPULACAO")
populacao <- populacao[grepl("\\(SP\\)$", populacao$MUNICIPIO), ]
cat(sprintf("Base população (IBGE): %s municípios SP\n", nrow(populacao)))

# ----- 3. Normalização ----------------------------------------
base$NOME_MUNICIPIO <- aplicar_abreviacoes(normalizar_municipio(base$NOME_MUNICIPIO))
renda$MUNICIPIO_key <- normalizar_municipio(renda$MUNICIPIO)
populacao$MUNICIPIO_key <- aplicar_abreviacoes(normalizar_municipio(populacao$MUNICIPIO))

# ----- 4. Análises --------------------------------------------
top3              <- top_rubricas(base, n = 3)
ocorr_mun         <- ocorrencias_por_municipio(base)
ocorr_com_renda   <- join_com_renda(ocorr_mun, renda)
ocorr_com_pop     <- join_com_populacao(ocorr_mun, populacao)
top5_rubrica      <- top5_por_rubrica(base, top3)
ocorr_por_rubrica <- ocorrencias_por_municipio_rubrica(base, top3)
ocorr_rubrica_pop <- ocorrencias_por_municipio_rubrica_per_capita(ocorr_por_rubrica, populacao)
stats_renda       <- estatisticas_renda(renda)
stats_ocorr       <- estatisticas_ocorrencias(ocorr_mun)

cat("\nTop 3 rubricas:\n")
print(top3)

cat("\nEstatísticas — Renda por Município (R$):\n")
print(stats_renda)

cat("\nEstatísticas — Ocorrências por Município:\n")
print(stats_ocorr)

cat("\nTop 10 — Ocorrências per capita (por 1.000 hab., municípios com pop. ≥ 10.000):\n")
print(ocorr_com_pop |> dplyr::filter(POPULACAO >= 10000) |> head(10))

# ----- 5. Exportação de tabelas -------------------------------
write.xlsx(
  list(
    "Ocorr_x_Renda"      = as.data.frame(ocorr_com_renda),
    "Ocorr_x_Populacao"  = as.data.frame(ocorr_com_pop),
    "Rubrica_PerCapita"  = as.data.frame(ocorr_rubrica_pop),
    "Top5_por_Rubrica"   = as.data.frame(top5_rubrica),
    "Contagem_Rubrica"   = as.data.frame(
      base |> count(RUBRICA, name = "QUANTIDADE") |> arrange(desc(QUANTIDADE))
    ),
    "Estatisticas_Renda" = stats_renda,
    "Estatisticas_Ocorr" = stats_ocorr
  ),
  file.path(OUT_DIR, "analise_2025.xlsx"),
  rowNames = FALSE
)
cat("\n✓ analise_2025.xlsx exportado\n")

# ----- 6. Gráficos --------------------------------------------

# 6.1 Top 10 por rubrica
for (rub in top3) {
  p <- grafico_top10_por_rubrica(ocorr_por_rubrica, rub, top_n = 10)
  nome_arq <- paste0("grafico_top10_", tolower(gsub("[^A-Za-z0-9]", "_", rub)), ".png")
  ggsave(file.path(OUT_DIR, nome_arq), plot = p, width = 10, height = 6, dpi = 150)
  cat(sprintf("✓ %s exportado\n", nome_arq))
}

# 6.2 Ocorrências vs Renda
p_renda <- grafico_ocorrencias_vs_renda(ocorr_com_renda, top_n = 30)
ggsave(file.path(OUT_DIR, "grafico_ocorrencias_vs_renda.png"),
       plot = p_renda, width = 11, height = 7, dpi = 150)
cat("✓ grafico_ocorrencias_vs_renda.png exportado\n")

# 6.3 Top 5 facetado
p_top5 <- grafico_top5_facetado(top5_rubrica)
ggsave(file.path(OUT_DIR, "grafico_top5_facetado.png"),
       plot = p_top5, width = 10, height = 12, dpi = 150)
cat("✓ grafico_top5_facetado.png exportado\n")

# 6.4 Distribuição da renda entre municípios
p_dist <- grafico_distribuicao_renda(renda)
ggsave(file.path(OUT_DIR, "grafico_distribuicao_renda.png"),
       plot = p_dist, width = 10, height = 6, dpi = 150)
cat("✓ grafico_distribuicao_renda.png exportado\n")

# 6.5 Ocorrências per capita — top 10 geral
p_percapita <- grafico_top10_per_capita(ocorr_com_pop, top_n = 10)
ggsave(file.path(OUT_DIR, "grafico_top10_per_capita.png"),
       plot = p_percapita, width = 10, height = 6, dpi = 150)
cat("✓ grafico_top10_per_capita.png exportado\n")

# 6.6 Ocorrências per capita por rubrica (Furto, Roubo, Lesão Corporal)
for (rub in top3) {
  p <- grafico_top10_rubrica_per_capita(ocorr_rubrica_pop, rub, top_n = 10)
  nome_arq <- paste0("grafico_top10_percapita_", tolower(gsub("[^A-Za-z0-9]", "_", rub)), ".png")
  ggsave(file.path(OUT_DIR, nome_arq), plot = p, width = 10, height = 6, dpi = 150)
  cat(sprintf("✓ %s exportado\n", nome_arq))
}

cat("\n=== Pipeline concluído ===\n")

