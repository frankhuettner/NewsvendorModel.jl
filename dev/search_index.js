var documenterSearchIndex = {"docs":
[{"location":"x50_library/#Library","page":"Library","title":"Library","text":"","category":"section"},{"location":"x50_library/#Newsvendor-Model","page":"Library","title":"Newsvendor Model","text":"","category":"section"},{"location":"x50_library/","page":"Library","title":"Library","text":"NVModel","category":"page"},{"location":"x50_library/#NewsvendorModel.NVModel","page":"Library","title":"NewsvendorModel.NVModel","text":"NVModel(demand, cost, price, salvage=0)\n\nCaptures a Newsvendor model  with unit cost, unit selling price, and  demand distribution. The demand can be any univariate distribution from the  package Distributions.jl.\n\nExamples\n\njulia> using Distributions\n\njulia> nvm = NVModel(demand = Normal(50, 20), cost = 5, price = 7)\nData of the Newsvendor Model\n * Demand distribution: Normal{Float64}(μ=50.0, σ=20.0)\n * Unit cost: 5.00\n * Unit selling price: 7.00\n\nThis defines a model with unit cost 5 and unit price 7, where uncertain demand  draws from a normal distribution with mean 50 and standard deviation 20.\n\nOptional keyword arguments and their defaults:\n\nNVModel(demand [; kwargs])\n\ncost for a unit; defaults to 0.0\nprice for selling a unit; defaults to 0.0\nsalvage value obtained from scraping a leftover unit; defaults to 0.0\nholding cost induced by a leftover unit, e.g., extra captial cost or warehousing cost; essentially a negative salvage value; defaults to 0.0\nbackorder penalty for being short a unit, e.g., contractual penalty for missing delivery targets or missed future profit of an unserved customer; defaults to 0.0\nsubstitute benefit received from selling an alternative to an unserved customer, e.g., when selling another product or serving in the future; essentially a negative backorder penalty; defaults to 0.0\nfixcost fixed cost of operations; defaults to 0.0\nq_min minimal feasible quantity, e.g., due to production limits; must be nonnegative; defaults to 0\nq_max maximal feasible quantity, e.g., due to production limits; must be greater than or equal to q_min; defaults to Inf\n\nExamples\n\nDefine a newsvendor problem with unit cost 5, unit price 7, uniform demand between 50 and 80, where a unit salvages for 0.5, and backorder comes at a penalty  of 2 per unit, and the operations incur a fixed cost of 100, as follows:\n\njulia> nvm2 = NVModel(demand = Uniform(50, 80), cost = 5, price = 7, salvage = 0.5, backorder = 2, fixcost = 100)\nData of the Newsvendor Model\n * Demand distribution: Uniform{Float64}(a=50.0, b=80.0)\n * Unit cost: 5.00\n * Unit selling price: 7.00\n * Unit salvage value: 0.50\n * Unit backorder penalty: 2.00\n * Fixed cost: 100.00\n\nNote that demand is a necessary argument that can be passed without keyword in first place. Moreover, only values that differ from the default will be shown.\n\nDefine a newsvendor problem with unit cost 5, unit price 7, uniform demand between 50 and 80, where a unit salvages for 0.5, and backorder comes at a penalty  of 2 per unit, and the operations incur a fixed cost of 100, as follows:\n\njulia> nvm3 = NVModel(Uniform(50, 80), 5, 7, 0.5, backorder = 2, fixcost = 100, q_min=0)\nData of the Newsvendor Model\n * Demand distribution: Uniform{Float64}(a=50.0, b=80.0)\n * Unit cost: 5.00\n * Unit selling price: 7.00\n * Unit salvage value: 0.50\n * Unit backorder penalty: 2.00\n * Fixed cost: 100.00\njulia> nvm3 == nvm2\ntrue\n\nHolding cost is essentially overage cost. Backorder penalty is essentially underage cost. The beer game has holding cost of 0.5 USD and backlog costs 1 USD per unit.  Demand is assumed to be uniform betwen 0 and 300. \n\njulia> beer = NVModel(Uniform(0, 300), backorder = 1, holding = 0.5)\nData of the Newsvendor Model\n * Demand distribution: Uniform{Float64}(a=0.0, b=300.0)\n * Unit cost: 0.00\n * Unit selling price: 0.00\n * Unit holding cost: 0.50\n * Unit backorder penalty: 1.00\n\n\n\n\n\n","category":"type"},{"location":"x50_library/#Optimizing-expected-profit","page":"Library","title":"Optimizing expected profit","text":"","category":"section"},{"location":"x50_library/","page":"Library","title":"Library","text":"solve","category":"page"},{"location":"x50_library/#NewsvendorModel.solve","page":"Library","title":"NewsvendorModel.solve","text":"solve(nvm::NVModel [; rounded = true])\n\nCompute the stocking quantity q_opt(nvm) that maximizes the expected profit  as well as further the metrics when using it. The optimal quantity is rounded up to the next integer by default. To get the  exact real number, set the keyword arguement rounded = false.\n\n\n\n\n\n","category":"function"},{"location":"x50_library/#Quantities","page":"Library","title":"Quantities","text":"","category":"section"},{"location":"x50_library/","page":"Library","title":"Library","text":"q_opt\nq_scarf","category":"page"},{"location":"x50_library/#NewsvendorModel.q_opt","page":"Library","title":"NewsvendorModel.q_opt","text":"q_opt(anp::AbstractNewsvendorProblem; rounded = true)\n\nCompute the quanitity that maximizes expected profit for a newsvendor problem (i.e., where critical fractile equals in-stock probability). Attempts to solve \n\nF(q_opt) = textrmcritical fractile \n\nwhere F is the c.d.f. of the demand distribution. Returns closest next integer unless rounded=false; then, it returns exact real. Clamps at qmin and qmax.\n\n\n\n\n\nq_opt(res::NVResult)\n\nGet optimal quantity from a stored result.\n\n\n\n\n\n","category":"function"},{"location":"x50_library/#NewsvendorModel.q_scarf","page":"Library","title":"NewsvendorModel.q_scarf","text":"q_scarf(anp::AbstractNewsvendorProblem)\n\nCompute the quanitity that maximizes the minimal expected profit among all  distributions with the same mean and variance. Worst-case solution (Scarf, 1958)\n\nq_scarf = mu + sigma2 * (sqrtr - sqrt1r)\n\nwhere\n\nr = fractextrmunderage cost textrmoverage cost\n\n\n\n\n\n","category":"function"},{"location":"x50_library/#Metrics","page":"Library","title":"Metrics","text":"","category":"section"},{"location":"x50_library/","page":"Library","title":"Library","text":"critical_fractile\nprofit\nmismatch_cost\nlost_sales\nsales\nleftover","category":"page"},{"location":"x50_library/#NewsvendorModel.critical_fractile","page":"Library","title":"NewsvendorModel.critical_fractile","text":"critical_fractile(anp::AbstractNewsvendorProblem)\n\nCompute the critical fractile for a newsvendor problem:\n\ntextrmcritical fractile = fractextrmunderage costtextrmunderage cost + textrmoverage cost\n\n\n\n\n\ncritical_fractile(res::NVResult)\n\nGet critical fractile from a stored result.\n\n\n\n\n\n","category":"function"},{"location":"x50_library/#NewsvendorModel.profit","page":"Library","title":"NewsvendorModel.profit","text":"profit(anp::AbstractNewsvendorProblem)\n\nCompute expected profit when stocking quantity q_opt.\n\nprofit(anp::AbstractNewsvendorProblem, q)\n\nCompute expected profit when stocking quantity q. It is given by\n\nEtextrmprofit = textrmunderage cost times  mu - Etextrmmismatch cost +  textrmprofit shift\n\n\n\n\n\nprofit(res::NVResult)\n\nGet expected profit from a stored result.\n\n\n\n\n\n","category":"function"},{"location":"x50_library/#NewsvendorModel.mismatch_cost","page":"Library","title":"NewsvendorModel.mismatch_cost","text":"mismatch_cost(anp::AbstractNewsvendorProblem, q)\n\nCompute expected mismatch cost when stocking quantity q. It is given by\n\nEtextrmmismatch cost = textrmunderage cost times  Etextrmlost sales + textrmoverage cost times  Etextrmleftover\n\n\n\n\n\n","category":"function"},{"location":"x50_library/#NewsvendorModel.lost_sales","page":"Library","title":"NewsvendorModel.lost_sales","text":"lost_sales(anp::AbstractNewsvendorProblem, q)\n\nCompute expected lost sales when stocking quantity q.\n\n\n\n\n\nlost_sales(res::NVResult)\n\nGet expected lost sales model from a stored result.\n\n\n\n\n\n","category":"function"},{"location":"x50_library/#NewsvendorModel.sales","page":"Library","title":"NewsvendorModel.sales","text":"sales(anp::AbstractNewsvendorProblem, q)\n\nCompute expected sales when stocking quantity q.\n\n\n\n\n\nsales(res::NVResult)\n\nGet expected sales from a stored result.\n\n\n\n\n\n","category":"function"},{"location":"x50_library/#NewsvendorModel.leftover","page":"Library","title":"NewsvendorModel.leftover","text":"leftover(anp::AbstractNewsvendorProblem, q)\n\nCompute expected leftover inventory when stocking quantity q.\n\nEtextrmleftover = int_-infty^q (q - x)f(x)dx \n\n\n\n\n\nleftover(res::NVResult)\n\nGet expected leftover from a stored result.\n\n\n\n\n\n","category":"function"},{"location":"x50_library/#AbstractNewsvendorProblem","page":"Library","title":"AbstractNewsvendorProblem","text":"","category":"section"},{"location":"x50_library/","page":"Library","title":"Library","text":"AbstractNewsvendorProblem","category":"page"},{"location":"x50_library/#NewsvendorModel.AbstractNewsvendorProblem","page":"Library","title":"NewsvendorModel.AbstractNewsvendorProblem","text":"An abstract newsvendor problem is essentially described by having a\n\ndemand distribution,\ncost of overage, \ncost of underage, and \nprofit_shift term.\n\nIts standard concrete type might come as a NewsvendorModel, defined by unit cost, uni selling price etc.\n\n\n\n\n\n","category":"type"},{"location":"x50_library/#Required-functions-that-determine-a-newsvendor-problem","page":"Library","title":"Required functions that determine a newsvendor problem","text":"","category":"section"},{"location":"x50_library/","page":"Library","title":"Library","text":"overage_cost(::AbstractNewsvendorProblem)\nunderage_cost(::AbstractNewsvendorProblem)\ndistr(::AbstractNewsvendorProblem)\nprofit_shift(::AbstractNewsvendorProblem)","category":"page"},{"location":"x50_library/#NewsvendorModel.overage_cost-Tuple{AbstractNewsvendorProblem}","page":"Library","title":"NewsvendorModel.overage_cost","text":"overage_cost(anp::AbstractNewsvendorProblem)\n\nGet the cost of overage of a newsvendor problem.\n\n\n\n\n\n","category":"method"},{"location":"x50_library/#NewsvendorModel.underage_cost-Tuple{AbstractNewsvendorProblem}","page":"Library","title":"NewsvendorModel.underage_cost","text":"underage_cost(anp::AbstractNewsvendorProblem)\n\nGet the cost of underage of a newsvendor problem.\n\n\n\n\n\n","category":"method"},{"location":"x50_library/#NewsvendorModel.distr-Tuple{AbstractNewsvendorProblem}","page":"Library","title":"NewsvendorModel.distr","text":"distr(anp::AbstractNewsvendorProblem)\n\nGet the demand distribution of a newsvendor problem.\n\n\n\n\n\n","category":"method"},{"location":"x50_library/#NewsvendorModel.profit_shift-Tuple{AbstractNewsvendorProblem}","page":"Library","title":"NewsvendorModel.profit_shift","text":"profit_shift(anp::AbstractNewsvendorProblem)\t\n\nDefine how profit is shifted because of fixed cost, penalty, etc.; defautls to 0.0.\n\n\n\n\n\n","category":"method"},{"location":"x30_distributions/#Demand-distribution","page":"Demand distribution","title":"Demand distribution","text":"","category":"section"},{"location":"x30_distributions/","page":"Demand distribution","title":"Demand distribution","text":"Working with distributions is very convinient in Julia. This package is supposed to work with any univariate distribution from the Distributions.jl package. ","category":"page"},{"location":"x30_distributions/","page":"Demand distribution","title":"Demand distribution","text":"For example, consider a slight variation of the introductory example. Suppose we want to avoid demand below zero, i.e., let us truncate the distribution at 0. We can define our distribution of choice as follows: ","category":"page"},{"location":"x30_distributions/","page":"Demand distribution","title":"Demand distribution","text":"julia> my_distr = truncated(Normal(50, 20), 0, Inf)\nTruncated(Normal{Float64}(μ=50.0, σ=20.0); lower=0.0)","category":"page"},{"location":"x30_distributions/","page":"Demand distribution","title":"Demand distribution","text":"The model is now defined and stored in the variable nvm2 as follows:","category":"page"},{"location":"x30_distributions/","page":"Demand distribution","title":"Demand distribution","text":"julia> nvm2 = NVModel(demand = my_distr, cost = 5, price = 7)\nData of the Newsvendor Model\n * Demand distribution: Truncated(Normal{Float64}(μ=50.0, σ=20.0); lower=0.0)\n * Unit cost: 5.00\n * Unit selling price: 7.00","category":"page"},{"location":"x30_distributions/","page":"Demand distribution","title":"Demand distribution","text":"Optimization yields a slightly different result:","category":"page"},{"location":"x30_distributions/","page":"Demand distribution","title":"Demand distribution","text":"julia> profit(solve(nvm2)) - profit(solve(NVModel(demand = Normal(50, 20), cost = 5, price = 7)))\n1.8282476501980582","category":"page"},{"location":"x30_distributions/","page":"Demand distribution","title":"Demand distribution","text":"Other typical distributions are readily available, e.g.,","category":"page"},{"location":"x30_distributions/","page":"Demand distribution","title":"Demand distribution","text":"Beta distribution with Beta(α, β)\nLog normal distribution with LogNormal(μ, σ)\nNonparametric discrete distribution with DiscreteNonParametric(xs, ps)\nPoisson distribution with Poisson(λ)\nUniform distribution with Uniform(a, b)","category":"page"},{"location":"x30_distributions/","page":"Demand distribution","title":"Demand distribution","text":"Moreover, it is convinient to fit distributions with Distributions.jl.","category":"page"},{"location":"x21_optimize_options/#Rounded","page":"Rounded","title":"Rounded","text":"","category":"section"},{"location":"x21_optimize_options/","page":"Rounded","title":"Rounded","text":"Let us assume that we do not want the integer quantity but the exact real number. To this end, we need to call the solve function with the additional argument rounded = false","category":"page"},{"location":"x21_optimize_options/#Example","page":"Rounded","title":"Example","text":"","category":"section"},{"location":"x21_optimize_options/","page":"Rounded","title":"Rounded","text":"julia> nvm = NVModel(demand = Normal(50, 20), cost = 2, price = 7)\nData of the Newsvendor Model\n * Demand distribution: Normal{Float64}(μ=50.0, σ=20.0)\n * Unit cost: 2.00\n * Unit selling price: 7.00\n\njulia> res_real = solve(nvm, rounded = false)\n=====================================\nResults of maximizing expected profit\n * Optimal quantity: 61.32\n * Expected profit: 202.41\n=====================================\nThis is a consequence of\n * Cost of underage:  5.00\n   ╚ + Price:               7.00\n   ╚ - Cost:                2.00\n * Cost of overage:   2.00\n   ╚ + Cost:                2.00\n * Critical fractile: 0.71\n * Rounded to closest integer: false\n-------------------------------------\nOrdering the optimal quantity yields\n * Expected sales: 46.44 units\n * Expected lost sales: 3.56 units\n * Expected leftover: 14.88 units\n-------------------------------------","category":"page"},{"location":"x21_optimize_options/","page":"Rounded","title":"Rounded","text":"This reveals a slighlty higher profit than with the standard (rounded up) integer result:","category":"page"},{"location":"x21_optimize_options/","page":"Rounded","title":"Rounded","text":"julia> q_opt(nvm)\n61\n\njulia> profit(res_real)\n202.41322650461186\n\njulia> profit(nvm)\n202.40715617998893","category":"page"},{"location":"x21_optimize_options/","page":"Rounded","title":"Rounded","text":"rounded(res_real) applied to a result tells whether the integer result was looked for is.","category":"page"},{"location":"x21_optimize_options/","page":"Rounded","title":"Rounded","text":"julia> rounded(res_real)\nfalse","category":"page"},{"location":"x20_model_options/#Further-options-when-specifying-the-model","page":"Further options when specifying the model","title":"Further options when specifying the model","text":"","category":"section"},{"location":"x20_model_options/","page":"Further options when specifying the model","title":"Further options when specifying the model","text":"You can pass the following optional keyword arguments in the definition of a newsvendor model NVModel(demand [; kwargs]):","category":"page"},{"location":"x20_model_options/","page":"Further options when specifying the model","title":"Further options when specifying the model","text":"cost for a unit; defaults to 0\nprice for selling a unit; defaults to 0\nsalvage value obtained from scraping a leftover unit; defaults to 0\nholding cost obtained from a leftover unit, e.g., extra captial cost or warehousing cost; essentially a negative salvage value; defaults to 0\nbackorder penalty for being short a unit, e.g., contractual penalty for missing delivery targets or missed future profit of an unserved customer; defaults to 0\nsubstitute benefit received from selling to an unserved customer, e.g., when selling another product or serving in the future; essentially a negative backorder penalty; defaults to 0\nfixcost fixed cost of operations; defaults to 0\nq_min minimal feasible quantity, e.g., due to production limits; must be nonnegative; defaults to 0\nq_max maximal feasible quantity, e.g., due to production limits; must be greater than or equal to q_min; defaults to Inf","category":"page"},{"location":"x20_model_options/#Example","page":"Further options when specifying the model","title":"Example","text":"","category":"section"},{"location":"x20_model_options/","page":"Further options when specifying the model","title":"Further options when specifying the model","text":"Define a newsvendor problem with unit cost 5, unit price 7, normal demand around 50 with standard deviation 20, where a unit salvages for 0.5, and back order incurs at a penalty of 2 per unit, as follows:","category":"page"},{"location":"x20_model_options/","page":"Further options when specifying the model","title":"Further options when specifying the model","text":"julia> nvm2 = NVModel(cost = 5, price = 7, demand = Normal(50, 20), salvage = 0.5, backorder = 2)\nData of the Newsvendor Model\n * Demand distribution: Normal{Float64}(μ=50.0, σ=20.0)\n * Unit cost: 5.00\n * Unit selling price: 7.00\n * Unit salvage value: 0.50\n * Unit backorder penalty: 2.00","category":"page"},{"location":"x20_model_options/","page":"Further options when specifying the model","title":"Further options when specifying the model","text":"Note that cost, price, and demand are necessary arguments that can be passed without keyword. Moreover, only values that differ from the default value will be shown in the REPL. For instance, adding q_min=0 does not have an impact.","category":"page"},{"location":"x20_model_options/","page":"Further options when specifying the model","title":"Further options when specifying the model","text":"julia> nvm3 = NVModel(demand = Normal(50, 20), cost = 5, price = 7, salvage = 0.5, backorder = 2, q_min=0)\nData of the Newsvendor Model\n * Demand distribution: Normal{Float64}(μ=50.0, σ=20.0)\n * Unit cost: 5.00\n * Unit selling price: 7.00\n * Unit salvage value: 0.50\n * Unit backorder penalty: 2.00","category":"page"},{"location":"x20_model_options/","page":"Further options when specifying the model","title":"Further options when specifying the model","text":"julia> nvm3 == nvm2\ntrue","category":"page"},{"location":"#Quick-start","page":"Quick start","title":"Quick start","text":"","category":"section"},{"location":"","page":"Quick start","title":"Quick start","text":"This is a lightweight and simple Julia package for modeling and solving newsvendor problems.","category":"page"},{"location":"#Setup","page":"Quick start","title":"Setup","text":"","category":"section"},{"location":"","page":"Quick start","title":"Quick start","text":"NewsvendorModel.jl requires an installation of Julia (can be downloaded from the official website). You can install NewsvendorModel.jl like any other Julia package using the REPL as follows:","category":"page"},{"location":"","page":"Quick start","title":"Quick start","text":"julia> import Pkg\njulia> Pkg.add(\"NewsvendorModel\")","category":"page"},{"location":"","page":"Quick start","title":"Quick start","text":"After installation, it can be loaded with the usual command.","category":"page"},{"location":"","page":"Quick start","title":"Quick start","text":"julia> using NewsvendorModel","category":"page"},{"location":"","page":"Quick start","title":"Quick start","text":"Moreover, you need to load the Distributions.jl package.","category":"page"},{"location":"","page":"Quick start","title":"Quick start","text":"julia> using Distributions","category":"page"},{"location":"#Usage","page":"Quick start","title":"Usage","text":"","category":"section"},{"location":"","page":"Quick start","title":"Quick start","text":"Define a model with the function nvm = NVModel(demand, cost, price) using the following required arguments:\ndemand distribution, which can be any choosen from the univariate distributions of the Distributions.jl package\nunit production cost\nunit selling price\nFind the optimal quanitity and obtain key metrics: \nq_opt(nvm) returns the quantity that maximizes the expected profit\nprofit(nvm, q) to get the expected profit if q is stocked\nprofit(nvm) is short for the maximal expected profit profit(nvm, q_opt(nvm)) \nsolve(nvm) gives a list of further important metrics (critical fractile as well as expected sales, lost sales, and leftover).","category":"page"},{"location":"","page":"Quick start","title":"Quick start","text":"Additional keyword arguments specifying salvage value, backorder penalty, holding cost, substitute value, fixcost, qmin, and qmax can be passed in Step 1. To obtain the unrounded optimal quantity, pass rounded=false in Step 2.","category":"page"},{"location":"#Example","page":"Quick start","title":"Example","text":"","category":"section"},{"location":"","page":"Quick start","title":"Quick start","text":"Consider an example with ","category":"page"},{"location":"","page":"Quick start","title":"Quick start","text":"unit cost = 5  \nunit price = 7\ndemand that draws from a normal distribution with \nmean = 50 \nstandard deviation = 20","category":"page"},{"location":"","page":"Quick start","title":"Quick start","text":"Define the model and store it in the variable nvm as follows:","category":"page"},{"location":"","page":"Quick start","title":"Quick start","text":"julia> nvm = NVModel(demand = Normal(50, 20), cost = 5, price = 7)\nData of the Newsvendor Model\n * Demand distribution: Normal{Float64}(μ=50.0, σ=20.0)\n * Unit cost: 5.00\n * Unit selling price: 7.00","category":"page"},{"location":"","page":"Quick start","title":"Quick start","text":"Next, you can solve the model and store the result in the variable res like so:","category":"page"},{"location":"","page":"Quick start","title":"Quick start","text":"julia> res = solve(nvm)\n=====================================\nResults of maximizing expected profit\n * Optimal quantity: 39 units\n * Expected profit: 52.41\n=====================================\nThis is a consequence of\n * Cost of underage:  2.00\n   ╚ + Price:               7.00\n   ╚ - Cost:                5.00\n * Cost of overage:   5.00\n   ╚ + Cost:                5.00\n * Critical fractile: 0.29\n * Rounded to closest integer: true\n-------------------------------------\nOrdering the optimal quantity yields\n * Expected sales: 35.34 units\n * Expected lost sales: 14.66 units\n * Expected leftover: 3.66 units\n-------------------------------------","category":"page"},{"location":"","page":"Quick start","title":"Quick start","text":"Moreover, you have stored the result in the variable res. Reading the data from the stored result is straight-forward:","category":"page"},{"location":"","page":"Quick start","title":"Quick start","text":"julia> q_opt(res)\n39","category":"page"},{"location":"","page":"Quick start","title":"Quick start","text":"julia> profit(res)\n52.40715617998893","category":"page"},{"location":"","page":"Quick start","title":"Quick start","text":"Analogously, underage_cost(res), overage_cost(res), critical_fractile(res), sales(res), lost_sales(res), leftover(res) read. ","category":"page"},{"location":"","page":"Quick start","title":"Quick start","text":"Applying the above functions directly to the model (instead of to the result) is also possible, with the ability to pass a quantity. For instance,  ","category":"page"},{"location":"","page":"Quick start","title":"Quick start","text":"julia> leftover(nvm, 39)\n3.656120545715868","category":"page"},{"location":"","page":"Quick start","title":"Quick start","text":"An advantage of using the solve function and then reading the data from the result lies in the fact that the model that was solved can be retrieved with nvmodel(res).","category":"page"}]
}
