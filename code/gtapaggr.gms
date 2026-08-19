$title	Aggregation Program for the GTAP9 Database

*$if not set source $abort	Need to specify a source on command line: --source=xxx
*$if not set target $abort	Need to specify a target on command line: --target=yyy

$if not set source $set source gsd_5
$if not set target $set target gtapingams
$if not set yr $set yr 11

$if not set output $set output %target%

$set fs %system.dirsep% 

$set ds %source%
$include "%system.fp%gtap9data"
$include "..%fs%defines%fs%%target%.map"

alias (ii,jj,kk), (rr,ss);

set	gg(*)	All goods in aggregate model plus C - G - I /
		c	Household,
		dd	Discretionary demand (LES model),
		sd	Subsistence demand (LES model),
		g	Government consumption,
		i	Investment/;
alias (u,*);
gg(u)$ii(u) = ii(u);
abort$sum(ii$(sameas(ii,"c") or sameas(ii,"dd") or sameas(ii,"sd") or sameas(ii,"g") or sameas(ii,"i")),1) "Invalid identifier: C, SD, DD, G and I are reserved.";

parameters
	vom_(*,rr)	Aggregate output
	vfm_(ff,*,rr)	Endowments - Firms' purchases at market prices,
	vdfm_(ii,*,rr)	Intermediates - firms' domestic purchases at market prices,
	vifm_(ii,*,rr)	Intermediates - firms' imports at market prices,
	vxmd_(ii,rr,ss)	Trade - bilateral exports at market prices,
	vst_(ii,rr)	Trade - exports for international transportation
	vtwr_(ii,jj,rr,ss)	Trade - Margins for international transportation at world prices,
	vtrev_(vtcomp,ii,rr,ss)	Components of trade taxes,

	pop_(rr)	Population,
	evt_(ii,rr,rr)	Volume of energy trade (mtoe),
	evd_(ii,*,rr)	Domestic energy use (mtoe),
	evi_(ii,*,rr)	Imported energy use (mtoe),
	eco2d_(ii,*,rr)	CO2 emissions in domestic fuels - Mt CO2",
	eco2i_(ii,*,rr)	CO2 emissions in foreign fuels - Mt CO2",

	rto_(*,rr)	Output (or income) subsidy rates
	rtf_(ff,*,rr)	Primary factor and commodity rates taxes 
	rtfd_(ii,*,rr)	Firms domestic tax rates
	rtfi_(ii,*,rr)	Firms' import tax rates
	rtxs_(ii,rr,ss)	Export subsidy rates
	rtms_(ii,rr,ss)	Import taxes rates,

	esubd_(ii)	Elasticity of substitution (M versus D),
	esubt_(ii)	Top level elasticity of substitution 
	esubva_(jj)	Elasticity of substitution between factors
	esubm_(ii)	Intra-import elasticity of substitution,
	etrae_(ff)	Elasticity of transformation,
	eta_(ii,rr)	Income elasticity of demand,
	aues_(ii,jj,rr)	Allen-Uzawa elasticity substitution matrix,

	subpar_(ii,rr)	Substitution parameter in CDE expenditure function,
	incpar_(ii,rr)	Income parameter,

	forecast_(rr,fitem,fyr)	GTAP regional population and GDP forecast;

alias (i,j), (ii,jj);;
alias (r,s), (rr,ss);
set maps(s,ss), mapj(j,jj), mapg(*,*)/c.c, i.i, g.g, sd.sd, dd.dd/;
maps(r,rr) = mapr(r,rr);
mapj(j,jj) = mapi(j,jj);
mapg(i,ii) = mapi(i,ii);

file ktitle; put ktitle;

put_utility 'title' /"Aggregating vst.";
$batinclude "%system.fp%aggr" vst  i r   vst_
put_utility 'title' /"Aggregating vom.";
$batinclude "%system.fp%aggr" vom  g r   vom_
put_utility 'title' /"Aggregating vfm.";
$batinclude "%system.fp%aggr" vfm  f j r vfm_
put_utility 'title' /"Aggregating vdfm.";
$batinclude "%system.fp%aggr" vdfm i g r vdfm_
put_utility 'title' /"Aggregating vifm.";
$batinclude "%system.fp%aggr" vifm i g r vifm_
put_utility 'title' /"Aggregating vxmd.";
$batinclude "%system.fp%aggr" vxmd i r s vxmd_
put_utility 'title' /"Aggregating evd.";
$batinclude "%system.fp%aggr" evd  i g r evd_
put_utility 'title' /"Aggregating pop.";
$batinclude "%system.fp%aggr" pop r pop_
put_utility 'title' /"Aggregating evi.";
$batinclude "%system.fp%aggr" evi  i g r evi_
put_utility 'title' /"Aggregating evt.";
$batinclude "%system.fp%aggr" evt  i r s evt_
put_utility 'title' /"Aggregating eco2d.";
$batinclude "%system.fp%aggr" eco2d  i g r eco2d_
put_utility 'title' /"Aggregating eco2i.";
$batinclude "%system.fp%aggr" eco2i  i g r eco2i_
put_utility 'title' /"Aggregating vtwr.";
$batinclude "%system.fp%aggr"  vtwr i j r s vtwr_

alias (vtcomp,v,vv);
set	mapv(v,vv); mapv(v,v) = yes;
put_utility 'title' /"Aggregating vtcomp.";
$batinclude "%system.fp%aggr"  vtrev v i r s vtrev_

parameter	vcm(i,r)	Value of consumption expenditure;
vcm(j,r) = vdfm(j,"c",r)*(1+rtfd0(j,"c",r)) + 
	   vifm(j,"c",r)*(1+rtfi0(j,"c",r));

parameter	theta(i,r)	Value shares in final demand;
theta(i,r) = vcm(i,r)/sum(j,vcm(j,r));

alias (i,k);

parameter	vcm_(ii,rr)	Value of consumption expenditure (aggregated);
vcm_(ii,rr) = sum((mapi(i,ii),mapr(r,rr)), vcm(i,r));

parameter	thetac_(ii,rr)	Aggregate value shares in final demand; 
thetac_(ii,rr) = vcm_(ii,rr)/sum(jj,vcm_(jj,rr));

subpar_(ii,rr)$vcm_(ii,rr) = 
	sum((mapi(i,ii),mapr(r,rr)), vcm(i,r)*subpar(i,r))/vcm_(ii,rr);

eta_(ii,rr)$vcm_(ii,rr) = 
	sum((mapi(i,ii),mapr(r,rr)), vcm(i,r)*eta(i,r))/vcm_(ii,rr);

*	For the time being, introduce an expenditure average:

incpar_(ii,rr)$vcm_(ii,rr) = sum((mapi(i,ii),mapr(r,rr)),
	vcm(i,r)*incpar(i,r))/vcm_(ii,rr);

*	First, convert tax rates into tax payments:

rto(g,r)    = rto(g,r)*vom(g,r);
rtf(f,j,r)  = rtf(f,j,r) * vfm(f,j,r);
rtfd(i,g,r) = rtfd(i,g,r) * vdfm(i,g,r);
rtfi(i,g,r) = rtfi(i,g,r) * vifm(i,g,r);
rtms(i,r,s) = rtms(i,r,s)*((1-rtxs(i,r,s)) * vxmd(i,r,s) + sum(j,vtwr(j,i,r,s)));
rtxs(i,r,s) = rtxs(i,r,s) * vxmd(i,r,s);

*	Aggregate:

put_utility 'title' /"Aggregating rto.";
$batinclude "%system.fp%aggr" rto g r   rto_
put_utility 'title' /"Aggregating rtf.";
$batinclude "%system.fp%aggr" rtf f j r rtf_
put_utility 'title' /"Aggregating rtfd.";
$batinclude "%system.fp%aggr" rtfd i g r rtfd_
put_utility 'title' /"Aggregating rtfi.";
$batinclude "%system.fp%aggr" rtfi i g r rtfi_
put_utility 'title' /"Aggregating rtxs.";
$batinclude "%system.fp%aggr" rtxs i r s rtxs_
put_utility 'title' /"Aggregating rtms.";
$batinclude "%system.fp%aggr" rtms i r s rtms_
put_utility 'title' /"Aggregating vcm.";
$batinclude "%system.fp%aggr"  vcm i r vcm_

put_utility 'title' /"Aggregating forecast.";
forecast_(rr,fitem,fyr) = sum(mapr(r,rr), forecast(r,fitem,fyr));

*	First aggregate commodities at the disaggregate regional level:

parameter	epsilon_reg(ii,jj,r)	Own and cross price elasticities of demand for aggregate goods at the regional level;
epsilon_reg(ii,jj,r)$sum((mapi(i,ii),mapj(j,jj)), vcm(i,r)*vcm(j,r))
	  = sum((mapi(i,ii),mapj(j,jj)), aues(i,j,r)*vcm(i,r)*vcm(j,r))
	  / sum((mapi(i,ii),mapj(j,jj)), vcm(i,r)*vcm(j,r)) * sum(mapj(j,jj),thetac(j,r))

*	Consistent aggregation of the AUES matrix is achieved by first

parameter	regshare(ii,jj,r,rr)	Regional shares of of each AUES term;
regshare(ii,jj,mapr(r,rr))$(sum(mapi(i,ii),vcm(i,r))*sum(mapj(j,jj),vcm(j,r)))
	=                 sum(mapi(i,ii),vcm(i,r))*sum(mapj(j,jj),vcm(j,r)) /
	  sum(r.local$mapr(r,rr), sum(mapi(i,ii),vcm(i,r))*sum(mapj(j,jj),vcm(j,r)));

*	Form the region-weighted price elasticities to impute the new AUES:

aues_(ii,jj,rr)$(thetac_(ii,rr)*thetac_(jj,rr)) = 
	sum(mapr(r,rr), epsilon_reg(ii,jj,r) * regshare(ii,jj,r,rr)) / thetac_(jj,rr);

*	The calculated AUES matrix may not satisfy the adding-up condition, so we scale the 
*	off-diagonal:

parameter	offdiagscale	Off diagonal scale factor;
offdiagscale(ii,rr)$sum(jj$(not sameas(ii,jj)), aues_(ii,jj,rr)*thetac_(jj,rr))
	= -thetac_(ii,rr)*aues_(ii,ii,rr) / sum(jj$(not sameas(ii,jj)), aues_(ii,jj,rr)*thetac_(jj,rr));
display offdiagscale;

aues_(ii,jj,rr)$(not sameas(ii,jj)) = aues_(ii,jj,rr) * offdiagscale(ii,rr);


parameter	aueschk		Homogeneity check on source dataset,
		aueschk_	Homogeneity check on aggregated dataset;
aueschk(i,r)    = round(sum(j, thetac(j,r)*aues(i,j,r)),4);
aueschk_(ii,rr) = round(sum(jj, aues_(ii,jj,rr)*thetac_(jj,rr)),4);
abort$card(aueschk)  "Homogeneity check for AUES fails (source data).", aueschk;
abort$card(aueschk_) "Homogeneity check for AUES fails (aggregated data).", aueschk_;

*	The convert tax flows back to rates:

rto_(gg,rr)$vom_(gg,rr) = rto_(gg,rr)/vom_(gg,rr);
rtf_(ff,jj,rr)$vfm_(ff,jj,rr)  = rtf_(ff,jj,rr) / vfm_(ff,jj,rr);
rtfd_(ii,gg,rr)$ vdfm_(ii,gg,rr) = rtfd_(ii,gg,rr) / vdfm_(ii,gg,rr);
rtfi_(ii,gg,rr)$ vifm_(ii,gg,rr) = rtfi_(ii,gg,rr) / vifm_(ii,gg,rr);
rtxs_(ii,rr,ss)$ vxmd_(ii,rr,ss) = rtxs_(ii,rr,ss) / vxmd_(ii,rr,ss);
rtms_(ii,rr,ss)$((1-rtxs_(ii,rr,ss)) * vxmd_(ii,rr,ss) + sum(jj,vtwr_(jj,ii,rr,ss)))
	 = rtms_(ii,rr,ss)/((1-rtxs_(ii,rr,ss)) * vxmd_(ii,rr,ss) + sum(jj,vtwr_(jj,ii,rr,ss)));

esubt_(ii)$sum((r,mapi(i,ii)), vom(i,r)*esubt(i)) 
	= sum((r,mapi(i,ii)), vom(i,r)*esubt(i)) / sum((r,mapi(i,ii)), vom(i,r)*esubt(i));

esubd_(ii)$sum(mapi(i,ii), sum((g,r), vdfm(i,g,r)+vifm(i,g,r)))
	= sum(mapi(i,ii), sum((g,r), vdfm(i,g,r)+vifm(i,g,r))*esubd(i)) /
	     sum(mapi(i,ii), sum((g,r), vdfm(i,g,r)+vifm(i,g,r)));
esubva_(jj)$sum(mapi(j,jj), sum((f,r), vfm(f,j,r)))
	= sum(mapi(j,jj), sum((f,r), vfm(f,j,r)*esubva(j))) /
	      sum(mapi(j,jj), sum((f,r), vfm(f,j,r)));

esubm_(ii)$sum((r,mapi(i,ii)), vim(i,r)) 
	= sum((r,mapi(i,ii)), vim(i,r)*esubm(i)) / sum((r,mapi(i,ii)), vim(i,r));

etrae_(ff)$(smax(mapf(f,ff),etrae(f))=inf) = inf;
etrae_(ff)$((smax(mapf(f,ff),etrae(f))<inf) and sum((jj,rr),vfm_(ff,jj,rr))) = 
	sum(mapf(f,ff), sum((j,r), vfm(f,j,r)*etrae(f))) / sum(mapf(f,ff), sum((j,r), vfm(f,j,r)));

parameter	beta(ii,r)	Share of commodity ii demand in constituent region r;
loop((ii,rr)$thetac_(ii,rr),
  beta(ii,r)$mapr(r,rr) = sum(mapi(i,ii),vcm(i,r))/vcm_(ii,rr));

parameter	epsiloneta	Alternative demand elasticity estimates;
epsiloneta(ii,rr,"epsilon","aues") = aues_(ii,ii,rr) * thetac_(ii,rr);
epsiloneta(ii,rr,"epsilon","ces") = 
	sum(mapr(r,rr), beta(ii,r) * 
	sum(mapi(i,ii), (1 - 1/thetac_(ii,rr))/(1 - 1/theta(i,r)) * 
		theta(i,r)/thetac_(ii,rr) * epsilon(i,r)));
epsiloneta(ii,rr,"epsilon","cde") = -subpar_(ii,rr) * sqr(1-thetac_(ii,rr))
		- thetac_(ii,rr)*sum(kk,thetac_(kk,rr)*subpar_(kk,rr))
		+ sqr(thetac_(ii,rr))*subpar_(ii,rr);
epsiloneta(ii,rr,"eta","eta") = eta_(ii,rr);
epsiloneta(ii,rr,"eta","cde") = (INCPAR_(ii,rr)*(1-SUBPAR_(ii,rr)) + 
		 sum(kk,thetac_(kk,rr)*INCPAR_(kk,rr)*SUBPAR_(kk,rr))) / 
			sum(kk,thetac_(kk,rr)*INCPAR_(kk,rr)) 
		+ (SUBPAR_(ii,rr) - sum(kk,thetac_(kk,rr)*SUBPAR_(kk,rr)));
option epsiloneta:3:2:2;
display epsiloneta;

parameter	demandelast	Demand elasticities (disaggregate vs. aggregate model);
loop((mapr(r,rr),mapi(i,ii))$theta(i,r),
	demandelast(rr,ii,r,i,"epsilon") = epsilon(i,r);
	demandelast(rr,ii,r,i,"eta")     = eta(i,r);
	demandelast(rr,ii,r,i,"theta")   = theta(i,r);
	demandelast(rr,ii,r,i,"theta*")  = thetac_(ii,rr);
	demandelast(rr,ii,r,i,"eta*")    = eta_(ii,rr);
	demandelast(rr,ii,r,i,"epsilon*")= epsiloneta(ii,rr,"epsilon","aues"););
option demandelast:3:4:1;
display demandelast;

put_utility 'title' /"Unloading dataset.";
execute_unload '%datadir%%output%.gdx', 
	gg=g, rr=r, ff=f, ii=i, 
	vfm_=vfm, vdfm_=vdfm, vifm_=vifm,vxmd_=vxmd, vst_=vst, vtwr_=vtwr, vtrev_=vtrev,
	rto_=rto, rtf_=rtf, rtfd_=rtfd, rtfi_=rtfi, rtxs_=rtxs, rtms_=rtms, 
	pop_=pop,evd_=evd, evi_=evi, evt_=evt, eco2d_=eco2d, eco2i_=eco2i, 
	esubt_=esubt, esubd_=esubd, esubva_=esubva, esubm_=esubm, 
	etrae_=etrae, eta_=eta, aues_=aues,
	incpar_=incpar, subpar_=subpar, forecast_=forecast;

put_utility 'title' /"All done with aggregation";

