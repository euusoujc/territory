# Guia GeoDa — experimentos com os dados do projeto

Roteiro para reproduzir no **GeoDa** a análise exploratória e as medidas de
autocorrelação espacial do trabalho, usando os dados já preparados pelo
pipeline (`Rscript run_espacial.R`). Os valores de referência no final servem
para conferir se o experimento no GeoDa bateu com o que calculamos em R.

## Arquivo de entrada

Abra no GeoDa (**File > Open**) um destes dois — são idênticos:

| Arquivo | Observação |
|---|---|
| `data/geoda_sp.gpkg` | GeoPackage — recomendado |
| `data/geoda_sp_shp/geoda_sp.shp` | Shapefile — use se o gpkg não abrir na sua versão |

Variáveis disponíveis (645 municípios de SP):

| Coluna | Conteúdo |
|---|---|
| `cod_ibge` | Código IBGE do município (**use como ID na matriz de pesos**) |
| `municipio` | Nome |
| `pop` | População residente (Censo 2022) |
| `renda` | Renda média per capita, 14+ anos (Censo 2022, R$) |
| `n_roubo`, `n_furto`, `n_lesao` | Contagens de ocorrências (SSP-SP 2025) |
| `tx_roubo`, `tx_furto`, `tx_lesao` | **Taxas por 1.000 hab.** — as variáveis de interesse |
| `litoral` | Dummy: 1 = município litorâneo/turístico |

---

## Passo 1 — Análise exploratória (mapas e gráficos)

Crie um mapa temático de cada taxa (**Map > Quantile Map**, por exemplo, ou
botão direito sobre o mapa > **Change Current Map Type**) e espacialize por:

**Quantile (quintis, 5 classes)** — cada classe tem ~o mesmo número de
municípios (645/5 = 129). Bom para ver o *padrão espacial relativo*: onde se
concentram os 20% de municípios com maiores taxas. Limitação: os cortes
seguem a distribuição, não valores "redondos" — classes podem juntar valores
muito diferentes quando a distribuição é assimétrica (caso das nossas taxas).
*Equivale aos mapas coropléticos do relatório (`outputs/mapa_taxa_*.png`).*

**Standard Deviation** — classes em desvios-padrão acima/abaixo da média.
Mostra o quão *extremo* cada município é em relação à média estadual. Como as
taxas têm forte assimetria (poucos municípios com taxas altíssimas), espere
muitos municípios nas classes centrais e uma cauda longa acima de +2 dp —
litorâneos no furto, RMSP no roubo.

**Box Map (Hinge = 1.5)** — versão espacial do boxplot: classes pelos
quartis, com destaque para *outliers* (> Q3 + 1,5·IQR ou < Q1 − 1,5·IQR).
É o melhor mapa para responder "quem são os municípios atípicos?". Espere
como upper outliers: Mongaguá, Itanhaém, Ilha Comprida, Peruíbe (furto);
Itapecerica da Serra, São Paulo, Santo André (roubo); Balbinos (lesão).

Complemente com **Explore > Histogram** (assimetria da distribuição das
taxas), **Explore > Boxplot** (mesmos outliers do Box Map, sem o espaço) e
**Explore > Scatter Plot** (ex.: `tx_furto` × `renda` — repare no sinal
*positivo*, que contraria a hipótese renda→crime).

## Passo 2 — Matriz de ponderação espacial (vizinhança)

**Tools > Weights Manager > Create**

1. **Select ID Variable = `cod_ibge`** (no lugar do "id_snis" do exemplo da aula)
2. **Contiguity Weight > Queen Contiguity**
3. **Order of Contiguity = 1** → para reproduzir os valores do nosso pipeline
   (se o professor pedir ordem 2, marque também "Include Lower Orders";
   os índices mudam — vizinhança mais ampla tende a suavizar o I)
4. **Create** > salve como `sp_queen1.gal` > **Close**

O que ela é: uma matriz 645×645 onde w_ij = 1 se os municípios i e j
compartilham fronteira (critério *queen*: qualquer ponto em comum, como o
movimento da rainha no xadrez; *rook* exigiria aresta comum). O GeoDa
normaliza as linhas (row-standardized), então o "lag espacial" de uma
variável é a **média dos vizinhos**.

⚠️ O GeoDa vai avisar que existe **1 observação sem vizinhos: Ilhabela**
(é ilha, não toca nenhum polígono). Aceite e siga — ela fica fora do cômputo,
igual fizemos no R (`zero.policy = TRUE`). No histograma de conectividade
(Weights Manager > Histogram), a média fica em torno de 5–6 vizinhos.

## Passo 3 — Moran's I global + diagrama de espalhamento

**Space > Univariate Moran's I** > selecione a taxa > matriz `sp_queen1`.

O **diagrama de espalhamento de Moran** coloca a variável padronizada (z) no
eixo x e o seu lag espacial (média dos vizinhos, também padronizado) no eixo
y. **A inclinação da reta de regressão é o próprio Moran's I.** Os quadrantes:

- **Alto-Alto** (sup. direito): município acima da média com vizinhos acima da média
- **Baixo-Baixo** (inf. esquerdo): abaixo da média com vizinhos abaixo
- **Alto-Baixo / Baixo-Alto**: discordância local (potenciais outliers espaciais)

I > 0 = autocorrelação positiva (valores similares se aglomeram no espaço);
I ≈ 0 = padrão aleatório; I < 0 = padrão xadrez (dissimilaridade entre
vizinhos). Significância: botão direito no diagrama > **Randomization > 999
permutations** — o pseudo p-valor compara o I observado com a distribuição
gerada embaralhando os valores no mapa.

**Valores de referência (queen ordem 1, 999 permutações, calculados em R):**

| Variável | Moran's I | pseudo p | Leitura |
|---|---|---|---|
| `tx_roubo` | **0,832** | 0,001 | fortíssima — roubo é o crime mais "geográfico" |
| `tx_furto` | **0,422** | 0,001 | moderada |
| `tx_lesao` | **0,181** | 0,001 | fraca, mas significativa |

(Pequenas diferenças decimais entre GeoDa e R são normais — permutação é
aleatória e o tratamento de Ilhabela pode diferir.)

## Passo 4 — LISA (Moran local) e mapa de clusters

**Space > Univariate Local Moran's I** > taxa > `sp_queen1` >
marque **todas as janelas** (Significance Map, Cluster Map, Moran Scatter).

O LISA decompõe o I global: cada município recebe um I_i local que mede sua
contribuição para a autocorrelação. O **Cluster Map** pinta só os
significativos (p ≤ 0,05 por permutação):

- **Vermelho (High-High)**: núcleo de "hot spot" — taxa alta cercada de taxas altas
- **Azul (Low-Low)**: "cold spot"
- **Vermelho/azul claros (High-Low, Low-High)**: outliers espaciais — municípios
  destoando da vizinhança

O **Significance Map** mostra a força da evidência (p = 0,05 / 0,01 / 0,001).
No botão direito dá para aumentar as permutações (99999) e ajustar o nível de
significância — vale comentar no trabalho que o LISA é sensível a isso.

**Resultados esperados (para comparar com `outputs/mapa_lisa_*.png` e
`outputs/lisa_clusters.csv` — pipeline R com permutação condicional, 999 sim.):**

| Variável | High-High esperado | Leitura |
|---|---|---|
| `tx_roubo` | ~45 municípios: um único grande cluster RMSP + Baixada Santista (+ grande campo Low-Low no oeste) | crime metropolitano |
| `tx_furto` | ~36 municípios acompanhando o litoral (36% litorâneos/turísticos) | evidência da hipótese turística |
| `tx_lesao` | ~22 municípios em bolsões dispersos no interior | pouca estrutura espacial |

---

## Resultados obtidos no GeoDa (experimento do grupo, jul/2026)

Executado com a matriz queen ordem 1 (`cod_ibge`), 999 permutações. Tudo
conferiu com o gabarito do pipeline em R:

**Moran's I global:**

| Variável | I (GeoDa) | I (R) | z-value | pseudo p |
|---|---|---|---|---|
| `tx_roubo` | 0,832 | 0,832 | 35,6 | 0,001 |
| `tx_furto` | 0,426 | 0,422 | 17,5 | 0,001 |
| `tx_lesao` | 0,183 | 0,181 | 7,5  | 0,001 |

(As diferenças na 3ª casa vêm do tratamento da Ilhabela: o GeoDa remove a
observação isolada; o R a mantém na base.)

**Clusters LISA (p ≤ 0,05):**

| Variável | High-High (GeoDa / R) | Low-Low (GeoDa / R) | Padrão |
|---|---|---|---|
| `tx_roubo` | 50 / 45 | 148 / 93 | AA: RMSP + Baixada; LL: oeste/noroeste |
| `tx_furto` | 49 / 36 | 67 / 45 | AA: litoral inteiro; LL: oeste e centro-sul |
| `tx_lesao` | 36 / 22 | 53 / 28 | bolsões pequenos e fragmentados |

**Nota metodológica (vale citar no trabalho):** os clusters Alto-Alto — que
sustentam as hipóteses — são robustos: aparecem nos mesmos lugares no GeoDa e
no R. Já a *extensão* dos clusters (especialmente Baixo-Baixo) depende do
procedimento de inferência local: a aproximação analítica clássica de
`spdep::localmoran()` quase não detecta cold spots em variáveis assimétricas
cheias de zeros, enquanto a permutação condicional (usada pelo GeoDa e por
`spdep::localmoran_perm()`, que o pipeline adota) os revela. Mesmo entre duas
implementações de permutação os totais variam um pouco (sorteios e critérios
de p-valor diferentes). Conclusão: leia o LISA pela *geografia* dos clusters,
não pela contagem exata de municípios.

## Dica final para o texto

Ao interpretar, conecte os três níveis: o **mapa temático** mostra *onde*
estão as taxas altas; o **Moran global** resume *o quanto* o padrão é
espacialmente estruturado; o **LISA** localiza *quais* aglomerados sustentam
esse padrão. No nosso caso, a história é consistente: roubo tem geografia
metropolitana fortíssima, furto tem geografia litorânea (população flutuante
turística infla o numerador das taxas), e lesão corporal é o crime menos
estruturado no espaço — compare sempre com a limitação de que o denominador
é a população *residente*.
