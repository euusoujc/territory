#!/usr/bin/env python3
# Monta docs/regressao_espacial.pdf embutindo os prints. Para trocar por prints
# reais do GeoDa: substitua os PNGs em docs/geoda_prints_regressao/ (mesmos
# nomes) e rode este script de novo.
import base64, pathlib, re, subprocess

REPO = pathlib.Path("/Users/lucasamorim/Documents/GitHub/territory")
SCRATCH = pathlib.Path("/private/tmp/claude-501/-Users-lucasamorim-Documents-GitHub-territory/4892db44-cdb2-4055-a199-bd1c0a4d9c0f/scratchpad")
SRCS = [REPO / "outputs", REPO / "docs" / "geoda_prints_regressao"]
CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

html = (SCRATCH / "relatorio_re_completo.html").read_text()
for name in set(re.findall(r"%%([\w]+)%%", html)):
    path = next((d / f"{name}.png" for d in SRCS if (d / f"{name}.png").exists()), None)
    if path is None:
        raise FileNotFoundError(name)
    b64 = base64.b64encode(path.read_bytes()).decode()
    html = html.replace(f"%%{name}%%", f"data:image/png;base64,{b64}")

prose = re.sub(r"<style.*?</style>", "", html, flags=re.S)
assert "%%" not in html and "—" not in prose, "placeholder ou travessao restante"
final = SCRATCH / "relatorio_re_completo_final.html"
final.write_text(html)
subprocess.run([CHROME, "--headless", "--no-pdf-header-footer",
                f"--print-to-pdf={REPO/'docs'/'regressao_espacial.pdf'}",
                f"file://{final}"], check=True, stderr=subprocess.DEVNULL)
print("PDF:", (REPO / "docs" / "regressao_espacial.pdf").stat().st_size, "bytes")
