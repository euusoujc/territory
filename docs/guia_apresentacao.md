# Guia de apresentação — Furto, Renda e Território

Roteiro de apoio para apresentar a versão **final** dos slides (a que foi
de fato editada e apresentada, com alguns slides cortados e textos
simplificados em relação a versões anteriores), em duas camadas:

- **🎯 Essencial** — o que falar naquele momento, com o slide na tela. Curto,
  direto, decorável.
- **📚 Complemento** — material extra para se sobrar tempo, para responder
  perguntas da banca sobre aquele slide, ou para quem quiser se aprofundar
  antes de apresentar. Cada complemento aponta para a seção correspondente
  em [`guia_projeto_completo.md`](guia_projeto_completo.md).

Para o significado de cada termo técnico e cada número na tela (o que é
Moran's I, o que é "t", o que é R²...), use
[`guia_conceitos_estatisticos.txt`](guia_conceitos_estatisticos.txt) — ele
segue exatamente esta mesma numeração de slides.

> ⚠️ **Numeração:** os números abaixo seguem o rodapé de cada slide da
> versão final. Dois slides de uma versão anterior (contrafactual do GWR e
> comparação final dos três modelos) foram removidos na edição final, então
> a numeração pula de 10 para 12 e de 13 para 15 — é esperado, não é erro.

## Como usar este guia

- Um só apresentador pode conduzir tudo, ou dividir por seção (sugestão: uma
  pessoa por bloco — Hipótese, Dados, Taxas, Correlação, Desenvolvimento,
  Conclusão).
- Antes do dia da apresentação, todo mundo deveria ter lido pelo menos uma
  vez o `guia_projeto_completo.md` inteiro — ele tem resultados que não
  couberam nos slides finais (o contrafactual do GWR, a tabela de
  comparação de todos os modelos) e que podem ser citados de cabeça se a
  banca perguntar por eles.

---

## Bloco 1 — Hipótese (slides 1–2)

### Slide 1 — Título

**🎯 Essencial:** quem são vocês, a disciplina e a orientação em uma frase;
sirva de ponte direta para o slide 2 com a pergunta de pesquisa.

### Slide 2 — A pergunta que originou o trabalho

**🎯 Essencial:** essa é a hipótese de senso comum (H1) que motivou o
trabalho — cidades mais pobres registram mais crimes patrimoniais — testada
com dados reais dos 645 municípios de SP, cruzando três crimes da SSP-SP com
a renda do Censo IBGE.

**📚 Complemento** (guia completo, seção 2): H2 nasceu *durante* a análise
exploratória, não era hipótese de partida — se alguém perguntar "vocês já
esperavam esse resultado?", a resposta honesta é não, e vale contar.

---

## Bloco 2 — Dados e variáveis (slide 3)

### Slide 3 — Dados e variáveis

**🎯 Essencial:** três fontes (SSP-SP, IBGE renda, IBGE população), sempre
em taxa por 1.000 hab. As bases da SSP-SP e do IBGE precisaram passar por
padronização e tratamento antes de poder ser cruzadas. Os 16 municípios
litorâneos/turísticos são classificação do próprio grupo (não é variável
oficial do IBGE/SSP).

**📚 Complemento** (guia completo, seção 3): se pedirem detalhe sobre esse
"tratamento de dados" — a chave de junção é o código IBGE de 7 dígitos,
nunca o nome do município (a SSP abrevia nomes, ex. "S BARBARA D OESTE"), o
que exige uma resolução em cascata (correspondência exata → abreviações →
distância de edição). A validação final do tabelão deu zero erros e zero
avisos em 645 linhas.

---

## Bloco 3 — Taxas (slides 4–5)

### Slide 4 — Como o crime se distribui no espaço

**🎯 Essencial:** os três mapas lado a lado já mostram um padrão espacial
diferente para cada crime. Roubo concentra na macrometrópole; furto
acompanha o litoral inteiro; lesão corporal é o menos estruturado no
espaço, com mais foco no interior — como a própria orientadora comentou,
"pessoal resolve na peixeira" (é um crime mais de ocasião/pessoal, não seguindo
um padrão geográfico claro de riqueza ou turismo).

**📚 Complemento** (guia completo, seção 5.1): o box map (não mostrado, mas
no artigo) confirma numericamente: 17 outliers superiores no furto (litoral
e capital) contra 60 no roubo (RMSP e Baixada Santista).

### Slide 5 — Por que o furto: cada crime tem seus outliers

**🎯 Essencial:** olhando a dispersão de cada taxa contra a renda, só no
furto os outliers extremos são quase todos litorâneos; no roubo e na lesão
corporal, os pontos mais extremos são de municípios não-litorâneos. Nomeie
Mongaguá — ele reaparece no slide 13.

**📚 Complemento** (guia completo, seção 3, último parágrafo): esse slide é
o segundo pilar da escolha do furto (mapas → outliers → correlação, que
fecha no slide 6).

---

## Bloco 4 — Correlação (slide 6)

### Slide 6 — A renda correlaciona positivamente com o furto

**🎯 Essencial:** a correlação (Pearson e Spearman) já contraria H1 para
roubo e furto — os dois sobem junto com a renda. Só a lesão corporal cai, e
fraco. **Pela maior correlação da taxa de furto com a renda, o furto foi
escolhido como variável principal do trabalho** — essa é a frase-chave do
slide.

**📚 Complemento** (guia completo, seção 5.2): a tabela completa tem também
roubo×furto (0,544 Pearson). Nenhuma correlação aqui é forte (todas
|r| < 0,6) — vale frisar isso se perguntarem "essa correlação é forte?":
não, é moderada/fraca, e é por isso que o trabalho avança para os modelos
espaciais em vez de parar aqui.

---

## Bloco 5 — Desenvolvimento e resultados do modelo (slides 7–13)

A lógica narrativa deste bloco: **o dado tem estrutura espacial → o modelo
simples não dá conta dela → cada modelo seguinte recupera um pedaço dessa
estrutura, até o GWR explicar a maior parte.**

### Slide 7 — O crime tem endereço: autocorrelação espacial

**🎯 Essencial:** o Moran's I mede o quanto valores parecidos se agrupam no
espaço — para o furto, I = 0,422 (moderado), significativo (p=0,001, 999
permutações): o crime não está distribuído ao acaso. O LISA localiza onde
isso acontece: cluster Alto-Alto do furto acompanha o litoral inteiro, e
36% desses municípios já são litorâneos/turísticos — primeira evidência
quantitativa a favor de H2, antes de qualquer regressão.

**📚 Complemento** (guia completo, seção 5.3): o Moran's I do roubo (0,832,
forte) e da lesão corporal (0,181, fraca) não aparecem mais neste slide da
versão final, mas estão prontos se perguntarem sobre os outros dois crimes.
Se perguntarem por que o GeoDa dá números diferentes (49 e não 36 para
Alto-Alto do furto): a geografia dos clusters é a mesma nos dois softwares
— a contagem exata varia por pequenas diferenças na implementação da
permutação local. Ver `docs/guia_geoda.md`.

### Slide 8 — Regressão clássica (as equações)

**🎯 Essencial:** o modelo simples já confirma que H1 não se sustenta
(coeficiente da renda positivo e significativo), mas explica pouco sozinho
(R²=0,129). Ao somar a variável litoral, o R² salta para 0,357.

**📚 Complemento** (guia completo, seção 5.4): o termo litoral (10,97) é
quase 11 furtos a mais por 1.000 hab. em município litorâneo, equivalente a
uma diferença de +R$4.700 de renda. Se perguntarem sobre outliers/pontos
influentes na reta: 29 municípios influentes pela distância de Cook, 8
deles litorâneos — metade dos 16 municípios do litoral entra como outlier
geral, e removê-los FORTALECE o efeito da renda (R² sobe de 0,13 para
0,19), não enfraquece.

### Slide 9 — Regressão clássica (o mapa de resíduos)

**🎯 Essencial:** os resíduos do modelo clássico ainda têm autocorrelação
espacial forte (Moran's I = 0,38) — o mapa mostra isso: municípios vizinhos
erram parecido, concentrado no litoral. Isso viola uma premissa do OLS
(independência dos erros) e motiva os modelos espaciais que seguem: spatial
error e GWR.

**📚 Complemento** (guia completo, seção 5.5, primeiro parágrafo): os
testes de Lagrange completos (LM lag=217,4, LM error=238,9, Robust LM
lag=1,23 p=0,267 não significativo, Robust LM error=22,8 p<0,001
significativo) são a base estatística formal por trás da escolha do spatial
error sobre o spatial lag — cite-os se a banca pedir rigor estatístico
nessa decisão. Esse teste não tem slide próprio na versão final.

### Slide 10 — O espaço importa: do global ao local

**🎯 Essencial:** três formas de tratar essa estrutura espacial, resumidas
nas três caixas: spatial error (R²=0,392), GWR só com renda (R²=0,458, o
coeficiente passa a variar no espaço) e GWR com renda + litoral (R²=0,532,
o melhor de todos, menor AIC entre todos os modelos testados: 3027,4).

**📚 Complemento** (guia completo, seção 5.6 e 5.7): esse é o único slide
onde o R²=0,532 do modelo final aparece — o cenário contrafactual que
isolava numericamente o efeito litorâneo (queda de até 12 furtos/1.000 hab.
ao "zerar" o litoral) e a tabela comparando os 6 modelos lado a lado (OLS,
spatial error e GWR, com e sem litoral) foram cortados da apresentação
final por tempo, mas estão completos no guia do projeto — vale ter esses
números na cabeça caso perguntem "e se vocês tirassem o litoral do
melhor modelo, o que mudaria concretamente?".

### Slide 12 — Onde o modelo erra: o rastro da população flutuante

**🎯 Essencial:** o numerador (ocorrências) infla com o turismo de verão,
mas o denominador (população) só conta quem mora fixo ali, medido pelo
Censo. Por isso a taxa por 1.000 hab. superestima o risco real para quem
mora no litoral. É a explicação mais "leiga" da apresentação — a que
qualquer pessoa da plateia entende sem saber estatística.

**📚 Complemento** (guia completo, seção 5.7): a correlação resíduo×litoral
é 0,51 sem a variável e cai a 0,00 com ela incluída — número extra de peso
estatístico, se quiserem reforçar o mecanismo.

### Slide 13 — Quanto R$ 1 de renda pesa — e onde falha

**🎯 Essencial:** um exemplo concreto fecha o argumento — em São Paulo, o
coeficiente local da renda é confiável (t=3,28); em Mongaguá, não (t=0,46),
e o resíduo de +21 ali é quase todo população turística flutuante, não
renda. Feche com a frase "não é só quanto de renda existe, é onde ela está".

**📚 Complemento** (`guia_conceitos_estatisticos.txt`, seção do slide 13):
se perguntarem o que é exatamente o "t" — é a estatística que diz se um
coeficiente é confiável ou pode ser só ruído (t = coeficiente ÷
incerteza da estimativa); |t| > 1,96 é o corte convencional para
"significativo". Vale ter essa definição pronta, é a pergunta mais
provável do slide inteiro. Todos os 7 números da tabela vêm direto de
`data/geoda_gwr_furto.gpkg`.

---

## Bloco 6 — Conclusão (slide 15)

### Slide 15 — Conclusão: turismo influencia no resultado

**🎯 Essencial:** feche revisitando a pergunta do slide 2 — a hipótese
inicial (H1) não se sustenta. Percorra os 3 pontos: (1) H1 não se sustenta;
(2) a renda sozinha explica pouco (R²=0,13) e deixa autocorrelação espacial
nos resíduos; (3) essa estrutura é majoritariamente explicada pela condição
litorânea/turística — a população flutuante infla a taxa sobre um
denominador de residentes fixos.

**📚 Complemento** (guia completo, seção 6): a versão longa da conclusão
tem mais dois pontos que não entraram na versão final dos slides — a
não-estacionariedade da relação renda-furto no espaço (forte no interior,
quase nula no litoral) e o R²=0,532 do modelo vencedor (GWR com renda e
litoral). Bom material para fechar a fala com mais força, mesmo sem estar
escrito no slide, ou para responder se a banca perguntar "qual foi o melhor
modelo, no final?".

---

## Perguntas prováveis e respostas rápidas

*(Versão condensada — a seção 7 do guia completo tem o texto integral de
cada ressalva.)*

- **"Por que furto e não roubo, que tem autocorrelação mais forte?"** →
  slides 4-6 / guia completo seção 3.
- **"Isso prova que turismo causa furto?"** → guia completo seção 7,
  primeiro item.
- **"Qual foi o melhor modelo no final, e por quanto ele venceu?"** → GWR
  com renda e litoral, R²=0,532, menor AIC (3027,4) — citado no slide 10,
  mas a tabela comparativa completa (6 modelos) só está no guia completo,
  seção 5.9.
- **"E se vocês tirassem a variável litoral do melhor modelo?"** → o
  cenário contrafactual (cortado da apresentação final) mostra queda de
  até 12 furtos/1.000 hab., concentrada na faixa costeira — guia completo,
  seção 5.7.
- **"O que é a estatística t, no slide de São Paulo x Mongaguá?"** →
  `guia_conceitos_estatisticos.txt`, explicação completa no bloco do
  slide 13.
- **"Como vocês decidiram quais municípios são litorâneos/turísticos?"** →
  guia completo seção 7, segundo item.
- **"A malha/matriz de vizinhança influencia muito o resultado?"** → guia
  completo seção 7, últimos dois itens.

## Dicas gerais

- Leve o PDF como plano B (`slides/apresentacao_final.pdf`) caso o
  computador da apresentação não tenha PowerPoint/LibreOffice.
- Nos slides de mapa (4, 7, 9, 12), aponte fisicamente para a região que
  sustenta a frase-chave — RMSP, Baixada Santista, litoral norte — em vez
  de só ler o texto ao lado.
- Os slides 7, 8 e 13 carregam a maior densidade de termos técnicos — vale
  reler `guia_conceitos_estatisticos.txt` pouco antes de apresentar,
  mesmo que não use tudo na fala.
