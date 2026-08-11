# 12_gwr_litoral.R — GWR com a variável litorânea, cenário contrafactual
# (litoral zerado) e tratamento dos resíduos em relação às cidades litorâneas.
#
# Aprofunda o step 11 (que usa tx_furto ~ renda): aqui o modelo é
# tx_furto ~ renda + litoral. Compara global x local, isola o impacto das
# cidades litorâneas e mostra como os resíduos do modelo sem litoral se
# concentram justamente nelas (efeito da população flutuante sobre um
# denominador de população residente).

suppressPackageStartupMessages({
  library(sf); library(dplyr); library(spdep); library(spatialreg)
  library(spgwr); library(ggplot2)
})

gl <- sf::read_sf(file.path(DIR_DATA, "geoda_sp.gpkg"))
gl$grupo <- factor(gl$litoral, c(0, 1), c("Demais municípios", "Litorâneo/turístico"))
gl_sp <- as(gl, "Spatial")

# vizinhança (reusa a do step 11 se existir)
if (exists("lw_reg")) { lw_gl <- lw_reg } else {
  lw_gl <- spdep::nb2listw(spdep::poly2nb(gl, queen = TRUE), style = "W", zero.policy = TRUE)
}

COR_GRUPO <- c("Demais municípios" = "#6baed6", "Litorâneo/turístico" = "#d95f02")
PAL_DIV <- function(mid = 0) scale_fill_gradient2(low = "#2166ac", mid = "#f7f7f7",
                                                  high = "#b2182b", midpoint = mid)
r2_geoda <- function(m) cor(gl$tx_furto, fitted(m))^2
qr2 <- function(fit) 1 - fit$results$rss / sum((gl$tx_furto - mean(gl$tx_furto))^2)

# ---- modelos globais -----------------------------------------
g_ols_r  <- lm(tx_furto ~ renda, data = gl)                # só renda
g_ols_rl <- lm(tx_furto ~ renda + litoral, data = gl)      # renda + litoral
g_err_rl <- spatialreg::errorsarlm(tx_furto ~ renda + litoral, data = gl,
                                   listw = lw_gl, zero.policy = TRUE)

# ---- GWR com renda + litoral (modelo principal) --------------
cat("Ajustando GWR (renda + litoral)...\n")
bw_rl <- spgwr::gwr.sel(tx_furto ~ renda + litoral, data = gl_sp,
                        adapt = TRUE, verbose = FALSE, longlat = TRUE)
gwr_rl <- spgwr::gwr(tx_furto ~ renda + litoral, data = gl_sp, adapt = bw_rl,
                     hatmatrix = TRUE, se.fit = TRUE, longlat = TRUE)

# ---- GWR só renda (reusa step 11 se existir) -----------------
if (exists("gwr_fit")) { gwr_r <- gwr_fit; bw_r <- gwr_bw } else {
  bw_r <- spgwr::gwr.sel(tx_furto ~ renda, data = gl_sp, adapt = TRUE, verbose = FALSE, longlat = TRUE)
  gwr_r <- spgwr::gwr(tx_furto ~ renda, data = gl_sp, adapt = bw_r,
                      hatmatrix = TRUE, se.fit = TRUE, longlat = TRUE)
}

# coeficientes locais, R² local, significância local (|t| > 1,96)
sdf <- gwr_rl$SDF
gl$b_intercepto <- sdf$"(Intercept)"
gl$b_renda      <- sdf$renda
gl$b_litoral    <- sdf$litoral
gl$r2_local     <- sdf$localR2
gl$t_renda      <- sdf$renda   / sdf$renda_se
gl$t_litoral    <- sdf$litoral / sdf$litoral_se
pct_sig_renda   <- mean(abs(gl$t_renda)   > 1.96) * 100
pct_sig_litoral <- mean(abs(gl$t_litoral) > 1.96) * 100

# ---- contrafactual: litoral = 0 ------------------------------
gl$pred_gwr    <- sdf$pred
gl$pred_cf     <- gl$pred_gwr - gl$b_litoral * gl$litoral      # zera a contribuição litorânea
gl$impacto_lit <- gl$pred_gwr - gl$pred_cf                     # = b_litoral em municípios litorâneos
gl$pred_global <- predict(g_ols_rl)
gl$dif_local_global <- gl$pred_gwr - gl$pred_global

# ---- resíduos: modelo SEM litoral vs COM litoral -------------
gl$res_sem_lit <- residuals(g_ols_r)
gl$res_com_lit <- residuals(g_ols_rl)

res_por_grupo <- gl |>
  sf::st_drop_geometry() |>
  group_by(grupo) |>
  summarise(n = n(),
            res_medio_sem_litoral = round(mean(res_sem_lit), 3),
            res_medio_com_litoral = round(mean(res_com_lit), 3),
            .groups = "drop")
readr::write_csv(res_por_grupo, file.path(DIR_OUT, "residuos_por_grupo.csv"))
cat("✓ residuos_por_grupo.csv\n"); print(as.data.frame(res_por_grupo))

# correlação ponto-bisserial resíduo x litoral
cor_sem <- cor(gl$res_sem_lit, gl$litoral)
cor_com <- cor(gl$res_com_lit, gl$litoral)
moran_sem <- spdep::moran.mc(gl$res_sem_lit, lw_gl, 499, zero.policy = TRUE)$statistic
moran_com <- spdep::moran.mc(gl$res_com_lit, lw_gl, 499, zero.policy = TRUE)$statistic

# ---- extra: regressão só do litoral (regime) ----------------
lit <- filter(gl, litoral == 1); mnl <- filter(gl, litoral == 0)
m_litoral <- lm(tx_furto ~ renda, data = lit)
m_interior <- lm(tx_furto ~ renda, data = mnl)

# ---- tabela comparativa de modelos ---------------------------
gwr_comp <- tibble::tibble(
  modelo = c("OLS ~ renda", "OLS ~ renda + litoral",
             "Spatial Error ~ renda + litoral", "GWR ~ renda",
             "GWR ~ renda + litoral", "OLS ~ renda (só litoral, n=16)"),
  tipo = c("global", "global", "global", "local", "local", "regime litorâneo"),
  r2 = c(summary(g_ols_r)$r.squared, summary(g_ols_rl)$r.squared, r2_geoda(g_err_rl),
         qr2(gwr_r), qr2(gwr_rl), summary(m_litoral)$r.squared),
  AIC = c(AIC(g_ols_r), AIC(g_ols_rl), AIC(g_err_rl),
          gwr_r$results$AICh, gwr_rl$results$AICh, AIC(m_litoral))
)
readr::write_csv(gwr_comp, file.path(DIR_OUT, "gwr_comparacao_modelos.csv"))
cat("✓ gwr_comparacao_modelos.csv\n"); print(as.data.frame(gwr_comp))

# ============================================================
# MAPAS
# ============================================================
mapa_fill <- function(campo, titulo, subtitulo, rotulo, escala) {
  ggplot(gl) + geom_sf(aes(fill = .data[[campo]]), colour = "white", linewidth = 0.06) +
    escala + labs(title = titulo, subtitle = subtitulo, fill = rotulo, caption = FONTE_DADOS) +
    tema_mapa()
}
sv <- function(p, arq, ...) { ggsave(file.path(DIR_OUT, arq), p, width = 9, height = 8, dpi = 150, ...); cat("✓", arq, "\n") }

sv(mapa_fill("b_renda", "GWR (renda + litoral): coeficiente local da renda",
   "Quanto a taxa de furto responde à renda em cada município", "Coef. renda", PAL_DIV()),
   "gwr_lit_coef_renda.png")

sv(mapa_fill("b_litoral", "GWR: coeficiente local da variável litorânea",
   "Efeito latente da condição litorânea/turística sobre a taxa de furto", "Coef. litoral", PAL_DIV()),
   "gwr_lit_coef_litoral.png")

sv(ggplot(gl) + geom_sf(aes(fill = r2_local), colour = "white", linewidth = 0.06) +
   scale_fill_gradient(low = "#eff3ff", high = "#08519c") +
   labs(title = "GWR (renda + litoral): R² local",
        subtitle = "Onde o modelo explica melhor (escuro) ou pior (claro) a taxa de furto",
        fill = "R² local", caption = FONTE_DADOS) + tema_mapa(),
   "gwr_lit_r2_local.png")

sv(mapa_fill("t_renda", "GWR: estatística t local da renda",
   sprintf("Magnitude e significância do efeito da renda (|t| > 1,96 em %.0f%% dos municípios)", pct_sig_renda),
   "t", PAL_DIV()),
   "gwr_lit_t_renda.png")
sv(mapa_fill("t_litoral", "GWR: estatística t local da condição litorânea",
   sprintf("Magnitude e significância do efeito litorâneo (|t| > 1,96 em %.0f%% dos municípios)", pct_sig_litoral),
   "t", PAL_DIV()),
   "gwr_lit_t_litoral.png")

sv(mapa_fill("impacto_lit", "Contrafactual: impacto das cidades litorâneas",
   "Diferença entre a predição real e o cenário com litoral = 0 (furtos/1.000 hab.)",
   "Impacto", PAL_DIV()),
   "gwr_contrafactual_dif.png")

sv(mapa_fill("dif_local_global", "GWR local menos predição global",
   "Onde o modelo local corrige o global (furtos/1.000 hab.)", "Local − global", PAL_DIV()),
   "gwr_local_vs_global.png")

tema_g <- theme_light(base_size = 12) +
  theme(legend.position = "top", panel.grid.minor = element_blank(),
        plot.title = element_text(face = "bold"))

# ---- extra: regime global x local do litoral -----------------
p_reg <- ggplot(gl, aes(renda, tx_furto)) +
  geom_point(aes(colour = grupo), size = 1.8, alpha = 0.7) +
  geom_smooth(aes(colour = grupo), method = "lm", se = FALSE, linewidth = 1) +
  geom_smooth(method = "lm", se = FALSE, colour = "grey30", linetype = "dashed",
              linewidth = 0.8) +
  scale_colour_manual(values = COR_GRUPO) +
  labs(title = "Regime litorâneo x interior (perspectiva global x local)",
       subtitle = "Reta tracejada = modelo global; retas coloridas = regimes separados",
       x = "Renda média per capita (R$)", y = "Furtos por 1.000 hab.",
       colour = NULL, caption = FONTE_DADOS) + tema_g
ggsave(file.path(DIR_OUT, "litoral_regime_global_local.png"), p_reg, width = 9, height = 6, dpi = 150)
cat("✓ litoral_regime_global_local.png\n")

# ---- resíduos (por último): mapa, boxplot e dispersão ---------
sv(mapa_fill("res_sem_lit", "Resíduos do modelo sem a variável litorânea",
   sprintf("Correlação resíduo × litoral = %.2f; Moran's I = %.2f", cor_sem, moran_sem),
   "Resíduo", PAL_DIV()),
   "residuos_mapa_sem_litoral.png")

res_long <- gl |> sf::st_drop_geometry() |>
  tidyr::pivot_longer(c(res_sem_lit, res_com_lit), names_to = "modelo", values_to = "residuo") |>
  mutate(modelo = factor(modelo, c("res_sem_lit", "res_com_lit"),
                         c("Sem litoral (~ renda)", "Com litoral (~ renda + litoral)")))
p_box <- ggplot(res_long, aes(grupo, residuo, fill = grupo)) +
  geom_hline(yintercept = 0, colour = "grey60") +
  geom_boxplot(outlier.size = 0.7, alpha = 0.85) +
  facet_wrap(~modelo) +
  scale_fill_manual(values = COR_GRUPO) +
  labs(title = "Resíduos por grupo, antes e depois de incluir a variável litorânea",
       subtitle = "Sem litoral, os resíduos dos litorâneos são sistematicamente positivos; com litoral, centram em zero",
       x = NULL, y = "Resíduo (furtos/1.000 hab.)", fill = NULL, caption = FONTE_DADOS) +
  tema_g
ggsave(file.path(DIR_OUT, "residuos_litoral_boxplot.png"), p_box, width = 10, height = 6, dpi = 150)
cat("✓ residuos_litoral_boxplot.png\n")

p_disp <- ggplot(gl, aes(renda, res_sem_lit, colour = grupo)) +
  geom_hline(yintercept = 0, colour = "grey60") +
  geom_point(size = 1.8, alpha = 0.7) +
  scale_colour_manual(values = COR_GRUPO) +
  labs(title = "Resíduos do modelo sem litoral × renda",
       subtitle = "Os municípios litorâneos concentram os maiores resíduos positivos",
       x = "Renda média per capita (R$)", y = "Resíduo (furtos/1.000 hab.)",
       colour = NULL, caption = FONTE_DADOS) + tema_g
ggsave(file.path(DIR_OUT, "residuos_dispersao_litoral.png"), p_disp, width = 9, height = 6, dpi = 150)
cat("✓ residuos_dispersao_litoral.png\n")

# objetos para o relatório
gwr_litoral <- list(
  bw_rl = bw_rl, gwr_rl = gwr_rl, comp = gwr_comp, res_grupo = res_por_grupo,
  cor_sem = cor_sem, cor_com = cor_com, moran_sem = moran_sem, moran_com = moran_com,
  m_litoral = m_litoral, m_interior = m_interior,
  impacto_max = max(gl$impacto_lit), qr2_rl = qr2(gwr_rl), qr2_r = qr2(gwr_r),
  pct_sig_renda = pct_sig_renda, pct_sig_litoral = pct_sig_litoral
)
