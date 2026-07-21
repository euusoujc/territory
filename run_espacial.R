# =============================================================
# run_espacial.R — Pipeline de análise espacial da criminalidade
# =============================================================
# Executa, em ordem:
#   1. Construção e validação do tabelão (data/tabelao.csv)
#   2. Classificação litorânea/turística (data/litoranea_turistica.csv)
#   3. Top 5 por crime + correlações (matriz e dispersões)
#   4. Download/recorte da malha de municípios de SP (IBGE)
#   5. Autocorrelação espacial: Moran global e LISA
#   6. Mapas coropléticos das taxas por 1.000 hab.
#   7. Relatório em outputs/relatorio.md
#
# Uso:  Rscript run_espacial.R
# =============================================================

args_file <- grep("--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
DIR_ROOT  <- if (length(args_file)) {
  dirname(normalizePath(sub("--file=", "", args_file[1])))
} else {
  getwd()  # execução interativa: assume raiz do repositório
}

etapas <- c(
  "00_config.R",
  "01_tabelao.R",
  "02_litoranea.R",
  "03_correlacao.R",
  "04_malha.R",
  "05_moran.R",
  "06_mapas.R",
  "07_relatorio.R",
  "08_xlsx.R",
  "09_geoda.R",
  "10_regressao.R"
)

t0 <- Sys.time()
for (etapa in etapas) {
  cat(sprintf("\n========== %s ==========\n", etapa))
  source(file.path(DIR_ROOT, "src", "espacial", etapa), encoding = "UTF-8")
}
cat(sprintf(
  "\n=== Pipeline concluído em %.1f s — resultados em outputs/ ===\n",
  as.numeric(difftime(Sys.time(), t0, units = "secs"))
))
