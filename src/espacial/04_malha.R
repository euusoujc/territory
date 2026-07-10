# 04_malha.R — malha de municípios de SP (UF 35), IBGE
#
# Baixa via geobr (malha municipal do Censo, já recortada para SP) e salva
# cache em data/malha_municipios_sp.gpkg. Se o geobr estiver fora do ar,
# usa a API de malhas do IBGE como fallback. Nada de passo manual.

ARQ_MALHA <- file.path(DIR_DATA, "malha_municipios_sp.gpkg")

if (!file.exists(ARQ_MALHA)) {
  cat("Baixando malha de municípios de SP (IBGE)...\n")
  malha <- tryCatch({
    m <- geobr::read_municipality(code_muni = "SP", year = ANO_MALHA,
                                  simplified = TRUE, showProgress = FALSE)
    m |> transmute(cod_ibge = as.character(code_muni), nome_malha = name_muni)
  }, error = function(e) {
    cat(sprintf("geobr falhou (%s) — usando API de malhas do IBGE\n", conditionMessage(e)))
    url <- paste0("https://servicodados.ibge.gov.br/api/v3/malhas/estados/35",
                  "?formato=application/vnd.geo+json&qualidade=intermediaria",
                  "&intrarregiao=municipio")
    tmp <- tempfile(fileext = ".geojson")
    utils::download.file(url, tmp, quiet = TRUE, mode = "wb")
    sf::read_sf(tmp) |> transmute(cod_ibge = as.character(codarea),
                                  nome_malha = NA_character_)
  })
  sf::write_sf(malha, ARQ_MALHA)
  cat(sprintf("✓ %s salvo: %d polígonos\n", basename(ARQ_MALHA), nrow(malha)))
} else {
  cat(sprintf("• %s já existe — usando cache local\n", basename(ARQ_MALHA)))
}

malha <- sf::read_sf(ARQ_MALHA)

# Join malha x tabelão pela chave IBGE
malha_dados <- malha |>
  left_join(tabelao, by = "cod_ibge")

sem_dados <- malha_dados |> filter(is.na(municipio))
sem_geom  <- setdiff(tabelao$cod_ibge, malha$cod_ibge)
if (nrow(sem_dados) > 0)
  warning(sprintf("%d polígonos sem dados no tabelão: %s", nrow(sem_dados),
                  paste(head(sem_dados$cod_ibge, 10), collapse = ", ")))
if (length(sem_geom) > 0)
  warning(sprintf("%d municípios do tabelão sem polígono na malha: %s",
                  length(sem_geom), paste(head(sem_geom, 10), collapse = ", ")))
cat(sprintf("Malha x tabelão: %d municípios pareados\n",
            sum(!is.na(malha_dados$municipio))))
