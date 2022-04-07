# using NewsvendorModel
# # using NewsvendorModel
# using Distributions
# using Test


@testset "Testing metrics" begin include("metrics_nvm_test.jl") end
@testset "Testing Simdata" begin include("simdata_test.jl") end
@testset "Testing metrics" begin include("metrics_sd_test.jl") end
@testset "Testing Simdata" begin include("visualize_test.jl") end

