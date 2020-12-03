using SWIM
using Documenter

makedocs(;
    modules=[SWIM],
    authors="Luigi Crisci <luigicrisci1997@gmail.com> and contributors",
    repo="https://github.com/Luigi-Crisci/SWIM.jl/blob/{commit}{path}#L{line}",
    sitename="SWIM.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://Luigi-Crisci.github.io/SWIM.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/Luigi-Crisci/SWIM.jl",
)
