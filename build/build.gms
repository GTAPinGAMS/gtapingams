$title	GAMS Command Script to Build GTAP 9

*	File separator: "\" for Windows --  "/" for Unix/OSX

$set fs %system.dirsep% 

*	Point to the code directory:

$set code ..%fs%code%fs%

*	Set number of decimals for filtering:

$set nd 5

*	Set the base year:

$set yr 11

*	Translate the .HAR file into a GTAPinGAMS GDX file:

$call gams %code%flex2gdx --yr=%yr% o=listings%fs%flex2gdx_%yr%.lst
$log	Finished with flex2gdx.
$if not %sys.filesys%==UNIX $call pause

*	Filter small values:

$call gams %code%filter --yr=%yr% --nd=%nd%  o=listings%fs%filter%yr%_%nd%.lst
$log	Finished with filter.
$if not %sys.filesys%==UNIX $call pause

*	Aggregate (relabel) and calibrate CDE demand for the GTAPinGAMS dataset:

$set ds gtapingams
$call gams %code%gtapaggr --yr=%yr% --source=gsd_%nd%  --target=%ds% o=listings%fs%%ds%_%yr%.lst
$call gams %code%cdecalib --yr=%yr% --ds=%ds%  o=listings%fs%cde_%ds%_%yr%.lst
$log	Finished with gtapingams.
$if not %sys.filesys%==UNIX $call pause

*	Aggregate and calibrate CDE demand for the G20_MACRO dataset:

$label g20_macro
$set ds g20_macro
$call gams %code%gtapaggr --yr=%yr% --source=gtapingams  --target=%ds%  o=listings%fs%%ds%_%yr%.lst
$call gams %code%cdecalib --yr=%yr% --ds=%ds%  o=listings%fs%cde_%ds%_%yr%.lst
$log	Finished with g20_macro.
$if not %sys.filesys%==UNIX $call pause

*	Aggregate and calibrate CDE demand for the G20_IEA dataset:

$label g20_iea
$set ds g20_iea
$call gams %code%gtapaggr --yr=%yr% --source=gtapingams  --target=%ds%  o=listings%fs%%ds%_%yr%.lst
$call gams %code%cdecalib --yr=%yr% --ds=%ds%  o=listings%fs%cde_%ds%_%yr%.lst
$log	Finished with g20_iea
$if not %sys.filesys%==UNIX $call pause

*	Aggregate and calibrate CDE demand for the G20 dataset:

$label g20
$set ds g20
$call gams %code%gtapaggr --yr=%yr% --source=gtapingams  --target=%ds%  o=listings%fs%%ds%_%yr%.lst
$call gams %code%cdecalib --yr=%yr% --ds=%ds%  o=listings%fs%cde_%ds%_%yr%.lst
$log	Finished with g20

