$call gdxmerge output\g20\soe\*.gdx o=output\g20\soe.gdx id=results,gdpresults
$call gdxmerge output\g20\gmr\*.gdx o=output\g20\gmr.gdx id=results,gdpresults
$call gdxmerge output\g20_macro\soe\*.gdx o=output\g20_macro\soe.gdx id=results,gdpresults
$call gdxmerge output\g20_macro\gmr\*.gdx o=output\g20_macro\gmr.gdx id=results,gdpresults


$call gdxmerge output\g20\*.gdx o=output\g20.gdx
$call gdxmerge output\g20_macro\*.gdx o=output\g20_macro.gdx


$call gdxmerge output\*.gdx o=results.gdx

$call gdxxrw i=labels.gdx  o=results.xlsx set=labels rng=PivotData!a2 cdim=0 intastext=no
$call gdxxrw i=results.gdx o=results.xlsx par=results rng=PivotData!a2 cdim=0 clear
