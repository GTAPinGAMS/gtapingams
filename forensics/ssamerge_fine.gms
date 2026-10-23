$if not set ds $set ds g20_macro

$call gdxmerge output_fine\%ds%\sate\*.gdx o=output_fine\%ds%\sate.gdx id=welfare_fine
$call gdxmerge output_fine\%ds%\sate_ls\*.gdx o=output_fine\%ds%\sate_ls.gdx id=welfare_fine
$call gdxmerge output_fine\%ds%\gmr\*.gdx o=output_fine\%ds%\gmr.gdx id=welfare_fine
$call gdxmerge output_fine\%ds%\gmr_ls\*.gdx o=output_fine\%ds%\gmr_ls.gdx id=welfare_fine
$call gdxmerge output_fine\%ds%\soe\*.gdx o=output_fine\%ds%\soe.gdx id=welfare_fine


$call gdxmerge output_fine\%ds%\*.gdx o=output_fine\%ds%.gdx

$call gdxmerge output_fine\*.gdx o=results_fine.gdx

* $call gdxxrw i=labels.gdx  o=results.xlsx set=labels rng=PivotData!a2 cdim=0 intastext=no
$call gdxxrw i=results_fine.gdx o=results.xlsx par=welfare_fine rng=DataFine!a2 cdim=0 intastext=no
