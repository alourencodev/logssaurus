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
		DEBUG	:: 1;
		WARNING :: 2;
		ERROR 	:: 3;
		NONE	:: 4;
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
		log(inFormat, args = ..inArgs, flags = .VERY_VERBOSE_ONLY, section = *inSection.logSection);
}

logV :: (inFormat : string, inArgs : .. Any) #expand
{
	#if LOG_LEVEL <= .VERBOSE
		log(inFormat, args = ..inArgs, flags = .VERY_VERBOSE_ONLY);
}



// Debug Log
logD :: (inSection : LogSection, inFormat : string, inArgs : .. Any) #expand 
{ 
	#if LOG_LEVEL <= .DEBUG
		log(inFormat, args = ..inArgs, flags = .VERBOSE_ONLY, section = *inSection.logSection);
}

logD :: (inFormat : string, inArgs : .. Any) #expand
{
	#if LOG_LEVEL <= .DEBUG
		log(inFormat, args = ..inArgs, flags = .VERBOSE_ONLY);
}



// Warning Log
logW :: (inSection : LogSection, inFormat : string, inArgs : .. Any) #expand 
{
	#if LOG_LEVEL <= .WARNING
		log(inFormat, args = ..inArgs, flags = .WARNING, section = *inSection.logSection);
}

logW :: (inFormat : string, inArgs : .. Any) #expand 
{
	#if LOG_LEVEL <= .WARNING
		log(inFormat, args = ..inArgs, flags = .WARNING);
}



// Error Log
logE :: (inSection : LogSection, inFormat : string, inArgs : .. Any) #expand 
{
	#if LOG_LEVEL <= .ERROR {
		log(inFormat, args = ..inArgs, flags = .ERROR, section = *inSection.logSection);
		print_stack_trace(context.stack_trace);
	}
}

logE :: (inFormat : string, inArgs : .. Any) #expand 
{
	#if LOG_LEVEL <= .ERROR {
		log(inFormat, args = ..inArgs, flags = .ERROR);
		print_stack_trace(context.stack_trace);
	}
}



// Content log
logC :: (inSection : LogSection, inFormat : string, inArgs : .. Any) #expand 
{
	#if LOG_LEVEL <= .ERROR
		log(inFormat, args = ..inArgs, flags = .ERROR | .CONTENT, section = *inSection.logSection);
}

logC :: (inFormat : string, inArgs : .. Any) #expand 
{
	#if LOG_LEVEL <= .ERROR
		log(inFormat, args = ..inArgs, flags = .ERROR | .CONTENT);
}



Logssaurus :: (inMessage : string, inData : *void, inInfo : Log_Info)
{
	path := inInfo.location.fully_pathed_filename;
	line_num := inInfo.location.line_number;

	color := Console_Color.WHITE;
	style := Console_Style.NORMAL;

	is_verbose : bool = xx (inInfo.common_flags & Log_Flags.VERY_VERBOSE_ONLY);
	is_debug : bool = xx (inInfo.common_flags & Log_Flags.VERBOSE_ONLY);
	is_content : bool = xx (inInfo.common_flags & Log_Flags.CONTENT);
	is_error : bool = xx (inInfo.common_flags & Log_Flags.ERROR);
	is_warning : bool = xx (inInfo.common_flags & Log_Flags.WARNING);

	filters := gLoggerData.logFilters;

	if !is_error && !is_warning {
		if is_verbose || (filters.count > 0) {
			if (inInfo.section == null)
				return;

			found, _ := array_find(gLoggerData.logFilters, inInfo.section.name);
			if !found
				return;
		}
	}

	#if DISPLAY_COLORS {
		if is_debug {
			color = Console_Color.HI_WHITE;
		}
		else if is_content {
			color = Console_Color.CYAN;
		}
		else if is_error {
			color = Console_Color.RED;
			style = Console_Style.BOLD;
		}
		else if is_warning {
			color = Console_Color.YELLOW;
			style = Console_Style.BOLD;
		}
	}

	builder : String_Builder;
	init_string_builder(*builder);

	#if DISPLAY_SECTION {
		if inInfo.section != null
			print_to_builder(*builder, "[%]", inInfo.section.name);
	}

	#if DISPLAY_TAGS {
		tag := "V";

		if is_debug {
			tag = "D";
		} else if is_content {
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

