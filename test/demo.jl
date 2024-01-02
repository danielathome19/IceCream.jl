push!(LOAD_PATH, "../src")
include("../src/IceCream.jl")
using .IceCream  # Load the IceCream module

# Configure the ice cream output with new settings
IceCream.ic_configure(new_prefix="🍦 >", include_color=true)
IceCream.ic_configure_color("red")

# Example usage
x = 3
y = "hello"
IceCream.ic_disable()
println(@ic x y)
IceCream.ic_enable()
@ic x y

function test()
    IceCream.ic_configure_color("green")
    IceCream.ic_configure_single(IceCream.include_datetime, true)
    @ic :test x y  # Have to manually pass the function name as a symbol
    IceCream.ic_configure_single(IceCream.include_datetime, false)
end

IceCream.ic_configure(include_context=true, include_datetime=false, include_filename=true, 
                      include_modulename=false, include_absolute_path=false,
                      include_methodname=true, include_line_number=true)
test()
IceCream.ic_configure_color("blue")
@ic y "world" [1, 2, 3]

@ic_log "This is a log message"
@ic_log "This is a plain log message" false

# Class test
module TestModule
    push!(LOAD_PATH, "../src")
    include("../src/IceCream.jl")
    using .IceCream
    struct TestStruct
        x
        y
    end
    function TestStruct(x, y)
        @ic TestStruct x y
    end
    function test()
        IceCream.ic_configure(include_context=true, include_datetime=false, include_filename=true, 
                      include_modulename=true, include_absolute_path=false,
                      include_methodname=true, include_line_number=true)
        @ic TestStruct(1, 2)
    end
end

TestModule.test()