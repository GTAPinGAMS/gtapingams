$title	Solve a Model as an MCP or an MGE Model

$if not set ds $set ds g20_macro
$if not set yr $set yr 17

$if not set mdl $set mdl mge

$set fs %system.dirsep%
$set code ..%fs%code%fs%

$include %code%%mdl%.gms
$include %code%loadmdl
$include %code%gdpcalc

set	rsoe(r) /CHN,JPN,USA/;

loadrm(rsoe);
loadcd(r);

gtap11.workspace = 1024;
gtap11.iterlim = 0;
$include gtap11.gen
solve gtap11 using mcp;
abort$(gtap11.objval > 1e-4) "GMR with CD fails.", gtap11.objval;

*	Then impose a tariff shock:

rtms(i,r,"usa") = 0;
gtap11.iterlim = 0;

$ifthen.loadpoint exist gtap11_p.gdx
	RA.LO(r) = 0; RA.UP(r) = +INF;
	gtap11.iterlim = 0;
$include gtap11.gen
	execute_loadpoint 'gtap11_p.gdx';
	RA.FX(rnum) = RA.L(rnum);

	solve gtap11 using mcp;

	display$(gtap11.objval > 1e-4) "Counterfactual simulation fails.", gtap11.objval;
	display$(gtap11.objval <= 1e-4) "Precision of counterfactual simulation:", gtap11.objval;
$else.loadpoint
	gtap11.savepoint = 1;
	gtap11.iterlim = 10000;
$include gtap11.gen
	solve gtap11 using mcp;
	display$(gtap11.objval > 1e-4) "Counterfactual solve fails.", gtap11.objval;
$endif.loadpoint

$include %code%gdpcalc
option gdp:3:1:1;
display gdp;
