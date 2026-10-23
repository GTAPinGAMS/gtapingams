"""Sectoral activity levels at an average trade tax rate of 10 percent:
one panel per data file forensics/figures/<ds>_<C>_sectors.data
(process_results.gms), with sectors on the y-axis.

Each sector row has two halves.  Upper half, benchmark elasticities: the
global model result (GMR) is a black dot on a vertical bar, and the SATE and
SOE results are connected to it by horizontal lines.  Lower half, halved
Armington elasticities sigma^m: the GMR_LS result is a white dot on a dashed
bar, and the SATE_LS result is connected to it.  A SATE modeller who wants to
know how sensitive the global model is to sigma^m compares the step from
SATE (upper half) to SATE_LS (lower half) with the step from GMR to GMR_LS.

All panels share the x-axis range XRANGE.  Sectors listed in SPLIT (US
energy) are drawn in a separate strip below the other sectors, with their own
x-axis at the bottom; the common axis is then labelled at the top.  The zero
line is drawn in solid pink, so that the shift of zero between the two axes
is visible.  Values outside the range of an axis (in practice SOE) are drawn
to the border with an arrow and their value is printed next to it.

Run:  python latex/jgea_new/make_dumbbells.py
Writes latex/jgea_new/figures/dumbbell_<ds>_<C>.tex; the data are embedded
in the .tex files, so rerun after new model runs.
"""

import math
from pathlib import Path

import pandas as pd

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent.parent
FORFIG = ROOT / "forensics" / "figures"
FIGOUT = HERE / "figures"

DS = "g20_macro"
COUNTRIES = ["USA", "CHN", "ZAF", "ARG"]
NAMES = {"USA": "United States", "CHN": "China", "ZAF": "South Africa",
         "ARG": "Argentina"}
SECTORS = ["AGR", "MFR", "SER", "ENR"]         # top to bottom

# reference: column, legend label, bar style, dot style, bar centre offset
REFS = {
    "gmr":    (r"\GMR",   "black, thick",          "mark=*, mark options={fill=black}", 0.22),
    "gmr_ls": (r"\GMRLS", "black, densely dashed", "mark=*, mark options={fill=white}", -0.22),
}
# approximation: column, reference, legend label, line style, marker, offset
APPROX = [
    ("sate",    "gmr",    r"\SATE",   "red, thick",                  "*, mark options={fill=red}",       0.30),
    ("soe",     "gmr",    r"\SOE",    "blue, densely dotted, thick", "triangle*, mark options={fill=blue}", 0.14),
    ("sate_ls", "gmr_ls", r"\SATELS", "red, densely dashed",         "*, mark options={fill=white}",     -0.22),
]
HALF = 0.17          # half height of the reference bars


def nice_step(span):
    raw = span / 4
    e = 10 ** math.floor(math.log10(raw))
    for s in (1, 2, 2.5, 5, 10):
        if s * e >= raw:
            return s * e
    return 10 * e


# Common x-axis range; sectors listed in SPLIT get a separate, wider axis
# below the common one (key: (country, sector), value: (xmin, xmax, step)).
XRANGE = (-2.5, 2.5, 1)
SPLIT = {("USA", "ENR"): (-15, 5, 5)}
HEIGHT = 0.34        # plot area of a full panel (4 sectors), fraction of \textheight


def legend_lines():
    body = []
    for col in ("gmr", "sate", "soe", "gmr_ls", "sate_ls"):
        if col in REFS:
            lab, _, dot, _ = REFS[col]
            body.append(f"\\addlegendimage{{only marks, {dot}}}\\addlegendentry{{{lab}}}")
        else:
            _, _, lab, style, mark, _ = next(a for a in APPROX if a[0] == col)
            mk, *mo = mark.split(",")
            body.append(f"\\addlegendimage{{{style}, mark={mk.strip()}, {','.join(mo).strip()}}}"
                        f"\\addlegendentry{{{lab}}}")
    return body


def sector_lines(df, s, y, xmin, xmax, sep):
    body = [f"% {s}: " + ", ".join(f"{col}={df.loc[s, col]:.4f}"
                                  for col in ("gmr", "gmr_ls", "sate", "sate_ls", "soe"))]
    if sep:
        body.append(f"\\draw[gray!40] (axis cs:{xmin:g},{y + 0.5:.2f}) -- (axis cs:{xmax:g},{y + 0.5:.2f});")
    for ref, (lab, bar, dot, off) in REFS.items():
        g = float(df.loc[s, ref])
        body.append(f"\\draw[{bar}] (axis cs:{g:.4f},{y + off - HALF:.2f}) -- (axis cs:{g:.4f},{y + off + HALF:.2f});")
    for col, ref, lab, style, mark, off in APPROX:
        g = float(df.loc[s, ref])
        v = float(df.loc[s, col])
        yy = y + off
        vv = min(max(v, xmin), xmax)
        clipped = vv != v
        arrow = ", -{Stealth[length=1.6mm]}" if clipped else ""
        body.append(f"\\draw[{style}{arrow}] (axis cs:{g:.4f},{yy:.2f}) -- (axis cs:{vv:.4f},{yy:.2f});")
        if not clipped:
            mk, *mo = mark.split(",")
            body.append(f"\\addplot[only marks, mark={mk.strip()}, {','.join(mo).strip()}, "
                        f"mark size=1.5pt, forget plot] coordinates {{({v:.4f},{yy:.2f})}};")
        else:
            anchor = "west" if v < xmin else "east"
            body.append(f"\\node[font=\\tiny, blue, anchor={anchor}, yshift=-1.2mm] "
                        f"at (axis cs:{vv:.4f},{yy:.2f}) {{{v:.1f}}};")
    for ref, (lab, bar, dot, off) in REFS.items():
        g = float(df.loc[s, ref])
        body.append(f"\\addplot[only marks, {dot}, mark size=1.9pt, forget plot] "
                    f"coordinates {{({g:.4f},{y + off:.2f})}};")
    return body


def axis(df, secs, n, xr, height, opts, body_extra=()):
    """One axis with the sectors secs (y positions n-k as in the full panel)."""
    xmin, xmax, step = xr
    ys = [n - SECTORS.index(s) for s in secs]
    body = list(body_extra)
    for j, (s, y) in enumerate(zip(secs, ys)):
        body += sector_lines(df, s, y, xmin, xmax, sep=j > 0)
    yt = ",".join(str(y) for y in ys)
    ytl = ",".join(r"\texttt{%s}" % s.lower() for s in secs)
    return f"""\\begin{{axis}}[{opts}
  scale only axis, width=0.8\\textwidth, height={height:.4f}\\textheight,
  xmin={xmin:g}, xmax={xmax:g}, ymin={min(ys) - 0.5}, ymax={max(ys) + 0.5},
  ytick={{{yt}}}, yticklabels={{{ytl}}}, y tick style={{draw=none}},
  xtick distance={step:g}, xmajorgrids=true, grid style={{dashed, gray!30}},
  clip=false, label style={{font=\\footnotesize}}, tick label style={{font=\\footnotesize}},
  extra x ticks={{0}}, extra x tick labels={{}}, extra x tick style={{grid=major, grid style={{solid, pink, line width=1pt}}}}]
{chr(10).join(body)}
\\end{{axis}}
"""


def panel(c, legend=None):
    fn = FORFIG / f"{DS}_{c}.data"
    df = pd.read_csv(fn, sep=r"\s+").set_index("sector")
    n = len(SECTORS)
    leg = ""
    if legend:
        leg = (f"legend to name={legend}, legend columns=5, legend cell align=left,\n"
               "  legend style={draw=none, /tikz/every even column/.append style={column sep=0.4cm}},")
    split = [s for s in SECTORS if (c, s) in SPLIT]
    main = [s for s in SECTORS if s not in split]
    xlab = "xlabel={Activity level (\\% change)},"
    lext = legend_lines() if legend else []
    if not split:
        axes = axis(df, main, n, XRANGE, HEIGHT, leg + "\n  " + xlab, lext)
    else:
        # main sectors on top (ticks above), split sectors below (ticks below)
        hs = HEIGHT * len(split) / n
        hm = HEIGHT - hs
        low = axis(df, split, n, SPLIT[(c, split[0])], hs, "name=low, " + xlab)
        top = axis(df, main, n, XRANGE, hm,
                   leg + "\n  at={(low.north west)}, anchor=south west, xticklabel pos=upper,", lext)
        axes = low + top
    txt = f"""% Generated by jgea_new/make_dumbbells.py from {fn.name} -- do not edit by hand.
\\begin{{subfigure}}[t]{{0.48\\textwidth}}
\\centering
\\begin{{tikzpicture}}
{axes}\\end{{tikzpicture}}
\\caption{{{NAMES[c]}.}}
\\end{{subfigure}}
"""
    out = FIGOUT / f"dumbbell_{DS}_{c}.tex"
    out.write_text(txt)
    return out


def main():
    FIGOUT.mkdir(exist_ok=True)
    for c in COUNTRIES:
        panel(c, legend="dumbbell_legend" if c == "USA" else None)
    print("written to", FIGOUT)


if __name__ == "__main__":
    main()
