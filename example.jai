
DEBUG :: true;



#if DEBUG
	#import,file "module.jai"(LOG_LEVEL = .VERBOSE);
else
	#import,file "module.jai";



EXAMPLE_SECTION : LogSection("Example Section");
SECOND_SECTION : LogSection("Second Section");



main :: ()
{
	context.logger = Logssaurus;

	/* 
		Uncomment so only the logs for SECOND_SECTION show up.
		Errors and Warnings always show up.
	*/
	// logAddFilter(SECOND_SECTION);

	logV(EXAMPLE_SECTION, "Example with section");
	logV("Example without section");
	logW(EXAMPLE_SECTION, "Warning example");
	logE(EXAMPLE_SECTION, "Error example");
	logV(SECOND_SECTION, "This logs in another section");
}
