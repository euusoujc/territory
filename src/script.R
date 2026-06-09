library(readxl)
library(openxlsx)

caminho <- "C:/Users/User/Documents/Dados_Territorio/SPDadosCriminais_2025.xlsx"
colunas <- c("NOME_MUNICIPIO", "RUBRICA", "NATUREZA_APURADA")

jan_jun <- read_excel(caminho, sheet = "JAN-JUN_2025")[, colunas]
jul_dez <- read_excel(caminho, sheet = "JUL-DEZ_2025")[, colunas]

base_tratada <- rbind(jan_jun, jul_dez)
  
write.xlsx(base_tratada, "C:/Users/User/Documents/Dados_Territorio/base_tratada_2025.xlsx", rowNames = FALSE)

print(paste("Linhas totais:", nrow(base_tratada)))
head(base_tratada)

contagem_rubrica <- as.data.frame(table(base_tratada$RUBRICA))
colnames(contagem_rubrica) <- c("RUBRICA", "QUANTIDADE")
contagem_rubrica <- contagem_rubrica[order(-contagem_rubrica$QUANTIDADE), ]

print(contagem_rubrica)
write.xlsx(contagem_rubrica, "C:/Users/User/Documents/Dados_Territorio/contagem_rubrica.xlsx", rowNames = FALSE)

