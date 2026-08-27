$title	GAMS Command Script to Build GTAP 12

$if not set aggr	$setglobal aggr	gtap12ingams

*	File separator: "\" for Windows --  "/" for Unix/OSX

$set fs %system.dirsep%

*	Point to the code directory:

$set code ..%fs%code%fs%

*	Set number of decimals for filtering:

$set nd 5

*	Set the base year:

$set yr 23

$goto %aggr%

$label gtap12ingams
$set ds gtap12ingams
$call gams %code%gtapaggr --yr=%yr% --source=gsd_%nd%  --target=%ds% o=listings%fs%%ds%_%yr%.lst
$call gams %code%cdecalib --yr=%yr% --ds=%ds%  o=listings%fs%cde_%ds%_%yr%.lst
$log	Finished with gtapingams.
$exit

*	Aggregate and calibrate CDE demand for the G20_MACRO dataset:

$label g20_macro
$set ds g20_macro
$call gams %code%gtapaggr --yr=%yr% --source=gtap12ingams  --target=%ds%  o=listings%fs%%ds%_%yr%.lst
$call gams %code%cdecalib --yr=%yr% --ds=%ds%  o=listings%fs%cde_%ds%_%yr%.lst
$log	Finished with g20_macro.
$exit

*	Aggregate and calibrate CDE demand for the G20_IEA dataset:

$label g20_iea
$set ds g20_iea
$call gams %code%gtapaggr --yr=%yr% --source=gtap12ingams  --target=%ds%  o=listings%fs%%ds%_%yr%.lst
$call gams %code%cdecalib --yr=%yr% --ds=%ds%  o=listings%fs%cde_%ds%_%yr%.lst
$log	Finished with g20_iea
$exit

*	Aggregate and calibrate CDE demand for the G20 dataset:

$label g20
$set ds g20
$call gams %code%gtapaggr --yr=%yr% --source=gtap12ingams  --target=%ds%  o=listings%fs%%ds%_%yr%.lst
$call gams %code%cdecalib --yr=%yr% --ds=%ds%  o=listings%fs%cde_%ds%_%yr%.lst
$log	Finished with g20
$exit
