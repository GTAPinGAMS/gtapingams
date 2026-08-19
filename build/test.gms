$title	Run some consistency tests for aggregate datasets.

*	File separator: "\" for Windows --  "/" for Unix/OSX

$set fs %system.dirsep% 

*	NB: Benchmark consistency is a necessary, but not a
*	sufficient condition that the model is properly specified.


*	Run BENCHMARK checks for the g20_macro dataset in both MGE
*	and MCP formats.  This routine produces a replication check
*	for the GMR model and all the single region SOE  models:


$set ds g20_macro

$call gams bmkchk --mdl=mcp --ds=%ds% o=listings%fs%bmkchk_mcp.lst
$call start "bmkchk_mge" gams bmkchk --mdl=mge --ds=%ds% o=listings%fs%bmkchk_mge.lst
$if not %sys.filesys%==UNIX $call pause
$call pause

*	Next we perform a check of consistency for the MCP and 
*	MGE models at a counterfactual point.

$label mcpmge

$log	Solve the MGE model then verify that the solution is
$log	valid for the MCP model:

$set ds g20
$label mcpmge
$if exist gtap9_p.gdx $call del gtap9_p.gdx
$call gams mcpmge --mdl=mge --ds=%ds% o=listings%fs%mge1_%ds%.lst ps=0
$call gams mcpmge --mdl=mcp --ds=%ds% o=listings%fs%mcp1_%ds%.lst ps=0


$log	Then solve the MCP model and verify that the solution is
$log	valid for the MGE model:

$if exist gtap9_p.gdx $call del gtap9_p.gdx
$call gams mcpmge --mdl=mcp --ds=%ds% o=listings%fs%mcp2_%ds%.lst ps=0
$call gams mcpmge --mdl=mge --ds=%ds% o=listings%fs%mge2_%ds%.lst ps=0
$call pause

*	Finally, verify that the CDE demand system reproduces the
*	exogenous own-price and income demand elasticities:

$set ds g20
$call gams cdechk --ds=%ds%  o=listings%fs%cdechk.lst ps=0
