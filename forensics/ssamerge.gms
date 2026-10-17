$if not set ds $set ds g20

$call gdxmerge output\%ds%\soe\*.gdx o=output\%ds%\soe.gdx id=results,gdpresults
$call gdxmerge output\%ds%\gmr\*.gdx o=output\%ds%\gmr.gdx id=results,gdpresults
* $call gdxmerge output\%ds%_macro\soe\*.gdx o=output\%ds%_macro\soe.gdx id=results,gdpresults
* $call gdxmerge output\%ds%_macro\gmr\*.gdx o=output\%ds%_macro\gmr.gdx id=results,gdpresults


$call gdxmerge output\%ds%\*.gdx o=output\%ds%.gdx
* $call gdxmerge output\%ds%_macro\*.gdx o=output\%ds%_macro.gdx


$call gdxmerge output\*.gdx o=results.gdx

* $call gdxxrw i=labels.gdx  o=results.xlsx set=labels rng=PivotData!a2 cdim=0 intastext=no
$call gdxxrw i=results.gdx o=results.xlsx par=results rng=PivotData!a2 cdim=0 clear
