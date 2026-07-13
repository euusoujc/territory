# territory — Análise de Dados para Planejamento Territorial (UFABC)

Projeto acadêmico: criminalidade nos 645 municípios de SP × renda e território.
Equipe: João Vitor Oliveira, Julio Cesar Salvino, Lucas Amorim.
Orientação: Prof.ª Flávia da Fonseca Feitosa. Idioma do projeto: português.

## O que o projeto investiga

- Hipótese original (H1): "acontecem mais crimes nas cidades mais pobres?"
  → até agora NÃO confirmada (correlação renda × furto/roubo é POSITIVA).
- Hipótese exploratória (H2): municípios litorâneos/turísticos concentram as
  maiores taxas por 1.000 hab. (população flutuante de verão infla o numerador;
  o denominador é população residente) → evidência acumulada a favor.
- Crimes analisados: roubo (art. 157), furto (art. 155), lesão corporal (art. 129),
  sempre em taxas por 1.000 habitantes.

## Comandos

```bash
Rscript run_espacial.R    # pipeline completo: tabelão validado, correlações,
                          # Moran global + LISA, mapas, relatório, xlsx, GeoDa
```

Pipeline antigo (não espacial): `src/main.R` (caminhos hardcoded de Windows —
não rodar sem ajustar).

## Estrutura

- `src/espacial/00..09_*.R` — etapas do pipeline espacial (R: sf, spdep, geobr)
- `data/tabelao.csv` — base consolidada, 1 linha/município, chave `cod_ibge`
  (reconstruído a partir de docs/ se apagado)
- `data/litoranea_turistica.csv` — dummy litorânea/turística, EDITÁVEL pelo
  grupo (o pipeline não sobrescreve; default = 16 municípios da costa)
- `data/geoda_sp.gpkg` + `data/geoda_sp_shp/` — entrada pronta para o GeoDa
- `docs/guia_geoda.md` — roteiro passo a passo do GeoDa com interpretações
- `outputs/` — relatório (relatorio.md), mapas, correlações, moran_global.csv,
  lisa_clusters.csv, analise_espacial.xlsx (tudo regenerado pelo pipeline)
- `slides/apresentacao.pptx` (editável) e `.html` — apresentação parcial
- `docs/*.xlsx` — bases originais (SSP-SP 2025 tratada, renda Censo 2022)

## Convenções e detalhes não óbvios

- Chave de município: SEMPRE `cod_ibge` (7 dígitos, prefixo 35). Nunca casar
  por nome — a SSP abrevia nomes ("S BARBARA D OESTE"); o resolvedor em
  `src/espacial/01_tabelao.R` já trata isso.
- Ilhabela é ilha: fica sem vizinhos na matriz queen (zero.policy = TRUE).
- Resultados de referência (queen ordem 1, 999 perm.): Moran's I roubo 0,832,
  furto 0,422, lesão 0,181 (todos p = 0,001).
- LISA usa spdep::localmoran_perm (permutação condicional, como o GeoDa) —
  a versão analítica localmoran() subestima clusters Baixo-Baixo nas taxas.
- ggplot2 >= 3.5: usar `show.legend = TRUE` no geom_sf para legendas com
  classes vazias (já aplicado em 05_moran.R).
- Commits em português, prefixos feat:/fix:/refact: (padrão do histórico).
