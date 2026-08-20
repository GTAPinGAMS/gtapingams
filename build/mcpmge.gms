$title	Solve a Model as an MCP or an MGE Model

$if not set ds $set ds g20_macro
$if not set yr $set yr 14

$if not set mdl $set mdl mge

$set fs %system.dirsep%
$set code ..%fs%code%fs%

$include %code%%mdl%.gms
$include %code%loadmdl
$include %code%gdpcalc

set	rsoe(r) /CHN,JPN,USA/;

loadrm(rsoe);
loadcd(r);

gtap10.workspace = 1024;
gtap10.iterlim = 0;
$include gtap10.gen
solve gtap10 using mcp;
abort$(gtap10.objval > 1e-4) "GMR with CD fails.", gtap10.objval;

*	Then impose a tariff shock:

rtms(i,r,"usa") = 0;
gtap10.iterlim = 0;

$ifthen.loadpoint exist gtap10_p.gdx
	RA.LO(r) = 0; RA.UP(r) = +INF;
	gtap10.iterlim = 0;
$include gtap10.gen
	execute_loadpoint 'gtap10_p.gdx';
	RA.FX(rnum) = RA.L(rnum);

	solve gtap10 using mcp;

	display$(gtap10.objval > 1e-4) "Counterfactual simulation fails.", gtap10.objval;
	display$(gtap10.objval <= 1e-4) "Precision of counterfactual simulation:", gtap10.objval;
$else.loadpoint
	gtap10.savepoint = 1;
	gtap10.iterlim = 10000;
$include gtap10.gen
	solve gtap10 using mcp;
	display$(gtap10.objval > 1e-4) "Counterfactual solve fails.", gtap10.objval;
$endif.loadpoint

$include %code%gdpcalc
option gdp:3:1:1;
display gdp;
