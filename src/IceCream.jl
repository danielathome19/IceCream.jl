module IceCream
# import Pkg; Pkg.add("Printf"); Pkg.add("Dates"); Pkg.add("Logging"); Pkg.add("Crayons")
using Printf
using Dates
using Logging
using Crayons

# Export the macro and configuration functions
export @ic, ic_configure, ic_configure_color, IC_Color

# Define default configurations using Refs for mutable global state
const DEFAULT_PREFIX = "ic| "
const ICE_CREAM_ENABLED = Ref(true)
const CONTEXT_INFO = Ref((include_context=true, include_datetime=true, include_filename=false, 
                         include_classname=true, include_absolute_path=false,
                         include_methodname=true, include_line_number=true))
const ERROR_CONTEXT_DISABLED = "includeContext needs to be enabled to set this config"
const DEFAULT_COLOR = :cyan
prefix = Ref(DEFAULT_PREFIX)
out_color = Ref(DEFAULT_COLOR)
color_output = Ref(true) # Control color output

# Configuration function to set various options
function ic_configure(; new_prefix=DEFAULT_PREFIX, enabled=true, include_context=true, 
                      include_datetime=true, include_filename=false, include_classname=true, 
                      include_absolute_path=false, include_methodname=true, 
                      include_line_number=true, color=true)
    ICE_CREAM_ENABLED[] = enabled
    CONTEXT_INFO[] = (include_context=include_context, include_datetime=include_datetime, include_filename=include_filename, 
                      include_classname=include_classname, include_absolute_path=include_absolute_path,
                      include_methodname=include_methodname, include_line_number=include_line_number)
    color_output[] = color
    if !include_context && (include_datetime || include_filename || include_classname || include_absolute_path || 
                            include_methodname || include_line_number)
    error(ERROR_CONTEXT_DISABLED)
end

prefix[] = new_prefix
end

function ic_configure_color(color)
    if typeof(color) == String
        out_color[] = Symbol(color)
    else
        out_color[] = color
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

        # Generate the expression for printing with timestamp and line number
        # Colored output is added if enabled
        return quote
            local output_str = prefix[] * ""
            local timestamp = Dates.format(Dates.now(), "yyyy-mm-dd HH:MM:SS") # Define timestamp
            # local output_str = prefix[] * "[$timestamp] " * join($var_infos, ", ") * " at line #=" * string($line_number) * "=#"
            context_info_tuple = CONTEXT_INFO[]
            # Check if include_context is true
            do_context = context_info_tuple.include_context
            for field_name in fieldnames(typeof(context_info_tuple))
                field_value = getfield(context_info_tuple, field_name)
                s_field_name = string(field_name)
                if field_value && do_context
                    if s_field_name == "include_datetime"
                        output_str *= "[$timestamp] "
                    elseif s_field_name == "include_absolute_path"
                        output_str *= "$(abspath(@__FILE__))/"
                    elseif s_field_name == "include_filename"
                        output_str *= "$(basename(@__FILE__)):"
                    elseif s_field_name == "include_classname"
                        output_str *= "$(basename(@__FILE__)):"
                    elseif s_field_name == "include_line_number"
                        output_str *= "$(string($line_number)) > "
                    elseif s_field_name == "include_methodname"
                        output_str *= "$(string(@__MODULE__)) > "
                    end
                    if !(s_field_name in ["include_context", "include_line_number", "include_methodname"])
                        output_str *= " "
                    end
                end
            end
            output_str *= join($var_infos, ", ")
            
            # Check if color output is enabled and print accordingly
            if $color_output[]
                printstyled(output_str, bold=true, color=out_color[])
            else
                println(output_str)
            end
        end
    else
        return :(nothing) # Do nothing if the feature is not enabled
    end
end

end # module