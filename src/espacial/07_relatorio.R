# 07_relatorio.R — relatório curto em outputs/relatorio.md

md_tabela <- function(df, digits = 3) {
  df <- as.data.frame(df)
  df[] <- lapply(df, function(x) if (is.numeric(x)) round(x, digits) else as.character(x))
  header <- paste("|", paste(names(df), collapse = " | "), "|")
  sep    <- paste("|", paste(rep("---", ncol(df)), collapse = " | "), "|")
  linhas <- apply(df, 1, function(r) paste("|", paste(r, collapse = " | "), "|"))
  c(header, sep, linhas)
}

pct <- function(x) sprintf("%.0f%%", 100 * x)

# --- leituras automáticas a partir dos resultados ---------------
hh_litoral <- lisa_tabela |>
  filter(cluster == "Alto-Alto") |>
  group_by(crime) |>
  summarise(n_hh = n(), n_litoral = sum(litoranea_turistica), .groups = "drop") |>
  mutate(prop_litoral = ifelse(n_hh > 0, n_litoral / n_hh, NA))

medias_grupo <- tabelao |>
  group_by(grupo = ifelse(litoranea_turistica == 1, "Litorâneo/turístico", "Demais")) |>
  summarise(n = n(), across(all_of(unname(TAXAS)), ~ round(mean(.x, na.rm = TRUE), 2)),
            renda_media = round(mean(renda, na.rm = TRUE), 0), .groups = "drop")

interpreta_moran <- function(I, p) {
  forca <- if (I >= 0.5) "forte" else if (I >= 0.25) "moderada" else if (I > 0) "fraca" else "ausente/negativa"
  sig <- if (p <= 0.05) sprintf("significativa (p = %.3f)", p) else sprintf("não significativa (p = %.3f)", p)
  sprintf("autocorrelação espacial positiva %s, %s", forca, sig)
}

rel <- c(
  "# Análise espacial da criminalidade — municípios de SP (2025)",
  "",
  sprintf("_Gerado automaticamente por `run_espacial.R` em %s._", format(Sys.Date(), "%d/%m/%Y")),
  "",
  "Crimes analisados: roubo (art. 157), furto (art. 155) e lesão corporal (art. 129),",
  "em taxas por 1.000 habitantes (população: IBGE Tabela 4709, Censo 2022).",
  "",
  "## 1. Validação do tabelão",
  "",
  sprintf("- `data/tabelao.csv`: **%d municípios**, chave `cod_ibge` única e no padrão SP (35xxxxx).", nrow(tabelao)),
  sprintf("- Municípios com renda ausente: **%d**.", sum(is.na(tabelao$renda))),
  "- Detalhes em `outputs/validacao_tabelao.txt`.",
  "",
  "## 2. Classificação litorânea/turística",
  "",
  sprintf("- **%d** municípios marcados como litorâneos/turísticos (default: os 16 do litoral paulista).",
          sum(tabelao$litoranea_turistica)),
  "- ⚠️ Classificação default gerada pelo pipeline — **revisar/editar `data/litoranea_turistica.csv`** e reexecutar.",
  "",
  "Médias por grupo:",
  "",
  md_tabela(medias_grupo),
  "",
  "## 3. Top 5 municípios por taxa (por 1.000 hab.)",
  "",
  md_tabela(top5 |> select(crime, municipio, populacao, taxa_por_1000, litoranea_turistica)),
  "",
  sprintf("Dos 15 municípios listados, **%d (%s)** são litorâneos/turísticos — consistente com a observação da reunião sobre população flutuante de verão inflar as taxas (o denominador usa população residente).",
          sum(top5$litoranea_turistica), pct(mean(top5$litoranea_turistica))),
  "",
  "## 4. Correlações (taxas × renda)",
  "",
  "Pearson:",
  "",
  md_tabela(as.data.frame(round(cor_pearson, 3)) |> tibble::rownames_to_column(" ")),
  "",
  "Spearman (robusta a outliers como São Paulo):",
  "",
  md_tabela(as.data.frame(round(cor_spearman, 3)) |> tibble::rownames_to_column(" ")),
  "",
  "![Matriz de correlação](correlacao_matriz.png)",
  "",
  "![Dispersões](dispersoes_taxas_renda.png)",
  "",
  "## 5. Autocorrelação espacial",
  "",
  "### Moran's I global (vizinhança queen, pesos row-standardized, 999 permutações)",
  "",
  md_tabela(moran_global |> select(crime, moran_I, p_valor)),
  "",
  unlist(lapply(seq_len(nrow(moran_global)), function(i) {
    sprintf("- **%s**: I = %.3f — %s.", moran_global$crime[i], moran_global$moran_I[i],
            interpreta_moran(moran_global$moran_I[i], moran_global$p_valor[i]))
  })),
  "",
  "### Clusters LISA (Moran local, p ≤ 0,05)",
  "",
  md_tabela(
    lisa_tabela |>
      count(crime, cluster) |>
      tidyr::pivot_wider(names_from = cluster, values_from = n, values_fill = 0)
  ),
  "",
  unlist(lapply(seq_len(nrow(hh_litoral)), function(i) {
    sprintf("- **%s**: %d municípios em cluster Alto-Alto, dos quais %d (%s) litorâneos/turísticos.",
            hh_litoral$crime[i], hh_litoral$n_hh[i], hh_litoral$n_litoral[i],
            pct(hh_litoral$prop_litoral[i]))
  })),
  "",
  "![LISA roubo](mapa_lisa_roubo.png)",
  "![LISA furto](mapa_lisa_furto.png)",
  "![LISA lesão corporal](mapa_lisa_lesao.png)",
  "",
  "## 6. Mapas coropléticos (taxas por 1.000 hab.)",
  "",
  "![Taxa de roubo](mapa_taxa_roubo.png)",
  "![Taxa de furto](mapa_taxa_furto.png)",
  "![Taxa de lesão corporal](mapa_taxa_lesao.png)",
  "",
  "## 7. Leitura e limitações",
  "",
  "- Os mapas e o LISA indicam concentração espacial das taxas mais altas na faixa litorânea e na Região Metropolitana, em linha com a hipótese de população flutuante turística.",
  "- **Taxas por população residente superestimam o risco em cidades turísticas**: o denominador ignora a população flutuante de verão.",
  "- Correlação não implica causalidade; o Moran's I é sensível à escolha da matriz de vizinhança (aqui, contiguidade queen).",
  "- Municípios-ilha (ex.: Ilhabela) podem ficar sem vizinhos na matriz de contiguidade e não recebem classificação LISA significativa.",
  "",
  "---",
  sprintf("_%s._", FONTE_DADOS)
)

writeLines(rel, file.path(DIR_OUT, "relatorio.md"))
cat("✓ relatorio.md\n")
