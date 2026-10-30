$title	Solve a Model as an MCP or an MGE Model

$if not set ds $set ds g20_macro
$if not set yr $set yr 23
$if not set mv $set mv soe

$if not set mdl $set mdl mge

$set fs %system.dirsep%
$set code ..%fs%code%fs%

$include %code%%mdl%.gms
$include %code%loadmdl
$include %code%gdpcalc

set	rsoe(r) /CHN,JPN,USA/;

loadrm(rsoe);
loadcd(r);

$if "%mv%" == "sate"
sate = 1;
$ifthen "%mv%" == "sate2"
sate2 = 1;
fix0(i,r) = theta_xi(i)/(1-theta_xi(i))*vem(i,r)*pem0(i,r);
$endif

gtap12.workspace = 1024;
gtap12.iterlim = 0;
$include gtap12.gen
solve gtap12 using mcp;
abort$(gtap12.objval > maxdev) "GMR with CD fails.", gtap12.objval;

*	Then impose a tariff shock:

rtms(i,r,"usa") = 0;
gtap12.iterlim = 0;

$ifthen.loadpoint exist gtap12_p.gdx
	RA.LO(r) = 0; RA.UP(r) = +INF;
	gtap12.iterlim = 0;
$include gtap12.gen
	execute_loadpoint 'gtap12_p.gdx';
	RA.FX(rnum) = RA.L(rnum);

	solve gtap12 using mcp;

	display$(gtap12.objval > maxdev) "Counterfactual simulation fails.", gtap12.objval;
	display$(gtap12.objval <= maxdev) "Precision of counterfactual simulation:", gtap12.objval;
$else.loadpoint
	gtap12.savepoint = 1;
	gtap12.iterlim = 10000;
$include gtap12.gen
	solve gtap12 using mcp;
	display$(gtap12.objval > maxdev) "Counterfactual solve fails.", gtap12.objval;
$endif.loadpoint

$include %code%gdpcalc
option gdp:3:1:1;
display gdp;
