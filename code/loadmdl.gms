*	Declare some macros to move between model types:

$macro loaddsys(ff,r) \
	if (sameas(ff,"les"), loadles(r); ); \
	if (sameas(ff,"cd"),  loadcd(r); ); \
	if (sameas(ff,"cde"), loadcde(r); ); 
	
$macro loadles(r)  \
	cde(r) = no; \
	cd(r) = no; \
	les(r) = yes; \
	vom("c",r) = 0; \
	vdfm(i,"sd",r) = vdfm(i,"c",r)*(1-betales(r)*eta(i,r)); \
	vifm(i,"sd",r) = vifm(i,"c",r)*(1-betales(r)*eta(i,r));  \
	vdfm(i,"dd",r) = vdfm(i,"c",r)*betales(r)*eta(i,r); \
	vifm(i,"dd",r) = vifm(i,"c",r)*betales(r)*eta(i,r);  \
$if defined cm0 cm0(lesd(g),r) = sum(i, vdfm(i,g,r)*(1+rtfd0(i,g,r)) + vifm(i,g,r)*(1+rtfi0(i,g,r))); \
$if defined cy0	cy0(lesd(g),r) = cf0(g,r) + cm0(g,r); \
	vom(lesd,r) = sum(i,vdfm(i,lesd,r)*(1+rtfd(i,lesd,r)) +  \
			    vifm(i,lesd,r)*(1+rtfi(i,lesd,r))); 

$macro	loadcde(r) \
	les(r) = no; \
	cd(r) = no; \
	cde(r) = yes; \
	vom("c",r) = 0; \
	vom(lesd,r) = 0; \
	vdfm(i,lesd,r) = 0; \
	D.L(i,r)$((not D.L(i,r)) and rm(r)*cde(r)*vcm(i,r)) = 1; \
	U.L(r)$((not U.L(r))     and rm(r)*cde(r)) = 1; \
	CC.L(r)$((not CC.L(r))   and rm(r)*cde(r)) = 1; \
	W.L(r)$((not W.L(r))     and rm(r)*cde(r)) = 1; \
	vifm(i,lesd,r) = 0; 

$macro loadcd(r)  \
	les(r) = no; \
	cd(r) = yes; \
	cde(r) = no; \
	vom(lesd,r) = 0; \
	vdfm(i,lesd,r) = 0; \
	vifm(i,lesd,r) = 0; \
	vom("c",r) = sum(i,vdfm(i,"c",r)*(1+rtfd(i,"c",r)) + vifm(i,"c",r)*(1+rtfi(i,"c",r))); 

$if defined ii_ $abort "The loadrm(r) macro requires a uniquely defined alias for i."
$if defined ss_ $abort "The loadrm(r) macro requires a uniquely defined alias for s."

alias (r,r_,rr), (j,j_),(i,ii_), (s,ss_), (f,f_);

$macro loadrm(r) \
	rm(r_) = no; \
	rm(r)  = yes; \
	loop(r_$(rm(r_) and (vom("c",r_)+vom("sd",r_)+vom("dd",r_)= \
	  smax(rm,vom("c",rm)+vom("sd",rm)+vom("dd",rm)))), rnum(r_) = yes;); \
	rx(r_) = (not rm(r_)); \
	vem(ii_,r_) = sum(rx,vxmd(ii_,r_,rx))$rm(r_) + sum(rm,vxmd(ii_,r_,rm))$rx(r_); \
	vem(ii_,r_)$(not round(vem(ii_,r_),5)) = 0; \
	rtxs_row(ii_,r_) = (sum(rx,vxmd(ii_,r_,rx)*rtxs(ii_,r_,rx))/vem(ii_,r_))$(rm(r_) and vem(ii_,r_));\
	rowpfx = sum(rx, vom("c",rx)+vom("sd",rx)+vom("dd",rx)+ \
		 sum(ii_,vcm(ii_,rx))+sum((j_,ii_,ss_),vtwr(j_,ii_,ss_,rx))) + sum(rm,vb(rm));\
	pem0(ii_,r_) = (1-rtxs_row(ii_,r_))$rm(r_);
