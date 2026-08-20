$title	Load SOE and GMR Models with Alternative Demand Systems

$set fs %system.dirsep%
$set code ..%fs%code%fs%

$if not set yr $set yr 14
$if not set ds $set ds g20_macro
$if not set mdl $set mdl mge

$include %code%%mdl%

$call mv gtap10.gen %gams.scrdir%gtap10.gen

$include %code%loadmdl

file	ktitle; ktitle.lw=0; ktitle.nw=0; ktitle.nd=0;

put_utility 'title' / ktitle 'Solve the GMR model with LES demand.';
loadles(r);
gtap10.iterlim = 0;
$include %gams.scrdir%gtap10.gen
solve gtap10 using mcp;

abort$(gtap10.objval > maxdev) "GMR with LES replication fails.", gtap10.objval;

*	Solve the GMR model with CD demand:

put_utility 'title' / ktitle 'Solve the GMR model with CD demand.';
loadrm(r);
loadcd(r);
gtap10.iterlim = 0;
$include %gams.scrdir%gtap10.gen
solve gtap10 using mcp;
abort$(gtap10.objval > maxdev) "GMR with LES replication fails.", gtap10.objval;

*	Solve the GMR model with CDE demand:

put_utility 'title' / ktitle 'Solve the GMR model with CDE demand.';
loadcde(r);
$include %gams.scrdir%gtap10.gen
gtap10.iterlim = 0;
solve gtap10 using mcp;
abort$(gtap10.objval > maxdev) "GMR with CDE replication fails.", gtap10.objval;

*	Solve SOE models with LES demand:

loop(rr,
	loadles(rr);
	loadrm(rr);
	gtap10.iterlim = 0;

	put_utility 'title' / ktitle 'Solve the SOE model for ',rr.tl,' with LES demand.';

	option limrow=1000, limcol=1000;
$include %gams.scrdir%gtap10.gen
	solve gtap10 using mcp;
	abort$(gtap10.objval > maxdev) "SOE with LES replication fails.", gtap10.objval;
);

*	Solve SOE models with Cobb-Douglas demand:

loop(rr,

	put_utility 'title' / ktitle 'Solve the SOE model for ',rr.tl,' with CD demand.';
	loadcd(rr);
	loadrm(rr);
	gtap10.iterlim = 0;
$include %gams.scrdir%gtap10.gen
	solve gtap10 using mcp;
	abort$(gtap10.objval > maxdev) "SOE with Cobb-Douglas replication fails.", gtap10.objval;
);

*	Solve the GMR model with CES demand:

esub("c",r) = sum(i, thetac(i,r) * epsilon(i,r)/(thetac(i,r)-1));
loop(rr,
	loadcd(rr);
	loadrm(rr);
	gtap10.iterlim = 0;

	put_utility 'title' / ktitle 'Solve the SOE model for ',rr.tl,' with CES demand.';

$include %gams.scrdir%gtap10.gen
	solve gtap10 using mcp;
	abort$(gtap10.objval > maxdev) "SOE with Cobb-Douglas replication fails.", gtap10.objval;
);
esub("c",r) = 1;

*	Solve the SOE model with CDE demand:

loop(rr,
	loadcde(rr);
	loadrm(rr);
	gtap10.iterlim = 0;

	put_utility 'title' / ktitle 'Solve the SOE model for ',rr.tl,' with CDE demand.';

$include %gams.scrdir%gtap10.gen
	solve gtap10 using mcp;
	abort$(gtap10.objval > maxdev) "SOE with CDE replication fails.", gtap10.objval;
);

scalar	telapsed	Time elapsed;
telapsed = TimeElapsed;
display telapsed;
