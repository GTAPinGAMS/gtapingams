"""Generate the pgfplots figure files included by ../jgea_new.tex.

Run from anywhere:   python latex/jgea_new/make_figs.py

Inputs (paths relative to the repository root):
  forensics/figures/g20_macro_<C>_<item>.data   simulation results
                                               (process_results.gms)
  forensics/figures/<C>_{commodity,txtm}_m.data
                                               benchmark trade taxes, written by
                                               forensics/tradetax.gms (ds=g20) with
                                               rcalc /usa, chn, zaf, arg/; read
                                               directly by the tariff figures
  forensics/output/g20_macro/gtap/gmr/<C>.lst  benchmark average trade
                                               tax rates ('averate')
Outputs:
  latex/jgea_new/figures/*.tex                 one file per (sub)figure
                                               (sectoral results: make_dumbbells.py)

All paths written into the .tex files are relative to ./latex/, where the
master document jgea_new.tex lives.
"""

import math
import re
from pathlib import Path

import pandas as pd

HERE = Path(__file__).resolve().parent            # latex/jgea_new
ROOT = HERE.parent.parent                         # repository root
FIGOUT = HERE / "figures"
FORFIG = ROOT / "forensics" / "figures"
TEX_FORFIG = "../forensics/figures/"              # as seen from ./latex/

COUNTRIES = ["USA", "CHN", "ZAF", "ARG"]
NAMES = {"USA": "United States", "CHN": "China", "ZAF": "South Africa",
         "ARG": "Argentina"}
SECTORS = ["AGR", "MFR", "SER", "ENR"]
SECNAMES = {"AGR": "Agriculture", "MFR": "Manufacturing", "SER": "Services",
            "ENR": "Energy", "W": "Welfare"}
VERSIONS = {"gtap": r"\textsc{gtap} version", "gtapingams": r"\textsc{gtapingams} version"}
TOP = 23

# Closures shown: column suffix, legend text, line style
CLOSURES = [
    ("gmr",    r"\GMR", "color=black, solid, thick"),
    ("gmr_ls", r"\GMRLS", "color=black, dashed"),
    ("soe",    r"\SOE", "color=blue, dotted, thick"),
    ("sate",    r"\SATE", "color=red, solid, thick"),
]
DEFAULT_AVERATE = {"USA": 2.238, "CHN": 2.333, "ZAF": 4.830, "ARG": 7.213}


def averate(c):
    lst = ROOT / "forensics" / "output" / "g20_macro" / "gtap" / "gmr" / f"{c}.lst"
    try:
        m = re.search(r"PARAMETER averate\s*=\s*([-+0-9.Ee]+)",
                      lst.read_text(errors="ignore"))
        if m:
            return float(m.group(1))
    except OSError:
        pass
    return DEFAULT_AVERATE[c]


def nice_up(x, steps=(1, 2, 2.5, 5, 10)):
    """Smallest 'nice' number >= x."""
    if x <= 0:
        return 0.0
    e = 10 ** math.floor(math.log10(x))
    for s in steps:
        if s * e >= x - 1e-12:
            return s * e
    return 10 * e


def yrange(values, pad=0.08):
    lo, hi = min(values), max(values)
    span = max(hi - lo, 1e-3)
    lo, hi = lo - pad * span, hi + pad * span
    step = nice_up(span / 5)
    return math.floor(lo / step) * step, math.ceil(hi / step) * step, step


def fmt(x):
    return f"{x:.6g}"


# ---------------------------------------------------------------------------
#  Benchmark trade taxes (bars)
# ---------------------------------------------------------------------------

def tariff_fig(c, kind, legend):
    """Write a figure that reads forensics/figures/<C>_<kind>_m.data
    (forensics/tradetax.gms, sorted by tm_m+tx_m) directly, so that the
    paper always shows the most recent data.  Columns: 0 label, 1 tm_m,
    2 tx_m, 3 tm$, 4 tmrev.  Commodity figures show the first TOP rows.
    x positions are the row indices, tick labels are read from the table,
    and both axes are scaled automatically."""
    key = "good" if kind == "commodity" else "region"
    ref = TEX_FORFIG + f"{c}_{kind}_m.data"
    tbl = f"\\tariff{kind}{c}"
    skip = f"skip coords between index={{{TOP}}}{{10000}}," if kind == "commodity" else ""
    xl = "Commodity" if kind == "commodity" else "Trading partner"
    leg1 = f"legend to name = {legend}_aux," if legend else ""
    leg2 = (f"legend to name = {legend}, legend style={{draw=none}}, "
            "legend cell align=left, legend columns=3,") if legend else ""
    entries1 = ("\\label{%s_tm}\\addlegendentry{Import tariff rate (left axis)}" % legend,
                "\\label{%s_tx}\\addlegendentry{Export tax rate (left axis)}" % legend) \
        if legend else ("", "")
    entries2 = ("\\addlegendimage{/pgfplots/refstyle=%s_tm}\\addlegendentry{Import tariff rate (left axis)}\n"
                "\\addlegendimage{/pgfplots/refstyle=%s_tx}\\addlegendentry{Export tax rate (left axis)}\n"
                % (legend, legend)) if legend else ""
    entry3 = "\\addlegendentry{Tariff revenue (right axis)}" if legend else ""
    # Both axes plot the same rows at x = row index, with the same plot box
    # and the same x enlargement, so that the bars line up.
    common = ("scale only axis, width=0.75\\textwidth, height=0.24\\textheight,\n"
              "  bar width=0.12cm, enlarge x limits=0.03, enlarge y limits={upper, value=0.05},"
              + (f"\n  {skip}" if skip else ""))
    txt = f"""% Generated by jgea_new/make_figs.py -- do not edit by hand.
% Reads {ref} (written by forensics/tradetax.gms).
\\pgfplotstableread{{{ref}}}{tbl}
\\begin{{subfigure}}[b]{{\\textwidth}}
\\centering
\\begin{{tikzpicture}}
\\begin{{axis}}[ybar stacked, {leg1}
  {common}
  xtick=data, ymin=0,
  xticklabel={{\\pgfplotstablegetelem{{\\ticknum}}{{{key}}}\\of{tbl}%
    \\edef\\tariffticklabel{{\\detokenize\\expandafter{{\\pgfplotsretval}}}}%
    \\texttt{{\\lowercase\\expandafter{{\\tariffticklabel}}}}}},
  x tick label style={{anchor=east, rotate=90, font=\\scriptsize}},
  major x tick style=transparent,
  axis x line*=bottom, axis y line*=left, ymajorgrids=true,
  xlabel={{{xl}}}, ylabel={{Tax rate (\\%)}}]
\\addplot+[ybar, fill=blue!30, draw=blue] table [x expr=\\coordindex, y index=1] {tbl};
{entries1[0]}
\\addplot+[ybar, fill=red!30, draw=red] table [x expr=\\coordindex, y index=2] {tbl};
{entries1[1]}
\\end{{axis}}
\\begin{{axis}}[ybar stacked, {leg2}
  {common}
  ymin=0,
  bar width=0.03cm,
  axis y line*=right, axis x line=none,
  ylabel={{Tariff revenue (bn USD)}}, ylabel near ticks]
{entries2}\\addplot+[ybar, fill=black, draw=black] table [x expr=\\coordindex, y index=4] {tbl};
{entry3}
\\end{{axis}}
\\end{{tikzpicture}}
\\caption{{{NAMES[c]}.}}
\\end{{subfigure}}
"""
    (FIGOUT / f"tariff_{kind}_{c}.tex").write_text(txt)


# ---------------------------------------------------------------------------
#  Simulation results (lines)
# ---------------------------------------------------------------------------

def result_panel(c, item, version, legend=None, width="0.48\\textwidth",
                 height="0.26\\textheight", caption=None, closures=CLOSURES):
    fn = f"g20_macro_{c}_{item}.data"
    df = pd.read_csv(FORFIG / fn, sep=r"\s+")
    cols = [f"{version}-{m}" for m, _, _ in closures]
    core = [f"{version}-{m}" for m, _, _ in closures if m != "soe"]
    vals = pd.concat([df[k] for k in core]).dropna().tolist() + [0.0]
    soe = df[f"{version}-soe"].dropna()
    lo0, hi0 = min(vals), max(vals)
    span = max(hi0 - lo0, 1e-3)
    if soe.min() >= lo0 - 0.5 * span and soe.max() <= hi0 + 0.5 * span:
        vals += soe.tolist()                      # SOE fits: show it fully
    ymin, ymax, step = yrange(vals)
    ref = TEX_FORFIG + fn
    leg = ""
    if legend:
        leg = (f"legend to name={legend}, legend columns={len(closures)},\n"
               "  legend style={draw=none, /tikz/every even column/.append style={column sep=0.5cm}},\n"
               "  legend cell align=left,")
    plots = "\n".join(
        f"\\addplot[{style}] table [x=tlvl, y={version}-{m}] {{{ref}}};"
        + (f"\n\\addlegendentry{{{lab}}}" if legend else "")
        for m, lab, style in closures)
    ylab = "Hicksian EV (\\%)" if item == "W" else "Activity level (\\% change)"
    cap = caption or f"{NAMES[c]}, {VERSIONS[version]}."
    txt = f"""% Generated by jgea_new/make_figs.py -- do not edit by hand.
\\begin{{subfigure}}[t]{{{width}}}
\\centering
\\begin{{tikzpicture}}
\\begin{{axis}}[{leg}
  width=\\textwidth, height={height},
  xlabel={{Average trade tax rate (\\%)}}, ylabel={{{ylab}}},
  grid=major, grid style={{dashed, gray!30}},
  xmin=0, xmax=10, ymin={fmt(ymin)}, ymax={fmt(ymax)}, ytick distance={fmt(step)},
  yticklabel style={{/pgf/number format/fixed}},
  unbounded coords=jump, label style={{font=\\footnotesize}},
  tick label style={{font=\\footnotesize}}]
{plots}
\\node[circle, fill=black, scale=0.4] at (axis cs:{averate(c):.3f},0) {{}};
\\end{{axis}}
\\end{{tikzpicture}}
\\caption{{{cap}}}
\\end{{subfigure}}
"""
    name = f"res_{c}_{item}_{version}.tex"
    (FIGOUT / name).write_text(txt)
    return name


# ---------------------------------------------------------------------------
#  Tables
# ---------------------------------------------------------------------------

def optimum(x, y):
    """Welfare-maximizing tariff level (quadratic interpolation around the
    best grid point) and a flag whether it lies at the border of the grid."""
    y = list(y)
    k = max(range(len(y)), key=lambda j: y[j])
    if 0 < k < len(y) - 1:
        a, b, c = y[k - 1], y[k], y[k + 1]
        den = a - 2 * b + c
        d = 0.5 * (a - c) / den if den else 0.0
        return x[k] + d, False
    return x[k], True


def table_optimum():
    rows = []
    for c in COUNTRIES:
        df = pd.read_csv(FORFIG / f"g20_macro_{c}_W.data", sep=r"\s+")
        x = list(df.tlvl)
        cells = []
        for v in VERSIONS:
            for m, _, _ in CLOSURES:
                t, border = optimum(x, df[f"{v}-{m}"])
                if border and t == x[-1]:
                    cells.append(r"$\geq$10")
                else:
                    cells.append(f"{t:.1f}")
        rows.append(f"{NAMES[c]} & {averate(c):.2f} & " + " & ".join(cells) + r" \\")
    head = " & ".join(lab for _, lab, _ in CLOSURES)
    txt = ("% Generated by jgea_new/make_figs.py -- do not edit by hand.\n"
           r"\begin{tabular}{lr|rrrr|rrrr}" "\n" r"\toprule" "\n"
           r" & Bench- & \multicolumn{4}{c|}{\texttt{gtap} version} & \multicolumn{4}{c}{\texttt{gtapingams} version}\\" "\n"
           r"Region & mark & " + head + " & " + head + r"\\" "\n" r"\midrule" "\n"
           + "\n".join(rows) + "\n" r"\bottomrule" "\n" r"\end{tabular}" "\n")
    (FIGOUT / "tab_optimum.tex").write_text(txt)


def rmsd(df, v, m):
    g = df[f"{v}-gmr"]
    return float(((df[f"{v}-{m}"] - g) ** 2).mean() ** 0.5)


def table_rmsd(items, name):
    rows = []
    for c in COUNTRIES:
        for it in items:
            df = pd.read_csv(FORFIG / f"g20_macro_{c}_{it}.data", sep=r"\s+")
            cells = []
            for v in VERSIONS:
                g = df[f"{v}-gmr"]
                cells.append(f"{g.max() - g.min():.2f}")
                vals = {m: rmsd(df, v, m) for m in ("gmr_ls", "soe", "sate")}
                for m in ("gmr_ls", "soe", "sate"):
                    s = f"{vals[m]:.2f}" if vals[m] < 100 else f"{vals[m]:.0f}"
                    if m == "sate" and vals["sate"] <= vals["gmr_ls"]:
                        s = r"\textbf{" + s + "}"
                    cells.append(s)
            lab = NAMES[c] if it == items[0] else ""
            rows.append(f"{lab} & {SECNAMES[it]} & " + " & ".join(cells) + r" \\")
        rows.append(r"\addlinespace")
    txt = ("% Generated by jgea_new/make_figs.py -- do not edit by hand.\n"
           r"\begin{tabular}{ll|rrrr|rrrr}" "\n" r"\toprule" "\n"
           r" & & \multicolumn{4}{c|}{\texttt{gtap} version} & \multicolumn{4}{c}{\texttt{gtapingams} version}\\" "\n"
           r" & & Range & \multicolumn{3}{c|}{RMSD from \GMR} & Range & \multicolumn{3}{c}{RMSD from \GMR}\\" "\n"
           r"Region & Item & \GMR & \GMRLS & \SOE & \SATE & \GMR & \GMRLS & \SOE & \SATE \\" "\n"
           r"\midrule" "\n" + "\n".join(rows[:-1]) + "\n" r"\bottomrule" "\n" r"\end{tabular}" "\n")
    (FIGOUT / name).write_text(txt)


def main():
    FIGOUT.mkdir(exist_ok=True)
    for c in COUNTRIES:
        tariff_fig(c, "commodity", "tariffcom_legend" if c == "USA" else None)
        tariff_fig(c, "txtm", "tariffpar_legend" if c == "USA" else None)
    for c in COUNTRIES:
        for v in VERSIONS:
            result_panel(c, "W", v, legend="welfare_legend" if (c, v) == ("USA", "gtap") else None)
    table_optimum()
    table_rmsd(["W"], "tab_rmsd_W.tex")
    print("figures written to", FIGOUT)


if __name__ == "__main__":
    main()
