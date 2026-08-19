$title	Solve a Model as an MCP or an MGE Model

$if not set ds $set ds g20_macro
$if not set yr $set yr 11

$if not set mdl $set mdl mge

$set fs %system.dirsep% 
$set code ..%fs%code%fs%

$include %code%%mdl%.gms
$include %code%loadmdl
$include %code%gdpcalc

set	rsoe(r) /CHN,JPN,USA/;

loadrm(rsoe);
loadcd(r);

gtap9.workspace = 1024;
gtap9.iterlim = 0;
$include gtap9.gen
solve gtap9 using mcp;
abort$(gtap9.objval > 1e-4) "GMR with CD fails.", gtap9.objval;

*	Then impose a tariff shock:

rtms(i,r,"usa") = 0;
gtap9.iterlim = 0;

$ifthen.loadpoint exist gtap9_p.gdx
	RA.LO(r) = 0; RA.UP(r) = +INF; 
	gtap9.iterlim = 0;
$include gtap9.gen
	execute_loadpoint 'gtap9_p.gdx';
	RA.FX(rnum) = RA.L(rnum);

	solve gtap9 using mcp;

	display$(gtap9.objval > 1e-4) "Counterfactual simulation fails.", gtap9.objval;
	display$(gtap9.objval <= 1e-4) "Precision of counterfactual simulation:", gtap9.objval;
$else.loadpoint
	gtap9.savepoint = 1;
	gtap9.iterlim = 10000;
$include gtap9.gen
	solve gtap9 using mcp;
	display$(gtap9.objval > 1e-4) "Counterfactual solve fails.", gtap9.objval;
$endif.loadpoint

$include %code%gdpcalc
option gdp:3:1:1;
display gdp;
