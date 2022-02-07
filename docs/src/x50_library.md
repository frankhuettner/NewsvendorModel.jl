# Library

## Newsvendor Model 

```@docs
NVModel
```


### Optimizing expected profit

```@docs
solve
```


### Quantities

```@docs
q_opt
q_scarf
```



### Metrics

```@docs
critical_fractile
profit
mismatch_cost
lost_sales
sales
leftover
```

## AbstractNewsvendorProblem

```@docs
AbstractNewsvendorProblem
```

### Required functions that determine a newsvendor problem

```@docs
overage_cost(::AbstractNewsvendorProblem)
underage_cost(::AbstractNewsvendorProblem)
distr(::AbstractNewsvendorProblem)
profit_shift(::AbstractNewsvendorProblem)
```

