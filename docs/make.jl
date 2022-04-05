using Documenter
using NewsvendorModel
using Distributions

makedocs(
    sitename = "NewsvendorModel.jl",
    format = Documenter.HTML(),
    modules = [NewsvendorModel]
)

deploydocs(
    repo = "github.com/frankhuettner/NewsvendorModel.jl.git",
    devbranch = "main",
)    