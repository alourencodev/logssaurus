
DEBUG :: true;



#if DEBUG
	#import,file "module.jai"(LOG_LEVEL = .VERBOSE);
else
	#import,file "module.jai";



EXAMPLE_SECTION : LogSection("Example Section");



main :: ()
{
	context.logger = Logssaurus;

	logV(EXAMPLE_SECTION, "Example with section");
	logV("Example without section");
	logW(EXAMPLE_SECTION, "Warning example");
	logE(EXAMPLE_SECTION, "Error example");
}
