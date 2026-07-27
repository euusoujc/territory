# Guia GeoDa — regressão clássica e espacial

Roteiro para a atividade de regressão espacial no GeoDa, em duas partes:
(1) a prática com o arquivo `agua_rede_sf.gpkg` (fornecido) e (2) a análise com
os dados do trabalho (`data/geoda_sp.gpkg`). Os valores de referência ao final
de cada parte servem para conferir se o experimento no GeoDa bateu com o
gabarito calculado em R (`Rscript run_espacial.R`, etapa `11_regressao_espacial.R`).

## Sequência geral (vale para os dois arquivos)

1. **Abrir** o `.gpkg`: File > New > Input file > GeoPackage.
2. **Matriz de ponderação**: Tools > Weights Manager > Create > ID Variable >
   Queen contiguity, ordem 1 > Create > salvar `.gal`.
3. **Regressão clássica** (sempre primeiro): Regression > variáveis (Dependent,
   Covariate) > marcar o Weights File > Model = Classic > marcar Pred. Val and
   Res. > Run. Ler R², coeficientes e, no bloco DIAGNOSTICS FOR SPATIAL
   DEPENDENCE, o **Moran's I dos resíduos** e os **testes LM**.
4. Se o Moran dos resíduos for significativo, os **testes de Multiplicadores de
   Lagrange** indicam qual modelo espacial usar (regra na parte 1).
5. **Spatial Lag** e **Spatial Error**: mesmo diálogo, trocando o Model. Salvar
   os resíduos (Save to Table) para mapeá-los.

---

## Parte 1 — Prática com `agua_rede_sf.gpkg`

- **ID Variable**: `id_snis` · **Dependent**: `CONSUMO1` (consumo de água per
  capita) · **Covariate**: `RENDAPITA` (renda per capita).
- Modelo: consumo de água explicado pela renda.

Valores de referência do tutorial (GeoDa, queen ordem 1):

| Modelo | R² | Parâmetro espacial | Leitura |
|---|---|---|---|
| Clássico (OLS) | 0,276 | — | renda explica ~28% do consumo; Moran dos resíduos = 0,244 (p = 0,000), há dependência espacial |
| Spatial Lag | 0,387 | rho = 0,534 | o consumo dos vizinhos influencia o do município |
| Spatial Error | 0,392 | lambda = 0,447 | efeitos espaciais como ruído de variáveis não medidas |

**Como interpretar os três modelos**

- **Clássico**: ponto de partida obrigatório. O coeficiente da renda é positivo e
  significativo, mas o R² é baixo e, sobretudo, o **Moran's I dos resíduos é
  significativo**: sobra estrutura espacial não modelada, então o OLS viola a
  hipótese de independência das observações e seus erros-padrão não são
  confiáveis.
- **Spatial Lag** (Y = ρWY + Xβ + ε): assume que o valor de um município é
  afetado pelo valor da variável resposta nos vizinhos (difusão). O rho positivo
  e significativo confirma essa dependência.
- **Spatial Error** (Y = Xβ + ε, ε = λWε + ξ): assume que a dependência está no
  **erro**, ou seja, variáveis não medidas e espacialmente correlacionadas. No
  exemplo da água, é o mais adequado (maior R², melhor ajuste), o que os testes
  LM já antecipavam.

---

## Parte 2 — Dados do trabalho (`data/geoda_sp.gpkg`)

- **ID Variable**: `cod_ibge` · **Dependent**: `tx_furto` (furtos por 1.000
  hab.) · **Covariate**: `renda` (renda média per capita).
- Modelo: taxa de furto explicada pela renda. Usamos só a renda (uma covariável
  contínua), como no exemplo da água; o efeito litorâneo fica de fora de
  propósito, e é ele que reaparece como autocorrelação nos resíduos.

### 1. Regressão clássica e Moran dos resíduos

Rode o modelo Classic, salve os resíduos (OLS_RESIDU) e mapeie-os. Depois
calcule o Moran global sobre os resíduos (Space > Univariate Moran's I sobre
OLS_RESIDU, ou leia direto no bloco de diagnóstico da regressão).

| | valor | leitura |
|---|---|---|
| R² | 0,129 | a renda sozinha explica ~13% da variação da taxa de furto |
| coef. renda | 0,00247 | positivo e significativo (p < 0,001) |
| **Moran's I dos resíduos** | **0,38** (p < 0,001) | **forte autocorrelação espacial**: o OLS é inadequado |

O mapa dos resíduos mostra um bloco de resíduos altos positivos no litoral: onde
o modelo mais subestima a taxa de furto, justamente porque a condição litorânea
(população flutuante) não está no modelo.

### 2. Testes de Multiplicadores de Lagrange (escolha do modelo)

No bloco DIAGNOSTICS FOR SPATIAL DEPENDENCE da regressão clássica:

| Teste | valor | p |
|---|---|---|
| LM (lag) | 217,4 | < 0,001 |
| LM (error) | 238,9 | < 0,001 |
| Robust LM (lag) | 1,23 | 0,267 |
| **Robust LM (error)** | **22,8** | **< 0,001** |

Regra de decisão: quando os dois LM simples são significativos, olham-se os
**robustos**. Aqui o **Robust LM (error) é significativo e o Robust LM (lag)
não** → o modelo indicado é o **Spatial Error**.

### 3. Modelos espaciais globais

| Modelo | R² (pseudo) | Parâmetro | AIC |
|---|---|---|---|
| Spatial Lag (SAR) | 0,310 | rho = 0,519 | 3241,5 |
| Spatial Error (CAR) | 0,332 | lambda = 0,588 | 3220,6 |

Os dois melhoram muito o ajuste em relação ao OLS (R² sobe de 0,13). O **Spatial
Error tem o menor AIC**, confirmando o que os testes LM indicaram: a dependência
está no erro (variáveis omitidas espacialmente correlacionadas, como a condição
litorânea/turística), e não numa difusão da própria taxa de furto entre vizinhos.

### 4. Mapa dos resíduos do modelo espacial

Salve e mapeie os resíduos do Spatial Error. O Moran's I cai de **0,38 (OLS)**
para **−0,03**: a autocorrelação foi praticamente eliminada, sinal de que o
modelo capturou a estrutura espacial que faltava.

### 5. GWR (regressão geograficamente ponderada)

O GWR ajusta uma regressão em cada município, ponderando os demais pela
distância, e deixa o coeficiente da renda variar no espaço (efeito não
estacionário). Referências (bandwidth adaptativo ≈ 10 vizinhos):

- **R² quase-global = 0,46** (melhor que os globais);
- coeficiente local da renda varia de **−0,002 a +0,006**: na maior parte do
  estado é positivo, mas chega a se inverter num bolsão do nordeste;
- R² local vai de **0,05 a 0,64**: a renda explica melhor a taxa de furto no
  centro-oeste e pior no litoral e na Região Metropolitana, onde outros fatores
  (turismo, dinâmica urbana) dominam.

> No GeoDa, o GWR está em Regression, ou pode ser feito em R (`spgwr`), como no
> gabarito. Mapeie o coeficiente local da renda e o R² local.

### 6. Comparação dos modelos

| Modelo | Tipo | R² | AIC | Moran dos resíduos |
|---|---|---|---|---|
| OLS clássico | não espacial | 0,129 | 3389,6 | 0,38 |
| Spatial Lag | espacial global | 0,310 | 3241,5 | ~0 |
| Spatial Error | espacial global | 0,332 | 3220,6 | −0,03 |
| GWR | espacial local | 0,458 | 3137,0 | — |

O **AIC diminui e o R² aumenta** a cada passo: o **GWR tem o melhor ajuste**,
seguido do Spatial Error, do Spatial Lag e, por último, do OLS. Cada modelo
revela algo diferente: o clássico mostra que a renda sozinha é insuficiente e que
há estrutura espacial ignorada; os globais capturam essa estrutura num único
parâmetro (e o error confirma que a dependência vem de variáveis omitidas); o GWR
mostra que a própria relação renda–furto **não é a mesma em todo o estado**,
sendo fraca no litoral, onde a taxa de furto é governada pela população flutuante
e não pela renda.
