push!(LOAD_PATH, "../src")
include("../src/IceCream.jl")
using .IceCream  # Load the IceCream module

# Configure the ice cream output with new settings
IceCream.ic_configure(new_prefix="🍦 >", color=true)

# Example usage
x = 3
y = "hello"
@ic x y