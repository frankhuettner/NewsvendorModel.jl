using NewsvendorModel, Distributions
using Test, Documenter

@testset "Testing NVModel initialization" begin include("nvmodel_test.jl") end

@testset "Testing metrics" begin include("newsvendorproblem_test.jl") end

doctest(NewsvendorModel)
