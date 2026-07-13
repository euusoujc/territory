# 08_xlsx.R — exporta todas as tabelas da análise num único xlsx editável
# (outputs/analise_espacial.xlsx), no mesmo padrão do analise_2025.xlsx.

medias_grupo_xlsx <- tabelao |>
  group_by(grupo = ifelse(litoranea_turistica == 1, "Litorâneo/turístico", "Demais")) |>
  summarise(n = n(),
            across(all_of(unname(TAXAS)), ~ round(mean(.x, na.rm = TRUE), 2)),
            renda_media = round(mean(renda, na.rm = TRUE), 0), .groups = "drop")

cor_para_df <- function(m) {
  df <- as.data.frame(round(m, 3))
  cbind(variavel = rownames(df), df, row.names = NULL)
}

openxlsx::write.xlsx(
  list(
    "Tabelao"             = as.data.frame(tabelao),
    "Litoranea_Turistica" = as.data.frame(litoranea),
    "Top5_por_Crime"      = as.data.frame(top5),
    "Medias_por_Grupo"    = as.data.frame(medias_grupo_xlsx),
    "Correlacao_Pearson"  = cor_para_df(cor_pearson),
    "Correlacao_Spearman" = cor_para_df(cor_spearman),
    "Moran_Global"        = as.data.frame(moran_global),
    "LISA_Clusters"       = as.data.frame(lisa_tabela)
  ),
  file.path(DIR_OUT, "analise_espacial.xlsx"),
  rowNames = FALSE, overwrite = TRUE
)
cat("✓ analise_espacial.xlsx\n")
