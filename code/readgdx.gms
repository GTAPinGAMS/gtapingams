$title	Translate GTAP Distribution Data into GDX

$set fs %system.dirsep%

$if not set yr $set yr 17
$if not set datadir $set datadir "..%fs%gamsdata%fs%20%yr%%fs%"
$if not dexist "%datadir%" $call mkdir "%datadir%"

*	Directory in which to find the GTAP zip files:

$if not set gtapdatadir $set gtapdatadir "..%fs%gtapdata%fs%"
$if not dexist "%gtapdatadir%" $abort Cannot find GTAP data directory: "%gtapdatadir%".

*	Use the GAMS scratch directory to hold temporary files:

$set tmpdir mytemp_gtap11%fs%
* $set tmpdir %gams.scrdir%

*	GTAP release version:

$set	gtapver GDX11c

$set gtapallyearfile %gtapdatadir%%gtapver%AY16994.zip
$set gtapdatafile %gtapver%%yr%.zip
$set gtapdatafilepath %tmpdir%%gtapdatafile%

*@ Do some unzipping

$if not exist "%gtapallyearfile%" $abort Cannot find GTAP data fie: "%gtapallyearfile%".

$call gmsunzip -j "%gtapallyearfile%" %gtapdatafile% -d %tmpdir%

$if not exist "%gtapdatafilepath%" $abort Cannot find GTAP file: "%gtapdatafilepath%".

$if exist %tmpdir%gsdfdat.gdx $goto load

$call gmsunzip -j "%gtapdatafilepath%" GSDFDAT.GDX -d %tmpdir%
$call gmsunzip -j "%gtapdatafilepath%" GSDFPAR.GDX -d %tmpdir%
$call gmsunzip -j "%gtapdatafilepath%" GSDFVOLE.GDX -d %tmpdir%
$call gmsunzip -j "%gtapdatafilepath%" GSDFEMISS.GDX -d %tmpdir%
$call gmsunzip -j "%gtapdatafilepath%" GSDFNCO2.GDX -d %tmpdir%

$if not exist %tmpdir%gsdfdat.gdx	$goto missinggdxfiles
$if not exist %tmpdir%gsdfpar.gdx	$goto missinggdxfiles
$if not exist %tmpdir%gsdfvole.gdx	$goto missinggdxfiles
$if not exist %tmpdir%gsdfemiss.gdx	$goto missinggdxfiles
$if not exist %tmpdir%gsdfnco2.gdx	$goto missinggdxfiles

$label load

set	r(*)	Regions,
	is(*)	Sectors,
	f(*)	Factors

$gdxin '%tmpdir%gsdfdat.gdx'
$load r=reg is=COMM f=ENDW

set	g	/c,g,i,sd,dd,set.is/,
	i(g)	/set.is/;

alias (i,j),(r,s), (u,*);

parameter
	mdf(i,j,r)	'Emissions from domestic product in current production, Mt CO2',
	mdg(i,r)	'Emissions from govt consumption of domestic product, Mt CO2',
	mdi(i,r)	'Emissions from invst consumption of domestic product, Mt CO2',
	mdp(i,r)	'Emissions from private consumption of domestic product, Mt CO2',
	mmf(i,j,r)	'Emissions from imports in current production, Mt CO2',
	mmg(i,r)	'Emissions from government consumption of imports, Mt CO2',
	mmi(i,r)	'Emissions from invst consumption of imports, Mt CO2',
	mmp(i,r)	'Emissions from private consumption of imports, Mt CO2';

$gdxin '%tmpdir%gsdfemiss.gdx'
$loaddc mdf mdg mdi mdp mmf mmg mmp mmi

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
*	adrv(i,r,s)	"Anti-dumping duty",
*	dpsm(r)		"Sum of distribution parameters in household demand system",
	evfp(f,i,r)	"Purchases of endowments by firms at purchasers' prices"
	evos(f,i,r)	"Post income tax factor income - now activity-specific"
*	fbep(f,i,r)	"Gross factor-based subsidies",
*	ftrv(f,i,r)	"Gross factor employment tax revenue",
*	isep(i,j,r,*)	"Net intermediate input subsidies",
*	osep(i,r)	"Net ordinary output subsidy",
	pop(r)		"Population",
	save(r)		"Net saving, by region",
*	tvom(i,r)	"Sales of domestic product, at basic prices",
	vdep(r)		"Capital depreciation",

	vdfp(i,g,r)	"Domestic purchases, by firms, at purchasers' prices",
	vdip(i,r)	"Domestic purchases, by investment, at purchasers' prices",
	vdfm(i,g,r)	"Domestic purchases, by firms, at basic prices",
	vdib(i,r)	"Domestic purchases, by investment, at basic prices",
	vdgp(i,r)	"Domestic purchases, by government, at purchasers' prices"
	vdgb(i,r)	"Domestic purchases, by government, at basic prices",
	vdpp(i,r)	"Domestic purchases, by households, at purchasers' prices",
	vdpb(i,r)	"Domestic purchases, by households, at basic prices",

	vfm(f,i,r)	"Purchases of endowments by firms at basic prices",
	vmfp(i,g,r)	"Import purchases, by firms, at purchasers' prices",
	vmip(i,r)	"Import purchases, by investment, at purchasers' prices",
	vifm(i,g,r)	"Import purchases, by firms, at basic prices",
	vmib(i,r)	"Import purchases, by investment, at basic prices",
	vmgp(i,r)	"Import purchases, by government, at purchasers' prices",
	vmgb(i,r)	"Import purchases, by government, at basic prices",
	vmsb(i,r,s)	"Imports, at basic (tariff-inclusive) prices",
	vmpp(i,r)	"Import purchases, by households, at purchasers' prices",
	vmpb(i,r)	"Import purchases, by households, at basic prices",
	vcif(i,r,s)	"Imports, at CIF prices",
	vkb(r)		"Capital stock",
	vst(i,r)	"Regional exports of intl. trade and transport services",

*	mfrv(i,r,s)	"Export tax equivalent of MFA quota premia",
*	purv(i,r,s)	"Export tax equivalent of price undertakings",
*	vrrv(i,r,s)	"Export tax equivalent of voluntary export restraints",
*	xtrv(i,r,s)	"Ordinary export tax"

*	tfrv(i,r,s)	"Ordinary import duty",
	vmts(ttype,i,r,s) "Import tariff rev by type of tariffs paid",

	vtwr(i,j,r,s)	"Modal distribution of intl. trade and transport services",
	vxmd(i,r,s)	"Bilateral trade at basic prices",
	vfob(i,r,s)	"Bilateral trade at FOB prices";

$gdxin '%tmpdir%gsdfdat.gdx'
$loaddc  vkb
$loaddc evfp evos pop save
$loaddc vdep vdfp vdip vdfm=vdfb vdib vdgp vdgb vdpp vdpb
$loaddc vmfp vmip vifm=vmfb vmib vmgp vmgb vmsb vmpp vmpb vcif
$loaddc vfm=evfb vst vtwr vxmd=vxsb vfob vmts

vdfp(i,"i",r) = vdip(i,r);
vmfp(i,"i",r) = vmip(i,r);
vdfm(i,"i",r) = vdib(i,r);
vifm(i,"i",r) = vmib(i,r);

parameter	vtrev(vtcomp,i,r,s)	All components of import and export taxes;
* vtrev("ad",i,r,s)    = adrv(i,r,s);
* vtrev("mfa",i,r,s)   = mfrv(i,r,s);
* vtrev("pu",i,r,s)   = purv(i,r,s);
* vtrev("ver",i,r,s)   = vrrv(i,r,s);
* vtrev("xt",i,r,s)    = xtrv(i,r,s);
* vtrev("tarif",i,r,s) = tfrv(i,r,s);
vtrev(ttype,i,r,s)   = vmts(ttype,i,r,s);

parameter
*	GTAP gave these region index, but it apears unused
	esubd_gtap(i,r)	"Elasticity of domestic-import substitution",
	esubm_gtap(i,r)	"Elasticity of import source substitution",
	esubt_gtap(i,r)	"Elasticity of top-level input substitution",
	esubva_gtap(i,r)	"Elasticity of factor substitution",
	etrae_gtap(f,r)	"Elasticity of transformation for sluggish endowments",
*	I want to abstract for region specificity as long as GTAP versions allow
	esubd(i)	"Elasticity of domestic-import substitution",
	esubm(i)	"Elasticity of import source substitution",
	esubt(i)	"Elasticity of top-level input substitution",
	esubva(i)	"Elasticity of factor substitution",
	etrae(f)	"Elasticity of transformation for sluggish endowments",
	incpar(i,r)	"Expansion parameter in the CDE minimum expenditure function",
	rorflex(r)	"Flexibility of expected net ROR wrt investment",
	subpar(i,r)	"Substitution parameter in CDE minimum expenditure function";

$gdxin '%tmpdir%gsdfpar.gdx'
$loaddc esubd_gtap=esubd esubm_gtap=esubm esubt_gtap=esubt esubva_gtap=esubva
$loaddc etrae_gtap=etrae
$loaddc incpar rorflex subpar

*	Tell me, if I need to make parameters region specific after all.
*	If not, assign values to non-region specific parameters.
loop(i,
    abort$(smin(r, esubd_gtap(i,r)) ne smax(r, esubd_gtap(i,r)))
	"Oh no. esubd_gtap actually varies across regions!",
	esubd_gtap;
    esubd(i) = esubd_gtap(i,"aus");
    abort$(smin(r, esubm_gtap(i,r)) ne smax(r, esubm_gtap(i,r)))
	"Oh no. esubm_gtap actually varies across regions!",
	esubm_gtap;
    esubm(i) = esubm_gtap(i,"aus");
    abort$(smin(r, esubt_gtap(i,r)) ne smax(r, esubt_gtap(i,r)))
	"Oh no. esubt_gtap actually varies across regions!",
	esubt_gtap;
    esubt(i) = esubt_gtap(i,"aus");
    abort$(smin(r, esubva_gtap(i,r)) ne smax(r, esubva_gtap(i,r)))
	"Oh no. esubva_gtap actually varies across regions!",
	esubva_gtap;
    esubva(i) = esubva_gtap(i,"aus");
);

loop(f,
    abort$(smin(r, etrae_gtap(f,r)) ne smax(r, etrae_gtap(f,r)))
	"Oh no. etrae_gtap actually varies across regions!",
	etrae_gtap;
    etrae(f) = etrae_gtap(f,"aus");
    abort$etrae("NatlRes")
	"Mmh, I got used to etrae having '0' entries at 'NatlRes',",
	"but this is no longer the case.",
	"I should reconsider correcting mf('NatlRes') and etrae(.) below."
	etrae;
);

set	fg(*) /set.f, set.g/;

*	In GTAP9inGAMS, these used to be read and then overwritten.
*	Since they are not in the GDX files provided on GTAP.org for GTAP10 and later,
*	don't load, but compute directly.
parameter
	rtf(f,i,r)	"Taxes on primary factors - ad valorem rate,",
	rtfd(i,g,r)	"Taxes on firms' domestic purchases - ad valorem rate,"
	rtfi(i,g,r)	"Taxes on firms' imports purchases -- ad valorem rate",
	rtms(i,r,s)	"Import taxes, by source -- ad valorem rate",
	rto(fg,r)	"Output (or income) subsidies in region r -- ad valorem rate",
	rtxs(i,r,s)	"Export subsidies, by destination -- ad valorem rate";

parameter
	edf(i,j,r)	"Usage of domestic product by firms, Mtoe",
	edg(i,r)	"Government consumption of domestic product, Mtoe",
	edp(i,r)	"Private consumption of domestic product, Mtoe",
	emf(i,j,r)	"Usage of imports by firms, Mtoe",
	emg(i,r)	"Government consumption of imports, Mtoe",
	emp(i,r)	"Private consumption of imports, Mtoe",
	exi(i,r,s)	"Volume of trade, Mtoe";

$gdxin "%tmpdir%gsdfvole.gdx"
$loaddc edf edg edp emf emg emp exi

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
	vdm(i,r)	Domestic sales of i in r at basic prices (tradeables only)
	vom(fg,r)	Value of commodity i output in region r at basic prices
	vpa(i,r)	Private household expenditure on i in r at purchaser's prices
	vga(i,r)	Government household expenditure on i in r at purchaser's prices

	echop_f		Check on factor markets,
	echop_m		Check on import markets,
	echop_b(*,*)	Regional budget balance,
	echop_t		Check on market for bilateral trade
	echop_tm	Check on market for transport margins
	echop_y		Check on market for produced goods and services
	echop_tax	Regional tax revenue

	evt(i,r,r)	Volume of energy trade (mtoe);

*	Assign some intermediate arrays:

vfa(fg(f),j,r) = evfp(f,j,r);
vfa(fg(i),j,s) = vdfp(i,j,s) + vmfp(i,j,s);
voa(fg(f),r) = sum(i, evos(f,i,r));

alias (fg,ffg);

voa(fg(i),r) = sum(ffg, vfa(ffg,i,r));

vdm(i,r) = vdpb(i,r) + vdgb(i,r) + sum(g, vdfm(i,g,r));

vom(fg(f),r) = sum(j, vfm(f,j,r));
vom(fg(i),r) = vdm(i,r) + sum(s, vxmd(i,r,s)) + vst(i,r);

vom("i",r) = voa("i",r);

vpa(i,s) = vdpp(i,s) + vmpp(i,s);
vga(i,s) = vdgp(i,s) + vmgp(i,s);

evt(i,r,s) = exi(i,r,s);

*	Compute tax rates from gross and net transactions:

rto(fg(i),r) = (1 - voa(fg,r)/vom(fg,r))$voa(fg,r);

rtf(f,j,r)$evfp(f,j,r) = evfp(f,j,r)/vfm(f,j,r) - 1;

*	Load private and public consumption in vdfm:

vdfm(i,"c",r) = vdpb(i,r);
vdfm(i,"g",r) = vdgb(i,r);

vom("c",r) = sum(i,vdpp(i,r)+vmpp(i,r));

rtfd(i,j,r)$vdfp(i,j,r) = vdfp(i,j,r)/vdfm(i,j,r) - 1;
rtfd(i,"i",r)$vdfp(i,"i",r) = vdfp(i,"i",r)/vdfm(i,"i",r) - 1;
rtfd(i,"c",r)$vdpp(i,r) = vdpp(i,r)/vdpb(i,r) - 1;
rtfd(i,"g",r)$vdgp(i,r) = vdgp(i,r)/vdgb(i,r) - 1;

*	Load private and public consumption in vifm:

vifm(i,"c",r) = vmpb(i,r);
vifm(i,"g",r) = vmgb(i,r);

rtfi(i,j,r)$vmfp(i,j,r) = vmfp(i,j,r)/vifm(i,j,r)-1;
rtfi(i,"i",r)$vmfp(i,"i",r) = vmfp(i,"i",r)/vifm(i,"i",r)-1;
rtfi(i,"c",r)$vmpp(i,r) = vmpp(i,r)/vmpb(i,r)-1;
rtfi(i,"g",r)$vmgp(i,r) = vmgp(i,r)/vmgb(i,r)-1;

vom("g",r) = sum(i,vdgp(i,r)+vmgp(i,r));

rtxs(i,r,s)$vfob(i,r,s) = vfob(i,r,s)/vxmd(i,r,s)-1;
rtms(i,r,s)$vmsb(i,r,s) = vmsb(i,r,s)/vcif(i,r,s)-1;

*	Provide an consistency check echoprint:

echop_m(i,s,"supply") = sum(r, vmsb(i,r,s));
echop_m(i,s,"demand") = sum(j, vifm(i,j,s)) + vifm(i,"c",s) + vifm(i,"g",s);
echop_m(i,s,"diff") = round(sum(r, vmsb(i,r,s)) -
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

echop_t(i,r,s,"demand") = vmsb(i,r,s);
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

echop_y(fg(i),r,"supply")$(not sameas(i,"i")) = vom(fg,r);
echop_y(i,r,"demand")$(not sameas(i,"i")) =
	sum(s, vxmd(i,r,s)) + vst(i,r) + sum(g,vdfm(i,g,r));
echop_y(i,r,"diff")$(not sameas(i,"i")) =
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
*	NatlRes does not appear in etrae, which I consider a mistake.
*	In the flex2gdx version of GTAP10, it's listed with 0.001
mf("NatlRes")	 = no;
etrae("NatlRes") = 0.001;

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
evi(i,j,r) = emf(i,j,r);
evi(i,"c",r) = emp(i,r);
evi(i,"g",r) = emg(i,r);

eco2d(i,j,r) = mdf(i,j,r);
eco2d(i,"g",r) = mdg(i,r);
eco2d(i,"i",r) = mdi(i,r);
eco2d(i,"c",r) = mdp(i,r);

eco2i(i,j,r)   = mmf(i,j,r);
eco2i(i,"g",r) = mmg(i,r);
eco2i(i,"i",r) = mmi(i,r);
eco2i(i,"c",r) = mmp(i,r);

set	ii(*)	Commodities,
 	gg(*)	Sectors and elements of final demand;

ii(i) = yes;
gg(g) = yes;

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
		eta, aues, incpar, subpar,
		pop, evd, evi, evt, eco2d, eco2i;

$exit

$label missinggdxfiles
$log
$log	*** Error *** Missing GDX files.
$log
$log	Reading from FLEXAGG archive %gtapdatafile%.
$log
$log	One of the following unzip actions seems to have failed
$log		gmsunzip -j "%gtapdatafile%" gsdfdat.gdx -d %tmpdir%
$log		gmsunzip -j "%gtapdatafile%" gsdfpar.gdx -d %tmpdir%
$log		gmsunzip -j "%gtapdatafile%" gsdfvole.gdx -d %tmpdir%
$log		gmsunzip -j "%gtapdatafile%" gsdfemiss.gdx -d %tmpdir%
$log		gmsunzip -j "%gtapdatafile%" gsdfnco2.gdx -d %tmpdir%
$log
$exit
