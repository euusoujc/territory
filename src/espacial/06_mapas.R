# 06_mapas.R — mapas coropléticos das taxas por 1.000 hab. (um por crime)
#
# Classes por quintis (classInt), rampa sequencial de um matiz
# (claro = taxa baixa, escuro = taxa alta).

for (crime in names(CRIMES)) {
  v <- malha_dados[[TAXAS[crime]]]
  brks <- unique(classInt::classIntervals(v[!is.na(v)], n = 5, style = "quantile")$brks)
  labs_cls <- sprintf("%.1f – %.1f", head(brks, -1), tail(brks, -1))
  malha_dados$classe <- cut(v, breaks = brks, labels = labs_cls, include.lowest = TRUE)

  p_mapa <- ggplot(malha_dados) +
    geom_sf(aes(fill = classe), colour = "white", linewidth = 0.08) +
    scale_fill_manual(values = PAL_SEQ[seq_along(labs_cls)],
                      na.value = "grey85", drop = FALSE) +
    labs(title = sprintf("%s — taxa por 1.000 habitantes", CRIMES[crime]),
         subtitle = "Municípios de São Paulo, 2025 — classes por quintis",
         fill = "Taxa / 1.000 hab.", caption = FONTE_DADOS) +
    tema_mapa()

  arq <- file.path(DIR_OUT, sprintf("mapa_taxa_%s.png", crime))
  ggsave(arq, p_mapa, width = 9, height = 8, dpi = 150)
  cat(sprintf("✓ %s\n", basename(arq)))
}
malha_dados$classe <- NULL
