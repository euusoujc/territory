# 05_moran.R — autocorrelação espacial: Moran global e LISA
#
# Vizinhança por contiguidade (queen), pesos row-standardized.
# Ilhas (ex.: Ilhabela, Ilha Comprida) podem ficar sem vizinhos:
# são mantidas com zero.policy e reportadas.

set.seed(SEED)

nb <- spdep::poly2nb(malha_dados, queen = TRUE)
isolados <- which(spdep::card(nb) == 0)
if (length(isolados))
  cat(sprintf("Municípios sem vizinhos (ilhas): %s\n",
              paste(malha_dados$municipio[isolados], collapse = ", ")))
lw <- spdep::nb2listw(nb, style = "W", zero.policy = TRUE)

# --- Moran global (teste de permutação) ------------------------
moran_global <- bind_rows(lapply(names(CRIMES), function(cr) {
  x <- malha_dados[[TAXAS[[cr]]]]
  x[is.na(x)] <- mean(x, na.rm = TRUE)  # NAs (se houver) neutralizados na média
  mc <- spdep::moran.mc(x, lw, nsim = N_PERM, zero.policy = TRUE)
  tibble::tibble(
    crime      = unname(CRIMES[[cr]]),
    variavel   = unname(TAXAS[[cr]]),
    moran_I    = round(unname(mc$statistic), 4),
    p_valor    = mc$p.value,
    n_perm     = N_PERM
  )
}))
readr::write_csv(moran_global, file.path(DIR_OUT, "moran_global.csv"))
cat("✓ moran_global.csv\n")
print(as.data.frame(moran_global))

# --- Moran local (LISA) + mapas de clusters --------------------
# Inferência por permutação condicional (999 sim.), como no GeoDa —
# a aproximação analítica de localmoran() subestima clusters Baixo-Baixo
# em variáveis assimétricas cheias de zeros (caso das taxas de roubo).
classificar_lisa <- function(x, lw, sig = SIG_LISA) {
  x[is.na(x)] <- mean(x, na.rm = TRUE)
  lisa <- spdep::localmoran_perm(x, lw, nsim = N_PERM, zero.policy = TRUE)
  p    <- lisa[, grep("Sim", colnames(lisa), value = TRUE)[1]]
  z    <- as.numeric(scale(x))
  lag  <- spdep::lag.listw(lw, z, zero.policy = TRUE)
  cluster <- dplyr::case_when(
    p > sig            ~ "Não significativo",
    z >= 0 & lag >= 0  ~ "Alto-Alto",
    z <  0 & lag <  0  ~ "Baixo-Baixo",
    z >= 0 & lag <  0  ~ "Alto-Baixo",
    TRUE               ~ "Baixo-Alto"
  )
  list(cluster = factor(cluster, names(PAL_LISA)),
       Ii = lisa[, "Ii"], p = p)
}

lisa_tabela <- list()
for (cr in names(CRIMES)) {
  res <- classificar_lisa(malha_dados[[TAXAS[[cr]]]], lw)
  col_cluster <- paste0("lisa_", cr)
  malha_dados[[col_cluster]] <- res$cluster

  lisa_tabela[[cr]] <- sf::st_drop_geometry(malha_dados) |>
    transmute(crime = unname(CRIMES[[cr]]), cod_ibge, municipio,
              taxa_por_1000 = .data[[TAXAS[[cr]]]],
              moran_local_Ii = round(res$Ii, 4),
              p_valor = round(res$p, 4),
              cluster = res$cluster,
              litoranea_turistica)

  p_lisa <- ggplot(malha_dados) +
    # show.legend = TRUE força a amostra de cor na legenda mesmo para
    # classes sem ocorrência no crime (ggplot2 >= 3.5 omite por padrão)
    geom_sf(aes(fill = .data[[col_cluster]]), colour = "white",
            linewidth = 0.08, show.legend = TRUE) +
    scale_fill_manual(values = PAL_LISA, drop = FALSE) +
    labs(title = sprintf("Clusters LISA — %s", CRIMES[[cr]]),
         subtitle = sprintf("Moran local da taxa por 1.000 hab. (p ≤ %.2f, vizinhança queen)", SIG_LISA),
         fill = "Cluster", caption = FONTE_DADOS) +
    tema_mapa()
  arq <- file.path(DIR_OUT, sprintf("mapa_lisa_%s.png", cr))
  ggsave(arq, p_lisa, width = 9, height = 8, dpi = 150)
  cat(sprintf("✓ %s\n", basename(arq)))
}

lisa_tabela <- bind_rows(lisa_tabela)
readr::write_csv(lisa_tabela, file.path(DIR_OUT, "lisa_clusters.csv"))
cat("✓ lisa_clusters.csv\n")
