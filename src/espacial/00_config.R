# 00_config.R — dependências, caminhos e parâmetros do pipeline espacial

pacotes <- c("readxl", "dplyr", "tidyr", "readr", "ggplot2", "corrplot",
             "stringi", "sf", "spdep", "geobr", "classInt")
novos <- pacotes[!sapply(pacotes, requireNamespace, quietly = TRUE)]
if (length(novos)) install.packages(novos, repos = "https://cloud.r-project.org")
suppressPackageStartupMessages(
  invisible(lapply(c("dplyr", "sf", "spdep", "ggplot2"), library, character.only = TRUE))
)

if (!exists("DIR_ROOT")) DIR_ROOT <- getwd()
DIR_DOCS <- file.path(DIR_ROOT, "docs")
DIR_DATA <- file.path(DIR_ROOT, "data")
DIR_OUT  <- file.path(DIR_ROOT, "outputs")
dir.create(DIR_DATA, showWarnings = FALSE)
dir.create(DIR_OUT,  showWarnings = FALSE)

source(file.path(DIR_ROOT, "src", "utils.R"))  # normalizar_municipio()

# Crimes analisados: slug -> rótulo para figuras/relatório
CRIMES <- c(
  roubo = "Roubo (art. 157)",
  furto = "Furto (art. 155)",
  lesao = "Lesão corporal (art. 129)"
)
TAXAS <- setNames(paste0("taxa_", names(CRIMES), "_1000"), names(CRIMES))

ANO_MALHA   <- 2022
SIG_LISA    <- 0.05   # significância para clusters LISA
N_PERM      <- 999    # permutações do Moran global (moran.mc)
SEED        <- 42

# Paleta (jobs de cor): sequencial de um matiz para magnitude;
# categóricas fixas para clusters LISA (convenção da literatura)
PAL_SEQ  <- c("#eff3ff", "#bdd7e7", "#6baed6", "#3182bd", "#08519c")
PAL_LISA <- c("Alto-Alto"          = "#b2182b",
              "Baixo-Baixo"        = "#2166ac",
              "Alto-Baixo"         = "#ef8a62",
              "Baixo-Alto"         = "#67a9cf",
              "Não significativo"  = "#e6e6e6")

tema_mapa <- function() {
  theme_void(base_size = 12) +
    theme(
      legend.position = "right",
      plot.title    = element_text(face = "bold", size = 13),
      plot.subtitle = element_text(size = 10, colour = "grey30"),
      plot.caption  = element_text(size = 8,  colour = "grey50")
    )
}

FONTE_DADOS <- "Fontes: SSP-SP (2025), IBGE Censo 2022 (renda, população e malha)"
