"""Copy the master figure figures/g20_macro_USA_W.tex to
figures/g20_macro_<cntry>_<item>.tex for every existing data file
figures/g20_macro_<cntry>_<item>.data, replacing in each copy the reference
to g20_macro_USA_W.data by g20_macro_<cntry>_<item>.data.

Edit only the master g20_macro_USA_W.tex and rerun this script to transfer
the changes; all other g20_macro_*.tex files are overwritten.

Besides the .data reference, the legend name g20_macro_USA_W_legend is
renamed to g20_macro_<cntry>_<item>_legend, because LaTeX needs a unique
name per figure (otherwise all \\ref{...} would show the same legend).
In \caption{...} the country code USA is replaced by the country name from
CAPTION_NAMES, or by <cntry> if it is not listed there (e.g.
\caption{USA.} -> \caption{China.}); the item is not part of the caption.
The benchmark dot (\node[circle,...] at (axis cs:<x>,0)) is moved to the
benchmark average trade tax rate of <cntry>, read from the 'averate' display
in the tgrid listings output/<PREFIX>/*/*/<cntry>.lst (the same value in all
runs of a country; a warning is printed if they differ or none is found).
Everything else (ymin/ymax, comments) is copied unchanged.

Usage (from the forensics directory):   python copyfigs.py [--dry-run]
"""

import re
import sys
from pathlib import Path

FIGDIR = Path(__file__).resolve().parent / "figures"
PREFIX = "g20_macro"
MASTER_CNTRY = "USA"
MASTER = f"{PREFIX}_{MASTER_CNTRY}_W"
# Names used in captions instead of the country code (codes not listed here
# are used as they are):
CAPTION_NAMES = {
    "CHN": "China",
    "ZAF": "South Africa",
    "ALG": "Algeria",
    "ARG": "Argentina",
}
CAPTION_RE = re.compile(r"\\caption\{[^}]*\}")


def set_caption(tex, cntry):
    """Replace the master country code inside every \\caption{...}."""
    return CAPTION_RE.sub(lambda m: re.sub(rf"\b{MASTER_CNTRY}\b", cntry, m.group(0)), tex)


OUTDIR = Path(__file__).resolve().parent / "output" / PREFIX
AVERATE_RE = re.compile(r"PARAMETER averate\s*=\s*([-+0-9.Ee]+)")
DOT_RE = re.compile(r"(\\node\[circle[^\]]*\]\s*at\s*\(axis cs:)\s*[-+0-9.Ee]+\s*,")
DOTNOTE_RE = re.compile(r"(average trade tax rate of )\w+( in [^:]*: )[-+0-9.Ee]+%")


def benchmark_rate(cntry):
    """Benchmark average trade tax rate of cntry from the tgrid listings."""
    vals = {}
    for lst in OUTDIR.glob(f"*/*/{cntry}.lst"):
        m = AVERATE_RE.search(lst.read_text(errors="ignore"))
        if m:
            vals[lst] = float(m.group(1))
    if not vals:
        print(f"   warning: no averate for {cntry} in {OUTDIR}; dot left unchanged")
        return None
    v = sorted(set(round(x, 3) for x in vals.values()))
    if len(v) > 1:
        print(f"   warning: averate for {cntry} differs between runs: {v}; using {v[0]}")
    return v[0]


def set_dot(tex, cntry, rate):
    if rate is None:
        return tex
    new, n = DOT_RE.subn(lambda m: f"{m.group(1)}{rate:g},", tex)
    if n == 0:
        print("   warning: no benchmark dot (\\node[circle...] at (axis cs:x,0)) found")
    return DOTNOTE_RE.sub(lambda m: f"{m.group(1)}{cntry}{m.group(2)}{rate:g}%", new)


def main():
    dry = "--dry-run" in sys.argv
    master = FIGDIR / f"{MASTER}.tex"
    tex = master.read_text()
    if f"{MASTER}.data" not in tex:
        sys.exit(f"{master.name} does not reference {MASTER}.data")

    # Check the master's own dot (the master itself is never changed):
    usa = benchmark_rate(MASTER_CNTRY)
    m0 = re.search(r"\\node\[circle[^\]]*\]\s*at\s*\(axis cs:\s*([-+0-9.Ee]+)", tex)
    if usa is not None and m0 and abs(float(m0.group(1)) - usa) > 0.005:
        print(f"   note: dot in {master.name} is at {m0.group(1)}, "
              f"benchmark rate of {MASTER_CNTRY} is {usa:g}")
    rates = {}

    pat = re.compile(rf"^{PREFIX}_([A-Za-z0-9]+)_([A-Za-z0-9]+)\.data$")
    n = 0
    for data in sorted(FIGDIR.glob(f"{PREFIX}_*_*.data")):
        m = pat.match(data.name)
        if not m or data.stem == MASTER:
            continue
        stem = data.stem
        new = (tex.replace(f"{MASTER}.data", f"{stem}.data")
                  .replace(f"{MASTER}_legend", f"{stem}_legend"))
        new = set_caption(new, CAPTION_NAMES.get(m.group(1), m.group(1)))
        cntry = m.group(1)
        if cntry not in rates:
            rates[cntry] = benchmark_rate(cntry)
        new = set_dot(new, cntry, rates[cntry])
        out = FIGDIR / f"{stem}.tex"
        print(f"{master.name} -> {out.name}   (dot at {rates[cntry]})")
        if not dry:
            out.write_text(new)
        n += 1
    print(f"{n} files {'would be ' if dry else ''}written")


if __name__ == "__main__":
    main()
