var documenterSearchIndex = {"docs":
[{"location":"x4_library/#Library","page":"Library","title":"Library","text":"","category":"section"},{"location":"x4_library/#Newsvendor-Model","page":"Library","title":"Newsvendor Model","text":"","category":"section"},{"location":"x4_library/","page":"Library","title":"Library","text":"NVModel","category":"page"},{"location":"x4_library/#NewsvendorModel.NVModel","page":"Library","title":"NewsvendorModel.NVModel","text":"NVModel(cost, price, demand)\n\nCaptures a Newsvendor model with unit cost, unit selling price, and  demand distribution. The demand can be any univariate  distribution from the package Distributions.jl.\n\nExamples\n\njulia> using Distributions\njulia> nvm = NVModel(5, 7, Normal(50, 20))\nData of the Newsvendor Model\n * Unit cost: 5.00\n * Unit selling price: 7.00\n * Demand distribution: Normal{Float64}(μ=50.0, σ=20.0)\n\nThis defines a model with unit cost 5, unit price 7, and an uncertain demand   that draws from a normal distribution with mean 50 and standard deviation 20.\n\nOptional keyword arguments and their defaults:\n\nNVModel(cost, price, demand [; kwargs])\n\nsalvage value obtained from scraping a leftover unit; might be negative, e.g., due to disposal cost, extra captial cost, or warehousing cost; defaults to 0\nbacklog penalty for being short a unit, e.g., contractual penalty for missing delivery targets or missed future profit of an unserved customer; defaults to 0\nfixcost fixed cost of operations; defaults to 0\nq_min minimal feasible quantity, e.g., due to production limits; must be nonnegative; defaults to 0\nq_max maximal feasible quantity, e.g., due to production limits; must be greater than or equal to q_min; defaults to Inf\n\nExamples\n\nDefine a newsvendor problem with unit cost 5, unit price 7, uniform demand between 50 and 80, where a unit salvages for 0.5, and backlog comes at a penalty  of 2 per unit, and the operations incur a fixed cost of 100, as follows:\n\njulia> nvm2 = NVModel(cost = 5, price = 7, demand = Uniform(50, 80), salvage = 0.5, backlog = 2, fixcost = 100)\nData of the Newsvendor Model\n * Unit cost: 5.00\n * Unit selling price: 7.00\n * Demand distribution: Uniform{Float64}(a=30.0, b=100.0)\n * Unit salvage value: 0.50\n * Unit backlog penalty: 2.00\n * Fixed cost: 100.00\n\nNote that cost, price, and demand are necessary arguments that can be passed without keyword. Moreover, only values that differ from the default will be shown.\n\nDefine a newsvendor problem with unit cost 5, unit price 7, uniform demand between 30 and 100, where a unit salvages for 0.5, and backlog comes at a penalty  of 2 per unit, and the operations incur a fixed cost of 100, as follows:\n\njulia> nvm3 = NVModel(5, 7, Uniform(50, 80), salvage = 0.5, backlog = 2, fixcost = 100, q_min=0.0)\nData of the Newsvendor Model\n * Unit cost: 5.00\n * Unit selling price: 7.00\n * Demand distribution: Uniform{Float64}(a=30.0, b=100.0)\n * Unit salvage value: 0.50\n * Unit backlog penalty: 2.00\n * Fixed cost: 100.00\njulia> nvm3 == nvm2\ntrue\n\n\n\n\n\n","category":"type"},{"location":"x4_library/#Optimizing-expected-profit","page":"Library","title":"Optimizing expected profit","text":"","category":"section"},{"location":"x4_library/","page":"Library","title":"Library","text":"optimize","category":"page"},{"location":"x4_library/#NewsvendorModel.optimize","page":"Library","title":"NewsvendorModel.optimize","text":"optimize(nvm::NVModel [; roundup_rule = true])\n\nCompute the stocking quantity q_opt(nvm) that maximizes the expected profit  as well as further the metrics when using it. The optimal quantity is rounded up to the next integer by default. To get the  exact real number, set the keyword arguement roundup_rule = false.\n\n\n\n\n\n","category":"function"},{"location":"x4_library/#Quantities","page":"Library","title":"Quantities","text":"","category":"section"},{"location":"x4_library/","page":"Library","title":"Library","text":"q_opt\nq_scarf","category":"page"},{"location":"x4_library/#NewsvendorModel.q_opt","page":"Library","title":"NewsvendorModel.q_opt","text":"q_opt(anp::AbstractNewsvendorProblem; roundup_rule = true)\n\nCompute the quanitity that maximizes expected profit for a newsvendor problem (i.e., where critical fractile equals in-stock probability). Attempts to solve \n\nF(q_opt) = textrmcritical fractile \n\nwhere F is the c.d.f. of the demand distribution. Returns the next integer unless roundup_rule=false; then, it returns exact real. Clamps at qmin and qmax.\n\n\n\n\n\nq_opt(res::NVResult)\n\nGet optimal quantity from a stored result.\n\n\n\n\n\n","category":"function"},{"location":"x4_library/#NewsvendorModel.q_scarf","page":"Library","title":"NewsvendorModel.q_scarf","text":"q_scarf(anp::AbstractNewsvendorProblem)\n\nCompute the quanitity that maximizes the minimal expected profit among all  distributions with the same mean and variance. Worst-case solution (Scarf, 1958)\n\nq_scarf = mu + sigma2 * (sqrtr - sqrt1r)\n\nwhere\n\nr = fractextrmunderage cost textrmoverage cost\n\n\n\n\n\n","category":"function"},{"location":"x4_library/#Metrics","page":"Library","title":"Metrics","text":"","category":"section"},{"location":"x4_library/","page":"Library","title":"Library","text":"critical_fractile\nprofit\nmismatch_cost\nlost_sales\nsales\nleftover","category":"page"},{"location":"x4_library/#NewsvendorModel.critical_fractile","page":"Library","title":"NewsvendorModel.critical_fractile","text":"critical_fractile(anp::AbstractNewsvendorProblem)\n\nCompute the critical fractile for a newsvendor problem:\n\ntextrmcritical fractile = fractextrmunderage costtextrmunderage cost + textrmoverage cost\n\n\n\n\n\ncritical_fractile(res::NVResult)\n\nGet critical fractile from a stored result.\n\n\n\n\n\n","category":"function"},{"location":"x4_library/#NewsvendorModel.profit","page":"Library","title":"NewsvendorModel.profit","text":"profit(anp::AbstractNewsvendorProblem)\n\nCompute expected profit when stocking quantity q_opt.\n\nprofit(anp::AbstractNewsvendorProblem, q)\n\nCompute expected profit when stocking quantity q. It is given by\n\nEtextrmprofit = textrmunderage cost times  mu - Etextrmmismatch cost +  textrmprofit shift\n\n\n\n\n\nprofit(res::NVResult)\n\nGet expected profit from a stored result.\n\n\n\n\n\n","category":"function"},{"location":"x4_library/#NewsvendorModel.mismatch_cost","page":"Library","title":"NewsvendorModel.mismatch_cost","text":"mismatch_cost(anp::AbstractNewsvendorProblem, q)\n\nCompute expected mismatch cost when stocking quantity q. It is given by\n\nEtextrmmismatch cost = textrmunderage cost times  Etextrmlost sales + textrmoverage cost times  Etextrmleftover\n\n\n\n\n\n","category":"function"},{"location":"x4_library/#NewsvendorModel.lost_sales","page":"Library","title":"NewsvendorModel.lost_sales","text":"lost_sales(anp::AbstractNewsvendorProblem, q)\n\nCompute expected lost sales when stocking quantity q.\n\n\n\n\n\nlost_sales(res::NVResult)\n\nGet expected lost sales model from a stored result.\n\n\n\n\n\n","category":"function"},{"location":"x4_library/#NewsvendorModel.sales","page":"Library","title":"NewsvendorModel.sales","text":"sales(anp::AbstractNewsvendorProblem, q)\n\nCompute expected sales when stocking quantity q.\n\n\n\n\n\nsales(res::NVResult)\n\nGet expected sales from a stored result.\n\n\n\n\n\n","category":"function"},{"location":"x4_library/#NewsvendorModel.leftover","page":"Library","title":"NewsvendorModel.leftover","text":"leftover(anp::AbstractNewsvendorProblem, q)\n\nCompute expected leftover inventory when stocking quantity q.\n\ntextrmExpected leftover inventory = qF(0) + int_0^q(q - y)f(y)dy\n\n\n\n\n\nleftover(res::NVResult)\n\nGet expected leftover from a stored result.\n\n\n\n\n\n","category":"function"},{"location":"x4_library/#AbstractNewsvendorProblem","page":"Library","title":"AbstractNewsvendorProblem","text":"","category":"section"},{"location":"x4_library/","page":"Library","title":"Library","text":"AbstractNewsvendorProblem","category":"page"},{"location":"x4_library/#NewsvendorModel.AbstractNewsvendorProblem","page":"Library","title":"NewsvendorModel.AbstractNewsvendorProblem","text":"An abstract newsvendor problem is essentially described by having a\n\ndemand distribution,\ncost of overage, \ncost of underage, and \nprofit_shift term.\n\nIts standard concrete type might come as a NewsvendorModel, defined by unit cost, uni selling price etc.\n\n\n\n\n\n","category":"type"},{"location":"x4_library/#Required-functions-that-determine-a-newsvendor-problem","page":"Library","title":"Required functions that determine a newsvendor problem","text":"","category":"section"},{"location":"x4_library/","page":"Library","title":"Library","text":"overage_cost(::AbstractNewsvendorProblem)\nunderage_cost(::AbstractNewsvendorProblem)\ndistr(::AbstractNewsvendorProblem)\nprofit_shift(::AbstractNewsvendorProblem)","category":"page"},{"location":"x4_library/#NewsvendorModel.overage_cost-Tuple{AbstractNewsvendorProblem}","page":"Library","title":"NewsvendorModel.overage_cost","text":"overage_cost(anp::AbstractNewsvendorProblem)\n\nGet the cost of overage of a newsvendor problem.\n\n\n\n\n\n","category":"method"},{"location":"x4_library/#NewsvendorModel.underage_cost-Tuple{AbstractNewsvendorProblem}","page":"Library","title":"NewsvendorModel.underage_cost","text":"underage_cost(anp::AbstractNewsvendorProblem)\n\nGet the cost of underage of a newsvendor problem.\n\n\n\n\n\n","category":"method"},{"location":"x4_library/#NewsvendorModel.distr-Tuple{AbstractNewsvendorProblem}","page":"Library","title":"NewsvendorModel.distr","text":"distr(anp::AbstractNewsvendorProblem)\n\nGet the demand distribution of a newsvendor problem.\n\n\n\n\n\n","category":"method"},{"location":"x4_library/#NewsvendorModel.profit_shift-Tuple{AbstractNewsvendorProblem}","page":"Library","title":"NewsvendorModel.profit_shift","text":"profit_shift(anp::AbstractNewsvendorProblem)\t\n\nDefine how profit is shifted because of fixed cost, penalty, etc.; defautls to 0.0.\n\n\n\n\n\n","category":"method"},{"location":"x3_distributions/#Demand-distribution","page":"Demand distribution","title":"Demand distribution","text":"","category":"section"},{"location":"x3_distributions/","page":"Demand distribution","title":"Demand distribution","text":"Working with distributions is very convinient in Julia. This package is supposed to work with any univariate distribution from the Distributions.jl package. ","category":"page"},{"location":"x3_distributions/","page":"Demand distribution","title":"Demand distribution","text":"For example, consider a slight variation of the introductory example. Suppose we want to avoid demand below zero, i.e., let us truncate the distribution at 0. We can define our distribution of choice as follows: ","category":"page"},{"location":"x3_distributions/","page":"Demand distribution","title":"Demand distribution","text":"julia> my_distr = truncated(Normal(50, 20), 0, Inf)\nTruncated(Normal{Float64}(μ=50.0, σ=20.0), range=(0.0, Inf))","category":"page"},{"location":"x3_distributions/","page":"Demand distribution","title":"Demand distribution","text":"The model is now defined and stored in the variable nvm2 as follows:","category":"page"},{"location":"x3_distributions/","page":"Demand distribution","title":"Demand distribution","text":"julia> nvm2 = NVModel(5, 7, my_distr)\nData of the Newsvendor Model\n * Unit cost: 5.00\n * Unit selling price: 7.00\n * Demand distribution: Truncated(Normal{Float64}(μ=50.0, σ=20.0), range=(0.0, Inf))","category":"page"},{"location":"x3_distributions/","page":"Demand distribution","title":"Demand distribution","text":"Optimization yields a slightly different result:","category":"page"},{"location":"x3_distributions/","page":"Demand distribution","title":"Demand distribution","text":"julia> profit(optimize(nvm2)) - profit(optimize(NVModel(5, 7, Normal(50, 20))))\n1.5476684451201237","category":"page"},{"location":"x3_distributions/","page":"Demand distribution","title":"Demand distribution","text":"Other typical distributions are readily available, e.g.,","category":"page"},{"location":"x3_distributions/","page":"Demand distribution","title":"Demand distribution","text":"Beta distribution with Beta(α, β)\nLog normal distribution with LogNormal(μ, σ)\nNonparametric discrete distribution with DiscreteNonParametric(xs, ps)\nPoisson distribution with Poisson(λ)\nUniform distribution with Uniform(a, b)","category":"page"},{"location":"x3_distributions/","page":"Demand distribution","title":"Demand distribution","text":"Moreover, it is convinient to fit distributions with Distributions.jl.","category":"page"},{"location":"x2_options/#Further-options","page":"Further options","title":"Further options","text":"","category":"section"},{"location":"x2_options/","page":"Further options","title":"Further options","text":"You can pass the following optional keyword arguments in the definition of a newsvendor model NVModel(cost, price, demand [; kwargs]):","category":"page"},{"location":"x2_options/","page":"Further options","title":"Further options","text":"salvage value obtained from scraping a leftover unit; might be negative, e.g., due to disposal cost, extra captial cost, or warehousing cost; defaults to 0\nbacklog penalty for being short a unit, e.g., contractual penalty for missing delivery targets or missed future profit of an unserved customer; defaults to 0\nfixcost fixed cost of operations; defaults to 0\nq_min minimal feasible quantity, e.g., due to production limits; must be nonnegative; defaults to 0\nq_max maximal feasible quantity, e.g., due to production limits; must be greater than or equal to q_min; defaults to Infinity","category":"page"},{"location":"x2_options/#Example","page":"Further options","title":"Example","text":"","category":"section"},{"location":"x2_options/","page":"Further options","title":"Further options","text":"Define a newsvendor problem with unit cost 5, unit price 7, normal demand around 50 with standard deviation 20, where a unit salvages for 0.5, and back order incurs at a penalty of 2 per unit, as follows:","category":"page"},{"location":"x2_options/","page":"Further options","title":"Further options","text":"julia> nvm2 = NVModel(cost = 5, price = 7, demand = Normal(50, 20), salvage = 0.5, backlog = 2)\nData of the Newsvendor Model\n * Unit cost: 5.00\n * Unit selling price: 7.00\n * Demand distribution: Normal{Float64}(μ=50.0, σ=20.0)\n * Unit salvage value: 0.50\n * Unit backlog penalty: 2.00","category":"page"},{"location":"x2_options/","page":"Further options","title":"Further options","text":"Note that cost, price, and demand are necessary arguments that can be passed without keyword. Moreover, only values that differ from the default value will be shown in the REPL. For instance, adding q_min=0.0 does not have an impact.","category":"page"},{"location":"x2_options/","page":"Further options","title":"Further options","text":"julia> nvm3 = NVModel(5, 7, Normal(50, 20), salvage = 0.5, backlog = 2, q_min=0.0)\nData of the Newsvendor Model\n * Unit cost: 5.00\n * Unit selling price: 7.00\n * Demand distribution: Normal{Float64}(μ=50.0, σ=20.0)\n * Unit salvage value: 0.50\n * Unit backlog penalty: 2.00\njulia> nvm3 == nvm2\ntrue","category":"page"},{"location":"x2_options/#Round-up-rule","page":"Further options","title":"Round-up rule","text":"","category":"section"},{"location":"x2_options/","page":"Further options","title":"Further options","text":"Finally, let us assume that we do not want the optimal integer quantity but the exact real number. To this end, we need to call the optimize function with the additional argument roundup_rule = false","category":"page"},{"location":"x2_options/","page":"Further options","title":"Further options","text":"You solve the model like so:","category":"page"},{"location":"x2_options/","page":"Further options","title":"Further options","text":"julia> optimize(nvm2, roundup_rule = false)\n=====================================\nResults of maximizing expected profit\n * Optimal quantity: 48.52\n * Expected profit: 32.70\n=====================================\nThis is a consequence of\n * Cost of underage: 4.00\n * Cost of overage: 4.50\n * The critical fractile: 0.47\n * Usage of round-up rule: false\n-------------------------------------\nOrdering the optimal quantity yields\n * Expected sales: 41.30 units\n * Expected lost sales: 8.70 units\n * Expected leftover: 7.22 units\n * Expected backlog penalty: 17.40\n-------------------------------------","category":"page"},{"location":"x2_options/","page":"Further options","title":"Further options","text":"This reveals a slighlty higher profit than with the standard integer result:","category":"page"},{"location":"x2_options/","page":"Further options","title":"Further options","text":"julia> q_opt(optimize(nvm2)) \n49\njulia> profit(optimize(nvm2)) \n32.68575807471575","category":"page"},{"location":"#Quick-start","page":"Quick start","title":"Quick start","text":"","category":"section"},{"location":"","page":"Quick start","title":"Quick start","text":"This is a lightweight and simple Julia package for modeling and solving newsvendor problems.","category":"page"},{"location":"#Setup","page":"Quick start","title":"Setup","text":"","category":"section"},{"location":"","page":"Quick start","title":"Quick start","text":"NewsvendorModel.jl requires an installation of Julia (can be downloaded from the official website). You can install NewsvendorModel.jl like any other Julia package using the REPL as follows:","category":"page"},{"location":"","page":"Quick start","title":"Quick start","text":"julia> import Pkg\njulia> Pkg.add(url=\"https://github.com/frankhuettner/NewsvendorModel.jl\")","category":"page"},{"location":"","page":"Quick start","title":"Quick start","text":"After installation, it can be loaded with the usual command.","category":"page"},{"location":"","page":"Quick start","title":"Quick start","text":"julia> using NewsvendorModel","category":"page"},{"location":"","page":"Quick start","title":"Quick start","text":"Moreover, you need to load the Distributions.jl package.","category":"page"},{"location":"","page":"Quick start","title":"Quick start","text":"julia> using Distributions","category":"page"},{"location":"#Usage","page":"Quick start","title":"Usage","text":"","category":"section"},{"location":"","page":"Quick start","title":"Quick start","text":"Define a model with the function nvm = NVModel(cost, price, demand) using the following required arguments:\nunit production cost\nunit selling price\ndemand distribution, which can be any choosen from the Distributions.jl package\nSolve for optimal quanitity and obtain key metrics with the optimize(nvm) function.","category":"page"},{"location":"","page":"Quick start","title":"Quick start","text":"Note that additional keyword arguments can be passed in Step 1: salvage value,   backlog, fixcost, q_min, and q_max. Moreover, it is possible to obtain the unrounded optimal quantity by passing roundup_rule=false in Step 2. For more details go to Further options.  ","category":"page"},{"location":"#Example","page":"Quick start","title":"Example","text":"","category":"section"},{"location":"","page":"Quick start","title":"Quick start","text":"Consider an example with ","category":"page"},{"location":"","page":"Quick start","title":"Quick start","text":"unit cost = 5  \nunit price = 7\ndemand that draws from a normal distribution with \nmean = 50 \nstandard deviation = 20","category":"page"},{"location":"","page":"Quick start","title":"Quick start","text":"Define the model and store it in the variable nvm as follows:","category":"page"},{"location":"","page":"Quick start","title":"Quick start","text":"julia> nvm = NVModel(5, 7, Normal(50, 20))","category":"page"},{"location":"","page":"Quick start","title":"Quick start","text":"Julia shows the model data:","category":"page"},{"location":"","page":"Quick start","title":"Quick start","text":"Data of the Newsvendor Model\n * Unit cost: 5.00\n * Unit selling price: 7.00\n * Demand distribution: Normal{Float64}(μ=50.0, σ=20.0)","category":"page"},{"location":"","page":"Quick start","title":"Quick start","text":"Next, you can solve the model and store the result in the variable res like so:","category":"page"},{"location":"","page":"Quick start","title":"Quick start","text":"julia> res = optimize(nvm)","category":"page"},{"location":"","page":"Quick start","title":"Quick start","text":"This gives the following output:","category":"page"},{"location":"","page":"Quick start","title":"Quick start","text":"=====================================\nResults of maximizing expected profit\n * Optimal quantity: 39 units\n * Expected profit: 52.69\n=====================================\nThis is a consequence of\n * Cost of underage: 2.00\n * Cost of overage: 5.00\n * The critical fractile: 0.29\n * Usage of round-up rule: true\n-------------------------------------\nOrdering the optimal quantity yields\n * Expected sales: 35.38 units\n * Expected lost sales: 14.62 units\n * Expected leftover: 3.62 units\n * Expected backlog penalty: 0.00\n-------------------------------------","category":"page"},{"location":"","page":"Quick start","title":"Quick start","text":"Moreover, you have stored the result in the varial res. Reading the data from the stored result is straight-forward:","category":"page"},{"location":"","page":"Quick start","title":"Quick start","text":"julia> q_opt(res)\n39","category":"page"},{"location":"","page":"Quick start","title":"Quick start","text":"julia> profit(res)\n52.687735385066865","category":"page"},{"location":"","page":"Quick start","title":"Quick start","text":"Analogously, underage_cost(res), overage_cost(res), critical_fractile(res),  roundup_rule(res), sales(res), lost_sales(res), leftover(res), penalty(res),  read the other information the stored in res. The model that was solved can be retrieved with nvmodel(res).","category":"page"}]
}
