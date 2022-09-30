using Documenter
using NewsvendorModel
using Distributions
# import Pkg; Pkg.add("PlutoStaticHTML")
using PlutoStaticHTML

"""
Run all Pluto tutorials notebooks (".jl" files) in and write output to Markdown files.
"""
function build_tutorials()
    println("Building tutorials")
    tutorials_dir = joinpath(@__DIR__, "src", "textbook")
    previous_dir = joinpath(@__DIR__, "src", "textbook")

     
    # Evaluate notebooks in the same process to avoid having to recompile from scratch each time.
    # This is similar to how Documenter and Franklin evaluate code.
    # Note that things like method overrides may leak between notebooks!
    bopts = BuildOptions(tutorials_dir ; 
                        previous_dir = previous_dir, 
                        use_distributed = false, 
                        output_format = documenter_output)
    build_notebooks(bopts)
    return nothing
end

# # Build the notebooks; defaults to "true".
# if get(ENV, "BUILD_DOCS_NOTEBOOKS", "true") == "true"
#     build_tutorials()
# end


makedocs(
    sitename = "NewsvendorModel.jl",
    modules = [NewsvendorModel],
    doctest = false,
    authors = "Frank Huettner and contributors",
    format = Documenter.HTML(),
    pages = [
            "Quick Start" => "index.md",
            "Further Options when specifying the model" => "x20_model_options.md",
            "Rounded Output" => "x21_optimize_options.md",
            "Demand Distribution" => "x30_distributions.md",
            "Textbook Examples" => ["Cachon and Terwiesch" => "textbook/cachon+terwiesch.md",
                                    "Nahmias and Olsen" => "textbook/nahmias+olsen.md",
            ],
            "Library" => "x50_library.md",
    ]
)

deploydocs(
    repo = "github.com/frankhuettner/NewsvendorModel.jl.git",
    devbranch = "main",
)    
