$title	Generate a Sparse Version of the GTAP Dataset

$if not set ds $set ds gsd
$include "%system.fp%gtap10data"

*	Produce a report of the resulting change in nonzeros and dataset density:

parameter	density		Filtering results;

set	array /vdfm, vifm, vfm, vxmd, vtwr/;

density("commodity","vtwr",j,"before") = sum((i,r,s)$vtwr(j,i,r,s),1);
density("commodity","vxmd",i,"before") = sum((r,s)$vxmd(i,r,s),1);
density("exporter","vxmd",r,"before") = sum((i,s)$vxmd(i,r,s),1);
density("importer","vxmd",s,"before") = sum((i,r)$vxmd(i,r,s),1);
density("region","vfm",r,"before") = sum((f,g)$vfm(f,g,r),1);
density("factor","vfm",f,"before") = sum((r,g)$vfm(f,g,r),1);
density("region","vdfm",r,"before") = sum((i,g)$vdfm(i,g,r),1);
density("region","vifm",r,"before") = sum((i,g)$vifm(i,g,r),1);
density("commodity","vdfm",i,"before") = sum((r,g)$vdfm(i,g,r),1);
density("commodity","vifm",i,"before") = sum((r,g)$vifm(i,g,r),1);
density("total","total",array,"before") =
	sum(i,density("commodity",array,i,"before"));


parameter
	neg_vdfm(i,g,r)		Negative elements of vdfm,
	neg_vifm(i,g,r)		Negative elements of vifm,
	neg_vfm(f,g,r)		Negative elements of vfm,
	neg_vxmd(i,r,s)		Negative elements of vxmd,
	neg_vtwr(j,i,r,s)	Negative elements of vtwr;

neg_vdfm(i,g,r) = min(0,vdfm(i,g,r));
neg_vifm(i,g,r) = min(0,vifm(i,g,r));
neg_vfm(f,g,r) = min(0,vfm(f,g,r));
neg_vxmd(i,r,s) = min(0,vxmd(i,r,s));
neg_vtwr(j,i,r,s) = min(0,vtwr(j,i,r,s));
display neg_vdfm, neg_vifm, neg_vfm, neg_vxmd, neg_vtwr;

$if not set nd $set nd 5
parameter	nd	Number of decimals of precision /%nd%/;

*	------------------------------------------------------------------------
*	1. Cinch the original dataset:

set		iteradj		/iter1*iter4/,
		logitm		/vb, "vb/gdp", trace, delta/;

parameter	iterlog(iteradj,logitm)	Iteration log,
		trace			Changes in values,
		delta			Change in trace,
		thetaf(f,i,r)		Shares of value added,
		thetaf0(f,i,r)		Default value added shares,
		thetat(i,r)		Shares of transporter services,
		thetafchk(i,r)		Checking on adding up of value shares,
		va(g,r)			Value-added by sector;

va(i,r) = sum(f, vfm(f,i,r)*(1+rtf(f,i,r)));
va(i,r)$(not round(va(i,r),nd)) = 0;

*	Factor shares of value added in sector i of region r:

thetaf0(f,i,r)$va(i,r) = vfm(f,i,r) * (1+rtf(f,i,r)) / va(i,r);

*	Factor shares in sectors which have no value-added are assigned
*	the average value across all sectors in the same region:

thetaf0(f,j,r)$(not va(j,r)) = sum(i$va(i,r),vfm(f,i,r)*(1+rtf(f,i,r))) / sum(i,va(i,r));

thetafchk(i,r) = round(1 - sum(f,thetaf0(f,i,r)),3);
abort$card(thetafchk)	"Error in thetaf0:", thetafchk;

thetaf(f,i,r) = thetaf0(f,i,r);

*	Use original GTAP data to define the value share of region r
*	in the provision of commodity i transportation services:

thetat(i,r)$vst(i,r) = vst(i,r)/sum(s,vst(i,s));

alias (u,*);

*	-----------------------------------------------------------------------------------
*	Generate a "subroutine" which cinches (calibrates through proportional scaling)
*	the dataset.

$onecho >%gams.scrdir%cinch.gms

iterlog(iteradj,logitm) = 0;
delta = 1;

loop(iteradj$delta,

*	Provision of transportation services:
	vst(j,r)$thetat(j,r) = thetat(j,r) *
		sum((i,r.local,s), vtwr(j,i,r,s));

*	Imports gross of taxes and transport costs:
	vim(i,r) = sum(s, pvxmd(i,s,r)*vxmd(i,s,r) +
			  pvtwr(i,s,r)*sum(j, vtwr(j,i,s,r)));

*	Filter with nd digits:
	vim(i,r)$(not round(vim(i,r),nd)) = 0;

*	Drop bilateral trade when gross trade is zero:
	vifm(i,g,r)$(not vim(i,r)) = 0;

*	Scale sectoral demand for imports to match vim:
	vifm(i,g,r)$vifm(i,g,r) = vim(i,r) * vifm(i,g,r) /
				  sum(g.local,vifm(i,g,r));
	vifm(i,g,r)$(not round(vifm(i,g,r),nd)) = 0;

*	Gross exports (transport services and bilateral flows):
	vxm(i,r) = vst(i,r) + sum(s, vxmd(i,r,s));
	vxm(i,r)$(not round(vxm(i,r),nd)) = 0;

*	Drop bilateral trade if either gross exports or gross
*	imports fall to zero:
	vxmd(i,r,s)$(not (vxm(i,r) and vim(i,s))) = 0;

*	Drop transportation services if bilateral trade flows
*	are zero:
	vtwr(j,i,r,s)$(not vxmd(i,r,s)) = 0;

*	Aggregate demand for domestic output:
	vdm(i,r) = sum(g,vdfm(i,g,r));
	vdm(i,r)$(not round(vdm(i,r),nd)) = 0;
	vdfm(i,g,r)$(not vdm(i,r)) = 0;

*	Final demand (C, I and G) defined by the gross value of
*	goods:
	vom(g,r)$(not i(g)) = sum(i,vdfm(i,g,r)*(1+rtfd(i,g,r))+
				    vifm(i,g,r)*(1+rtfi(i,g,r)))/(1-rto(g,r));

*	Gross output equals exports and supply for the
*	domestic market:
	vom(i,r) = vxm(i,r) + vdm(i,r);

*	Value added in goods production is determined as a
*	residual:
	va(j,r) = vom(j,r)*(1-rto(j,r)) -
		sum(i,	vdfm(i,j,r)*(1+rtfd(i,j,r))+
			vifm(i,j,r)*(1+rtfi(i,j,r)));

*	Filter at the specified number of decimals:
	va(j,r)$(not round(va(j,r),nd)) = 0;

*	If implicit value-added is negative, add this to sectoral
*	output which is added to investment:
	vdfm(i,"i",r) = vdfm(i,"i",r) -    min(0,va(i,r))/(1-rto(i,r));
	vom("i",r)    = vom("i",r) - sum(i,min(0,va(i,r))/(1-rto(i,r)));

*	Adjust domestic supply now to account for adjustments in
*	investment:
	vdm(i,r) = sum(g,vdfm(i,g,r));
	vdm(i,r)$(not round(vdm(i,r),nd)) = 0;

*	Adjust gross output:
	vom(i,r) = vxm(i,r) + vdm(i,r);

*	If residual value-added is positive, we use benchmark
*	factor shares to allocate to factor inputs:
	va(j,r) = max(0, va(j,r));

	thetafchk(i,r)$va(i,r) = round(1 - sum(f,thetaf(f,i,r)),3);
	abort$card(thetafchk) thetafchk;

	vfm(f,i,r) = thetaf(f,i,r)*va(i,r)/(1+rtf(f,i,r));
	vfm(f,i,r)$(not round(vfm(f,i,r),nd)) = 0;

*	Verify that sectoral profits are zero:
	yprofit(g,r) = 0;
	yprofit(g,r)$vom(g,r) = round(vom(g,r)*(1-rto(g,r))
		- sum(i,vdfm(i,g,r)*(1+rtfd(i,g,r)) +
			vifm(i,g,r)*(1+rtfi(i,g,r)))
		- sum(f,vfm(f,g,r)*(1+rtf(f,g,r))),3);
	abort$card(yprofit) yprofit;

*	Aggregate factor supply equals factor demand:
	evom(f,r) = sum(i, vfm(f,i,r));
	evom(f,r)$(not round(evom(f,r),nd)) = 0;

*	Impute current account deficits using the
*	regional budget constraint:
	vb(r) = vom("c",r) + vom("g",r) + vom("i",r)
		- sum(f, evom(f,r))
		- sum(g,  vom(g,r)*rto(g,r))
		- sum(g,  sum(i, vdfm(i,g,r)*rtfd(i,g,r) +
				 vifm(i,g,r)*rtfi(i,g,r)))
		- sum((f,g),     vfm(f,g,r)*rtf(f,g,r))
		- sum((i,s), rtms(i,s,r) *
		    (vxmd(i,s,r) * (1-rtxs(i,s,r)) + sum(j,vtwr(j,i,s,r))))
		+ sum((i,s), rtxs(i,r,s) * vxmd(i,r,s));

*	Generate a numeric index to determine whether the
*	scaling procedure has stabilized:
	trace("vst") = card(vst) + sum((j,r),abs(vst(j,r)));
	trace("vxm") = card(vxm) + sum((i,r),abs(vxm(i,r)));
	trace("vdm") = card(vdm) + sum((i,r),abs(vdm(i,r)));
	trace("vom") = card(vom) + sum((g,r),abs(vom(g,r)));
	trace("vim") = card(vim) + sum((i,r),abs(vim(i,r)));
	trace("vdfm") = card(vdfm) + sum((i,g,r),abs(vdfm(i,g,r)));
	trace("vifm") = card(vifm) + sum((i,g,r),abs(vifm(i,g,r)));
	trace("vfm") = card(vfm) + sum((f,g,r),abs(vfm(f,g,r)));
	trace("vxmd") = card(vxmd) + sum((i,r,s),abs(vxmd(i,r,s)));
	trace("vtwr") = card(vtwr) + sum((j,i,r,s),abs(vtwr(j,i,r,s)));
	trace("va") = card(va) + sum((j,r),abs(va(j,r)));
	trace("vfm") = card(vfm) + sum((f,i,r),abs(vfm(f,i,r)));
	trace("evom") = card(evom) + sum((f,r),abs(evom(f,r)));

*	Produce a measure of change:
	delta = round(sum(u, trace(u)) - iterlog(iteradj-1,"trace"),nd);

*	Generate an iterational log:
	iterlog(iteradj,"vb") = sum(r,vb(r));
	iterlog(iteradj,"vb/gdp") = sum(r,vb(r))/
			sum(r,vom("c",r)+vom("g",r)+vom("i",r));
	iterlog(iteradj,"trace") = sum(u,trace(u));
	iterlog(iteradj,"delta") = delta;

);
iterlog(iteradj,"trace") = 0;
display iterlog;

$offecho

*	-----------------------------------------------------------------------------------

$include %gams.scrdir%cinch

*	2. Round taxes and recinch:

*	This was rounded to 2 digits in GTAP9inGAMS, but this caused mayhem in some
*	heavily subsidized cases. (It set rates to -1 for GTAP10.)
rto(g,r)    = round(rto(g,r),3);
rtfd(i,g,r) = round(rtfd(i,g,r),3);
rtfi(i,g,r) = round(rtfi(i,g,r),3);
rtf(f,g,r)  = round(rtf(f,g,r),3);
rtxs(i,r,s) = round(rtxs(i,r,s),3);
rtms(i,r,s) = round(rtms(i,r,s),3);

pvxmd(i,s,r) = (1+rtms(i,s,r)) * (1-rtxs(i,s,r));
pvtwr(i,s,r) = 1+rtms(i,s,r);

thetaf(f,i,r) = thetaf0(f,i,r);
va(i,r) = sum(f,vfm(f,i,r));
va(i,r)$(not round(va(i,r),nd)) = 0;

thetaf(f,i,r)$va(i,r) = vfm(f,i,r)*(1+rtf(f,i,r)) /
	sum(f.local, vfm(f,i,r)*(1+rtf(f,i,r)));

thetat(i,r) = 0;
thetat(i,r)$vst(i,r) = vst(i,r)/sum(s,vst(i,s));

$include %gams.scrdir%cinch

*	3. Filter and recinch:

sets	dropvfm(f,g,r)		Indicates that a non-zero in vfm will be set to zero
	dropvxmd(i,r,s)		Indicates that a non-zero in vxmd will be set to zero
	dropvtwr(j,i,r,s)	Indicates that a non-zero in vxmd will be set to zero
	dropvdfm(i,g,r)		Indicates that a non-zero in vdfm will be set to zero
	dropvifm(i,g,r)		Indicates that a non-zero in vifm will be set to zero;

dropvdfm(i,g,r)$vdfm(i,g,r)     = yes$(not round(vdfm(i,g,r),  nd));
dropvifm(i,g,r)$vifm(i,g,r)     = yes$(not round(vifm(i,g,r),  nd));
dropvfm(f,g,r)$vfm(f,g,r)       = yes$(not round(vfm(f,g,r),   nd));
dropvxmd(i,r,s)$vxmd(i,r,s)     = yes$(not round(vxmd(i,r,s),  nd));
dropvtwr(j,i,r,s)$vtwr(j,i,r,s) = yes$(not round(vtwr(j,i,r,s),nd));

density("commodity","vtwr",j,"after")  = sum((i,r,s)$vtwr(j,i,r,s),1$(not dropvtwr(j,i,r,s)));
density("commodity","vtwr",j,"%reduction")$density("commodity","vtwr",j,"before")  =
	100 * (1 - density("commodity","vtwr",j,"after") /
		   density("commodity","vtwr",j,"before"));

density("commodity","vxmd",i,"after")  = sum((r,s)$vxmd(i,r,s),1$(not dropvxmd(i,r,s)));
density("commodity","vxmd",i,"%reduction")$density("commodity","vxmd",i,"before")  =
	100 * (1 - density("commodity","vxmd",i,"after") /
		   density("commodity","vxmd",i,"before"));

density("exporter","vxmd",r,"after")  = sum((i,s)$vxmd(i,r,s),1$(not dropvxmd(i,r,s)));
density("exporter","vxmd",r,"%reduction")$density("exporter","vxmd",r,"before")  =
	100 * (1 - density("exporter","vxmd",r,"after") /
		   density("exporter","vxmd",r,"before"));

density("importer","vxmd",s,"after")  = sum((i,r)$vxmd(i,r,s),1$(not dropvxmd(i,r,s)));
density("importer","vxmd",s,"%reduction")$density("importer","vxmd",s,"before")  =
	100 * (1 - density("importer","vxmd",s,"after") /
		   density("importer","vxmd",s,"before"));

density("region","vfm",r,"after")  = sum((f,g)$vfm(f,g,r),1$(not dropvfm(f,g,r)));
density("region","vfm",r,"%reduction")$density("region","vfm",r,"before")  =
	100 * (1 - density("region","vfm",r,"after") /
		   density("region","vfm",r,"before"));

density("factor","vfm",f,"after")  = sum((r,g)$vfm(f,g,r),1$(not dropvfm(f,g,r)));
density("factor","vfm",f,"%reduction")$density("factor","vfm",f,"before")  =
	100 * (1 - density("factor","vfm",f,"after") /
		   density("factor","vfm",f,"before"));

density("region","vdfm",r,"after")  = sum((i,g)$vdfm(i,g,r),1$(not dropvdfm(i,g,r)));
density("region","vdfm",r,"%reduction")$density("region","vdfm",r,"before")  =
	100 * (1 - density("region","vdfm",r,"after") /
		   density("region","vdfm",r,"before"));

density("region","vifm",r,"after")  = sum((i,g)$vifm(i,g,r),1$(not dropvifm(i,g,r)));
density("region","vifm",r,"%reduction")$density("region","vifm",r,"before")  =
	100 * (1 - density("region","vifm",r,"after") /
		   density("region","vifm",r,"before"));

density("commodity","vdfm",i,"after")  = sum((r,g)$vdfm(i,g,r),1$(not dropvdfm(i,g,r)));
density("commodity","vdfm",i,"%reduction")$density("commodity","vdfm",i,"before")  =
	100 * (1 - density("commodity","vdfm",i,"after") /
		   density("commodity","vdfm",i,"before"));

density("commodity","vifm",i,"after")  = sum((r,g)$vifm(i,g,r),1$(not dropvifm(i,g,r)));
density("commodity","vifm",i,"%reduction")$density("commodity","vifm",i,"before")  =
	100 * (1 - density("commodity","vifm",i,"after") /
		   density("commodity","vifm",i,"before"));

density("total","total",array,"after") =
	sum(i,density("commodity",array,i,"after"));
density("total","total",array,"%reduction")$density("total","total",array,"before") =
	100 * (1 -	density("total","total",array,"after") /
			density("total","total",array,"before"));

option density:0:2:1;
display density;

*	Round small values to zero:

vfm(f,g,r)$dropvfm(f,g,r) = 0;
vxmd(i,r,s)$dropvxmd(i,r,s) = 0;
vtwr(j,i,r,s)$dropvtwr(j,i,r,s) = 0;
vdfm(i,g,r)$dropvdfm(i,g,r) = 0;
vifm(i,g,r)$dropvifm(i,g,r) = 0;

*	Calculate updated factor shares:

thetaf(f,i,r) = thetaf0(f,i,r);
va(i,r) = sum(f,vfm(f,i,r));
va(i,r)$(not round(va(i,r),5)) = 0;
thetaf(f,i,r)$va(i,r) = vfm(f,i,r)*(1+rtf(f,i,r)) /
	      sum(f.local, vfm(f,i,r)*(1+rtf(f,i,r)));
thetat(i,r) = 0;
thetat(i,r)$vst(i,r) = vst(i,r)/sum(s,vst(i,s));

*	Rebalance the dataset one more time:

$include %gams.scrdir%cinch

neg_vdfm(i,g,r) = min(0,vdfm(i,g,r));
neg_vifm(i,g,r) = min(0,vifm(i,g,r));
neg_vfm(f,g,r) = min(0,vfm(f,g,r));
neg_vxmd(i,r,s) = min(0,vxmd(i,r,s));
neg_vtwr(j,i,r,s) = min(0,vtwr(j,i,r,s));

display "Negative values at the end:", neg_vdfm, neg_vifm, neg_vfm,
					neg_vxmd, neg_vtwr;

*	Recalibrate elasticities:

thetac(i,r) = (vdfm(i,"c",r)*(1+rtfd(i,"c",r)) + vifm(i,"c",r)*(1+rtfi(i,"c",r))) /
	 sum(j,vdfm(j,"c",r)*(1+rtfd(j,"c",r)) + vifm(j,"c",r)*(1+rtfi(j,"c",r)));

eta(i,r) = (eta(i,r)/sum(j,thetac(j,r)*eta(j,r)))$thetac(i,r);

aues(i,j,r)$(not (thetac(i,r) and thetac(j,r))) = 0;

parameter	auessum(i,r)	Row sum;
auessum(i,r) = sum(j$(not sameas(i,j)),thetac(j,r)*aues(i,j,r));

aues(i,j,r)$(aues(i,j,r) and (not sameas(i,j))) =
	aues(i,j,r) * (-thetac(i,r)*aues(i,i,r))/auessum(i,r);

execute_unload '%datadir%%ds%_%nd%.gdx',
		r, f, g, i,  vfm, vdfm, vifm, vxmd, vst, vtwr, vtrev,
		rto, rtf, rtfd, rtfi, rtxs, rtms, esubt, esubd, esubva, esubm, etrae,
		eta, aues, incpar, subpar,
		pop, evd, evi, evt, eco2d, eco2i;
