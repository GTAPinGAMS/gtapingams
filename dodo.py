import os
from doit.tools import run_once
# This provides shutil.copy(source,destination):
# import shutil


def task_folders():
    """Make sure all necessary directories exist."""
    def make_some_dirs():
        dirlist = ['gtapdata',
                   'build/listings',
                   'gamsdata/2014',
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
        input("Please provide file gtapdata/flexagg10AY14.zip.\n" +
              "It can be obtained from\n" +
              "https://www.gtap.agecon.purdue.edu/databases/archives.asp\n" +
              "(Look for FlexAgg (year 2014) for GTAP10a\n" +
              "under the heading 'Satellite Data and Utilities').\n"
              "Then press ENTER.\n\n"
              )

    # If both run_once and targets are there:
    # Task is only uptodate if BOTH targets are there AND it has been ran once
    return {
        'actions': [ask_for_GTAP, ],
        'targets': ['gtapdata/flexagg10AY14.zip'],
        'verbosity': 2,
        'uptodate': [run_once],
    }


# Set some command flags as strings
code = "../code/"
nd = "5"
yr = "14"


def task_readgdx():
    """Run code/readgdx.gms"""
    return {
        'file_dep': [
            'code/readgdx.gms',
            f'gtapdata/GDX10a_{yr}.zip',
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
            'code/gtap10data.gms',
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

    return {
        'file_dep': [
            'build/build.gms',
            'code/gtapaggr.gms',
            'code/cdecalib.gms',
            'code/gtap10data.gms',
            'code/aggr.gms',
            'code/checkset.gms',
            'code/chktarget.gms',
            'code/domain.gms',
            'defines/g20_iea.map',
            'defines/g20_macro.map',
            'defines/g20.map',
            'defines/gtap10ingams.map',
            'gamsdata/2014/gsd_5.gdx',
        ],
        'targets': [
            'build/build.lst',
            'build/listings/cde_g20_14.lst',
            'build/listings/cde_g20_iea_14.lst',
            'build/listings/cde_g20_macro_14.lst',
            'build/listings/cde_gtapingams_14.lst',
            'build/listings/g20_14.lst',
            'build/listings/g20_iea_14.lst',
            'build/listings/g20_macro_14.lst',
            'build/listings/gtapingams_14.lst',
            'build/listings/cde_gtap10ingams_14.lst',
            'build/listings/gtap10ingams_14.lst',
            'gamsdata/2014/gtap10ingams.gdx',
            'gamsdata/2014/g20.gdx',
            'gamsdata/2014/g20_iea.gdx',
            'gamsdata/2014/g20_macro.gdx',
        ],
        'verbosity': 2,
        'actions': ["cd build & gams build & cd .."],
    }


def task_test():
    """Run the testing script build/test.gms"""
    return {
        'file_dep': [
            'build/test.gms',
            'build/cdechk.gms',
            'build/mcpmge.gms',
            'code/mge.gms',
            'code/mcp.gms',
            'code/loadmdl.gms',
            'code/gdpcalc.gms',
            'gamsdata/2014/g20_macro.gdx',
            'gamsdata/2014/g20.gdx',
        ],
        'targets': [
            'build/GTAP10.GEN',
            'build/GTAP10_p.gdx',
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
        'actions': ["cd build & gams test & cd .."],
    }
