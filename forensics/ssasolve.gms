$title	Run tgrid12 for the cases shown in Figures 12-13 (GTAP12, g20 dataset)

*	Run from the forensics directory:  gams run12
*	Each job writes output\<ds>\<mdl>\<rcalc>.lst/.gdx and <rcalc>_<mdl>_<ds>.data

$if not set ds $set ds g20
$if not set soextax $set soextax yes

$if not dexist output\%ds%\soe $call mkdir output\%ds%\soe
$if not dexist output\%ds%\gmr $call mkdir output\%ds%\gmr


$call.async gams tgrid --rcalc=USA --mdl=soe --ds=%ds% --soextax=%soextax% o=output\%ds%\soe\USA.lst gdx=output\%ds%\soe\USA.gdx
$call sleep 1s
$call.async gams tgrid --rcalc=CHN --mdl=soe --ds=%ds% --soextax=%soextax% o=output\%ds%\soe\CHN.lst gdx=output\%ds%\soe\CHN.gdx
$call sleep 1s
$call.async gams tgrid --rcalc=USA --mdl=gmr --ds=%ds% o=output\%ds%\gmr\USA.lst gdx=output\%ds%\gmr\USA.gdx
$call sleep 1s
$call.async gams tgrid --rcalc=CHN --mdl=gmr --ds=%ds% o=output\%ds%\gmr\CHN.lst gdx=output\%ds%\gmr\CHN.gdx
$call sleep 1s

$exit
