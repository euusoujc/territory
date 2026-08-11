# Guia completo do projeto — Furto, Renda e Território

Base de conhecimento única e completa do trabalho: toda a informação
necessária para apresentar, defender e responder perguntas sobre o projeto,
num só lugar. Este guia não substitui o artigo (`paper/relatorio_final_gwr.tex`)
— ele é a versão "para consulta rápida e defesa oral" do mesmo conteúdo,
organizada por tema em vez de estrutura de artigo acadêmico, com todos os
números à mão. Onde o artigo tem uma frase, aqui tem o número por trás dela.

Uso: leia por completo antes de apresentar, e depois use como referência
durante ensaios ou para responder perguntas fora do roteiro da apresentação.
O guia irmão, [`guia_apresentacao.md`](guia_apresentacao.md), aponta de volta
para as seções daqui em cada slide.

---

## 1. Contexto e equipe

- **Disciplina:** Análise de Dados para Planejamento Territorial — UFABC.
- **Equipe:** João Vitor Oliveira, Julio Cesar Salvino, Lucas Amorim.
- **Orientação:** Prof.ª Flávia da Fonseca Feitosa.
- **Tema:** cruzar criminalidade patrimonial (roubo, furto, lesão corporal)
  com renda média nos 645 municípios de São Paulo, usando ferramental de
  econometria espacial progressivo — de correlação simples a regressão
  geograficamente ponderada (GWR).
- **Onde está tudo:** `paper/relatorio_final_gwr.tex` (+ `.pdf`) é o artigo
  final; `slides/apresentacao_final.pptx` (+ `.pdf`) é a apresentação;
  `src/espacial/00..13_*.R` é o pipeline que gera todos os números e figuras
  citados aqui (`Rscript run_espacial.R` reproduz tudo do zero).

---

## 2. A pergunta e as duas hipóteses

**H1 (hipótese inicial, senso comum):** "Acontecem mais crimes nas cidades
mais pobres?" — cidades mais pobres registrariam mais crimes patrimoniais.

**O que os dados mostraram:** já na análise exploratória, a taxa de furto
concentra visualmente na macrometrópole e no litoral — não no interior mais
pobre. A correlação confirma: é **positiva**, não negativa. H1 não se
sustenta em nenhum dos modelos testados, do mais simples ao mais complexo.

**H2 (hipótese exploratória, nascida dos dados):** municípios
litorâneos/turísticos concentram taxas mais altas de criminalidade
patrimonial — não porque sejam mais pobres, mas porque a população flutuante
de verão infla o numerador da taxa (ocorrências) sobre um denominador que
mede apenas a população residente (Censo IBGE). H2 foi formulada *durante* a
análise exploratória, não era hipótese de partida — isso é importante de
comunicar: o trabalho é honesto sobre de onde vieram as hipóteses.

Toda a "escada" metodológica do trabalho (correlação → Moran/LISA → OLS →
regressão espacial global → GWR) existe para acumular evidência a favor de
H2 e contra H1, camada por camada.

---

## 3. Dados: fontes, variáveis, junção

| Variável | Fonte | Descrição |
|---|---|---|
| Taxa de roubo (art. 157) | SSP-SP, 2025 | Ocorrências / 1.000 hab. |
| Taxa de furto (art. 155) | SSP-SP, 2025 | Ocorrências / 1.000 hab. — variável dependente principal |
| Taxa de lesão corporal (art. 129) | SSP-SP, 2025 | Ocorrências / 1.000 hab. |
| Renda média per capita | IBGE, Censo 2022 | R$ por habitante |
| População | IBGE, Tabela 4709 | Denominador das taxas |
| Litorâneo/turístico | Classificação do grupo | Dummy (1/0), 16 municípios da costa paulista (padrão do pipeline; editável em `data/litoranea_turistica.csv`) |

**Unidade de análise:** os 645 municípios do estado de São Paulo.

**Por que taxa e não contagem bruta:** a contagem acompanha o tamanho da
população — qualquer mapa de contagem destaca a capital e as cidades grandes
independentemente do fenômeno investigado. A taxa por 1.000 hab. permite
comparar municípios de portes muito diferentes.

**Chave de junção — o detalhe técnico mais citável do projeto:** código IBGE
de 7 dígitos, **nunca o nome do município**. A base da SSP abrevia nomes
(ex. "S BARBARA D OESTE"), o que exige uma resolução em cascata:
correspondência exata → expansão de abreviações → remoção de preposições →
distância de edição ≤ 1. Implementado em `src/espacial/01_tabelao.R`.
Validação do tabelão final: **645 linhas × 10 colunas, zero erros, zero
avisos** (`outputs/validacao_tabelao.txt`).

**Por que o furto foi escolhido como variável dependente principal** (entre
os três crimes disponíveis) — três evidências convergentes, nesta ordem na
apresentação:
1. **Mapas municipais:** furto é o único dos três cujo padrão espacial
   acompanha nitidamente o litoral inteiro (roubo concentra na
   macrometrópole; lesão corporal não tem padrão espacial claro).
2. **Outliers por crime:** no furto, os outliers extremos da dispersão
   taxa×renda são quase todos litorâneos (Mongaguá e outros municípios da
   costa muito acima da nuvem geral); no roubo, o outlier mais extremo é
   não-litorâneo; na lesão corporal, idem, com os litorâneos perdidos no
   meio da distribuição.
3. **Correlação:** roubo e furto correlacionam positivamente com a renda
   (contrariando H1), mas só o furto tem essa relação de outliers batendo
   com a hipótese litorânea — por isso ele, e não roubo, foi escolhido.

---

## 4. Metodologia completa

*(Removida da apresentação por orientação da Prof.ª Flávia — "não é tão
necessária" ali — mas completa no artigo em LaTeX e aqui, para responder
perguntas técnicas.)*

**Vizinhança espacial:** contiguidade **queen** de ordem 1 (dois municípios
são vizinhos se compartilham qualquer trecho de fronteira), pesos
normalizados por linha (row-standardization). Matriz com 645 observações,
mínimo de 0 e máximo de 22 vizinhos, média de 5,50. **Ilhabela**, por ser
arquipélago, fica sem vizinhos (`zero.policy = TRUE` no `spdep`).

**Quatro etapas progressivas:**

1. **Correlação e autocorrelação espacial** — Pearson e Spearman entre as
   taxas de crime e a renda; índice global de Moran e sua decomposição local
   (LISA), com significância avaliada por permutação condicional (999
   permutações) — mais robusta que a versão analítica para variáveis
   assimétricas com muitos zeros (`spdep::localmoran_perm`).
2. **Regressão linear clássica (OLS)** — modelo simples (taxa ~ renda) e
   múltiplo (taxa ~ renda + litoral), com diagnóstico de resíduos
   (Shapiro-Wilk, `ncvTest`, distância de Cook).
3. **Regressão espacial global** — testes de Multiplicadores de Lagrange
   (LM) para escolher entre *spatial lag* (ρ) e *spatial error* (λ), ambos
   por máxima verossimilhança.
4. **Regressão Geograficamente Ponderada (GWR)** — ajusta uma regressão
   local para cada município, com pesos decaindo por um núcleo gaussiano
   $w_{ij} = \exp(-\tfrac{1}{2}(d_{ij}/h)^2)$ em função da distância
   geográfica $d_{ij}$, onde a banda $h$ é adaptativa (definida pelo
   k-ésimo vizinho mais próximo, k ≈ 10, escolhido por validação cruzada).

---

## 5. Resultados, passo a passo, com todos os números

### 5.1 Análise exploratória

- Mapa da taxa de furto: concentração visual na macrometrópole e no litoral.
- **Box map** (não reproduzido na apresentação, citado no artigo): **17
  outliers superiores** na taxa de furto (concentrados no litoral e na
  capital) contra **60 outliers superiores** na taxa de roubo (quase todos
  contíguos na RMSP e na Baixada Santista). Confirmado visualmente contra o
  GeoDa (`docs/geoda_prints/mapa_boxmap_tx_furto.jpeg` e
  `mapa_boxmap_tx_roubo.jpeg`).
- **Top 5 municípios por taxa** (`outputs/top5_por_crime.csv`):
  - Roubo: Itapecerica da Serra (10,12), São Paulo (9,47), Santo André
    (8,16), Embu das Artes (7,52), São Vicente (7,32, litorâneo).
  - Furto: Mongaguá (34,17, litorâneo), Itanhaém (27,94, litorâneo), Ilha
    Comprida (26,46, litorâneo), São Paulo (25,20), Peruíbe (25,06,
    litorâneo) — **4 dos 5 top municípios de furto são litorâneos**.
  - Lesão corporal: Balbinos (14,15), Santo Expedito (10,33), Rifaina
    (10,13), Guarantã (10,11), Pontalinda (9,69) — nenhum litorâneo,
    municípios pequenos do interior.

### 5.2 Correlação (Tabela completa)

| Par | Pearson | Spearman |
|---|---|---|
| Roubo × Renda | 0,302 | 0,389 |
| Furto × Renda | 0,359 | 0,380 |
| Lesão corporal × Renda | −0,190 | −0,166 |
| Roubo × Furto | 0,544 | 0,567 |
| Roubo × Lesão corporal | −0,131 | −0,177 |
| Furto × Lesão corporal | 0,116 | 0,084 |

Roubo e furto correlacionam positivamente com a renda — o oposto do que H1
previa. Só a lesão corporal correlaciona negativamente, e fraco.

### 5.3 Autocorrelação espacial: Moran global e LISA

| Variável | Moran's I | p (permutação) | Leitura |
|---|---|---|---|
| Taxa de roubo | 0,832 | 0,001 | forte |
| Taxa de furto | 0,422 | 0,001 | moderada |
| Taxa de lesão corporal | 0,181 | 0,001 | fraca |

Todas significativas a p = 0,001 (999 permutações): o crime não está
distribuído ao acaso.

**LISA — clusters por crime** (`outputs/lisa_clusters.csv`, versão R,
`spdep::localmoran_perm`):

| Crime | Alto-Alto | Baixo-Baixo | Alto-Baixo | Baixo-Alto | Não signif. |
|---|---|---|---|---|---|
| Roubo | 45 | 93 | 1 | 2 | 504 |
| Furto | 36 | 45 | 7 | 6 | 551 |
| Lesão corporal | 22 | 28 | 5 | 6 | 584 |

Para o furto: 36 municípios no cluster Alto-Alto acompanham o litoral de
Ubatuba a Cananéia; **36% deles (13/36) já são litorâneos/turísticos** —
primeira evidência quantitativa a favor de H2, antes de qualquer regressão.

> ⚠️ **Nota importante — R × GeoDa:** os mesmos dados processados no GeoDa
> (permutação condicional independente) indicam **49 municípios Alto-Alto e
> 67 Baixo-Baixo** para o furto — a mesma geografia de clusters, com
> contagens um pouco maiores. O artigo e a apresentação reportam os números
> do R (`spdep::localmoran_perm`), a mesma implementação usada no Moran's I
> global, para manter os dois números consistentes entre si. Se a banca
> perguntar por que o número "parece diferente" do que viram em algum print
> do GeoDa, essa é a explicação — ver `docs/guia_geoda.md` para a
> comparação completa R × GeoDa, crime a crime.

### 5.4 Regressão linear clássica (OLS)

**Modelo simples:**
$$\text{taxa de furto} = 0{,}971 + 0{,}00247 \cdot \text{renda}, \quad R^2 = 0{,}129$$
Coeficiente positivo e significativo (p < 0,001): confirma que H1 não se
sustenta.

**Modelo múltiplo (com litoral):**
$$\text{taxa de furto} = 1{,}036 + 0{,}00233 \cdot \text{renda} + 10{,}969 \cdot \text{litoral}, \quad R^2 = 0{,}357 \ (R^2_{\text{ajustado}} = 0{,}355)$$
O coeficiente da renda pouco muda em relação ao modelo simples (VIF = 1, sem
multicolinearidade). O termo litoral (10,969) é a distância vertical entre
as retas dos dois grupos: um município litorâneo registra, em média, quase
**11 furtos a mais por 1.000 habitantes** do que um município comum de
mesma renda — efeito equivalente a uma diferença de renda de **cerca de
R$4.700**.

**Distância de Cook:** 29 municípios influentes (Cook > 4/n); **8 deles são
litorâneos — 50% dos 16 municípios do litoral entram como outlier geral da
reta**. Ao excluir os 29 influentes, a inclinação da renda sobe de 0,00247
para 0,00288 e o R² sobe de 0,13 para 0,19 — ou seja, o efeito positivo não
é artefato de poucos pontos extremos, e se fortalece sem eles. Municípios
mais influentes: Mongaguá e outros litorâneos ficam muito acima da reta;
Santana de Parnaíba (renda alta, furto baixo) puxa a reta para baixo pela
direita.

**Diagnósticos:** Shapiro-Wilk (normalidade) p < 0,001; `ncvTest`
(homocedasticidade) p < 0,001 — ambos rejeitam as premissas clássicas do
OLS, esperado dada a assimetria das taxas de crime, e motivam avançar para
modelos espaciais.

### 5.5 Regressão espacial global

O Moran's I dos resíduos do modelo clássico é **0,38** (p < 0,001): a
autocorrelação espacial não explicada é elevada, violando a premissa de
independência do OLS.

**Testes de Multiplicadores de Lagrange:**

| Teste | Estatística | p-valor |
|---|---|---|
| LM (lag) | 217,4 | < 0,001 |
| LM (error) | 238,9 | < 0,001 |
| Robust LM (lag) | 1,23 | 0,267 |
| Robust LM (error) | 22,8 | < 0,001 |

A versão robusta indica o modelo **spatial error** como mais adequado
(Robust LM error significativo, Robust LM lag não significativo).

| Modelo | Parâmetro espacial | R² | AIC |
|---|---|---|---|
| OLS clássico | — | 0,129 | 3389,6 |
| Spatial Lag (SAR) | ρ = 0,519 | 0,355 | 3241,5 |
| Spatial Error (CAR) | λ = 0,588 | 0,392 | 3220,6 |
| GWR (renda) | bw adapt. ≈ 10 vizinhos | 0,458 | 3137,0 |

O modelo spatial error supõe que a dependência espacial está no **erro**,
refletindo uma variável omitida e espacialmente agrupada — coerente com a
hipótese de que é a condição litorânea, e não um efeito de contágio entre
vizinhos, que gera o padrão espacial. Após o ajuste, o Moran's I dos
resíduos cai de 0,38 para **−0,03**, praticamente eliminando a
autocorrelação residual.

### 5.6 GWR (renda)

Com banda adaptativa (k ≈ 10 vizinhos), o R² quase-global sobe para
**0,458**, superando os modelos globais. O coeficiente local da renda varia
de **−0,00216 a +0,00562** pelo estado, positivo na maior parte e invertido
num bolsão do noroeste; a estatística t é significativa (|t| > 1,96) em
**72% dos municípios**. O R² local varia de **0,05 a 0,64**: a renda
explica bem a taxa de furto no centro-oeste do estado e mal no litoral e na
Região Metropolitana — justamente onde a população flutuante turística
deveria dominar o fenômeno, segundo H2.

### 5.7 GWR + litoral, contrafactual e mecanismo

Ajustando GWR com renda **e** litoral, o R² quase-global sobe para **0,532**
e o AIC cai para **3027,4** — o melhor entre todos os modelos testados. Os
coeficientes locais mostram que o efeito litorâneo varia de **0 a 22**
furtos/1.000 hab. conforme o município.

**Cenário contrafactual:** mantendo os coeficientes locais do GWR, zeramos a
variável litoral e recalculamos a predição. A diferença entre a predição
real e a contrafactual — de até **12 furtos/1.000 hab.** — concentra-se
inteiramente na faixa costeira.

**Tratamento dos resíduos (o mecanismo, em números):** sem a variável
litoral, os municípios litorâneos têm resíduo médio de **+10,68**
furtos/1.000 hab. contra **−0,27** dos demais (n = 16 litorâneos, n = 629
demais); ao incluir a variável, os dois grupos centram em **zero**. A
correlação entre o resíduo (sem litoral) e a dummy litorânea é **0,51** e
cai para **0,00** com a variável incluída.

**Leitura por regime espacial:** ajustando regressões separadas por grupo —
no interior, a taxa de furto cresce com a renda (R² = 0,19); no litoral, a
reta é praticamente plana, num patamar bem mais alto (R² = 0,008) — ou seja,
dentro do próprio grupo litorâneo, a renda não explica a variação do furto.

**O mecanismo numérico, em uma frase:** o numerador (ocorrências) infla com
o fluxo de turistas no verão; o denominador (população) conta só a
população residente medida pelo Censo IBGE. A taxa por 1.000 hab.
superestima o risco real para quem mora lá — sem a variável litoral, o
modelo sempre subestima a taxa observada nos municípios turísticos.

### 5.8 Exemplo concreto: São Paulo × Mongaguá

Extraído diretamente de `data/geoda_gwr_furto.gpkg` (GWR ~ renda, modelo
enxuto de um crime só) — mostra a não-estacionariedade do coeficiente da
renda em dois municípios reais:

| Métrica | São Paulo | Mongaguá |
|---|---|---|
| Renda | R$ 4.547,62 | R$ 2.138,21 |
| Taxa de furto observada | 25,20 | 34,17 |
| β renda (local) | 0,00156 | 0,00019 |
| t (renda) | 3,28 (significativo) | 0,46 (não significativo) |
| R² local | 0,31 | 0,18 |
| Furto previsto (GWR) | 13,7 | 13,2 |
| Resíduo | +11,5 | +21,0 |

Em São Paulo e Mongaguá, a previsão do modelo é parecida (~13 a 14) — mas só
em São Paulo o coeficiente da renda é estatisticamente confiável. Em
Mongaguá, t = 0,46 diz que a renda local não explica quase nada do crime; o
resíduo de +21 é, segundo a hipótese do trabalho, reflexo quase puro da
população turística flutuante que o modelo não capta. **Não é só "quanto"
de renda existe, é "onde" ela está alocada** — a frase que resume o valor
do GWR sobre um coeficiente único e global.

### 5.9 Comparação final de todos os modelos

| Modelo | Sem litoral (R²) | Com litoral (R²) | Δ |
|---|---|---|---|
| OLS | 0,129 | 0,357 | +0,228 |
| Spatial Error | 0,392 | 0,444 | +0,052 |
| GWR | 0,458 | **0,532** | +0,074 |

A condição litorânea melhora o ajuste em todos os três casos, mas o ganho é
desigual: maior no modelo mais simples (+0,228 no OLS) e menor nos modelos
espaciais (+0,052 no spatial error; +0,074 no GWR) — sinal de que os
modelos espaciais já capturavam parte do padrão litorâneo implicitamente,
antes mesmo de a variável entrar explicitamente. **O melhor modelo entre
todos os testados é o GWR com renda e litoral, R² = 0,532, menor AIC entre
todos (3027,4).**

---

## 6. Conclusão completa

A hipótese original (H1) — de que municípios mais pobres registram mais
crimes patrimoniais — **não se sustenta** nos dados de São Paulo: a relação
entre renda e taxa de furto é positiva, não negativa, tanto na correlação
simples quanto em todos os modelos de regressão testados.

A explicação mais consistente com a evidência acumulada é a hipótese
exploratória **H2**: municípios litorâneos e turísticos concentram taxas
elevadas de criminalidade patrimonial porque sua população flutuante de
verão infla o numerador da taxa sobre um denominador que mede apenas
residentes.

A progressão metodológica revela **três camadas distintas** do fenômeno:

1. A renda sozinha é insuficiente e deixa estrutura espacial não explicada
   nos resíduos (Moran's I = 0,38 nos resíduos do OLS).
2. Essa estrutura é majoritariamente absorvida por uma única variável
   omitida e espacialmente agrupada, a condição litorânea (Moran's I dos
   resíduos cai a −0,03 no spatial error).
3. Mesmo controlando por essa variável, a própria relação renda–furto **não
   é estacionária no espaço**, sendo razoavelmente forte no interior e
   quase nula no litoral, onde a dinâmica turística domina (GWR).

O modelo final (GWR com renda e litoral, R² = 0,532) combina essas duas
camadas e obtém o melhor ajuste entre todos os testados.

**Direção futura:** a inclusão de uma medida direta de fluxo turístico
(hospedagem, pedágios, dados de telefonia) permitiria testar diretamente o
mecanismo proposto, hoje capturado apenas indiretamente por uma variável
dummy.

---

## 7. Limitações e ressalvas (para perguntas difíceis)

- **Correlação não implica causalidade.** Toda a cadeia de evidência
  (correlação → LISA → contrafactual → resíduos → exemplo Mongaguá) é
  convergente e forte, mas a variável litorânea/turística é uma **proxy
  indireta** (dummy 1/0) do fenômeno turístico real — não uma medida direta
  de fluxo de visitantes.
- **A classificação litorânea/turística é do próprio grupo**, não uma
  variável oficial do IBGE ou da SSP — 16 municípios da costa paulista por
  padrão, documentada e editável em `data/litoranea_turistica.csv`.
- **O Moran's I e o LISA são sensíveis à matriz de vizinhança** escolhida
  (aqui, contiguidade queen de ordem 1). Municípios-ilha (Ilhabela) ficam
  sem vizinhos e não recebem classificação LISA significativa.
- **Contagens de cluster LISA variam um pouco entre implementações** (R vs.
  GeoDa) mesmo mantendo a mesma geografia de clusters — ver nota na seção
  5.3 acima e `docs/guia_geoda.md`.
- **Malha municipal:** os números de referência deste guia vêm da malha
  municipal obtida via `geobr` (cache em `data/malha_municipios_sp.gpkg`).
  Em ambientes sem acesso normal ao backend do `geobr`, o pipeline cai para
  um fallback via API de malhas do IBGE, que pode gerar pequenas variações
  nos números que dependem da matriz de vizinhança (Moran's I, LISA,
  spatial lag/error) — os resultados de OLS e GWR são robustos a isso. Ao
  reproduzir o pipeline, prefira sempre rodar num ambiente com acesso
  normal à internet para obter os números de referência exatos deste guia.

---

## 8. Onde encontrar cada coisa no repositório

| O que você precisa | Onde está |
|---|---|
| Artigo completo (LaTeX + PDF) | `paper/relatorio_final_gwr.tex`, `.pdf` |
| Apresentação (pptx + PDF) | `slides/apresentacao_final.pptx`, `.pdf` |
| Script que gera a apresentação | `slides/build_apresentacao.py` |
| Guia de como apresentar (por slide) | `docs/guia_apresentacao.md` |
| Este guia (base de conhecimento completa) | `docs/guia_projeto_completo.md` |
| Roteiro do GeoDa (comparação R × GeoDa) | `docs/guia_geoda.md` |
| Roteiro de regressão espacial no GeoDa | `docs/guia_regressao_espacial.md` |
| Roteiro do GWR no GeoDa | `docs/guia_gwr_geoda.md` |
| Pipeline completo (reproduz tudo) | `run_espacial.R` → `src/espacial/00..13_*.R` |
| Todas as figuras e tabelas geradas | `outputs/` |
| Base consolidada (1 linha/município) | `data/tabelao.csv` |
| Classificação litorânea/turística (editável) | `data/litoranea_turistica.csv` |
| Dados prontos para o GeoDa | `data/geoda_sp.gpkg`, `data/geoda_gwr_furto.gpkg` |

---

## 9. Referências bibliográficas

1. P. A. P. Moran, "Notes on continuous stochastic phenomena," *Biometrika*,
   vol. 37, no. 1/2, pp. 17–23, 1950.
2. L. Anselin, "Local indicators of spatial association—LISA," *Geographical
   Analysis*, vol. 27, no. 2, pp. 93–115, 1995.
3. W. R. Tobler, "A computer movie simulating urban growth in the Detroit
   region," *Economic Geography*, vol. 46, sup. 1, pp. 234–240, 1970.
4. A. S. Fotheringham, C. Brunsdon, and M. Charlton, *Geographically
   Weighted Regression: The Analysis of Spatially Varying Relationships*.
   Chichester: John Wiley & Sons, 2002.
5. Instituto Brasileiro de Geografia e Estatística (IBGE), *Censo
   Demográfico 2022*. https://censo2022.ibge.gov.br
6. Secretaria de Segurança Pública do Estado de São Paulo (SSP-SP), *Dados
   Estatísticos do Estado de São Paulo, 2025*. https://www.ssp.sp.gov.br
