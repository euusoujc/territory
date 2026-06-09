# utils.R — funções auxiliares

library(stringi)

# Normaliza nome de município: maiúsculo, sem acento, sem pontuação, espaços simples
normalizar_municipio <- function(x) {
  x <- toupper(trimws(x))
  x <- stri_trans_general(x, "Latin-ASCII")
  x <- gsub("[.\\-]", " ", x)
  x <- gsub("\\s+", " ", x)
  trimws(x)
}

# Tabela de abreviações presentes na base criminal
abreviacoes <- c(
  "S PAULO"                  = "SAO PAULO",
  "S BERNARDO DO CAMPO"      = "SAO BERNARDO DO CAMPO",
  "S CAETANO DO SUL"         = "SAO CAETANO DO SUL",
  "S VICENTE"                = "SAO VICENTE",
  "S ANDRE"                  = "SANTO ANDRE",
  "S JOSE DO RIO PRETO"      = "SAO JOSE DO RIO PRETO",
  "S JOSE DOS CAMPOS"        = "SAO JOSE DOS CAMPOS",
  "S JOSE DO RIO PARDO"      = "SAO JOSE DO RIO PARDO",
  "S JOAO DA BOA VISTA"      = "SAO JOAO DA BOA VISTA",
  "S ROQUE"                  = "SAO ROQUE",
  "S SEBASTIAO"              = "SAO SEBASTIAO",
  "S LUIZ DO PARAITINGA"     = "SAO LUIZ DO PARAITINGA",
  "S JOSE DO BARREIRO"       = "SAO JOSE DO BARREIRO",
  "S BRANCA"                 = "SANTA BRANCA",
  "S ANTONIO DO PINHAL"      = "SANTO ANTONIO DO PINHAL",
  "S BENTO DO SAPUCAI"       = "SAO BENTO DO SAPUCAI",
  "S ANTONIO DE ARACANGUA"   = "SANTO ANTONIO DO ARACANGUA",
  "S JOAO DE IRACEMA"        = "SAO JOAO DE IRACEMA",
  "S ANTONIO DE POSSE"       = "SANTO ANTONIO DE POSSE",
  "S CARLOS"                 = "SAO CARLOS",
  "S SIMAO"                  = "SAO SIMAO",
  "S RITA PASSA QUATRO"      = "SANTA RITA DO PASSA QUATRO",
  "S ERNESTINA"              = "SANTA ERNESTINA",
  "S LUCIA"                  = "SANTA LUCIA",
  "S JOSE DA BELA VISTA"     = "SAO JOSE DA BELA VISTA"
)

aplicar_abreviacoes <- function(x) {
  for (abr in names(abreviacoes)) {
    x[x == abr] <- abreviacoes[[abr]]
  }
  x
}