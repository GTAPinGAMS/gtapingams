$stitle		GAMS Code for GDP Reporting from the MGE Model

$ifthen.undefined not defined gdpcat

	set	gdpcat	GDP Categories  /
			expend		Expenditure (C + G + I - (X-M)),
			income		Income (Factor income + taxes),
			valueadded	Sectoral factor earnings plus tax payments, 
			total		Total GDP/,

		gdpitem /"X-M",set.g,set.f, 
			 revto,revtfd,revtfi,revtf,revtxs,revtms,
			 expend,income,valueadded,chksum/;

	alias (gdpitem, gdpi);

	parameter	gdp(gdpcat,*,gdpitem)	Real GDP accouting
			vadd(g, gdpitem, r)	GDP on a value-added basis;

$endif.undefined


$ondotl
loop(rm(r),
	gdp("expend",r,"C") =  RA(r)/pnum(r) 
		+ ( sum(i$vcm(i,r), PA(i,r)*vcm(i,r)*D(i,r))/pnum(r)
		  - sum(f_$evom(f_,r), PF(f_,r)*evom(f_,r)) /pnum(r) )$cde(r)
		+ (P("sd",r)*vom("sd",r)/pnum(r)                     )$vom("sd",r);

	gdp("expend",r,"X-M") = -vb(r)*(PFX$rx(rnum)+P("i",rnum)$rm(rnum))/pnum(r);
	gdp("expend",r,"g") = P("g",r)*vom("g",r)/pnum(r) ;
	gdp("expend",r,"i") = P("i",r)*vom("i",r)/pnum(r) ;

	vadd(i,gdpitem(f),r) = DFM(f,i,r)*(PF.L(f,r)*mf(f)+PS.L(f,i,r)$sf(f))/pnum(r);
	vadd(g,"revto",r) = REV_TO(g,r)/pnum(r);
	vadd(g,"revtfd",r) = sum(i,REV_TFD(i,g,r))/pnum(r);
	vadd(g,"revtfi",r) = sum(i,REV_TFI(i,g,r))/pnum(r);
	vadd(g,"revtf",r) = sum(f,REV_TF(f,g,r))/pnum(r);
	vadd(i,"revtxs",r) = -sum(s,REV_TXS(i,r,s))/pnum(r);
	vadd(i,"revtms",r) = sum(s, REV_TMS(i,s,r))/pnum(r);
	
	gdp("valueadded",r,gdpitem(g)) = sum(gdpi,vadd(g,gdpi,r));

	gdp("income",r,gdpitem(f)) = PF(f,r)*evom(f,r)/pnum(r);
	gdp("income",r,"revto") =  sum(g,REV_TO(g,r))/pnum(r);
	gdp("income",r,"revtfd") = sum((i,g), REV_TFD(i,g,r))/pnum(r);
	gdp("income",r,"revtfi") = sum((i,g), REV_TFI(i,g,r))/pnum(r);
	gdp("income",r,"revtf")  = sum((f,g), REV_TF(f,g,r))/pnum(r);
	gdp("income",r,"revtxs") = -sum((i,s), REV_TXS(i,r,s))/pnum(r);
	gdp("income",r,"revtms") = sum((i,s), REV_TMS(i,s,r))/pnum(r);

	gdp("total",r,"valueadded") = sum((g,gdpitem),vadd(g,gdpitem,r));

	gdp("total",r,"expend") = 
			gdp("expend",r,"c")
			+ gdp("expend",r,"i")
			+ gdp("expend",r,"g")
			+ gdp("expend",r,"x-m");
	gdp("total",r,"income") = 
			sum(gdpitem(f), gdp("income",r,gdpitem))
			+ gdp("income",r,"revto")
			+ gdp("income",r,"revtfd")
			+ gdp("income",r,"revtfi")
			+ gdp("income",r,"revtf")
			+ gdp("income",r,"revtxs")
			+ gdp("income",r,"revtms");
	gdp("total",r,"chksum") = abs(gdp("total",r,"expend") - gdp("total",r,"income")) +
				  abs(gdp("total",r,"expend") - gdp("total",r,"valueadded")) ;
); 

