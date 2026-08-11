# Guia de apresentação — Furto, Renda e Território

Roteiro de apoio para apresentar `slides/apresentacao_final.pptx` (ou o PDF
equivalente), slide a slide, em duas camadas:

- **🎯 Essencial** — o que falar naquele momento, com o slide na tela. Curto,
  direto, decorável.
- **📚 Complemento** — material extra para se sobrar tempo, para responder
  perguntas da banca sobre aquele slide, ou para quem quiser se aprofundar
  antes de apresentar. Cada complemento aponta para a seção correspondente
  em [`guia_projeto_completo.md`](guia_projeto_completo.md), que tem *todos*
  os números do projeto — este guia aqui é só a porta de entrada.

Tempo alvo: **até 10-12 min** de fala usando só a camada Essencial (± 45s
por slide). Sem slide de metodologia isolado — a orientação avaliou que não
é necessário detalhar esse passo a passo na apresentação; ele está completo
na seção 4 do guia completo e no artigo em LaTeX.

## Como usar este guia

- Um só apresentador pode conduzir tudo, ou dividir por seção (sugestão: uma
  pessoa por bloco — Hipótese, Dados, Taxas, Correlação, Desenvolvimento,
  Conclusão).
- Ritmo: os slides 5, 6, 10 e 13 carregam o argumento central (outliers,
  por que o furto, progressão de modelos, exemplo concreto) — não acelere
  neles, e vale ler o Complemento deles antes de apresentar, mesmo que não
  use tudo na hora. Os slides 4, 7, 8, 11, 12 podem ser mais rápidos.
- Antes do dia da apresentação, todo mundo deveria ter lido pelo menos uma
  vez o `guia_projeto_completo.md` inteiro — ele é curto o suficiente para
  isso e é o que garante que qualquer um da equipe responda qualquer
  pergunta, não só sobre "seu" bloco.

---

## Bloco 1 — Hipótese (slides 1–2)

### Slide 1 — Título

**🎯 Essencial:** quem são vocês, a disciplina e a orientação em uma frase;
sirva de ponte direta para o slide 2 com a pergunta de pesquisa.

### Slide 2 — A pergunta que originou o trabalho

**🎯 Essencial:** essa é a hipótese de senso comum (H1) que motivou o
trabalho — cidades mais pobres registram mais crimes patrimoniais — testada
com dados reais dos 645 municípios de SP, cruzando três crimes da SSP-SP com
a renda do Censo IBGE. Este slide fica só na pergunta e nas fontes; os mapas
e a primeira observação visual vêm no bloco seguinte, então não antecipe.

**📚 Complemento** (guia completo, seção 2 — "A pergunta e as duas
hipóteses"): H2 nasceu *durante* a análise exploratória, não era hipótese de
partida — se alguém perguntar "vocês já esperavam esse resultado?", a
resposta honesta é não, e vale contar. Se perguntarem por que só três
crimes: são os três mais frequentes/registrados de forma consistente pela
SSP-SP no recorte usado.

---

## Bloco 2 — Dados e variáveis (slide 3)

### Slide 3 — Dados e variáveis

**🎯 Essencial:** três fontes (SSP-SP, IBGE renda, IBGE população), sempre
em taxa por 1.000 hab. Destaque o desafio prático da junção — SSP abrevia
nomes de município, então a chave real é o código IBGE de 7 dígitos, não o
nome. Os 16 municípios litorâneos/turísticos são classificação do próprio
grupo (não é variável oficial do IBGE/SSP).

**📚 Complemento** (guia completo, seção 3 — "Dados: fontes, variáveis,
junção"): a cascata de resolução de nomes tem 4 passos (correspondência
exata → abreviações → preposições → distância de edição ≤ 1); a validação
final do tabelão deu **zero erros e zero avisos** em 645 linhas — vale citar
esse número se perguntarem sobre qualidade dos dados. Se perguntarem por que
não usaram nome de município como chave: porque perderia observações (nomes
abreviados/divergentes entre bases).

---

## Bloco 3 — Taxas (slides 4–5)

### Slide 4 — Como o crime se distribui no espaço

**🎯 Essencial:** antes de qualquer estatística, olhe os três mapas lado a
lado — o padrão espacial já é diferente para cada crime. Roubo concentra na
macrometrópole; furto acompanha o litoral inteiro, de ponta a ponta; lesão
corporal não tem um padrão espacial claro. Aponte fisicamente o contraste
entre o mapa do meio (furto, escuro no litoral) e os outros dois — é o
gancho visual para o slide seguinte.

**📚 Complemento** (guia completo, seção 5.1 — "Análise exploratória"): o
box map (não mostrado, mas no artigo) confirma numericamente o que o mapa
sugere visualmente: 17 outliers superiores no furto (litoral e capital)
contra 60 no roubo (RMSP e Baixada Santista). No top 5 de furto, 4 dos 5
municípios são litorâneos — Mongaguá sozinho tem taxa de 34,17/1.000 hab.

### Slide 5 — Por que o furto: cada crime tem seus outliers

**🎯 Essencial:** esse slide responde a pergunta que a banca certamente
teria — por que escolher furto entre os três crimes disponíveis? Olhando a
dispersão de cada taxa contra a renda, só no furto os outliers extremos são
quase todos litorâneos; no roubo e na lesão corporal, os pontos mais
extremos são de municípios não-litorâneos. Nomeie Mongaguá — ele reaparece
no slide 13, então já plante essa referência aqui.

**📚 Complemento** (guia completo, seção 3, último parágrafo — "Por que o
furto foi escolhido"): esse slide é o segundo dos três pilares da escolha do
furto (mapas → outliers → correlação, que fecha no slide 6). Se quiserem
juntar tudo numa frase só: "mapa, outliers e correlação apontam os três na
mesma direção, só para o furto."

---

## Bloco 4 — Correlação (slide 6)

### Slide 6 — A renda correlaciona positivamente com o furto

**🎯 Essencial:** a correlação (Pearson e Spearman) já contraria H1 para
roubo e furto — os dois sobem junto com a renda. Só a lesão corporal cai, e
fraco. O mapa de calor ao lado é só outra forma de ler a mesma tabela. Feche
amarrando os três blocos anteriores — mapas, outliers e correlação apontam
juntos para o furto, "por isso ele foi escolhido como variável dependente
principal." Depois, reforce que correlação não implica causalidade — é o
que abre espaço para toda a investigação espacial que vem a seguir.

**📚 Complemento** (guia completo, seção 5.2 — "Correlação (tabela
completa)"): a tabela completa tem também roubo×furto (0,544 Pearson) e as
correlações cruzadas com lesão corporal, caso perguntem sobre elas
especificamente. Nenhuma correlação aqui é forte (todas |r| < 0,6) — vale
frisar isso se perguntarem "essa correlação é forte?": não, é moderada/fraca,
e é exatamente por isso que o trabalho não para na correlação e avança para
os modelos espaciais.

---

## Bloco 5 — Desenvolvimento e resultados do modelo (slides 7–14)

A lógica narrativa deste bloco: **o dado tem estrutura espacial → o modelo
simples não dá conta dela → cada modelo seguinte recupera um pedaço dessa
estrutura, até o GWR explicar a maior parte.**

### Slide 7 — O crime tem endereço: autocorrelação espacial

**🎯 Essencial:** o Moran's I mede o quanto valores parecidos se agrupam no
espaço — roubo tem autocorrelação forte (0,832), furto moderada (0,422),
lesão corporal fraca (0,181). O LISA localiza onde isso acontece: cluster
Alto-Alto do furto acompanha o litoral inteiro. Os 36% de municípios do
cluster Alto-Alto que já são litorâneos/turísticos são a primeira evidência
quantitativa a favor de H2, antes de qualquer regressão.

**📚 Complemento** (guia completo, seção 5.3 — "Autocorrelação espacial:
Moran global e LISA"): tabela completa de LISA para os três crimes (roubo:
45 Alto-Alto/93 Baixo-Baixo; lesão: 22/28). Se perguntarem por que o GeoDa
dá números diferentes (49 e não 36 para Alto-Alto do furto): a geografia dos
clusters é a mesma nos dois softwares — a contagem exata varia por pequenas
diferenças na implementação da permutação local. O texto do artigo e da
apresentação sempre usa os números do R, para bater com o Moran's I global
citado (que também vem do R). Ver `docs/guia_geoda.md` para a comparação
completa.

### Slide 8 — Regressão clássica: a renda sozinha não basta

**🎯 Essencial:** o modelo simples já confirma que H1 não se sustenta
(coeficiente da renda positivo e significativo), mas explica pouco sozinho
(R²=0,129). Ao somar a variável litoral, o R² salta para 0,357, e o
coeficiente do litoral (quase 11 furtos/1.000 hab.) é o tamanho do efeito,
não só a direção. O "equivalente a +R$4.700 de renda" e o detalhe de Cook
(29 influentes, 8 litorâneos = metade dos 16 municípios do litoral) mostram
que o padrão litorâneo não é coincidência de poucos pontos.

**📚 Complemento** (guia completo, seção 5.4 — "Regressão linear clássica"):
os diagnósticos formais (Shapiro-Wilk e ncvTest, ambos p<0,001) rejeitam
normalidade e homocedasticidade dos resíduos — é a justificativa técnica
para todo o resto da apresentação, se alguém perguntar "por que vocês não
pararam no OLS?". Sem os 29 municípios influentes, o R² do modelo simples
sobe de 0,13 para 0,19 — o efeito da renda se *fortalece*, não desaparece,
ao remover outliers, o que responde de antemão "isso não é um artefato de
poucos pontos extremos?".

### Slide 9 — Por que sair do OLS

**🎯 Essencial:** os resíduos do modelo clássico ainda têm autocorrelação
espacial forte (Moran's I = 0,38) — o mapa mostra isso: municípios vizinhos
erram parecido, concentrado no litoral. Isso viola uma premissa do OLS
(independência dos erros) e é o motivo técnico, não só estatístico, para
migrar para modelos espaciais. Dê um segundo para o mapa antes de seguir.

**📚 Complemento** (guia completo, seção 5.5 — "Regressão espacial global",
primeiro parágrafo): os testes de Lagrange completos (LM lag=217,4, LM
error=238,9, Robust LM lag=1,23 p=0,267 não significativo, Robust LM
error=22,8 p<0,001 significativo) são a base estatística formal para
escolher spatial error sobre spatial lag — cite-os se a banca pedir rigor
estatístico nessa decisão.

### Slide 10 — O espaço importa: do global ao local

**🎯 Essencial:** três formas de tratar essa estrutura espacial, resumidas
nas três caixas: spatial error (melhor modelo global, R²=0,392), GWR só com
renda (R²=0,458, o coeficiente passa a variar no espaço) e GWR com renda +
litoral (R²=0,532, o melhor de todos). É o slide mais denso de números do
bloco — dê um segundo a mais antes de seguir, e feche com "menor AIC entre
todos os modelos" para cravar por que esse é o vencedor.

**📚 Complemento** (guia completo, seção 5.5, tabela de comparação e seção
5.6 — "GWR (renda)"): o spatial lag (ρ=0,519, R²=0,355, AIC=3241,5) também
aparece na tabela completa, mas não é citado no slide — foi descartado pelos
testes de Lagrange (ver slide 9). No GWR só-renda, o coeficiente local varia
de −0,00216 a +0,00562 pelo estado e é significativo (|t|>1,96) em 72% dos
municípios — útil se perguntarem "o efeito da renda é sempre positivo?": não,
há um bolsão invertido no noroeste.

### Slide 11 — GWR + litoral: isolando o efeito turístico

**🎯 Essencial:** para isolar o efeito litorâneo de verdade, foi simulado
"e se nenhum município fosse litorâneo?", zerando essa variável e comparando
a predição. A diferença — até 12 furtos/1.000 hab. — aparece exatamente na
faixa costeira. O contraste de resíduos (+10,68 nos litorâneos vs. −0,27 nos
demais, sem a variável; ambos zero com ela) é a evidência mais direta do
mecanismo — fale devagar nesse número.

**📚 Complemento** (guia completo, seção 5.7 — "GWR + litoral, contrafactual
e mecanismo"): a correlação resíduo×litoral cai de 0,51 (sem a variável)
para 0,00 (com ela) — um número extra de peso estatístico, se quiserem
reforçar o contrafactual. A leitura por regime espacial (interior R²=0,19
vs. litoral R²=0,008) também está aqui, caso a pergunta seja "e dentro do
próprio litoral, a renda importa?" — a resposta é não, quase nada.

### Slide 12 — Onde o modelo erra: o rastro da população flutuante

**🎯 Essencial:** esse slide explica o *porquê* em uma frase — o numerador
(ocorrências) infla com o turismo de verão, mas o denominador (população) só
conta quem mora fixo ali, medido pelo Censo. Por isso a taxa por 1.000 hab.
superestima o risco real para quem mora no litoral. É a explicação mais
"leiga" da apresentação — a que qualquer pessoa da plateia entende sem saber
estatística. Não pule ou acelere aqui.

**📚 Complemento** (guia completo, seção 5.7, último parágrafo — "O
mecanismo numérico"): se perguntarem como resolver isso de vez, a resposta
está na seção 6 (Conclusão) do guia completo — medida direta de fluxo
turístico (hospedagem, pedágio, telefonia), hoje só capturada indiretamente
pela dummy.

### Slide 13 — Quanto R$ 1 de renda pesa — e onde falha

**🎯 Essencial:** um exemplo concreto fecha o argumento — em São Paulo, o
coeficiente local da renda é confiável (t=3,28); em Mongaguá, não (t=0,46),
e o resíduo de +21 ali é quase todo população turística flutuante, não
renda. Feche com a frase "não é só quanto de renda existe, é onde ela está"
— é a tese do GWR resumida em uma linha.

**📚 Complemento** (guia completo, seção 5.8 — "Exemplo concreto: São Paulo
× Mongaguá"): todos os 7 números da tabela (renda, banda, β, t, R² local,
previsto, resíduo) vêm direto de `data/geoda_gwr_furto.gpkg`, o pacote de
dados do modelo GWR enxuto (só renda). Se perguntarem por que a banda de
Mongaguá (41,9 km) é maior que a de São Paulo (23,6 km): a banda é
adaptativa — em áreas menos densas de municípios (litoral sul), é preciso
alcançar uma distância maior para reunir os mesmos ~10 vizinhos.

### Slide 14 — Comparação final dos modelos

**🎯 Essencial:** a tabela resume a jornada inteira — cada modelo melhora
sobre o anterior, e a variável litoral ajuda em todos, mas ajuda menos nos
modelos espaciais (porque eles já capturavam parte do padrão
implicitamente). O melhor modelo é o GWR com renda e litoral, R²=0,532. Esse
é o slide-resumo — se alguém só prestar atenção em um slide do bloco de
resultados, é este.

**📚 Complemento** (guia completo, seção 5.9 — "Comparação final de todos os
modelos"): o padrão de "ganho decrescente" do litoral (+0,228 no OLS,
+0,052 no spatial error, +0,074 no GWR) é, em si, um resultado — mostra que
quanto mais sofisticado o modelo espacial, menos ele "precisa" da variável
litoral para captar o padrão, porque a geografia já faz parte do modelo.

---

## Bloco 6 — Conclusão (slide 15)

### Slide 15 — Conclusão: não é pobreza. É território.

**🎯 Essencial:** feche revisitando a pergunta do slide 2 — não, os
municípios mais pobres não têm mais furto; a relação é positiva em todos os
modelos. Percorra os 5 pontos numerados e feche no ponto 5 (verde, em
destaque): o modelo vencedor e seu R². Se sobrar tempo, comente a direção
futura oralmente (medida direta de fluxo turístico) e agradeça a orientação
da Prof.ª Flávia.

**📚 Complemento** (guia completo, seções 6 e 7 — "Conclusão completa" e
"Limitações e ressalvas"): as três camadas do fenômeno (renda insuficiente
→ estrutura absorvida pelo litoral → relação não-estacionária) são a versão
longa dos 5 pontos do slide — útil se a banca pedir para "explicar de novo,
com mais detalhe" a conclusão. A seção de limitações tem respostas prontas
para as perguntas mais difíceis (causalidade, malha espacial, classificação
litorânea) — leia antes de qualquer apresentação, mesmo que não use nada
dela nos slides.

---

## Perguntas prováveis e respostas rápidas

*(Versão condensada — a seção 7 do guia completo tem o texto integral de
cada ressalva.)*

- **"Por que furto e não roubo, que tem autocorrelação mais forte?"** →
  slides 4-6 / guia completo seção 3.
- **"Isso prova que turismo causa furto?"** → guia completo seção 7,
  primeiro item.
- **"Por que GWR e não só spatial error?"** → slide 13 / guia completo
  seção 5.8.
- **"Como vocês decidiram quais municípios são litorâneos/turísticos?"** →
  guia completo seção 7, segundo item.
- **"Qual a vizinhança espacial usada nos modelos?"** → guia completo
  seção 4.
- **"A malha/matriz de vizinhança influencia muito o resultado?"** → guia
  completo seção 7, últimos dois itens.

## Dicas gerais

- Leve o PDF como plano B (`slides/apresentacao_final.pdf`) caso o
  computador da apresentação não tenha PowerPoint/LibreOffice.
- Nos slides de mapa (4, 7, 9, 11, 12), aponte fisicamente para a região que
  sustenta a frase-chave — RMSP, Baixada Santista, litoral norte — em vez de
  só ler o texto ao lado.
- Se o tempo apertar, os slides que dá para condensar em uma frase de
  transição são o 11 e o 12 (ambos reforçam o mesmo mecanismo, de ângulos
  diferentes); não corte o 5, o 6, o 10 ou o 13 — são onde a hipótese vira
  evidência.
- Pratique com cronômetro pelo menos uma vez, usando só a camada Essencial:
  15 slides em 10-12 minutos são ~45-50s cada, e os slides 10 e 13 tendem a
  estourar esse tempo se não forem ensaiados.
