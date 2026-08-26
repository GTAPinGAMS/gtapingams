$title	 Calibrate the CDE Demand Systems

$if not set threads $set threads 8
option threadsAsync=%threads%;
$if not %threads%==1 option limrow=0, limcol=0, solprint=off;

$if not set yr $set yr 17
$if not set ds $set ds g20

$set fs %system.dirsep%
$set code ..%fs%code%fs%

$include "%code%gtap11data"

alias (r,rr), (i,k);

parameter	p(i)	Price index,
		e(r)	Expenditure;
p(i) = 1;
e(r) = 1;

variables	D(i,r), U(r), C(r);

D.L(i,r) = 1$thetac(i,r);
U.L(r) = 1;
C.L(r) = 1;

equations	ddef, udef, cdef;

ddef(i,r)$thetac(i,r)..
	D(i,r) * sum(j$thetac(j,r), thetac(j,r) * U(r)**((1-subpar(j,r))*incpar(j,r)) *
		(p(j)/C(r))**(1-subpar(j,r))) =e= U(r)**((1-subpar(i,r))*incpar(i,r)) *
		(p(i)/C(r))**(-subpar(i,r));

udef(r)..
	sum(i$thetac(i,r), thetac(i,r)*D(i,r)*p(i)) =e= e(r);

cdef(r)..
	sum(i, thetac(i,r) * U(r)**((1-subpar(i,r))*incpar(i,r)) *
		(p(i)/C(r))**(1-subpar(i,r))) =e= 1;

model cdechk /ddef.D, udef.U, cdef.C/;

cdechk.iterlim = 0;
solve cdechk using mcp;
abort$(cdechk.objval > 1e-3) "CDE benchmark inconsistency.";
cdechk.iterlim = 10000;

parameter	peps		Numerical differencing interval /0.01/,
		elaslog		Own price elasticity,
		dcdp(j,r)	"Derivative of D(j,r) wrt p(i)";

alias (i,k);

loop(k$sum(r,thetac(k,r)),
	p(k) = p(k) + peps;
	solve cdechk using mcp;
	dcdp(k,r)$thetac(k,r) = (D.L(k,r)-1)/peps;
	p(k) = p(k) - peps;
);


elaslog(i,r,"epsilon")$thetac(i,r) = aues(i,i,r)*thetac(i,r);
elaslog(i,r,"epsilon_n")$thetac(i,r) = dcdp(i,r);

e(r) = 1 + peps;
solve cdechk using mcp;
elaslog(i,r,"eta")$thetac(i,r) = eta(i,r);
elaslog(i,r,"eta_n")$thetac(i,r) = (D.L(i,r)-1)/peps;

option elaslog:1:2:1;
display elaslog;
