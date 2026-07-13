# 09_geoda.R — exporta a malha com os atributos do tabelão para uso no GeoDa
#
# Gera dois formatos:
#   data/geoda_sp.gpkg          — GeoPackage (recomendado, sem limite de nomes)
#   data/geoda_sp_shp/          — Shapefile (fallback; nomes de coluna <= 10 chars)
#
# Colunas curtas e sem acento para compatibilidade com o DBF do shapefile.

geoda <- malha_dados |>
  transmute(
    cod_ibge  = cod_ibge,
    municipio = municipio,
    pop       = populacao,
    renda     = renda,
    n_roubo   = n_roubo,
    n_furto   = n_furto,
    n_lesao   = n_lesao,
    tx_roubo  = taxa_roubo_1000,
    tx_furto  = taxa_furto_1000,
    tx_lesao  = taxa_lesao_1000,
    litoral   = litoranea_turistica
  )

sf::write_sf(geoda, file.path(DIR_DATA, "geoda_sp.gpkg"), delete_dsn = TRUE)

dir_shp <- file.path(DIR_DATA, "geoda_sp_shp")
dir.create(dir_shp, showWarnings = FALSE)
sf::write_sf(geoda, file.path(dir_shp, "geoda_sp.shp"),
             delete_layer = TRUE, quiet = TRUE)

cat(sprintf("✓ geoda_sp.gpkg e geoda_sp_shp/ exportados (%d municípios, %d colunas)\n",
            nrow(geoda), ncol(geoda) - 1))
