# 11_regressao_espacial.R — regressão espacial (roteiro da prática da semana)
#
# Fluxo: OLS clássico -> Moran dos resíduos -> testes LM (lag vs error) ->
# spatial lag e spatial error -> mapas de resíduos -> GWR (local) -> comparação.
# Modelo: tx_furto ~ renda (uma covariável contínua, como no tutorial da água).
# O efeito litorâneo fica de fora de propósito: ele reaparece como
# autocorrelação espacial nos resíduos, o que motiva a regressão espacial.

suppressPackageStartupMessages({
  library(sf); library(dplyr); library(spdep); library(spatialreg)
  library(spgwr); library(ggplot2)
})

reg_g <- sf::read_sf(file.path(DIR_DATA, "geoda_sp.gpkg"))

# --- vizinhança queen ordem 1, row-standardized ---------------
nb_reg <- spdep::poly2nb(reg_g, queen = TRUE)
lw_reg <- spdep::nb2listw(nb_reg, style = "W", zero.policy = TRUE)

# --- 1. OLS clássico ------------------------------------------
ols <- lm(tx_furto ~ renda, data = reg_g)
moran_ols <- spdep::lm.morantest(ols, lw_reg, zero.policy = TRUE)

# --- 2. Testes LM (Lagrange / Rao) ----------------------------
LMfun <- if (exists("lm.RStests")) spdep::lm.RStests else spdep::lm.LMtests
lm_tests <- LMfun(ols, lw_reg, test = "all", zero.policy = TRUE)

# --- 3. Modelos espaciais globais -----------------------------
m_lag <- spatialreg::lagsarlm(tx_furto ~ renda, data = reg_g, listw = lw_reg, zero.policy = TRUE)
m_err <- spatialreg::errorsarlm(tx_furto ~ renda, data = reg_g, listw = lw_reg, zero.policy = TRUE)

# --- 4. GWR (local) -------------------------------------------
reg_sp <- as(reg_g, "Spatial")
gwr_bw <- spgwr::gwr.sel(tx_furto ~ renda, data = reg_sp, adapt = TRUE, verbose = FALSE, longlat = TRUE)
gwr_fit <- spgwr::gwr(tx_furto ~ renda, data = reg_sp, adapt = gwr_bw,
                      hatmatrix = TRUE, se.fit = TRUE, longlat = TRUE)

# resíduos e coeficientes locais de volta ao sf
reg_g$res_ols <- residuals(ols)
reg_g$res_err <- residuals(m_err)
reg_g$gwr_b_renda <- gwr_fit$SDF$renda
reg_g$gwr_localR2 <- gwr_fit$SDF$localR2

moran_err <- spdep::moran.mc(reg_g$res_err, lw_reg, nsim = 499, zero.policy = TRUE)

# --- 5. Tabela comparativa ------------------------------------
# R² dos modelos espaciais no padrão do GeoDa: correlação ao quadrado
# entre observado e predito (não o pseudo-R² de Nagelkerke).
r2_geoda <- function(m) cor(reg_g$tx_furto, fitted(m))^2
gwr_R2 <- 1 - gwr_fit$results$rss / sum((reg_g$tx_furto - mean(reg_g$tx_furto))^2)
reg_espacial_comp <- tibble::tibble(
  modelo = c("OLS clássico", "Spatial Lag (SAR)", "Spatial Error (CAR)", "GWR (local)"),
  parametro_espacial = c("nenhum",
                         sprintf("rho = %.3f", m_lag$rho),
                         sprintf("lambda = %.3f", m_err$lambda),
                         sprintf("bw adapt. = %.3f", gwr_bw)),
  r2 = c(summary(ols)$r.squared, r2_geoda(m_lag), r2_geoda(m_err), gwr_R2),
  AIC = c(AIC(ols), AIC(m_lag), AIC(m_err), gwr_fit$results$AICh),
  moran_residuos = c(moran_ols$estimate[1], NA, moran_err$statistic, NA)
)
readr::write_csv(reg_espacial_comp, file.path(DIR_OUT, "reg_espacial_comparacao.csv"))
cat("✓ reg_espacial_comparacao.csv\n")
print(as.data.frame(reg_espacial_comp))

# --- 6. Mapas -------------------------------------------------
mapa_div <- function(campo, titulo, subtitulo, rotulo, paleta) {
  lim <- max(abs(reg_g[[campo]]), na.rm = TRUE)
  ggplot(reg_g) +
    geom_sf(aes(fill = .data[[campo]]), colour = "white", linewidth = 0.06) +
    paleta +
    labs(title = titulo, subtitle = subtitulo, fill = rotulo, caption = FONTE_DADOS) +
    tema_mapa()
}

virg <- function(x, d = 2) formatC(x, format = "f", digits = d, decimal.mark = ",")
p_res_ols <- mapa_div("res_ols",
  "Resíduos do modelo clássico (OLS)",
  sprintf("Moran's I dos resíduos = %s (p < 0,001): forte autocorrelação espacial", virg(moran_ols$estimate[1])),
  "Resíduo",
  scale_fill_gradient2(low = "#2166ac", mid = "#f7f7f7", high = "#b2182b", midpoint = 0))
ggsave(file.path(DIR_OUT, "reg_esp_residuos_ols.png"), p_res_ols, width = 9, height = 8, dpi = 150)
cat("✓ reg_esp_residuos_ols.png\n")

p_res_err <- mapa_div("res_err",
  "Resíduos do modelo spatial error",
  sprintf("Moran's I dos resíduos = %s: autocorrelação praticamente eliminada", virg(moran_err$statistic)),
  "Resíduo",
  scale_fill_gradient2(low = "#2166ac", mid = "#f7f7f7", high = "#b2182b", midpoint = 0))
ggsave(file.path(DIR_OUT, "reg_esp_residuos_error.png"), p_res_err, width = 9, height = 8, dpi = 150)
cat("✓ reg_esp_residuos_error.png\n")

p_gwr_b <- mapa_div("gwr_b_renda",
  "GWR: coeficiente local da renda",
  "Quanto a taxa de furto responde à renda em cada município (efeito não estacionário)",
  "Coef. renda",
  scale_fill_gradient2(low = "#2166ac", mid = "#f7f7f7", high = "#b2182b", midpoint = 0))
ggsave(file.path(DIR_OUT, "reg_esp_gwr_coef.png"), p_gwr_b, width = 9, height = 8, dpi = 150)
cat("✓ reg_esp_gwr_coef.png\n")

p_gwr_r2 <- ggplot(reg_g) +
  geom_sf(aes(fill = gwr_localR2), colour = "white", linewidth = 0.06) +
  scale_fill_gradient(low = "#eff3ff", high = "#08519c") +
  labs(title = "GWR: R² local",
       subtitle = "Onde a renda explica melhor (escuro) ou pior (claro) a taxa de furto",
       fill = "R² local", caption = FONTE_DADOS) +
  tema_mapa()
ggsave(file.path(DIR_OUT, "reg_esp_gwr_r2.png"), p_gwr_r2, width = 9, height = 8, dpi = 150)
cat("✓ reg_esp_gwr_r2.png\n")

# objetos para o relatório
reg_espacial <- list(ols = ols, moran_ols = moran_ols, lm = lm_tests,
                     lag = m_lag, err = m_err, gwr = gwr_fit, gwr_bw = gwr_bw,
                     moran_err = moran_err, comp = reg_espacial_comp)
