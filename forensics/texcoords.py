"""Generate the pgfplots figures <RGN>_bycommodity.tex and <RGN>_bypartner.tex
from the (static, version-controlled) templates <RGN>_bycommodity_git.tex and
<RGN>_bypartner_git.tex, with 'symbolic x coords' and 'xticklabels' set to the
row labels (and their order) in the .data files written by tradetax.gms.
The templates are only read, never written.

Usage (from the forensics directory):
    python texcoords.py                 # all rows of each .data file
    python texcoords.py --top 20        # only the 20 most highly taxed rows
    python texcoords.py --top 20 --dry-run

The .data file of a figure is taken from the first \\addplot table {...} in
the template (only its file name is used; it is looked up, case-insensitively,
in the --datadir folder). All \\addplot references are written as
../forensics/figures/<file> (TEXPATH), i.e. relative to the main document in ./latex/. With --top N the script writes a truncated copy
<name>_topN.data next to the .data file and points every \\addplot table to it
(pgfplots stops with 'input coordinate ... has not been defined' if the table
holds rows that are not in 'symbolic x coords'). Without --top the references
are pointed back to the full .data file.
"""

import argparse
import re
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
# Location of the .data files as seen from the main LaTeX document in ./latex/:
TEXPATH = "../forensics/figures/"
# Templates <RGN>_<kind><TEMPLATE_SUFFIX>.tex are read, <RGN>_<kind>.tex written:
TEMPLATE_SUFFIX = "_git"
TOP_RE = re.compile(r"_top\d+(?=\.data$)", re.I)


def matching_brace(text, i):
    """Index of the '}' closing the '{' at position i."""
    depth = 0
    for k in range(i, len(text)):
        if text[k] == "{":
            depth += 1
        elif text[k] == "}":
            depth -= 1
            if depth == 0:
                return k
    raise ValueError("unbalanced braces")


def replace_key(text, key, value):
    """Replace every 'key={...}' (balanced braces) by 'key={value}'."""
    pat = re.compile(re.escape(key) + r"\s*=\s*\{")
    out, pos, n = [], 0, 0
    while True:
        m = pat.search(text, pos)
        if not m:
            break
        close = matching_brace(text, m.end() - 1)
        out.append(text[pos:m.start()])
        out.append(f"{key}={{{value}}}")
        pos = close + 1
        n += 1
    out.append(text[pos:])
    return "".join(out), n


def wrap(items, per_line, indent):
    lines = [", ".join(items[k:k + per_line]) for k in range(0, len(items), per_line)]
    return (",\n" + indent).join(lines)


def check_ymax(tex, datafile, n, name):
    """Warn if bars exceed ymax (they are cut off at the top of the plot)."""
    rows = [l.split() for l in datafile.read_text().splitlines() if l.strip()][1:n + 1]
    ymax = [float(v) for v in re.findall(r"ymax\s*=\s*([-\d.]+)", tex)]
    if len(ymax) < 2:
        return
    left = max(float(r[1]) + max(float(r[2]), 0) for r in rows)
    right = max(float(r[3]) for r in rows)
    for side, top, lim in (("left", left, ymax[0]), ("right", right, ymax[1])):
        if top > lim:
            print(f"   warning: {name}: {side} axis has values up to {top:.1f} > ymax = {lim:g};"
                  " those bars are cut off")


def read_labels(datafile):
    rows = [l.split() for l in datafile.read_text().splitlines() if l.strip()]
    rows = [r for r in rows if not r[0].startswith("%")]
    return [r[0] for r in rows[1:]]          # first row is the header


def find_datafile(tex, datadir):
    m = re.search(r"\\addplot\+?\s*\[[^\]]*\]\s*table\s*\[[^\]]*\]\s*\{([^}]*)\}", tex)
    if not m:
        raise ValueError("no '\\addplot ... table [...] {file}' found")
    name = TOP_RE.sub("", Path(m.group(1)).name).lower()
    hits = [p for p in datadir.iterdir() if p.name.lower() == name]
    if not hits:
        raise FileNotFoundError(f"{name} not found in {datadir}")
    return hits[0], m.group(1)


def set_ref(tex, newname):
    """Point every \\addplot ... table [...] {...} to TEXPATH/newname."""
    def fix(m):
        return m.group(1) + TEXPATH + newname + m.group(3)
    return re.sub(r"(\\addplot\+?\s*\[[^\]]*\]\s*table\s*\[[^\]]*\]\s*\{)([^}]*)(\})",
                  fix, tex)


MARK = "% set by texcoords.py"
MARK_RE = re.compile(r"^[ \t]*[^\n]*" + re.escape(MARK) + r"[ \t]*\n", re.M)


def set_axis_opts(tex, first, last):
    """Give every axis the same plot box and the same x range.

    The black bars live in a second axis overlaid on the first one, and the
    two axes only line up if
      - 'width' refers to the plot box only ('scale only axis'); otherwise the
        tick and axis labels, which differ between the left and right axis,
        are subtracted from 'width' and the two boxes get different sizes;
      - the x range is fixed (xmin/xmax) and enlarged by the same amount;
        otherwise each axis takes its range from its own data.
    The keys are appended as the LAST entry of each axis' option list, so
    that they override any 'enlarge x limits' etc. set earlier in the list.
    """
    tex = MARK_RE.sub("", tex)
    keys = (f"scale only axis, xmin={first}, xmax={last}, "
            f"enlarge x limits=0.03, {MARK}")
    out, pos = [], 0
    for m in re.finditer(r"\\begin\{axis\}\[", tex):
        if m.start() < pos:
            continue
        k, depth = m.end(), 0
        while True:                      # find the ']' closing the options
            ch = tex[k]
            if ch == "\\":               # skip escaped characters (\%, \{, ...)
                k += 2
                continue
            if ch == "%":                # skip comments
                k = tex.index("\n", k)
            elif ch == "{":
                depth += 1
            elif ch == "}":
                depth -= 1
            elif ch == "]" and depth == 0:
                break
            k += 1
        body = tex[pos:k].rstrip()
        if body.endswith(","):
            body = body[:-1]
        # This was a hack invented by Claude that was needed
        # if ymax (hard coded in the .tex files) was set too restrictively.
        # I leave the code in for emergencies, but comment it out,
        # assuming that ymax is set correctly.
        # out.append(body + ",\n        " + keys + "\n        ")
        out.append(body + ",\n%        " + keys + "\n        ")
        pos = k
    out.append(tex[pos:])
    return "".join(out)


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--figdir", default=HERE / "figures", type=Path,
                    help="folder with the _git.tex templates and the generated .tex files (default: ./figures)")
    ap.add_argument("--datadir", default=None, type=Path,
                    help="folder with the .data files (default: = figdir)")
    ap.add_argument("--top", type=int, default=None,
                    help="keep only the first N rows of each .data file")
    ap.add_argument("--regions", default="USA,CHN,ZAF,ARG")
    ap.add_argument("--dry-run", action="store_true")
    a = ap.parse_args()
    datadir = a.datadir or a.figdir

    for rgn in a.regions.split(","):
        for kind in ("bycommodity", "bypartner"):
            gitfile = a.figdir / f"{rgn}_{kind}{TEMPLATE_SUFFIX}.tex"
            texfile = a.figdir / f"{rgn}_{kind}.tex"
            if not gitfile.exists():
                print(f"skip: template {gitfile} not found")
                continue
            tex = gitfile.read_text()
            datafile, ref = find_datafile(tex, datadir)
            labels = read_labels(datafile)
            plotfile = datafile
            if a.top and a.top < len(labels):
                labels = labels[:a.top]
                plotfile = datafile.with_name(f"{datafile.stem}_top{a.top}.data")
                if not a.dry_run:
                    lines = [l for l in datafile.read_text().splitlines() if l.strip()]
                    plotfile.write_text("\n".join(lines[:a.top + 1]) + "\n")

            coords = wrap(labels, 10, " " * 16)
            ticks = wrap([r"\texttt{%s}" % l.lower().replace("_", r"\_") for l in labels],
                         6, " " * 8)
            new, n1 = replace_key(tex, "symbolic x coords", coords)
            new, n2 = replace_key(new, "xticklabels", ticks)
            new = set_ref(new, plotfile.name)
            new = set_axis_opts(new, labels[0], labels[-1])

            print(f"{gitfile.name} -> {texfile.name}: {len(labels)} labels from {datafile.name}, "
                  f"plotting {plotfile.name} "
                  f"({n1} x coords, {n2} xticklabels replaced)")
            check_ymax(new, datafile, len(labels), texfile.name)
            if TOP_RE.sub("", ref) != TEXPATH + datafile.name:
                print(f"   note: reference '{ref}' changed to '{TEXPATH}{plotfile.name}'")
            if not a.dry_run:
                texfile.write_text(new)


if __name__ == "__main__":
    sys.exit(main())
