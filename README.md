# Furto, Renda e Território — Análise Espacial da Criminalidade em SP

Projeto acadêmico da disciplina **Análise de Dados para Planejamento Territorial**
(UFABC), sob orientação da Prof.ª **Flávia da Fonseca Feitosa**. Cruza ocorrências
criminais da SSP-SP (2025) com a renda média do Censo IBGE 2022 nos 645 municípios
de São Paulo para investigar:

> **Acontecem mais crimes nas cidades mais pobres?**

A hipótese original (H1) **não se confirma**: a correlação entre renda e taxa de
furto é positiva, não negativa. A explicação mais consistente com a evidência
acumulada é a hipótese exploratória (H2): municípios **litorâneos e turísticos**
concentram taxas mais altas por 1.000 habitantes porque a população flutuante de
verão infla o numerador (ocorrências) sobre um denominador que mede só residentes.

O artigo completo, com todo o desenvolvimento metodológico (correlação →
autocorrelação espacial → OLS → regressão espacial global → GWR), está em
[`paper/relatorio_final_gwr.tex`](paper/relatorio_final_gwr.tex).

---

## 🗂️ Estrutura do repositório

```
territory/
├── run_espacial.R              # ponto de entrada: roda o pipeline completo
├── src/
│   ├── utils.R                 # normalização de nomes de município
│   └── espacial/                # pipeline espacial, em ordem (00 a 13)
│       ├── 00_config.R          # pacotes, caminhos, paleta, constantes
│       ├── 01_tabelao.R         # junta SSP-SP + IBGE renda/população → data/tabelao.csv
│       ├── 02_litoranea.R       # gera data/litoranea_turistica.csv (editável)
│       ├── 03_correlacao.R      # Pearson/Spearman, matriz e dispersões
│       ├── 04_malha.R           # baixa a malha de municípios (IBGE via geobr)
│       ├── 05_moran.R           # Moran's I global + LISA (localmoran_perm)
│       ├── 06_mapas.R           # mapas coropléticos das taxas
│       ├── 07_relatorio.R       # outputs/relatorio.md
│       ├── 08_xlsx.R            # outputs/analise_espacial.xlsx
│       ├── 09_geoda.R           # pacote data/geoda_sp.gpkg (+ shp) para o GeoDa
│       ├── 10_regressao.R       # OLS simples e múltiplo (renda + litoral)
│       ├── 11_regressao_espacial.R  # testes LM, spatial lag/error, GWR (~renda)
│       ├── 12_gwr_litoral.R     # GWR (~renda + litoral), contrafactual, resíduos
│       └── 13_gwr_geoda.R       # GWR enxuto (~renda) empacotado p/ o GeoDa
├── data/                        # tabelão, malha, pacotes prontos para o GeoDa
├── docs/                        # bases originais (.xlsx), guias do GeoDa, prints
├── outputs/                     # mapas, tabelas e relatório gerados pelo pipeline
├── paper/                       # artigo final (LaTeX, modelo IEEE)
└── slides/                      # apresentação da equipe (pptx / html / pdf)
```

---

## ⚙️ Como rodar

```bash
Rscript run_espacial.R
```

Pacotes usados: `sf`, `spdep`, `spatialreg`, `spgwr`, `geobr`, `dplyr`,
`ggplot2`, `corrplot`, `openxlsx`, entre outros (instalados automaticamente
pelo `00_config.R` se ausentes).

O pipeline:

1. Constrói e valida `data/tabelao.csv` (uma linha por município, chave
   `cod_ibge`) a partir das bases em `docs/`;
2. Gera `data/litoranea_turistica.csv` — classificação **editável** dos
   municípios litorâneos/turísticos (revise e reexecute se necessário);
3. Calcula correlações, autocorrelação espacial (Moran's I global e LISA) e
   gera os mapas coropléticos e de clusters;
4. Ajusta a progressão de modelos — OLS simples e múltiplo, spatial lag e
   spatial error, GWR (~renda e ~renda + litoral) com cenário contrafactual
   isolando o efeito litorâneo;
5. Exporta tudo para `outputs/` (mapas, csv, `analise_espacial.xlsx`,
   `relatorio.md`) e empacota os resultados para o GeoDa em `data/`.

---

## 📊 Fontes de dados

| Base | Fonte | Descrição |
|---|---|---|
| Dados Criminais SP 2025 | [SSP-SP](https://www.ssp.sp.gov.br/estatistica/dados-mensais) | Ocorrências de roubo, furto e lesão corporal por município |
| Renda média per capita | [IBGE — Censo 2022](https://cidades.ibge.gov.br/) | Renda média per capita, 645 municípios de SP |
| População (Tabela 4709) | IBGE, Censo 2022 | Denominador das taxas por 1.000 hab. |
| Litorâneo/turístico | Classificação do grupo | Dummy (1/0), 16 municípios da costa paulista por padrão |

---

## 🔍 Metodologia (resumo)

Vizinhança espacial: contiguidade **queen** de ordem 1, pesos
row-standardized (Ilhabela fica sem vizinhos — `zero.policy = TRUE`).

1. **Correlação e autocorrelação espacial** — Pearson/Spearman; Moran's I
   global e LISA (permutação condicional, 999 simulações).
2. **Regressão linear clássica (OLS)** — simples (`taxa ~ renda`) e múltipla
   (`taxa ~ renda + litoral`), com diagnóstico de resíduos.
3. **Regressão espacial global** — testes de Multiplicadores de Lagrange para
   escolher entre spatial lag e spatial error.
4. **Regressão Geograficamente Ponderada (GWR)** — banda adaptativa
   (k ≈ 10 vizinhos), coeficientes e R² locais, cenário contrafactual com o
   litoral zerado.

Resultado: o modelo final (GWR com renda e litoral) eleva o poder explicativo
de R² = 0,129 (OLS simples) para R² = 0,532, com o menor AIC entre os modelos
testados — ver o artigo completo para a discussão.

---

## 👥 Equipe

| Nome | GitHub |
|---|---|
| João Vitor Oliveira | [@joaooliveira23](https://github.com/joaooliveira23) |
| Julio Cesar Salvino | [@euusoujc](https://github.com/euusoujc) |
| Lucas Amorim | [@lucamorim](https://github.com/lucamorim) |

**Orientação:** Prof.ª Flávia da Fonseca Feitosa
