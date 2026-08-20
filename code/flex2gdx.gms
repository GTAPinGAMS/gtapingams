$title	Translate GTAP Distribution Data into GDX

$set fs %system.dirsep%

$if not set yr $set yr 14
$if not set datadir $set datadir "..%fs%gamsdata%fs%20%yr%%fs%"
$if not dexist "%datadir%" $call mkdir "%datadir%"

*	Directory in which to find the GTAP zip files:

$if not set gtapdatadir $set gtapdatadir "..%fs%gtapdata%fs%"
$if not dexist "%gtapdatadir%" $abort Cannot find GTAP data directory: "%gtapdatadir%".

*	GTAP release version:

$set	gtapver flexagg10AY

$set gtapdatafile %gtapdatadir%%gtapver%%yr%.zip
$if not exist "%gtapdatafile%" $abort Cannot find GTAP data fie: "%gtapdatafile%".

*	Use the GAMS scratch directory to hold temporary files:

* $set tmpdir %gams.scrdir%..%fs%mytemp%fs%
$set tmpdir %gams.scrdir%

$if exist %tmpdir%gsdset.gdx $goto load

$call gmsunzip -j "%gtapdatafile%" %gtapver%%yr%/gsdset.har -d %tmpdir%
$call gmsunzip -j "%gtapdatafile%" %gtapver%%yr%/gsddat.har -d %tmpdir%
$call gmsunzip -j "%gtapdatafile%" %gtapver%%yr%/gsdpar.har -d %tmpdir%
$call gmsunzip -j "%gtapdatafile%" %gtapver%%yr%/gsdvole.har -d %tmpdir%
$call gmsunzip -j "%gtapdatafile%" %gtapver%%yr%/gsdemiss.har -d %tmpdir%
$call gmsunzip -j "%gtapdatafile%" %gtapver%%yr%/gsdtax.har -d %tmpdir%

$call 'har2gdx "%tmpdir%gsdset.har"   "%tmpdir%gsdset.gdx"'
$call 'har2gdx "%tmpdir%gsddat.har"   "%tmpdir%gsddat.gdx"'
$call 'har2gdx "%tmpdir%gsdpar.har"   "%tmpdir%gsdpar.gdx"'
$call 'har2gdx "%tmpdir%gsdvole.har"  "%tmpdir%gsdvole.gdx"'
$call 'har2gdx "%tmpdir%gsdemiss.har" "%tmpdir%gsdemiss.gdx"'
$call 'har2gdx "%tmpdir%gsdtax.har"   "%tmpdir%gsdtax.gdx"'

$if not exist %tmpdir%gsdset.gdx	$goto missinggdxfiles
$if not exist %tmpdir%gsddat.gdx	$goto missinggdxfiles
$if not exist %tmpdir%gsdpar.gdx	$goto missinggdxfiles
$if not exist %tmpdir%gsdvole.gdx	$goto missinggdxfiles
$if not exist %tmpdir%gsdemiss.gdx	$goto missinggdxfiles
$if not exist %tmpdir%gsdtax.gdx	$goto missinggdxfiles

$label load

set	r(*)	Regions,
	is(*)	Sectors,
	f(*)	Factors

$gdxin '%tmpdir%gsdset.gdx'
$load r=reg is=PROD_COMM f=ENDW_COMM

set	g	/c,g,i,sd,dd,set.is/,
	i(g)	/set.is/;

alias (i,j),(r,s), (u,*);

parameter
	mdf(i,j,r)	'Emissions from domestic product in current production, Mt CO2',
	mdg(i,r)	'Emissions from govt consumption of domestic product, Mt CO2',
	mdp(i,r)	'Emissions from private consumption of domestic product, Mt CO2',
	mif(i,j,r)	'Emissions from imports in current production, Mt CO2',
	mig(i,r)	'Emissions from government consumption of imports, Mt CO2',
	mip(i,r)	'Emissions from private consumption of imports, Mt CO2';

$gdxin '%tmpdir%gsdemiss.gdx'
$loaddc mdf mdg mdp mif mig mip

set		vtcomp /ad	"Anti-dumping duty",
			mfa	"Export tax equivalent of MFA quota premia",
			pu	"Export tax equivalent of price undertakings",
			ver	"Export tax equivalent of voluntary export restraints",
			xt	"Ordinary export tax"
			tarif	"Ordinary import duty",
			adv	"Import tariff revenue - levied on an ad-valorem basis",
			spe	"Import tariff revenue - levied on a specific basis" /;

set		ttype(vtcomp)	Tariff type /
			adv	Ad-valorem,
			spe	Specific /;

parameters
	adrv(i,r,s)	"Anti-dumping duty",
	dpsm(r)		"Sum of distribution parameters in household demand system",
	evfa(f,i,r)	"Primary factor purchases, at agents' prices",
	evoa(f,r)	"Primary factor sales, at agents' prices",
	fbep(f,i,r)	"Gross factor-based subsidies",
	ftrv(f,i,r)	"Gross factor employment tax revenue",
	isep(i,j,r,*)	"Net intermediate input subsidies",
	osep(i,r)	"Net ordinary output subsidy",
	pop(r)		"Population",
	save(r)		"Net saving, by region",
	tvom(i,r)	"Sales of domestic product, at market prices",
	vdep(r)		"Capital depreciation",

	vdfa(i,j,r)	"Domestic purchases, by firms, at agents' prices",
	vdfm(i,g,r)	"Domestic purchases, by firms, at market prices",
	vdga(i,r)	"Domestic purchases, by government, at agents' prices",
	vdgm(i,r)	"Domestic purchases, by government, at market prices",
	vdpa(i,r)	"Domestic purchases, by households, at agents' prices",
	vdpm(i,r)	"Domestic purchases, by households, at market prices",

	vfm(f,i,r)	"Primary factor purchases, by firms, at market prices",
	vifa(i,j,r)	"Import purchases, by firms, at agents' prices",
	vifm(i,g,r)	"Import purchases, by firms, at market prices",
	viga(i,r)	"Import purchases, by government, at agents' prices",
	vigm(i,r)	"Import purchases, by government, at market prices",
	vims(i,r,s)	"Imports, at market prices",
	vipa(i,r)	"Import purchases, by households, at agents' prices",
	vipm(i,r)	"Import purchases, by households, at market prices",
	viws(i,r,s)	"Imports, at world prices",
	vkb(r)		"Capital stock",
	vst(i,r)	"Margin exports",

	mfrv(i,r,s)	"Export tax equivalent of MFA quota premia",
	purv(i,r,s)	"Export tax equivalent of price undertakings",
	vrrv(i,r,s)	"Export tax equivalent of voluntary export restraints",
	xtrv(i,r,s)	"Ordinary export tax"

	tfrv(i,r,s)	"Ordinary import duty",
	vtss(ttype,i,r,s) "Import tariff rev by type of tariffs paid",

	vtwr(i,j,r,s)	"Margins by margin commodity",
	vxmd(i,r,s)	"Non-margin exports, at market prices",
	vxwd(i,r,s)	"Non-margin exports, at world prices";

$gdxin '%tmpdir%gsddat.gdx'
$loaddc adrv dpsm evfa evoa fbep ftrv isep mfrv osep pop purv save tfrv
$loaddc tvom vdep vdfa vdfm vdga vdgm vdpa vdpm vfm vifa vifm viga vigm vims vipa
$loaddc vipm viws vkb vrrv vst vtss vtwr vxmd vxwd xtrv


parameter	vtrev(vtcomp,i,r,s)	All components of import and export taxes;
vtrev("ad",i,r,s)    = adrv(i,r,s);
vtrev("mfa",i,r,s)   = mfrv(i,r,s);
vtrev("pu",i,r,s)   = purv(i,r,s);
vtrev("ver",i,r,s)   = vrrv(i,r,s);
vtrev("xt",i,r,s)    = xtrv(i,r,s);
vtrev("tarif",i,r,s) = tfrv(i,r,s);
vtrev(ttype,i,r,s)   = vtss(ttype,i,r,s);

parameter
	esubd(i)	"Elasticity of domestic-import substitution",
	esubm(i)	"Elasticity of import source substitution",
	esubt(i)	"Elasticity of top-level input substitution",
	esubva(i)	"Elasticity of factor substitution",
	etrae(f)	"Elasticity of transformation for sluggish endowments",
	incpar(i,r)	"Expansion parameter in the CDE minimum expenditure function",
	rorflex(r)	"Flexibility of expected net ROR wrt investment",
	subpar(i,r)	"Substitution parameter in CDE minimum expenditure function";

$gdxin '%tmpdir%gsdpar.gdx'
$loaddc esubd esubm esubt esubva etrae incpar rorflex subpar

set	fg(*) /set.f, set.g/;

parameter
	rtf(f,i,r)	"Taxes on primary factors - ad valorem rate,",
	rtfd(i,g,r)	"Taxes on firms' domestic purchases - ad valorem rate,"
	rtfi(i,g,r)	"Taxes on firms' imports purchases -- ad valorem rate",
*	Not used or unloaded:
	rtgd(i,r)	"Government domestic purchases taxes -- ad valorem rate",
	rtgi(i,r)	"Government import purchases taxes -- ad valorem rate",
*	Overwritten below:
	rtms(i,r,s)	"Import taxes, by source -- ad valorem rate",
	rto(fg,r)	"Output (or income) subsidies in region r -- ad valorem rate",
*	Not used or unloaded:
	rtpd(i,r)	"Private domestic consumption taxes -- ad valorem rate",
	rtpi(i,r)	"Private import consumption taxes -- ad valorem rate",
*	Overwritten below:
	rtxs(i,r,s)	"Export subsidies, by destination -- ad valorem rate",
*	Original parameters in %
	rtf_(f,i,r)	"Taxes on primary factors - % ad valorem rate,",
	rtfd_(i,g,r)	"Taxes on firms' domestic purchases - % ad valorem rate,"
	rtfi_(i,g,r)	"Taxes on firms' imports purchases -- % ad valorem rate",
	rtgd_(i,r)	"Government domestic purchases taxes -- % ad valorem rate",
	rtgi_(i,r)	"Government import purchases taxes -- % ad valorem rate",
	rtms_(i,r,s)	"Import taxes, by source -- % ad valorem rate",
	rto_(fg,r)	"Output (or income) subsidies in region r -- % ad valorem rate",
	rtpd_(i,r)	"Private domestic consumption taxes -- % ad valorem rate",
	rtpi_(i,r)	"Private import consumption taxes -- % ad valorem rate",
	rtxs_(i,r,s)	"Export subsidies, by destination -- % ad valorem rate";

$gdxin "%tmpdir%gsdtax.gdx"
$loaddc rtf_=rtf rtfd_=rtfd rtfi_=rtfi rtgd_=rtgd rtgi_=rtgi rtms_=rtms rto_=rto
$loaddc rtpd_=rtpd rtpi_=rtpi rtxs_=rtxs

*	Not all elements are always overwritten, so make extra sure they're not % anymore
rtf(f,i,r) = rtf_(f,i,r)/100;
rtfd(i,g,r) = rtfd_(i,g,r)/100;
rtfi(i,g,r) = rtfi_(i,g,r)/100;
rtgd(i,r) = rtgd_(i,r)/100;
rtgi(i,r) = rtgi_(i,r)/100;
rtms(i,r,s) = rtms_(i,r,s)/100;
rto(fg,r) = rto_(fg,r)/100;
rtpd(i,r) = rtpd_(i,r)/100;
rtpi(i,r) = rtpi_(i,r)/100;
rtxs(i,r,s) = rtxs_(i,r,s)/100;

parameter
	edf(i,j,r)	"Usage of domestic product by firms, Mtoe",
	edg(i,r)	"Government consumption of domestic product, Mtoe",
	edp(i,r)	"Private consumption of domestic product, Mtoe",
	eif(i,j,r)	"Usage of imports by firms, Mtoe",
	eig(i,r)	"Government consumption of imports, Mtoe",
	eip(i,r)	"Private consumption of imports, Mtoe",
	exi(i,r,s)	"Volume of trade, Mtoe";

$gdxin "%tmpdir%gsdvole.gdx"
$loaddc edf edg edp eif eig eip exi

parameters
	echop_f		Check on factor markets,
	echop_m		Check on import markets,
	echop_b(*,*)	Regional budget balance,
	echop_t		Check on market for bilateral trade
	echop_tm	Check on market for transport margins
	echop_y		Check on market for produced goods and services
	echop_tax	Regional tax revenue

parameters
	vfa(fg,j,r)	Firm's expenditure on factor by industry j
	voa(fg,r)	Value of commodity i output in region r
	vdm(i,r)	Domestic sales of i in r at market prices (tradeables only)
	vom(fg,r)	Value of commodity i output in region r at market prices
	vpa(i,r)	Private household expenditure on i in r at agent's prices
	vga(i,r)	Government household expenditure on i in r at agent's prices

	echop_f		Check on factor markets,
	echop_m		Check on import markets,
	echop_b(*,*)	Regional budget balance,
	echop_t		Check on market for bilateral trade
	echop_tm	Check on market for transport margins
	echop_y		Check on market for produced goods and services
	echop_tax	Regional tax revenue

	evt(i,r,r)	Volume of energy trade (mtoe);

*	Assign some intermediate arrays:

vfa(fg(f),j,r) = evfa(f,j,r);
vfa(fg(i),j,s) = vdfa(i,j,s) + vifa(i,j,s);
voa(fg(f),r) = evoa(f,r);

alias (fg,ffg);

voa(fg(i),r) = sum(ffg, vfa(ffg,i,r));

vdm(i,r) = vdpm(i,r) + vdgm(i,r) + sum(j, vdfm(i,j,r));

vom(fg(f),r) = sum(j, vfm(f,j,r));
vom(fg(i),r) = vdm(i,r) + sum(s, vxmd(i,r,s)) + vst(i,r);

vom("cgds",r) = voa("cgds",r);

vpa(i,s) = vdpa(i,s) + vipa(i,s);
vga(i,s) = vdga(i,s) + viga(i,s);

evt(i,r,s) = exi(i,r,s);

*	Compute tax rates from gross and net transactions:

rto(fg(i),r) = (1 - voa(fg,r)/vom(fg,r))$voa(fg,r);

rtf(f,j,r)$evfa(f,j,r) = evfa(f,j,r)/vfm(f,j,r) - 1;

*	Load private and public consumption in vdfm:

vdfm(i,"c",r) = vdpm(i,r);
vdfm(i,"g",r) = vdgm(i,r);

vom("c",r) = sum(i,vdpa(i,r)+vipa(i,r));

rtfd(i,j,r)$vdfa(i,j,r) = vdfa(i,j,r)/vdfm(i,j,r) - 1;
rtfd(i,"c",r)$vdpa(i,r) = vdpa(i,r)/vdpm(i,r) - 1;
rtfd(i,"g",r)$vdga(i,r) = vdga(i,r)/vdgm(i,r) - 1;

*	Load private and public consumption in vifm:

vifm(i,"c",r) = vipm(i,r);
vifm(i,"g",r) = vigm(i,r);

rtfi(i,j,r)$vifa(i,j,r) = vifa(i,j,r)/vifm(i,j,r)-1;
rtfi(i,"c",r)$vipa(i,r) = vipa(i,r)/vipm(i,r)-1;
rtfi(i,"g",r)$viga(i,r) = viga(i,r)/vigm(i,r)-1;

vom("g",r) = sum(i,vdga(i,r)+viga(i,r));

rtxs(i,r,s)$vxwd(i,r,s) = vxwd(i,r,s)/vxmd(i,r,s)-1;
rtms(i,r,s)$vims(i,r,s) = vims(i,r,s)/viws(i,r,s)-1;

*	Provide an consistency check echoprint:

echop_m(i,s,"supply") = sum(r, vims(i,r,s));
echop_m(i,s,"demand") = sum(j, vifm(i,j,s)) + vifm(i,"c",s) + vifm(i,"g",s);
echop_m(i,s,"diff") = round(sum(r, vims(i,r,s)) -
	(sum(j, vifm(i,j,s)) + vifm(i,"c",s) + vifm(i,"g",s)),3);
echop_m(i,s,u)$(not round(echop_m(i,s,"diff"),3)) = 0;
option echop_m:3:2:1;
display echop_m;

*	Generate an echo print of regional
*	budget constraints:

echop_b(r,"voa") = sum(fg(f), voa(fg,r));
echop_b(r,"taxrev") =
	+ sum(fg(f), vom(fg,r)-voa(fg,r))
        + sum(fg(i), rto(fg,r)*vom(fg,r))
        + sum(j, sum(f, rtf(f,j,r)*vfm(f,j,r)))
        + sum(i, sum(g, rtfi(i,g,r)*vifm(i,g,r)))
        + sum(i, sum(g, rtfd(i,g,r)*vdfm(i,g,r)))
        + sum(i, sum(s, rtxs(i,r,s)*vxmd(i,r,s)))
	+ sum(i, sum(s, rtms(i,s,r)*
			((1+rtxs(i,s,r))*vxmd(i,s,r)+sum(j,vtwr(j,i,s,r)))));

echop_b(r,"saving") = save(r) + vdep(r);
echop_b(r,"expend") = sum(i, (1+rtfd(i,"c",r))*vdfm(i,"c",r) +
					(1+rtfi(i,"c",r))*vifm(i,"c",r) +
					(1+rtfd(i,"g",r))*vdfm(i,"g",r) +
					(1+rtfi(i,"g",r))*vifm(i,"g",r) );
echop_b(r,"diff") = round(echop_b(r,"voa") + echop_b(r,"taxrev")
	- echop_b(r,"saving") - echop_b(r,"expend"),3);
echop_b(r,u)$(not round(echop_b(r,"diff"),3)) = 0;

option echop_b:3:1:1;
display echop_b;

*	Generate an echo print of regional
*	tax revenue:

echop_tax(r,"1") = sum(fg(f), vom(fg,r)-voa(fg,r)) + sum(fg(i), rto(fg,r)*vom(fg,r));
echop_tax(r,"2") = sum(j, sum(f, rtf(f,j,r)*vfm(f,j,r)));
echop_tax(r,"3") = sum(i, rtfi(i,"c",r)*vifm(i,"c",r));
echop_tax(r,"4") = sum(i, rtfd(i,"c",r)*vdfm(i,"c",r));
echop_tax(r,"5") = sum(i, rtfi(i,"g",r)*vifm(i,"g",r));
echop_tax(r,"6") = sum(i, rtfd(i,"g",r)*vdfm(i,"g",r));
echop_tax(r,"7") = sum(i, sum(j, rtfi(i,j,r)*vifm(i,j,r)));
echop_tax(r,"8") = sum(i, sum(j, rtfd(i,j,r)*vdfm(i,j,r)));

echop_tax(r,"9") = sum(i, sum(s, rtxs(i,r,s)*vxmd(i,r,s)));
echop_tax(r,"10") = sum(i, sum(s, rtms(i,s,r)*
		((1+rtxs(i,s,r))*vxmd(i,s,r)+sum(j,vtwr(j,i,s,r)))))
display echop_tax;

*	Generate an echo print of bilateral trade:

echop_t(i,r,s,"demand") = vims(i,r,s);
echop_t(i,r,s,"supply") = (1+rtms(i,r,s))*((1+rtxs(i,r,s))*vxmd(i,r,s) +
						sum(j, vtwr(j,i,r,s)));
echop_t(i,r,s,"diff") = echop_t(i,r,s,"demand") - echop_t(i,r,s,"supply");

echop_t(i,r,s,u)$(not round(echop_t(i,r,s,"diff"),3)) = 0;

option echop_t:3:3:1;
display echop_t;

*	Generate an echo print of the market for
*	transportation margins:

echop_tm(j,"supply") = sum(r, vst(j,r));
echop_tm(j,"demand") = sum((i,r,s), vtwr(j,i,r,s));
echop_tm(j,"diff") = round(echop_tm(j,"supply") - echop_tm(j,"demand"),3);
echop_tm(j,u)$(not round(echop_tm(j,"diff"),3)) = 0;
display echop_tm;


*	Generate an echo print of the market for output:

echop_y(fg(i),r,"supply")$(not sameas(i,"cgds")) = vom(fg,r);
echop_y(i,r,"demand")$(not sameas(i,"cgds")) =
	sum(s, vxmd(i,r,s)) + vst(i,r) + sum(g,vdfm(i,g,r));
echop_y(i,r,"diff")$(not sameas(i,"cgds")) =
	round(echop_y(i,r,"supply") - echop_y(i,r,"demand"),3);
echop_y(i,r,u)$(not echop_y(i,r,"diff")) = 0;
option echop_y:3:2:1;
display echop_y;

set	sf(f)	Sluggish primary factors (sector-specific)
	mf(f)	Mobile primary factors;
mf(f) = yes$(etrae(f)=0);
sf(f) = yes$(etrae(f)<0);

*	Convert sign of etrae() so that it is interpreted as
*	non-negative elasticity of transformation:

etrae(f) = -etrae(f);
etrae(mf) = +inf;

*	-------------------------------------------------------------------
*	Scale data from millions to billions of dollars:

vfm(f,i,r)    = vfm(f,i,r)/1000;
vdfm(i,g,r)   = vdfm(i,g,r)/1000;
vifm(i,g,r)   = vifm(i,g,r)/1000;
vxmd(i,r,s)   = vxmd(i,r,s)/1000;
vst(i,r)      = vst(i,r)/1000;
vtwr(i,j,r,s) = vtwr(i,j,r,s)/1000;
vtrev(vtcomp,i,r,s) = vtrev(vtcomp,i,r,s)/1000;

*	Change the sign of export taxes as export subsidies:

rtxs(i,s,r) = - rtxs(i,s,r);

$ontext
set	ghg		Greenhouse gases /
	co2		Carbon dioxide Mt (CO2 - 81% - GWP 1)
	n2o		Nitrous oxide (Gg - 6%)
	ch4		Methane (Gg - 11%)
	fg		Florinated gases (Gg - 3%) /

$call 'har2gdx "%gtapdatadir%consld_2014.har"   "%tmpdir%consld_2014.gdx"'

set	nco2		Non-co2 /n2o,ch4,fg/;
$offtext

parameter
	evd(i,*,r)	Domestic energy use (mtoe),
	evi(i,*,r)	Imported energy use (mtoe),
	eco2d(i,*,r)	CO2 emissions in domestic fuels - Mt CO2",
	eco2i(i,*,r)	CO2 emissions in foreign fuels - Mt CO2";

evd(i,j,r) = edf(i,j,r);
evd(i,"c",r) = edp(i,r);
evd(i,"g",r) = edg(i,r);
evi(i,j,r) = eif(i,j,r);
evi(i,"c",r) = eip(i,r);
evi(i,"g",r) = eig(i,r);

eco2d(i,j,r) = mdf(i,j,r);
eco2d(i,"g",r) = mdg(i,r);
eco2d(i,"c",r) = mdp(i,r);

eco2i(i,j,r)   = mif(i,j,r);
eco2i(i,"g",r) = mig(i,r);
eco2i(i,"c",r) = mip(i,r);

*	Finally, remove the CGDS commodity and transfer all production
*	coefficients into the I (investment) activity:

$onuni
rto("i",r) = rto("cgds",r); rto("cgds",r) = 0;

vdfm(i,"i",r) = vdfm(i,"cgds",r); vdfm(i,"cgds",r) = 0;
vifm(i,"i",r) = vifm(i,"cgds",r); vifm(i,"cgds",r) = 0;

vdfm("cgds",g,r) = 0;
vifm("cgds",g,r) = 0;

rtfd(i,"i",r) = rtfd(i,"cgds",r); rtfd(i,"cgds",r) = 0;
rtfi(i,"i",r) = rtfi(i,"cgds",r); rtfi(i,"cgds",r) = 0;

rtfd("cgds",g,r) = 0;
vifm("cgds",g,r) = 0;

evd(i,"i",r) = evd(i,"cgds",r); evd(i,"cgds",r) = 0;
evi(i,"i",r) = evi(i,"cgds",r); evi(i,"cgds",r) = 0;

eco2d(i,"i",r) = eco2d(i,"cgds",r); eco2d(i,"cgds",r) = 0;
eco2i(i,"i",r) = eco2i(i,"cgds",r); eco2i(i,"cgds",r) = 0;

evd("cgds",j,r) = 0;
evi("cgds",j,r) = 0;

eco2d("cgds",j,r) = 0;
eco2i("cgds",j,r) = 0;

set	ii(*)	Commodities (excluding cgds),
	gg(*)	Sectors (excluding cgds) and elements of final demand;

ii(i) = yes$(not sameas(i,"cgds"));
gg(g) = yes$(not sameas(g,"cgds"));

parameter	thetac(i,r)	Final demand value shares,
		eta(i,r)	Income elasticity of demand,
		aues(i,j,r)	Allen-Uzawa elasticities of substitution;

alias (i,k);

*	Final consumption value shares:

thetac(i,r) = (vdfm(i,"c",r)*(1+rtfd(i,"c",r)) + vifm(i,"c",r)*(1+rtfi(i,"c",r))) /
	 sum(j,vdfm(j,"c",r)*(1+rtfd(j,"c",r)) + vifm(j,"c",r)*(1+rtfi(j,"c",r)));

*	Drop references to commodities with zero value shares:

subpar(i,r)$(not thetac(i,r)) = 0;
incpar(i,r)$(not thetac(i,r)) = 0;

*	Income elasticity of demand:

eta(i,r)$(not thetac(i,r)) = 0;
eta(i,r)$thetac(i,r) = subpar(i,r) - sum(k,thetac(k,r)*subpar(k,r)) +
	(incpar(i,r)*(1-subpar(i,r)) + sum(k,thetac(k,r)*incpar(k,r)*subpar(k,r))) /
	sum(k,thetac(k,r)*incpar(k,r));

*	The Allen-Uzawa matrix of own- and cross-price elasticities
*	of substitution:

aues(i,j,r)$(not (thetac(i,r) and thetac(j,r))) = 0;
aues(i,j,r)$(thetac(i,r) and thetac(j,r)) = subpar(i,r) + subpar(j,r)
		- sum(k,thetac(k,r)*subpar(k,r))
		- (subpar(i,r)/thetac(i,r))$sameas(i,j);


execute_unload '%datadir%gsd.gdx',
		r, f, gg=g, ii=i,  vfm,
		vdfm, vifm, vxmd, vst, vtwr, vtrev,
		rto, rtf, rtfd, rtfi, rtxs, rtms,
		esubd, esubva, esubm, etrae, esubt,
		eta, aues, incpar, subpar, vtrev,
		pop, evd, evi, evt, eco2d, eco2i;

$exit

$label missinggdxfiles
$log
$log	*** Error *** Missing GDX files.
$log
$log	Reading from FLEXAGG archive %gtapdatafile%.
$log
$log	One of the following translations seems to have failed
$log		har2gdx "%gams.scrdir%gsdset.har" "%gams.scrdir%gsdset.gdx"
$log		har2gdx "%gams.scrdir%gsddat.har" "%gams.scrdir%gsddat.gdx"
$log		har2gdx "%gams.scrdir%gsdpar.har" "%gams.scrdir%gsdpar.gdx"
$log		har2gdx "%gams.scrdir%gsdvole.har" "%gams.scrdir%gsdvole.gdx"
$log		har2gdx "%gams.scrdir%gsdemiss.har" "%gams.scrdir%gsdemiss.gdx"
$log		har2gdx "%gams.scrdir%gsdtax.har" "%gams.scrdir%gsdtax.gdx"
$log
$exit
