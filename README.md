# GTAPinGAMS
Updates to Bruno Lanz and Tom Rutherford's GTAP9inGAMS

- Check out different branches for processing GTAP versions 10, 11, 12; 'main' branch is GTAP 12 as of October 2026
- Using python doit for build stream management

# Acknowledgements

This is based on Bruno Lanz and Thomas F. Rutherford's work published in the Journal of Global Economic Analysis:

Lanz, B., & Rutherford, T. F. (2016). GTAPinGAMS: Multiregional and Small Open Economy Models. Journal of Global Economic Analysis, 1(2), 1–77. https://doi.org/10.21642/JGEA.010201AF

Consult that paper and its supplementary information for documentation of the GTAPinGAMS model.

# Instructions

System requirements:
- Scripts run on Windows, but should only require minor adjustments to be run on other systems.
- GAMS (www.gams.com) with system's PATH pointing to the gams executable. (routinges checked for GAMS 44.4)
- python with python doit (https://pydoit.org/index.html) available in the active environment. (If in doubt, consult requirements.txt for exact python package versions to install.)

Running the code:
- On the system's command line, navigate to the root folder of the repository, activate your python environment that includes python doit, then type 'doit' and press Enter.
 (This will run python doit and execute the different scripts according to the sequence given to python doit by dodo.py.)
- Follow instructions on the command line for placing GTAP data in the correct folder.
Currently, this means placing the GDX version of GTAP12a that includes all shipped reference years ('GDX12a_AY168994.zip') in folder ./gtapdata.
- Whatch the lines whiz by and hope that no error occurs.
- If all went well: Behold different aggregations of GTAP12 data in ./gamsdata/2023/

Using the code for your own work:
- You may want to use different aggregations. For this, you can change (bad) or copy, rename, and edit (good) existing .map files in folder ./defines/. If you create new a 'newdefines.map' file, make sure that dodo.py and the scripts called therein pick up on it by adding 'newdefines' to the python list 'agg_levels' in 'dodo.py'.
- You may want to use reference years different from 2023. Try changing the value of variable 'yr' in dodo.py and see what happens. Chances are the yr is still hard-coded in some .gms files, so you MAY have to debug the code a bit. Sorry.