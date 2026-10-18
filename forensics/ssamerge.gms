$if not set ds $set ds g20

$call gdxmerge output\%ds%\gtapingams\soe\*.gdx o=output\%ds%\gtapingams\soe.gdx id=results,gdpresults,yresults
$call gdxmerge output\%ds%\gtapingams\sop\*.gdx o=output\%ds%\gtapingams\sop.gdx id=results,gdpresults,yresults
$call gdxmerge output\%ds%\gtapingams\sop2\*.gdx o=output\%ds%\gtapingams\sop2.gdx id=results,gdpresults,yresults
$call gdxmerge output\%ds%\gtapingams\gmr\*.gdx o=output\%ds%\gtapingams\gmr.gdx id=results,gdpresults,yresults
$call gdxmerge output\%ds%\gtapingams\gmr_ls\*.gdx o=output\%ds%\gtapingams\gmr_ls.gdx id=results,gdpresults,yresults
$call gdxmerge output\%ds%\gtap\soe\*.gdx o=output\%ds%\gtap\soe.gdx id=results,gdpresults,yresults
$call gdxmerge output\%ds%\gtap\sop\*.gdx o=output\%ds%\gtap\sop.gdx id=results,gdpresults,yresults
$call gdxmerge output\%ds%\gtap\sop2\*.gdx o=output\%ds%\gtap\sop2.gdx id=results,gdpresults,yresults
$call gdxmerge output\%ds%\gtap\gmr\*.gdx o=output\%ds%\gtap\gmr.gdx id=results,gdpresults,yresults
$call gdxmerge output\%ds%\gtap\gmr_ls\*.gdx o=output\%ds%\gtap\gmr_ls.gdx id=results,gdpresults,yresults


$call gdxmerge output\%ds%\gtapingams\*.gdx o=output\%ds%\gtapingams.gdx
$call gdxmerge output\%ds%\gtap\*.gdx o=output\%ds%\gtap.gdx

$call gdxmerge output\%ds%\*.gdx o=output\%ds%.gdx
*.$call gdxmerge output\%ds%_macro\*.gdx o=output\%ds%_macro.gdx


$call gdxmerge output\*.gdx o=results.gdx

* $call gdxxrw i=labels.gdx  o=results.xlsx set=labels rng=PivotData!a2 cdim=0 intastext=no
$call gdxxrw i=results.gdx o=results.xlsx par=results rng=PivotData!a2 cdim=0 intastext=no
$call gdxxrw i=results.gdx o=results.xlsx par=yresults rng=DataY!a2 cdim=0 intastext=no
