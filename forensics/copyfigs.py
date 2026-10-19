"""Copy the master figure figures/g20_macro_USA_W.tex to
figures/<ds>_<cntry>_<item>.tex for every existing data file
figures/<ds>_<cntry>_<item>.data, where <ds> is the dataset of the runs
(e.g. g20_macro or g20), <cntry> a three-letter upper-case region code and
<item> a sector (e.g. AGR, OIL, B_T) or W (welfare). Data files whose item is
'gtap' or 'gtapingams' (e.g. g20_ARG_gtap.data) are ignored.

In each copy, the reference to g20_macro_USA_W.data is replaced by
<ds>_<cntry>_<item>.data. Edit only the master g20_macro_USA_W.tex and rerun
this script to transfer the changes; all other generated .tex files are
overwritten.

Besides the .data reference, the legend name g20_macro_USA_W_legend is
renamed to <ds>_<cntry>_<item>_legend, because LaTeX needs a unique
name per figure (otherwise all \\ref{...} would show the same legend).
In \\caption{...} the country code USA is replaced by the country name from
CAPTION_NAMES, or by <cntry> if it is not listed there (e.g.
\\caption{USA.} -> \\caption{China.}); the item is not part of the caption.
The benchmark dot (\\node[circle,...] at (axis cs:<x>,0)) is moved to the
benchmark average trade tax rate of <cntry> in dataset <ds>, read from the
'averate' display in the tgrid listings output/<ds>/*/*/<cntry>.lst (the same
value in all runs of a country and dataset; a warning is printed if they
differ or none is found). Everything else (ymin/ymax, comments) is copied
unchanged.

Usage (from the forensics directory):   python copyfigs.py [--dry-run]
"""

import re
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
FIGDIR = HERE / "figures"
OUTDIR = HERE / "output"               # tgrid listings: output/<ds>/<version>/<mdl>/<cntry>.lst
MASTER_DS = "g20_macro"
MASTER_CNTRY = "USA"
MASTER = f"{MASTER_DS}_{MASTER_CNTRY}_W"
# Items (last part of the file name) that are not figures of this kind:
IGNORE_ITEMS = {"gtap", "gtapingams"}
# <ds>_<CNTRY>_<item>.data; <ds> is matched lazily, so that g20_macro_USA_W
# yields ds=g20_macro and g20_ARG_B_T yields ds=g20, item=B_T:
NAME_RE = re.compile(r"^(?P<ds>.+?)_(?P<cntry>[A-Z]{3})_(?P<item>.+)\.data$")
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


AVERATE_RE = re.compile(r"PARAMETER averate\s*=\s*([-+0-9.Ee]+)")
DOT_RE = re.compile(r"(\\node\[circle[^\]]*\]\s*at\s*\(axis cs:)\s*[-+0-9.Ee]+\s*,")
DOTNOTE_RE = re.compile(r"(average trade tax rate of )\w+( in )[\w]+(, [^:]*: )[-+0-9.Ee]+%")

_rates = {}


def benchmark_rate(ds, cntry):
    """Benchmark average trade tax rate of cntry in dataset ds from the tgrid
    listings output/<ds>/*/*/<cntry>.lst (cached)."""
    if (ds, cntry) in _rates:
        return _rates[ds, cntry]
    vals = {}
    for lst in (OUTDIR / ds).glob(f"*/*/{cntry}.lst"):
        m = AVERATE_RE.search(lst.read_text(errors="ignore"))
        if m:
            vals[lst] = float(m.group(1))
    rate = None
    if not vals:
        print(f"   warning: no averate for {cntry} in {OUTDIR / ds}; dot left unchanged")
    else:
        v = sorted(set(round(x, 3) for x in vals.values()))
        if len(v) > 1:
            print(f"   warning: averate for {cntry} ({ds}) differs between runs: {v}; using {v[0]}")
        rate = v[0]
    _rates[ds, cntry] = rate
    return rate


def set_dot(tex, ds, cntry, rate):
    if rate is None:
        return tex
    new, n = DOT_RE.subn(lambda m: f"{m.group(1)}{rate:g},", tex)
    if n == 0:
        print("   warning: no benchmark dot (\\node[circle...] at (axis cs:x,0)) found")
    return DOTNOTE_RE.sub(lambda m: f"{m.group(1)}{cntry}{m.group(2)}{ds}{m.group(3)}{rate:g}%", new)


def main():
    dry = "--dry-run" in sys.argv
    master = FIGDIR / f"{MASTER}.tex"
    tex = master.read_text()
    if f"{MASTER}.data" not in tex:
        sys.exit(f"{master.name} does not reference {MASTER}.data")

    # Check the master's own dot (the master itself is never changed):
    usa = benchmark_rate(MASTER_DS, MASTER_CNTRY)
    m0 = re.search(r"\\node\[circle[^\]]*\]\s*at\s*\(axis cs:\s*([-+0-9.Ee]+)", tex)
    if usa is not None and m0 and abs(float(m0.group(1)) - usa) > 0.005:
        print(f"   note: dot in {master.name} is at {m0.group(1)}, "
              f"benchmark rate of {MASTER_CNTRY} is {usa:g}")

    n = 0
    for data in sorted(FIGDIR.glob("*_*_*.data")):
        m = NAME_RE.match(data.name)
        if not m or data.stem == MASTER or m.group("item").lower() in IGNORE_ITEMS:
            continue
        ds, cntry, stem = m.group("ds"), m.group("cntry"), data.stem
        new = (tex.replace(f"{MASTER}.data", f"{stem}.data")
                  .replace(f"{MASTER}_legend", f"{stem}_legend"))
        new = set_caption(new, CAPTION_NAMES.get(cntry, cntry))
        rate = benchmark_rate(ds, cntry)
        new = set_dot(new, ds, cntry, rate)
        out = FIGDIR / f"{stem}.tex"
        print(f"{master.name} -> {out.name}   (dot at {rate})")
        if not dry:
            out.write_text(new)
        n += 1
    print(f"{n} files {'would be ' if dry else ''}written")


if __name__ == "__main__":
    main()
