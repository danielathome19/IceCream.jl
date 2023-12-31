module IceCream
# import Pkg; Pkg.add("Printf"); Pkg.add("Dates"); Pkg.add("Logging"); Pkg.add("Crayons")
using Printf
using Dates
using Logging
using Crayons

# Export the macro and configuration functions
export @ic, @ic_log, ic_configure, ic_configure_color, ic_configure_single, ic_enable, ic_disable, Configs

# Define default configurations using Refs for mutable global state
const DEFAULT_PREFIX = "ic| "
const ICE_CREAM_ENABLED = Ref(true)
const CONTEXT_INFO = Ref((include_context=true, include_datetime=true, include_absolute_path=false,
                         include_filename=false, include_modulename=true,
                         include_methodname=true, include_line_number=true, print_output=true))
const ERROR_CONTEXT_DISABLED = "includeContext needs to be enabled to set this config"
const DEFAULT_COLOR = :cyan
prefix = Ref(DEFAULT_PREFIX)
out_color = Ref(DEFAULT_COLOR)
color_output = Ref(true) # Control color output

# Configuration function to set various options
function ic_configure(; new_prefix=DEFAULT_PREFIX, enabled=true, include_context=true, 
                      include_datetime=false, include_absolute_path=false, include_filename=true,
                      include_modulename=true, include_methodname=true, 
                      include_line_number=true, include_color=true, print_output=true)
    ICE_CREAM_ENABLED[] = enabled
    CONTEXT_INFO[] = (include_context=include_context, include_datetime=include_datetime, include_absolute_path=include_absolute_path,
                      include_filename=include_filename, include_modulename=include_modulename, 
                      include_methodname=include_methodname, include_line_number=include_line_number, print_output=print_output)
    color_output[] = include_color
    if !include_context && (include_datetime || include_filename || include_modulename || include_absolute_path || 
                            include_methodname || include_line_number)
    error(ERROR_CONTEXT_DISABLED)
end

prefix[] = new_prefix
end

@enum Configs include_context include_datetime include_absolute_path include_filename include_modulename include_methodname include_line_number include_color new_prefix enabled

function ic_enable()
    ICE_CREAM_ENABLED[] = true
end

function ic_disable()
    ICE_CREAM_ENABLED[] = false
end

# Configuration function to set various options using enum
function ic_configure_single(config::Configs, value)
    current_context = CONTEXT_INFO[]
    for field_name in fieldnames(typeof(current_context))
        if string(field_name) == string(config)
            new_context = []
            for field_name in fieldnames(typeof(current_context))
                if string(field_name) == string(config)
                    push!(new_context, value)
                else
                    push!(new_context, getfield(current_context, field_name))
                end
            end
            # TODO: Turn new_context into a Ref((...)) object
            CONTEXT_INFO[] = new_context
            break
        end
    end
end

function ic_configure_color(color)
    if typeof(color) == String
        out_color[] = Symbol(color)
    else
        out_color[] = color
    end
end

# Macro to print (colored) text with a prefix
macro ic_log(text, colored=true)
    if ICE_CREAM_ENABLED[]
        output = prefix[] * text
        if CONTEXT_INFO[].print_output
            if colored
                printstyled(output, bold=true, color=out_color[])
                println()
            else
                println(output)
            end
        end
        return output
    else
        return :(nothing)
    end
end

# Macro to capture and print variable names and their values
macro ic(exprs...)
    # Only proceed if ICE_CREAM_ENABLED is true
    if ICE_CREAM_ENABLED[] # Checking if the debugging is enabled
        var_infos = Expr(:vect) # Container for variable information tuples
        for expr in exprs
            var_str = string(expr) # The variable name as a string
            var_value = esc(expr)  # Capture the expression to be evaluated
            push!(var_infos.args, Expr(:tuple, var_str, var_value)) # Push the tuple to var_infos
        end

        # The line number where the macro is called
        line_number = __source__.line
        # Have to manually pass in the function name in Julia; original callers do not appear in the stacktrace
        method_name = ""  # TODO: find a workaround or create an issue on JuliaLang
        class_name = ""
        try
            class_name = replace(string(@__MODULE__), ".IceCream" => "")
        catch
        end
        file_name_without_path = basename(string(__source__.file))
        absolute_path = abspath(string(__source__.file))
        
        # Generate the expression for printing with timestamp and line number
        # Colored output is added if enabled
        return quote
            local output_str = prefix[] * ""
            local timestamp = Dates.format(Dates.now(), "yyyy-mm-dd HH:MM:SS")
            context_info_tuple = CONTEXT_INFO[]
            do_context = context_info_tuple.include_context
            do_abs_path = context_info_tuple.include_absolute_path
            for field_name in fieldnames(typeof(context_info_tuple))
                field_value = getfield(context_info_tuple, field_name)
                s_field_name = string(field_name)
                if field_value && do_context
                    if s_field_name == "include_datetime"
                        output_str *= "[$timestamp] "
                    elseif s_field_name == "include_absolute_path"
                        output_str *= "$(string($absolute_path)):"
                    elseif s_field_name == "include_filename" && !do_abs_path
                        output_str *= "$(string($file_name_without_path)):"
                    elseif s_field_name == "include_modulename" && length($class_name) > 0
                        output_str *= "$(string($class_name)):"
                    elseif s_field_name == "include_line_number"
                        output_str *= "$(string($line_number)) > "
                    elseif s_field_name == "include_methodname" && length($method_name) > 0
                        output_str *= "$(string($method_name)):"
                    end
                end
            end
            # Check if first item of var_infos is a symbol; if so, it is the function name and should be printed with a colon
            if typeof($var_infos[1][2]) == Symbol
                output_str *= "$(string($var_infos[1][2])): "
                output_str *= join($var_infos[2:end], ", ")
            else
                output_str *= join($var_infos, ", ")
            end
            
            # Check if color output is enabled and print accordingly
            if context_info_tuple.print_output
                if $color_output[]
                    printstyled(output_str, bold=true, color=out_color[])
                    println()
                else
                    println(output_str)
                end
            else
                output_str
            end
        end
    else
        return :(nothing) # Do nothing if the feature is not enabled
    end
end

end # module