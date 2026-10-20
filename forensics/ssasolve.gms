$title	Run tgrid12 for the cases shown in Figures 12-13 (GTAP12, g20 dataset)

*	Run from the forensics directory:  gams run12
*	Each job writes output\<ds>\<mdl>\<rcalc>.lst/.gdx and <rcalc>_<mdl>_<ds>.data

$if not set ds $set ds g20
$if not set soextax $set soextax yes

$if not dexist output\%ds%\gtapingams	$call mkdir output\%ds%\gtapingams
$if not dexist output\%ds%\gtapingams\soe $call mkdir output\%ds%\gtapingams\soe
$if not dexist output\%ds%\gtapingams\sate $call mkdir output\%ds%\gtapingams\sate
$if not dexist output\%ds%\gtapingams\sate2 $call mkdir output\%ds%\gtapingams\sate2
$if not dexist output\%ds%\gtapingams\gmr $call mkdir output\%ds%\gtapingams\gmr
$if not dexist output\%ds%\gtapingams\gmr_ls $call mkdir output\%ds%\gtapingams\gmr_ls

$if not dexist output\%ds%\gtap		$call mkdir output\%ds%\gtap
$if not dexist output\%ds%\gtap\soe $call mkdir output\%ds%\gtap\soe
$if not dexist output\%ds%\gtap\sate $call mkdir output\%ds%\gtap\sate
$if not dexist output\%ds%\gtap\sate2 $call mkdir output\%ds%\gtap\sate2
$if not dexist output\%ds%\gtap\gmr $call mkdir output\%ds%\gtap\gmr
$if not dexist output\%ds%\gtap\gmr_ls $call mkdir output\%ds%\gtap\gmr_ls

*@ Start mdl=GMR (with the longest running time) first

*	Lanz and Rutherfords GTAPinGAMS with thetadx=0.5
$call.async gams tgrid --thetadx=0.5 --rcalc=USA --mdl=gmr --ds=%ds% o=output\%ds%\gtapingams\gmr\USA.lst gdx=output\%ds%\gtapingams\gmr\USA.gdx
$call sleep 5s
$call.async gams tgrid --thetadx=0.5 --rcalc=ZAF --mdl=gmr --ds=%ds% o=output\%ds%\gtapingams\gmr\ZAF.lst gdx=output\%ds%\gtapingams\gmr\ZAF.gdx
$call sleep 5s
$call.async gams tgrid --thetadx=0.5 --rcalc=ARG --mdl=gmr --ds=%ds% o=output\%ds%\gtapingams\gmr\ARG.lst gdx=output\%ds%\gtapingams\gmr\ARG.gdx
$call sleep 5s
$call.async gams tgrid --thetadx=0.5 --rcalc=CHN --mdl=gmr --ds=%ds% o=output\%ds%\gtapingams\gmr\CHN.lst gdx=output\%ds%\gtapingams\gmr\CHN.gdx
$call sleep 5s
$call.async gams tgrid --thetadx=0.5 --rcalc=USA --mdl=gmr --fsubm=0.5 --ds=%ds% o=output\%ds%\gtapingams\gmr_ls\USA.lst gdx=output\%ds%\gtapingams\gmr_ls\USA.gdx
$call sleep 5s
$call.async gams tgrid --thetadx=0.5 --rcalc=ZAF --mdl=gmr --fsubm=0.5 --ds=%ds% o=output\%ds%\gtapingams\gmr_ls\ZAF.lst gdx=output\%ds%\gtapingams\gmr_ls\ZAF.gdx
$call sleep 5s
$call.async gams tgrid --thetadx=0.5 --rcalc=ARG --mdl=gmr --fsubm=0.5 --ds=%ds% o=output\%ds%\gtapingams\gmr_ls\ARG.lst gdx=output\%ds%\gtapingams\gmr_ls\ARG.gdx
$call sleep 5s
$call.async gams tgrid --thetadx=0.5 --rcalc=CHN --mdl=gmr --fsubm=0.5 --ds=%ds% o=output\%ds%\gtapingams\gmr_ls\CHN.lst gdx=output\%ds%\gtapingams\gmr_ls\CHN.gdx
$call sleep 5s

*	Like GTAP with thetadx=1
$call.async gams tgrid --thetadx=1 --rcalc=USA --mdl=gmr --ds=%ds% o=output\%ds%\gtap\gmr\USA.lst gdx=output\%ds%\gtap\gmr\USA.gdx
$call sleep 5s
$call.async gams tgrid --thetadx=1 --rcalc=ZAF --mdl=gmr --ds=%ds% o=output\%ds%\gtap\gmr\ZAF.lst gdx=output\%ds%\gtap\gmr\ZAF.gdx
$call sleep 5s
$call.async gams tgrid --thetadx=1 --rcalc=ARG --mdl=gmr --ds=%ds% o=output\%ds%\gtap\gmr\ARG.lst gdx=output\%ds%\gtap\gmr\ARG.gdx
$call sleep 5s
$call.async gams tgrid --thetadx=1 --rcalc=CHN --mdl=gmr --ds=%ds% o=output\%ds%\gtap\gmr\CHN.lst gdx=output\%ds%\gtap\gmr\CHN.gdx
$call sleep 5s
$call.async gams tgrid --thetadx=1 --rcalc=USA --mdl=gmr --fsubm=0.5 --ds=%ds% o=output\%ds%\gtap\gmr_ls\USA.lst gdx=output\%ds%\gtap\gmr_ls\USA.gdx
$call sleep 5s
$call.async gams tgrid --thetadx=1 --rcalc=ZAF --mdl=gmr --fsubm=0.5 --ds=%ds% o=output\%ds%\gtap\gmr_ls\ZAF.lst gdx=output\%ds%\gtap\gmr_ls\ZAF.gdx
$call sleep 5s
$call.async gams tgrid --thetadx=1 --rcalc=ARG --mdl=gmr --fsubm=0.5 --ds=%ds% o=output\%ds%\gtap\gmr_ls\ARG.lst gdx=output\%ds%\gtap\gmr_ls\ARG.gdx
$call sleep 5s
$call.async gams tgrid --thetadx=1 --rcalc=CHN --mdl=gmr --fsubm=0.5 --ds=%ds% o=output\%ds%\gtap\gmr_ls\CHN.lst gdx=output\%ds%\gtap\gmr_ls\CHN.gdx
$call sleep 5s


*@ Diverse SOE versions

*	Lanz and Rutherfords GTAPinGAMS with thetadx=0.5
$call.async gams tgrid --thetadx=0.5 --rcalc=USA --mdl=soe --ds=%ds% --soextax=%soextax% o=output\%ds%\gtapingams\soe\USA.lst gdx=output\%ds%\gtapingams\soe\USA.gdx
$call sleep 5s
$call.async gams tgrid --thetadx=0.5 --rcalc=ZAF --mdl=soe --ds=%ds% --soextax=%soextax% o=output\%ds%\gtapingams\soe\ZAF.lst gdx=output\%ds%\gtapingams\soe\ZAF.gdx
$call sleep 5s
$call.async gams tgrid --thetadx=0.5 --rcalc=ARG --mdl=soe --ds=%ds% --soextax=%soextax% o=output\%ds%\gtapingams\soe\ARG.lst gdx=output\%ds%\gtapingams\soe\ARG.gdx
$call sleep 5s
$call.async gams tgrid --thetadx=0.5 --rcalc=CHN --mdl=soe --ds=%ds% --soextax=%soextax% o=output\%ds%\gtapingams\soe\CHN.lst gdx=output\%ds%\gtapingams\soe\CHN.gdx
$call sleep 5s
$call.async gams tgrid --thetadx=0.5 --rcalc=USA --mdl=sate --ds=%ds% --soextax=%soextax% o=output\%ds%\gtapingams\sate\USA.lst gdx=output\%ds%\gtapingams\sate\USA.gdx
$call sleep 5s
$call.async gams tgrid --thetadx=0.5 --rcalc=ZAF --mdl=sate --ds=%ds% --soextax=%soextax% o=output\%ds%\gtapingams\sate\ZAF.lst gdx=output\%ds%\gtapingams\sate\ZAF.gdx
$call sleep 5s
$call.async gams tgrid --thetadx=0.5 --rcalc=ARG --mdl=sate --ds=%ds% --soextax=%soextax% o=output\%ds%\gtapingams\sate\ARG.lst gdx=output\%ds%\gtapingams\sate\ARG.gdx
$call sleep 5s
$call.async gams tgrid --thetadx=0.5 --rcalc=CHN --mdl=sate --ds=%ds% --soextax=%soextax% o=output\%ds%\gtapingams\sate\CHN.lst gdx=output\%ds%\gtapingams\sate\CHN.gdx
$call sleep 5s
$call.async gams tgrid --thetadx=0.5 --rcalc=USA --mdl=sate2 --ds=%ds% --soextax=%soextax% o=output\%ds%\gtapingams\sate2\USA.lst gdx=output\%ds%\gtapingams\sate2\USA.gdx
$call sleep 5s
$call.async gams tgrid --thetadx=0.5 --rcalc=ZAF --mdl=sate2 --ds=%ds% --soextax=%soextax% o=output\%ds%\gtapingams\sate2\ZAF.lst gdx=output\%ds%\gtapingams\sate2\ZAF.gdx
$call sleep 5s
$call.async gams tgrid --thetadx=0.5 --rcalc=ARG --mdl=sate2 --ds=%ds% --soextax=%soextax% o=output\%ds%\gtapingams\sate2\ARG.lst gdx=output\%ds%\gtapingams\sate2\ARG.gdx
$call sleep 5s
$call.async gams tgrid --thetadx=0.5 --rcalc=CHN --mdl=sate2 --ds=%ds% --soextax=%soextax% o=output\%ds%\gtapingams\sate2\CHN.lst gdx=output\%ds%\gtapingams\sate2\CHN.gdx
$call sleep 5s

*	Like GTAP with thetadx=1
$call.async gams tgrid --thetadx=1 --rcalc=USA --mdl=soe --ds=%ds% --soextax=%soextax% o=output\%ds%\gtap\soe\USA.lst gdx=output\%ds%\gtap\soe\USA.gdx
$call sleep 5s
$call.async gams tgrid --thetadx=1 --rcalc=ZAF --mdl=soe --ds=%ds% --soextax=%soextax% o=output\%ds%\gtap\soe\ZAF.lst gdx=output\%ds%\gtap\soe\ZAF.gdx
$call sleep 5s
$call.async gams tgrid --thetadx=1 --rcalc=ARG --mdl=soe --ds=%ds% --soextax=%soextax% o=output\%ds%\gtap\soe\ARG.lst gdx=output\%ds%\gtap\soe\ARG.gdx
$call sleep 5s
$call.async gams tgrid --thetadx=1 --rcalc=CHN --mdl=soe --ds=%ds% --soextax=%soextax% o=output\%ds%\gtap\soe\CHN.lst gdx=output\%ds%\gtap\soe\CHN.gdx
$call sleep 5s
$call.async gams tgrid --thetadx=1 --rcalc=USA --mdl=sate --ds=%ds% --soextax=%soextax% o=output\%ds%\gtap\sate\USA.lst gdx=output\%ds%\gtap\sate\USA.gdx
$call sleep 5s
$call.async gams tgrid --thetadx=1 --rcalc=ZAF --mdl=sate --ds=%ds% --soextax=%soextax% o=output\%ds%\gtap\sate\ZAF.lst gdx=output\%ds%\gtap\sate\ZAF.gdx
$call sleep 5s
$call.async gams tgrid --thetadx=1 --rcalc=ARG --mdl=sate --ds=%ds% --soextax=%soextax% o=output\%ds%\gtap\sate\ARG.lst gdx=output\%ds%\gtap\sate\ARG.gdx
$call sleep 5s
$call.async gams tgrid --thetadx=1 --rcalc=CHN --mdl=sate --ds=%ds% --soextax=%soextax% o=output\%ds%\gtap\sate\CHN.lst gdx=output\%ds%\gtap\sate\CHN.gdx
$call sleep 5s
$call.async gams tgrid --thetadx=1 --rcalc=USA --mdl=sate2 --ds=%ds% --soextax=%soextax% o=output\%ds%\gtap\sate2\USA.lst gdx=output\%ds%\gtap\sate2\USA.gdx
$call sleep 5s
$call.async gams tgrid --thetadx=1 --rcalc=ZAF --mdl=sate2 --ds=%ds% --soextax=%soextax% o=output\%ds%\gtap\sate2\ZAF.lst gdx=output\%ds%\gtap\sate2\ZAF.gdx
$call sleep 5s
$call.async gams tgrid --thetadx=1 --rcalc=ARG --mdl=sate2 --ds=%ds% --soextax=%soextax% o=output\%ds%\gtap\sate2\ARG.lst gdx=output\%ds%\gtap\sate2\ARG.gdx
$call sleep 5s
$call.async gams tgrid --thetadx=1 --rcalc=CHN --mdl=sate2 --ds=%ds% --soextax=%soextax% o=output\%ds%\gtap\sate2\CHN.lst gdx=output\%ds%\gtap\sate2\CHN.gdx
$call sleep 5s
$exit
