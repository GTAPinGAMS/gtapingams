$title	GENERATE Script to Run the Model

*	---------------------------------------------------------
*	Define sets for the sensitvity analysis:

$set s1 ds
$set s2 mdl
$set s3 rcalc

*	---------------------------------------------------------

set	ds	Datasets to run (g20 or smaller) / g20, g20_macro /,
	mdl	Models should we should run /soe,gmr/,
	rcalc	Regions to be studied /USA, CHN/,
	tr	Average tax rates to be calculated /0*10/,
	dsys	Final demand system /cd, les, cde/,
	values	Solution values to return /w,globalw,modelstat,solvestat/;

set labels	Generate a dense set of identifiers to drive pivot domain;
labels(%s1%,	%s2%,	%s3%,	dsys,	tr,	values) = yes;
labels(%s1%,	%s2%,	%s3%,	dsys,	tr,	"")    = yes;
labels(%s1%,	%s2%,	%s3%,	dsys,	"",	values) = yes;
labels(%s1%,	%s2%,	%s3%,	"",	tr,	values) = yes;
labels(%s1%,	%s2%,	"",	dsys,	tr,	values) = yes;
labels(%s1%,	"",	%s3%,	dsys,	tr,	values) = yes;
labels("",	%s2%,	%s3%,	dsys,	tr,	values) = yes;

execute_unload 'labels',labels;

*	--------------------------------------------------------------------
*	Multi-dimensional results to retrieve:

file ssasolve /ssasolve.gms/, ssamerge /ssamerge.gms/;  
ssasolve.lw=0; 
ssasolve.nw=0; 
ssasolve.nd=0;
put ssasolve;

ssamerge.lw=0; 
ssamerge.nw=0; 
ssamerge.nd=0;

$set fs %system.dirsep% 

$set outdir  "'output%fs%',%s1%.tl,'%fs%',%s2%.tl"
loop((%s1%,%s2%), put '$if not dexist ',%outdir%,' $call mkdir ',%outdir%/);

put //;

$set title   "%s3%.tl,' - ',%s1%.tl,' - ',%s2%.tl"
$set outfile "'output%fs%',%s1%.tl,'%fs%',%s2%.tl,'%fs%',%s3%.tl"
$set options "'--%s3%=',%s3%.tl,' --%s2%=',%s2%.tl,' --%s1%=',%s1%.tl"
$set gamscmd "'gams tgrid ',%options%,' o=',%outfile%,'.lst gdx=',%outfile%,'.gdx'"

loop((%s1%,%s2%,%s3%),
	      put '$call.async ',%gamscmd%/;
	      put '$call sleep 1s'//;; );

put '$exit'//;

put ssamerge;
$set gdxin  "'output%fs%',%s1%.tl,'%fs%',%s2%.tl,'%fs%*.gdx'"
$set gdxout "'output%fs%',%s1%.tl,'%fs%',%s2%.tl,'.gdx'"
loop((%s1%,%s2%), 
	put '$call gdxmerge ',%gdxin%,' o=',%gdxout%,' id=results,gdpresults'/;);

put //;

$set gdxin  "'output%fs%',%s1%.tl,'%fs%*.gdx'"
$set gdxout "'output%fs%',%s1%.tl,'.gdx'"
loop(%s1%, 
	put '$call gdxmerge ',%gdxin%,' o=',%gdxout%/;);

put //;

put	'$call gdxmerge output%fs%*.gdx o=results.gdx'//;

put	'$call gdxxrw i=labels.gdx  o=results.xlsx set=labels rng=PivotData!a2 cdim=0 intastext=no'/
	'$call gdxxrw i=results.gdx o=results.xlsx par=results rng=PivotData!a2 cdim=0 clear'/;

putclose;
