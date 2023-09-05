using Documenter
using SunCalc
using Dates

makedocs(;
    modules=[SunCalc],
    pages=["Getting started" => "index.md",
        "Functions" => "functions.md"],
    repo = "https://github.com/g-rppl/SunCalc.jl/blob/{commit}{path}#{line}",
    sitename="SunCalc.jl",
    authors="Georg Rüppel"
)

deploydocs(
    repo = "github.com/g-rppl/SunCalc.jl.git"
)