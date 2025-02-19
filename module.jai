#scope_module

#import "Basic";
#import "Math";
#import "Print_Color";

gLoggerData : struct
{
	logFilters : [..] string;
}



#scope_export   	
                	


#module_parameters(	LOG_LEVEL := LogLevel.NONE,
					DISPLAY_SECTION := true,
					DISPLAY_TAGS := true,
					DISPLAY_COLORS := true)
{
	LogLevel :: enum u8
	{
		VERBOSE :: 0;
		WARNING :: 10;
		ERROR 	:: 20;
		NONE	:: U8_MAX;
	}
};



LogSection :: struct ($inName : string)
{
	logSection := Log_Section.{name = inName};
}



// Add filter section, so only the added sections are logged.
logAddFilter :: (inFilter : string)
{
	array_add(*gLoggerData.logFilters, inFilter);
}

logAddFilter :: (inFilter : LogSection)
{
	array_add(*gLoggerData.logFilters, inFilter.logSection.name);
}



// Verbose Log
logV :: (inSection : LogSection, inFormat : string, inArgs : .. Any) #expand 
{ 
	#if LOG_LEVEL <= .VERBOSE
		log(inFormat, args = inArgs, flags = .VERBOSE_ONLY, section = *inSection.logSection);
}

logV :: (inFormat : string, inArgs : .. Any) #expand
{
	#if LOG_LEVEL <= .VERBOSE
		log(inFormat, args = inArgs, flags = .VERBOSE_ONLY);
}



// Warning Log
logW :: (inSection : LogSection, inFormat : string, inArgs : .. Any) #expand 
{
	#if LOG_LEVEL <= .WARNING
		log(inFormat, args = inArgs, flags = .WARNING, section = *inSection.logSection);
}

logW :: (inFormat : string, inArgs : .. Any) #expand 
{
	#if LOG_LEVEL <= .WARNING
		log(inFormat, args = inArgs, flags = .WARNING);
}



// Error Log
logE :: (inSection : LogSection, inFormat : string, inArgs : .. Any) #expand 
{
	#if LOG_LEVEL <= .ERROR {
		log(inFormat, args = inArgs, flags = .ERROR, section = *inSection.logSection);
		print_stack_trace(context.stack_trace);
	}
}

logE :: (inFormat : string, inArgs : .. Any) #expand 
{
	#if LOG_LEVEL <= .ERROR {
		log(inFormat, args = inArgs, flags = .ERROR);
		print_stack_trace(context.stack_trace);
	}
}



// Content log
logC :: (inSection : LogSection, inFormat : string, inArgs : .. Any) #expand 
{
	#if LOG_LEVEL <= .ERROR
		log(inFormat, args = inArgs, flags = .ERROR | .CONTENT, section = *inSection.logSection);
}

logC :: (inFormat : string, inArgs : .. Any) #expand 
{
	#if LOG_LEVEL <= .ERROR
		log(inFormat, args = inArgs, flags = .ERROR | .CONTENT);
}



Logssaurus :: (inMessage : string, inData : *void, inInfo : Log_Info)
{
	path := inInfo.location.fully_pathed_filename;
	line_num := inInfo.location.line_number;

	color := Console_Color.WHITE;
	style := Console_Style.NORMAL;

	is_error : bool = xx (inInfo.common_flags & Log_Flags.ERROR);
	is_warning : bool = xx (inInfo.common_flags & Log_Flags.WARNING);

	filters := gLoggerData.logFilters;

	if (filters.count > 0) && !is_error && !is_warning {
		if (inInfo.section == null)
			return;

		found, _ := array_find(gLoggerData.logFilters, inInfo.section.name);
		if !found
			return;
	}

	#if DISPLAY_COLORS {
		if is_error
			color = Console_Color.RED;
		else if is_warning
			color = Console_Color.YELLOW;
	}

	builder : String_Builder;
	init_string_builder(*builder);

	#if DISPLAY_SECTION {
		if inInfo.section != null
			print_to_builder(*builder, "[%]", inInfo.section.name);
	}

	#if DISPLAY_TAGS {
		tag := "V";

		if inInfo.common_flags & Log_Flags.CONTENT {
			tag = "C";
		} else if is_error {
			tag = "E";
		} else if is_warning {
			tag = "W";
		}

		#if DISPLAY_SECTION {
			print_to_builder(*builder, " %", tag);
		} else {
			print_to_builder(*builder, "%", tag);
		}
	}

	#if DISPLAY_SECTION || DISPLAY_TAGS {
		append(*builder, ": %\n");
	} else {
		append(*builder, "%\n");
	}

	print_color(builder_to_string(*builder), inMessage, color = color, style = style, to_standard_error = is_error);
}

