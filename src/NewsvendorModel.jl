__precompile__()
module NewsvendorModel

using Distributions
using QuadGK
using Printf

import Base: show


# export my_round
export AbstractNewsvendorProblem, underage_cost, overage_cost, profit_shift, 
distr, q_opt, q_scarf, lost_sales, sales, leftover, profit, mismatch_cost, 
solve, penalty, critical_fractile, q_max, q_min
export NVModel, rounded, nvmodel

"""
An abstract newsvendor problem is essentially described by having a
  - demand distribution,
  - cost of overage, 
  - cost of underage, and 
  - profit_shift term.
Its standard concrete type might come as a NewsvendorModel, defined by
unit cost, uni selling price etc.
"""
abstract type AbstractNewsvendorProblem end

include("./newsvendorproblem.jl")
include("./leftover.jl")
include("./nvmodel.jl")


end # module