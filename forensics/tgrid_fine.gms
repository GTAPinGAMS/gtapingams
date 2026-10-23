$title	Generate a Grid over Tariff Rates for a Single Region (GTAP12inGAMS)

*	GTAP12 version of tgrid.gms -- produces the data behind Figures 12
*	(and 13) in Lanz & Rutherford (2016), JGEA 1(2), section 5.
*
*	Run from the forensics directory, e.g.
*	   gams tgrid12 --ds=g20 --mdl=gmr --rcalc=USA
*	   gams tgrid12 --ds=g20 --mdl=soe --rcalc=CHN
*
*	Options:
*	   --ds      dataset in gamsdata/20%yr%  (paper: g20)        [g20]
*	   --yr      reference year (GTAP12: 23)                      [23]
*	   --mdl     gmr (all regions) or soe (rcalc only)            [gmr]
*	   --rcalc   region whose trade taxes are scaled              [CHN]
*	   --soextax yes: in the SOE closure also scale export taxes on
*	             exports to the rest of the world (rtxs_row).  The
*	             original code (and hence the paper) leaves rtxs_row at
*	             its benchmark value, i.e. in the SOE runs only import
*	             tariffs move.                                    [no]

$set fs %system.dirsep%
$set code ..%fs%code%fs%

$if not set t0		$set	t0	1
$if not set yr		$set 	yr	23
$if not set ds      	$set 	ds	g20_macro
$if not set rcalc   	$set 	rcalc	USA
$if not set mdl     	$set 	mdl	gmr
$if not set soextax 	$set	soextax yes
$if not set fsubm	$setglobal fsubm	1

$if not set thetadx 	$setglobal thetadx	1
$if %mdl%==soe		$setglobal thetadx	0.5

$eval tmin max(0, 10*(%t0%-0.2))
$eval tmax min(200, 10*(%t0%+0.2))
$eval tmin 10*%t0%
$eval tmax 10*(%t0%+1)
$eval tint 10*%t0%/10
$eval tintplus1 %tint%+1

set
    tlvl /%tmin%*%tmax%/,
    tord /'%tint%.0',
	  '%tint%.1',
	  '%tint%.2',
	  '%tint%.3',
	  '%tint%.4',
	  '%tint%.5',
	  '%tint%.6',
	  '%tint%.7',
	  '%tint%.8',
	  '%tint%.9',
	  '%tintplus1%.0' /,
    lvlmapord(*,tord);

lvlmapord(tlvl,tord) = yes$(ord(tlvl) = ord(tord));
display tlvl, tord, lvlmapord, "tint is %tint%";

*	Read the model here (this writes gtap12.gen in the working directory,
*	which is moved to the scratch directory so that parallel runs do not
*	overwrite each other):

$include %code%mge
$ifthen.os %system.filesys%==MSNT
$call move /Y gtap12.gen "%gams.scrdir%gtap12.gen" > nul
$else.os
$call mv gtap12.gen "%gams.scrdir%gtap12.gen"
$endif.os

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
$if %mdl%==sate loadrm("%rcalc%");	sate = 1;
$if %mdl%==sate2 loadrm("%rcalc%");	sate2 = 1;
$if %mdl%==sate2 fix0(i,r) = theta_xi(i)/(1-theta_xi(i))*vem(i,r)*pem0(i,r);


*	Macro to update the average export subsidy rate on exports to the
*	rest of the world (only relevant for the SOE closure):

$macro updrow(rr)  rtxs_row(i,rr)$(rm(rr) and vem(i,rr)) = sum(rx, vxmd(i,rr,rx)*rtxs(i,rr,rx))/vem(i,rr);

*	Unilateral free trade solution first with a savepoint
*	so we can reload as starting point:

rtms(i,s,rcalc)$(rtms0(i,s,rcalc)>0) = 0;
rtxs(i,rcalc,s)$(rtxs0(i,rcalc,s)<0) = 0;
$if %soextax%==yes updrow(rcalc);

gtap12.iterlim = 10000;
gtap12.savepoint = 1;
$include %gams.scrdir%gtap12.gen
solve gtap12 using mcp;
abort$(gtap12.objval>1e-3) "Free trade solution fails (%mdl%).";
$ifthen.os %system.filesys%==MSNT
execute 'move /Y gtap12_p.gdx "%gams.scrdir%gtap12_p.gdx" > nul';
$else.os
execute 'mv gtap12_p.gdx "%gams.scrdir%gtap12_p.gdx"';
$endif.os
gtap12.savepoint = 0;

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
		yresults	Counterfactural simulation activity levels,
		welfare_fine,
		figresults	Counterfactural simulation activity levels,
		exitcode	Simulation exit codes;

set dsys /cd, les, cde/;

gtap12.solvelink = 2;

loaddsys("cd",r);

execute_loadpoint '%gams.scrdir%gtap12_p.gdx';

rtms(i,s,r) = rtms0(i,s,r);
rtxs(i,s,r) = rtxs0(i,s,r);
loop(lvlmapord(tlvl,tord),

    rtms(i,s,rcalc)$max(rtms0(i,s,rcalc),0) = rtms0(i,s,rcalc) * tlvl.val/10/averate;
    rtxs(i,rcalc,s)$max(-rtxs0(i,rcalc,s),0) = rtxs0(i,rcalc,s) * tlvl.val/10/averate;
$if %soextax%==yes updrow(rcalc);

    results("cd",tlvl,"averate") =100 *
	sum((i,s),	max(-rtxs(i,rcalc,s),0) * vxmd(i,rcalc,s) +
	    max(rtms(i,s,rcalc),0)*((1-rtxs(i,s,rcalc))*
		vxmd(i,s,rcalc)+sum(j,vtwr(j,i,s,rcalc)))) /
		sum((i,s), vxmd(i,rcalc,s)$max(-rtxs0(i,rcalc,s),0) +
		    ((1-rtxs0(i,s,rcalc))*vxmd(i,s,rcalc)+
			sum(j,vtwr(j,i,s,rcalc)))$max(rtms0(i,s,rcalc),0));

    gtap12.iterlim = 100000;
$include %gams.scrdir%gtap12.gen
    solve gtap12 using mcp;
    abort$(gtap12.objval>1e-3) "Simulation fails: gtap12.";

    results("cd",tlvl,"W") = 100 * (UTIL(rcalc) -1);
    results("cd",tlvl,"W") = 100 * (UTIL(rcalc) -1);
    results("cd",tlvl,"globalW") = 100 * sum(r,vc(r)*(UTIL(r)-1))/vc(rcalc);
    results("cd",tlvl,"modelstat") = gtap12.modelstat;
    results("cd",tlvl,"solvestat") = gtap12.solvestat;

*	Do the GDP calculations:

$include %code%gdpcalc

    gdpresults("cd",tlvl,gdpcat,r,gdpitem) = gdp(gdpcat,r,gdpitem);
    yresults("cd",tlvl,i) = 100*(Y.l(i,rcalc)-1);
    figresults("cd",tlvl,i) = yresults("cd",tlvl,i);
    figresults("cd",tlvl,"W") = results("cd",tlvl,"W");
    welfare_fine(tord) = results("cd",tlvl,"W");
);
option welfare_fine:6;
display welfare_fine;
