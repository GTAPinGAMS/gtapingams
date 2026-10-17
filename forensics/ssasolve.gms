$title	Run tgrid12 for the cases shown in Figures 12-13 (GTAP12, g20 dataset)

*	Run from the forensics directory:  gams run12
*	Each job writes output\<ds>\<mdl>\<rcalc>.lst/.gdx and <rcalc>_<mdl>_<ds>.data

$if not set ds $set ds g20
$if not set soextax $set soextax yes

$if not dexist output\%ds%\gtapingams	$call mkdir output\%ds%\gtapingams
$if not dexist output\%ds%\gtapingams\soe $call mkdir output\%ds%\gtapingams\soe
$if not dexist output\%ds%\gtapingams\sop $call mkdir output\%ds%\gtapingams\sop
$if not dexist output\%ds%\gtapingams\gmr $call mkdir output\%ds%\gtapingams\gmr

$if not dexist output\%ds%\gtap		$call mkdir output\%ds%\gtap
$if not dexist output\%ds%\gtap\soe $call mkdir output\%ds%\gtap\soe
$if not dexist output\%ds%\gtap\sop $call mkdir output\%ds%\gtap\sop
$if not dexist output\%ds%\gtap\gmr $call mkdir output\%ds%\gtap\gmr


$call.async gams tgrid --thetadx=0.5 --rcalc=USA --mdl=soe --ds=%ds% --soextax=%soextax% o=output\%ds%\gtapingams\soe\USA.lst gdx=output\%ds%\gtapingams\soe\USA.gdx
$call sleep 2s
$call.async gams tgrid --thetadx=0.5 --rcalc=CHN --mdl=soe --ds=%ds% --soextax=%soextax% o=output\%ds%\gtapingams\soe\CHN.lst gdx=output\%ds%\gtapingams\soe\CHN.gdx
$call sleep 2s
$call.async gams tgrid --thetadx=0.5 --rcalc=USA --mdl=sop --ds=%ds% --soextax=%soextax% o=output\%ds%\gtapingams\sop\USA.lst gdx=output\%ds%\gtapingams\sop\USA.gdx
$call sleep 2s
$call.async gams tgrid --thetadx=0.5 --rcalc=CHN --mdl=sop --ds=%ds% --soextax=%soextax% o=output\%ds%\gtapingams\sop\CHN.lst gdx=output\%ds%\gtapingams\sop\CHN.gdx
$call sleep 2s
$call.async gams tgrid --thetadx=0.5 --rcalc=USA --mdl=gmr --ds=%ds% o=output\%ds%\gtapingams\gmr\USA.lst gdx=output\%ds%\gtapingams\gmr\USA.gdx
$call sleep 2s
$call.async gams tgrid --thetadx=0.5 --rcalc=CHN --mdl=gmr --ds=%ds% o=output\%ds%\gtapingams\gmr\CHN.lst gdx=output\%ds%\gtapingams\gmr\CHN.gdx
$call sleep 2s

$call.async gams tgrid --thetadx=1 --rcalc=USA --mdl=soe --ds=%ds% --soextax=%soextax% o=output\%ds%\gtap\soe\USA.lst gdx=output\%ds%\gtap\soe\USA.gdx
$call sleep 2s
$call.async gams tgrid --thetadx=1 --rcalc=CHN --mdl=soe --ds=%ds% --soextax=%soextax% o=output\%ds%\gtap\soe\CHN.lst gdx=output\%ds%\gtap\soe\CHN.gdx
$call sleep 2s
$call.async gams tgrid --thetadx=1 --rcalc=USA --mdl=sop --ds=%ds% --soextax=%soextax% o=output\%ds%\gtap\sop\USA.lst gdx=output\%ds%\gtap\sop\USA.gdx
$call sleep 2s
$call.async gams tgrid --thetadx=1 --rcalc=CHN --mdl=sop --ds=%ds% --soextax=%soextax% o=output\%ds%\gtap\sop\CHN.lst gdx=output\%ds%\gtap\sop\CHN.gdx
$call sleep 2s
$call.async gams tgrid --thetadx=1 --rcalc=USA --mdl=gmr --ds=%ds% o=output\%ds%\gtap\gmr\USA.lst gdx=output\%ds%\gtap\gmr\USA.gdx
$call sleep 2s
$call.async gams tgrid --thetadx=1 --rcalc=CHN --mdl=gmr --ds=%ds% o=output\%ds%\gtap\gmr\CHN.lst gdx=output\%ds%\gtap\gmr\CHN.gdx
$call sleep 2s

$exit
