$title	 GTAP12inGAMS -- GAMS/MCP Formulation

$if not set yr $set yr 23
$if not set ds $set ds g20_macro
$include "%system.fp%gtap12data"

nonnegative
variables

*$sectors:
	Y(g,r)		Supply
	M(i,r)		Imports
	YT(j)		Transportation services
	FT(f,r)		Specific factor transformation
	X(i,r)		Exports to rest of world (SOE model)
	A(i,r)		Armington final demand quantity index (CDE model)

*$commodities:
	P(g,r)		Domestic output price
	PA(i,r)		Armington final demand price
	PE(g,r)		Export market
	PM(j,r)		Import price
	PT(j)		Transportation services
	PF(f,r)		Primary factors rent
	PS(f,g,r)	Sector-specific primary factors
	PFX		Real exchange rate (SOE model)

*$consumers:
	RA(r)		Representative agent
	ROW		Rest of world (SOE model)

*$auxiliary:
	D(i,r)		CDE Demand (index)
	U(r)		CDE utility (index)
	CC(r)		CDE Consumption cost index,
	W(r)		CDE money metric welfare;

equations
        prf_y(g,r)              Supply,
        prf_a(i,r)              Armington demand,
        prf_x(i,r)              Exports,
        prf_m(i,r)              Imports,
        prf_yt(j)               Transportation services,
        prf_ft(f,r)             Factor transformation,

        mkt_p(g,r)              Domestic market,
        mkt_pe(g,r)             Export market,
        mkt_pm(j,r)             Import market,
        mkt_pa(i,r)             Armington market,
        mkt_pt(j)               Transportation service market,
        mkt_pf(f,r)             Primary factor markets,
        mkt_ps(f,j,r)           Specific factor markets,
	mkt_pfx			Market for foreign exchange,

        inc_ra(r)               Representative agent
	inc_row			Rest of world agent

	constraint_D		Defines D (CDE model)
	constraint_U		Defines U (CDE model)
	constraint_CC		Defines CC (CDE model),
	constraint_W		Defines W (CDE model);

*       -----------------------------------------------------------------------------

*       Define some macros which diagnose the functional form:

$macro  Leontief(sigma)         (yes$(round(sigma,2)=0))
$macro  CobbDouglas(sigma)      (yes$(round(sigma-1,2)=0))
$macro  CES(sigma)              (yes$(round(sigma-1,2)<>0 and round(sigma,2)<>0))

*       -------------------------------------------------------------------------------

*       Benchmark value shares:

parameter
	cf0(g,r)		Factor cost
	cm0(g,r)		Material cost
	cy0(g,r)		Reference total cost,
	theta_cf0(g,r)		Value added share of cost,
	theta_vfm(f,g,r)	Factor share of value added,
	theta_cm0(i,g,r)	Armington share of material cost,
	theta_vdfm(i,g,r)	Domestic share of Armington composite,
	theta_vxm(g,r)		Export share of output,
	theta_vst(j,r)		Value share,
	theta_vxmd(i,s,r)	Value share of goods in imports,
	theta_vtwr(j,i,s,r)	Value share of transportation services,
	theta_vim(i,s,r)	Bilateral import value share
	vxmt(i,s,r)		Value of imports gross transport cost,
	vxmd0(i,r,s)		Trade - bilateral exports at market prices (dataset values),
	vtwr0(j,i,r,s)		Trade - margins for international transportation at world prices,
	theta_evom(f,j,r)	Value shares of specific factors;

vxmd0(i,r,s) = vxmd(i,r,s);
vtwr0(j,i,r,s) = vtwr(j,i,r,s);

$setlocal datetime %system.date%%system.time%
$echo   *       Calibration code for mcp.gms (%datetime%)    >gtap12.gen

*	Save copy of the benchmark trade flows so that we can turn off
*	demand as needed in the SOE model:

vxmd(i,r,s) = vxmd0(i,r,s);
vxmd(i,rx(r),rm(s)) = vxmd0(i,r,s)$vem(i,r);

vtwr(j,i,r,s) = vtwr0(j,i,r,s);
vtwr(j,i,rx(r),rm(s)) = vtwr0(j,i,r,s)$vem(i,r);

*       User cost indices for factors, domestic and imported
*       intermediate inputs:

$macro P_PF(f,g,r) (((PF(f,r)$mf(f)+PS(f,g,r)$sf(f))*(1+rtf(f,g,r)) \
                / (1+rtf0(f,g,r)))$theta_vfm(f,g,r)  + 1$(theta_vfm(f,g,r)=0))

$macro P_D(i,g,r)  ((P(i,r)*(1+rtfd(i,g,r)) \
                / (1+rtfd0(i,g,r)))$theta_vdfm(i,g,r) + 1$(not theta_vdfm(i,g,r)))

$macro P_I(i,g,r)  ((PM(i,r)*(1+rtfi(i,g,r)) \
                / (1+rtfi0(i,g,r)))$(1-theta_vdfm(i,g,r)) + 1$(theta_vdfm(i,g,r)=1))

*       Compensated cost functions:

$if defined f_ $abort "The CF(g,r) macro requires a uniquely defined alias for f."
alias (f,f_);

*	Factor cost index:

$macro C_F(g,r) ( \
        ( (sum(f_$theta_vfm(f_,g,r),  theta_vfm(f_,g,r)*P_PF(f_,g,r)))$Leontief(esubva(g)) + \
          (prod(f_$theta_vfm(f_,g,r), P_PF(f_,g,r)**theta_vfm(f_,g,r)))$CobbDouglas(esubva(g)) + \
          (sum(f_$theta_vfm(f_,g,r),  theta_vfm(f_,g,r)*P_PF(f_,g,r)**(1-esubva(g)))**(1/(1-esubva(g))))$CES(esubva(g)))$cf0(g,r) )

*	Armington cost index:

$macro C_A(i,g,r) ( \
        (theta_vdfm(i,g,r)*P_D(i,g,r) + (1-theta_vdfm(i,g,r))*P_I(i,g,r))$Leontief(esubdm(i)) + \
        (P_D(i,g,r)**theta_vdfm(i,g,r) * P_I(i,g,r)**(1-theta_vdfm(i,g,r)))$CobbDouglas(esubdm(i)) + \
        ( (theta_vdfm(i,g,r) *P_D(i,g,r)**(1-esubdm(i)) + \
        (1-theta_vdfm(i,g,r))*P_I(i,g,r)**(1-esubdm(i)))**(1/(1-esubdm(i))))$CES(esubdm(i)))

$if defined i_ $abort "The C_M(g,r) macro requires a uniquely defined alias for i."
alias (i,i_);
$macro C_M(g,r) ( \
 ( (sum(i_$theta_cm0(i_,g,r),  theta_cm0(i_,g,r) * C_A(i_,g,r)**(1-esub(g,r)))**(1/(1-esub(g,r))))$CES(esub(g,r)) + \
    prod(i_$theta_cm0(i_,g,r), C_A(i_,g,r)**theta_cm0(i_,g,r))$CobbDouglas(esub(g,r)) + \
    sum(i_$theta_cm0(i_,g,r),  theta_cm0(i_,g,r) * C_A(i_,g,r))$Leontief(esub(g,r)) ) )

*       Unit cost function:

$macro C_Y(g,r) (theta_cf0(g,r)*C_F(g,r) + (1-theta_cf0(g,r))*C_M(g,r))

*       Unit revenue function:

$macro R_Y(g,r) (  P(g,r)$(not vxm(g,r)) + \
 (((1-theta_vxm(g,r))*  P(g,r)**(1+etadx(g)) + \
      theta_vxm(g,r) * PE(g,r)**(1+etadx(g)))**(1/(1+etadx(g))))$vxm(g,r) )

*       Demand functions:

$macro DDY(i,g,r)	((vdfm(i,g,r)*Y(g,r)*(C_A(i,g,r)/P_D(i,g,r))**esubdm(i) * \
			                       (C_M(g,r)/C_A(i,g,r))**esub(g,r))$vdfm(i,g,r))

$macro DDA(i,r)		((vdfm(i,"C",r)*A(i,r)*(C_A(i,"C",r)/P_D(i,"C",r))**esubdm(i) * \
			                         (C_M("C",r)/C_A(i,"C",r))**esub("c",r))$vdfm(i,"c",r))

$macro DIY(i,g,r)	((vifm(i,g,r)   * Y(g,r) * (C_A(i,g,r) /P_I(i,g,r)  )**esubdm(i) * \
			                           (C_M(g,r)/C_A(i,g,r))**esub(g,r))$vifm(i,g,r))

$macro DIA(i,r)		((vifm(i,"c",r) * A(i,r) * (C_A(i,"C",r)/P_I(i,"C",r))**esubdm(i))$(vifm(i,"C",r)*vcm(i,r)))

$macro DDFM(i,g,r)	(DDY(i,g,r)$vom(g,r) + DDA(i,r)$(sameas(g,"c") and cde(r) and vcm(i,r)))

$macro DIFM(i,g,r)	(DIY(i,g,r)$vom(g,r) + DIA(i,r)$(sameas(g,"c") and cde(r) and vcm(i,r)))

$macro DFM(f,g,r)	(vfm(f,g,r)  * Y(g,r) * (C_F(g,r)/P_PF(f,g,r))**esubva(g))$vfm(f,g,r)

$macro S_D(g,r)		((1$(not vxm(g,r)) + ((P(g,r) /R_Y(g,r))**etadx(g))$vxm(g,r)) * \
			(vom(g,r)-vxm(g,r)) * Y(g,r))

$macro S_E(g,r)		(vxm(g,r)*Y(g,r)*(PE(g,r)/R_Y(g,r))**etadx(g))

*       Associated tax revenue flows:

$macro REV_TO(g,r)  (rto(g,r)*R_Y(g,r)*vom(g,r)*Y(g,r))

$macro REV_TFD(i,g,r)	((rtfd(i,g,r) * P(i,r)  * DDFM(i,g,r))$(rm(r)*rtfd(i,g,r)*vdfm(i,g,r)))

$macro REV_TFI(i,g,r)	((rtfi(i,g,r) * PM(i,r) * DIFM(i,g,r))$(rm(r)*rtfi(i,g,r)*vifm(i,g,r)))

$macro REV_TF(f,g,r) 	((rtf(f,g,r)  * DFM(f,g,r) * ((PS(f,g,r))$sf(f)+(PF(f,r))$mf(f)))$(rm(r)*vom(g,r)*rtf(f,g,r)*vfm(f,g,r)))

prf_y(g,r)$(rm(r)*vom(g,r))..   cy0(g,r)*C_Y(g,r) =e= vom(g,r)*(1-rto(g,r))*R_Y(g,r);

*	-----------------------------------------------------------------------------
*	Profit function for exports to ROW:

* $prod:X(i,r)$(rm(r)*vem(i,r))
*	o:PFX				q:(pem0(i,r)*vem(i,r))
*	i:P(i,r)$(not vxm(i,r))		q:vem(i,r)	a:RA(r)	t:(-rtxs_row(i,r))
*	i:PE(i,r)$vxm(i,r)		q:vem(i,r)	a:RA(r)	t:(-rtxs_row(i,r))

*	-----------------------------------------------------------------------------
*	Profit function for imports from ROW:

* $prod:X(i,r)$(rx(r)*vem(i,r))
*	o:PE(i,r)		q:vem(i,r)
*	o:PFX			q:vem(i,r)

$macro	PX(i,r)		((P(i,r)$(not vxm(i,r)) + PE(i,r)$vxm(i,r))$rm(r) + PE(i,r)$rx(r))

prf_x(i,r)$vem(i,r)..
		(PX(i,r) * (1-rtxs_row(i,r)) - pem0(i,r)*    PFX)$rm(r) +
		(PFX                         -           PE(i,r))$rx(r) =e= 0;

*	-----------------------------------------------------------------------------
*	Profit function for international transportation services:

*	$prod:YT(j)$vtw(j)  s:1
*		o:PT(j)				q:vtw(j)
*		i:PE(j,r)$(rm(r)*vxm(j,r)) 	q:vst(j,r)
*		i:P(j,r)$(rm(r)*(not vxm(j,r)))	q:vst(j,r)
*		i:PFX				q:(sum(rx(r),vst(j,r)))


$macro PYT(j,r)	(PX(j,r)$rm(r) + (PFX)$rx(r))

prf_yt(j)$vtw(j).. sum(r,vst(j,r)) *
	prod(r, PYT(j,r)**theta_vst(j,r)) =e= vtw(j)*PT(j);

*	Demand Function:

$macro DST(j,r)    ((vst(j,r)*YT(j)*PT(j)/PYT(j,r))$vst(j,r))

*	-----------------------------------------------------------------------------
*	Profit function for bilateral trade aggregation:

* $prod:M(i,r)$(rm(r)*vim(i,r))	s:esubm(i)  s.tl:0
*	o:PM(i,r)	q:vim(i,r)
*	i:PE(i,s)$(rm(s)*vxm(i,s))	q:vxmd(i,s,r)	p:pvxmd(i,s,r) s.tl:
* +		a:RA(s) t:(-rtxs(i,s,r)) a:RA(r) t:(rtms(i,s,r)*(1-rtxs(i,s,r)))
*	i:P(i,s)$(rm(s)*(not vxm(i,s)))	q:vxmd(i,s,r)	p:pvxmd(i,s,r) s.tl:
* +		a:RA(s) t:(-rtxs(i,s,r)) a:RA(r) t:(rtms(i,s,r)*(1-rtxs(i,s,r)))
*	i:PT(j)#(s)			q:vtwr(j,i,s,r) p:pvtwr(i,s,r) s.tl:
* +		a:RA(r) t:rtms(i,s,r)
*	i:PE(i,rx)$vem(i,rx)		q:vxmd(i,rx,r)	p:pvxmd(i,rx,r) rx.tl:
* +		a:ROW t:(-rtxs(i,rx,r))    a:RA(r) t:(rtms(i,rx,r)*(1-rtxs(i,rx,r)))

*	User cost indices:

$macro P_M(i,s,r)   ((PX(i,s) * \
	(1-rtxs(i,s,r))*(1+rtms(i,s,r))/pvxmd(i,s,r))$vxmd(i,s,r) + 1$(vxmd(i,s,r)=0))

$macro P_T(j,i,s,r) ((PT(j)*(1+rtms(i,s,r))/pvtwr(i,s,r))$vtwr(j,i,s,r)+1$(vtwr(j,i,s,r)=0))

*	Price index of bilateral imports (Leontief cost function):

$if defined j1 $abort "The PT_M(i,s,r) macro requires a uniquely defined alias for j."
alias (j,j1);
$macro PT_M(i,s,r) (P_M(i,s,r)*theta_vxmd(i,s,r) + sum(j1, P_T(j1,i,s,r)*theta_vtwr(j1,i,s,r)))

*	Unit cost function for imports (CES):

$if defined s_ $abort "The CIM(i,r) macro requires a uniquely defined alias for s."
alias (s,s_);
$macro CIM(i,r) ( \
   sum(s_, theta_vim(i,s_,r) * PT_M(i,s_,r) )$Leontief(esubm(i)) + \
   prod(s_, PT_M(i,s_,r)**theta_vim(i,s_,r) )$CobbDouglas(esubm(i)) + \
  (sum(s_, theta_vim(i,s_,r) * PT_M(i,s_,r)**(1-esubm(i)))**(1/(1-esubm(i))))$CES(esubm(i)) )

prf_m(i,rm(r))$vim(i,r)..	CIM(i,r)*vim(i,r) =e= PM(i,r)*vim(i,r);

*	Demand function:

$macro DXMD(i,s,r)   ((vxmd(i,s,r)   * M(i,r) * (PM(i,r)/PT_M(i,s,r))**esubm(i))$vxmd(i,s,r))
$macro DTWR(j,i,s,r) ((vtwr(j,i,s,r) * M(i,r) * (PM(i,r)/PT_M(i,s,r))**esubm(i))$vtwr(j,i,s,r))

*	Associated tax revenue:

alias (rm,sm);

$macro XMD(i,s,r)	((DXMD(i,s,r)/vxmd(i,s,r))$(rm(r)*vim(i,r)*vxmd(i,s,r)) + X(i,s)$(rm(s) and rx(r) and vxmd(i,s,r)))
$macro REV_TXS(i,s,r)	((XMD(i,s,r)*vxmd(i,s,r)*PX(i,s)*rtxs(i,s,r))$(rm(s) and vxmd(i,s,r)))

$if defined j2 $abort "The REVTMS(r) macro requires a uniquely defined alias for j."
alias (j,j2);

$macro REV_TMS(i,s,r)	((XMD(i,s,r)*rtms(i,s,r)* \
		((1-rtxs(i,s,r))*vxmd(i,s,r)*PX(i,s) + \
		 sum(j$vtwr(j,i,s,r), PT(j)*vtwr(j,i,s,r))))$(rm(r)*vxmd(i,s,r)*rtms(i,s,r)))

*	-----------------------------------------------------------------------------
*	Transforamtion sector for sluggish factors:

*	$prod:FT(sf,r)$evom(sf,r)  t:etrae(sf)
*		o:PS(sf,j,r)	q:vfm(sf,j,r)
*		i:PF(sf,r)	q:evom(sf,r)

$if defined j3 $abort "The PVFM(sf,r) macro requires a uniquely defined alias for j."
alias (j,j3);
$macro PVFM(sf,r) (sum(j3,theta_evom(sf,j3,r)*PS(sf,j3,r)**(1+etrae(sf)))**(1/(1+etrae(sf))))

prf_ft(sf,rm(r))$evom(sf,r)..	evom(sf,r)*PF(sf,r) =e= evom(sf,r)*PVFM(sf,r);

*	-----------------------------------------------------------------------------
* $prod:A(i,r)$(cde(r)*rm(r)*vcm(i,r))  s:esubdm(i)
*	o:PA(i,r)	q:vcm(i,r)
*	i:P(i,r)	q:vdfm(i,"c",r)	p:(1+rtfd0(i,"c",r)) a:RA(r) t:rtfd(i,"c",r)
*	i:PM(i,r)	q:vifm(i,"c",r)	p:(1+rtfi0(i,"c",r)) a:RA(r) t:rtfi(i,"c",r)

prf_a(i,r)$(cde(r)*rm(r)*vcm(i,r))..	C_A(i,"c",r) =g= PA(i,r);

*	-----------------------------------------------------------------------------
*	Income balance conditions:

* $demand:RA(r)$rm(r)  s:0
*	d:P("c",r)		q:vom("c",r)
*	e:P("g",r)		q:(-vom("g",r))
*	e:P("i",r)		q:(-vom("i",r))
*	e:P("i",rnum)$rm(rnum)	q:vb(r)
*	e:PFX$rx(rnum)		q:vb(r)
*	e:PF(f,r)		q:evom(f,r)
*	d:PF(f,r)$cde(r)	q:evom(f,r)
*	e:PF(f,r)$cde(r)	q:evom(f,r)
*	e:PA(i,r)		q:(-vcm(i,r))	R:D(i,r)

inc_ra(rm(r))$(RA.LO(r) < RA.UP(r))..
	RA(r) =e=	( sum(f$evom(f,r), PF(f,r)*evom(f,r))
			- sum(i$vcm(i,r), PA(i,r)*vcm(i,r)*D(i,r)) )$cde(r)
			- (P("sd",r)*vom("sd",r))$les(r)
			+ vb(r)*((PFX)$rx(rnum)+P("i",rnum)$rm(rnum))
			- P("g",r)*vom("g",r)
			- P("i",r)*vom("i",r)
			+ sum(f$evom(f,r), PF(f,r)*evom(f,r))
			+ sum(g,REV_TO(g,r))
			+ sum((i,g),REV_TFD(i,g,r))
			+ sum((i,g),REV_TFI(i,g,r))
			+ sum((f,g),REV_TF(f,g,r))
			- sum((i,s),REV_TXS(i,r,s))
			+ sum((i,s),REV_TMS(i,s,r));

constraint_D(i,r)$(cde(r)*rm(r)*vcm(i,r))..
	D(i,r) * sum(j$thetac(j,r), thetac(j,r) *
	  U(r)**((1-incpar(j,r))*subpar(j,r)) *
		(PA(j,r)/CC(r))**(1-incpar(j,r)))
		   =e= U(r)**((1-incpar(i,r))*subpar(i,r)) *
			(PA(i,r)/CC(r))**(-incpar(i,r));

constraint_U(r)$(cde(r)*rm(r))..
	sum(f, PF(f,r)*evom(f,r)) =e= RA(r);

constraint_CC(r)$(cde(r)*rm(r))..
	sum(i, thetac(i,r) * U(r)**((1-incpar(i,r))*subpar(i,r)) *
		(PA(i,r)/CC(r))**(1-incpar(i,r))) =e= 1;

constraint_W(r)$(cde(r)*rm(r))..
	sum(i, thetac(i,r) * U(r)**((1-subpar(i,r))*incpar(i,r)) *
			 (1/W(r))**(1-subpar(i,r))) =e= 1;

*	$demand:ROW$card(rx)
*	e:PFX			q:(rowpfx)
*	e:P("i",rnum)$rm(rnum)	q:(-sum(rm,vb(rm)))
*	e:PT(j)			q:(-sum((i,s,r)$rx(r), vtwr(j,i,s,r)))
*	d:PFX

inc_row$card(rx)..
	ROW =e= PFX*rowpfx - (P("i",rnum)*sum(rm,vb(rm)))$rm(rnum)
		- sum(j, PT(j)*sum((i,s,rx), vtwr(j,i,s,rx)))
		- sum((i,rx,rm)$vxmd(i,rx,rm), rtxs(i,rx,rm) * PFX * DXMD(i,rx,rm));

*	-----------------------------------------------------------------------------
*	Market clearance associated with firm output:

alias (g,gg);

mkt_p(g,rm(r))$(rm(r)*(vom(g,r)-vxm(g,r)))..
	S_D(g,r) =e= (RA(r)/P(g,r))$((sameas(g,"c") and cd(r)) or (sameas(g,"dd") and les(r))) +
		vom(g,r)$(sameas(g,"G") or sameas(g,"I") or sameas(g,"sd")) +
		sum(i$sameas(i,g),
		  sum(gg,DDFM(i,gg,r)) +
			(X(i,r)*vem(i,r)+sum(sm(s),DXMD(i,r,s)) + DST(i,r))$(not vxm(i,r)));

mkt_pe(i,r)$(rm(r)*vxm(i,r) or rx(r)*vem(i,r))..
	S_E(i,r)$rm(r) + (X(i,r)*vem(i,r))$rx(r) =e= sum(sm(s),DXMD(i,r,s)) + (X(i,r)*vem(i,r) + DST(i,r))$rm(r);

*	-----------------------------------------------------------------------------
*	Market clearance associated with imports:

mkt_pm(i,rm(r))$vim(i,r)..	M(i,r) * vim(i,r) =e= sum(g, DIFM(i,g,r));

*	-----------------------------------------------------------------------------
*	Market clearance associated with transport services:

mkt_pt(j)$vtw(j)..	YT(j) * vtw(j) =e= sum((i,s,r)$vtwr(j,i,s,r), DTWR(j,i,s,r)$rm(r) + vtwr(j,i,s,r)$rx(r));

*	-----------------------------------------------------------------------------
*	Market clearance associated with primary factors:

mkt_pf(f,rm(r))$evom(f,r)..
	evom(f,r) =e= sum(j, DFM(f,j,r))$mf(f) + (evom(f,r)*FT(f,r))$sf(f);

*	-----------------------------------------------------------------------------
*	Market clearance associated with specific factors:

mkt_ps(sf,j,rm(r))$vfm(sf,j,r)..
	vfm(sf,j,r) * (PS(sf,j,r)/PF(sf,r))**etrae(sf) * FT(sf,r) =e= DFM(sf,j,r);

*	-----------------------------------------------------------------------------
*	Market clearance associated with Armington demand (CDE):

mkt_pa(i,rm(r))$(cde(r)*vcm(i,r))..  A(i,r)*vcm(i,r) =e= D(i,r)*vcm(i,r);

*	-----------------------------------------------------------------------------
*	Market clearance foreign exchange:

mkt_pfx$card(rx)..
	sum(rm(r), vb(r))$rx(rnum) + sum((i,rm)$vem(i,rm), X(i,rm)*pem0(i,rm)*vem(i,rm)) + rowpfx
		=e= sum(j$vtw(j),sum(rx,vst(j,rx))*YT(j)*PT(j)/PFX) + sum((i,rx)$vem(i,rx),X(i,rx)*vem(i,rx)) + ROW/PFX;

model gtap12 /
	prf_y.Y,prf_x.X,prf_a.A,prf_m.M,prf_yt.YT,prf_ft.FT,
	mkt_p.P,mkt_pe.PE,mkt_pa.PA,mkt_pm.PM,mkt_pt.PT,mkt_pf.PF,mkt_ps.PS,mkt_pfx.PFX,
	constraint_D.D, constraint_U.U, constraint_CC.CC, constraint_W.W,
	inc_ra.RA, inc_row.ROW/;

model gtap12cns /
	prf_y,prf_x,prf_a,prf_m,prf_yt,prf_ft,
	mkt_p,mkt_pe,mkt_pa,mkt_pm,mkt_pt,mkt_pf,mkt_ps,mkt_pfx,
	constraint_D, constraint_U, constraint_CC, constraint_W,
	inc_ra, inc_row/;

*	Assign default values:

Y.L(g,r) = 1;
A.L(i,r) = 1;
X.L(i,r) = 1;
M.L(i,r) = 1;
YT.L(j) = 1;
FT.L(sf,r) = 1;
P.L(g,r) = 1;
PA.L(i,r) = 1;
PM.L(j,r) = 1;
PM.FX(j,r)$(not vim(j,r))  = 0;
PT.L(j) = 1;
PF.L(f,r) = 1;
PS.L(sf,j,r) = 1;
PFX.L = 1;
X.L(i,r)$vem(i,r) = 1;
PE.L(i,r)$vxm(i,r) = 1;
D.L(i,r) = 1;
U.L(r) = 1;
CC.L(r) = 1;
W.L(r) = 1;

*	Assign some lower bounds to avoid bad function calls:

P.LO(g,r)$vom(g,r) = 0.001;
PM.LO(j,r)$vim(j,r) = 0.001;
PT.LO(j) = 0.001;
PF.LO(f,r)$evom(f,r) = 0.001;
PS.LO(sf,g,r)$vfm(sf,g,r) = 0.001;

*	Calibration algebra:

$onechov >>gtap12.gen

cf0(g,r) = sum(f, vfm(f,g,r)*(1+rtf0(f,g,r)));
cm0(g,r) = sum(i, vdfm(i,g,r)*(1+rtfd0(i,g,r)) + vifm(i,g,r)*(1+rtfi0(i,g,r)));
cy0(g,r) = cf0(g,r) + cm0(g,r);
theta_cf0(g,r)$vom(g,r)  = cf0(g,r) / cy0(g,r);

theta_vfm(f,g,r)$cf0(g,r) = vfm(f,g,r)*(1+rtf0(f,g,r)) / cf0(g,r);
theta_cm0(i,g,r)$cm0(g,r) =
	(vdfm(i,g,r)*(1+rtfd0(i,g,r)) + vifm(i,g,r)*(1+rtfi0(i,g,r))) / cm0(g,r);
theta_vdfm(i,g,r)$vdfm(i,g,r) = vdfm(i,g,r)*(1+rtfd0(i,g,r)) /
	(vdfm(i,g,r)*(1+rtfd0(i,g,r)) + vifm(i,g,r)*(1+rtfi0(i,g,r)));
theta_vxm(g,r)$vom(g,r)  = vxm(g,r)/vom(g,r);
theta_vst(j,r)$vtw(j) = vst(j,r)/sum(r.local,vst(j,r));
vxmt(i,s,r)$vxmd(i,s,r)		= vxmd(i,s,r)*pvxmd(i,s,r) + sum(j,vtwr(j,i,s,r)*pvtwr(i,s,r));

vxmt(i,s,r)$(rx(s) and rm(r) and (not vem(i,s))) = 0;

theta_vxmd(i,s,r)= (vxmd(i,s,r)*pvxmd(i,s,r) / vxmt(i,s,r))$vxmt(i,s,r);
theta_vtwr(j,i,s,r) = (vtwr(j,i,s,r)*pvtwr(i,s,r) / vxmt(i,s,r))$vxmt(i,s,r);
theta_vim(i,s,r)$vxmt(i,s,r)	= vxmt(i,s,r)/vim(i,r);
theta_evom(sf,j,r)$evom(sf,r) = vfm(sf,j,r)/evom(sf,r);

RA.L(r) = vom("c",r)$cd(r) + vom("dd",r)$les(r) + sum(f,evom(f,r))$cde(r);

ROW.L = rowpfx 	- sum(rm,vb(rm))$rm(rnum) - sum((j,i,s,rx), vtwr(j,i,s,rx))
	- sum((i,rx,rm), rtxs(i,rx,rm)*vxmd(i,rx,rm));
RA.LO(r) = 0; RA.UP(r) = +INF; RA.FX(rnum) = RA.L(rnum);
$offecho

$macro pnum(r) (sum(i_, P.L(i_,r)*vdfm(i_,"c",r)+PM.L(i_,r)*vifm(i_,"c",r))/sum(i_,vdfm(i_,"c",r)+vifm(i_,"c",r)))

parameter	maxdev /1e-3/;

gtap12.workspace = 1024;
gtap12.iterlim = 0;
$include gtap12.gen
solve gtap12 using mcp;
abort$(gtap12.objval > maxdev) "GTAP12 replication fails.", gtap12.objval;
