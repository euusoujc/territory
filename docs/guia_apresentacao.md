# Guia de apresentação — Furto, Renda e Território

Roteiro de apoio para apresentar `slides/apresentacao_final.pptx` (ou o PDF
equivalente). Cobre os 15 slides, o que falar em cada um, o dado que merece
ênfase, e perguntas prováveis da banca/turma com respostas prontas. Tempo
sugerido: 10–12 min de fala + perguntas (± 45s por slide, mais nos slides 9–13
que carregam o argumento central).

## Como usar este guia

- Cada bloco abaixo corresponde a um slide (numeração igual à do rodapé do
  slide). "Diga" é a fala sugerida, não um script para decorar — adapte com
  suas palavras. "Não esqueça" é o número/detalhe que não pode faltar.
- Um só apresentador pode conduzir tudo, ou dividir por seção (sugestão: uma
  pessoa por seção — Hipótese, Dados, Desenvolvimento, Conclusão — já que são
  blocos com início e fim claros).
- Se a banca só vai ver o PDF (sem interação), destaque verbalmente os números
  que estão nas figuras — quem lê rápido foca no mapa, não no texto pequeno.

---

## Bloco 1 — Hipótese e motivação (slides 1–3)

**Slide 1 — Título.** Diga quem são vocês, a disciplina e a orientação em uma
frase; não precisa ler o subtítulo, só apontar. Sirva de ponte direta para o
slide 2 com a pergunta de pesquisa.

**Slide 2 — "Acontecem mais crimes nas cidades mais pobres?"**
Diga: essa é a hipótese de senso comum (H1) que motivou o trabalho, testada
com dados reais dos 645 municípios de SP — SSP-SP para ocorrências, IBGE para
renda e população.
Não esqueça: explicar *por que taxa e não contagem bruta* — é a pergunta mais
óbvia que a banca pode fazer se pular esse ponto. Contagem destaca sempre as
cidades grandes (São Paulo, Guarulhos...) independente do fenômeno; taxa por
1.000 hab. permite comparar municípios de portes muito diferentes.

**Slide 3 — "A correlação é positiva — o oposto de H1".**
Diga: já na correlação simples, o sinal já contraria H1 — renda e furto
andam juntos, positivamente (Pearson 0,359). Isso não prova causalidade, mas
foi o gatilho para abrir uma segunda hipótese exploratória, H2, sobre
municípios litorâneos/turísticos.
Não esqueça: deixar claro que H2 nasceu *dos dados*, não foi hipótese de
partida — reforça que a metodologia foi exploratória e honesta com o que os
números mostraram.

---

## Bloco 2 — Dados e variáveis (slides 4–5)

**Slide 4 — Bases, chave de junção e variáveis.**
Diga: três fontes (SSP-SP, IBGE renda, IBGE população), sempre em taxa por
1.000 hab., e destaque o desafio prático da junção — SSP abrevia nomes de
município, então usar nome como chave perderia observações; a chave real é o
código IBGE de 7 dígitos.
Não esqueça: mencionar os 16 municípios litorâneos/turísticos como uma
classificação do próprio grupo (não é uma variável oficial do IBGE/SSP) —
isso costuma gerar pergunta.

**Slide 5 — Metodologia: quatro etapas progressivas.**
Diga: a análise é uma escada, cada degrau motivado pelo anterior — correlação
aponta o sinal, autocorrelação espacial mostra que o dado tem estrutura no
espaço, OLS clássico ainda deixa essa estrutura nos resíduos, regressão
espacial trata parte dela globalmente, e o GWR (último degrau) permite que a
própria relação renda–furto mude de município para município.
Não esqueça: o detalhe da vizinhança **queen** e da Ilhabela sem vizinhos —
é um detalhe técnico que mostra cuidado metodológico se alguém perguntar
"e ilhas, como vocês trataram?".

---

## Bloco 3 — Desenvolvimento e resultados do modelo (slides 6–13)

Este é o bloco mais longo e o coração do argumento. A lógica narrativa é:
**o dado tem estrutura espacial → o modelo simples não dá conta dela → cada
modelo seguinte recupera um pedaço dessa estrutura, até o GWR explicar a
maior parte.**

**Slide 6 — Moran's I e LISA.**
Diga: o Moran's I mede o quanto valores parecidos se agrupam no espaço —
roubo tem autocorrelação forte (0,832, geografia de RMSP/Baixada), furto
moderada (0,422), lesão corporal fraca (0,181). O LISA localiza *onde* isso
acontece: cluster Alto-Alto do furto acompanha o litoral inteiro.
Não esqueça: os 36% de municípios do cluster Alto-Alto que são
litorâneos/turísticos — é a primeira evidência quantitativa a favor de H2,
antes de qualquer regressão.
Se perguntarem "por que o GeoDa dá 49 e não 36 nesse cluster": a geografia dos
clusters é a mesma nos dois softwares; a contagem exata varia porque a
inferência local (permutação) tem implementações levemente diferentes no R e
no GeoDa — ver `docs/guia_geoda.md` para a comparação completa. O número
citado no artigo/slide é sempre o do R, para bater com o Moran's I global
(que também vem do R).

**Slide 7 — Regressão linear clássica.**
Diga: o modelo simples já confirma que H1 não se sustenta (coeficiente da
renda positivo e significativo), mas explica pouco sozinho (R²=0,129). Ao
somar a variável litoral, o R² salta para 0,357 e o coeficiente do litoral
(quase 11 furtos/1.000 hab.) é o tamanho do efeito, não só a direção.
Não esqueça: o "equivalente a +R$4.700 de renda" — é a forma mais concreta de
comunicar a magnitude do efeito litorâneo para quem não pensa em unidades de
regressão.

**Slide 8 — Regressão espacial global.**
Diga: os resíduos do modelo clássico ainda têm autocorrelação espacial forte
(Moran's I = 0,38) — isso viola uma premissa do OLS e é o motivo técnico para
migrar para modelos espaciais. Os testes de Lagrange apontam o *spatial
error* como mais adequado que o *spatial lag*.
Não esqueça: a leitura substantiva, não só o teste estatístico — "erro
espacial" aqui sugere uma variável omitida e agrupada no espaço (leia-se:
litoral), e não um efeito de contágio direto entre municípios vizinhos.

**Slide 9 — GWR (renda).**
Diga: aqui a análise muda de patamar — em vez de um coeficiente único para o
estado inteiro, o GWR ajusta uma regressão *por município*, deixando a
relação renda–furto variar no espaço. R² sobe para 0,458, e o mapa mostra
onde a renda explica bem (centro-oeste) e onde explica mal (litoral e RMSP).
Não esqueça: essa é a virada conceitual do trabalho — reforce que "explica
mal justamente onde H2 prevê que o turismo deveria dominar" é o elo entre o
método e a hipótese.

**Slide 10 — GWR com renda + litoral.**
Diga: ao entrar com a variável litoral no GWR, os quatro mapas (coeficiente e
estatística t de cada variável) mostram onde e o quanto cada efeito atua. O
efeito litorâneo tem magnitude de até 22 furtos/1.000 hab. em alguns
municípios.
Não esqueça: o mapa do t mostra significância *contínua*, não um corte
binário — e o padrão real é que o efeito litorâneo cresce do noroeste em
direção à RMSP e à Baixada Santista, não fica restrito a uma faixa estreita
do litoral. Vale explicar em uma frase por que isso faz sentido: o GWR usa
vizinhos geográficos, então o efeito "vaza" para municípios próximos aos
litorâneos.

**Slide 11 — Cenário contrafactual.**
Diga: para isolar o efeito litorâneo de verdade, foi simulado "e se nenhum
município fosse litorâneo?" zerando essa variável e comparando a predição.
A diferença — até 12 furtos/1.000 hab. — aparece exatamente na faixa costeira.
Não esqueça: o resultado da regressão por regime (interior vs. litoral) é um
ponto forte — dentro do próprio grupo litorâneo a renda quase não explica
nada (R²=0,008), o que reforça que ali o motor é outro (turismo), não renda.

**Slide 12 — Resíduos confirmam o mecanismo.**
Diga: esse slide fecha o argumento causal indireto — sem a variável litoral,
o erro do modelo é sistematicamente positivo nos municípios litorâneos
(+10,68 em média) e neutro nos demais (−0,27); ao incluir a variável, os dois
grupos centram em zero.
Não esqueça: a correlação resíduo × litoral caindo de 0,51 para 0,00 é a
frase mais "estatística" do slide — só cite se achar que a banca vai gostar
do detalhe, senão o boxplot já fala por si.

**Slide 13 — Comparação final dos modelos.**
Diga: a tabela resume a jornada inteira — cada modelo melhora sobre o
anterior, e a variável litoral ajuda em todos, mas ajuda menos nos modelos
espaciais (porque eles já capturavam parte do padrão implicitamente). O
melhor modelo é o GWR com renda e litoral, R²=0,532, menor AIC.
Não esqueça: esse é o slide-resumo — se alguém só prestar atenção em um
slide do bloco de resultados, é este. Dê um segundo a mais para a tabela
"respirar" antes de seguir para a conclusão.

---

## Bloco 4 — Conclusão (slides 14–15)

**Slide 14 — H1 não se sustenta; H2 explica o padrão.**
Diga: feche revisitando a pergunta do slide 2 — não, os municípios mais
pobres não têm mais furto; a relação é positiva em todos os modelos. Depois
resuma as três camadas do fenômeno (renda insuficiente sozinha → estrutura
absorvida pelo litoral → a própria relação renda–furto não é estacionária).
Não esqueça: reforçar a explicação do mecanismo (população flutuante de
verão infla o numerador sobre denominador de população residente) — é a
frase que resume o trabalho inteiro em uma linha.

**Slide 15 — Direção futura e agradecimentos.**
Diga: a limitação principal é que "litorâneo/turístico" é uma dummy do
grupo, não uma medida direta de fluxo turístico — próximo passo seria
incorporar dado de hospedagem, pedágio ou telefonia para testar o mecanismo
diretamente. Feche agradecendo a orientação.

---

## Perguntas prováveis e respostas rápidas

- **"Por que furto e não roubo, que tem autocorrelação mais forte?"** —
  Furto foi o que mostrou a relação mais nítida com renda e território na
  exploração inicial; roubo tem geografia muito concentrada na RMSP e
  Baixada Santista, o que o torna menos interessante para testar a hipótese
  litorânea/turística especificamente.
- **"Isso prova que turismo causa furto?"** — Não; é uma hipótese
  exploratória bem sustentada por evidência convergente (correlação, LISA,
  resíduos, contrafactual), mas com uma variável dummy como proxy indireta
  do fenômeno. Causalidade exigiria dado direto de fluxo turístico.
- **"Por que GWR e não só spatial error?"** — Porque o spatial error assume
  um único coeficiente para o estado inteiro; o GWR testa diretamente a
  hipótese de que a própria relação renda–furto muda no espaço, e o ganho de
  R² (0,458 vs. 0,392 sem litoral) confirma que essa não-estacionariedade é
  real, não ruído.
- **"Como vocês decidiram quais municípios são litorâneos/turísticos?"** —
  Classificação do grupo, 16 municípios da costa paulista por padrão,
  documentada e editável em `data/litoranea_turistica.csv`.
- **"A malha/matriz de vizinhança influencia muito o resultado?"** — Os
  resultados que dependem só de renda e litoral (OLS, GWR) são estáveis;
  os que dependem da matriz de vizinhança (Moran's I, LISA, spatial
  lag/error) podem variar um pouco conforme a fonte da malha municipal —
  por isso o pipeline sempre roda com a mesma malha cacheada em
  `data/malha_municipios_sp.gpkg` e os números foram conferidos contra o
  GeoDa (ver `docs/guia_geoda.md`).

## Dicas gerais

- Leve o PDF como plano B (`slides/apresentacao_final.pdf`) caso o
  computador da apresentação não tenha PowerPoint/LibreOffice para abrir o
  `.pptx`.
- Nos slides de mapa (3, 6, 9, 10, 11, 12), aponte fisicamente para a região
  que sustenta a frase-chave — RMSP, Baixada Santista, litoral norte — em vez
  de só ler o texto ao lado.
- Se o tempo apertar, os slides que dá para condensar em uma frase de
  transição são o 8 (regressão espacial global) e o 11 (contrafactual);
  não corte o 6, o 9, o 10 ou o 13 — são onde a hipótese vira evidência.
