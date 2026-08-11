# build_apresentacao.py — gera slides/apresentacao_final.pptx (ate 15 slides)
# Ordem: Hipotese e motivacao -> Dados e variaveis -> Desenvolvimento e
# resultados do modelo -> Conclusao. Usa as figuras ja geradas em outputs/
# pelo pipeline (Rscript run_espacial.R).
#
# Uso: python slides/build_apresentacao.py

import os
from pptx import Presentation
from pptx.util import Inches, Pt, Emu
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN, MSO_ANCHOR
from pptx.enum.shapes import MSO_SHAPE
from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT_DIR = os.path.join(ROOT, "outputs")
SLIDES_DIR = os.path.join(ROOT, "slides")

NAVY = RGBColor(0x1F, 0x4E, 0x79)
RED = RGBColor(0xC0, 0x00, 0x00)
ORANGE = RGBColor(0xED, 0x7D, 0x31)
GREY = RGBColor(0x59, 0x59, 0x59)
LIGHT_GREY = RGBColor(0xF2, 0xF2, 0xF2)
WHITE = RGBColor(0xFF, 0xFF, 0xFF)

SW, SH = Inches(13.333), Inches(7.5)

prs = Presentation()
prs.slide_width = SW
prs.slide_height = SH
BLANK = prs.slide_layouts[6]


def add_slide():
    return prs.slides.add_slide(BLANK)


def set_bg(slide, color=WHITE):
    bg = slide.background
    bg.fill.solid()
    bg.fill.fore_color.rgb = color


def textbox(slide, l, t, w, h, text, size=18, color=RGBColor(0x33, 0x33, 0x33),
            bold=False, italic=False, align=PP_ALIGN.LEFT, font="Calibri",
            anchor=MSO_ANCHOR.TOP, line_spacing=1.15):
    tb = slide.shapes.add_textbox(l, t, w, h)
    tf = tb.text_frame
    tf.word_wrap = True
    tf.vertical_anchor = anchor
    lines = text.split("\n")
    for i, line in enumerate(lines):
        p = tf.paragraphs[0] if i == 0 else tf.add_paragraph()
        p.alignment = align
        p.line_spacing = line_spacing
        run = p.add_run()
        run.text = line
        run.font.size = Pt(size)
        run.font.bold = bold
        run.font.italic = italic
        run.font.color.rgb = color
        run.font.name = font
    return tb


def bullets(slide, l, t, w, h, items, size=18, color=RGBColor(0x33, 0x33, 0x33),
            bold_first=False, space_after=10, marker="—  "):
    tb = slide.shapes.add_textbox(l, t, w, h)
    tf = tb.text_frame
    tf.word_wrap = True
    for i, item in enumerate(items):
        p = tf.paragraphs[0] if i == 0 else tf.add_paragraph()
        p.space_after = Pt(space_after)
        p.line_spacing = 1.15
        run = p.add_run()
        run.text = marker + item
        run.font.size = Pt(size)
        run.font.color.rgb = color
        run.font.name = "Calibri"
    return tb


def kicker(slide, text, color=NAVY):
    """Small caps section label top-left."""
    textbox(slide, Inches(0.6), Inches(0.35), Inches(8), Inches(0.4),
            text.upper(), size=13, color=color, bold=True)


def title(slide, text, size=30, top=Inches(0.65), color=RGBColor(0x1A, 0x1A, 0x1A)):
    textbox(slide, Inches(0.6), top, Inches(12.1), Inches(0.9), text,
            size=size, color=color, bold=True)


def rule(slide, top=Inches(1.45), color=NAVY, width=Inches(12.1)):
    line = slide.shapes.add_shape(MSO_SHAPE.RECTANGLE, Inches(0.6), top, width, Pt(2.2))
    line.fill.solid()
    line.fill.fore_color.rgb = color
    line.line.fill.background()
    line.shadow.inherit = False


def footer(slide, n):
    textbox(slide, Inches(0.6), Inches(7.12), Inches(8), Inches(0.3),
            "Furto, Renda e Território — UFABC", size=10, color=GREY)
    textbox(slide, Inches(12.0), Inches(7.12), Inches(0.8), Inches(0.3),
            str(n), size=10, color=GREY, align=PP_ALIGN.RIGHT)


def picture_fit(slide, path, l, t, max_w, max_h):
    """Places an image inside a bounding box, preserving aspect ratio, centered."""
    with Image.open(path) as im:
        iw, ih = im.size
    ar = iw / ih
    box_ar = max_w / max_h
    if ar > box_ar:
        w = max_w
        h = int(w / ar)
    else:
        h = max_h
        w = int(h * ar)
    x = l + int((max_w - w) / 2)
    y = t + int((max_h - h) / 2)
    slide.shapes.add_picture(path, x, y, width=w, height=h)


def img(name):
    return os.path.join(OUT_DIR, name)


def stat_pill(slide, l, t, w, h, value, label, value_color=NAVY):
    box = slide.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, l, t, w, h)
    box.adjustments[0] = 0.08
    box.fill.solid()
    box.fill.fore_color.rgb = LIGHT_GREY
    box.line.fill.background()
    box.shadow.inherit = False
    tf = box.text_frame
    tf.word_wrap = True
    tf.margin_left = Inches(0.15)
    tf.margin_right = Inches(0.15)
    tf.vertical_anchor = MSO_ANCHOR.MIDDLE
    p1 = tf.paragraphs[0]
    p1.alignment = PP_ALIGN.CENTER
    r1 = p1.add_run()
    r1.text = value
    r1.font.size = Pt(26)
    r1.font.bold = True
    r1.font.color.rgb = value_color
    r1.font.name = "Calibri"
    p2 = tf.add_paragraph()
    p2.alignment = PP_ALIGN.CENTER
    r2 = p2.add_run()
    r2.text = label
    r2.font.size = Pt(12)
    r2.font.color.rgb = GREY
    r2.font.name = "Calibri"


# =====================================================================
# 1. TÍTULO
# =====================================================================
s = add_slide(); set_bg(s)
band = s.shapes.add_shape(MSO_SHAPE.RECTANGLE, 0, 0, SW, Inches(0.18))
band.fill.solid(); band.fill.fore_color.rgb = NAVY; band.line.fill.background(); band.shadow.inherit = False

textbox(s, Inches(0.9), Inches(2.35), Inches(11.5), Inches(1.9),
        "Furto, Renda e Território", size=44, color=NAVY, bold=True)
textbox(s, Inches(0.9), Inches(3.35), Inches(11.5), Inches(1.0),
        "Uma análise espacial da criminalidade patrimonial\nnos municípios de São Paulo",
        size=22, color=RGBColor(0x33, 0x33, 0x33))
textbox(s, Inches(0.9), Inches(4.75), Inches(11.5), Inches(0.5),
        "João Vitor Oliveira   •   Julio Cesar Salvino   •   Lucas Amorim", size=16, color=GREY)
textbox(s, Inches(0.9), Inches(5.15), Inches(11.5), Inches(0.9),
        "Centro de Matemática, Computação e Cognição — UFABC\n"
        "Análise de Dados para Planejamento Territorial · Orientação: Prof.ª Flávia da Fonseca Feitosa",
        size=14, color=GREY)

# =====================================================================
# SEÇÃO: HIPÓTESE E MOTIVAÇÃO
# =====================================================================

# 2. Pergunta de pesquisa (H1)
s = add_slide(); set_bg(s)
kicker(s, "Hipótese e motivação")
title(s, "Acontecem mais crimes nas cidades mais pobres?")
rule(s)
bullets(s, Inches(0.6), Inches(1.85), Inches(6.7), Inches(4.6), [
    "Hipótese de senso comum sobre criminalidade (H1): renda baixa → mais crime.",
    "Testada com a taxa de furto (art. 155) por 1.000 hab. nos 645 municípios de SP,\ncontra a renda média per capita (Censo IBGE 2022).",
    "Por que taxa e não contagem? A contagem bruta acompanha o tamanho da\npopulação — qualquer mapa de contagem destaca só as cidades grandes.",
    "Fontes: SSP-SP (ocorrências, 2025) e IBGE (renda e população, Censo 2022).",
], size=17, space_after=16)
stat_pill(s, Inches(7.7), Inches(2.0), Inches(4.9), Inches(1.3), "645", "municípios de São Paulo")
stat_pill(s, Inches(7.7), Inches(3.5), Inches(4.9), Inches(1.3), "3", "crimes analisados:\nroubo · furto · lesão corporal")
stat_pill(s, Inches(7.7), Inches(5.0), Inches(4.9), Inches(1.3), "por 1.000 hab.", "unidade de análise\n(comparável entre municípios)")
footer(s, 2)

# 3. O que os dados mostram / H2
s = add_slide(); set_bg(s)
kicker(s, "Hipótese e motivação")
title(s, "A correlação é positiva — o oposto de H1")
rule(s)
bullets(s, Inches(0.6), Inches(1.85), Inches(6.7), Inches(2.6), [
    "Renda × furto: Pearson = 0,359, Spearman = 0,380 — positivo e significativo.",
    "Renda × roubo: também positivo (0,302 / 0,389).",
    "Só a lesão corporal correlaciona negativamente, e fraco (−0,19).",
], size=17, space_after=14)
textbox(s, Inches(0.6), Inches(4.35), Inches(6.7), Inches(0.5),
        "Isso abriu espaço para uma segunda hipótese, exploratória:", size=17, bold=True, color=NAVY)
box = s.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(0.6), Inches(4.9), Inches(6.7), Inches(1.9))
box.adjustments[0] = 0.06
box.fill.solid(); box.fill.fore_color.rgb = RGBColor(0xFD, 0xEE, 0xE3); box.line.color.rgb = ORANGE; box.line.width = Pt(1)
box.shadow.inherit = False
tf = box.text_frame; tf.word_wrap = True; tf.margin_left = Inches(0.25); tf.margin_right = Inches(0.25)
tf.vertical_anchor = MSO_ANCHOR.MIDDLE
p = tf.paragraphs[0]; r = p.add_run()
r.text = ("H2 — municípios litorâneos/turísticos concentram taxas mais altas: "
          "a população flutuante de verão infla o numerador (ocorrências) sobre um "
          "denominador que mede só a população residente.")
r.font.size = Pt(16); r.font.color.rgb = RGBColor(0x66, 0x33, 0x00); r.font.name = "Calibri"
picture_fit(s, img("mapa_taxa_furto.png"), Inches(7.7), Inches(1.85), Inches(4.9), Inches(4.95))
footer(s, 3)

# =====================================================================
# SEÇÃO: DADOS E VARIÁVEIS
# =====================================================================

# 4. Dados e variáveis
s = add_slide(); set_bg(s)
kicker(s, "Dados e variáveis")
title(s, "Bases, chave de junção e variáveis")
rule(s)
rows = [
    ("Taxa de roubo (art. 157)", "SSP-SP, 2025", "Ocorrências / 1.000 hab."),
    ("Taxa de furto (art. 155)", "SSP-SP, 2025", "Ocorrências / 1.000 hab."),
    ("Taxa de lesão corporal (art. 129)", "SSP-SP, 2025", "Ocorrências / 1.000 hab."),
    ("Renda média", "IBGE, Censo 2022", "Renda per capita em R$"),
    ("População", "IBGE, Tabela 4709", "Denominador das taxas"),
    ("Litorâneo/turístico", "Classificação do grupo", "Dummy (1/0), 16 municípios da costa"),
]
tbl_shape = s.shapes.add_table(len(rows) + 1, 3, Inches(0.6), Inches(1.85), Inches(9.2), Inches(3.4))
tbl = tbl_shape.table
tbl.columns[0].width = Inches(3.6); tbl.columns[1].width = Inches(2.4); tbl.columns[2].width = Inches(3.2)
headers = ["Variável", "Fonte", "Descrição"]
for j, htext in enumerate(headers):
    c = tbl.cell(0, j); c.text = htext
    c.fill.solid(); c.fill.fore_color.rgb = NAVY
    p = c.text_frame.paragraphs[0]; p.runs[0].font.color.rgb = WHITE; p.runs[0].font.bold = True; p.runs[0].font.size = Pt(13)
for i, (a, b, c_) in enumerate(rows, start=1):
    for j, val in enumerate([a, b, c_]):
        cell = tbl.cell(i, j); cell.text = val
        cell.fill.solid(); cell.fill.fore_color.rgb = WHITE if i % 2 else LIGHT_GREY
        p = cell.text_frame.paragraphs[0]; p.runs[0].font.size = Pt(12); p.runs[0].font.color.rgb = RGBColor(0x33, 0x33, 0x33)
bullets(s, Inches(0.6), Inches(5.55), Inches(9.2), Inches(1.4), [
    "Chave de junção: código IBGE de 7 dígitos (nunca o nome — a SSP abrevia,\nex. \"S BARBARA D OESTE\"): correspondência exata → abreviações → distância de edição ≤ 1.",
], size=14, color=GREY)
footer(s, 4)

# 5. Metodologia
s = add_slide(); set_bg(s)
kicker(s, "Dados e variáveis")
title(s, "Metodologia: quatro etapas progressivas")
rule(s)
textbox(s, Inches(0.6), Inches(1.75), Inches(12.1), Inches(0.5),
        "Vizinhança espacial: contiguidade queen de ordem 1, pesos row-standardized "
        "(645 municípios, média 5,50 vizinhos; Ilhabela sem vizinhos)", size=14, italic=True, color=GREY)
steps = [
    ("1", "Correlação e autocorrelação espacial", "Pearson/Spearman; Moran's I global e LISA (permutação condicional, 999 simulações)"),
    ("2", "Regressão linear clássica (OLS)", "taxa ~ renda e taxa ~ renda + litoral, com diagnóstico de resíduos"),
    ("3", "Regressão espacial global", "Testes de Multiplicadores de Lagrange → spatial lag (ρ) vs. spatial error (λ)"),
    ("4", "GWR — Regressão Geograficamente Ponderada", "Regressão local por município, núcleo gaussiano, banda adaptativa (k ≈ 10)"),
]
top = Inches(2.5)
for i, (n, t_, d_) in enumerate(steps):
    y = top + Inches(1.1) * i
    circ = s.shapes.add_shape(MSO_SHAPE.OVAL, Inches(0.6), y, Inches(0.7), Inches(0.7))
    circ.fill.solid(); circ.fill.fore_color.rgb = NAVY; circ.line.fill.background(); circ.shadow.inherit = False
    tf = circ.text_frame; tf.vertical_anchor = MSO_ANCHOR.MIDDLE
    p = tf.paragraphs[0]; p.alignment = PP_ALIGN.CENTER; r = p.add_run(); r.text = n
    r.font.size = Pt(20); r.font.bold = True; r.font.color.rgb = WHITE
    textbox(s, Inches(1.55), y - Inches(0.03), Inches(10.8), Inches(0.4), t_, size=18, bold=True, color=RGBColor(0x1A,0x1A,0x1A))
    textbox(s, Inches(1.55), y + Inches(0.35), Inches(10.8), Inches(0.5), d_, size=13, color=GREY)
footer(s, 5)

# =====================================================================
# SEÇÃO: DESENVOLVIMENTO E RESULTADOS DO MODELO
# =====================================================================

# 6. Autocorrelação espacial
s = add_slide(); set_bg(s)
kicker(s, "Desenvolvimento e resultados")
title(s, "Autocorrelação espacial: Moran's I e LISA")
rule(s)
picture_fit(s, img("mapa_lisa_furto.png"), Inches(0.6), Inches(1.85), Inches(6.9), Inches(5.0))
stat_pill(s, Inches(7.8), Inches(1.9), Inches(4.8), Inches(1.05), "I = 0,832", "Moran's I — taxa de roubo (forte)")
stat_pill(s, Inches(7.8), Inches(3.1), Inches(4.8), Inches(1.05), "I = 0,422", "Moran's I — taxa de furto (moderada)")
stat_pill(s, Inches(7.8), Inches(4.3), Inches(4.8), Inches(1.05), "I = 0,181", "Moran's I — lesão corporal (fraca)")
textbox(s, Inches(7.8), Inches(5.55), Inches(4.8), Inches(1.3),
        "LISA (furto): 36 municípios em cluster Alto-Alto ao longo do litoral "
        "(36% litorâneos/turísticos) e 45 Baixo-Baixo no oeste/centro-sul — "
        "todos significativos a p = 0,001 (999 permutações).",
        size=13, color=GREY)
footer(s, 6)

# 7. OLS clássico
s = add_slide(); set_bg(s)
kicker(s, "Desenvolvimento e resultados")
title(s, "Regressão linear clássica: renda explica pouco sozinha")
rule(s)
picture_fit(s, img("reg_multipla.png"), Inches(0.6), Inches(1.85), Inches(7.0), Inches(5.0))
bullets(s, Inches(7.9), Inches(1.95), Inches(4.7), Inches(3.2), [
    "Simples: taxa = 0,971 + 0,00247·renda   R² = 0,129",
    "Com litoral: taxa = 1,036 + 0,00233·renda + 10,969·litoral   R² = 0,357",
    "Litoral soma ~11 furtos/1.000 hab., equivalente a\n+R$4.700 de renda.",
], size=14, space_after=14)
textbox(s, Inches(7.9), Inches(5.35), Inches(4.7), Inches(1.4),
        "Resíduos não normais e heterocedásticos (Shapiro-Wilk, ncvTest\np<0,001) e Moran's I dos resíduos = 0,38 → estrutura espacial\nnão explicada motiva os modelos espaciais.",
        size=13, color=GREY)
footer(s, 7)

# 8. Regressão espacial global
s = add_slide(); set_bg(s)
kicker(s, "Desenvolvimento e resultados")
title(s, "Regressão espacial global: spatial error vence")
rule(s)
bullets(s, Inches(0.6), Inches(1.9), Inches(6.0), Inches(3.6), [
    "Testes de Lagrange (robustos): LM error significativo (p<0,001),\nLM lag não significativo (p=0,267) → spatial error é o modelo indicado.",
    "λ = 0,588, R² = 0,392, AIC = 3220,6.",
    "Moran's I dos resíduos cai de 0,38 para −0,03 — autocorrelação\nespacial praticamente eliminada.",
], size=16, space_after=16)
box = s.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(0.6), Inches(5.5), Inches(6.0), Inches(1.3))
box.adjustments[0] = 0.08; box.fill.solid(); box.fill.fore_color.rgb = LIGHT_GREY; box.line.fill.background(); box.shadow.inherit = False
tf = box.text_frame; tf.word_wrap = True; tf.vertical_anchor = MSO_ANCHOR.MIDDLE
tf.margin_left = Inches(0.2); tf.margin_right = Inches(0.2)
p = tf.paragraphs[0]; r = p.add_run()
r.text = "Leitura: a dependência espacial está no erro — coerente com uma variável omitida e espacialmente agrupada, como a condição litorânea."
r.font.size = Pt(13); r.font.italic = True; r.font.color.rgb = GREY
picture_fit(s, img("reg_esp_residuos_ols.png"), Inches(6.9), Inches(1.85), Inches(5.8), Inches(5.0))
footer(s, 8)

# 9. GWR — renda
s = add_slide(); set_bg(s)
kicker(s, "Desenvolvimento e resultados")
title(s, "GWR: a relação renda–furto não é fixa no espaço")
rule(s)
picture_fit(s, img("reg_esp_gwr_r2.png"), Inches(0.6), Inches(1.85), Inches(6.4), Inches(5.0))
bullets(s, Inches(7.3), Inches(1.95), Inches(5.4), Inches(3.6), [
    "Banda adaptativa (k ≈ 10 vizinhos) → R² quase-global sobe para 0,458,\nsuperando os modelos globais.",
    "Coeficiente local da renda varia de −0,00216 a +0,00562 pelo estado;\nsignificativo (|t|>1,96) em 72% dos municípios.",
    "R² local varia de 0,05 a 0,64: a renda explica bem o furto no\ncentro-oeste e mal no litoral e na RMSP — onde H2 prevê que\no turismo domina.",
], size=15, space_after=14)
footer(s, 9)

# 10. GWR com litoral — coeficientes e mapa do t
s = add_slide(); set_bg(s)
kicker(s, "Desenvolvimento e resultados")
title(s, "GWR com renda + litoral: coeficientes e significância local")
rule(s)
picture_fit(s, img("gwr_lit_coef_renda.png"), Inches(0.5), Inches(1.8), Inches(3.15), Inches(4.9))
picture_fit(s, img("gwr_lit_coef_litoral.png"), Inches(3.75), Inches(1.8), Inches(3.15), Inches(4.9))
t_renda_path = img("gwr_lit_t_renda.png")
t_litoral_path = img("gwr_lit_t_litoral.png")
if os.path.exists(t_renda_path) and os.path.exists(t_litoral_path):
    picture_fit(s, t_renda_path, Inches(7.0), Inches(1.8), Inches(3.15), Inches(4.9))
    picture_fit(s, t_litoral_path, Inches(10.25), Inches(1.8), Inches(3.15), Inches(4.9))
else:
    textbox(s, Inches(7.0), Inches(3.5), Inches(6.4), Inches(1.5),
            "Mapas de estatística t (renda e litoral) — gerar com\nRscript run_espacial.R para incluir aqui.",
            size=14, italic=True, color=GREY, align=PP_ALIGN.CENTER)
textbox(s, Inches(0.6), Inches(6.75), Inches(12.1), Inches(0.5),
        "Efeito litorâneo varia de 0 a 22 furtos/1.000 hab.; a estatística t mostra magnitude e significância crescendo do noroeste em direção à RMSP e à Baixada Santista.",
        size=13, color=GREY)
footer(s, 10)

# 11. Contrafactual
s = add_slide(); set_bg(s)
kicker(s, "Desenvolvimento e resultados")
title(s, "Cenário contrafactual: isolando o efeito litorâneo")
rule(s)
picture_fit(s, img("gwr_contrafactual_dif.png"), Inches(0.6), Inches(1.85), Inches(6.4), Inches(5.0))
bullets(s, Inches(7.3), Inches(2.0), Inches(5.4), Inches(4.5), [
    "Mantendo os coeficientes locais do GWR, zeramos a variável\nlitoral e recalculamos a predição.",
    "Diferença entre predição real e contrafactual — até 12\nfurtos/1.000 hab. — concentra-se inteiramente na faixa costeira.",
    "Regime separado: no interior, furto cresce com a renda (R²=0,19);\nno litoral, reta praticamente plana e num patamar bem mais alto\n(R²=0,008) — a renda não explica a variação lá dentro.",
], size=15, space_after=16)
footer(s, 11)

# 12. Resíduos (mecanismo)
s = add_slide(); set_bg(s)
kicker(s, "Desenvolvimento e resultados")
title(s, "Resíduos confirmam o mecanismo")
rule(s)
picture_fit(s, img("residuos_litoral_boxplot.png"), Inches(0.6), Inches(1.85), Inches(7.6), Inches(5.0))
bullets(s, Inches(8.5), Inches(2.1), Inches(4.2), Inches(4.5), [
    "Sem litoral: resíduo médio +10,68 (litorâneos) vs. −0,27 (demais).",
    "Com litoral: os dois grupos centram em zero.",
    "Correlação resíduo × litoral cai de 0,51 para 0,00.",
], size=15, space_after=16)
footer(s, 12)

# 13. Comparação final dos modelos
s = add_slide(); set_bg(s)
kicker(s, "Desenvolvimento e resultados")
title(s, "Comparação final dos modelos")
rule(s)
rows = [
    ("OLS", "0,129", "0,357", "+0,228"),
    ("Spatial Error", "0,392", "0,444", "+0,052"),
    ("GWR", "0,458", "0,532", "+0,074"),
]
tbl_shape = s.shapes.add_table(len(rows) + 1, 4, Inches(1.4), Inches(2.2), Inches(7.4), Inches(2.2))
tbl = tbl_shape.table
for c, w in zip(tbl.columns, [Inches(2.4), Inches(1.8), Inches(1.8), Inches(1.4)]):
    c.width = w
headers = ["Modelo", "Sem litoral", "Com litoral", "Δ"]
for j, htext in enumerate(headers):
    c = tbl.cell(0, j); c.text = htext
    c.fill.solid(); c.fill.fore_color.rgb = NAVY
    p = c.text_frame.paragraphs[0]; p.alignment = PP_ALIGN.CENTER
    p.runs[0].font.color.rgb = WHITE; p.runs[0].font.bold = True; p.runs[0].font.size = Pt(15)
for i, row in enumerate(rows, start=1):
    is_best = row[0] == "GWR"
    for j, val in enumerate(row):
        cell = tbl.cell(i, j); cell.text = val
        cell.fill.solid()
        cell.fill.fore_color.rgb = RGBColor(0xE2, 0xEF, 0xDA) if is_best else (WHITE if i % 2 else LIGHT_GREY)
        p = cell.text_frame.paragraphs[0]; p.alignment = PP_ALIGN.CENTER
        p.runs[0].font.size = Pt(16); p.runs[0].font.color.rgb = RGBColor(0x1A, 0x1A, 0x1A)
        p.runs[0].font.bold = is_best
textbox(s, Inches(1.4), Inches(4.7), Inches(10.6), Inches(1.4),
        "O ganho da variável litoral é maior no modelo mais simples (OLS, +0,228) e menor "
        "nos modelos espaciais (+0,052 no spatial error, +0,074 no GWR) — sinal de que os "
        "modelos espaciais já capturavam parte do padrão litorâneo implicitamente.",
        size=15, color=GREY)
stat_pill(s, Inches(9.5), Inches(2.2), Inches(3.0), Inches(2.2), "R² = 0,532", "melhor modelo:\nGWR renda + litoral\n(menor AIC: 3027,4)", value_color=RGBColor(0x2E, 0x7D, 0x32))
footer(s, 13)

# =====================================================================
# SEÇÃO: CONCLUSÃO
# =====================================================================

# 14. Conclusão
s = add_slide(); set_bg(s)
kicker(s, "Conclusão")
title(s, "H1 não se sustenta; H2 explica o padrão observado")
rule(s)
bullets(s, Inches(0.6), Inches(1.9), Inches(12.1), Inches(4.6), [
    "A relação entre renda e taxa de furto é positiva, não negativa — em toda\ncorrelação simples e em todos os modelos de regressão testados.",
    "Três camadas do fenômeno: (i) a renda sozinha deixa estrutura espacial não\nexplicada nos resíduos; (ii) essa estrutura é majoritariamente absorvida pela\ncondição litorânea; (iii) mesmo controlando por ela, a relação renda–furto\nnão é estacionária — forte no interior, quase nula no litoral.",
    "Mecanismo mais consistente com a evidência: população flutuante de verão\ninfla o numerador (ocorrências) sobre um denominador de população residente.",
], size=17, space_after=18)
footer(s, 14)

# 15. Próximos passos / encerramento
s = add_slide(); set_bg(s)
band = s.shapes.add_shape(MSO_SHAPE.RECTANGLE, 0, Inches(7.32), SW, Inches(0.18))
band.fill.solid(); band.fill.fore_color.rgb = NAVY; band.line.fill.background(); band.shadow.inherit = False
kicker(s, "Conclusão")
title(s, "Direção futura e agradecimentos")
rule(s)
bullets(s, Inches(0.6), Inches(1.9), Inches(12.1), Inches(2.2), [
    "Incluir uma medida direta de fluxo turístico (hospedagem, pedágios, dados\nde telefonia) para testar o mecanismo diretamente, hoje capturado só\nindiretamente pela dummy litorânea/turística.",
], size=17, space_after=16)
textbox(s, Inches(0.6), Inches(4.6), Inches(12.1), Inches(1.6),
        "Agradecemos à Prof.ª Flávia da Fonseca Feitosa pela orientação ao longo da "
        "disciplina de Análise de Dados para Planejamento Territorial.",
        size=18, italic=True, color=NAVY)
textbox(s, Inches(0.6), Inches(6.3), Inches(12.1), Inches(0.6),
        "João Vitor Oliveira · Julio Cesar Salvino · Lucas Amorim — UFABC", size=15, color=GREY)

out_path = os.path.join(SLIDES_DIR, "apresentacao_final.pptx")
prs.save(out_path)
print(f"OK: {len(prs.slides)} slides")
print(f"saved: {out_path}")
