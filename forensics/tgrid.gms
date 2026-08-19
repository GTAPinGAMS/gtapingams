$title	Generate a Grid over Tariff Rates for a Single Region

*	Point to the GTAP9inGAMS code directory:

$set fs %system.dirsep% 
$set code ..%fs%code%fs%

$if not set yr $set yr 11
$if not set ds $set ds g20_macro
$if not set rcalc $set rcalc chn
$if not set mdl $set mdl gmr

set	tlvl /0*10/;

*	Read the model here:

$include %code%mge
$call 'mv gtap9.gen %gams.scrdir%gtap9.gen'

parameter	vc(r)	Value of benchmark expenditure;
vc(r) = vom("c",r);

*	Preliminary invocation outside a loop permits 
*	parameter declarations:

$include %code%loadmdl
$include %code%gdpcalc

*	Region to be calculated:

singleton set	rcalc(r) /%rcalc%/;

*	Model (soe or gmr):

$if %mdl%==gmr loadrm(r);
$if %mdl%==soe loadrm("%rcalc%");

*	Unilateral free trade solution first with a savepoint
*	so we can reload as starting point:

rtms(i,s,rcalc)$(rtms0(i,s,rcalc)>0) = 0;
rtxs(i,rcalc,s)$(rtxs0(i,rcalc,s)<0) = 0;

gtap9.iterlim = 10000;
gtap9.savepoint = 1;
$include %gams.scrdir%gtap9.gen
solve gtap9 using mcp;
abort$(gtap9.objval>1e-3) "Benchmark replication fails (%mdl%).";
execute 'mv gtap9_p.gdx %gams.scrdir%gtap9_p.gdx';
gtap9.savepoint = 0;

alias (r,rr);

$macro UTIL(r) (Y.L("c",r)$(not (les(r) or cde(r)))+ \
		(1+(Y.L("dd",r)-1)*betales(r))$les(r)+W.L(r)$cde(r))

parameter	averate	Benchmark trade tax rates (%);

averate = 100 *

   sum((i,s),	max(-rtxs0(i,rcalc,s),0) * vxmd(i,rcalc,s) +
		max(rtms0(i,s,rcalc),0)  * ((1-rtxs0(i,s,rcalc))*
			vxmd(i,s,rcalc)+sum(j,vtwr(j,i,s,rcalc)))) /

   sum((i,s),    vxmd(i,rcalc,s)$max(-rtxs0(i,rcalc,s),0) + 
                ((1-rtxs0(i,s,rcalc))*vxmd(i,s,rcalc)
			+sum(j,vtwr(j,i,s,rcalc)))$max(rtms0(i,s,rcalc),0));
display averate;

parameter	results		Counterfactural simulation summary
		gdpresults	Counterfactural simulation GDP results,
		exitcode	Simulation exit codes;

set		dsys	Final demand system /cd, les, cde/;

gtap9.solvelink = 2;
loop(dsys,

  loaddsys(dsys,r);

  execute_loadpoint '%gams.scrdir%gtap9_p.gdx';

  rtms(i,s,r) = rtms0(i,s,r);
  rtxs(i,s,r) = rtxs0(i,s,r);
  loop(tlvl,

    rtms(i,s,rcalc)$max(rtms0(i,s,rcalc),0) = rtms0(i,s,rcalc) * tlvl.val/averate;
    rtxs(i,rcalc,s)$max(-rtxs0(i,rcalc,s),0) = rtxs0(i,rcalc,s) * tlvl.val/averate;

    results(dsys,tlvl,"averate") =100 *
	sum((i,s),	max(-rtxs(i,rcalc,s),0) * vxmd(i,rcalc,s) +
			max(rtms(i,s,rcalc),0)*((1-rtxs(i,s,rcalc))*
			vxmd(i,s,rcalc)+sum(j,vtwr(j,i,s,rcalc)))) /
	sum((i,s), vxmd(i,rcalc,s)$max(-rtxs0(i,rcalc,s),0) + 
		        ((1-rtxs0(i,s,rcalc))*vxmd(i,s,rcalc)+
			sum(j,vtwr(j,i,s,rcalc)))$max(rtms0(i,s,rcalc),0));

    gtap9.iterlim = 100000;
$include %gams.scrdir%gtap9.gen
    solve gtap9 using mcp;
    abort$(gtap9.objval>1e-3) "Simulation fails: gtap9.";

    results(dsys,tlvl,"W") = 100 * (UTIL(rcalc) -1);
    results(dsys,tlvl,"globalW") = 100 * sum(r,vc(r)*(UTIL(r)-1))/vc(rcalc);
    results(dsys,tlvl,"modelstat") = gtap9.modelstat;
    results(dsys,tlvl,"solvestat") = gtap9.solvestat;

*	Do the GDP calculations:

$include %code%gdpcalc

    gdpresults(dsys,tlvl,gdpcat,r,gdpitem) = gdp(gdpcat,r,gdpitem);

  );
);
display results;
