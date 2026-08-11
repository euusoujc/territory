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
                          # Moran global + LISA, mapas, regressão (OLS, spatial
                          # lag/error, GWR), relatório, xlsx, pacotes p/ GeoDa
```

Não há mais pipeline não espacial no repositório — a primeira tentativa
(`src/main.R`, `analise.R`, `graficos.R`, `script.R`) foi removida por estar
obsoleta; `src/utils.R` (normalização de nomes de município) continua em uso,
importado por `00_config.R`.

## Estrutura

- `src/espacial/00..13_*.R` — etapas do pipeline espacial, nesta ordem (ver
  `run_espacial.R`): config → tabelão → litorânea → correlação → malha →
  Moran/LISA → mapas → relatório → xlsx → pacote GeoDa → regressão OLS →
  regressão espacial global (lag/error) → GWR com litoral e contrafactual →
  GWR enxuto (`tx_furto ~ renda`) empacotado para o GeoDa
- `docs/tabela4709.csv` — população por município (IBGE, Tabela 4709), lida
  por `01_tabelao.R` como universo dos 645 municípios
- `data/tabelao.csv` — base consolidada, 1 linha/município, chave `cod_ibge`
  (reconstruído a partir de docs/ se apagado)
- `data/litoranea_turistica.csv` — dummy litorânea/turística, EDITÁVEL pelo
  grupo (o pipeline não sobrescreve; default = 16 municípios da costa)
- `data/geoda_sp.gpkg` + `data/geoda_sp_shp/` — entrada pronta para o GeoDa;
  `data/geoda_gwr_furto.gpkg` + `_shp/` — saída do GWR enxuto p/ mapear no GeoDa
- `docs/guia_geoda.md`, `docs/guia_regressao_espacial.md`, `docs/guia_gwr_geoda.md`
  — roteiros passo a passo do GeoDa, com números de referência (R × GeoDa)
- `docs/guia_apresentacao.md` — roteiro para apresentar `slides/`: o que
  falar em cada slide e perguntas prováveis da banca
- `outputs/` — relatório (relatorio.md), mapas, correlações, moran_global.csv,
  lisa_clusters.csv, resultados de regressão/GWR, analise_espacial.xlsx
  (tudo regenerado pelo pipeline)
- `paper/relatorio_final_gwr.tex` (+ `.pdf` compilado) — artigo final (modelo
  IEEE, PT-BR): correlação → Moran/LISA → OLS → regressão espacial → GWR
- `slides/` — apresentação da equipe: `build_apresentacao.py` gera
  `apresentacao_final.pptx`; `.pdf` exportado para quem não abre pptx
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
- Contagens de cluster LISA divergem um pouco entre R e GeoDa (ver
  `docs/guia_geoda.md`): para furto, o R (fonte usada no texto do artigo)
  aponta 36 Alto-Alto / 45 Baixo-Baixo; o GeoDa aponta 49 / 67. A geografia
  dos clusters é a mesma; a extensão exata depende da implementação da
  permutação. Sempre citar os números do R, para ficar consistente com o
  Moran's I global (que também vem do R) no mesmo texto.
- ggplot2 >= 3.5: usar `show.legend = TRUE` no geom_sf para legendas com
  classes vazias (já aplicado em 05_moran.R).
- Nos mapas do GWR (`12_gwr_litoral.R`), significância local é mostrada como
  mapa contínuo da estatística t (não mapa binário significativo/não
  significativo) — mais informativo sobre magnitude e não só limiar. O mapa
  de exemplo do kernel de pesos gaussianos (`13_gwr_geoda.R`) foi removido por
  ser redundante com o texto do artigo. Nos dois scripts de GWR, os mapas e
  gráficos de resíduos são gerados por último, depois dos demais mapas do
  modelo (coeficientes, R² local, contrafactual/regime).
- Commits em português, prefixos feat:/fix:/refact: (padrão do histórico).
