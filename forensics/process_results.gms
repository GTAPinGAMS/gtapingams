$title	Write pgfplots .data Files from figresults in results.gdx

*	Run from the forensics directory:   gams process_results
*
*	figresults(d1,...,d7) is read from results.gdx, where
*	   d1  dataset            (e.g. g20_macro)
*	   d2  data/parameter variant (e.g. gtap, gtapingams)
*	   d3  model closure      (gmr, soe, sate, ...)
*	   d4  region             (ARG, CHN, ...)
*	   d5  demand system      (cd, les, cde)
*	   d6  tariff level       (0*10)
*	   d7  item               (sectors and welfare W)
*
*	For every (d1,d4,d7) a file  <d1>_<d4>_<d7>.data  is written with one
*	row per tariff level d6 and one column per d2-d3 combination.  If
*	results.gdx holds more than one demand system, the column labels are
*	d2-d3-d5 instead.  Only runs present in results.gdx get a column; tariff
*	levels missing from a run (e.g. a failed solve) are written as nan, which
*	pgfplots skips.  Exact zeros (not stored in GDX) are written as 0.

$if not set gdx    $set gdx    results.gdx
$if not set outdir $set outdir figures
$if not set ds 	   $set ds     g20_macro

set	d1	Data set ds,
	d2	gtap or gtapingams,
	d3	Trade closure,
	d4	Country,
	d5	Demand system (CD only),
	d6	Tariff level,
	d7	Sector (includes W for welfare);

parameter	figresults(d1<,d2<,d3<,d4<,d5<,d6<,d7<)	Simulation results for plotting;
$gdxin %gdx%
$load figresults
$gdxin

*	Which runs exist (a run may contain exact zeros, which GDX does not store):

set	run(d1,d2,d3,d4,d5)	Runs present in results.gdx,
	outft(d1,d4,d7)		Files to be written (with tariff levels),
	outfs(d1,d4,d2)		Files to be written (with sectors),
	done(d1,d2,d3,d4,d5,d6)	Tariff levels solved in a run;

set pltsec(d7)	subset of sectors to plot
    		/
* First a selection for G20
* (includes 5 most tariffed and 2 most revenue generating for USA, CHN, ZAF, ARG)
$ifthen %ds% == g20
		 sgr, lea, mil, wap, tex, wht, gro, wol, pfb,
		 omf, omt, col, mvh, ome, chm
$endif
* Then all for g20_macro
$ifthen %ds% == g20_macro
		 agr, mfr, ser, enr
$endif
		/;

run(d1,d2,d3,d4,d5) = yes$sum((d6,d7)$figresults(d1,d2,d3,d4,d5,d6,d7), 1);
outft(d1,d4,d7)      = yes$sum((d2,d3,d5,d6)$figresults(d1,d2,d3,d4,d5,d6,d7), 1);
outfs(d1,d4,d2)	= yes$sum((d7,d3)$pltsec(d7), 1$figresults(d1,d2,d3,d4,"cd","10",d7));
done(d1,d2,d3,d4,d5,d6) = yes$sum(d7$figresults(d1,d2,d3,d4,d5,d6,d7), 1);

scalar	multidsys	Include demand system in the column labels;
multidsys = 1$(card(d5) > 1);

option outft:0:0:1;
display outft;

scalar	col	Column counter,
	cw	Column width /20/;

file kdat; kdat.nd = 6; kdat.nw = 19; kdat.nj = 2; kdat.lw = 0; kdat.pw = 32767;
put kdat;

*	Data files for plotting results against tariff levels:
loop(outft(d1,d4,d7),
	put_utility 'ren' / '%outdir%%system.dirsep%' d1.tl:0 '_' d4.tl:0 '_' d7.tl:0 '.data';

*	Header:
	put 'tlvl';
	col = 1;
	loop((d2,d3,d5)$run(d1,d2,d3,d4,d5),
	  put @(1+col*cw) d2.tl:0 '-' d3.tl:0;
	  if(multidsys, put '-' d5.tl:0;);
	  col = col + 1;
	);
	put /;

*	One row per tariff level:
	loop(d6,
	  put d6.tl:0;
	  col = 1;
	  loop((d2,d3,d5)$run(d1,d2,d3,d4,d5),
	    put @(1+col*cw);
	    if(not done(d1,d2,d3,d4,d5,d6),
	       put 'nan':19;
	    else
	       put figresults(d1,d2,d3,d4,d5,d6,d7):19:6;
	    );
	    col = col + 1;
	  );
	  put /;
	);
	putclose;
);

*	Data files for plotting results across sectors
loop(outfs(d1,d4,d2),
	put_utility 'ren' / '%outdir%%system.dirsep%' d1.tl:0 '_' d4.tl:0 '_' d2.tl:0 '.data';

*	Header:
	put 'sector';
	col = 1;
	loop((d3),
	  put @(1+col*cw) d3.tl:0;
	  col = col + 1;
	);
	put /;

*	One row per tariff level:
	loop(d7$pltsec(d7),
	  put d7.tl:0;
	  col = 1;
	  loop((d3)$run(d1,d2,d3,d4,"cd"),
	    put @(1+col*cw);
	    if(not done(d1,d2,d3,d4,"cd","10"),
	       put 'nan':19;
	    else
	       put figresults(d1,d2,d3,d4,"cd","10",d7):19:6;
	    );
	    col = col + 1;
	  );
	  put /;
	);
	putclose;
);
