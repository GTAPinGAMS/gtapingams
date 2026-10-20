import os
from doit.tools import run_once
# This provides shutil.copy(source,destination):
import shutil


# Set some command flags as strings
code = "../code/"
nd = "5"
yr = "23"


def task_folders():
    """Make sure all necessary directories exist."""
    def make_some_dirs():
        dirlist = ['gtapdata',
                   'build/listings',
                   f'gamsdata/20{yr}',
                   'forensics/figures'
                   ]
        for dir in dirlist:
            if not os.access(dir, os.F_OK):
                print(f"Creating directory {dir}")
                os.mkdir(dir)

    return {
        'actions': [make_some_dirs, ],
        'verbosity': 2,
        'uptodate': [run_once],
    }


def task_instruct():
    """Provide some instructions for getting GTAP source data."""
    def ask_for_GTAP():
        input("Please provide file gtapdata/GDX12a_AY16994.zip.\n" +
              "It can be purchased from\n" +
              "https://www.gtap.agecon.purdue.edu\n" +
              "Then press ENTER.\n\n"
              )

    # If both run_once and targets are there:
    # Task is only uptodate if BOTH targets are there AND it has been ran once
    return {
        'actions': [ask_for_GTAP, ],
        'targets': ['gtapdata/GDX12a_AY16994.zip'],
        'verbosity': 2,
        'uptodate': [run_once],
    }


def task_readgdx():
    """Run code/readgdx.gms"""
    return {
        'file_dep': [
            'code/readgdx.gms',
            'gtapdata/GDX12a_AY16994.zip',
        ],
        'targets': [
            f'build/listings/readgdx_{yr}.lst',
            f'gamsdata/20{yr}/gsd.gdx',
        ],
        'verbosity': 2,
        'actions': [
            "cd build" +
            f" & gams {code}readgdx --yr={yr} o=listings/readgdx_{yr}.lst" +
            " & cd .."
        ],
    }


def task_filter():
    """Run code/filter.gms"""
    return {
        'file_dep': [
            'code/filter.gms',
            'code/gtap12data.gms',
            f'gamsdata/20{yr}/gsd.gdx',
        ],
        'targets': [
            f'build/listings/filter{yr}_{nd}.lst',
            f'gamsdata/20{yr}/gsd_{nd}.gdx',
        ],
        'verbosity': 2,
        'actions': [
            "cd build" +
            f" & gams {code}filter --yr={yr} --nd={nd}" +
            f"   o=listings/filter{yr}_{nd}.lst" +
            " & cd .."
        ],
    }


def task_build():
    """Run the build script build/build.gms,
    which creates different aggregations of gsd.gdx
    """

    agg_levels = [
        'gtap12ingams',
        'g20_macro',
        'g20_iea',
        'g20',
    ]

    def run_build():
        # Create the GTAP12 dataset from gsd_{nd}.gdx
        os.system(
            "cd build" +
            f" & gams ../code/gtapaggr --yr={yr} --source=gsd_{nd}" +
            f"  --target=gtap12ingams o=listings/gtap12ingams_{yr}.lst" +
            " & cd .."
        )
        os.system(
            "cd build" +
            f" & gams ../code/cdecalib --yr={yr} --ds=gtap12ingams" +
            f" o=listings/cde_gtap12ingams_{yr}.lst" +
            " & cd .."
        )

        # Make aggregations from gtap12ingams.gdx
        for agg in agg_levels:
            os.system(
                "cd build" +
                f" & gams ../code/gtapaggr --yr={yr} --source=gtap12ingams" +
                f" --target={agg} o=listings/{agg}_{yr}.lst" +
                " & cd .."
            )
            os.system(
                "cd build" +
                f" & gams ../code/cdecalib --yr={yr} --ds={agg}" +
                f" o=listings/cde_{agg}_{yr}.lst" +
                " & cd .."
            )

    dependencies = [
            'code/gtapaggr.gms',
            'code/cdecalib.gms',
            'code/gtap12data.gms',
            'code/aggr.gms',
            'code/checkset.gms',
            'code/chktarget.gms',
            'code/domain.gms',
            f'gamsdata/20{yr}/gsd_{nd}.gdx',
    ]
    dependencies += [f'defines/{agg}.map' for agg in agg_levels]
    targets = [f'build/listings/{agg}_{yr}.lst' for agg in agg_levels]
    targets += [f'build/listings/cde_{agg}_{yr}.lst' for agg in agg_levels]
    targets += [f'gamsdata/20{yr}/{agg}.gdx' for agg in agg_levels]

    return {
        'file_dep': dependencies,
        'targets': targets,
        'verbosity': 2,
        'actions': [run_build],
    }


def task_test():
    """Run the testing script build/test.gms"""
    run_these = [
        'bmkchk',
        'mge_mcp',
        'mcp_mge',
        'cdechk',
    ]

    def run_tests():
        for run in run_these:
            os.system(f"cd build & gams test --run={run} & cd ..")

    return {
        'file_dep': [
            'build/test.gms',
            'build/bmkchk.gms',
            'build/cdechk.gms',
            'build/mcpmge.gms',
            'code/mge.gms',
            'code/mcp.gms',
            'code/loadmdl.gms',
            'code/gdpcalc.gms',
            f'gamsdata/20{yr}/g20_macro.gdx',
            f'gamsdata/20{yr}/g20.gdx',
        ],
        'targets': [
            'build/GTAP12.GEN',
            'build/GTAP12_p.gdx',
            'build/listings/bmkchk_mcp.lst',
            'build/listings/bmkchk_mge.lst',
            'build/listings/cdechk.lst',
            'build/listings/mcp1_g20.lst',
            'build/listings/mcp2_g20.lst',
            'build/listings/mge1_g20.lst',
            'build/listings/mge2_g20.lst',
            'build/test.lst',
        ],
        'verbosity': 2,
        'actions': [
            run_tests,
        ],
    }


ds = 'g20_macro'


def task_grid():
    """Run all model runs necessary for paper reconstruction"""
    dependencies = [
        'forensics/ssasolve.gms',
        'forensics/tgrid.gms',
        ]
    targets = [
        'forensics/USA_soe_g20.data',
        'forensics/CHN_soe_g20.data',
        'forensics/USA_gmr_g20.data',
        'forensics/CHN_gmr_g20.data',
        f'forensics/output/{ds}/gtap/gmr/CHN.gdx',
        f'forensics/output/{ds}/gtap/gmr_ls/CHN.gdx',
        f'forensics/output/{ds}/gtap/soe/CHN.gdx',
        f'forensics/output/{ds}/gtap/sate/CHN.gdx',
        f'forensics/output/{ds}/gtap/sate2/CHN.gdx',
        # lst files in output/g20/
    ]

    return {
        'file_dep': dependencies,
        'targets': targets,
        'verbosity': 2,
        'actions': [
            f"cd forensics & gams ssasolve --ds={ds} & cd .."
        ],

    }


def task_merge():
    """Run all model runs necessary for paper reconstruction"""
    dependencies = [
        'forensics/ssamerge.gms',
        'forensics/results_git.xlsx',
        f'forensics/output/{ds}/gtap/gmr/CHN.gdx',
        f'forensics/output/{ds}/gtap/gmr_ls/CHN.gdx',
        f'forensics/output/{ds}/gtap/soe/CHN.gdx',
        f'forensics/output/{ds}/gtap/sate/CHN.gdx',
        f'forensics/output/{ds}/gtap/sate2/CHN.gdx',
        ]
    targets = [
        'forensics/results.gdx',
        'forensics/results.xlsx'
    ]

    def copy_excel():
        shutil.copy('forensics/results_git.xlsx', 'forensics/results.xlsx')

    def merge():
        os.system(f"cd forensics & gams ssamerge --ds={ds} & cd ..")

    return {
        'file_dep': dependencies,
        'targets': targets,
        'verbosity': 2,
        'actions': [
            copy_excel,
            merge
        ],

    }


def task_tarifffigs():
    dependencies = [
        'forensics/tradetax.gms',
        'forensics/texcoords.py',
        f'gamsdata/20{yr}/{ds}.gdx',
    ]
    targets = [
        'forensics/tradetax.gdx',
    ]

    def run_paperfigs():
        # extract import tariffs and export taxes from
        os.system(f'cd forensics & gams tradetax --ds={ds} & cd ..')
        os.system(
            "cd forensics & python texcoords.py" +
            " --top 23 & cd ..")

    return {
        'file_dep': dependencies,
        'targets': targets,
        'verbosity': 2,
        'actions': [run_paperfigs],
    }


def task_resultsfigs():
    dependencies = [
        'forensics/process_results.gms',
        'forensics/copyfigs.py',
        'forensics/figures/g20_macro_USA_W.tex',
        'forensics/results.gdx',
    ]
    targets = [
        'forensics/figures/g20_macro_CHN_W.tex',
        'forensics/figures/g20_macro_USA_W.data',
        'forensics/figures/g20_macro_CHN_W.data',
    ]

    def create_figs():
        # extract import tariffs and export taxes from
        os.system(f'cd forensics & gams process_results --ds={ds} & cd ..')
        os.system(
            "cd forensics & python copyfigs.py & cd .."
        )

    return {
        'file_dep': dependencies,
        'targets': targets,
        'verbosity': 2,
        'actions': [create_figs],
    }


def task_paperfigs():
    dependencies = [
        'latex/jgea_new/make_dumbbells.py',
        'latex/jgea_new/make_figs.py',
        'forensics/figures/g20_macro_USA_W.data',
        'forensics/figures/g20_macro_USA_gtap.data',
        'forensics/figures/g20_macro_USA_gtapingams.data',
    ]
    targets = [
        f'latex/jgea_new/figures/dumbbell_{ds}_USA_gtap.tex',
        f'latex/jgea_new/figures/dumbbell_{ds}_USA_gtapingams.tex',
        'latex/jgea_new/figures/res_USA_W_gtap.tex',
        'latex/jgea_new/figures/res_USA_W_gtapingams.tex',
    ]

    def create_figs():
        os.system('cd latex & cd jgea_new' +
                  ' & python make_figs.py' +
                  ' & python make_dumbbells.py' +
                  ' & cd .. & cd ..')

    return {
        'file_dep': dependencies,
        'targets': targets,
        'verbosity': 2,
        'actions': [create_figs],
    }


def task_compile_paper():
    dependencies = [
        'latex/jgea_new.tex',
        'latex/jgea.cls',
        'latex/jgea_new/jgea_new.bib',
        'latex/jgea_new/appendices/appendix_model.tex',
        'latex/jgea_new/appendices/appendix_tariffs.tex',
        'latex/jgea_new/appendices/calibration_lr.tex',
        'latex/jgea_new/appendices/model_lr.tex',
        'latex/jgea_new/appendices/closures.tex',
        'latex/jgea_new/appendices/programs.tex',
        f'latex/jgea_new/figures/dumbbell_{ds}_USA_gtap.tex',
        f'latex/jgea_new/figures/dumbbell_{ds}_USA_gtapingams.tex',
        'latex/jgea_new/figures/res_USA_W_gtap.tex',
        'latex/jgea_new/figures/res_USA_W_gtapingams.tex',
        'latex/jgea_new/data/USA_commodity_m_top23.data',
        'latex/jgea_new/data/USA_txtm_m.plot.data',
    ]

    targets = [
        'latex/jgea_new.pdf'
    ]

    return {
        'file_dep': dependencies,
        'targets': targets,
        'verbosity': 2,
        'actions': ['cd latex' +
                    ' & pdflatex jgea_new.tex' +
                    ' & bibtex jgea_new.aux' +
                    ' & pdflatex jgea_new.tex & pdflatex jgea_new.tex' +
                    ' & cd ..'],
    }
