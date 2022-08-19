
## Primitives: Functions to be implemented for a newsvendor problems

"""
    underage_cost(anp::AbstractNewsvendorProblem)	

Get the cost of underage of a newsvendor problem.
"""
underage_cost(anp::AbstractNewsvendorProblem) = error("Underage cost is not
 defined in the concrete type")



"""
    overage_cost(anp::AbstractNewsvendorProblem)	

Get the cost of overage of a newsvendor problem.
"""
overage_cost(anp::AbstractNewsvendorProblem) = error("Overage cost is not defined 
in the concrete type")


"""
	distr(anp::AbstractNewsvendorProblem)	

Get the demand distribution of a newsvendor problem.
"""
distr(anp::AbstractNewsvendorProblem) = error("Demand distribution is not 
defined in the concrete type")
##


## Optional primitive

"""
profit_shift(anp::AbstractNewsvendorProblem)	

Define how profit is shifted because of fixed cost, penalty, etc.;
defautls to 0.0.
"""
profit_shift(anp::AbstractNewsvendorProblem) = zero(underage_cost(anp))

"""
	q_min(anp::AbstractNewsvendorProblem)	

Define minimal feasible quanitity, e.g., due to contractual limitations;
defautls to 0.0.
"""
q_min(anp::AbstractNewsvendorProblem) = zero(underage_cost(anp))

"""
	q_max(anp::AbstractNewsvendorProblem)	

Define maximal feasible quanitity, e.g., due to contractual limitations;
defautls to `Inf`.
"""
q_max(anp::AbstractNewsvendorProblem) = Inf
##



## Maximizing order quanitity

"""
	critical_fractile(anp::AbstractNewsvendorProblem)	

Compute the critical fractile for a newsvendor problem:
```math
\\textrm{critical fractile} = \\frac{\\textrm{underage cost}}{\\textrm{underage cost} + \\textrm{overage cost}}
```
"""
function critical_fractile(anp::AbstractNewsvendorProblem)
    underage_cost(anp) / (underage_cost(anp) + overage_cost(anp))
end



"""
	q_opt(anp::AbstractNewsvendorProblem; rounded = true)	

Compute the quanitity that maximizes expected profit for a newsvendor problem
(i.e., where critical fractile equals in-stock probability). Attempts to solve 
```math
F(q_{opt}) = \\textrm{critical fractile} 
```  
where F is the c.d.f. of the demand distribution.
Returns closest next integer unless `rounded=false`; then, it returns exact real.
Clamps at q_min and q_max.
"""
function q_opt(anp::AbstractNewsvendorProblem; rounded = true)
    CF = critical_fractile(anp)
    if CF <= zero(CF)
        return q_min(anp)
    end

    if CF >= one(CF)
        return min(maximum(distr(anp)), q_max(anp))
    end

    q = clamp(quantile(distr(anp), CF), q_min(anp), q_max(anp))
    
    if rounded == false  return q end

    q = round(Int, q)

    if q_min(anp) < q < q_max(anp)
        return q
    else
        return clamp(q, q_min(anp), q_max(anp))
    end

end


@doc raw"""
	q_scarf(anp::AbstractNewsvendorProblem)	

Compute the quanitity that maximizes the minimal expected profit among all 
distributions with the same mean and variance. Worst-case solution (Scarf, 1958)
```math
q_{scarf} = \mu + \sigma/2 * (\sqrt{r} - \sqrt{1/r})
```  
where
```math
r = \frac{\textrm{underage cost}}{ \textrm{overage cost}}
```  
"""
function q_scarf(anp::AbstractNewsvendorProblem)
    μ = mean(distr(anp))
    σ = std(distr(anp))
    r = underage_cost(anp) / overage_cost(anp)
    return μ + σ / 2 * (√r - √(1 / r))
end

##


## Metrics: Expected values depending on order quanitity

@doc raw"""
	leftover(anp::AbstractNewsvendorProblem, q)

Compute expected leftover inventory when stocking quantity q.

```math
E[\textrm{leftover}] = \int_{-\infty}0^q(q - x)f(x)dx 
```
"""
function leftover(anp::AbstractNewsvendorProblem, q)
    if isinf(q) return Inf end
    return leftover(distr(anp), q)
end


"""
    sales(anp::AbstractNewsvendorProblem, q)

Compute expected sales when stocking quantity q.
"""
sales(anp::AbstractNewsvendorProblem, q) = q - leftover(anp, q)


"""
	lost_sales(anp::AbstractNewsvendorProblem, q)

Compute expected lost sales when stocking quantity q.
"""
lost_sales(anp::AbstractNewsvendorProblem, q) = mean(distr(anp)) - sales(anp, q)



"""
	mismatch_cost(anp::AbstractNewsvendorProblem, q)

Compute expected mismatch cost when stocking quantity q. It is given by
```math
E[\\textrm{mismatch cost}] = \\textrm{underage cost} \\times  E[\\textrm{lost sales}] + \\textrm{overage cost} \\times  E[\\textrm{leftover}]
```
"""
function mismatch_cost(anp::AbstractNewsvendorProblem, q)
    if isinf(q) return 0 end
    return (underage_cost(anp) * lost_sales(anp, q)
            +
            overage_cost(anp) * leftover(anp, q))
end


"""
    profit(anp::AbstractNewsvendorProblem)

Compute expected profit when stocking quantity q_opt.


	profit(anp::AbstractNewsvendorProblem, q)

Compute expected profit when stocking quantity q. It is given by
```math
E[\\textrm{profit}] = \\textrm{underage cost} \\times  \\mu - E[\\textrm{mismatch cost}] +  \\textrm{profit shift}
```
"""
profit(anp::AbstractNewsvendorProblem, q) = (underage_cost(anp) * mean(distr(anp))
                                             -
                                             mismatch_cost(anp, q) + profit_shift(anp))

profit(anp::AbstractNewsvendorProblem) = profit(anp, q_opt(anp))