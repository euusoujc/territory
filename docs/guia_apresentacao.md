# Guia de apresentação — Furto, Renda e Território

Roteiro de apoio para apresentar `slides/apresentacao_final.pptx` (ou o PDF
equivalente). Cobre os 13 slides, o que falar em cada um, o dado que merece
ênfase, e perguntas prováveis da banca/turma com respostas prontas. Tempo
alvo: **até 10 min** de fala (± 45s por slide) — sem slide de metodologia
isolado (a orientação avaliou que não é necessário detalhar esse passo a
passo na apresentação; ele continua completo no artigo em LaTeX).

## Como usar este guia

- Cada bloco abaixo corresponde a um slide (numeração igual à do rodapé do
  slide). "Diga" é a fala sugerida, não um script para decorar. "Não esqueça"
  é o número/detalhe que não pode faltar.
- Um só apresentador pode conduzir tudo, ou dividir por seção (sugestão: uma
  pessoa por seção — Hipótese, Dados, Desenvolvimento, Conclusão).
- Ritmo: os slides 4, 5, 8 e 11 carregam o argumento central (por que furto,
  correlação, progressão de modelos, exemplo concreto) — não acelere neles.
  Os slides 6, 7, 9, 10 podem ser mais rápidos, uma frase de leitura por
  figura.

---

## Bloco 1 — Hipótese e motivação (slides 1–2)

**Slide 1 — Título.** Diga quem são vocês, a disciplina e a orientação em
uma frase; sirva de ponte direta para o slide 2 com a pergunta de pesquisa.

**Slide 2 — Motivação: a pergunta que originou o trabalho.**
Diga: essa é a hipótese de senso comum (H1) que motivou o trabalho — cidades
mais pobres registram mais crimes patrimoniais — testada com dados reais dos
645 municípios de SP (SSP-SP para ocorrências, IBGE para renda).
Não esqueça: a observação inicial no mapa — a taxa de furto já concentra
visualmente na macrometrópole e no litoral, não no interior mais pobre. É o
gancho que puxa o resto da apresentação.

---

## Bloco 2 — Dados e variáveis (slides 3–5)

**Slide 3 — Dados e variáveis.**
Diga: três fontes (SSP-SP, IBGE renda, IBGE população), sempre em taxa por
1.000 hab. Destaque o desafio prático da junção — SSP abrevia nomes de
município, então a chave real é o código IBGE de 7 dígitos, não o nome.
Não esqueça: mencionar os 16 municípios litorâneos/turísticos como
classificação do próprio grupo (não é variável oficial do IBGE/SSP).

**Slide 4 — Por que o furto: cada crime tem seus outliers.**
Diga: esse slide responde uma pergunta que a banca certamente teria — por
que escolher furto entre os três crimes disponíveis? Olhando a dispersão de
cada taxa contra a renda, só no furto os outliers extremos são quase todos
litorâneos; no roubo e na lesão corporal, os pontos mais extremos são de
municípios não-litorâneos.
Não esqueça: nomear Mongaguá como exemplo do painel do meio — ele reaparece
depois no slide 11, então já plante essa referência aqui.

**Slide 5 — A renda correlaciona positivamente com o furto.**
Diga: a correlação (Pearson e Spearman) já contraria H1 para roubo e furto —
os dois sobem junto com a renda. Só a lesão corporal cai, e fraco. O mapa de
calor ao lado é só outra forma de ler a mesma tabela.
Não esqueça: reforçar que correlação não implica causalidade — é a ressalva
que abre espaço para toda a investigação espacial que vem a seguir.

---

## Bloco 3 — Desenvolvimento e resultados do modelo (slides 6–12)

A lógica narrativa deste bloco: **o dado tem estrutura espacial → o modelo
simples não dá conta dela → cada modelo seguinte recupera um pedaço dessa
estrutura, até o GWR explicar a maior parte.**

**Slide 6 — O crime tem endereço: autocorrelação espacial.**
Diga: o Moran's I mede o quanto valores parecidos se agrupam no espaço —
roubo tem autocorrelação forte (0,832), furto moderada (0,422), lesão
corporal fraca (0,181). O LISA localiza onde isso acontece: cluster
Alto-Alto do furto acompanha o litoral inteiro.
Não esqueça: os 36% de municípios do cluster Alto-Alto que já são
litorâneos/turísticos — primeira evidência quantitativa a favor de H2, antes
de qualquer regressão. Se perguntarem por que o GeoDa dá números um pouco
diferentes (49 e não 36), explique que a geografia dos clusters é a mesma
nos dois softwares — a contagem exata varia por causa de pequenas diferenças
na implementação da permutação local; ver `docs/guia_geoda.md`.

**Slide 7 — Regressão clássica: a renda sozinha não basta.**
Diga: o modelo simples já confirma que H1 não se sustenta (coeficiente da
renda positivo e significativo), mas explica pouco sozinho (R²=0,129). Ao
somar a variável litoral, o R² salta para 0,357, e o coeficiente do litoral
(quase 11 furtos/1.000 hab.) é o tamanho do efeito, não só a direção.
Não esqueça: o "equivalente a +R$4.700 de renda" e o detalhe de Cook (29
influentes, 8 litorâneos = metade dos 16 municípios do litoral) — mostra que
o padrão litorâneo não é coincidência de poucos pontos.

**Slide 8 — O espaço importa: do global ao local.**
Diga: os resíduos do modelo clássico ainda têm autocorrelação espacial forte
(Moran's I = 0,38) — isso viola uma premissa do OLS e motiva os três passos
seguintes, resumidos nas três caixas: spatial error (melhor modelo global,
R²=0,392), GWR só com renda (R²=0,458, o coeficiente passa a variar no
espaço) e GWR com renda + litoral (R²=0,532, o melhor de todos).
Não esqueça: é o slide mais denso de números do bloco — dê um segundo a mais
antes de seguir, e feche com "menor AIC entre todos os modelos" para cravar
por que esse é o vencedor.

**Slide 9 — GWR + litoral: isolando o efeito turístico.**
Diga: para isolar o efeito litorâneo de verdade, foi simulado "e se nenhum
município fosse litorâneo?", zerando essa variável e comparando a predição.
A diferença — até 12 furtos/1.000 hab. — aparece exatamente na faixa
costeira.
Não esqueça: o contraste de resíduos (+10,68 nos litorâneos vs. −0,27 nos
demais, sem a variável; ambos zero com ela) é a evidência mais direta do
mecanismo — fale devagar nesse número.

**Slide 10 — Onde o modelo erra: o rastro da população flutuante.**
Diga: esse slide explica o *porquê* em uma frase — o numerador (ocorrências)
infla com o turismo de verão, mas o denominador (população) só conta quem
mora fixo ali, medido pelo Censo. Por isso a taxa por 1.000 hab. superestima
o risco real para quem mora no litoral.
Não esqueça: é a explicação mais "leiga" da apresentação — a que qualquer
pessoa da plateia entende sem saber estatística. Não pule ou acelere aqui.

**Slide 11 — Quanto R$ 1 de renda pesa — e onde falha.**
Diga: um exemplo concreto fecha o argumento — em São Paulo, o coeficiente
local da renda é confiável (t=3,28); em Mongaguá, não (t=0,46), e o resíduo
de +21 ali é quase todo população turística flutuante, não renda.
Não esqueça: a frase final — "não é só quanto de renda existe, é onde ela
está" — é a tese do GWR resumida em uma linha; feche o slide com ela.

**Slide 12 — Comparação final dos modelos.**
Diga: a tabela resume a jornada inteira — cada modelo melhora sobre o
anterior, e a variável litoral ajuda em todos, mas ajuda menos nos modelos
espaciais (porque eles já capturavam parte do padrão implicitamente). O
melhor modelo é o GWR com renda e litoral, R²=0,532.
Não esqueça: esse é o slide-resumo — se alguém só prestar atenção em um
slide do bloco de resultados, é este.

---

## Bloco 4 — Conclusão (slide 13)

**Slide 13 — Conclusão: não é pobreza. É território.**
Diga: feche revisitando a pergunta do slide 2 — não, os municípios mais
pobres não têm mais furto; a relação é positiva em todos os modelos. Percorra
os 5 pontos numerados e feche no ponto 5 (verde, em destaque): o modelo
vencedor e seu R².
Não esqueça: se sobrar tempo, comente a direção futura oralmente (medida
direta de fluxo turístico — hospedagem, pedágio, telefonia — para testar o
mecanismo sem depender só da dummy) e agradeça a orientação da Prof.ª
Flávia. Isso não está mais em slide próprio — cabe numa frase de encerramento.

---

## Perguntas prováveis e respostas rápidas

- **"Por que furto e não roubo, que tem autocorrelação mais forte?"** — O
  slide 4 já responde: no furto, os outliers extremos são quase todos
  litorâneos; no roubo, a geografia é dominada pela RMSP e Baixada Santista,
  menos interessante para testar a hipótese litorânea/turística.
- **"Isso prova que turismo causa furto?"** — Não; é uma hipótese
  exploratória bem sustentada por evidência convergente (correlação, LISA,
  resíduos, contrafactual, exemplo de Mongaguá), mas com uma variável dummy
  como proxy indireta do fenômeno. Causalidade exigiria dado direto de fluxo
  turístico.
- **"Por que GWR e não só spatial error?"** — O spatial error assume um
  único coeficiente para o estado inteiro; o GWR testa diretamente a
  hipótese de que a própria relação renda–furto muda no espaço — e o
  exemplo São Paulo × Mongaguá (slide 11) mostra isso concretamente.
- **"Como vocês decidiram quais municípios são litorâneos/turísticos?"** —
  Classificação do grupo, 16 municípios da costa paulista por padrão,
  documentada e editável em `data/litoranea_turistica.csv`.
- **"Qual a vizinhança espacial usada nos modelos?"** — Contiguidade queen
  de ordem 1 (municípios que compartilham fronteira), pesos
  row-standardized. Ilhabela, por ser arquipélago, fica sem vizinhos na
  matriz (`zero.policy = TRUE`). Esse detalhe metodológico está completo no
  artigo em LaTeX, se pedirem mais profundidade do que cabe na apresentação.
- **"A malha/matriz de vizinhança influencia muito o resultado?"** — Os
  resultados que dependem só de renda e litoral (OLS, GWR) são estáveis; os
  que dependem da matriz de vizinhança (Moran's I, LISA, spatial lag/error)
  podem variar um pouco conforme a fonte da malha municipal — por isso os
  números foram conferidos contra o GeoDa (ver `docs/guia_geoda.md`).

## Dicas gerais

- Leve o PDF como plano B (`slides/apresentacao_final.pdf`) caso o
  computador da apresentação não tenha PowerPoint/LibreOffice.
- Nos slides de mapa (2, 6, 9, 10), aponte fisicamente para a região que
  sustenta a frase-chave — RMSP, Baixada Santista, litoral norte — em vez de
  só ler o texto ao lado.
- Se o tempo apertar, os slides que dá para condensar em uma frase de
  transição são o 9 e o 10 (ambos reforçam o mesmo mecanismo, de ângulos
  diferentes); não corte o 4, o 5, o 8 ou o 11 — são onde a hipótese vira
  evidência.
- Pratique com cronômetro pelo menos uma vez: 13 slides em 10 minutos são
  ~45s cada, e os slides 8 e 11 tendem a estourar esse tempo se não forem
  ensaiados.
