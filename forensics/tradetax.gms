$title	Data for Figures 10 and 11 of Lanz & Rutherford (2016): Trade Taxes on Imports

*	Run from the forensics directory, e.g.:
*	   gams tradetax --ds=g20 --yr=23
*	Writes <r>_commodity_m.data and <r>_txtm_m.data (same columns as the
*	files in the paper's latex/figures directory) plus tradetax.gdx.
*
*	Definitions (they reproduce the GTAP9 numbers in the paper exactly):
*	  tm_m  = 100 * tariff revenue / imports at cif world prices
*	  tx_m  = 100 * export-tax revenue of the exporter / vxmd   (rtxs<0 = tax)
*	  tm$   = imports gross of tariff, i.e. cif*(1+rtms), in $bn.
*	          NB: the paper labels this "Tariff revenue ($M)", but the
*	          plotted numbers are tariff-inclusive import values in $bn.
*	          The actual tariff revenue is reported as tmrev (last column).

$set fs %system.dirsep%
$if not set yr $set yr 23
$if not set ds $set ds g20
$if not set code $set code ..%fs%code%fs%
$include %code%gtap12data

set	rcalc(r)	Regions to report /usa, chn, zaf, arg/,
	item		/tm_m, tx_m, "tm$", tmrev, cif/;

parameter
	cif(i,s,r)	Imports at cif world prices,
	bycom(r,i,item)	Trade taxes on imports by commodity,
	byreg(r,s,item)	Trade taxes on imports by partner,
	ave(r,item)	Averages over all imports;

cif(i,s,r) = vxmd(i,s,r)*(1-rtxs(i,s,r)) + sum(j,vtwr(j,i,s,r));

bycom(rcalc(r),i,"cif")   = sum(s, cif(i,s,r));
bycom(rcalc(r),i,"tmrev") = sum(s, rtms(i,s,r)*cif(i,s,r));
bycom(rcalc(r),i,"tm$")   = bycom(r,i,"cif") + bycom(r,i,"tmrev");
bycom(rcalc(r),i,"tm_m")$bycom(r,i,"cif") = 100*bycom(r,i,"tmrev")/bycom(r,i,"cif");
bycom(rcalc(r),i,"tx_m")$sum(s,vxmd(i,s,r)) = 100*sum(s,-rtxs(i,s,r)*vxmd(i,s,r))/sum(s,vxmd(i,s,r));

byreg(rcalc(r),s,"cif")   = sum(i, cif(i,s,r));
byreg(rcalc(r),s,"tmrev") = sum(i, rtms(i,s,r)*cif(i,s,r));
byreg(rcalc(r),s,"tm$")   = byreg(r,s,"cif") + byreg(r,s,"tmrev");
byreg(rcalc(r),s,"tm_m")$byreg(r,s,"cif") = 100*byreg(r,s,"tmrev")/byreg(r,s,"cif");
byreg(rcalc(r),s,"tx_m")$sum(i,vxmd(i,s,r)) = 100*sum(i,-rtxs(i,s,r)*vxmd(i,s,r))/sum(i,vxmd(i,s,r));

ave(rcalc(r),"cif")   = sum((i,s), cif(i,s,r));
ave(rcalc(r),"tmrev") = sum((i,s), rtms(i,s,r)*cif(i,s,r));
ave(rcalc(r),"tm_m")  = 100*ave(r,"tmrev")/ave(r,"cif");
ave(rcalc(r),"tx_m")  = 100*sum((i,s),-rtxs(i,s,r)*vxmd(i,s,r))/sum((i,s),vxmd(i,s,r));

option bycom:3:2:1, byreg:3:2:1, ave:3:1:1;
display ave, bycom, byreg;
execute_unload 'tradetax.gdx', bycom, byreg, ave;

*	Write pgfplots tables sorted by tm_m+tx_m (the paper then plots
*	only the most highly taxed commodities, i.e. the top rows):

*	Rank commodities and partners by tm_m+tx_m (descending; ties are
*	broken by set order).  rnk = 1 is the most highly taxed:

alias (s,ss);
parameter	keyi(r,i)	Sort key by commodity (tm_m+tx_m),
		keys(r,s)	Sort key by partner (tm_m+tx_m),
		rnki(r,i)	Rank by commodity,
		rnks(r,s)	Rank by partner;

keyi(rcalc(r),i)$bycom(r,i,"cif") = bycom(r,i,"tm_m") + bycom(r,i,"tx_m");
keys(rcalc(r),s)$byreg(r,s,"cif") = byreg(r,s,"tm_m") + byreg(r,s,"tx_m");

rnki(rcalc(r),i)$bycom(r,i,"cif") = 1 + sum(j$(bycom(r,j,"cif") and
	((keyi(r,j) > keyi(r,i)) or ((keyi(r,j) = keyi(r,i)) and (ord(j) < ord(i))))), 1);
rnks(rcalc(r),s)$byreg(r,s,"cif") = 1 + sum(ss$(byreg(r,ss,"cif") and
	((keys(r,ss) > keys(r,s)) or ((keys(r,ss) = keys(r,s)) and (ord(ss) < ord(s))))), 1);

option rnki:0, rnks:0;
display rnki, rnks;

*	Write the sorted tables (loop over rank positions, using the set
*	itself as a counter):

file kdat; kdat.nd = 4; kdat.nw = 12; kdat.lw = 8;
loop(rcalc(r),
	put_utility kdat 'ren' / 'figures/' r.tl:0 '_commodity_m.data';
	put kdat 'good' @9 'tm_m' @21 'tx_m' @33 'tm$' @45 'tmrev' /;
	loop(j, loop(i$(rnki(r,i) = ord(j)),
	    put i.tl:8, bycom(r,i,"tm_m"), bycom(r,i,"tx_m"),
		bycom(r,i,"tm$"), bycom(r,i,"tmrev") /;););
	putclose kdat;
	put_utility kdat 'ren' / 'figures/' r.tl:0 '_txtm_m.data';
	put kdat 'region' @9 'tm_m' @21 'tx_m' @33 'tm$' @45 'tmrev' /;
	loop(ss, loop(s$(rnks(r,s) = ord(ss)),
	    put s.tl:8, byreg(r,s,"tm_m"), byreg(r,s,"tx_m"),
		byreg(r,s,"tm$"), byreg(r,s,"tmrev") /;););
	putclose kdat;
);
