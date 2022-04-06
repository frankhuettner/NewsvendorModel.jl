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
```
```jldoctest nvm; setup = :(using Distributions, NewsvendorModel)
julia> nvm = NVModel(demand = Normal(50, 20), cost = 5, price = 7)
Data of the Newsvendor Model
 * Demand distribution: Normal{Float64}(μ=50.0, σ=20.0)
 * Unit cost: 5.00
 * Unit selling price: 7.00
```
This defines a model with unit cost 5 and unit price 7, where uncertain demand 
draws from a normal distribution with mean 50 and standard deviation 20.


Optional keyword arguments and their defaults:

	NVModel(demand [; kwargs])

- `cost` for a unit; defaults to `0.0`
- `price` for selling a unit; defaults to `0.0`
- `salvage` value obtained from scraping a leftover unit; defaults to `0.0`
- `holding` cost induced by a leftover unit, e.g., extra captial cost or warehousing cost; essentially a negative salvage value; defaults to `0.0`
- `backorder` penalty for being short a unit, e.g., contractual penalty for missing delivery targets or missed future profit of an unserved customer; defaults to `0.0`
- `substitute` benefit received from selling an alternative to an unserved customer, e.g., when selling another product or serving in the future; essentially a negative backorder penalty; defaults to `0.0`
- `fixcost` fixed cost of operations; defaults to `0.0`
- `q_min` minimal feasible quantity, e.g., due to production limits; must be nonnegative; defaults to `0`
- `q_max` maximal feasible quantity, e.g., due to production limits; must be greater than or equal to `q_min`; defaults to `Inf`

# Examples
Define a newsvendor problem with unit cost 5, unit price 7, uniform demand
between 50 and 80, where a unit salvages for 0.5, and backorder comes at a penalty 
of 2 per unit, and the operations incur a fixed cost of 100, as follows:
```jldoctest nvm
julia> nvm2 = NVModel(demand = Uniform(50, 80), cost = 5, price = 7, salvage = 0.5, backorder = 2, fixcost = 100)
Data of the Newsvendor Model
 * Demand distribution: Uniform{Float64}(a=50.0, b=80.0)
 * Unit cost: 5.00
 * Unit selling price: 7.00
 * Unit salvage value: 0.50
 * Unit backorder penalty: 2.00
 * Fixed cost: 100.00
```

Note that demand is a necessary argument that can be passed
without keyword in first place. Moreover, only values that differ from the default will be shown.

Define a newsvendor problem with unit cost 5, unit price 7, uniform demand
between 50 and 80, where a unit salvages for 0.5, and backorder comes at a penalty 
of 2 per unit, and the operations incur a fixed cost of 100, as follows:
```jldoctest nvm
julia> nvm3 = NVModel(Uniform(50, 80), 5, 7, 0.5, backorder = 2, fixcost = 100, q_min=0)
Data of the Newsvendor Model
 * Demand distribution: Uniform{Float64}(a=50.0, b=80.0)
 * Unit cost: 5.00
 * Unit selling price: 7.00
 * Unit salvage value: 0.50
 * Unit backorder penalty: 2.00
 * Fixed cost: 100.00
julia> nvm3 == nvm2
true
```

Holding cost is essentially overage cost.
Backorder penalty is essentially underage cost.
The beer game has holding cost of 0.5 USD and backlog costs 1 USD per unit. 
Demand is assumed to be uniform betwen 0 and 300. 
```jldoctest nvm
julia> beer = NVModel(Uniform(0, 300), backorder = 1, holding = 0.5)
Data of the Newsvendor Model
 * Demand distribution: Uniform{Float64}(a=0.0, b=300.0)
 * Unit cost: 0.00
 * Unit selling price: 0.00
 * Unit holding cost: 0.50
 * Unit backorder penalty: 1.00
```

"""
struct NVModel <: AbstractNewsvendorProblem 
    demand::UnivariateDistribution
    cost::Real
    price::Real
    salvage::Real
    holding::Real
    backorder::Real
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
    holding = zero(cost), backorder = zero(cost), substitute = zero(cost), 
    fixcost = zero(cost), q_min = 0, q_max = Inf)
    c, p, s, h, b, r, f = promote(cost, price, salvage, holding, backorder, substitute, fixcost)
    NVModel(d, c, p, s, h, b, r, f, q_min, q_max)
end
function NVModel(d, cost, price, salvage = zero(cost); 
    holding = zero(cost), backorder = zero(cost), substitute = zero(cost), 
    fixcost = zero(cost), q_min = 0, q_max = Inf)
    c, p, s, h, b, r, f = promote(cost, price, salvage, holding, backorder, substitute, fixcost)
    NVModel(d, c, p, s, h, b, r, f, q_min, q_max)
end
function NVModel(;demand, cost = 0.0, price = zero(cost), salvage = zero(cost), 
    holding = zero(cost), backorder = zero(cost), substitute = zero(cost), 
    fixcost = zero(cost), q_min = 0, q_max = Inf)
    c, p, s, h, b, r, f = promote(cost, price, salvage, holding, backorder, substitute, fixcost)
    NVModel(demand, c, p, s, h, b, r, f, q_min, q_max)
end



# Characteristic functions
underage_cost(nvm::NVModel) = nvm.price - nvm.cost + nvm.backorder - nvm.substitute
overage_cost(nvm::NVModel) = nvm.cost - nvm.salvage + nvm.holding
distr(nvm::NVModel) = nvm.demand
"At q=0, expected profit = μ × (substitute - backorder) - fixed cost"
profit_shift(nvm::NVModel) = ( mean(nvm.demand) * (nvm.substitute - nvm.backorder) 
                              - nvm.fixcost )
q_min(nvm::NVModel) = nvm.q_min
q_max(nvm::NVModel) = nvm.q_max



function Base.show(io::IO, nvm::NVModel)
    @printf io "Data of the Newsvendor Model\n"
    @printf io " * Demand distribution: "
    println(io, nvm.demand)
    @printf io " * Unit cost: %.2f\n" nvm.cost
    @printf io " * Unit selling price: %.2f" nvm.price
    if nvm.salvage != zero(nvm.cost)
        @printf io "\n * Unit salvage value: %.2f" nvm.salvage
    end
    if nvm.holding != zero(nvm.cost)
        @printf io "\n * Unit holding cost: %.2f" nvm.holding
    end
    if nvm.backorder != zero(nvm.cost)
        @printf io "\n * Unit backorder penalty: %.2f" nvm.backorder
    end
    if nvm.substitute != zero(nvm.cost)
        @printf io "\n * Unit substitute profit: %.2f" nvm.substitute
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
    @printf io "\n"
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
    salvage_revenue::Real
    holding_cost::Real
    backorder_penalty::Real
    substitute_profit::Real
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
    salvage_revenue(res::NVResult)
Get expected salvage revenue from a stored result.
"""
salvage_revenue(res::NVResult) = res.salvage_revenue

"""
    holding_cost(res::NVResult)
Get expected holding cost from a stored result.
"""
holding_cost(res::NVResult) = res.holding_cost

"""
	backorder_penalty(res::NVResult)
Get expected backorder penalty from a stored result.
"""
backorder_penalty(res::NVResult) = res.backorder_penalty

"""
    substitute_profit(res::NVResult)
Get expected substitute profit from a stored result.
"""
substitute_profit(res::NVResult) = res.substitute_profit


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
    @printf io " * Cost of underage:  %.2f\n" underage_cost(r)
    if nvmodel(r).price != zero(nvmodel(r).cost)
        @printf io "   ╚ + Price:               %.2f\n" nvmodel(r).price
    end
    if nvmodel(r).cost != zero(nvmodel(r).cost)
        @printf io "   ╚ - Cost:                %.2f\n" nvmodel(r).cost
    end
    if nvmodel(r).backorder != zero(nvmodel(r).cost)
        @printf io "   ╚ + Backorder penalty:   %.2f\n" nvmodel(r).backorder
    end
    if nvmodel(r).substitute != zero(nvmodel(r).cost)
        @printf io "   ╚ - Substitute profit:   %.2f\n" nvmodel(r).substitute
    end
    @printf io " * Cost of overage:   %.2f\n" overage_cost(r)
    if nvmodel(r).cost != zero(nvmodel(r).cost)
        @printf io "   ╚ + Cost:                %.2f\n" nvmodel(r).cost
    end
    if nvmodel(r).salvage != zero(nvmodel(r).cost)
        @printf io "   ╚ - Salvage value:       %.2f\n" nvmodel(r).salvage
    end
    if nvmodel(r).holding != zero(nvmodel(r).cost)
        @printf io "   ╚ + Holding cost:        %.2f\n" nvmodel(r).holding
    end
    @printf io " * Critical fractile: %.2f\n" critical_fractile(r)
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
    if nvmodel(r).salvage != zero(nvmodel(r).cost)
        @printf io " * Expected salvage revenue: %.2f\n" salvage_revenue(r)
    end
    if nvmodel(r).backorder != zero(nvmodel(r).cost)
        @printf io " * Expected backorder penalty: %.2f\n" backorder_penalty(r)
    end
    if nvmodel(r).holding != zero(nvmodel(r).cost)
        @printf io " * Expected holding cost: %.2f\n" holding_cost(r)
    end
    if nvmodel(r).substitute != zero(nvmodel(r).cost)
        @printf io " * Expected substitute profit: %.2f\n" substitute_profit(r)
    end
    @printf io "-------------------------------------\n"
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
    salvage_revenue = nvm.salvage * leftover(nvm, q)
    holding_cost = nvm.holding * leftover(nvm, q)
    backorder_penalty = nvm.backorder * lost_sales(nvm, q)
    substitute_profit = nvm.substitute * lost_sales(nvm, q)

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
        salvage_revenue,
        holding_cost,
        backorder_penalty,
        substitute_profit,
    )
end