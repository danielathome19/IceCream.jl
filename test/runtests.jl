# import Pkg; Pkg.add("Test");
using Test
push!(LOAD_PATH, "../src")
include("../src/IceCream.jl")
using .IceCream


function reset_configuration()
    IceCream.ic_configure(new_prefix="ic| ", include_color=true, include_context=true,
                          include_datetime=false, include_absolute_path=false,
                          include_filename=false, include_modulename=true,
                          include_methodname=true, include_line_number=true, enabled=true, print_output=false)
    IceCream.ic_configure_color("white")
end
reset_configuration()

function concat(a, b)
    return a * b
end


@testset "Test1SimplePrintTest" begin
    reset_configuration()
    result = @ic_log("Test1SimplePrintTest")
    @test occursin("ic| Test1SimplePrintTest", result)
end

@testset "Test2WithParamsTest" begin
    reset_configuration()
    result = @ic(:Test2WithParamsTest, 1, 2, 3)
    @test occursin("Test2WithParamsTest:", result)
    @test occursin(" (\"1\", 1), (\"2\", 2), (\"3\", 3)", result)
end

@testset "Test3WithMethodAsParamTest" begin
    reset_configuration()
    result = @ic(:Test3WithMethodAsParamTest, concat("1", "2"))
    @test occursin("Test3WithMethodAsParamTest:", result)
    @test occursin(" (\"concat(\\\"1\\\", \\\"2\\\")\", \"12\")", result)
end