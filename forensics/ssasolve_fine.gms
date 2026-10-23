$title	Run tgrid12 for the cases shown in Figures 12-13 (GTAP12, g20 dataset)

*	Run from the forensics directory:  gams run12
*	Each job writes output\<ds>\<mdl>\<rcalc>.lst/.gdx and <rcalc>_<mdl>_<ds>.data

$if not set ds $set ds g20_macro
$if not set soextax $set soextax yes

$if not dexist output_fine $call mkdir output_fine
$if not dexist output_fine\%ds% $call mkdir output_fine\%ds%
$if not dexist output_fine\%ds%\sate $call mkdir output_fine\%ds%\sate
$if not dexist output_fine\%ds%\soe $call mkdir output_fine\%ds%\soe
$if not dexist output_fine\%ds%\gmr $call mkdir output_fine\%ds%\gmr
$if not dexist output_fine\%ds%\sate_ls $call mkdir output_fine\%ds%\sate_ls
$if not dexist output_fine\%ds%\gmr_ls $call mkdir output_fine\%ds%\gmr_ls

*@ Start mdl=GMR (with the longest running time) first

* T0 are from Claudes estimates in Table 5 of the paper draft (23 October 2026)
$call.async gams tgrid_fine --rcalc=USA --t0=0 --mdl=gmr --ds=%ds% o=output_fine\%ds%\gmr\USA.lst gdx=output_fine\%ds%\gmr\USA.gdx
$call sleep 5s
$call.async gams tgrid_fine --rcalc=CHN --t0=0 --mdl=gmr --ds=%ds% o=output_fine\%ds%\gmr\CHN.lst gdx=output_fine\%ds%\gmr\CHN.gdx
$call sleep 5s
$call.async gams tgrid_fine --rcalc=ZAF --t0=5 --mdl=gmr --ds=%ds% o=output_fine\%ds%\gmr\ZAF.lst gdx=output_fine\%ds%\gmr\ZAF.gdx
$call sleep 5s
$call.async gams tgrid_fine --rcalc=ARG --t0=6 --mdl=gmr --ds=%ds% o=output_fine\%ds%\gmr\ARG.lst gdx=output_fine\%ds%\gmr\ARG.gdx
$call sleep 5s

$call.async gams tgrid_fine --rcalc=USA --t0=10 --mdl=gmr --fsubm=0.5 --ds=%ds% o=output_fine\%ds%\gmr_ls\USA.lst gdx=output_fine\%ds%\gmr_ls\USA.gdx
$call sleep 5s
$call.async gams tgrid_fine --rcalc=CHN --t0=11 --mdl=gmr --fsubm=0.5 --ds=%ds% o=output_fine\%ds%\gmr_ls\CHN.lst gdx=output_fine\%ds%\gmr_ls\CHN.gdx
$call sleep 5s
$call.async gams tgrid_fine --rcalc=ZAF --t0=19 --mdl=gmr --fsubm=0.5 --ds=%ds% o=output_fine\%ds%\gmr_ls\ZAF.lst gdx=output_fine\%ds%\gmr_ls\ZAF.gdx
$call sleep 5s
$call.async gams tgrid_fine --rcalc=ARG --t0=17 --mdl=gmr --fsubm=0.5 --ds=%ds% o=output_fine\%ds%\gmr_ls\ARG.lst gdx=output_fine\%ds%\gmr_ls\ARG.gdx
$call sleep 5s

*@ Diverse SOE versions

$call.async gams tgrid_fine --rcalc=USA --t0=0 --mdl=sate --ds=%ds% --soextax=%soextax% o=output_fine\%ds%\sate\USA.lst gdx=output_fine\%ds%\sate\USA.gdx
$call sleep 5s
$call.async gams tgrid_fine --rcalc=CHN --t0=0 --mdl=sate --ds=%ds% --soextax=%soextax% o=output_fine\%ds%\sate\CHN.lst gdx=output_fine\%ds%\sate\CHN.gdx
$call sleep 5s
$call.async gams tgrid_fine --rcalc=ZAF --t0=3 --mdl=sate --ds=%ds% --soextax=%soextax% o=output_fine\%ds%\sate\ZAF.lst gdx=output_fine\%ds%\sate\ZAF.gdx
$call sleep 5s
$call.async gams tgrid_fine --rcalc=ARG --t0=7 --mdl=sate --ds=%ds% --soextax=%soextax% o=output_fine\%ds%\sate\ARG.lst gdx=output_fine\%ds%\sate\ARG.gdx
$call sleep 5s

$call.async gams tgrid_fine --rcalc=USA --t0=9 --mdl=sate --fsubm=0.5 --ds=%ds% --soextax=%soextax% o=output_fine\%ds%\sate_ls\USA.lst gdx=output_fine\%ds%\sate_ls\USA.gdx
$call sleep 5s
$call.async gams tgrid_fine --rcalc=CHN --t0=10 --mdl=sate --fsubm=0.5 --ds=%ds% --soextax=%soextax% o=output_fine\%ds%\sate_ls\CHN.lst gdx=output_fine\%ds%\sate_ls\CHN.gdx
$call sleep 5s
$call.async gams tgrid_fine --rcalc=ZAF --t0=12 --mdl=sate --fsubm=0.5 --ds=%ds% --soextax=%soextax% o=output_fine\%ds%\sate_ls\ZAF.lst gdx=output_fine\%ds%\sate_ls\ZAF.gdx
$call sleep 5s
$call.async gams tgrid_fine --rcalc=ARG --t0=18 --mdl=sate --fsubm=0.5 --ds=%ds% --soextax=%soextax% o=output_fine\%ds%\sate_ls\ARG.lst gdx=output_fine\%ds%\sate_ls\ARG.gdx
$call sleep 5s

$call.async gams tgrid_fine --rcalc=ARG --t0=1 --mdl=soe --ds=%ds% --soextax=%soextax% o=output_fine\%ds%\soe\ARG.lst gdx=output_fine\%ds%\soe\ARG.gdx
$call sleep 5s
