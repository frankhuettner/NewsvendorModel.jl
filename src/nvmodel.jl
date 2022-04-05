"""
	NVModel  <: AbstractNewsvendorProblem
Description of a newsvendor problem in its typical form. 
"""


"""
	NVModel(demand, cost, price, salvage=0)

Captures a [Newsvendor model](https://en.wikipedia.org/wiki/Newsvendor_model) 
with unit `cost`, unit selling `price`, and 
`demand` distribution. The demand can be any univariate distribution from the 
package [Distributions.jl](https://juliastats.org/Distributions.jl/latest/univariate/).
# Examples
```julia-repl
julia> using Distributions
julia> nvm = NVModel(Normal(50, 20), 5, 7)
Data of the Newsvendor Model
 * Demand distribution: Normal{Float64}(μ=50.0, σ=20.0)
 * Unit cost: 5.00
 * Unit selling price: 7.00
```
This defines a model with unit cost 5 and unit price 7, where uncertain demand 
draws from a normal distribution with mean 50 and standard deviation 20.


Optional keyword arguments and their defaults:

	NVModel(demand [; kwargs])

- `cost` for a unit; defaults to `0`
- `price` for selling a unit; defaults to `0`
- `salvage` value obtained from scraping a leftover unit; defaults to `0`
- `holding` cost obtained from a leftover unit, e.g., extra captial cost or warehousing cost; essentially a negative salvage value; defaults to `0`
- `backlog` penalty for being short a unit, e.g., contractual penalty for missing delivery targets or missed future profit of an unserved customer; defaults to `0`
- `substitute` benefit received from selling to an unserved customer, e.g., when selling another product or serving in the future; essentially a negative backlog penalty; defaults to `0`
- `fixcost` fixed cost of operations; defaults to `0`
- `q_min` minimal feasible quantity, e.g., due to production limits; must be nonnegative; defaults to `0`
- `q_max` maximal feasible quantity, e.g., due to production limits; must be greater than or equal to `q_min`; defaults to `Inf`

# Examples
Define a newsvendor problem with unit cost 5, unit price 7, uniform demand
between 50 and 80, where a unit salvages for 0.5, and backlog comes at a penalty 
of 2 per unit, and the operations incur a fixed cost of 100, as follows:
```julia-repl
julia> nvm2 = NVModel(demand = Uniform(50, 80), cost = 5, price = 7, salvage = 0.5, backlog = 2, fixcost = 100)
Data of the Newsvendor Model
 * Demand distribution: Uniform{Float64}(a=30.0, b=100.0)
 * Unit cost: 5.00
 * Unit selling price: 7.00
 * Unit salvage value: 0.50
 * Unit backlog penalty: 2.00
 * Fixed cost: 100.00
```

Note that demand is a necessary argument that can be passed
without keyword in first place. Moreover, only values that differ from the default will be shown.

Define a newsvendor problem with unit cost 5, unit price 7, uniform demand
between 30 and 100, where a unit salvages for 0.5, and backlog comes at a penalty 
of 2 per unit, and the operations incur a fixed cost of 100, as follows:
```julia-repl
julia> nvm3 = NVModel(Uniform(50, 80), 5, 7, 0.5, backlog = 2, fixcost = 100, q_min=0.0)
Data of the Newsvendor Model
 * Unit cost: 5.00
 * Unit selling price: 7.00
 * Demand distribution: Uniform{Float64}(a=30.0, b=100.0)
 * Unit salvage value: 0.50
 * Unit backlog penalty: 2.00
 * Fixed cost: 100.00
julia> nvm3 == nvm2
true
```

"""
struct NVModel <: AbstractNewsvendorProblem 
    demand::UnivariateDistribution
    cost::Real
    price::Real
    salvage::Real
    holding::Real
    backlog::Real
    substitute::Real
    fixcost::Real
    q_min::Real
    q_max::Real
    function NVModel(d, c, p, s, h, b, r, f, q_min, q_max)
        if q_min > q_max return  error("q_min > q_max not feasible") end
        if q_min < 0.0 return error("q_min must be nonnegative") end
        return new(d, c, p, s, h, b, r, f, q_min, q_max)
    end
end

# Outer constructor
function NVModel(d; cost = 0.0, price = zero(cost), salvage = zero(cost), 
    holding = zero(cost), backlog = zero(cost), substitute = zero(cost), 
    fixcost = zero(cost), q_min = 0, q_max = Inf)
    c, p, s, h, b, r, f = promote(cost, price, salvage, holding, backlog, substitute, fixcost)
    NVModel(d, c, p, s, h, b, r, f, q_min, q_max)
end
function NVModel(d, cost, price, salvage = zero(cost); 
    holding = zero(cost), backlog = zero(cost), substitute = zero(cost), 
    fixcost = zero(cost), q_min = 0, q_max = Inf)
    c, p, s, h, b, r, f = promote(cost, price, salvage, holding, backlog, substitute, fixcost)
    NVModel(d, c, p, s, h, b, r, f, q_min, q_max)
end
function NVModel(;demand, cost = 0.0, price = zero(cost), salvage = zero(cost), 
    holding = zero(cost), backlog = zero(cost), substitute = zero(cost), 
    fixcost = zero(cost), q_min = 0, q_max = Inf)
    c, p, s, h, b, r, f = promote(cost, price, salvage, holding, backlog, substitute, fixcost)
    NVModel(demand, c, p, s, h, b, r, f, q_min, q_max)
end



# Characteristic functions
underage_cost(nvm::NVModel) = nvm.price - nvm.cost + nvm.backlog - nvm.substitute
overage_cost(nvm::NVModel) = nvm.cost - nvm.salvage + nvm.holding
distr(nvm::NVModel) = nvm.demand
"At q=0, expected profit = μ × (substitute - backlog) - fixed cost"
profit_shift(nvm::NVModel) = mean(nvm.demand) * (nvm.substitute - nvm.backlog) - nvm.fixcost
q_min(nvm::NVModel) = nvm.q_min
q_max(nvm::NVModel) = nvm.q_max



function Base.show(io::IO, nvm::NVModel)
    @printf io "Data of the Newsvendor Model\n"
    @printf io " * Unit cost: %.2f\n" nvm.cost
    @printf io " * Unit selling price: %.2f\n" nvm.price
    @printf(io, " * Demand distribution: ")
    print(io, nvm.demand)
    if nvm.salvage != zero(nvm.cost)
        @printf io "\n * Unit salvage value: %.2f" nvm.salvage
    end
    if nvm.holding != zero(nvm.cost)
        @printf io "\n * Unit holding value: %.2f" nvm.holding
    end
    if nvm.backlog != zero(nvm.cost)
        @printf io "\n * Unit backlog penalty: %.2f" nvm.backlog
    end
    if nvm.substitute != zero(nvm.cost)
        @printf io "\n * Unit substitute value: %.2f" nvm.substitute
    end
    if nvm.fixcost != zero(nvm.cost)
        @printf io "\n * Fixed cost: %.2f" nvm.fixcost
    end
    if nvm.q_min != zero(nvm.cost)
        print(io, "\n * Minimal feasible quanitity: $(nvm.q_min) units")
    end
    if nvm.q_max != Inf
        print(io, "\n * Maximal feasible quanitity: $(nvm.q_max) units")
    end
    return
end




## Storage of results 

mutable struct NVResult
    nvm::NVModel
    rounded::Bool
    q_opt::Real
    profit::Real
    underage_cost::Real
    overage_cost::Real
    critical_fractile::Real
    sales::Real
    leftover::Real
    lost_sales::Real
    penalty::Real
end
"""
	nvm(res::NVResult)
Get underlying model from a stored result.
"""
nvmodel(res::NVResult) = res.nvm

"""
	rounded(res::NVResult)
Get information whether round-up rule was applied to get the stored result.
"""
rounded(res::NVResult) = res.rounded

"""
	q_opt(res::NVResult)
Get optimal quantity from a stored result.
"""
q_opt(res::NVResult) = res.q_opt

"""
	profit(res::NVResult)
Get expected profit from a stored result.
"""
profit(res::NVResult) = res.profit

"""
	underage_cost(res::NVResult)
Get cost of underage from a stored result.
"""
underage_cost(res::NVResult) = res.underage_cost

"""
	overage_cost(res::NVResult)
Get cost of overage from a stored result.
"""
overage_cost(res::NVResult) = res.overage_cost

"""
	critical_fractile(res::NVResult)
Get critical fractile from a stored result.
"""
critical_fractile(res::NVResult) = res.critical_fractile

"""
	sales(res::NVResult)
Get expected sales from a stored result.
"""
sales(res::NVResult) = res.sales

"""
	lost_sales(res::NVResult)
Get expected lost sales model from a stored result.
"""
lost_sales(res::NVResult) = res.lost_sales

"""
	leftover(res::NVResult)
Get expected leftover from a stored result.
"""
leftover(res::NVResult) = res.leftover

"""
	penalty(res::NVResult)
Get expected backlog penalty from a stored result.
"""
# penalty(res::NVResult) = res.penalty


function Base.show(io::IO, r::NVResult)
    @printf io "=====================================\n"
    @printf io "Results of maximizing expected profit\n"
    if rounded(r)
        @printf io " * Optimal quantity: %d units\n" q_opt(r)
    else
        @printf io " * Optimal quantity: %.2f\n" q_opt(r)
    end
    @printf io " * Expected profit: %.2f\n" profit(r)
    @printf io "=====================================\n"
    @printf io "This is a consequence of\n"
    @printf io " * Cost of underage: %.2f\n" underage_cost(r)
    @printf io " * Cost of overage: %.2f\n" overage_cost(r)
    @printf io " * The critical fractile: %.2f\n" critical_fractile(r)
    if 0 >= critical_fractile(r)
        @printf io " ! No benefit from trade !\n"
    end
    if 1 <= critical_fractile(r)
        @printf io " ! No damage from excess quanitiy !\n"
        if isinf(q_opt(r))
            @printf io " ! No upper bound on quanitity !\n"
        end
    else
        @printf io " * Rounded to closest integer: %s\n" rounded(r)
    end
    @printf io "-------------------------------------\n"
    @printf io "Ordering the optimal quantity yields\n"
    @printf io " * Expected sales: %.2f units\n" sales(r)
    @printf io " * Expected lost sales: %.2f units\n" lost_sales(r)
    @printf io " * Expected leftover: %.2f units\n" leftover(r)
    # if nvmodel(r).backlog != zero(nvmodel(r).cost)
    #     @printf io " * Expected backlog penalty: %.2f\n" penalty(r)
    # end
    @printf io "-------------------------------------"
    return
end


## Optimization

"""
	solve(nvm::NVModel [; rounded = true])

Compute the stocking quantity `q_opt(nvm)` that maximizes the expected profit 
as well as further the metrics when using it.
The optimal quantity is rounded up to the next integer by default. To get the 
exact real number, set the keyword arguement `rounded = false`.
"""
function solve(nvm::NVModel; rounded = true)
    q = q_opt(nvm, rounded = rounded)
    NVResult(nvm,
        rounded,
        q,
        profit(nvm, q),
        underage_cost(nvm),
        overage_cost(nvm),
        critical_fractile(nvm),
        sales(nvm, q),
        leftover(nvm, q),
        lost_sales(nvm, q),
        nvm.backlog * lost_sales(nvm, q),
    )
end