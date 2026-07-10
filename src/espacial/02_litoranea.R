# 02_litoranea.R — dummy litoranea_turistica (1 = litorâneo/turístico)
#
# O arquivo data/litoranea_turistica.csv é EDITÁVEL: a classificação default
# marca apenas os 16 municípios do litoral paulista. Revise/edite o CSV
# (ex.: incluir estâncias turísticas do interior) e rode o pipeline de novo —
# o arquivo não é sobrescrito se já existir.

ARQ_LITORANEA <- file.path(DIR_DATA, "litoranea_turistica.csv")

# Os 16 municípios costeiros de SP (norte -> sul)
MUNICIPIOS_LITORAL <- c(
  "Ubatuba", "Caraguatatuba", "Ilhabela", "São Sebastião", "Bertioga",
  "Guarujá", "Santos", "São Vicente", "Cubatão", "Praia Grande",
  "Mongaguá", "Itanhaém", "Peruíbe", "Iguape", "Ilha Comprida", "Cananéia"
)

if (!file.exists(ARQ_LITORANEA)) {
  litoral_key <- normalizar_municipio(MUNICIPIOS_LITORAL)
  class_default <- tabelao |>
    transmute(
      cod_ibge, municipio,
      litoranea_turistica = as.integer(normalizar_municipio(municipio) %in% litoral_key),
      criterio = ifelse(normalizar_municipio(municipio) %in% litoral_key,
                        "litoral (default gerado — revisar)", "")
    )
  n_marcados <- sum(class_default$litoranea_turistica)
  if (n_marcados != length(MUNICIPIOS_LITORAL))
    warning(sprintf("Esperados %d litorâneos, marcados %d — verificar nomes",
                    length(MUNICIPIOS_LITORAL), n_marcados))
  readr::write_csv(class_default, ARQ_LITORANEA)
  cat(sprintf("✓ %s gerado (%d municípios marcados como litorâneos) — REVISE antes da versão final\n",
              basename(ARQ_LITORANEA), n_marcados))
} else {
  cat(sprintf("• %s já existe — usando a classificação atual\n", basename(ARQ_LITORANEA)))
}

litoranea <- readr::read_csv(ARQ_LITORANEA, col_types = readr::cols(
  cod_ibge = readr::col_character(), municipio = readr::col_character(),
  litoranea_turistica = readr::col_integer(), criterio = readr::col_character()
))

stopifnot(all(litoranea$litoranea_turistica %in% c(0L, 1L)))
if (!setequal(litoranea$cod_ibge, tabelao$cod_ibge))
  warning("Códigos IBGE de litoranea_turistica.csv não batem com o tabelão")

tabelao <- tabelao |>
  left_join(select(litoranea, cod_ibge, litoranea_turistica), by = "cod_ibge") |>
  mutate(litoranea_turistica = tidyr::replace_na(litoranea_turistica, 0L))

cat(sprintf("Municípios litorâneos/turísticos: %d de %d\n",
            sum(tabelao$litoranea_turistica), nrow(tabelao)))
