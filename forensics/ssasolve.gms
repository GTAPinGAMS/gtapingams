$title	Run tgrid12 for the cases shown in Figures 12-13 (GTAP12, g20 dataset)

*	Run from the forensics directory:  gams run12
*	Each job writes output\<ds>\<mdl>\<rcalc>.lst/.gdx and <rcalc>_<mdl>_<ds>.data

$if not set ds $set ds g20
$if not set soextax $set soextax yes

$if not dexist output\%ds%\soe $call mkdir output\%ds%\soe
$if not dexist output\%ds%\sate $call mkdir output\%ds%\sate
$if not dexist output\%ds%\sate2 $call mkdir output\%ds%\sate2
$if not dexist output\%ds%\gmr $call mkdir output\%ds%\gmr
$if not dexist output\%ds%\gmr_ls $call mkdir output\%ds%\gmr_ls
$if not dexist output\%ds%\sate_ls $call mkdir output\%ds%\sate_ls

*@ Start mdl=GMR (with the longest running time) first

*	Lanz and Rutherfords GTAPinGAMS with thetadx=0.5
$call.async gams tgrid --rcalc=USA --mdl=gmr --ds=%ds% o=output\%ds%\gmr\USA.lst gdx=output\%ds%\gmr\USA.gdx
$call sleep 5s
$call.async gams tgrid --rcalc=ZAF --mdl=gmr --ds=%ds% o=output\%ds%\gmr\ZAF.lst gdx=output\%ds%\gmr\ZAF.gdx
$call sleep 5s
$call.async gams tgrid --rcalc=ARG --mdl=gmr --ds=%ds% o=output\%ds%\gmr\ARG.lst gdx=output\%ds%\gmr\ARG.gdx
$call sleep 5s
$call.async gams tgrid --rcalc=CHN --mdl=gmr --ds=%ds% o=output\%ds%\gmr\CHN.lst gdx=output\%ds%\gmr\CHN.gdx
$call sleep 5s
$call.async gams tgrid --rcalc=USA --mdl=gmr --fsubm=0.5 --ds=%ds% o=output\%ds%\gmr_ls\USA.lst gdx=output\%ds%\gmr_ls\USA.gdx
$call sleep 5s
$call.async gams tgrid --rcalc=ZAF --mdl=gmr --fsubm=0.5 --ds=%ds% o=output\%ds%\gmr_ls\ZAF.lst gdx=output\%ds%\gmr_ls\ZAF.gdx
$call sleep 5s
$call.async gams tgrid --rcalc=ARG --mdl=gmr --fsubm=0.5 --ds=%ds% o=output\%ds%\gmr_ls\ARG.lst gdx=output\%ds%\gmr_ls\ARG.gdx
$call sleep 5s
$call.async gams tgrid --rcalc=CHN --mdl=gmr --fsubm=0.5 --ds=%ds% o=output\%ds%\gmr_ls\CHN.lst gdx=output\%ds%\gmr_ls\CHN.gdx
$call sleep 5s

*@ Diverse SOE versions

*	Lanz and Rutherfords GTAPinGAMS with thetadx=0.5
$call.async gams tgrid --rcalc=USA --mdl=soe --ds=%ds% --soextax=%soextax% o=output\%ds%\soe\USA.lst gdx=output\%ds%\soe\USA.gdx
$call sleep 5s
$call.async gams tgrid --rcalc=ZAF --mdl=soe --ds=%ds% --soextax=%soextax% o=output\%ds%\soe\ZAF.lst gdx=output\%ds%\soe\ZAF.gdx
$call sleep 5s
$call.async gams tgrid --rcalc=ARG --mdl=soe --ds=%ds% --soextax=%soextax% o=output\%ds%\soe\ARG.lst gdx=output\%ds%\soe\ARG.gdx
$call sleep 5s
$call.async gams tgrid --rcalc=CHN --mdl=soe --ds=%ds% --soextax=%soextax% o=output\%ds%\soe\CHN.lst gdx=output\%ds%\soe\CHN.gdx
$call sleep 5s
$call.async gams tgrid --rcalc=USA --mdl=sate --ds=%ds% --soextax=%soextax% o=output\%ds%\sate\USA.lst gdx=output\%ds%\sate\USA.gdx
$call sleep 5s
$call.async gams tgrid --rcalc=ZAF --mdl=sate --ds=%ds% --soextax=%soextax% o=output\%ds%\sate\ZAF.lst gdx=output\%ds%\sate\ZAF.gdx
$call sleep 5s
$call.async gams tgrid --rcalc=ARG --mdl=sate --ds=%ds% --soextax=%soextax% o=output\%ds%\sate\ARG.lst gdx=output\%ds%\sate\ARG.gdx
$call sleep 5s
$call.async gams tgrid --rcalc=CHN --mdl=sate --ds=%ds% --soextax=%soextax% o=output\%ds%\sate\CHN.lst gdx=output\%ds%\sate\CHN.gdx
$call sleep 5s

$call.async gams tgrid --rcalc=USA --mdl=sate --fsubm=0.5 --ds=%ds% --soextax=%soextax% o=output\%ds%\sate_ls\USA.lst gdx=output\%ds%\sate_ls\USA.gdx
$call sleep 5s
$call.async gams tgrid --rcalc=ZAF --mdl=sate --fsubm=0.5 --ds=%ds% --soextax=%soextax% o=output\%ds%\sate_ls\ZAF.lst gdx=output\%ds%\sate_ls\ZAF.gdx
$call sleep 5s
$call.async gams tgrid --rcalc=ARG --mdl=sate --fsubm=0.5 --ds=%ds% --soextax=%soextax% o=output\%ds%\sate_ls\ARG.lst gdx=output\%ds%\sate_ls\ARG.gdx
$call sleep 5s
$call.async gams tgrid --rcalc=CHN --mdl=sate --fsubm=0.5 --ds=%ds% --soextax=%soextax% o=output\%ds%\sate_ls\CHN.lst gdx=output\%ds%\sate_ls\CHN.gdx
$call sleep 5s

$call.async gams tgrid --rcalc=USA --mdl=sate2 --ds=%ds% --soextax=%soextax% o=output\%ds%\sate2\USA.lst gdx=output\%ds%\sate2\USA.gdx
$call sleep 5s
$call.async gams tgrid --rcalc=ZAF --mdl=sate2 --ds=%ds% --soextax=%soextax% o=output\%ds%\sate2\ZAF.lst gdx=output\%ds%\sate2\ZAF.gdx
$call sleep 5s
$call.async gams tgrid --rcalc=ARG --mdl=sate2 --ds=%ds% --soextax=%soextax% o=output\%ds%\sate2\ARG.lst gdx=output\%ds%\sate2\ARG.gdx
$call sleep 5s
$call.async gams tgrid --rcalc=CHN --mdl=sate2 --ds=%ds% --soextax=%soextax% o=output\%ds%\sate2\CHN.lst gdx=output\%ds%\sate2\CHN.gdx
$call sleep 5s

$exit
