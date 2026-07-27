# Saídas de referência — regressão espacial

Estas imagens reproduzem, no formato de saída do GeoDa, os resultados da
atividade de regressão espacial sobre os dados do trabalho (`geoda_sp.gpkg`,
modelo `tx_furto ~ renda`, vizinhança queen ordem 1). Servem de gabarito: os
valores são os mesmos que o GeoDa mostra ao rodar cada modelo (calculados em R
com `spdep`/`spatialreg`, etapa `11_regressao_espacial.R` do pipeline).

| Arquivo | Conteúdo |
|---|---|
| `geoda_saida_ols.png` | Regressão clássica (OLS) com os diagnósticos de dependência espacial (Moran's I e testes LM) |
| `geoda_saida_lag.png` | Modelo spatial lag (rho) |
| `geoda_saida_error.png` | Modelo spatial error (lambda) |
| `geoda_moran_residuos_ols.png` | Diagrama de Moran dos resíduos do modelo clássico |

Os mapas de resíduos e do GWR estão em `outputs/reg_esp_*.png`, e a
interpretação completa em `docs/regressao_espacial.pdf`.

> Observação: são reproduções geradas em R, não capturas de tela do GeoDa. Ao
> rodar no GeoDa, pequenas diferenças decimais podem aparecer pelo tratamento da
> ilha sem vizinhos (Ilhabela).
