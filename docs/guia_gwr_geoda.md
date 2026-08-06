# Guia GeoDa — mapas do GWR (taxa de furto ~ renda)

O GWR roda em R (o GeoDa não calcula GWR), então já deixamos os resultados
por município empacotados para você abrir no GeoDa e gerar os mapas.

## Arquivo de entrada

Abra no GeoDa (**File > New > Input file**) um destes, são idênticos:

| Arquivo | Observação |
|---|---|
| `data/geoda_gwr_furto.gpkg` | GeoPackage, recomendado |
| `data/geoda_gwr_furto_shp/geoda_gwr_furto.shp` | Shapefile, alternativa |

## Colunas do pacote (uma por município)

| Coluna | O que é |
|---|---|
| `tx_furto` | taxa de furto por 1.000 hab. (variável dependente) |
| `renda` | renda média per capita (variável explicativa) |
| `b0` | intercepto local do GWR |
| `b_renda` | **coeficiente local da renda (beta)**: quanto a taxa muda por R$ 1 de renda |
| `se_renda` | erro-padrão local do beta |
| `t_renda` | **estatística t** do beta (significância local) |
| `sig_renda` | 1 se o beta é significativo (\|t\| > 1,96), 0 caso contrário |
| `localR2` | **R² local**: quanto a renda explica o furto naquele ponto |
| `y_hat` | taxa de furto prevista pelo GWR |
| `resid` | **resíduo** (observado menos previsto) |
| `std_res` | resíduo padronizado (para achar outliers) |

## Mapas a gerar no GeoDa

Em cada caso: **Map > (tipo de mapa)** e escolha a coluna. Sugestões:

1. **Coeficiente da renda (beta)** — coluna `b_renda`, mapa **Standard Deviation**
   ou **Natural Breaks**. Mostra onde a renda pesa mais (positivo) ou até se
   inverte (negativo) na taxa de furto.
2. **Estatística t** — coluna `t_renda`. Para ver a significância, use a coluna
   pronta `sig_renda` num **Unique Values Map** (1 = significativo, 0 = não), ou
   um mapa de `t_renda` com quebra manual em ±1,96.
3. **R² local** — coluna `localR2`, mapa **Quantile** ou **Natural Breaks**.
   Onde é mais escuro, a renda explica melhor o furto; onde é claro, explica mal
   (e outros fatores, como o turismo litorâneo, dominam).
4. **Resíduos** — coluna `resid` (ou `std_res`), mapa **Standard Deviation** ou
   **Box Map (Hinge = 1.5)** para destacar os outliers. Os maiores resíduos
   positivos ficam no litoral, onde o modelo só com renda subestima o furto.

## Leitura rápida (valores de referência do GWR em R)

- Efeito da renda (global): cada **R$ 1** a mais de renda soma **0,00247**
  furto/1.000 hab. (R$ 100 = +0,25; R$ 1.000 = +2,47). No GWR esse efeito varia
  no espaço, de cerca de **&minus;0,22 a +0,56 furto/1.000 hab. por R$ 100**.
- **R² local** vai de 0,05 a 0,64; **72%** dos municípios têm o efeito da renda
  significativo.
- O GWR (R² quase-global 0,46) explica bem mais que o modelo global (R² 0,13),
  porque deixa a relação renda–furto mudar de vizinhança para vizinhança.

> Os mapas equivalentes gerados em R estão em `outputs/gwrfr_*.png` para conferência.
