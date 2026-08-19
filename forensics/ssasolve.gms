$if not dexist output\g20\soe $call mkdir output\g20\soe
$if not dexist output\g20\gmr $call mkdir output\g20\gmr
$if not dexist output\g20_macro\soe $call mkdir output\g20_macro\soe
$if not dexist output\g20_macro\gmr $call mkdir output\g20_macro\gmr


$call.async gams tgrid --rcalc=USA --mdl=soe --ds=g20 o=output\g20\soe\USA.lst gdx=output\g20\soe\USA.gdx
$call sleep 1s

$call.async gams tgrid --rcalc=CHN --mdl=soe --ds=g20 o=output\g20\soe\CHN.lst gdx=output\g20\soe\CHN.gdx
$call sleep 1s

$call.async gams tgrid --rcalc=USA --mdl=gmr --ds=g20 o=output\g20\gmr\USA.lst gdx=output\g20\gmr\USA.gdx
$call sleep 1s

$call.async gams tgrid --rcalc=CHN --mdl=gmr --ds=g20 o=output\g20\gmr\CHN.lst gdx=output\g20\gmr\CHN.gdx
$call sleep 1s

$call.async gams tgrid --rcalc=USA --mdl=soe --ds=g20_macro o=output\g20_macro\soe\USA.lst gdx=output\g20_macro\soe\USA.gdx
$call sleep 1s

$call.async gams tgrid --rcalc=CHN --mdl=soe --ds=g20_macro o=output\g20_macro\soe\CHN.lst gdx=output\g20_macro\soe\CHN.gdx
$call sleep 1s

$call.async gams tgrid --rcalc=USA --mdl=gmr --ds=g20_macro o=output\g20_macro\gmr\USA.lst gdx=output\g20_macro\gmr\USA.gdx
$call sleep 1s

$call.async gams tgrid --rcalc=CHN --mdl=gmr --ds=g20_macro o=output\g20_macro\gmr\CHN.lst gdx=output\g20_macro\gmr\CHN.gdx
$call sleep 1s

$exit

