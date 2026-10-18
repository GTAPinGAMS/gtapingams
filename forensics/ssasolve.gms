$title	Run tgrid12 for the cases shown in Figures 12-13 (GTAP12, g20 dataset)

*	Run from the forensics directory:  gams run12
*	Each job writes output\<ds>\<mdl>\<rcalc>.lst/.gdx and <rcalc>_<mdl>_<ds>.data

$if not set ds $set ds g20
$if not set soextax $set soextax yes

$if not dexist output\%ds%\gtapingams	$call mkdir output\%ds%\gtapingams
$if not dexist output\%ds%\gtapingams\soe $call mkdir output\%ds%\gtapingams\soe
$if not dexist output\%ds%\gtapingams\sop $call mkdir output\%ds%\gtapingams\sop
$if not dexist output\%ds%\gtapingams\sop2 $call mkdir output\%ds%\gtapingams\sop2
$if not dexist output\%ds%\gtapingams\gmr $call mkdir output\%ds%\gtapingams\gmr
$if not dexist output\%ds%\gtapingams\gmr_ls $call mkdir output\%ds%\gtapingams\gmr_ls

$if not dexist output\%ds%\gtap		$call mkdir output\%ds%\gtap
$if not dexist output\%ds%\gtap\soe $call mkdir output\%ds%\gtap\soe
$if not dexist output\%ds%\gtap\sop $call mkdir output\%ds%\gtap\sop
$if not dexist output\%ds%\gtap\sop2 $call mkdir output\%ds%\gtap\sop2
$if not dexist output\%ds%\gtap\gmr $call mkdir output\%ds%\gtap\gmr
$if not dexist output\%ds%\gtap\gmr_ls $call mkdir output\%ds%\gtap\gmr_ls

*@ Start mdl=GMR (with the longest running time) first

*	Lanz and Rutherfords GTAPinGAMS with thetadx=0.5
$call.async gams tgrid --thetadx=0.5 --rcalc=USA --mdl=gmr --ds=%ds% o=output\%ds%\gtapingams\gmr\USA.lst gdx=output\%ds%\gtapingams\gmr\USA.gdx
$call sleep 2s
$call.async gams tgrid --thetadx=0.5 --rcalc=ZAF --mdl=gmr --ds=%ds% o=output\%ds%\gtapingams\gmr\ZAF.lst gdx=output\%ds%\gtapingams\gmr\ZAF.gdx
$call sleep 2s
$call.async gams tgrid --thetadx=0.5 --rcalc=ARG --mdl=gmr --ds=%ds% o=output\%ds%\gtapingams\gmr\ARG.lst gdx=output\%ds%\gtapingams\gmr\ARG.gdx
$call sleep 2s
$call.async gams tgrid --thetadx=0.5 --rcalc=CHN --mdl=gmr --ds=%ds% o=output\%ds%\gtapingams\gmr\CHN.lst gdx=output\%ds%\gtapingams\gmr\CHN.gdx
$call sleep 2s
$call.async gams tgrid --thetadx=0.5 --rcalc=USA --mdl=gmr --fsubm=0.5 --ds=%ds% o=output\%ds%\gtapingams\gmr_ls\USA.lst gdx=output\%ds%\gtapingams\gmr_ls\USA.gdx
$call sleep 2s
$call.async gams tgrid --thetadx=0.5 --rcalc=ZAF --mdl=gmr --fsubm=0.5 --ds=%ds% o=output\%ds%\gtapingams\gmr_ls\ZAF.lst gdx=output\%ds%\gtapingams\gmr_ls\ZAF.gdx
$call sleep 2s
$call.async gams tgrid --thetadx=0.5 --rcalc=ARG --mdl=gmr --fsubm=0.5 --ds=%ds% o=output\%ds%\gtapingams\gmr_ls\ARG.lst gdx=output\%ds%\gtapingams\gmr_ls\ARG.gdx
$call sleep 2s
$call.async gams tgrid --thetadx=0.5 --rcalc=CHN --mdl=gmr --fsubm=0.5 --ds=%ds% o=output\%ds%\gtapingams\gmr_ls\CHN.lst gdx=output\%ds%\gtapingams\gmr_ls\CHN.gdx
$call sleep 2s

*	Like GTAP with thetadx=1
$call.async gams tgrid --thetadx=1 --rcalc=USA --mdl=gmr --ds=%ds% o=output\%ds%\gtap\gmr\USA.lst gdx=output\%ds%\gtap\gmr\USA.gdx
$call sleep 2s
$call.async gams tgrid --thetadx=1 --rcalc=ZAF --mdl=gmr --ds=%ds% o=output\%ds%\gtap\gmr\ZAF.lst gdx=output\%ds%\gtap\gmr\ZAF.gdx
$call sleep 2s
$call.async gams tgrid --thetadx=1 --rcalc=ARG --mdl=gmr --ds=%ds% o=output\%ds%\gtap\gmr\ARG.lst gdx=output\%ds%\gtap\gmr\ARG.gdx
$call sleep 2s
$call.async gams tgrid --thetadx=1 --rcalc=CHN --mdl=gmr --ds=%ds% o=output\%ds%\gtap\gmr\CHN.lst gdx=output\%ds%\gtap\gmr\CHN.gdx
$call sleep 2s
$call.async gams tgrid --thetadx=1 --rcalc=USA --mdl=gmr --fsubm=0.5 --ds=%ds% o=output\%ds%\gtap\gmr_ls\USA.lst gdx=output\%ds%\gtap\gmr_ls\USA.gdx
$call sleep 2s
$call.async gams tgrid --thetadx=1 --rcalc=ZAF --mdl=gmr --fsubm=0.5 --ds=%ds% o=output\%ds%\gtap\gmr_ls\ZAF.lst gdx=output\%ds%\gtap\gmr_ls\ZAF.gdx
$call sleep 2s
$call.async gams tgrid --thetadx=1 --rcalc=ARG --mdl=gmr --fsubm=0.5 --ds=%ds% o=output\%ds%\gtap\gmr_ls\ARG.lst gdx=output\%ds%\gtap\gmr_ls\ARG.gdx
$call sleep 2s
$call.async gams tgrid --thetadx=1 --rcalc=CHN --mdl=gmr --fsubm=0.5 --ds=%ds% o=output\%ds%\gtap\gmr_ls\CHN.lst gdx=output\%ds%\gtap\gmr_ls\CHN.gdx
$call sleep 2s


*@ Diverse SOE versions

*	Lanz and Rutherfords GTAPinGAMS with thetadx=0.5
$call.async gams tgrid --thetadx=0.5 --rcalc=USA --mdl=soe --ds=%ds% --soextax=%soextax% o=output\%ds%\gtapingams\soe\USA.lst gdx=output\%ds%\gtapingams\soe\USA.gdx
$call sleep 2s
$call.async gams tgrid --thetadx=0.5 --rcalc=ZAF --mdl=soe --ds=%ds% --soextax=%soextax% o=output\%ds%\gtapingams\soe\ZAF.lst gdx=output\%ds%\gtapingams\soe\ZAF.gdx
$call sleep 2s
$call.async gams tgrid --thetadx=0.5 --rcalc=ARG --mdl=soe --ds=%ds% --soextax=%soextax% o=output\%ds%\gtapingams\soe\ARG.lst gdx=output\%ds%\gtapingams\soe\ARG.gdx
$call sleep 2s
$call.async gams tgrid --thetadx=0.5 --rcalc=CHN --mdl=soe --ds=%ds% --soextax=%soextax% o=output\%ds%\gtapingams\soe\CHN.lst gdx=output\%ds%\gtapingams\soe\CHN.gdx
$call sleep 2s
$call.async gams tgrid --thetadx=0.5 --rcalc=USA --mdl=sop --ds=%ds% --soextax=%soextax% o=output\%ds%\gtapingams\sop\USA.lst gdx=output\%ds%\gtapingams\sop\USA.gdx
$call sleep 2s
$call.async gams tgrid --thetadx=0.5 --rcalc=ZAF --mdl=sop --ds=%ds% --soextax=%soextax% o=output\%ds%\gtapingams\sop\ZAF.lst gdx=output\%ds%\gtapingams\sop\ZAF.gdx
$call sleep 2s
$call.async gams tgrid --thetadx=0.5 --rcalc=ARG --mdl=sop --ds=%ds% --soextax=%soextax% o=output\%ds%\gtapingams\sop\ARG.lst gdx=output\%ds%\gtapingams\sop\ARG.gdx
$call sleep 2s
$call.async gams tgrid --thetadx=0.5 --rcalc=CHN --mdl=sop --ds=%ds% --soextax=%soextax% o=output\%ds%\gtapingams\sop\CHN.lst gdx=output\%ds%\gtapingams\sop\CHN.gdx
$call sleep 2s
$call.async gams tgrid --thetadx=0.5 --rcalc=USA --mdl=sop2 --ds=%ds% --soextax=%soextax% o=output\%ds%\gtapingams\sop2\USA.lst gdx=output\%ds%\gtapingams\sop2\USA.gdx
$call sleep 2s
$call.async gams tgrid --thetadx=0.5 --rcalc=ZAF --mdl=sop2 --ds=%ds% --soextax=%soextax% o=output\%ds%\gtapingams\sop2\ZAF.lst gdx=output\%ds%\gtapingams\sop2\ZAF.gdx
$call sleep 2s
$call.async gams tgrid --thetadx=0.5 --rcalc=ARG --mdl=sop2 --ds=%ds% --soextax=%soextax% o=output\%ds%\gtapingams\sop2\ARG.lst gdx=output\%ds%\gtapingams\sop2\ARG.gdx
$call sleep 2s
$call.async gams tgrid --thetadx=0.5 --rcalc=CHN --mdl=sop2 --ds=%ds% --soextax=%soextax% o=output\%ds%\gtapingams\sop2\CHN.lst gdx=output\%ds%\gtapingams\sop2\CHN.gdx
$call sleep 2s

*	Like GTAP with thetadx=1
$call.async gams tgrid --thetadx=1 --rcalc=USA --mdl=soe --ds=%ds% --soextax=%soextax% o=output\%ds%\gtap\soe\USA.lst gdx=output\%ds%\gtap\soe\USA.gdx
$call sleep 2s
$call.async gams tgrid --thetadx=1 --rcalc=ZAF --mdl=soe --ds=%ds% --soextax=%soextax% o=output\%ds%\gtap\soe\ZAF.lst gdx=output\%ds%\gtap\soe\ZAF.gdx
$call sleep 2s
$call.async gams tgrid --thetadx=1 --rcalc=ARG --mdl=soe --ds=%ds% --soextax=%soextax% o=output\%ds%\gtap\soe\ARG.lst gdx=output\%ds%\gtap\soe\ARG.gdx
$call sleep 2s
$call.async gams tgrid --thetadx=1 --rcalc=CHN --mdl=soe --ds=%ds% --soextax=%soextax% o=output\%ds%\gtap\soe\CHN.lst gdx=output\%ds%\gtap\soe\CHN.gdx
$call sleep 2s
$call.async gams tgrid --thetadx=1 --rcalc=USA --mdl=sop --ds=%ds% --soextax=%soextax% o=output\%ds%\gtap\sop\USA.lst gdx=output\%ds%\gtap\sop\USA.gdx
$call sleep 2s
$call.async gams tgrid --thetadx=1 --rcalc=ZAF --mdl=sop --ds=%ds% --soextax=%soextax% o=output\%ds%\gtap\sop\ZAF.lst gdx=output\%ds%\gtap\sop\ZAF.gdx
$call sleep 2s
$call.async gams tgrid --thetadx=1 --rcalc=ARG --mdl=sop --ds=%ds% --soextax=%soextax% o=output\%ds%\gtap\sop\ARG.lst gdx=output\%ds%\gtap\sop\ARG.gdx
$call sleep 2s
$call.async gams tgrid --thetadx=1 --rcalc=CHN --mdl=sop --ds=%ds% --soextax=%soextax% o=output\%ds%\gtap\sop\CHN.lst gdx=output\%ds%\gtap\sop\CHN.gdx
$call sleep 2s
$call.async gams tgrid --thetadx=1 --rcalc=USA --mdl=sop2 --ds=%ds% --soextax=%soextax% o=output\%ds%\gtap\sop2\USA.lst gdx=output\%ds%\gtap\sop2\USA.gdx
$call sleep 2s
$call.async gams tgrid --thetadx=1 --rcalc=ZAF --mdl=sop2 --ds=%ds% --soextax=%soextax% o=output\%ds%\gtap\sop2\ZAF.lst gdx=output\%ds%\gtap\sop2\ZAF.gdx
$call sleep 2s
$call.async gams tgrid --thetadx=1 --rcalc=ARG --mdl=sop2 --ds=%ds% --soextax=%soextax% o=output\%ds%\gtap\sop2\ARG.lst gdx=output\%ds%\gtap\sop2\ARG.gdx
$call sleep 2s
$call.async gams tgrid --thetadx=1 --rcalc=CHN --mdl=sop2 --ds=%ds% --soextax=%soextax% o=output\%ds%\gtap\sop2\CHN.lst gdx=output\%ds%\gtap\sop2\CHN.gdx
$call sleep 2s
$exit
