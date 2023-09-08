## About

Julia implementation of the [SunCalc](https://github.com/mourner/suncalc/) package for 
calculating sun position, sunlight phases (times for sunrise, sunset, dusk, etc.), 
moon position, and lunar phase for the given location and time for the given location and time.

Most calculations are based on the formulas given in the Astronomy Answers articles
about [position of the sun](https://www.aa.quae.nl/en/reken/zonpositie.html)
and [the planets](https://www.aa.quae.nl/en/reken/hemelpositie.html).
You can find more information on twilight phases calculated by SunCalc.jl
in the [Twilight article on Wikipedia](https://en.wikipedia.org/wiki/Twilight).

## Installation

The package is registered in the [General registry](https://github.com/JuliaRegistries/General)
and can therefore be installed with:

```julia
using Pkg
pkg.add("SunCalc")
```