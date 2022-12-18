using ScienceProjectTemplate
using Documenter

DocMeta.setdocmeta!(ScienceProjectTemplate, :DocTestSetup, 
    :(using ScienceProjectTemplate); 
    recursive=true)

prettyurls = get(ENV, "CI", nothing) == "true"
mathengine = MathJax3()
    
makedocs(;
    modules = [ScienceProjectTemplate],
    doctest = true, 
    clean = true,    
    format= Documenter.HTML(; mathengine, prettyurls, assets=assets),
    sitename = "ScienceProjectTemplate.jl",
    pages = ["Home" => "index.md",
            ],
)

deploydocs(repo="github.com/CarloLucibello/ScienceProjectTemplate.jl.git")
