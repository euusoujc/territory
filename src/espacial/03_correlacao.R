# 03_correlacao.R — top 5 por crime, matriz de correlação e dispersões

# --- Top 5 municípios por taxa em cada crime -------------------
top5 <- lapply(names(CRIMES), function(cr) {
  tabelao |>
    slice_max(.data[[TAXAS[[cr]]]], n = 5) |>
    transmute(crime = CRIMES[[cr]], cod_ibge, municipio, populacao,
              taxa_por_1000 = .data[[TAXAS[[cr]]]],
              litoranea_turistica)
}) |> bind_rows()

readr::write_csv(top5, file.path(DIR_OUT, "top5_por_crime.csv"))
cat("✓ top5_por_crime.csv\n")
print(as.data.frame(top5))

# --- Matriz de correlação (taxas + renda) ----------------------
vars_cor <- tabelao |>
  select(all_of(unname(TAXAS)), renda) |>
  rename(!!!setNames(unname(TAXAS), paste0("Taxa ", tolower(sub(" \\(.*", "", CRIMES)))),
         Renda = renda)

cor_pearson  <- cor(vars_cor, use = "pairwise.complete.obs", method = "pearson")
cor_spearman <- cor(vars_cor, use = "pairwise.complete.obs", method = "spearman")

salvar_cor <- function(m, arq) {
  readr::write_csv(as.data.frame(m) |> tibble::rownames_to_column("variavel"),
                   file.path(DIR_OUT, arq))
}
salvar_cor(round(cor_pearson, 3),  "correlacao_pearson.csv")
salvar_cor(round(cor_spearman, 3), "correlacao_spearman.csv")

png(file.path(DIR_OUT, "correlacao_matriz.png"), width = 1600, height = 1400, res = 200)
corrplot::corrplot(
  cor_pearson, method = "color", type = "upper", order = "original",
  addCoef.col = "grey20", number.cex = 0.9,
  tl.col = "grey20", tl.srt = 30, tl.cex = 0.9,
  col = colorRampPalette(c("#2166ac", "#f7f7f7", "#b2182b"))(200),
  mar = c(0, 0, 2, 0),
  title = "Correlação (Pearson) — taxas por 1.000 hab. e renda média"
)
dev.off()
cat("✓ correlacao_matriz.png / correlacao_pearson.csv / correlacao_spearman.csv\n")

# --- Dispersões: cada taxa vs renda e taxa vs taxa -------------
pares <- list(
  c("renda", TAXAS[["roubo"]]), c("renda", TAXAS[["furto"]]), c("renda", TAXAS[["lesao"]]),
  c(TAXAS[["furto"]], TAXAS[["roubo"]]),
  c(TAXAS[["furto"]], TAXAS[["lesao"]]),
  c(TAXAS[["roubo"]], TAXAS[["lesao"]])
)
rotulo <- function(v) {
  if (v == "renda") return("Renda média (R$)")
  crime <- names(TAXAS)[TAXAS == v]
  sprintf("%s / 1.000 hab.", sub(" \\(.*", "", CRIMES[crime]))
}

disp <- bind_rows(lapply(pares, function(p) {
  tibble::tibble(
    painel = sprintf("%s × %s", rotulo(p[2]), rotulo(p[1])),
    x = tabelao[[p[1]]], y = tabelao[[p[2]]],
    grupo = factor(tabelao$litoranea_turistica, c(0, 1),
                   c("Demais municípios", "Litorâneo/turístico"))
  )
})) |>
  mutate(painel = factor(painel, unique(painel)))  # mantém a ordem definida em `pares`

p_disp <- ggplot(disp, aes(x, y, colour = grupo)) +
  geom_point(size = 1.6, alpha = 0.65) +
  geom_smooth(aes(group = 1), method = "lm", se = FALSE,
              linewidth = 0.6, colour = "grey40", linetype = "dashed") +
  scale_colour_manual(values = c("Demais municípios" = "#6baed6",
                                 "Litorâneo/turístico" = "#d95f02")) +
  facet_wrap(~painel, scales = "free", ncol = 3) +
  labs(title = "Dispersões — taxas de crime (por 1.000 hab.) e renda média",
       subtitle = "Cada ponto é um município de SP; reta tracejada = ajuste linear",
       x = NULL, y = NULL, colour = NULL, caption = FONTE_DADOS) +
  theme_minimal(base_size = 11) +
  theme(legend.position = "top",
        panel.grid.minor = element_blank(),
        strip.text = element_text(size = 8.5))

ggsave(file.path(DIR_OUT, "dispersoes_taxas_renda.png"), p_disp,
       width = 11, height = 7, dpi = 150)
cat("✓ dispersoes_taxas_renda.png\n")
