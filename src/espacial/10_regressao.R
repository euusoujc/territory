# 10_regressao.R — regressão linear clássica (roteiro da prática da semana)
#
# Pergunta: a taxa de furto por 1.000 hab. é explicada pela renda média
# (hipótese H1) e/ou pela condição litorânea/turística (hipótese H2)?
#
# Segue as técnicas da aula: regressão simples e múltipla com lm(),
# extração com broom, diagnóstico de resíduos com car, transformação log
# e tabela comparativa com stargazer. Figuras salvas em outputs/.

suppressPackageStartupMessages({
  library(dplyr); library(ggplot2); library(broom); library(car)
})

# ----- dados --------------------------------------------------
reg_df <- tabelao |>
  filter(!is.na(renda), !is.na(taxa_furto_1000)) |>
  mutate(grupo = factor(litoranea_turistica, c(0, 1),
                        c("Demais municípios", "Litorâneo/turístico")))

cat(sprintf("Regressão: %d municípios (%d litorâneos/turísticos)\n",
            nrow(reg_df), sum(reg_df$litoranea_turistica)))

tema_reg <- theme_light(base_size = 12) +
  theme(legend.position = "top", panel.grid.minor = element_blank(),
        plot.title = element_text(face = "bold"))
COR_GRUPO <- c("Demais municípios" = "#6baed6", "Litorâneo/turístico" = "#d95f02")

# ----- 1. Análise exploratória --------------------------------
p_disp <- ggplot(reg_df, aes(renda, taxa_furto_1000)) +
  geom_point(aes(colour = grupo), size = 1.9, alpha = 0.7) +
  geom_smooth(method = "lm", se = TRUE, colour = "grey20", linewidth = 0.7) +
  scale_colour_manual(values = COR_GRUPO) +
  labs(title = "Taxa de furto e renda média por município",
       subtitle = "Cada ponto é um município de SP; reta = ajuste linear simples",
       x = "Renda média per capita (R$)", y = "Furtos por 1.000 hab.",
       colour = NULL, caption = FONTE_DADOS) +
  tema_reg
ggsave(file.path(DIR_OUT, "reg_dispersao.png"), p_disp, width = 9, height = 6, dpi = 150)
cat("✓ reg_dispersao.png\n")

# ----- 2. Regressão linear SIMPLES ----------------------------
m_simples <- lm(taxa_furto_1000 ~ renda, data = reg_df)

cat("\n=== Modelo simples: taxa_furto ~ renda ===\n")
print(broom::tidy(m_simples))
print(broom::glance(m_simples)[c("r.squared", "adj.r.squared", "p.value")])

# ----- 3. Influência dos outliers na reta de tendência --------
# Distância de Cook mede quanto cada município puxa o ajuste. Pontos
# com Cook > 4/n são influentes: reajustar sem eles muda a inclinação.
reg_df$cook <- cooks.distance(m_simples)
limiar_cook <- 4 / nrow(reg_df)
reg_df$influente <- reg_df$cook > limiar_cook
m_sem_infl <- lm(taxa_furto_1000 ~ renda, data = filter(reg_df, !influente))

rotulos_infl <- reg_df |>
  slice_max(cook, n = 5) |>
  mutate(rot = sprintf("%s (Cook %.2f)", municipio, cook))

p_outlier <- ggplot(reg_df, aes(renda, taxa_furto_1000)) +
  geom_point(aes(colour = influente, size = cook), alpha = 0.65) +
  geom_smooth(method = "lm", se = FALSE, aes(linetype = "Todos os municípios"),
              colour = "grey20", linewidth = 0.9) +
  geom_abline(aes(slope = coef(m_sem_infl)[2], intercept = coef(m_sem_infl)[1],
                  linetype = "Sem os pontos influentes"),
              colour = "#d95f02", linewidth = 0.9) +
  ggrepel::geom_text_repel(data = rotulos_infl, aes(label = municipio),
                           size = 3, colour = "grey20", min.segment.length = 0) +
  scale_colour_manual(values = c("FALSE" = "#9ecae1", "TRUE" = "#08519c"),
                      labels = c("FALSE" = "Comum", "TRUE" = "Influente (Cook > 4/n)")) +
  scale_size_continuous(range = c(1, 6), guide = "none") +
  scale_linetype_manual(values = c("Todos os municípios" = "solid",
                                   "Sem os pontos influentes" = "dashed")) +
  labs(title = "Influência dos outliers na reta de tendência",
       subtitle = sprintf("Sem os %d municípios influentes, a inclinação da renda sobe de %s para %s e o R² vai de %s a %s",
                          sum(reg_df$influente),
                          formatC(coef(m_simples)[2], format = "f", digits = 5, decimal.mark = ","),
                          formatC(coef(m_sem_infl)[2], format = "f", digits = 5, decimal.mark = ","),
                          formatC(summary(m_simples)$r.squared, format = "f", digits = 2, decimal.mark = ","),
                          formatC(summary(m_sem_infl)$r.squared, format = "f", digits = 2, decimal.mark = ",")),
       x = "Renda média per capita (R$)", y = "Furtos por 1.000 hab.",
       colour = NULL, linetype = NULL, caption = FONTE_DADOS) +
  tema_reg
ggsave(file.path(DIR_OUT, "reg_outliers.png"), p_outlier, width = 9.5, height = 6, dpi = 150)
cat("✓ reg_outliers.png\n")

# ----- 4. Regressão linear MÚLTIPLA (renda + dummy litoral) ---
m_multipla <- lm(taxa_furto_1000 ~ renda + litoranea_turistica, data = reg_df)

cat("\n=== Modelo múltiplo: taxa_furto ~ renda + litoranea_turistica ===\n")
print(broom::tidy(m_multipla))
print(broom::glance(m_multipla)[c("r.squared", "adj.r.squared", "p.value")])

# Duas retas paralelas: o dummy desloca o intercepto (efeito litoral)
reg_df$ajuste_multiplo <- predict(m_multipla)
p_multipla <- ggplot(reg_df, aes(renda, taxa_furto_1000, colour = grupo)) +
  geom_point(size = 1.9, alpha = 0.7) +
  geom_line(aes(y = ajuste_multiplo), linewidth = 0.9) +
  scale_colour_manual(values = COR_GRUPO) +
  labs(title = "Modelo múltiplo: renda mais a condição litorânea/turística",
       subtitle = "O dummy desloca a reta: mesma inclinação da renda, patamar mais alto no litoral",
       x = "Renda média per capita (R$)", y = "Furtos por 1.000 hab.",
       colour = NULL, caption = FONTE_DADOS) +
  tema_reg
ggsave(file.path(DIR_OUT, "reg_multipla.png"), p_multipla, width = 9, height = 6, dpi = 150)
cat("✓ reg_multipla.png\n")

# ----- 5. Transformação logarítmica da renda ------------------
m_log <- lm(taxa_furto_1000 ~ log(renda) + litoranea_turistica, data = reg_df)
cat("\n=== Modelo com log(renda) ===\n")
print(broom::tidy(m_log))
print(broom::glance(m_log)[c("r.squared", "adj.r.squared")])

# ----- 6. Diagnóstico dos resíduos (modelo múltiplo) ----------
reg_diag <- augment(m_multipla)

p_res_hist <- ggplot(reg_diag, aes(.resid)) +
  geom_histogram(aes(y = after_stat(density)), bins = 40,
                 fill = "#6baed6", colour = "white") +
  geom_density(colour = "#08519c", linewidth = 0.8) +
  labs(title = "Distribuição dos resíduos", x = "Resíduo", y = "Densidade") +
  tema_reg

p_res_fit <- ggplot(reg_diag, aes(.fitted, .resid)) +
  geom_point(colour = "#6baed6", alpha = 0.7) +
  geom_hline(yintercept = 0, colour = "grey30") +
  geom_smooth(method = "loess", se = FALSE, colour = "#d95f02", linewidth = 0.7) +
  labs(title = "Resíduos vs. valores ajustados", x = "Valor ajustado", y = "Resíduo") +
  tema_reg

p_diag <- patchwork::wrap_plots(p_res_hist, p_res_fit, ncol = 2)
ggsave(file.path(DIR_OUT, "reg_residuos.png"), p_diag, width = 11, height = 5, dpi = 150)
cat("✓ reg_residuos.png\n")

# Q-Q plot (normalidade) via car::qqPlot
png(file.path(DIR_OUT, "reg_qqplot.png"), width = 1400, height = 1100, res = 200)
car::qqPlot(m_multipla, main = "Q-Q plot dos resíduos (normalidade)",
            ylab = "Resíduos studentizados", xlab = "Quantis teóricos", id = FALSE)
dev.off()
cat("✓ reg_qqplot.png\n")

# Testes formais
teste_ncv <- car::ncvTest(m_multipla)          # homocedasticidade
teste_shapiro <- shapiro.test(residuals(m_multipla))  # normalidade
vif_vals <- car::vif(m_multipla)               # multicolinearidade

cat("\n=== Diagnóstico ===\n")
cat(sprintf("ncvTest (homocedasticidade): p = %.4g\n", teste_ncv$p))
cat(sprintf("Shapiro-Wilk (normalidade): p = %.4g\n", teste_shapiro$p.value))
cat("VIF:\n"); print(round(vif_vals, 2))

# ----- 7. Tabela comparativa dos modelos ----------------------
sink(file.path(DIR_OUT, "reg_tabela.txt"))
stargazer::stargazer(
  m_simples, m_multipla, m_log, type = "text",
  title = "Modelos de regressão para a taxa de furto por 1.000 hab.",
  dep.var.labels = "Furtos por 1.000 hab.",
  covariate.labels = c("Renda média (R$)", "log(Renda)", "Litorâneo/turístico"),
  digits = 4, no.space = TRUE)
sink()
cat("✓ reg_tabela.txt\n")

# ----- 8. Objetos para o relatório ----------------------------
reg_resultados <- list(
  simples  = list(coef = coef(m_simples),  r2 = summary(m_simples)$r.squared),
  multipla = list(coef = coef(m_multipla),
                  r2 = summary(m_multipla)$r.squared,
                  r2aj = summary(m_multipla)$adj.r.squared,
                  tidy = broom::tidy(m_multipla)),
  log      = list(coef = coef(m_log), r2 = summary(m_log)$r.squared),
  sem_influentes = list(coef = coef(m_sem_infl),
                        r2 = summary(m_sem_infl)$r.squared,
                        n_influentes = sum(reg_df$influente)),
  diag = list(ncv = teste_ncv$p, shapiro = teste_shapiro$p.value, vif = vif_vals)
)

cat("\n--- Relatório automático (report::report) ---\n")
tryCatch(print(summary(report::report(m_multipla))),
         error = function(e) cat("report indisponível:", conditionMessage(e), "\n"))
