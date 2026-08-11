# 01_tabelao.R — constrói data/tabelao.csv (uma linha por município de SP)
# e valida chave IBGE, tipos e NAs. Inconsistências vão para
# outputs/validacao_tabelao.txt; problemas de chave interrompem o pipeline.
#
# Se data/tabelao.csv já existir (ex.: versão revisada manualmente),
# ele NÃO é reconstruído — apague o arquivo para forçar a reconstrução.

ARQ_TABELAO <- file.path(DIR_DATA, "tabelao.csv")

# Resolve nomes de municípios no padrão SSP (abreviados: "S BARBARA D OESTE")
# para o código IBGE, casando contra a base de população. Cascata:
# 1) match exato da chave normalizada (sem acento/apóstrofo);
# 2) expansão de abreviações (S -> SAO/SANTA/SANTO, STO, STA, PTA) + match;
# 3) match ignorando preposições (DO/DA/DOS/DAS/DE);
# 4) distância de edição <= 1 (variações de grafia, ex. FLORINIA/FLORINEA).
# Só aceita resoluções com match único; o resto vira NA (reportado e descartado).
resolver_cod_por_nome <- function(nomes, pop) {
  chave    <- function(x) trimws(gsub("\\s+", " ", gsub("'", " ", normalizar_municipio(x))))
  sem_prep <- function(x) trimws(gsub("\\s+", " ", gsub("\\b(DO|DA|DOS|DAS|DE)\\b", " ", x)))

  keys  <- chave(pop$municipio)
  keys2 <- sem_prep(keys)

  expandir <- function(n) {
    cands <- n
    if (grepl("^S ", n))
      cands <- c(cands, sub("^S ", "SAO ", n), sub("^S ", "SANTA ", n), sub("^S ", "SANTO ", n))
    cands <- unlist(lapply(cands, function(cc) c(
      cc,
      gsub("\\bSTO\\b", "SANTO", cc), gsub("\\bSTA\\b", "SANTA", cc),
      gsub("\\bPTA\\b", "PAULISTA", cc),
      sub(" S ", " SANTO ", cc), sub(" S ", " SANTA ", cc), sub(" S ", " SAO ", cc)
    )))
    unique(cands)
  }

  vapply(nomes, function(nome) {
    cands <- expandir(chave(nome))
    hit <- unique(pop$cod_ibge[keys %in% cands])
    if (length(hit) == 1) return(hit)
    hit <- unique(pop$cod_ibge[keys2 %in% sem_prep(cands)])
    if (length(hit) == 1) return(hit)
    d <- utils::adist(sem_prep(cands), keys2)
    hit <- unique(pop$cod_ibge[apply(d, 2, min) <= 1])
    if (length(hit) == 1) return(hit)
    NA_character_
  }, character(1), USE.NAMES = TRUE)
}

construir_tabelao <- function() {
  rpc <- readxl::read_excel(file.path(DIR_DOCS, "analise_2025.xlsx"),
                            sheet = "Rubrica_PerCapita")

  # Renda tem código IBGE na própria base — join direto por código
  renda <- readxl::read_excel(file.path(DIR_DOCS, "Renda_por_Municipio_-_SP.xlsx")) |>
    transmute(cod_ibge = as.character(COD), renda = as.numeric(RENDA)) |>
    filter(!is.na(cod_ibge)) |>
    distinct(cod_ibge, .keep_all = TRUE)

  # Universo: todos os municípios de SP na Tabela 4709 (população, IBGE)
  pop <- read.csv(file.path(DIR_DOCS, "tabela4709.csv"),
                  fileEncoding = "UTF-8-BOM", stringsAsFactors = FALSE)
  colnames(pop) <- c("cod_ibge", "municipio", "populacao")
  pop <- pop |>
    filter(grepl("\\(SP\\)$", municipio)) |>
    mutate(cod_ibge  = as.character(cod_ibge),
           municipio = sub(" \\(SP\\)$", "", municipio),
           populacao = as.integer(populacao))

  # Recupera códigos IBGE que o join por nome da base consolidada perdeu
  rpc$cod_ibge <- as.character(rpc$COD_IBGE)
  sem_codigo <- unique(rpc$NOME_MUNICIPIO[is.na(rpc$cod_ibge)])
  if (length(sem_codigo)) {
    resolvidos <- resolver_cod_por_nome(sem_codigo, pop)
    rpc$cod_ibge[is.na(rpc$cod_ibge)] <-
      resolvidos[rpc$NOME_MUNICIPIO[is.na(rpc$cod_ibge)]]
    descartados <- sem_codigo[is.na(resolvidos)]
    cat(sprintf("Códigos IBGE recuperados por nome: %d de %d\n",
                sum(!is.na(resolvidos)), length(sem_codigo)))
    if (length(descartados))
      cat(sprintf("Descartados (fora de SP ou não identificados): %s\n",
                  paste(descartados, collapse = ", ")))
  }

  contagens <- rpc |>
    mutate(crime_slug = case_when(
      grepl("157", RUBRICA) ~ "roubo",
      grepl("155", RUBRICA) ~ "furto",
      grepl("129", RUBRICA) ~ "lesao"
    )) |>
    filter(!is.na(crime_slug), !is.na(cod_ibge)) |>
    group_by(cod_ibge, crime_slug) |>
    summarise(n = sum(QUANTIDADE), .groups = "drop") |>
    tidyr::pivot_wider(names_from = crime_slug, values_from = n,
                       names_prefix = "n_", values_fill = 0)

  tab <- pop |>
    left_join(contagens, by = "cod_ibge") |>
    left_join(renda,     by = "cod_ibge") |>
    mutate(
      across(all_of(paste0("n_", names(CRIMES))), ~ tidyr::replace_na(., 0L)),
      taxa_roubo_1000 = round(n_roubo / populacao * 1000, 3),
      taxa_furto_1000 = round(n_furto / populacao * 1000, 3),
      taxa_lesao_1000 = round(n_lesao / populacao * 1000, 3)
    ) |>
    select(cod_ibge, municipio, populacao, renda,
           n_roubo, n_furto, n_lesao, all_of(unname(TAXAS))) |>
    arrange(cod_ibge)

  readr::write_csv(tab, ARQ_TABELAO)
  cat(sprintf("✓ %s construído: %d municípios\n", basename(ARQ_TABELAO), nrow(tab)))
  tab
}

validar_tabelao <- function(tab) {
  problemas <- character(0)
  avisos    <- character(0)

  # --- chave IBGE (erros fatais) -------------------------------
  if (any(is.na(tab$cod_ibge)))
    problemas <- c(problemas, "cod_ibge com NA")
  if (any(duplicated(tab$cod_ibge)))
    problemas <- c(problemas, sprintf("cod_ibge duplicado: %s",
      paste(tab$cod_ibge[duplicated(tab$cod_ibge)], collapse = ", ")))
  fora_padrao <- !grepl("^35\\d{5}$", tab$cod_ibge)
  if (any(fora_padrao))
    problemas <- c(problemas, sprintf("%d códigos fora do padrão SP (7 dígitos, prefixo 35): %s",
      sum(fora_padrao), paste(head(tab$cod_ibge[fora_padrao], 10), collapse = ", ")))

  # --- cobertura ------------------------------------------------
  if (nrow(tab) != 645)
    avisos <- c(avisos, sprintf("esperados 645 municípios em SP, encontrados %d", nrow(tab)))

  # --- tipos ----------------------------------------------------
  num_cols <- c("populacao", "renda", paste0("n_", names(CRIMES)), unname(TAXAS))
  nao_num <- num_cols[!sapply(tab[num_cols], is.numeric)]
  if (length(nao_num))
    problemas <- c(problemas, sprintf("colunas não numéricas: %s", paste(nao_num, collapse = ", ")))

  # --- NAs ------------------------------------------------------
  nas <- colSums(is.na(tab))
  nas <- nas[nas > 0]
  for (col in names(nas)) {
    quais <- head(tab$municipio[is.na(tab[[col]])], 10)
    avisos <- c(avisos, sprintf("coluna '%s' com %d NA(s): %s", col, nas[[col]],
                                paste(quais, collapse = ", ")))
  }

  # --- valores --------------------------------------------------
  if (length(nao_num) == 0) {
    for (col in unname(TAXAS)) {
      if (any(tab[[col]] < 0, na.rm = TRUE))
        problemas <- c(problemas, sprintf("taxas negativas em %s", col))
    }
    if (any(tab$populacao <= 0, na.rm = TRUE))
      problemas <- c(problemas, "população <= 0")
    # coerência taxa = n / pop * 1000
    for (crime in names(CRIMES)) {
      esperada <- tab[[paste0("n_", crime)]] / tab$populacao * 1000
      desvio <- abs(tab[[TAXAS[crime]]] - esperada) > 0.01
      if (any(desvio, na.rm = TRUE))
        avisos <- c(avisos, sprintf("taxa de %s incoerente com contagem/população em %d município(s)",
                                    crime, sum(desvio, na.rm = TRUE)))
    }
  }

  linhas <- c(
    sprintf("Validação do tabelão — %s", format(Sys.time(), "%Y-%m-%d %H:%M")),
    sprintf("Arquivo: %s | %d linhas x %d colunas", ARQ_TABELAO, nrow(tab), ncol(tab)),
    "",
    if (length(problemas)) c("ERROS:", paste(" -", problemas)) else "ERROS: nenhum",
    "",
    if (length(avisos)) c("AVISOS:", paste(" -", avisos)) else "AVISOS: nenhum"
  )
  writeLines(linhas, file.path(DIR_OUT, "validacao_tabelao.txt"))
  cat(paste(linhas, collapse = "\n"), "\n")

  if (length(problemas))
    stop("Tabelão reprovado na validação — ver outputs/validacao_tabelao.txt")
  invisible(TRUE)
}

if (!file.exists(ARQ_TABELAO)) {
  construir_tabelao()
} else {
  cat(sprintf("• %s já existe — usando a versão atual (apague para reconstruir)\n",
              basename(ARQ_TABELAO)))
}

tabelao <- readr::read_csv(ARQ_TABELAO, col_types = readr::cols(
  cod_ibge = readr::col_character(), municipio = readr::col_character(),
  .default = readr::col_double()
))
validar_tabelao(tabelao)
