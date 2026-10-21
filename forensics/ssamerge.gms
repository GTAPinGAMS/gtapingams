$if not set ds $set ds g20

$call gdxmerge output\%ds%\soe\*.gdx o=output\%ds%\soe.gdx id=results,gdpresults,yresults,figresults
$call gdxmerge output\%ds%\sate\*.gdx o=output\%ds%\sate.gdx id=results,gdpresults,yresults,figresults
$call gdxmerge output\%ds%\sate_ls\*.gdx o=output\%ds%\sate_ls.gdx id=results,gdpresults,yresults,figresults
$call gdxmerge output\%ds%\sate2\*.gdx o=output\%ds%\sate2.gdx id=results,gdpresults,yresults,figresults
$call gdxmerge output\%ds%\gmr\*.gdx o=output\%ds%\gmr.gdx id=results,gdpresults,yresults,figresults
$call gdxmerge output\%ds%\gmr_ls\*.gdx o=output\%ds%\gmr_ls.gdx id=results,gdpresults,yresults,figresults


$call gdxmerge output\%ds%\*.gdx o=output\%ds%.gdx

$call gdxmerge output\*.gdx o=results.gdx

* $call gdxxrw i=labels.gdx  o=results.xlsx set=labels rng=PivotData!a2 cdim=0 intastext=no
$call gdxxrw i=results.gdx o=results.xlsx par=results rng=PivotData!a2 cdim=0 intastext=no
$call gdxxrw i=results.gdx o=results.xlsx par=yresults rng=DataY!a2 cdim=0 intastext=no
