# 13_gwr_geoda.R — modelo enxuto tx_furto ~ renda: GWR, resíduos e
# empacotamento dos resultados para o GeoDa (mapas feitos lá).
#
# Foca na relação entre a taxa de furto por 1.000 hab. e a renda média.
# Exporta os coeficientes locais, o t, o R² local e os resíduos como
# colunas de um GeoPackage/Shapefile prontos para mapear no GeoDa.

suppressPackageStartupMessages({
  library(sf); library(dplyr); library(spgwr); library(ggplot2); library(spdep)
})

gg <- sf::read_sf(file.path(DIR_DATA, "geoda_sp.gpkg"))
gg_sp <- as(gg, "Spatial")

# --- OLS global (referência) ----------------------------------
ols_fr <- lm(tx_furto ~ renda, data = gg)
b_glob <- coef(ols_fr)[["renda"]]

# --- GWR tx_furto ~ renda (reusa step 11 se disponível) -------
if (exists("gwr_fit") && exists("gwr_bw")) {
  fit <- gwr_fit; bw <- gwr_bw
} else {
  bw <- spgwr::gwr.sel(tx_furto ~ renda, data = gg_sp, adapt = TRUE, verbose = FALSE, longlat = TRUE)
  fit <- spgwr::gwr(tx_furto ~ renda, data = gg_sp, adapt = bw,
                    hatmatrix = TRUE, se.fit = TRUE, longlat = TRUE)
}
S <- fit$SDF
# o nome do intercepto no SDF varia ("(Intercept)" / "X.Intercept.")
col_icept <- grep("Intercept", names(S), value = TRUE)
col_icept <- col_icept[!grepl("_se$", col_icept)][1]

# --- resultados por município ---------------------------------
gg <- gg |> mutate(
  b0       = S[[col_icept]],
  b_renda  = S$renda,
  se_renda = S$renda_se,
  t_renda  = S$renda / S$renda_se,
  sig_renda = as.integer(abs(S$renda / S$renda_se) > 1.96),
  localR2  = S$localR2,
  y_hat    = S$pred,
  resid    = tx_furto - S$pred,
  std_res  = as.numeric(scale(tx_furto - S$pred))
)

qr2 <- 1 - fit$results$rss / sum((gg$tx_furto - mean(gg$tx_furto))^2)
cat(sprintf("GWR tx_furto ~ renda: bw=%.4f (~%d pts) | AICc=%.1f | quasi-R2=%.3f\n",
            bw, round(bw * nrow(gg)), fit$results$AICh, qr2))

# ============================================================
# PACOTE PARA O GEODA
# ============================================================
geoda_gwr <- gg |>
  select(cod_ibge, municipio, tx_furto, renda,
         b0, b_renda, se_renda, t_renda, sig_renda, localR2, y_hat, resid, std_res)

sf::write_sf(geoda_gwr, file.path(DIR_DATA, "geoda_gwr_furto.gpkg"), delete_dsn = TRUE)
dir_shp <- file.path(DIR_DATA, "geoda_gwr_furto_shp")
dir.create(dir_shp, showWarnings = FALSE)
sf::write_sf(geoda_gwr, file.path(dir_shp, "geoda_gwr_furto.shp"),
             delete_layer = TRUE, quiet = TRUE)
cat("✓ data/geoda_gwr_furto.gpkg e geoda_gwr_furto_shp/ (prontos para o GeoDa)\n")

# ============================================================
# MAPAS DE REFERÊNCIA (o GeoDa gera os finais a partir do pacote)
# ============================================================
PAL_DIV <- scale_fill_gradient2(low = "#2166ac", mid = "#f7f7f7", high = "#b2182b", midpoint = 0)
mapa <- function(campo, titulo, subt, rot, escala) {
  ggplot(gg) + geom_sf(aes(fill = .data[[campo]]), colour = "white", linewidth = 0.06) +
    escala + labs(title = titulo, subtitle = subt, fill = rot, caption = FONTE_DADOS) + tema_mapa()
}
sv <- function(p, a) { ggsave(file.path(DIR_OUT, a), p, width = 9, height = 8, dpi = 150); cat("✓", a, "\n") }

sv(mapa("b_renda", "GWR: coeficiente local da renda (beta)",
        "Quanto a taxa de furto muda a cada R$ 1 de renda, em cada município",
        "beta", PAL_DIV), "gwrfr_beta_renda.png")
sv(mapa("t_renda", "GWR: estatística t da renda",
        "Onde o efeito da renda é estatisticamente forte (|t| > 1,96)",
        "t", PAL_DIV), "gwrfr_t_renda.png")
sv(ggplot(gg) + geom_sf(aes(fill = localR2), colour = "white", linewidth = 0.06) +
     scale_fill_gradient(low = "#eff3ff", high = "#08519c") +
     labs(title = "GWR: R² local", subtitle = "Onde a renda explica melhor (escuro) ou pior (claro) o furto",
          fill = "R² local", caption = FONTE_DADOS) + tema_mapa(), "gwrfr_localR2.png")
sv(mapa("resid", "GWR: resíduos do modelo tx_furto ~ renda",
        "Onde o modelo subestima (vermelho) ou superestima (azul) o furto",
        "resíduo", PAL_DIV), "gwrfr_residuos.png")

# ---- boxplot dos resíduos (tratamento) -----------------------
box_df <- tibble::tibble(
  modelo = rep(c("OLS global", "GWR local"), each = nrow(gg)),
  residuo = c(residuals(ols_fr), gg$resid)) |>
  mutate(modelo = factor(modelo, c("OLS global", "GWR local")))
lim_out <- function(x) { q <- quantile(x, c(.25, .75)); q[2] + 1.5 * (q[2] - q[1]) }
p_box <- ggplot(box_df, aes(modelo, residuo, fill = modelo)) +
  geom_hline(yintercept = 0, colour = "grey60") +
  geom_boxplot(width = 0.5, outlier.size = 0.8, alpha = 0.85) +
  scale_fill_manual(values = c("OLS global" = "#9ecae1", "GWR local" = "#d95f02")) +
  labs(title = "Tratamento dos resíduos: OLS global x GWR local",
       subtitle = "O GWR reduz a dispersão e os resíduos extremos; pontos acima do bigode são outliers (1,5 IQR)",
       x = NULL, y = "Resíduo (furtos/1.000 hab.)", fill = NULL, caption = FONTE_DADOS) +
  theme_light(base_size = 12) +
  theme(legend.position = "none", panel.grid.minor = element_blank(),
        plot.title = element_text(face = "bold"))
ggsave(file.path(DIR_OUT, "gwrfr_residuos_boxplot.png"), p_box, width = 8, height = 6, dpi = 150)
cat("✓ gwrfr_residuos_boxplot.png\n")

# ---- exemplo do cálculo: banda local de um alvo (São Paulo) --
cent <- sf::st_coordinates(sf::st_centroid(sf::st_geometry(gg)))
alvo <- which(gg$cod_ibge == "3550308")            # São Paulo
gc_dist <- spDists(cent, cent[alvo, , drop = FALSE], longlat = TRUE)[, 1]
k <- round(bw * nrow(gg))                           # nº efetivo de vizinhos
h <- sort(gc_dist)[k]                               # banda adaptativa local (km)
b_local_alvo <- gg$b_renda[alvo]

# ---- objetos/resumo para o relatório -------------------------
gwr_geoda <- list(
  bw = bw, k = k, h = h, aicc = fit$results$AICh, qr2 = qr2,
  b_global = b_glob, r2_ols = summary(ols_fr)$r.squared,
  b_range = range(gg$b_renda), t_range = range(gg$t_renda),
  r2_range = range(gg$localR2), pct_sig = mean(gg$sig_renda) * 100,
  alvo_local = b_local_alvo, alvo_global = b_glob
)
cat(sprintf("Exemplo São Paulo: beta local=%.5f vs global=%.5f (por R$1)\n", b_local_alvo, b_glob))
