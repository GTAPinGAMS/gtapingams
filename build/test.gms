$title	Run some consistency tests for aggregate datasets.

$if not set run	$setglobal run	bmkchk

*	File separator: "\" for Windows --  "/" for Unix/OSX

$set fs %system.dirsep%

$goto %run%

*	NB: Benchmark consistency is a necessary, but not a
*	sufficient condition that the model is properly specified.


*	Run BENCHMARK checks for the g20_macro dataset in both MGE
*	and MCP formats.  This routine produces a replication check
*	for the GMR model and all the single region SOE  models:


$label bmkchk
$set ds g20_macro

$call start "bmkchk_mcp" gams bmkchk --mdl=mcp --ds=%ds% o=listings%fs%bmkchk_mcp.lst
$call start "bmkchk_mge" gams bmkchk --mdl=mge --ds=%ds% o=listings%fs%bmkchk_mge.lst
$exit

*	Next we perform a check of consistency for the MCP and
*	MGE models at a counterfactual point.

$label mge_mcp
$log	Solve the MGE model then verify that the solution is
$log	valid for the MCP model:

$set ds g20
$if exist gtap12_p.gdx $call del gtap12_p.gdx
$call gams mcpmge --mdl=mge --ds=%ds% o=listings%fs%mge1_%ds%.lst ps=0
$call gams mcpmge --mdl=mcp --ds=%ds% o=listings%fs%mcp1_%ds%.lst ps=0
$exit


$label mcp_mge
$log	Then solve the MCP model and verify that the solution is
$log	valid for the MGE model:

$set ds g20
$if exist gtap12_p.gdx $call del gtap12_p.gdx
$call gams mcpmge --mdl=mcp --ds=%ds% o=listings%fs%mcp2_%ds%.lst ps=0
$call gams mcpmge --mdl=mge --ds=%ds% o=listings%fs%mge2_%ds%.lst ps=0
$exit

*	Next we perform a check of consistency for the MCP and
*	MGE models at a counterfactual point WITH SATE.

$label mge_mcp_sate
$log	Solve the MGE model then verify that the solution is
$log	valid for the MCP model:

$set ds g20
$if exist gtap12_p.gdx $call del gtap12_p.gdx
$call gams mcpmge --mdl=mge --mv=sate --ds=%ds% o=listings%fs%mge1_%ds%_sate.lst ps=0
$call gams mcpmge --mdl=mcp --mv=sate --ds=%ds% o=listings%fs%mcp1_%ds%_sate.lst ps=0
$exit


$label mcp_mge_sate
$log	Then solve the MCP model and verify that the solution is
$log	valid for the MGE model:

$set ds g20
$if exist gtap12_p.gdx $call del gtap12_p.gdx
$call gams mcpmge --mdl=mcp --mv=sate --ds=%ds% o=listings%fs%mcp2_%ds%_sate.lst ps=0
$call gams mcpmge --mdl=mge --mv=sate --ds=%ds% o=listings%fs%mge2_%ds%_sate.lst ps=0
$exit

*	Next we perform a check of consistency for the MCP and
*	MGE models at a counterfactual point WITH SATE2.

$label mge_mcp_sate2
$log	Solve the MGE model then verify that the solution is
$log	valid for the MCP model:

$set ds g20
$if exist gtap12_p.gdx $call del gtap12_p.gdx
$call gams mcpmge --mdl=mge --mv=sate2 --ds=%ds% o=listings%fs%mge1_%ds%_sate2.lst ps=0
$call gams mcpmge --mdl=mcp --mv=sate2 --ds=%ds% o=listings%fs%mcp1_%ds%_sate2.lst ps=0
$exit


$label mcp_mge_sate2
$log	Then solve the MCP model and verify that the solution is
$log	valid for the MGE model:

$set ds g20
$if exist gtap12_p.gdx $call del gtap12_p.gdx
$call gams mcpmge --mdl=mcp --mv=sate2 --ds=%ds% o=listings%fs%mcp2_%ds%_sate2.lst ps=0
$call gams mcpmge --mdl=mge --mv=sate2 --ds=%ds% o=listings%fs%mge2_%ds%_sate2.lst ps=0
$exit

*	Finally, verify that the CDE demand system reproduces the
*	exogenous own-price and income demand elasticities:

$label cdechk
$set ds g20
$call gams cdechk --ds=%ds%  o=listings%fs%cdechk.lst ps=0
$exit
